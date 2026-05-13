input_file  = "../sample_logs/sim1.log"
output_file = "../reports/summary.txt"

errors     = []
warnings   = []
fatals     = []
assertions = []

with open(input_file, "r") as f:
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

if len(errors) == 0 and len(fatals) == 0 and len(assertions) == 0:
    verdict = "PASS"
else:
    verdict = "FAIL"

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

with open(output_file, "w") as f:
    f.write(report)

print(f"\nReport saved to: {output_file}")