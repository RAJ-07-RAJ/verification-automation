#!/usr/bin/env python3
"""
Run core verification-automation demos from repository root.
Usage: python run_all.py
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent

STEPS = [
    ("Stage 1 — Basic log reader", [sys.executable, "log_parser/basic_reader.py"]),
    ("Stage 2 — UVM parser", [sys.executable, "log_parser/uvm_parser.py"]),
    ("Stage 3 — Summary report", [sys.executable, "log_parser/report_generator.py"]),
    ("Stage 4 — Multi-log regression", [sys.executable, "log_parser/Multi_log_parser/regression.py"]),
    ("Stage 8 — Testlist pipeline", [sys.executable, "regression_manager/testlist_launcher/complete_pipeline.py"]),
    ("Stage 9 — Coverage report", [sys.executable, "coverage_tools/coverage_parser/full_coverage_report.py"]),
]


def main():
    print("Verification Automation — demo pipeline")
    print(f"Repo root: {ROOT}\n")
    for title, cmd in STEPS:
        print("=" * 60)
        print(title)
        print("=" * 60)
        r = subprocess.run(cmd, cwd=ROOT)
        if r.returncode != 0:
            print(f"[WARN] Exit code {r.returncode}\n")
        else:
            print("[OK]\n")
    print("RTL projects (requires iverilog):")
    print("  python rtl_projects/adder/run.py")
    print("  python rtl_projects/shift_reg/run.py")
    print("\nSee rtl_projects/README.md and ROADMAP.md")


if __name__ == "__main__":
    main()
