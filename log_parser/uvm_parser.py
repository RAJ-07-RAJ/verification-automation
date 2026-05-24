import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import paths

input_file = paths.SAMPLE_LOGS / "sim1.log"

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

print("===== ERRORS =====")
for e in errors:
    print(e)

print("\n===== WARNINGS =====")
for w in warnings:
    print(w)

print("\n===== ASSERTIONS =====")
for a in assertions:
    print(a)

print("\n===== FATALS =====")
for f in fatals:
    print(f)
