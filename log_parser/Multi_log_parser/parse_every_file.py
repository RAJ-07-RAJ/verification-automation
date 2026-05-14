import os

logs_folder = "sample_logs"

log_files = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

results = []

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)

    errors     = 0
    warnings   = 0
    fatals     = 0
    assertions = 0

    with open(filepath, "r") as f:
        for line in f:
            if "UVM_ERROR"        in line: errors     += 1
            elif "UVM_FATAL"      in line: fatals     += 1
            elif "UVM_WARNING"    in line: warnings   += 1
            elif "ASSERTION FAILED" in line: assertions += 1

    verdict = "PASS" if errors == 0 and fatals == 0 and assertions == 0 else "FAIL"

    results.append({
        "file"      : filename,
        "errors"    : errors,
        "warnings"  : warnings,
        "fatals"    : fatals,
        "assertions": assertions,
        "verdict"   : verdict
    })

print(f"{'FILE':<20} {'ERR':>4} {'WARN':>5} {'FATAL':>6} {'ASSERT':>7} {'VERDICT':>8}")
print("-" * 55)
for r in results:
    print(f"{r['file']:<20} {r['errors']:>4} {r['warnings']:>5} {r['fatals']:>6} {r['assertions']:>7} {r['verdict']:>8}")