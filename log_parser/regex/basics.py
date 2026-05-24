import re
import os

# REGEX BASICS FIRST — read this before running
#
# re.search(pattern, line)  → finds pattern anywhere in the line
# re.findall(pattern, line) → returns list of all matches
#
# Pattern building blocks:
#   \d     = any digit (0-9)
#   \d+    = one or more digits
#   \w+    = one or more word characters
#   .      = any character
#   +      = one or more of previous
#   *      = zero or more of previous
#   ()     = capture group — extract this part
#   \s     = whitespace
#
# Example:
#   line    = "[300ns]   UVM_ERROR: ..."
#   pattern = r"\[(\d+)ns\]"
#   match   = re.search(pattern, line)
#   match.group(1) gives → "300"

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import paths
logs_folder = paths.SAMPLE_LOGS
log_files   = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

print("Extracting timestamps from all error lines:\n")

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)
    with open(filepath, "r") as f:
        for line in f:
            if "UVM_ERROR" in line or "ASSERTION FAILED" in line:
                match = re.search(r"\[(\d+)ns\]", line)
                if match:
                    timestamp = match.group(1)
                    print(f"{filename}  @{timestamp}ns  →  {line.strip()[:60]}")