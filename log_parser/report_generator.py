import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import paths

input_file = paths.SAMPLE_LOGS / "sim1.log"
output_file = paths.REPORTS / "summary.txt"

errors = []
warnings = []
fatals = []
assertions = []

with open(input_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if "UVM_ERROR" in line:
            errors.append(line)
        elif "UVM_FATAL" in line:
            fatals.append(line)
        elif "UVM_WARNING" in line:
            warnings.append(line)
        elif "ASSERTION FAILED" in line:
            assertions.append(line)

verdict = "PASS" if not errors and not fatals and not assertions else "FAIL"

lines = []
lines.append("=" * 45)
lines.append("  SIMULATION REPORT")
lines.append("=" * 45)
lines.append(f"  Log file  : {input_file}")
lines.append(f"  Verdict   : {verdict}")
lines.append("-" * 45)
lines.append(f"  UVM_ERROR     : {len(errors)}")
lines.append(f"  UVM_WARNING   : {len(warnings)}")
lines.append(f"  UVM_FATAL     : {len(fatals)}")
lines.append(f"  ASSERTIONS    : {len(assertions)}")
lines.append("=" * 45)

if errors:
    lines.append("\nERRORS:")
    for e in errors:
        lines.append("  " + e)

if assertions:
    lines.append("\nASSERTIONS:")
    for a in assertions:
        lines.append("  " + a)

if fatals:
    lines.append("\nFATALS:")
    for ff in fatals:
        lines.append("  " + ff)

report = "\n".join(lines)
print(report)

paths.REPORTS.mkdir(parents=True, exist_ok=True)
with open(output_file, "w", encoding="utf-8") as f:
    f.write(report)

print(f"\nReport saved to: {output_file}")
