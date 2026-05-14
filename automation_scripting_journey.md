# Verification Automation Journey

---

# Stage 1 — Basic Log Reader

## Objective
Learn how to open and read simulation log files using Python.

## Script
`basic_reader.py`

## Input
Simulation log:
`sample_logs/sim1.log`

## Functionality
- Opens simulation log
- Reads line-by-line
- Prints contents to terminal

## Key Concepts Learned
- File handling
- `with open()`
- Line iteration
- `strip()`

## Limitation
- No filtering
- No report generation
- No automation

---

# Stage 2 — UVM Message Parser

## Objective
Extract important verification messages from simulation logs.

## Script
`uvm_parser.py`

## Functionality
Detects:
- UVM_ERROR
- UVM_WARNING
- UVM_FATAL
- ASSERTION FAILED

## Output
Grouped terminal report.

## Key Concepts Learned
- Pattern matching
- Conditional parsing
- List storage
- Categorization

## Limitation
- No file export
- Hardcoded log path

---

# Stage 3 — Summary Report Generator

## Objective
Generate reusable simulation summary reports.

## Script
`report_generator.py`

## Functionality
- Parses log
- Counts errors/warnings
- Decides PASS/FAIL
- Generates report file

## Output
`reports/summary.txt`

## Key Concepts Learned
- Report automation
- PASS/FAIL logic
- File writing
- Structured summaries

## Current Limitation
- Supports only one log
- No multi-test regression
- No HTML/Markdown report

---

# Next Planned Improvements

- Multiple log support
- Regression dashboard
- Colored terminal output
- CSV/HTML reports
- Jenkins integration
- Auto waveform collection
- Runtime extraction
- Coverage extraction
