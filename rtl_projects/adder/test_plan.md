# Adder Verification Test Plan

## Corner Cases

### 1. Maximum value overflow
  a=4'hF b=4'hF cin=1
  Expected: sum=4'hF cout=1 (unsigned overflow)
  Risk: cout not asserted — result silently wraps

### 2. Zero addition
  a=0 b=0 cin=0
  Expected: sum=0 cout=0 ovflow=0
  Risk: X propagation from uninitialised inputs

### 3. Carry-in effect at boundary
  a=4'hF b=4'h0 cin=1
  Expected: sum=0 cout=1
  Risk: cin ignored in implementation

### 4. Signed overflow — positive + positive = negative
  a=4'b0111 b=4'b0001 cin=0  (7 + 1 = 8 → reads as -8 in signed)
  Expected: ovflow=1
  Risk: ovflow flag not generated correctly

### 5. Signed overflow — negative + negative = positive
  a=4'b1000 b=4'b1000 cin=0  (-8 + -8 = -16 → wraps to 0)
  Expected: ovflow=1
  Risk: sign extension not handled

### 6. No overflow — negative + positive
  a=4'b1111 b=4'b0001 cin=0  (-1 + 1 = 0 signed, valid)
  Expected: ovflow=0 sum=0 cout=1
  Risk: cout wrongly treated as overflow

### 7. cin=1 with a=0 b=0
  Expected: sum=1 cout=0
  Risk: cin path not exercised

### 8. All ones
  a=4'hF b=4'hF cin=0
  Expected: sum=4'hE cout=1

### 9. Identical operands
  a=4'h5 b=4'h5 cin=0
  Expected: sum=4'hA cout=0

### 10. MSB boundary
  a=4'b1000 b=4'b0111 cin=0  (-8 + 7 = -1, no overflow)
  Expected: sum=4'hF ovflow=0

## Bug Analysis

### Bug 1 — Missing cin in implementation
  Symptom : a=0xF b=0x0 cin=1 gives sum=0xF instead of 0x0
  Waveform : sum stays at F when cin goes high
  Silicon  : all carry-in dependent results wrong in hardware
  Fix      : ensure cin included in addition expression

### Bug 2 — Wrong overflow logic
  Symptom : ovflow asserted when cout=1 (unsigned overflow)
  Waveform : ovflow goes high at a=F b=F which is NOT signed overflow
  Silicon  : processor exception triggered incorrectly
  Fix      : ovflow is MSB sign check, not cout

### Bug 3 — Width truncation
  Symptom : result truncated to WIDTH bits, cout lost
  Waveform : cout never asserts even at max values
  Silicon  : carry chain broken, arithmetic unit wrong
  Fix      : use WIDTH+1 intermediate result

### Bug 4 — X propagation on reset
  Symptom : combinational block — no reset needed but
            if inputs are X at time 0, output is X
  Waveform : sum=XXXX at t=0
  Silicon  : no issue (inputs always driven in real design)
  Fix      : TB must drive all inputs before checking outputs

## Directed Test Cases

| Test               | a      | b      | cin | Expected sum | cout | ovflow |
|--------------------|--------|--------|-----|--------------|------|--------|
| zero_add           | 0x0    | 0x0    | 0   | 0x0          | 0    | 0      |
| max_no_cin         | 0xF    | 0xF    | 0   | 0xE          | 1    | 0      |
| max_with_cin       | 0xF    | 0xF    | 1   | 0xF          | 1    | 0      |
| signed_pos_ovflow  | 0x7    | 0x1    | 0   | 0x8          | 0    | 1      |
| signed_neg_ovflow  | 0x8    | 0x8    | 0   | 0x0          | 1    | 1      |
| cin_only           | 0x0    | 0x0    | 1   | 0x1          | 0    | 0      |
| no_ovflow_mixed    | 0xF    | 0x1    | 0   | 0x0          | 1    | 0      |
| boundary_msb       | 0x8    | 0x7    | 0   | 0xF          | 0    | 0      |

## Constrained Random Ideas
- Random a, b, cin — 10000 combinations
- Bias toward boundary values (0, 1, 7, 8, 14, 15)
- Force cin=1 in 50% of tests
- Force a==b in 20% of tests
- Force MSB of both equal in 30% of tests

## Assertions
- cout must be 1 whenever result > 2^WIDTH - 1
- ovflow must be 1 only when signs of a and b match but sign of sum differs
- sum must always equal (a + b + cin) % 2^WIDTH
- ovflow and cout are independent — both can be 1 or 0 simultaneously

## Functional Coverage Points
- All values of a (0 to 15)
- All values of b (0 to 15)
- cin = 0 and cin = 1
- cout = 0 and cout = 1
- ovflow = 0 and ovflow = 1
- Both cout and ovflow asserted simultaneously
- a == b (identical operands)
- a == 0 or b == 0 (zero operand)
- a == 4'hF or b == 4'hF (max operand)
- Cross coverage: a_val × b_val × cin