import subprocess
import os
from datetime import datetime

design_dir  = "rtl_projects/adder"
log_dir     = "rtl_projects/adder/logs"
report_dir  = "reports"
os.makedirs(log_dir,    exist_ok=True)
os.makedirs(report_dir, exist_ok=True)

log_file    = f"{log_dir}/adder_sim.log"
report_file = f"{report_dir}/adder_report.txt"

print("=" * 55)
print("  Adder Simulation Runner")
print("=" * 55)

# compile — all 3 files together
print("\n[1] Compiling...")
compile_cmd = [
    "iverilog", "-g2012",
    "-o", f"{design_dir}/adder.vvp",
    f"{design_dir}/adder.sv",
    f"{design_dir}/assertions.sv",
    f"{design_dir}/coverage.sv",
    f"{design_dir}/tb_adder.sv"
]

result = subprocess.run(compile_cmd, capture_output=True, text=True)
if result.returncode != 0:
    print("COMPILE FAILED:")
    print(result.stderr)
    exit(1)
print("Compile: PASSED")

# simulate
print("\n[2] Simulating...")
with open(log_file, "w", encoding="utf-8") as lf:
    subprocess.run(["vvp", f"{design_dir}/adder.vvp"], stdout=lf, stderr=lf)
print(f"Done. Log: {log_file}")

# parse
print("\n[3] Parsing...")
errors = warnings = passes = assertions = 0
with open(log_file, "r", encoding="utf-8") as f:
    for line in f:
        if "UVM_ERROR"        in line: errors     += 1
        elif "UVM_WARNING"    in line: warnings   += 1
        elif "UVM_INFO: [PASS]" in line: passes   += 1
        elif "ASSERTION FAILED" in line: assertions += 1

verdict = "PASS" if errors == 0 and assertions == 0 else "FAIL"
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 55)
lines.append("  ADDER VERIFICATION REPORT")
lines.append(f"  Generated  : {timestamp}")
lines.append("=" * 55)
lines.append(f"  Verdict    : {verdict}")
lines.append(f"  Tests run  : {passes + errors}")
lines.append(f"  Passed     : {passes}")
lines.append(f"  Failed     : {errors}")
lines.append(f"  Assertions : {assertions} failures")
lines.append("=" * 55)

report = "\n".join(lines)
print("\n" + report)

with open(report_file, "w", encoding="utf-8") as f:
    f.write(report)
print(f"\nSaved: {report_file}")