import pandas as pd

failures_csv = "reports/extracted_failures.csv"
triage_csv   = "reports/failure_triage.csv"

df = pd.read_csv(failures_csv)

# 1 — filter only data mismatches
mismatches = df[df["type"] == "DATA_MISMATCH"]
print("=== DATA MISMATCHES ONLY ===")
print(mismatches[["file", "time_ns", "addr", "expected", "got"]])

# 2 — which file has most failures
print("\n=== FAILURES PER FILE ===")
per_file = df.groupby("file")["type"].count().sort_values(ascending=False)
print(per_file)

# 3 — which failure type is most common
print("\n=== FAILURES BY TYPE ===")
by_type = df.groupby("type")["file"].count().sort_values(ascending=False)
print(by_type)

# 4 — filter only assertions
assertions = df[df["type"] == "ASSERTION"]
print("\n=== ASSERTIONS ===")
print(assertions[["file", "time_ns", "sv_file", "line_no", "message"]])

# 5 — unique addresses that failed
print("\n=== UNIQUE FAILING ADDRESSES ===")
unique_addrs = df[df["addr"] != ""]["addr"].unique()
print(unique_addrs)