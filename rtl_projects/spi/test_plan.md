# SPI Master/Slave Verification Test Plan

## Corner Cases

### 1. CS_N timing violation
  CS_N must be LOW before first SCLK edge
  Risk: first bit shifted before CS asserted — slave misses bit[7]

### 2. MOSI/MISO simultaneous — full duplex
  Both directions active same cycle
  Risk: one direction interferes with other

### 3. Transmit 0x00 — all MOSI LOW
  All bits LOW on wire
  Risk: indistinguishable from idle SCLK

### 4. Transmit 0xFF — all MOSI HIGH
  Risk: slave sees continuous HIGH — misses bit boundaries

### 5. Back-to-back transfers
  start immediately after done
  CS_N must deassert and reassert between transfers
  Risk: CS_N never deasserts — slave doesn't see frame boundary

### 6. start ignored during transfer
  Assert start while transfer in progress
  Expected: ignored until IDLE
  Risk: transfer corrupted mid-byte

### 7. done pulse width — exactly 1 cycle
  Risk: done stays high — double-trigger

### 8. SCLK frequency
  Each bit = 2 × CLK_DIV clock cycles
  Risk: off-by-one — SCLK faster or slower than spec

### 9. Loopback — master receives what slave echoes
  Send byte N, slave echoes it, master receives N on next transfer
  Risk: bit order reversed, shift register direction wrong

### 10. MSB first verification
  Send 0x80 — first MOSI bit must be HIGH
  Send 0x01 — first MOSI bit must be LOW
  Risk: LSB first implementation

## Bug Analysis

### Bug 1 — start accepted during transfer
  Symptom : new data loaded mid-byte — corrupts current frame
  Waveform : MOSI changes unexpectedly mid-transfer
  Fix      : only accept start in IDLE state

### Bug 2 — SCLK not gated by CS
  Symptom : SCLK toggles before CS_N asserted
  Waveform : slave sees SCLK before CS — ignores transfer
  Fix      : gate SCLK output with active signal

### Bug 3 — MSB/LSB order wrong
  Symptom : 0x80 sent as 0x01 at receiver
  Waveform : first MOSI bit is LOW for 0x80 (should be HIGH)
  Fix      : start bit_cnt at 7, decrement downward

### Bug 4 — MISO sampled on wrong edge
  Symptom : received byte one bit offset from sent byte
  Waveform : shift_in shifts on falling instead of rising
  Fix      : CPHA=0 — sample on rising, shift on falling

### Bug 5 — CS_N deasserts before last bit sampled
  Symptom : last bit of MISO not captured
  Waveform : CS_N goes HIGH during last SCLK cycle
  Fix      : FINISH state waits one more half-period

## Assertions
  - CS_N must be LOW throughout TRANSFER state
  - SCLK must be LOW when CS_N is HIGH
  - done must be exactly 1 cycle
  - done must only assert in IDLE transition
  - bit_cnt must never exceed 7

## Coverage Points
  - All 256 MOSI data values
  - 0x00 and 0xFF (boundary patterns)
  - 0x55 and 0xAA (alternating)
  - 0x01 and 0x80 (single bit MSB/LSB)
  - done observed
  - rx_valid observed on slave
  - back-to-back transfers
  - start during transfer (ignored check)
  - full loopback round-trip verified