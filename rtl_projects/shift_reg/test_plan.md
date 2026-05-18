# Shift Register Verification Test Plan

## Corner Cases

### 1. Reset during shift
  Mid-shift, assert rst — data must clear to 0 immediately
  Risk: rst ignored if enable has higher priority in implementation

### 2. Load vs shift priority
  load=1 and enable=1 simultaneously
  load must win — data_out = load_data
  Risk: enable wins instead — wrong data

### 3. Shift left boundary
  data=4'b1000 shift left — MSB lost, LSB gets serial_in
  Risk: MSB wraps to LSB (circular shift instead of linear)

### 4. Shift right boundary
  data=4'b0001 shift right — LSB lost, MSB gets serial_in
  Risk: LSB wraps to MSB

### 5. Serial in = 0 vs 1
  Verify serial_in=0 shifts in 0
  Verify serial_in=1 shifts in 1
  Risk: serial_in path not connected

### 6. Enable = 0 hold
  data must not change when enable=0 and load=0
  Risk: data shifts anyway — enable ignored

### 7. Full shift through (N shifts)
  After N shifts, original data completely gone
  After N more, all serial_in values
  Risk: off-by-one in shift count

### 8. Parallel load all zeros
  load=1, load_data=0 — data_out must go to 0
  Looks like reset — must verify it is load not rst

### 9. Parallel load all ones
  load=1, load_data=4'hF
  Risk: width mismatch in load path

### 10. Direction change mid-shift
  Shift left 2, change direction, shift right 2
  Risk: direction change causes glitch

## Bug Analysis

### Bug 1 — Load priority wrong
  Symptom : enable=1 load=1 — data shifts instead of loading
  Waveform : data_out changes by one shift instead of jumping to load_data
  Fix      : check load before enable in if-else chain

### Bug 2 — Serial in not connected
  Symptom : shift left always shifts in 0 regardless of serial_in
  Waveform : LSB always 0 after every left shift
  Fix      : ensure serial_in drives LSB in left shift expression

### Bug 3 — Circular shift instead of linear
  Symptom : MSB reappears at LSB after shift left
  Waveform : data appears to rotate rather than shift
  Fix      : use serial_in at boundary, not data_out[MSB]

### Bug 4 — Enable ignored
  Symptom : data shifts even when enable=0
  Waveform : data changes on every clock edge
  Fix      : enable condition in always_ff

## Regression Tests
  Test 1 : basic_shift_test    — left/right shift, serial_in, hold
  Test 2 : boundary_test       — MSB/LSB boundary, full shift through
  Test 3 : reset_load_test     — reset during shift, load priority
  Test 4 : random_shift_test   — random direction, serial_in, enable

## Assertions
  - After rst: data_out must be 0
  - load=1: next cycle data_out === load_data
  - enable=0 and load=0: data_out unchanged next cycle
  - After N left shifts with serial_in=0: data_out must be 0
  - After N right shifts with serial_in=1: data_out must be all 1s

## Coverage Points
  - direction = 0 and direction = 1
  - serial_in = 0 and serial_in = 1
  - enable = 0 (hold) and enable = 1 (shift)
  - load = 1 (parallel load)
  - load and enable simultaneously (priority test)
  - rst during shift
  - all data_out values 0x0 to 0xF
  - full shift-through (data completely replaced)