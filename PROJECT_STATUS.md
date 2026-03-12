# Project Status & To-Do List
# 项目状态与待办清单

**Last updated:** 2026-03-13
**Current phase:** Suspension installed — awaiting first test drive & accelerometer recording

---

## Suspension Hardware Installed (2026-03-13) / 悬挂已安装

**Type:** Parallel 4-bar linkage with coil-over shock (NOT the simple trailing arm from §16, NOT Candidate C).

Each unit: **1.4 kg**. Total 4 units installed on all corners.

CAD reference: `sus-design/` (4 PNG files: side view with dims, top view, perspective, 45° view)

### Updated Mass Budget / 更新后的质量

| Component | Before | After |
|---|---|---|
| Total system | 25.0 kg | 30.6 kg |
| Unsprung per corner | 1.3 kg | ~1.9 kg (estimate) |
| Sprung per corner | 4.95 kg | **~5.75 kg** (estimate) |

### Track Width Change / 轮距变化

| Parameter | Before | After |
|---|---|---|
| Diagonal track (contact-to-contact) | ~600 mm | ~800 mm |
| Tipping stability (critical lateral accel) | 10.4 m/s² | **13.9 m/s²** (+33%) |

- Vibration calculations (√2 factor) **unaffected** — depends on 45° angle, not track width
- Firmware omni kinematics L parameter **needs updating** (rotation commands ~25% slow otherwise)

### Effective Spring Rate Correction / 等效刚度修正

```
k_wheel = k_coilover × MR² × cos²(θ)
```

At MR=1.0, θ=25° (estimated): k_wheel = 0.821 × k_coilover

---

## Immediate: Pre-Test Measurements / 测试前测量

| ID | Measurement | Method | Status |
|---|---|---|---|
| M1 | **Motion ratio (MR)** | Push wheel up 10 mm, measure coil-over compression | ☐ |
| M2 | **Coil-over angle** | Measure from CAD or protractor — estimated ~25° | ☐ |
| M3 | **Sprung/unsprung mass split** | Detach moving parts from bracket, weigh separately | ☐ |
| M4 | **Static sag under load** | Measure ride height drop after installation | ☐ |
| M5 | **Total coil-over stroke** | Compress fully, measure max eye-to-eye travel | ☐ |
| M6 | **Update firmware L parameter** | ~300 mm → ~400 mm (centre-to-wheel diagonal) | ☐ |

**After M1–M3:** update `MR`, `theta_coilover_deg`, and mass values in `suspended_analysis.m`.

---

## Accelerometer Test Plan / 加速度计测试计划

Script: **`suspended_analysis.m`** — place CSVs in `testData/SuspendedTests/`, re-run.

| ID | Test | File naming | Purpose |
|---|---|---|---|
| T1 | Indoor speed sweep 0.2–1.2 m/s | `...-a-0.2-...csv` through `...-a-1.2-...csv` | Before/after RMS comparison |
| T2 | Bump / ring-down test | `...-bump-...csv` or `...-ringdown-...csv` | Extract measured fn and ζ |
| T3 | Extended speed (if stable) | `...-a-1.5-...csv` | Full range check |
| T4 | Multi-surface (if indoor passes) | Subfolder per surface | Validate on pavement/cement |

---

## Previous Candidate Evaluation (completed) / 候选弹簧评估（已完成）

| Candidate | k | Status | Notes |
|---|---|---|---|
| A | 3,919 N/m | ✗ Rejected | No damping fluid → ζ ≈ 0 |
| B | 699 N/m | ✗ Rejected | Spring too soft |
| C | 2,985 N/m | ✓ Was sole viable candidate | **May not apply to installed hardware** |
| D | 1,587 N/m | ✗ Rejected | Spring too soft |

Note: The installed suspension is a complete custom assembly — its coil-over k and c are unknown and need independent measurement.

---

## Longer-Horizon: Arm Vibration / 远期：机械臂振动

| # | Action | Why | Status |
|---|---|---|---|
| A1 | **Arm tap test** — accelerometer at EE tip, impulse hammer | Verify 5.8 Hz (X), 9 Hz (Y), 11.5 Hz (X) arm resonances from §14.8 | ☐ |
| A2 | **Arm stiffening assessment** — arm horizontal amplification (up to 7.5×) is the primary EE precision bottleneck post-suspension | Suspension cannot fix this | ☐ |
| A3 | **Formalise low-speed protocol** — avoid sustained ≤ 0.3 m/s while arm is extended | Operational guideline | ☐ |

---

## Reference / 参考文档

| Document | Contents |
|---|---|
| `full_analysis_report.md` | Complete analysis — vibration, suspension design, sandwich, dual-acc, candidate eval (§15), geometry rec (§16) |
| `suspension_candidate_eval.md` | Printable test sheets for spring candidates |
| `suspended_analysis.m` | **NEW** — before/after analysis with suspension; ring-down extraction; design preview |
| `sus-design/` | CAD images of installed 4-bar linkage suspension |
| `suspension_design_summary.md` | Suspension design derivation (fn, k, c, sag, stroke) |
| `dual_accelero_summary.md` | Dual-sensor results: chassis vs EE, per-axis, arm resonances |
| `CLAUDE.md` | Project constants, key verified results, MATLAB execution rules |
