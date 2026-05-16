import os
import subprocess

testlist_file = "regression_manager/testlists/basic_regression.f"
log_dir       = "log_parser/sim_runs"
os.makedirs(log_dir, exist_ok=True)

tests = []
with open(testlist_file, "r") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) == 2:
            tests.append({"test": parts[0], "seed": parts[1]})

print(f"Launching {len(tests)} tests...\n")

results = []

for t in tests:
    test_name = t["test"]
    seed      = t["seed"]

    print(f"  Running {test_name} (seed={seed})...", end=" ", flush=True)

    # This is exactly how you'd call a real simulator:
    # cmd = ["vcs", "-f", "filelist.f", "+UVM_TESTNAME=" + test_name, "+seed=" + seed]
    # We call our fake simulator instead:
    cmd = ["python", "log_parser/fake_simulator.py", test_name, seed, log_dir]

    result = subprocess.run(cmd, capture_output=True, text=True)

    # return code 0 = PASS, anything else = FAIL
    verdict = "PASS" if result.returncode == 0 else "FAIL"
    print(verdict)

    results.append({
        "test"    : test_name,
        "seed"    : seed,
        "verdict" : verdict,
        "log"     : f"{log_dir}/{test_name}_seed{seed}.log"
    })

print(f"\nDone. Logs written to: {log_dir}/")
print(f"Files created:")
for f in sorted(os.listdir(log_dir)):
    print(f"  {f}")