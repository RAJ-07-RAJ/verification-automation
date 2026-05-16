import sys
import os
import random
import time

# This mimics what a real simulator does:
# - takes a test name and seed as arguments
# - runs for some time
# - writes a log file
# - exits with 0 (pass) or 1 (fail)
#
# Real usage would be:
#   vcs +UVM_TESTNAME=axi_test +ntb_random_seed=42
# We simulate that exact behaviour here.

test_name = sys.argv[1] if len(sys.argv) > 1 else "default_test"
seed      = sys.argv[2] if len(sys.argv) > 2 else "1"
log_dir   = sys.argv[3] if len(sys.argv) > 3 else "log_parser/sim_runs"

os.makedirs(log_dir, exist_ok=True)

log_file = os.path.join(log_dir, f"{test_name}_seed{seed}.log")

# deterministic pass/fail based on test name
# in real sim this comes from actual RTL behaviour
fail_tests = ["axi_burst_test", "axi_stress_test", "axi_reset_test"]
should_fail = test_name in fail_tests

lines = []
lines.append(f"# Simulation Log")
lines.append(f"# Test : {test_name}")
lines.append(f"# Seed : {seed}")
lines.append(f"[0ns]    INFO: Simulation started")
lines.append(f"[10ns]   INFO: Reset asserted")
lines.append(f"[50ns]   INFO: Reset released")
lines.append(f"[100ns]  UVM_INFO: Starting test {test_name}")

if should_fail:
    lines.append(f"[300ns]  UVM_ERROR: uvm_test_top.env.scoreboard [SCB] Data mismatch ADDR=0x0010 EXP=0xDEAD GOT=0x0000")
    lines.append(f"[500ns]  UVM_ERROR: uvm_test_top.env.scoreboard [SCB] Data mismatch ADDR=0x0020 EXP=0xBEEF GOT=0xFFFF")
    if "stress" in test_name:
        lines.append(f"[700ns]  ASSERTION FAILED: axi_slave.sv:88 - RVALID asserted without ARVALID")
        lines.append(f"[800ns]  UVM_FATAL: uvm_test_top [SCB] Too many errors - stopping simulation")
    lines.append(f"[900ns]  INFO: Simulation ended")
    lines.append(f"# UVM_ERROR  : 2")
    lines.append(f"# UVM_FATAL  : {'1' if 'stress' in test_name else '0'}")
else:
    lines.append(f"[300ns]  UVM_INFO: All transactions complete")
    lines.append(f"[400ns]  UVM_INFO: Scoreboard clean - no mismatches")
    lines.append(f"[500ns]  INFO: Simulation ended")
    lines.append(f"# UVM_ERROR  : 0")
    lines.append(f"# UVM_FATAL  : 0")

with open(log_file, "w") as f:
    f.write("\n".join(lines))

# exit code 0 = pass, 1 = fail — exactly like a real simulator
sys.exit(1 if should_fail else 0)