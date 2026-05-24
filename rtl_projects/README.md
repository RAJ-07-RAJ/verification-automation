# RTL Mini-Projects (Simulation + Automation)

SystemVerilog/Verilog blocks with **self-checking testbenches**, **test plans**, and **`run.py`** flows that compile → simulate → parse logs → write reports under `reports/`.

| Design | Language | Tests | Automation |
|--------|----------|-------|------------|
| [adder](adder/) | SV | TB + assertions + coverage | `python rtl_projects/adder/run.py` |
| [counter](counter/) | SV | Reset, enable, wrap | `python rtl_projects/counter/run.py` |
| [fifo](fifo/) | SV | 3 TBs (basic, integrity, assertions) | `python rtl_projects/fifo/run.py` |
| [shift_reg](shift_reg/) | SV | 4-test regression | `python rtl_projects/shift_reg/run.py` |

## Requirements

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`) on PATH
- Run all commands from **repository root**

## Output

| Design | Log | Report |
|--------|-----|--------|
| adder | `rtl_projects/adder/logs/` | `reports/adder_report.txt` |
| counter | `rtl_projects/counter/logs/` | `reports/counter_report.txt` |
| fifo | `rtl_projects/fifo/logs/` | `reports/fifo_regression.txt` |
| shift_reg | `rtl_projects/shift_reg/logs/` | `reports/shift_reg_regression.txt` |

Each `run.py` reuses the same log-parsing patterns as `log_parser/` (UVM-style messages, PASS/FAIL).
