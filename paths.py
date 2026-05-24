"""
Repository path helpers — run scripts from repo root:
    python log_parser/uvm_parser.py
    python regression_manager/testlist_launcher/complete_pipeline.py
"""
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent
SAMPLE_LOGS = REPO_ROOT / "sample_logs"
REPORTS = REPO_ROOT / "reports"
SIM_RUNS = REPO_ROOT / "log_parser" / "sim_runs"
RTL_PROJECTS = REPO_ROOT / "rtl_projects"
COVERAGE_SAMPLES = REPO_ROOT / "coverage_tools" / "sample_coverage"
TESTLISTS = REPO_ROOT / "regression_manager" / "testlists"
