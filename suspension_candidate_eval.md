# Suspension Candidate Evaluation Guide
# 候选减震器评估指南

**Units under evaluation / 待评估型号:** Two RC coil-over shock candidates (same body: 115 mm total, 33 mm stroke, 3 mm shaft)
**Tools needed / 所需工具:** Ruler, digital scale, known weights (~100–500 g), phone camera (slow-mo), string or clamp
**Time required / 预计耗时:** ~30 minutes for all tests / 全部测试约30分钟

---

## Candidate Spring Profiles / 候选弹簧参数（已测量）

Two springs have been physically measured and compared. Spring formula:
两根弹簧已经实物测量并对比。弹簧公式：

```
k = G × d⁴ / (8 × D_mean³ × n_active)     G = 80,000 N/mm² (steel)
```

| Parameter / 参数 | Candidate A — "stiff" / 候选A（硬） | Candidate B — "soft" / 候选B（软） |
|---|---|---|
| Wire diameter d / 线径 | **2.0 mm** | **1.5 mm** |
| Spring OD / 弹簧外径 | 20 mm | 18.4 mm |
| D_mean = OD − d | 18.0 mm | 16.9 mm |
| Total coils / 总圈数 | ~9 (2 flat end coils) | ~17 (2 flat end coils) |
| **Active coils n / 有效圈数** | **7** | **15** |
| Coil gap / 圈间隙 | 9.5 mm | 2.7 mm |
| Pitch = gap + d | 11.5 mm | 4.2 mm |
| Free length (estimated) / 自由长（估算） | 7 × 11.5 + 4 = **84.5 mm** | 15 × 4.2 + 3 = **66 mm** |
| Rated support load / 额定支撑载荷 | 2–12 kg | 5–15 kg |
| **Calculated k / 计算刚度** | **4,265 N/m** | **699 N/m** |

### Calculated performance / 计算性能

| Scenario / 工况 | **Candidate A** k = 4,265 N/m | **Candidate B** k = 699 N/m |
|---|---|---|
| fn at 4.95 kg/corner (no sandwich) | 4.67 Hz | 1.89 Hz |
| fn at 7.00 kg/corner (with sandwich) | **3.93 Hz ✓** | 1.59 Hz |
| Static sag at 4.95 kg | 11.4 mm | 69.5 mm — **exceeds 33 mm stroke** |
| Static sag at 7.00 kg | 16.1 mm | 98.2 mm — **exceeds 33 mm stroke** |
| Bump travel remaining (7.00 kg) | **16.9 mm ✓** (need ≥ 15 mm) | — bottoms out |
| Rebound travel available (7.00 kg) | **16.1 mm ✓** (need ≥ 15 mm) | — bottoms out |

### Pre-screening verdict / 预筛选结论

**Candidate B (15-active-coil, d=1.5 mm): REJECTED.**
k = 699 N/m is ~6× too soft. Static sag (70–98 mm) far exceeds the 33 mm stroke on every mass scenario. No modification can fix this — the spring is fundamentally wrong for this body. Candidate B would need to go into a shock body with ≥ 120 mm stroke to be usable, which is not practical for this chassis.

**候选B（15有效圈，d=1.5 mm）：拒绝。**
k = 699 N/m过软约6倍，静态下沉（70–98 mm）远超33 mm行程，任何改造均无法修复——弹簧与筒体根本不匹配。

**Candidate A (7-active-coil, d=2.0 mm): PROCEED to Tests 1–3.**
At 7.00 kg/corner (chassis + sandwich hardware fitted), fn = **3.93 Hz** — essentially the 4 Hz target. Stroke check passes on both bump and rebound. The only remaining unknown is damping (ζ). All further testing applies to Candidate A only.

**候选A（7有效圈，d=2.0 mm）：进入测试1–3。**
在7.00 kg/角质量（底盘+夹层硬件）时，fn = **3.93 Hz**——几乎正好达到4 Hz目标。压缩和回弹行程均通过。唯一待确认项为阻尼（ζ）。以下所有测试仅针对候选A。

---

## Overview / 概述

