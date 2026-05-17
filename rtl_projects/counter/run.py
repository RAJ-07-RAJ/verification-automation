import subprocess
import os
from datetime import datetime

# paths
design_dir  = "rtl_projects/counter"
log_dir     = "rtl_projects/counter/logs"
report_dir  = "reports"
os.makedirs(log_dir,    exist_ok=True)
os.makedirs(report_dir, exist_ok=True)

log_file    = f"{log_dir}/counter_sim.log"
report_file = f"{report_dir}/counter_report.txt"

print("=" * 50)
print("  Counter Simulation Runner")
print("=" * 50)

# ── step 1: compile ───────────────────────────────────
print("\n[1] Compiling...")

compile_cmd = [
    "iverilog",
    "-g2012",
    "-o", f"{design_dir}/counter.vvp",
    f"{design_dir}/counter.sv",
    f"{design_dir}/tb_counter.sv"
]
print("Compile command:", " ".join(compile_cmd))
compile_result = subprocess.run(compile_cmd, capture_output=True, text=True)

if compile_result.returncode != 0:
    print("COMPILE FAILED:")
    print(compile_result.stderr)
    exit(1)

print("Compile: PASSED")

# ── step 2: simulate ──────────────────────────────────
print("\n[2] Running simulation...")

sim_cmd = ["vvp", f"{design_dir}/counter.vvp"]

sim_result = subprocess.run(sim_cmd, capture_output=True, text=True)

# write log
with open(log_file, "w", encoding="utf-8") as f:
    f.write(sim_result.stdout)

print(f"Simulation done. Log: {log_file}")

# ── step 3: parse log ─────────────────────────────────
print("\n[3] Parsing log...")

errors     = []
warnings   = []
infos      = []

with open(log_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if "UVM_ERROR" in line:
            errors.append(line)
        elif "UVM_WARNING" in line:
            warnings.append(line)
        elif "UVM_INFO" in line:
            infos.append(line)

verdict = "PASS" if len(errors) == 0 else "FAIL"

# ── step 4: generate report ───────────────────────────
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 50)
lines.append("  COUNTER SIMULATION REPORT")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 50)
lines.append(f"  Design    : counter.sv")
lines.append(f"  Testbench : tb_counter.sv")
lines.append(f"  Verdict   : {verdict}")
lines.append("-" * 50)
lines.append(f"  UVM_INFO    : {len(infos)}")
lines.append(f"  UVM_WARNING : {len(warnings)}")
lines.append(f"  UVM_ERROR   : {len(errors)}")
lines.append("=" * 50)

if errors:
    lines.append("\nERRORS:")
    for e in errors:
        lines.append(f"  {e}")

lines.append("\nFULL SIMULATION OUTPUT:")
lines.append("-" * 50)
with open(log_file, "r", encoding="utf-8") as f:
    for line in f:
        lines.append(line.rstrip())

report = "\n".join(lines)
print("\n" + report)

with open(report_file, "w", encoding="utf-8") as f:
    f.write(report)

print(f"\nReport saved: {report_file}")