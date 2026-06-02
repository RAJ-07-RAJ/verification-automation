import subprocess
import os
from datetime import datetime

design_dir = "rtl_projects/spi"
log_dir    = f"{design_dir}/logs"
rep_dir    = "reports"
os.makedirs(log_dir, exist_ok=True)
os.makedirs(rep_dir, exist_ok=True)

master_sv = f"{design_dir}/spi_master.sv"
slave_sv  = f"{design_dir}/spi_slave.sv"
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

tests = [
    {
        "name"    : "spi_basic",
        "tb"      : f"{design_dir}/tb_spi_basic.sv",
        "designs" : [master_sv, slave_sv]
    },
    {
        "name"    : "spi_loopback",
        "tb"      : f"{design_dir}/tb_spi_loopback.sv",
        "designs" : [master_sv, slave_sv]
    },
    {
        "name"    : "spi_protocol",
        "tb"      : f"{design_dir}/tb_spi_protocol.sv",
        "designs" : [master_sv, slave_sv]
    },
]

print("=" * 55)
print("  SPI Master/Slave Regression")
print(f"  {timestamp}")
print("=" * 55)

results = []

for t in tests:
    name    = t["name"]
    tb_file = t["tb"]
    vvp     = f"{design_dir}/{name}.vvp"
    log     = f"{log_dir}/{name}.log"

    print(f"\n[{name}]")

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

total  = len(results)
passed = sum(1 for r in results if r["verdict"] == "PASS")
failed = total - passed

lines = []
lines.append("\n" + "=" * 55)
lines.append("  SPI REGRESSION REPORT")
lines.append(f"  Generated : {timestamp}")
lines.append("=" * 55)
lines.append(f"  Total     : {total}")
lines.append(f"  Passed    : {passed}")
lines.append(f"  Failed    : {failed}")
lines.append(f"  Pass rate : {round(passed/total*100)}%")
lines.append("=" * 55)
lines.append(f"\n{'TEST':<20} {'PASSES':>7} {'ERRORS':>7} {'VERDICT':>8}")
lines.append("-" * 45)
for r in results:
    lines.append(
        f"{r['name']:<20} {r['passes']:>7} "
        f"{r['errors']:>7} {r['verdict']:>8}")

report = "\n".join(lines)
print(report)

out = f"{rep_dir}/spi_regression.txt"
with open(out, "w", encoding="utf-8") as f:
    f.write(report)
print(f"\nSaved: {out}")
print(f"\nVCD waveforms:")
print(f"  gtkwave {log_dir}/spi_loopback.vcd")