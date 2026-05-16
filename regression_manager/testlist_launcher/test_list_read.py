import os

testlist_file = "regression_manager/testlists/basic_regression.f"

tests = []

with open(testlist_file, "r") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) == 2:
            tests.append({
                "test" : parts[0],
                "seed" : parts[1]
            })

print(f"Testlist loaded: {len(tests)} tests\n")
print(f"{'TEST NAME':<25} {'SEED':>6}")
print("-" * 35)
for t in tests:
    print(f"{t['test']:<25} {t['seed']:>6}")