import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import paths

testlist_file = paths.TESTLISTS / "basic_regression.f"
log_dir       = paths.SIM_RUNS
output_file   = paths.REPORTS / "full_regression.txt"
os.makedirs(log_dir, exist_ok=True)
paths.REPORTS.mkdir(parents=True, exist_ok=True)

# ── step 1: read testlist ──────────────────────────────────
tests = []
with open(testlist_file, "r") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) == 2:
            tests.append({"test": parts[0], "seed": parts[1]})

print(f"Loaded {len(tests)} tests from testlist")
print(f"Launching regression...\n")

# ── step 2: launch all tests ───────────────────────────────
for t in tests:
    print(f"  Launching {t['test']} seed={t['seed']}...", end=" ", flush=True)
    fake_sim = paths.REPO_ROOT / "log_parser" / "fake_simulator" / "fake_sim.py"
    cmd = [sys.executable, str(fake_sim), t["test"], t["seed"], str(log_dir)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    t["returncode"] = result.returncode
    t["log_file"]   = os.path.join(log_dir, f"{t['test']}_seed{t['seed']}.log")
    print("done")

# ── step 3: parse each log ─────────────────────────────────
print("\nParsing logs...")

def parse_log(filepath):
    errors = warnings = fatals = assertions = 0
    if not os.path.exists(filepath):
        return errors, warnings, fatals, assertions
    with open(filepath, "r") as f:
        for line in f:
            if "UVM_ERROR"          in line: errors     += 1
            elif "UVM_FATAL"        in line: fatals     += 1
            elif "UVM_WARNING"      in line: warnings   += 1
            elif "ASSERTION FAILED" in line: assertions += 1
    return errors, warnings, fatals, assertions

results = []
for t in tests:
    errors, warnings, fatals, assertions = parse_log(t["log_file"])
    verdict = "PASS" if errors == 0 and fatals == 0 and assertions == 0 else "FAIL"
    results.append({
        "test"      : t["test"],
        "seed"      : t["seed"],
        "errors"    : errors,
        "warnings"  : warnings,
        "fatals"    : fatals,
        "assertions": assertions,
        "verdict"   : verdict,
        "log"       : t["log_file"]
    })

# ── step 4: generate report ────────────────────────────────
total     = len(results)
passed    = sum(1 for r in results if r["verdict"] == "PASS")
failed    = total - passed
pass_rate = round((passed / total) * 100) if total > 0 else 0
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

lines = []
lines.append("=" * 65)
lines.append("  FULL REGRESSION REPORT")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 65)
lines.append(f"  Total     : {total}")
lines.append(f"  Passed    : {passed}")
lines.append(f"  Failed    : {failed}")
lines.append(f"  Pass rate : {pass_rate}%")
lines.append("=" * 65)
lines.append("")
lines.append(f"{'TEST':<25} {'SEED':>6} {'ERR':>4} {'WARN':>5} {'FATAL':>6} {'ASSERT':>7} {'VERDICT':>8}")
lines.append("-" * 65)

for r in results:
    lines.append(
        f"{r['test']:<25} {r['seed']:>6} {r['errors']:>4} {r['warnings']:>5} "
        f"{r['fatals']:>6} {r['assertions']:>7} {r['verdict']:>8}"
    )

lines.append("")
lines.append("FAILED TESTS:")
for r in results:
    if r["verdict"] == "FAIL":
        lines.append(f"  {r['test']:<25} seed={r['seed']}  log={r['log']}")

report = "\n".join(lines)
print("\n" + report)

with open(output_file, "w") as f:
    f.write(report)

print(f"\nSaved: {output_file}")