We need to confirm three things before accepting Candidate A as the suspension unit.
在接受候选A作为悬挂单元之前，需要确认三件事：

| Test # | What we measure | What we need | Pass criterion |
|---|---|---|---|
| 1 | Spring rate k (N/m) — verify against formula | k ≈ 4,265 N/m | 3,500–5,000 N/m |
| 2 | Damping ratio ζ — **the critical unknown** | ζ = 0.4 | ζ > 0.3 |
| 3 | Stroke — measure actual rebound travel | bump ≥ 15 mm, rebound ≥ 15 mm | Both ≥ 15 mm at 7.00 kg |

If all three pass → order 4 units and proceed to prototype.
If Test 2 fails → change oil, re-test.

三项均通过 → 订购4个并进入样机阶段。
测试2不通过 → 换油重测。

---

## Step 0 — Before You Test: Count Active Coils
## 第0步 — 测试前：数清有效圈数

The coil count is needed to cross-check the k measurement and understand the spring.
线圈数用于交叉验证k的测量结果，并加深对弹簧的理解。

**How / 操作方法:**

1. Remove the spring from the shock body.
   将弹簧从减震筒上取下。
2. Lay it flat. Count every full coil that is **not** tightly ground flat at each end.
   平放弹簧，数清两端**非**密封磨平圈以外的所有完整圈。
3. The two flat end coils (ground coils) are inactive — **do not count them**.
   两端磨平的密封圈为非有效圈——**不计入总数**。
4. Record: n = _____ active coils.
   记录：n = _____ 有效圈数。

**For Candidate A:** 7 active coils confirmed (2 flat ground end coils, ~9 total).
**候选A：** 已确认7有效圈（两端各1个磨平密封圈，共约9圈）。

**Quick formula cross-check for Candidate A / 候选A公式校验:**
d = 2.0 mm, D_mean = 18.0 mm, G = 80,000 N/mm²
```
k = (80,000 × 2.0⁴) / (8 × 18.0³ × n)
  = 1,280,000 / (46,656 × n)
  = 27,435 / n   [N/m]
```
| n active | k (N/m) | fn at 7.00 kg |
|---|---|---|
| 6 | 4,572 | 4.07 Hz |
| **7** | **3,919** | **3.76 Hz** ← Candidate A |
| 8 | 3,429 | 3.52 Hz |

> **Note on D_mean:** Using D_mean = OD − d = 20 − 2.0 = 18.0 mm (correct for a spring wound to 20 mm OD with 2.0 mm wire). Earlier estimates used 17.5 mm (OD/2 + ID/2) from image dimensions; 18.0 mm from direct wire/OD measurement is more accurate.
>
> **关于D_mean：** 使用D_mean = OD − d = 20 − 2.0 = 18.0 mm（适用于线径2.0 mm、绕至20 mm外径的弹簧）。此处数值比早期图纸估算（17.5 mm）更精确。

> **Expected measured k / 预期实测k:** ~3,900–4,300 N/m. If measurement gives a significantly different result, re-check coil count and OD.
> **预期实测k：** 约3,900–4,300 N/m。若实测值差异较大，请重新检查圈数和外径。

---

## Test 1 — Spring Rate k
## 测试1 — 弹簧刚度k

**Method: hanging weight deflection / 方法：悬挂重物挠度法**

This is the most reliable and requires zero special equipment.
这是最可靠的方法，无需任何专业设备。

### Setup / 装置

```
     ┌─ fixed clamp or hook ─┐
     │                       │
     │   ← ruler taped       │
     │      to wall          │
     │                       │
    [TOP EYE of shock]
     │
    [shock body]
     │
    [BOTTOM EYE]   ← hang weights here via wire hook
     │
   [weights]
```

1. Clamp the **top eye** to a firm horizontal bar or vice. Shock hangs vertically.
   将**顶部吊耳**夹在固定横杆或虎钳上，减震器竖直悬挂。
2. Tape a mm ruler to the side of the shock, aligned with the bottom eye.
   在减震器侧面贴一把毫米刻度尺，与底部吊耳对齐。
