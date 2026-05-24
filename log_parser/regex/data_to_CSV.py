import re
import os
import csv

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import paths
logs_folder = paths.SAMPLE_LOGS
paths.REPORTS.mkdir(parents=True, exist_ok=True)
output_csv  = paths.REPORTS / "extracted_failures.csv"
log_files   = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

all_failures = []

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)
    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()

            # named groups — much more readable
            mismatch_pattern = (
                r"\[(?P<time>\d+)ns\]"
                r".*Data mismatch"
                r"\s+ADDR=(?P<addr>0x\w+)"
                r"\s+EXP=(?P<expected>0x\w+)"
                r"\s+GOT=(?P<got>0x\w+)"
            )
            m = re.search(mismatch_pattern, line)
            if m:
                all_failures.append({
                    "file"        : filename,
                    "time_ns"     : m.group("time"),
                    "type"        : "DATA_MISMATCH",
                    "addr"        : m.group("addr"),
                    "expected"    : m.group("expected"),
                    "got"         : m.group("got"),
                    "sv_file"     : "",
                    "line_no"     : "",
                    "message"     : f"EXP={m.group('expected')} GOT={m.group('got')}"
                })

            assert_pattern = (
                r"\[(?P<time>\d+)ns\]"
                r".*ASSERTION FAILED:\s+"
                r"(?P<sv_file>\w+\.sv):(?P<line_no>\d+)"
                r"\s+-\s+(?P<message>.+)"
            )
            a = re.search(assert_pattern, line)
            if a:
                all_failures.append({
                    "file"        : filename,
                    "time_ns"     : a.group("time"),
                    "type"        : "ASSERTION",
                    "addr"        : "",
                    "expected"    : "",
                    "got"         : "",
                    "sv_file"     : a.group("sv_file"),
                    "line_no"     : a.group("line_no"),
                    "message"     : a.group("message")
                })

# print to terminal
print(f"Total failures extracted: {len(all_failures)}\n")
for f in all_failures:
    print(f"  [{f['type']:<15}] {f['file']}  @{f['time_ns']}ns  {f['message']}")

# save to CSV
fieldnames = ["file","time_ns","type","addr","expected","got","sv_file","line_no","message"]
with open(output_csv, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(all_failures)

print(f"\nSaved to: {output_csv}")