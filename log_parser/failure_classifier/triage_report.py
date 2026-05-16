import os
import csv
from collections import defaultdict
from datetime import datetime

logs_folder = "sample_logs"
output_txt  = "reports/failure_triage.txt"
output_csv  = "reports/failure_triage.csv"
log_files   = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

def classify(line):
    if "Data mismatch" in line:
        return "DATA_MISMATCH"
    elif "ASSERTION FAILED" in line and "AWREADY" in line:
        return "ASSERTION_AWREADY"
    elif "ASSERTION FAILED" in line and "RVALID" in line:
        return "ASSERTION_RVALID"
    elif "ASSERTION FAILED" in line and "Reset" in line:
        return "ASSERTION_RESET"
    elif "ASSERTION FAILED" in line and "BVALID" in line:
        return "ASSERTION_BVALID"
    elif "timeout" in line.lower() and "ASSERTION" not in line:
        return "TIMEOUT"
    elif "Protocol violation" in line:
        return "PROTOCOL_VIOLATION"
    elif "Bus stall" in line:
        return "BUS_STALL"
    elif "UVM_FATAL" in line:
        return "FATAL_STOP"
    else:
        return None

failures = defaultdict(list)

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)
    with open(filepath, "r") as f:
        for line in f:
            fault_type = classify(line.strip())
            if fault_type:
                failures[fault_type].append(filename)

sorted_failures = sorted(failures.items(), key=lambda x: len(x[1]), reverse=True)

total_failures  = sum(len(v) for v in failures.values())
unique_types    = len(failures)
most_common     = sorted_failures[0] if sorted_failures else ("NONE", [])
timestamp       = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 65)
lines.append("  FAILURE TRIAGE REPORT")
lines.append(f"  Generated     : {timestamp}")
lines.append(f"  Logs scanned  : {len(log_files)}")
lines.append("=" * 65)
lines.append(f"  Total failures   : {total_failures}")
lines.append(f"  Unique types     : {unique_types}")
lines.append(f"  Most common      : {most_common[0]} ({len(most_common[1])} occurrences)")
lines.append("=" * 65)
lines.append("")
lines.append(f"{'FAILURE TYPE':<25} {'COUNT':>6}  {'AFFECTED FILES'}")
lines.append("-" * 65)

for fault_type, file_list in sorted_failures:
    unique_files = sorted(set(file_list))
    count        = len(file_list)
    files_str    = ", ".join(unique_files)
    lines.append(f"{fault_type:<25} {count:>6}  {files_str}")

lines.append("")
lines.append("TRIAGE VERDICT:")
lines.append(f"  Fix {most_common[0]} first — appears in {len(set(most_common[1]))} log(s)")
lines.append(f"  Resolving this may clear majority of failures.")

report = "\n".join(lines)
print(report)

with open(output_txt, "w") as f:
    f.write(report)

# CSV for pandas later
with open(output_csv, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["failure_type", "count", "affected_files"])
    for fault_type, file_list in sorted_failures:
        unique_files = ", ".join(sorted(set(file_list)))
        writer.writerow([fault_type, len(file_list), unique_files])

print(f"\nSaved: {output_txt}")
print(f"Saved: {output_csv}")