3. Note the zero-load position (bottom eye location) as **L₀**.
   记录空载时底部吊耳位置为 **L₀**。

### Measurements / 测量步骤

Hang each weight and wait 5 seconds for oscillations to settle, then read position.
悬挂每个砝码后等待5秒让振荡稳定，再读取位置。

| Weight added / 悬挂重量 | Deflection δ = L₀ − L | k = F/δ = m·g/δ |
|---|---|---|
| 100 g = 0.981 N | δ₁ = _____ mm | k₁ = 981/δ₁ N/m |
| 200 g = 1.962 N | δ₂ = _____ mm | k₂ = 1962/δ₂ N/m |
| 300 g = 2.943 N | δ₃ = _____ mm | k₃ = 2943/δ₃ N/m |
| 500 g = 4.905 N | δ₄ = _____ mm | k₄ = 4905/δ₄ N/m |

**k_measured = average of k₁–k₄**

> **Note:** Do not exceed ~50 mm total deflection or you risk coil bind.
> **注意：** 总挠度不超过约50 mm，否则可能导致弹簧并圈。

### Pass criterion / 通过标准

Candidate A is expected to measure ~3,900–4,300 N/m. Evaluate against both mass scenarios:
候选A预期实测约3,900–4,300 N/m，按两种质量工况评估：

| k_measured | fn at 4.95 kg (no sandwich) | fn at 7.00 kg (with sandwich) | Verdict |
|---|---|---|---|
| < 3,000 N/m | < 3.9 Hz | < 3.3 Hz | ✗ Too soft for indoor use |
| 3,000–3,500 N/m | 3.9–4.2 Hz | 3.3–3.5 Hz | ⚠ Acceptable no-sandwich; soft with sandwich |
| **3,500–4,500 N/m** | **4.2–4.8 Hz** | **3.5–4.0 Hz** | **✓ Target range — Candidate A expected here** |
| 4,500–5,500 N/m | 4.8–5.3 Hz | 4.0–4.5 Hz | ⚠ Acceptable with sandwich; stiff without |
| > 5,500 N/m | > 5.3 Hz | > 4.5 Hz | ✗ Too stiff — replace spring |

**Primary operating scenario: with sandwich hardware (7.00 kg/corner).** The 3,500–4,500 N/m range gives fn = 3.5–4.0 Hz — right on target.
**主要使用工况：配合夹层硬件（7.00 kg/角）。** 3,500–4,500 N/m范围对应fn = 3.5–4.0 Hz——正中目标。

**If k is too high (> 5,500 N/m):** Replace spring with same geometry but d = 1.8 mm wire:
k_1.8mm = (80,000 × 1.8⁴) / (8 × 18.0³ × 7) = 839,808 / 326,592 = **2,572 N/m** (fn ≈ 3.05 Hz — softer than needed)
Try d = 1.9 mm: k = (80,000 × 1.9⁴) / 326,592 = **1,010,048 / 326,592 = 3,093 N/m** (fn ≈ 3.35 Hz — good)

**若k过高（>5,500 N/m）：** 用相同几何参数但线径d = 1.9 mm的弹簧替换（k≈3,093 N/m，fn≈3.35 Hz）。

---

## Test 2 — Damping Ratio ζ (the critical unknown)
## 测试2 — 阻尼比ζ（关键未知量）

This is the most important test. The 3 mm shaft suggests this may be significantly under-damped.
这是最重要的测试。3 mm主轴提示此减震器可能明显欠阻尼。

### Method A — Free vibration ring-down (easiest, ~5 min)
### 方法A — 自由振动衰减法（最简便，约5分钟）

**Setup:** Attach the shock in its normal orientation with the **correct corner mass**.
**装置：** 以正常安装方向连接减震器，并附上**正确的角质量**。

A practical rig:
实用测试装置：

```
   Fixed support
        │
    [top eye]──────────────────── fixed pivot
        │
    [shock body] (vertical)
        │
    [bottom eye]──── rigid plate (7.00 kg total including plate)
```

