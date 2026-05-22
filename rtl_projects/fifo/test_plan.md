# FIFO Verification Test Plan

## Corner Cases

### 1. Write to full FIFO (overflow attempt)
  Write when full=1
  Expected: wr_ptr unchanged, count unchanged, data not written
  Risk: wr_ptr increments anyway — pointer corrupted

### 2. Read from empty FIFO (underflow attempt)
  Read when empty=1
  Expected: rd_ptr unchanged, count unchanged, rd_data unchanged
  Risk: rd_ptr increments anyway — reading garbage

### 3. Simultaneous read and write
  wr_en=1 and rd_en=1 at same time, FIFO half full
  Expected: count unchanged, new data written, old data read
  Risk: count double-increments or double-decrements

### 4. Simultaneous read and write when full
  wr_en=1 rd_en=1 full=1
  Expected: write happens (rd freed space), read happens
  Actually: in this RTL — wr blocked when full, rd happens
  Risk: deadlock — nothing ever gets written when full

### 5. Simultaneous read and write when empty
  wr_en=1 rd_en=1 empty=1
  Expected: write happens, read blocked
  Risk: read happens on stale data

### 6. Fill completely then drain completely
  Write DEPTH items, verify full
  Read DEPTH items, verify empty
  Verify all data correct and in order

### 7. Pointer wrap-around
  Fill to DEPTH, drain completely, fill again
  Pointers wrap — verify no corruption

### 8. Single entry FIFO behaviour
  Write one, read one — verify correct
  Simultaneous write+read on single entry

### 9. Reset mid-operation
  Reset during active write — all pointers cleared
  After reset, FIFO behaves as if fresh

### 10. Data integrity — FIFO order
  Write known sequence: 1,2,3,4,5,6,7,8
  Read back — must come out in same order (FIFO not LIFO)

## Bug Analysis

### Bug 1 — Write to full FIFO corrupts pointer
  Symptom : wr_ptr increments even when full=1
  Waveform : wr_ptr goes to DEPTH, wraps to 0, overwrites old data
  Silicon  : data corruption — oldest data silently overwritten
  Fix      : guard write with !full check

### Bug 2 — Simultaneous read/write count error
  Symptom : count increments when both rd and wr active
  Waveform : count goes to DEPTH+1 — impossible value
  Silicon  : full flag never asserts — FIFO overflows silently
  Fix      : case statement handles all 4 combinations

### Bug 3 — Empty flag one cycle late
  Symptom : rd_en=1 when count goes to 0 — empty asserts next cycle
             but read happens this cycle on stale data
  Waveform : one extra read after FIFO empties
  Silicon  : processor reads garbage data
  Fix      : empty based on count_r directly, updated same cycle

### Bug 4 — Pointer width wrong
  Symptom : wr_ptr or rd_ptr only goes to DEPTH/2 before wrapping
  Waveform : wr_ptr wraps at 4 for DEPTH=8
  Silicon  : half the FIFO memory never used
  Fix      : pointer width = $clog2(DEPTH)

### Bug 5 — Data order wrong (LIFO behaviour)
  Symptom : rd_data comes out in reverse order
  Waveform : write 1,2,3 — read gives 3,2,1
  Silicon  : protocol violation — any protocol expecting FIFO order breaks
  Fix      : rd_ptr points to oldest entry, increments after read

## Assertions
  - full must never be 1 when count < DEPTH
  - empty must never be 1 when count > 0
  - count must never exceed DEPTH
  - count must never go below 0
  - wr_ptr must not change when full=1 and wr_en=1
  - rd_ptr must not change when empty=1 and rd_en=1
  - simultaneous rd+wr: count must not change

## Coverage Points
  - full=1 observed
  - empty=1 observed
  - wr_en=1 when full (overflow attempt)
  - rd_en=1 when empty (underflow attempt)
  - simultaneous wr_en=1 rd_en=1
  - count at every value 0 to DEPTH
  - pointer wrap-around observed
  - fill completely and drain completely
  - all data values 0x00 to 0xFF written and read