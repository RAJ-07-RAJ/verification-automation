# Verification Automation Toolkit

**Python-based design verification utilities** for log parsing, regression orchestration, failure triage, and coverage report analysis — aligned with industry DV workflows.

| | |
|---|---|
| **Role focus** | Design Verification · Verification Automation |
| **Language** | Python 3 |
| **Domain** | Simulation logs · Regressions · Coverage |
| **Status** | Learning → production-style scripts with sample data |

---

## What recruiters should see here

- Structured progression from **basic log reading** → **UVM-style parsing** → **regression launch** → **pandas analysis** → **coverage trending**
- Scripts mirror tasks done on real DV teams: triage failures, summarize regressions, parse coverage databases
- Sample logs and reports included so reviewers can run tools **without a live simulator**

---

## Repository structure

```
verification-automation/
├── log_parser/                 # Simulation log analysis
│   ├── basic_reader.py         # Stage 1: read log line-by-line
│   ├── uvm_parser.py           # UVM_ERROR / FATAL / assertion detection
│   ├── report_generator.py     # PASS/FAIL summary reports
│   ├── regex/                  # Pattern extraction → CSV
│   ├── pandas_analyser/        # Group / sort / filter failures
│   ├── failure_classifier/     # Triage reports
│   ├── Multi_log_parser/       # Folder scan + regression parse
│   └── sim_runs/               # Sample simulation logs
├── regression_manager/         # Test list → subprocess launch
│   ├── testlists/
│   └── testlist_launcher/
├── coverage_tools/             # Coverage log parsing
│   ├── coverage_parser/
│   └── sample_coverage/
├── reports/                    # Generated outputs (examples)
└── automation_scripting_journey.md   # Stage-by-stage learning notes
```

---

## Key capabilities

| Module | Purpose |
|--------|---------|
| `uvm_parser.py` | Extract UVM_ERROR, UVM_FATAL, assertion failures |
| `report_generator.py` | Regression PASS/FAIL decision + text report |
| `regression.py` | Multi-log folder scan and aggregate parsing |
| `triage_report.py` | Classify and group failure lines |
| `full_coverage_report.py` | Parse and summarize coverage runs |
| `complete_pipeline.py` | End-to-end testlist → sim → report flow |

---

## Quick start

```bash
# Clone and enter repo
git clone https://github.com/RAJ-07-RAJ/verification-automation.git
cd verification-automation

# Python 3.8+ recommended
python log_parser/basic_reader.py
python log_parser/uvm_parser.py
python log_parser/report_generator.py
python regression_manager/testlist_launcher/complete_pipeline.py
```

Outputs appear under `reports/` (sample reports already committed for reference).

---

## Verification skills demonstrated

- Log-based **failure triage** and structured reporting
- **Regression** testlist execution via subprocess
- **Regex** and **pandas** for DV data analysis
- **Coverage** run comparison and trending (sample inputs)
- Modular scripts suitable for extension toward CI/CD hooks

---

## Tools

| Tool | Use |
|------|-----|
| Python 3 | All automation |
| pandas | Log/statistics analysis |
| Git | Version control |

---

## Related RTL portfolio

| Project | Link |
|---------|------|
| Async FIFO (CDC) | [FIFO_ASYNC](https://github.com/RAJ-07-RAJ/FIFO_ASYNC) |
| AXI-Stream FIFO | [AXIS_FIF0](https://github.com/RAJ-07-RAJ/AXIS_FIF0) |
| CDC techniques | [CDC_TECHNIQUES](https://github.com/RAJ-07-RAJ/CDC_TECHNIQUES) |
| Profile | [RAJ-07-RAJ](https://github.com/RAJ-07-RAJ) |

---

## Author

**Raj** · RTL Design & Verification Engineer  
[GitHub](https://github.com/RAJ-07-RAJ) · [LinkedIn](https://www.linkedin.com/in/mallela-n-9bb085304/)