**Target mass: 7.00 kg/corner** (chassis + sandwich hardware scenario — the primary use case for Candidate A).
**目标质量：7.00 kg/角**（底盘+夹层硬件工况——候选A的主要使用场景）。

If you don't have a rig yet, use 1.0 kg weight as a quick first indication:
若暂无测试台架，可先用1.0 kg砝码作为初步判断：

1. Mount shock vertically, hang 7.00 kg from bottom eye (or 1.0 kg for quick indication).
   竖直安装减震器，底部吊耳悬挂7.00 kg（快速判断可用1.0 kg）。
2. Displace the mass **10 mm downward** from static equilibrium and release.
   将质量从静平衡位置向下偏移**10 mm**后释放。
3. **Record with phone in slow-motion (240 fps or higher).**
   **用手机慢动作（240fps或以上）录像。**
4. Count the oscillation peaks until the motion is undetectable.
   数清振荡峰值直至运动消失。

### How to read the result / 结果解读

Count the number of visible oscillation cycles N_cycles:

| Visible oscillation cycles / 可见振荡周期数 | ζ estimate / ζ估计值 | Assessment / 评估 |
|---|---|---|
| > 5 cycles | ζ < 0.1 | ✗ Severely under-damped / 严重欠阻尼 |
| 3–5 cycles | ζ ≈ 0.1–0.2 | ✗ Under-damped — needs heavier oil / 欠阻尼——需换更重的油 |
| 1.5–3 cycles | ζ ≈ 0.2–0.35 | ⚠ Marginal — try thicker oil first / 临界——先尝试加粗油 |
| ~1 cycle | ζ ≈ 0.35–0.5 | ✓ **Target range** / **目标范围** |
| < 0.5 cycles | ζ > 0.5 | ✓ Slightly over-damped — acceptable / 轻微过阻尼——可接受 |
| No oscillation | ζ ≥ 1.0 | ⚠ Over-damped — shock too stiff-feeling, check oil / 过阻尼——感觉太硬，检查油 |

**To calculate ζ precisely from the ring-down:**
**从衰减记录精确计算ζ：**

Measure the amplitude of peak 1 (x₁) and peak n (xₙ), then:
测量第1个峰值x₁和第n个峰值xₙ的幅度，代入：

```
δ = (1/n) × ln(x₁/xₙ)          [logarithmic decrement / 对数衰减率]
ζ = δ / √(4π² + δ²)             [damping ratio / 阻尼比]
```

Example: if x₁ = 10 mm, x₃ = 2 mm, n = 2:
示例：若x₁ = 10 mm，x₃ = 2 mm，n = 2：
```
δ = (1/2) × ln(10/2) = (1/2) × 1.609 = 0.805
ζ = 0.805 / √(39.48 + 0.648) ≈ 0.127
```

### Method B — Oil weight identification (if disassembly is easy)
### 方法B — 油号识别法（如拆卸方便）

RC shocks use silicone oil numbered by weight (e.g. 30wt, 50wt, 100wt).
RC减震器使用以重量标号的硅油（如30号、50号、100号）。

If the manufacturer states the oil weight, the **approximate c value** can be estimated:
若厂家标明油号，可估算**大致c值**：

```
c ≈ η × (A_piston² / gap_area)     [simplified viscous dashpot model]
```

However, without piston geometry, this formula cannot be evaluated from the datasheet alone.
然而，若无活塞几何尺寸，仅凭数据表无法单独求解此公式。

**Practical approach:** ask the seller for the oil weight used, then cross-reference with Method A to understand the c-vs-oil-weight relationship for this specific unit.
**实用建议：** 向卖家询问所用油号，再结合方法A，建立该型号减震器的c-油号对应关系。

---

## Test 3 — Stroke Verification
## 测试3 — 行程验证

### Required stroke for Candidate A / 候选A所需行程

| Scenario | k | Static sag δ | Bump needed | Rebound needed | **Total stroke needed** |
|---|---|---|---|---|---|
| **7.00 kg + sandwich (primary)** | **4,265 N/m** | **16.1 mm** | **≥ 15 mm** | **≥ 15 mm** | **≥ 46 mm** |
| 4.95 kg no sandwich | 4,265 N/m | 11.4 mm | ≥ 15 mm | ≥ 15 mm | ≥ 38 mm |
| Pavement (fn=3 Hz softer spring) | 1,758 N/m | 39.0 mm | — | — | ≥ 80 mm (different shock needed) |

