# Project Status & To-Do List
# 项目状态与待办清单

**Last updated:** 2026-03-04
**Current phase:** Suspension candidate physical testing (pre-order)

---

## Immediate: Physical Tests on Shock Candidates / 物理测试（订货前必做）

Run Tests 1–3 (from `suspension_candidate_eval.md`) on **both A and C in parallel**.

| ID | Test | Candidate | Mass | Expected | Done? |
|---|---|---|---|---|---|
| T1-A | Spring rate k — hanging weight (4 loads) | A | 7.00 kg | ~3,900 N/m → fn ~3.77 Hz | ☐ |
| T1-C | Spring rate k — hanging weight (4 loads) | C | 4.95 kg | ~2,985 N/m → fn ~3.91 Hz | ☐ |
| T2-A | **Ring-down ζ** — 10 mm drop, 240 fps video, log-decrement | A | 7.00 kg | ζ ≥ 0.3 (~1 visible cycle) | ☐ |
| T2-C | Ring-down ζ | C | 4.95 kg | ζ ≥ 0.3 | ☐ |
| T3-A | Stroke: measure L_min, L_max | A | 7.00 kg | bump ~15.5 mm ✓, rebound ~17.5 mm ✓ | ☐ |
| T3-C | Stroke: measure L_min, L_max | C | 4.95 kg | bump ~16.7 mm ✓, rebound ~16.3 mm ✓ | ☐ |

**If ζ fails (too many cycles):** fill with 100–200 wt silicone oil, retest. See §"If Damping is Too Low" in eval guide.

---

## Decision Gate / 决策节点

| ID | Decision | Condition | Action |
|---|---|---|---|
| D1 | **Select A or C** | After T1–T3 | Prefer A (with sandwich, better isolation). Use C only if A's ζ < 0.3 after oil change. |
| D2 | **Order 4 units** | After D1 | Order the selected candidate × 4 |
| D3 | **If A selected:** build sandwich hardware | After D2 | Fabricate per §12.10: 16 pads, 12 spacers, 2 sandwich plates |
| D4 | **If C selected (no sandwich):** decide on body upgrade | After D2 | Option: source ≥50 mm stroke body to allow sandwich (see §15.2 in report) |
| D5 | **Recompute k, c** after hardware is weighed | Before assembly | Current 25 kg estimate excludes suspension hardware weight |

---

## Sandwich Hardware Fabrication (if A selected) / 夹层硬件制造（选A后）

From §12.10 of the main report:

| # | Item | Spec | Status |
|---|---|---|---|
| 1 | Silicon bumper pads × 16 | 50×50×15 mm, ø16 mm central void, rubber bumps both faces | ☐ Source |
| 2 | Spacer plates × 12 | 50×50×2 mm Al, ø16 mm centre hole, laser-cut, deburr | ☐ Fabricate |
| 3 | Bottom isolation plate | 3 mm Al, 320×320 mm square, 4× ø16 mm corner holes | ☐ Fabricate |
| 4 | Top plate | 3 mm Al, 320×320 mm, 4× ø16 mm corner holes | ☐ Fabricate |
| 5 | Upper assembly plate | 4 mm Al, 4× M6 tapped holes | ☐ Fabricate |
| 6 | Prototype impulse test (1 corner) | Load 4.95 kg, tap, verify fn ≈ 4.5 Hz, ζ ≈ 0.13 | ☐ After parts ready |

---

## Longer-Horizon: Arm Vibration / 远期：机械臂振动

| # | Action | Why | Status |
|---|---|---|---|
| A1 | **Arm tap test** — accelerometer at EE tip, impulse hammer | Verify 5.8 Hz (X), 9 Hz (Y), 11.5 Hz (X) arm resonances from §14.8 | ☐ |
| A2 | **Arm stiffening assessment** — arm horizontal amplification (up to 7.5×) is the primary EE precision bottleneck post-suspension | Suspension/sandwich cannot fix this | ☐ |
| A3 | **Formalise low-speed protocol** — avoid sustained ≤ 0.3 m/s while arm is extended (N=11 roller frequency ≈ fn → ×1.62 amplification) | Operational guideline | ☐ |

---

## Reference / 参考文档

| Document | Contents |
|---|---|
| `full_analysis_report.md` | Complete analysis — vibration characterisation, suspension design, sandwich design, dual-acc results, candidate evaluation (§15) |
| `suspension_candidate_eval.md` | Printable test sheets for A and C; step-by-step measurement procedures |
| `suspension_design_summary.md` | Suspension design derivation (fn, k, c, sag, stroke) |
| `dual_accelero_summary.md` | Dual-sensor results: chassis vs EE, per-axis, arm resonances |
| `CLAUDE.md` | Project constants, key verified results, MATLAB execution rules |
