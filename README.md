# Verification Automation Toolkit

**Ongoing portfolio repo** — Python DV automation from log parsing through regression launch, failure triage, coverage tracking, and **RTL compile/sim/report** flows.

| | |
|---|---|
| **Focus** | Design Verification · Verification Automation |
| **Language** | Python 3 · SystemVerilog (RTL mini-projects) |
| **Status** | **Active** — Stages 1–11 complete · see [ROADMAP.md](ROADMAP.md) |
| **Journey log** | [automation_scripting_journey.md](automation_scripting_journey.md) |

---

## Is this repo well structured?

**Yes, with a clear learning arc** — but it is intentionally **staged** (tutorial → production-style), not a single commercial tool yet.

```
Learning scripts (log_parser/)  →  Regression manager  →  Coverage tools
                                        ↓
                              RTL projects + run.py
                                        ↓
                              reports/ (PASS/FAIL, triage, trends)
```

| Strength | Detail |
|----------|--------|
| Progressive stages | 11 documented stages in journey file |
| Runnable without EDA license | Sample logs + fake simulator + committed example reports |
| RTL connection | 4 designs with `run.py` (iverilog) → same log parsing |
| Test plans | FIFO / shift_reg include corner cases + bug analysis |
| Honest scope | Fake sim for Stage 8; real sim for RTL blocks |

| Gap (being improved) | Plan |
|----------------------|------|
| Paths assumed cwd | Fixed via `paths.py` — run from **repo root** |
| `.vvp` binaries in git | `.gitignore` added — remove from tracking over time |
| No CI yet | [ROADMAP.md](ROADMAP.md) |
| README was behind code | Updated to match `rtl_projects/` |

---

## Repository structure

```
verification-automation/
├── paths.py                    # Repo-root paths (use from any script)
├── run_all.py                  # Run core demo pipeline
├── requirements.txt            # pandas
├── ROADMAP.md                  # Future work (ongoing repo)
├── automation_scripting_journey.md
│
├── log_parser/                 # Stages 1–7
│   ├── basic_reader.py
│   ├── uvm_parser.py
│   ├── report_generator.py
│   ├── regex/                  # Structured extraction → CSV
│   ├── failure_classifier/     # Triage by root cause
│   ├── pandas_analyser/        # DataFrame reports
│   ├── Multi_log_parser/       # Folder regression parse
│   ├── fake_simulator/         # Mimics VCS/Questa log output
│   └── sim_runs/               # Generated fake-sim logs
│
├── regression_manager/         # Stage 8
│   ├── testlists/basic_regression.f
│   └── testlist_launcher/complete_pipeline.py
│
├── coverage_tools/             # Stage 9
│   ├── coverage_parser/
│   └── sample_coverage/
│
├── rtl_projects/               # Stages 10–11
│   ├── adder/                  # SV + assertions + coverage
│   ├── counter/
│   ├── fifo/                   # 3 testbenches + test_plan.md
│   └── shift_reg/              # 4-test regression
│
├── sample_logs/                # sim1.log … sim6.log (UVM-style)
└── reports/                    # Example outputs for reviewers
```

See [rtl_projects/README.md](rtl_projects/README.md) for per-design run commands.

---

## Quick start

```bash
git clone https://github.com/RAJ-07-RAJ/verification-automation.git
cd verification-automation

pip install -r requirements.txt

# Run core automation demos (from repo root)
python run_all.py

# Or step-by-step
python log_parser/basic_reader.py
python log_parser/uvm_parser.py
python log_parser/report_generator.py
python log_parser/Multi_log_parser/regression.py
python log_parser/regex/data_to_CSV.py
python log_parser/failure_classifier/triage_report.py
python log_parser/pandas_analyser/analysis_report.py
python regression_manager/testlist_launcher/complete_pipeline.py
python coverage_tools/coverage_parser/full_coverage_report.py
```

### RTL + automation (requires [Icarus Verilog](http://iverilog.icarus.com/))

```bash
python rtl_projects/adder/run.py
python rtl_projects/counter/run.py
python rtl_projects/fifo/run.py
python rtl_projects/shift_reg/run.py
```

---

## What recruiters should review

1. **[automation_scripting_journey.md](automation_scripting_journey.md)** — shows how each script maps to industry DV tasks  
2. **`reports/`** — sample regression, triage, coverage, RTL reports (no simulator needed to understand output)  
3. **`rtl_projects/fifo/test_plan.md`** — structured verification thinking (corners, bugs, assertions)  
4. **`complete_pipeline.py`** — testlist → launch → parse → PASS/FAIL table  
5. **[ROADMAP.md](ROADMAP.md)** — proves this is an ongoing, directed effort  

---

## Skills demonstrated

| Area | Evidence in repo |
|------|------------------|
| Log parsing | UVM_ERROR/FATAL/assertion detection |
| Regression automation | Testlist + subprocess launch |
| Failure triage | Classify → group → CSV/txt reports |
| Data analysis | pandas groupby, filters, summaries |
| Coverage tracking | Multi-run parse + trend CSV |
| RTL verification | SV TBs, assertions, multi-test `run.py` |
| Tool scripting | Same patterns reusable for VCS/Questa |

---

## Related RTL portfolio

| Project | Link |
|---------|------|
| Async FIFO (CDC) | [FIFO_ASYNC](https://github.com/RAJ-07-RAJ/FIFO_ASYNC) |
| Sync FIFO study | [FIFO_S](https://github.com/RAJ-07-RAJ/FIFO_S) |
| AXI-Stream FIFO | [AXIS_FIF0](https://github.com/RAJ-07-RAJ/AXIS_FIF0) |
| GitHub profile | [RAJ-07-RAJ](https://github.com/RAJ-07-RAJ) |

---

## Author

**Raj** · RTL Design & Verification Engineer  
[GitHub](https://github.com/RAJ-07-RAJ) · [LinkedIn](https://www.linkedin.com/in/mallela-n-9bb085304/)