At 7.00 kg, static sag = 16.1 mm. This shock has 33 mm **compression** stroke (from the datasheet).
Calculated remaining travel from static equilibrium:
- Bump: 33 − 16.1 = **16.9 mm ✓** (need ≥ 15 mm)
- Rebound: depends on **measured** full-extension travel — measure below.

在7.00 kg工况下，静态下沉16.1 mm，减震器压缩行程33 mm（数据表）。从静平衡位置计算剩余行程：
- 压缩侧：33 − 16.1 = **16.9 mm ✓**（需≥15 mm）
- 回弹侧：取决于实测最大伸长量——见下方测量。

### Measure rebound travel / 测量回弹行程

1. Compress the shock fully by hand. Measure the eye-to-eye distance at full compression: **L_min = _____ mm**
   用手将减震器压缩至底，测量吊耳间距：**L_min = _____ mm**
2. Extend the shock fully (pull apart until it stops). Measure eye-to-eye: **L_max = _____ mm**
   将减震器完全拉伸（拉到底），测量吊耳间距：**L_max = _____ mm**
3. Total stroke = L_max − L_min = _____ mm (expected: ~33 mm if compression-only body)
   总行程 = L_max − L_min = _____ mm（若为纯压缩筒体，预期约33 mm）
4. With k from Test 1 and m = 7.00 kg:
   使用测试1的k值，m = 7.00 kg：
   - Static sag δ = 7.00 × 9.81 / k_measured = _____ mm
   - Remaining bump = 33 − δ = _____ mm  (need ≥ 15 mm — **expected 16.9 mm ✓**)
   - Available rebound = L_extension_from_free − δ = _____ mm  (need ≥ 15 mm — **measure carefully**)

### Pass criterion / 通过标准

| Available bump travel | Available rebound travel | Result |
|---|---|---|
| ≥ 15 mm | ≥ 15 mm | ✓ Pass |
| ≥ 15 mm | 10–15 mm | ⚠ Marginal — add preload to shift equilibrium toward bump |
| < 15 mm either direction | — | ✗ Fail — shock too short for this application |

> **Preload trick / 预载技巧:** If rebound travel is marginal, use the adjustable collar to add preload (compress the spring at installation). This shifts the static equilibrium point deeper into the stroke, giving more rebound travel at the cost of reduced bump travel. Works only if bump travel > 15 mm after adjustment.
>
> **预载技巧：** 若回弹行程临界不足，可利用可调螺纹领施加预载（安装时预压弹簧）。这将静平衡点向压缩方向移动，以减少压缩行程为代价增加回弹行程。仅在调整后压缩行程仍>15 mm时有效。

---

## Decision Flowchart / 决策流程图

```
                    ┌──────────────────────────────┐
                    │  Run Tests 1, 2, 3           │
                    └──────────────┬───────────────┘
                                   │
              ┌────────────────────┼─────────────────────┐
              ▼                    ▼                      ▼
         Test 1: k             Test 2: ζ            Test 3: stroke
              │                    │                      │
    ┌─────────┴────────┐  ┌────────┴───────┐   ┌─────────┴────────┐
    │ k in 2500–4500?  │  │  ζ ≥ 0.3?      │   │ stroke ≥ 38 mm?  │
    └────────┬─────────┘  └───────┬────────┘   └─────────┬────────┘
         Yes │ No             Yes │ No               Yes │ No
             │  │                 │  │                   │  │
             │  └─ Replace spring │  └─ Change oil:      │  └─ Reject unit.
             │     (thinner wire) │    try 100wt or      │    Need longer
             │     or source      │    200wt silicone.   │    shock
             │     softer spring  │    Re-test.          │    (≥50 mm stroke)
             │                    │                      │
             └────────────────────┴──────────────────────┘
                                   │
                          All 3 pass?
                                   │
                    ┌──────────────┴──────────────┐
                    ▼                             ▼
              YES — proceed               NO — see fix guide
             to prototype build           in §Fix section below
```

