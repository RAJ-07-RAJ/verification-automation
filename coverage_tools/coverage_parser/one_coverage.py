import re
import os

cov_file = "coverage_tools/sample_coverage/coverage_run1.txt"

line_coverage  = {}
func_coverage  = {}
toggle_coverage = {}
overall        = 0.0

with open(cov_file, "r") as f:
    current_file  = None
    current_group = None
    section       = None

    for line in f:
        line = line.strip()

        # detect section
        if "LINE COVERAGE" in line:
            section = "line"
        elif "FUNCTIONAL COVERAGE" in line:
            section = "func"
        elif "TOGGLE COVERAGE" in line:
            section = "toggle"

        # extract file name
        m = re.search(r"File:\s+(\S+)", line)
        if m:
            current_file = m.group(1)

        # extract group name
        m = re.search(r"Group:\s+(\S+)", line)
        if m:
            current_group = m.group(1)

        # extract coverage percentage
        m = re.search(r"Coverage\s*:\s*([\d.]+)%", line)
        if m:
            pct = float(m.group(1))
            if section == "line" and current_file:
                line_coverage[current_file] = pct
            elif section == "func" and current_group:
                func_coverage[current_group] = pct
            elif section == "toggle" and current_file:
                toggle_coverage[current_file] = pct

        # overall
        m = re.search(r"OVERALL COVERAGE\s*:\s*([\d.]+)%", line)
        if m:
            overall = float(m.group(1))

print("LINE COVERAGE:")
for f, pct in line_coverage.items():
    print(f"  {f:<25} {pct}%")

print("\nFUNCTIONAL COVERAGE:")
for g, pct in func_coverage.items():
    print(f"  {g:<25} {pct}%")

print("\nTOGGLE COVERAGE:")
for f, pct in toggle_coverage.items():
    print(f"  {f:<25} {pct}%")

print(f"\nOVERALL: {overall}%")