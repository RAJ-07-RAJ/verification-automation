import os

logs_folder = "sample_logs"

log_files = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

print(f"Found {len(log_files)} log files:")
for f in log_files:
    print(f"  {f}")