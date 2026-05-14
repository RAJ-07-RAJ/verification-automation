import os
from datetime import datetime

logs_folder = "sample_logs"
output_file = "reports/regression_report.txt"

log_files = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

results = []

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)

    errors     = 0
    warnings   = 0
    fatals     = 0
    assertions = 0

    with open(filepath, "r") as f:
        for line in f:
            if "UVM_ERROR"          in line: errors     += 1
            elif "UVM_FATAL"        in line: fatals     += 1
            elif "UVM_WARNING"      in line: warnings   += 1
            elif "ASSERTION FAILED" in line: assertions += 1

    verdict = "PASS" if errors == 0 and fatals == 0 and assertions == 0 else "FAIL"

    results.append({
        "file"      : filename,
        "errors"    : errors,
        "warnings"  : warnings,
        "fatals"    : fatals,
        "assertions": assertions,
        "verdict"   : verdict
    })

total     = len(results)
passed    = sum(1 for r in results if r["verdict"] == "PASS")
failed    = total - passed
pass_rate = round((passed / total) * 100) if total > 0 else 0
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 55)
lines.append("  REGRESSION SUMMARY")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 55)
lines.append(f"  Total     : {total}")
lines.append(f"  Passed    : {passed}")
lines.append(f"  Failed    : {failed}")
lines.append(f"  Pass rate : {pass_rate}%")
lines.append("=" * 55)
lines.append("")
lines.append(f"{'FILE':<20} {'ERR':>4} {'WARN':>5} {'FATAL':>6} {'ASSERT':>7} {'VERDICT':>8}")
lines.append("-" * 55)

for r in results:
    lines.append(
        f"{r['file']:<20} {r['errors']:>4} {r['warnings']:>5} "
        f"{r['fatals']:>6} {r['assertions']:>7} {r['verdict']:>8}"
    )

lines.append("")
lines.append("FAILED TESTS:")
for r in results:
    if r["verdict"] == "FAIL":
        lines.append(f"  {r['file']:<20} errors={r['errors']}  fatals={r['fatals']}  assertions={r['assertions']}")

report = "\n".join(lines)
print(report)

with open(output_file, "w") as f:
    f.write(report)

print(f"\nSaved to: {output_file}")