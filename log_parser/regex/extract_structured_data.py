import re
import os

logs_folder = "sample_logs"
log_files   = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

mismatches = []
assertions = []

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)
    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()

            # Extract data mismatch details
            # Example line:
            # [300ns] UVM_ERROR: ... Data mismatch ADDR=0x0020 EXP=0xCAFEBABE GOT=0x00000000
            mismatch_pattern = r"\[(\d+)ns\].*Data mismatch ADDR=(0x\w+)\s+EXP=(0x\w+)\s+GOT=(0x\w+)"
            m = re.search(mismatch_pattern, line)
            if m:
                mismatches.append({
                    "file"     : filename,
                    "time"     : m.group(1),
                    "addr"     : m.group(2),
                    "expected" : m.group(3),
                    "got"      : m.group(4)
                })

            # Extract assertion details
            # Example line:
            # [500ns] ASSERTION FAILED: axi_master.sv:142 - AWREADY timeout exceeded 16 cycles
            assert_pattern = r"\[(\d+)ns\].*ASSERTION FAILED:\s+(\w+\.sv):(\d+)\s+-\s+(.+)"
            a = re.search(assert_pattern, line)
            if a:
                assertions.append({
                    "file"    : filename,
                    "time"    : a.group(1),
                    "sv_file" : a.group(2),
                    "line_no" : a.group(3),
                    "message" : a.group(4)
                })

print("DATA MISMATCHES:")
print(f"{'FILE':<12} {'TIME':>7}  {'ADDR':<12} {'EXPECTED':<14} {'GOT'}")
print("-" * 60)
for m in mismatches:
    print(f"{m['file']:<12} @{m['time']:>6}ns  {m['addr']:<12} {m['expected']:<14} {m['got']}")

print(f"\nASSERTIONS:")
print(f"{'FILE':<12} {'TIME':>7}  {'SV FILE':<18} {'LINE':>5}  MESSAGE")
print("-" * 70)
for a in assertions:
    print(f"{a['file']:<12} @{a['time']:>6}ns  {a['sv_file']:<18} L{a['line_no']:>4}  {a['message']}")