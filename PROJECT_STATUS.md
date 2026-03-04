# Project Status & To-Do List
# 项目状态与待办清单

**Last updated:** 2026-03-04
**Current phase:** Suspension candidate physical testing (pre-order)

---

## Candidate Status / 候选方案状态

| Candidate | k | Rejection reason | Status |
|---|---|---|---|
| A | 3,919 N/m | **No damping fluid confirmed → ζ ≈ 0** | ✗ Rejected |
| B | 699 N/m | Spring too soft — bottoms out | ✗ Rejected |
| **C** | **2,985 N/m** | — | **✓ Sole remaining candidate** |
| D | 1,587 N/m | Spring too soft — bottoms out | ✗ Rejected |

Design basis: **4.95 kg/corner, no sandwich layer** (C + 33 mm body cannot accommodate 7.00 kg sandwich mass).

---

## Immediate: Physical Tests on Candidate C / 物理测试（订货前必做）

Run Tests 1–3 (from `suspension_candidate_eval.md`) on **Candidate C at 4.95 kg**.

| ID | Test | Mass | Expected | Done? |
|---|---|---|---|---|
| T1 | Spring rate k — hanging weight (4 loads, 200/500/1000/2000 g) | 4.95 kg | ~2,985 N/m → fn ~3.91 Hz | ☐ |
| T2 | **Ring-down ζ** — 10 mm drop, 240 fps slow-mo, log-decrement | 4.95 kg | ζ ≥ 0.3 (~1 visible cycle) | ☐ |
| T3 | Stroke: measure L_min, L_max eye-to-eye | 4.95 kg | bump ~16.7 mm ✓, rebound ~16.3 mm ✓ | ☐ |

**If T2 fails (ζ < 0.3):** change to 100–200 wt silicone oil, retest. See §"If Damping is Too Low" in `suspension_candidate_eval.md`.

---

## Decision Gate / 决策节点

| ID | Decision | Condition | Action |
|---|---|---|---|
| D1 | **Order 4 units (Candidate C)** | T1–T3 all pass | Order C × 4 |
| D2 | **Recompute k, c** | Before assembly | 4.95 kg/corner excludes suspension hardware weight — reweigh after hardware is made |
| D3 | **Sandwich layer decision** | After D1 | (a) Omit permanently (simplest), or (b) source ≥50 mm stroke body for C's spring to re-enable sandwich at 7.00 kg |

---

## Sandwich Hardware (deferred) / 夹层硬件（暂缓）

Sandwich cannot be used with C in the current 33 mm stroke body at 7.00 kg (sag = 23 mm, exceeds valid window).
Options to re-enable sandwich:
- Source a longer shock body (≥50 mm stroke, same spring OD 20 mm) → C's spring fits, sandwich mass accommodated
- Find a different spring with k ≈ 4,421 N/m that has fluid damping → then use with sandwich at 7.00 kg

*Fabrication spec is documented in §12.10 of the main report — revisit after D3.*

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
