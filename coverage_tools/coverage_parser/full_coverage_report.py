import re
import os
import csv
from datetime import datetime

cov_folder  = "coverage_tools/sample_coverage"
output_txt  = "reports/coverage_report.txt"
output_csv  = "reports/coverage_trend.csv"
cov_files   = sorted([f for f in os.listdir(cov_folder) if f.endswith(".txt")])

def parse_coverage(filepath):
    result = {
        "run": "", "overall": 0.0,
        "line_coverage": {}, "func_coverage": {}, "toggle_coverage": {}
    }
    section = current_file = current_group = None
    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()
            m = re.search(r"#\s*Run\s*:\s*(\S+)", line)
            if m: result["run"] = m.group(1)
            if "LINE COVERAGE"        in line: section = "line"
            elif "FUNCTIONAL COVERAGE" in line: section = "func"
            elif "TOGGLE COVERAGE"    in line: section = "toggle"
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
            if m: result["overall"] = float(m.group(1))
    return result

all_runs = []
for filename in cov_files:
    data = parse_coverage(os.path.join(cov_folder, filename))
    data["filename"] = filename
    all_runs.append(data)

latest    = all_runs[-1]
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 60)
lines.append("  COVERAGE REPORT")
lines.append(f"  Generated  : {timestamp}")
lines.append(f"  Runs found : {len(all_runs)}")
lines.append("=" * 60)

# overall trend
lines.append("\nOVERALL COVERAGE TREND:")
lines.append(f"  {'RUN':<10} {'OVERALL':>8}  DELTA")
lines.append("  " + "-" * 35)
prev = None
for r in all_runs:
    o = r["overall"]
    delta = f"+{o-prev:.2f}%" if prev and o > prev else (f"-{prev-o:.2f}%" if prev else "--")
    lines.append(f"  {r['run']:<10} {o:>7}%  {delta}")
    prev = o

# line coverage latest
lines.append(f"\nLINE COVERAGE — {latest['run']}:")
lines.append(f"  {'FILE':<20} {'COVERAGE':>10}  {'STATUS'}")
lines.append("  " + "-" * 45)
for fname, pct in sorted(latest["line_coverage"].items(), key=lambda x: x[1]):
    status = "OK" if pct >= 90 else "NEEDS WORK" if pct < 75 else "ACCEPTABLE"
    lines.append(f"  {fname:<20} {pct:>9}%  {status}")

# functional coverage latest + gaps
lines.append(f"\nFUNCTIONAL COVERAGE — {latest['run']}:")
lines.append(f"  {'GROUP':<25} {'COVERAGE':>10}  {'GAP':>6}  STATUS")
lines.append("  " + "-" * 55)
gaps = []
for group, pct in sorted(latest["func_coverage"].items(), key=lambda x: x[1]):
    gap    = round(100 - pct, 2)
    status = "OK" if pct >= 90 else "NEEDS WORK" if pct < 70 else "ACCEPTABLE"
    lines.append(f"  {group:<25} {pct:>9}%  {gap:>5}%  {status}")
    if pct < 90:
        gaps.append((group, pct, gap))

# coverage gaps summary
if gaps:
    lines.append(f"\nCOVERAGE GAPS (below 90%):")
    lines.append("  Priority order — lowest coverage first:")
    for group, pct, gap in gaps:
        lines.append(f"  → {group:<25} {pct}%  ({gap}% uncovered)")

# toggle coverage
lines.append(f"\nTOGGLE COVERAGE — {latest['run']}:")
for fname, pct in latest["toggle_coverage"].items():
    lines.append(f"  {fname:<20} {pct}%")

lines.append("\n" + "=" * 60)

report = "\n".join(lines)
print(report)

with open(output_txt, "w", encoding="utf-8") as f:
    f.write(report)

# save trend CSV for pandas
with open(output_csv, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["run", "overall"] +
                    list(all_runs[0]["func_coverage"].keys()))
    for r in all_runs:
        row = [r["run"], r["overall"]] + list(r["func_coverage"].values())
        writer.writerow(row)

print(f"\nSaved: {output_txt}")
print(f"Saved: {output_csv}")