---

## If Damping is Too Low — How to Fix It
## 若阻尼不足——修复方法

RC coil-over shocks can usually have their oil changed. This is the first thing to try before rejecting the unit.
RC同轴减震器通常可以更换油液，这是拒绝使用该型号前首先应尝试的方法。

### What oil to use / 使用什么油

| Current state (cycles in ring-down) | Recommended oil upgrade | Expected ζ change |
|---|---|---|
| > 5 cycles (ζ < 0.1) | 500wt or 1000wt silicone shock oil | Large increase |
| 3–5 cycles (ζ ≈ 0.1–0.2) | 200wt–300wt silicone shock oil | Moderate increase |
| 1.5–3 cycles (ζ ≈ 0.2–0.3) | 100wt silicone shock oil | Small increase |

Silicone shock oils are widely available from RC hobby suppliers (e.g. Traxxas, Hot Racing, Axial).
硅油减震油在RC模型供应商处广泛供应（如Traxxas、Hot Racing、Axial）。

### Oil change procedure / 换油步骤

1. Unscrew the top cap of the shock body (usually a threaded collar or set screw).
   拧开减震筒顶盖（通常为螺纹领或紧定螺钉）。
2. Remove piston/shaft assembly. Drain old oil completely.
   取出活塞/主轴组件，完全排尽旧油。
3. Inspect the piston: note the number and diameter of bleed holes.
   检查活塞：记录泄油孔的数量和直径。
   - Fewer/smaller holes → more resistance → higher c
   - More/larger holes → less resistance → lower c
4. Fill with new oil to ~90% full (leave air gap for thermal expansion).
   注入新油至约90%满（留气隙供热膨胀）。
5. Slowly pump the shaft 10× to bleed air bubbles.
   缓慢往复活塞10次排出气泡。
6. Reassemble and re-run Test 2.
   重新组装后重做测试2。

> **Piston bleed holes:** If oil change alone is insufficient (ζ still < 0.3 with thickest available oil), the piston bleed holes may be too large. A machinist can plug one or more holes with epoxy or replace the piston with a drilled-smaller version. This is a permanent modification.
>
> **活塞泄油孔：** 若仅换油仍不足（使用最稠油后ζ仍<0.3），泄油孔可能过大。可请机械师用环氧树脂封堵部分孔，或换一个孔径更小的活塞。这是永久性改造。

---

## If Stroke is Insufficient — Options
## 若行程不足——可选方案

| Option | Description | Complexity |
|---|---|---|
| **A — Adjust preload** | Thread collar inward 3–5 mm; shifts static equilibrium deeper into stroke | 5 min, try first |
| **B — Source longer unit** | Same spring specs but 140–150 mm total length, ≥ 50 mm stroke | Drop-in replacement |
| **C — Rocker arm linkage** | Mount shock at angle or via rocker (mechanical advantage ratio < 1) — effective stroke seen at wheel increases | Mechanical design required |
| **D — Series mounting** | Two shocks end-to-end via a floating plate — doubles stroke, halves k (needs re-tuning spring) | Complex, not recommended |

Option B is the simplest: look for a RC shock with **压缩行程 ≥ 50 mm** (total length ~140–150 mm, same spring OD 20 mm).
方案B最简单：寻找**压缩行程≥50 mm**的RC减震器（总长约140–150 mm，弹簧外径相同20 mm）。

---

## Summary Checklist / 汇总检查清单

### Candidate B — Pre-screening / 候选B预筛选

```
Unit B: 15-active-coil, d=1.5 mm, OD=18.4 mm, rated 5–15 kg

☒ Step 0 — Active coils: n = 15  (17 total, 2 flat end coils)
☒ Pre-screen k formula: k = 699 N/m  →  static sag at 7.00 kg = 98 mm
☒ RESULT: REJECTED — k too soft by 6×, bottoms out in 33 mm stroke body.
          Do not proceed to physical tests.
          候选B：拒绝。刚度过软6倍，在33 mm行程筒体内立即触底。
```

