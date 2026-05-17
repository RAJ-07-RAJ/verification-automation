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
---
# Stage 6 — Failure Classifier and Triage Report

## Objective
Group failures by root cause type across all logs.
Answer the real question: how many unique failure types exist?

## Script
`log_parser/failure_classifier.py`

## Input
`log_parser/sample_logs/` — sim1 through sim6.log

## Functionality
- Classifies every failure line into a named type
- Groups by type using defaultdict
- Counts occurrences per type across all logs
- Tracks which files each type appears in
- Sorts by frequency — worst failures first
- Saves triage report to .txt and .csv

## Output
Terminal: ranked failure triage table
File: reports/failure_triage.txt
File: reports/failure_triage.csv

## Key Concepts Learned
- collections.defaultdict
- classify() function — single responsibility
- Sorting by value using lambda
- set() for unique file tracking
- Writing both .txt and .csv from same data

## Why this matters
500 failures in a regression might have only 3 root causes.
This script finds that instantly. Engineers fix root causes,
not individual failures. This is how debug time gets cut in half.
---
# Stage 7 — Pandas Regression Analyser

## Objective
Load extracted failure CSVs into pandas and produce
a structured analysis report with ranked findings.

## Script
`log_parser/pandas_analyser.py`

## Input
`reports/extracted_failures.csv` — from Stage 5
`reports/failure_triage.csv`    — from Stage 6

## Functionality
- Loads CSV data into DataFrame
- Failures per file sorted worst first
- Failures by type sorted most common first
- ASCII bar chart for quick visual comparison
- Data mismatch deep dive — unique addresses, all values
- Assertion deep dive — file, line number, message
- Triage summary merged from Stage 6 output
- Recommendation block — what to fix first

## Output
Terminal + File: reports/pandas_analysis.txt

## Key Concepts Learned
- pd.read_csv()
- df.groupby().count()
- df[df["col"] == value] filtering
- sort_values(), nunique(), iterrows()
- Combining multiple CSVs into one analysis

## Why this matters
pandas turns raw CSV data into queryable analysis.
In real projects this feeds dashboards, email reports,
and management summaries — all automated, zero manual work

---
# Stage 8 — Testlist Launcher and Regression Manager

## Objective
Simulate the full industry regression flow —
read a testlist, launch every test, parse its log,
generate a final regression report. All automated.

## Scripts
`regression_manager/testlist_launcher.py` — full pipeline
`log_parser/fake_simulator.py`            — mimics a real simulator

## Input
`regression_manager/testlists/basic_regression.f` — testlist

## Functionality
- Reads testlist file, skips comments
- Launches each test using subprocess.run()
- Captures return code (0=pass 1=fail)
- Parses generated log files
- Produces full regression report with per-test verdict

## Output
Logs  : log_parser/sim_runs/*.log  (one per test)
Report: reports/full_regression.txt

## Key Concepts Learned
- subprocess.run() — launching external processes
- sys.argv — passing arguments to scripts
- sys.exit() — return codes from processes
- Return code 0 = pass, non-zero = fail (Unix standard)
- Full pipeline: launch → collect → parse → report

## Why this matters
This is exactly how regression managers work.
Replace fake_simulator.py call with actual vcs/questasim command
and this script runs a real RTL regression unchanged.

---
# Stage 9 — Coverage Parser and Tracker

## Objective
Parse simulator coverage reports, track coverage trend
across runs, identify uncovered groups and gaps.

## Script
`coverage_tools/coverage_parser.py`

## Input
`coverage_tools/sample_coverage/` — coverage_run1/2/3.txt

## Functionality
- Parses line, functional, toggle coverage sections
- Extracts coverage % per file and per group using regex
- Tracks overall coverage trend across multiple runs
- Calculates delta between runs
- Identifies gaps — groups below 90% threshold
- Saves report to txt and trend data to CSV

## Output
Terminal + File : reports/coverage_report.txt
CSV            : reports/coverage_trend.csv

## Key Concepts Learned
- Multi-section parsing with state tracking
- Coverage report structure
- Trend calculation across runs
- Gap identification and priority ordering
- Combining regex + state machine for structured parsing

## Why this matters
Coverage closure is a primary verification goal.
Scripts that automatically identify gaps and track trends
across regressions save hours of manual report reading.
This is what coverage automation tools do internally.

---
# Stage 10 — First Real RTL Design + Automation

## Objective
Connect everything built in Stages 1-9 to a real
RTL simulation. Compile, simulate, parse, report — fully automated.

## Design
`rtl_projects/counter/counter.sv` — 4-bit synchronous up counter

## Testbench
`rtl_projects/counter/tb_counter.sv`
- Tests reset behaviour
- Tests counting 0 to 15
- Tests wrap-around
- Tests enable/disable
- Tests mid-count reset

## Automation
`rtl_projects/counter/run.py`
- Compiles RTL + TB using iverilog via subprocess
- Simulates using vvp
- Captures stdout to log file
- Parses log for errors and warnings
- Generates full report

## Tools
- Icarus Verilog (iverilog) — open source RTL simulator
- vvp — simulation runtime

## Key Concepts Learned
- What a module is and how instantiation works
- always_ff — synchronous flip-flop behaviour
- Clock generation in testbench
- $display for simulation messages
- Compile step separate from simulation step
- Your scripts work on real sim output unchanged