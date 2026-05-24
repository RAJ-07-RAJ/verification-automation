# Roadmap — Verification Automation (Ongoing)

This repository is **actively maintained**. Stages 1–11 are implemented; later stages are planned.

## Current status

| Stage | Topic | Status |
|-------|--------|--------|
| 1 | Basic log reader | Done |
| 2 | UVM message parser | Done |
| 3 | PASS/FAIL report generator | Done |
| 4 | Multi-log regression parser | Done |
| 5 | Regex structured extraction → CSV | Done |
| 6 | Failure classifier / triage | Done |
| 7 | Pandas regression analysis | Done |
| 8 | Testlist launcher (fake + real path) | Done |
| 9 | Coverage parser + trend CSV | Done |
| 10 | RTL + `run.py` (counter, adder) | Done |
| 11 | Multi-test RTL regression (shift_reg, fifo) | Done |

Details: [automation_scripting_journey.md](automation_scripting_journey.md)

---

## Near-term (next commits)

- [ ] **Unified CLI** — `python tools/regress.py --suite basic` wrapping testlists + RTL runs
- [ ] **Makefile** — `make log-demo`, `make rtl-adder`, `make full-regression`
- [ ] **Connect RTL logs to triage** — pipe `rtl_projects/*/logs/*.log` through `failure_classifier`
- [ ] **HTML/Markdown reports** — recruiter-friendly regression summary page
- [ ] **CI (GitHub Actions)** — run log-parser stages on push; optional iverilog job
- [ ] **Remove committed `.vvp`** from git history; build only in CI/local sim

---

## Medium-term (portfolio strength)

- [ ] **UVM-style log format** alignment with real Questa/VCS logs (sample snippets)
- [ ] **Config YAML** — paths, thresholds, testlists (industry-style)
- [ ] **Coverage merge** — parse URG/HTML orIMC exports, not only text samples
- [ ] **Waveform pointers** — link failure line → timestamp for GTKWave
- [ ] **Lint integration** — parse Verilator/Vivado DRC summary into same report format
- [ ] **Link to RTL portfolio** — auto-list pass/fail from [FIFO_ASYNC](https://github.com/RAJ-07-RAJ/FIFO_ASYNC) sims when added

---

## Long-term (industry parity)

- [ ] Plugin architecture: `parsers/vcs.py`, `parsers/xrun.py`
- [ ] Database or SQLite for regression history
- [ ] Slack/email notification on regression FAIL
- [ ] Integration with real UVM regressions (when available)
- [ ] Published docs (GitHub Pages) with architecture diagram

---

## How to contribute (solo)

1. Pick one checkbox above.
2. Branch → implement → update `automation_scripting_journey.md` with a new stage section.
3. Add sample log or report under `reports/` if useful for reviewers.
4. Keep **run from repo root** using `paths.py`.
