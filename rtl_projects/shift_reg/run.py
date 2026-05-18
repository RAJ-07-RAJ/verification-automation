import subprocess
import os
from datetime import datetime

design_dir = "rtl_projects/shift_reg"
log_dir    = f"{design_dir}/logs"
rep_dir    = "reports"
os.makedirs(log_dir, exist_ok=True)
os.makedirs(rep_dir, exist_ok=True)

design_file = f"{design_dir}/shift_reg.sv"
timestamp   = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# all 4 tests
tests = [
    {"name": "basic_shift",   "tb": f"{design_dir}/tb_basic_shift.sv"},
    {"name": "boundary",      "tb": f"{design_dir}/tb_boundary.sv"},
    {"name": "reset_load",    "tb": f"{design_dir}/tb_reset_load.sv"},
    {"name": "random_shift",  "tb": f"{design_dir}/tb_random_shift.sv"},
]

print("=" * 55)
print("  Shift Register Regression")
print(f"  {timestamp}")
print("=" * 55)

results = []

for t in tests:
    name    = t["name"]
    tb_file = t["tb"]
    vvp     = f"{design_dir}/{name}.vvp"
    log     = f"{log_dir}/{name}.log"

    print(f"\n[{name}]")

    # compile
    compile_cmd = ["iverilog", "-g2012", "-o", vvp, design_file, tb_file]
    cr = subprocess.run(compile_cmd, capture_output=True, text=True)

    if cr.returncode != 0:
        print(f"  COMPILE FAILED: {cr.stderr.strip()}")
        results.append({"name": name, "verdict": "COMPILE_FAIL",
                        "errors": 0, "passes": 0})
        continue

    print(f"  Compile : PASSED")

    # simulate
    with open(log, "w", encoding="utf-8") as lf:
        subprocess.run(["vvp", vvp], stdout=lf, stderr=lf)

    # parse log
    errors = passes = 0
    with open(log, "r", encoding="utf-8") as f:
        for line in f:
            if "UVM_ERROR" in line: errors  += 1
            elif "UVM_INFO: [PASS]" in line: passes += 1

    verdict = "PASS" if errors == 0 else "FAIL"
    print(f"  Simulate: done")
    print(f"  Verdict : {verdict}  (pass={passes} fail={errors})")

    results.append({
        "name"    : name,
        "verdict" : verdict,
        "errors"  : errors,
        "passes"  : passes
    })

# regression summary
total  = len(results)
passed = sum(1 for r in results if r["verdict"] == "PASS")
failed = total - passed

lines = []
lines.append("\n" + "=" * 55)
lines.append("  SHIFT REGISTER REGRESSION REPORT")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 55)
lines.append(f"  Total tests : {total}")
lines.append(f"  Passed      : {passed}")
lines.append(f"  Failed      : {failed}")
lines.append(f"  Pass rate   : {round(passed/total*100)}%")
lines.append("=" * 55)
lines.append(f"\n{'TEST':<20} {'PASSES':>7} {'ERRORS':>7} {'VERDICT':>8}")
lines.append("-" * 45)
for r in results:
    lines.append(f"{r['name']:<20} {r['passes']:>7} {r['errors']:>7} {r['verdict']:>8}")

if failed > 0:
    lines.append("\nFAILED TESTS:")
    for r in results:
        if r["verdict"] != "PASS":
            lines.append(f"  {r['name']}  errors={r['errors']}")

report = "\n".join(lines)
print(report)

report_file = f"{rep_dir}/shift_reg_regression.txt"
with open(report_file, "w", encoding="utf-8") as f:
    f.write(report)
print(f"\nSaved: {report_file}")