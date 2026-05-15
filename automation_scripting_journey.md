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

---
# Stage 4 — Multi-Log Regression Parser

## Objective
Scale from single log to full regression — parse an entire folder of logs automatically.

## Script
`log_parser/Multi_log_parser`

## Input
`sample_logs` — sim1.log to sim4.log

## Functionality
- Scans folder using os.listdir()
- Parses every .log file
- Counts errors, warnings, fatals, assertions per file
- Decides PASS/FAIL per test
- Calculates total/passed/failed/pass rate
- Saves full regression summary to reports/regression_report.txt

## Output
Terminal: formatted results table
File: reports/regression_report.txt

## Key Concepts Learned
- os.listdir() and os.path.join()
- List of dicts as a results table
- f-string column formatting
- datetime for timestamps
- Scaling single-file logic to folder-level automation

## Limitation
- Simple string matching, not regex yet
- No failure detail extraction
- No grouping by failure type

---
# Stage 5 — Regex-Based Data Extractor

## Objective
Use regex to extract structured data from log lines —
not just detect keywords but pull out actual values.

## Script
`log_parser/regex`

## Input
`log_parser/sample_logs/` — sim1 through sim6.log

## Functionality
- Extracts timestamp, address, expected value, got value from mismatch lines
- Extracts sv file name, line number, message from assertion lines
- Uses named capture groups for readable patterns
- Saves all extracted failures to reports/extracted_failures.csv

## Output
Terminal: structured failure table
File: reports/extracted_failures.csv

## Key Concepts Learned
- re.search() with capture groups
- Named groups (?P<name>pattern)
- Extracting structured data from unstructured text
- Building patterns incrementally
- CSV export with csv.DictWriter

## Why this matters
In a real regression with 5000 logs, you never read lines manually.
Regex pulls every data mismatch address, every assertion location,
every timeout value — structured and queryable in seconds.