import re
import os
from collections import defaultdict

logs_folder = "sample_logs"
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

# defaultdict(list) — key is failure type, value is list of filenames
failures = defaultdict(list)

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)
    with open(filepath, "r") as f:
        for line in f:
            fault_type = classify(line.strip())
            if fault_type:
                failures[fault_type].append(filename)

# sort by count descending
sorted_failures = sorted(failures.items(), key=lambda x: len(x[1]), reverse=True)

print(f"{'FAILURE TYPE':<25} {'COUNT':>6}  FILES")
print("-" * 70)
for fault_type, file_list in sorted_failures:
    unique_files = sorted(set(file_list))
    count        = len(file_list)
    files_str    = ", ".join(unique_files)
    print(f"{fault_type:<25} {count:>6}  {files_str}")