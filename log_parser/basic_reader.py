import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import paths

input_file = paths.SAMPLE_LOGS / "sim1.log"

with open(input_file, "r", encoding="utf-8") as f:
    for line in f:
        print(line.strip())
