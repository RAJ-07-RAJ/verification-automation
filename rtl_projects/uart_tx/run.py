import subprocess
import os
from datetime import datetime

design_dir = "rtl_projects/uart_tx"
log_dir    = f"{design_dir}/logs"
rep_dir    = "reports"
os.makedirs(log_dir, exist_ok=True)
os.makedirs(rep_dir, exist_ok=True)

tx_sv  = f"{design_dir}/uart_tx.sv"
rx_sv  = f"{design_dir}/uart_rx.sv"
top_sv = f"{design_dir}/uart_top.sv"
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

tests = [
    {
        "name"    : "uart_tx_unit",
        "tb"      : f"{design_dir}/tb_uart_tx.sv",
        "designs" : [tx_sv],
        "desc"    : "TX unit — frame verify, done pulse, busy, reset"
    },
    {
        "name"    : "uart_rx_unit",
        "tb"      : f"{design_dir}/tb_uart_rx.sv",
        "designs" : [rx_sv],
        "desc"    : "RX unit — directed bytes, glitch, framing error, reset"
    },
    {
        "name"    : "uart_top_integration",
        "tb"      : f"{design_dir}/tb_uart_top.sv",
        "designs" : [tx_sv, rx_sv, top_sv],
        "desc"    : "Integration — loopback, 8 corner bytes + 50 random"
    },
]

print("=" * 60)
print("  UART Full Regression  (Unit + Integration)")
print(f"  {timestamp}")
print("=" * 60)

results = []

for t in tests:
    name    = t["name"]
    tb_file = t["tb"]
    vvp     = f"{design_dir}/{name}.vvp"
    log     = f"{log_dir}/{name}.log"

    print(f"\n[{name}]")
    print(f"  {t['desc']}")

    compile_cmd = ["iverilog", "-g2012", "-o", vvp] + \
                   t["designs"] + [tb_file]

    cr = subprocess.run(compile_cmd, capture_output=True, text=True)

    if cr.returncode != 0:
        print(f"  COMPILE FAILED:\n{cr.stderr.strip()}")
        results.append({"name":name,"verdict":"COMPILE_FAIL",
                        "errors":0,"passes":0})
        continue

    print("  Compile : PASSED")

    with open(log, "w", encoding="utf-8") as lf:
        subprocess.run(["vvp", vvp], stdout=lf, stderr=lf)

    errors = passes = 0
    with open(log, "r", encoding="utf-8") as f:
        for line in f:
            if   "UVM_ERROR"        in line: errors += 1
            elif "UVM_INFO: [PASS]" in line: passes += 1

    verdict = "PASS" if errors == 0 else "FAIL"
    print(f"  Simulate: done")
    print(f"  Verdict : {verdict}  (pass={passes} fail={errors})")

    results.append({"name":name,"verdict":verdict,
                    "errors":errors,"passes":passes})

# ── regression summary ────────────────────────────────────
total  = len(results)
passed = sum(1 for r in results if r["verdict"] == "PASS")
failed = total - passed

lines = []
lines.append("\n" + "=" * 60)
lines.append("  UART REGRESSION REPORT")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 60)
lines.append(f"  Total     : {total}")
lines.append(f"  Passed    : {passed}")
lines.append(f"  Failed    : {failed}")
lines.append(f"  Pass rate : {round(passed/total*100)}%")
lines.append("=" * 60)
lines.append("")
lines.append(f"{'TEST':<28} {'PASSES':>6} {'ERRORS':>6} {'VERDICT':>8}")
lines.append("-" * 55)
for r in results:
    lines.append(
        f"{r['name']:<28} {r['passes']:>6} "
        f"{r['errors']:>6} {r['verdict']:>8}")
lines.append("")
lines.append("TEST LEVELS:")
lines.append("  uart_tx_unit          — unit test, TX block only")
lines.append("  uart_rx_unit          — unit test, RX block only")
lines.append("  uart_top_integration  — integration, TX+RX loopback")

report = "\n".join(lines)
print(report)

out = f"{rep_dir}/uart_full_regression.txt"
with open(out, "w", encoding="utf-8") as f:
    f.write(report)

print(f"\nSaved: {out}")
print(f"\nOpen waveforms:")
print(f"  gtkwave {log_dir}/uart_top.vcd     ← loopback — most useful")
print(f"  gtkwave {log_dir}/uart_tx_unit.vcd ← TX frame structure")
print(f"  gtkwave {log_dir}/uart_rx_unit.vcd ← RX sampling points")