---

### Candidate A — Full test sheet / 候选A完整测试表

Print and fill in as you test:
打印后测试时逐项填写：

```
Unit A: 7-active-coil, d=2.0 mm, OD=20 mm, rated 2–12 kg
        RC coil-over 115 mm total / 33 mm compression stroke / 3 mm shaft

□ Step 0 — Coil count (verify):
    Active coils n = _______ (expected: 7)
    Total coils  = _______ (expected: ~9, 2 flat end coils each end)
    CONFIRMED?  [ ] YES  [ ] NO — recount if not 7 active

□ Test 1 — Spring rate (primary test mass: 7.00 kg):
    Test mass used: _______ kg
    Reference position L₀: _______ mm
    ┌─────────┬──────────────┬───────────────┐
    │ Weight  │ Deflection δ │ k = F/δ       │
    ├─────────┼──────────────┼───────────────┤
    │ 200 g   │ _______ mm  │ _______ N/m   │
    │ 500 g   │ _______ mm  │ _______ N/m   │
    │ 1000 g  │ _______ mm  │ _______ N/m   │
    │ 2000 g  │ _______ mm  │ _______ N/m   │
    └─────────┴──────────────┴───────────────┘
    k_average = _______ N/m  (expected: ~3,900–4,300 N/m)
    fn = √(k/7.00)/(2π) = _______ Hz  (expected: ~3.75–3.93 Hz)
    PASS (3,500–5,000 N/m)?  [ ] YES  [ ] NO

□ Test 2 — Damping (CRITICAL — most important test):
    Test mass: 7.00 kg  |  Initial displacement: 10 mm
    Ring-down visible cycles: _______
    Amplitude at peak 1: x₁ = _______ mm
    Amplitude at peak n: xₙ = _______ mm   n = _______
    δ = (1/n) × ln(x₁/xₙ) = _______
    ζ = δ / √(4π² + δ²)  = _______
    PASS (ζ ≥ 0.3)?  [ ] YES  [ ] NO
    If NO: change to 100–200 wt silicone oil, retest → new ζ = _______

□ Test 3 — Stroke verification (at 7.00 kg with k from Test 1):
    L_min (full bump, eye-to-eye):   _______ mm
    L_max (full droop, eye-to-eye):  _______ mm
    Total stroke = L_max − L_min:    _______ mm
    Static sag δ = 7.00×9.81/k:     _______ mm  (expected: ~16 mm)
    Bump travel = compression − δ:   _______ mm  (need ≥ 15, expected ~17 mm)
    Rebound travel available:        _______ mm  (need ≥ 15 mm)
    PASS?  [ ] YES  [ ] NO → if NO, add 2–3 mm preload via collar

□ Overall verdict:
    [ ] ALL 3 PASS → order 4 units, proceed to prototype build
    [ ] Test 1 fail (k wrong) → source d=1.9 mm replacement spring
    [ ] Test 2 fail (ζ low)   → change oil (100–200 wt), retest
    [ ] Test 3 fail (stroke)  → add preload via collar; if still fails, source longer shock
    [ ] Multiple fail         → reassess unit before ordering
```

---

## Target Values Reference / 目标参数参考

| Parameter | Indoor target | Acceptable range | This unit's constraint |
|---|---|---|---|
| k per corner | 3,127 N/m | 2,500–4,500 N/m | Estimated 4,400–5,500 N/m (measure!) |
| ζ | 0.4 | 0.3–0.6 | Unknown — **Test 2 required** |
| Stroke | ≥ 46 mm | ≥ 38 mm (if k > 3,500 N/m) | **33 mm — tight, verify rebound** |
| fn (resulting) | 4 Hz | 3.5–5 Hz | ~4.5–5.3 Hz (if k as estimated) |
| Static sag | 15.5 mm | 10–25 mm | ~11–12 mm (if k ~4,000–4,500 N/m) |

---

*See also: `suspension_design_summary.md` for the full design derivation and target justification.*
*另见：`suspension_design_summary.md`，包含完整设计推导与目标依据。*
