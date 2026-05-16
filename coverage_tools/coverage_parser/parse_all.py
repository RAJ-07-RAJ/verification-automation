import re
import os

cov_folder = "coverage_tools/sample_coverage"
cov_files  = sorted([f for f in os.listdir(cov_folder) if f.endswith(".txt")])

def parse_coverage(filepath):
    result = {
        "run"            : "",
        "overall"        : 0.0,
        "line_coverage"  : {},
        "func_coverage"  : {},
        "toggle_coverage": {}
    }
    section       = None
    current_file  = None
    current_group = None

    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()

            m = re.search(r"#\s*Run\s*:\s*(\S+)", line)
            if m:
                result["run"] = m.group(1)

            if "LINE COVERAGE"       in line: section = "line"
            elif "FUNCTIONAL COVERAGE" in line: section = "func"
            elif "TOGGLE COVERAGE"   in line: section = "toggle"

            m = re.search(r"File:\s+(\S+)", line)
            if m: current_file = m.group(1)

            m = re.search(r"Group:\s+(\S+)", line)
            if m: current_group = m.group(1)

            m = re.search(r"Coverage\s*:\s*([\d.]+)%", line)
            if m:
                pct = float(m.group(1))
                if section == "line" and current_file:
                    result["line_coverage"][current_file] = pct
                elif section == "func" and current_group:
                    result["func_coverage"][current_group] = pct
                elif section == "toggle" and current_file:
                    result["toggle_coverage"][current_file] = pct

            m = re.search(r"OVERALL COVERAGE\s*:\s*([\d.]+)%", line)
            if m:
                result["overall"] = float(m.group(1))

    return result

all_runs = []
for filename in cov_files:
    filepath = os.path.join(cov_folder, filename)
    data = parse_coverage(filepath)
    data["filename"] = filename
    all_runs.append(data)

# overall trend
print("OVERALL COVERAGE TREND:")
print(f"{'RUN':<12} {'OVERALL':>8}  TREND")
print("-" * 40)
prev = None
for r in all_runs:
    overall = r["overall"]
    if prev is None:
        trend = "  --"
    elif overall > prev:
        trend = f"  ▲ +{overall - prev:.2f}%"
    elif overall < prev:
        trend = f"  ▼ -{prev - overall:.2f}%"
    else:
        trend = "  → no change"
    print(f"{r['run']:<12} {overall:>7}%  {trend}")
    prev = overall

# functional coverage gaps
print("\nFUNCTIONAL COVERAGE — LATEST RUN:")
latest = all_runs[-1]
for group, pct in sorted(latest["func_coverage"].items(), key=lambda x: x[1]):
    bar    = "#" * int(pct / 5)
    gap    = 100 - pct
    flag   = "  ← NEEDS WORK" if pct < 70 else ""
    print(f"  {group:<25} {pct:>6}%  [{bar:<20}]{flag}")