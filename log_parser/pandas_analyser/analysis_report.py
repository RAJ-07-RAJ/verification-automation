import pandas as pd
import os
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import paths

failures_csv = paths.REPORTS / "extracted_failures.csv"
triage_csv   = paths.REPORTS / "failure_triage.csv"
output_file  = paths.REPORTS / "pandas_analysis.txt"
paths.REPORTS.mkdir(parents=True, exist_ok=True)

df_failures = pd.read_csv(failures_csv)
df_triage   = pd.read_csv(triage_csv)

timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 60)
lines.append("  REGRESSION ANALYSIS REPORT")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 60)

# --- summary numbers
total      = len(df_failures)
files      = df_failures["file"].nunique()
types      = df_failures["type"].nunique()
lines.append(f"\n  Total failures   : {total}")
lines.append(f"  Files affected   : {files}")
lines.append(f"  Unique types     : {types}")

# --- failures per file
lines.append("\n" + "=" * 60)
lines.append("  FAILURES PER FILE (worst first)")
lines.append("=" * 60)
per_file = df_failures.groupby("file")["type"].count().sort_values(ascending=False)
for fname, count in per_file.items():
    bar = "#" * count
    lines.append(f"  {fname:<15} {count:>3}  {bar}")

# --- failures by type
lines.append("\n" + "=" * 60)
lines.append("  FAILURES BY TYPE (most common first)")
lines.append("=" * 60)
by_type = df_failures.groupby("type")["file"].count().sort_values(ascending=False)
for ftype, count in by_type.items():
    bar = "#" * count
    lines.append(f"  {ftype:<25} {count:>3}  {bar}")

# --- data mismatch deep dive
lines.append("\n" + "=" * 60)
lines.append("  DATA MISMATCH DEEP DIVE")
lines.append("=" * 60)
mismatches = df_failures[df_failures["type"] == "DATA_MISMATCH"]
if not mismatches.empty:
    lines.append(f"  Total mismatches : {len(mismatches)}")
    lines.append(f"  Unique addresses : {mismatches['addr'].nunique()}")
    lines.append("")
    lines.append(f"  {'FILE':<12} {'ADDR':<12} {'EXPECTED':<14} {'GOT'}")
    lines.append("  " + "-" * 50)
    for _, row in mismatches.iterrows():
        lines.append(f"  {row['file']:<12} {row['addr']:<12} {row['expected']:<14} {row['got']}")

# --- assertion deep dive
lines.append("\n" + "=" * 60)
lines.append("  ASSERTION DEEP DIVE")
lines.append("=" * 60)
assertions = df_failures[df_failures["type"] == "ASSERTION"]
if not assertions.empty:
    lines.append(f"  Total assertions : {len(assertions)}")
    lines.append("")
    for _, row in assertions.iterrows():
        lines.append(f"  {row['file']:<12} {row['sv_file']}:{row['line_no']}  {row['message']}")
else:
    lines.append("  No assertions found in extracted_failures.csv")
    lines.append("  (assertions are in failure_triage.csv instead)")

# --- triage summary from stage 6
lines.append("\n" + "=" * 60)
lines.append("  TRIAGE SUMMARY (from failure_classifier)")
lines.append("=" * 60)
for _, row in df_triage.iterrows():
    lines.append(f"  {row['failure_type']:<25} count={row['count']}  files: {row['affected_files']}")

# --- recommendation
top_type  = by_type.index[0]
top_count = by_type.iloc[0]
lines.append("\n" + "=" * 60)
lines.append("  RECOMMENDATION")
lines.append("=" * 60)
lines.append(f"  Priority fix : {top_type}")
lines.append(f"  Occurrences  : {top_count}")
lines.append(f"  Fixing this type will have the highest impact.")
lines.append("=" * 60)

report = "\n".join(lines)
print(report)

with open(output_file, "w") as f:
    f.write(report)

print(f"\nSaved: {output_file}")