import os

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import paths
logs_folder = paths.SAMPLE_LOGS

log_files = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

print(f"Found {len(log_files)} log files:")
for f in log_files:
    print(f"  {f}")