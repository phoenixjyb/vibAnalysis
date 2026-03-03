# Suspension Candidate Evaluation Guide
# 候选减震器评估指南

**Unit under test / 待测型号:** RC coil-over shock, 115 mm total, 33 mm stroke, 3 mm shaft
**Tools needed / 所需工具:** Ruler, digital scale, known weights (~100–500 g), phone camera (slow-mo), string or clamp
**Time required / 预计耗时:** ~30 minutes for all tests / 全部测试约30分钟

---

## Overview / 概述

We need to determine three things before accepting this shock as a suspension candidate.
在接受此减震器作为悬挂候选件之前，我们需要确定三件事：

| Test # | What we measure | What we need | Pass criterion |
|---|---|---|---|
| 1 | Spring rate k (N/m) | k = 3,127 N/m | 2,500–4,500 N/m |
| 2 | Damping ratio ζ (or c) | ζ = 0.4 | ζ > 0.3 |
| 3 | Stroke check | ≥ 46 mm total | ≥ 46 mm |

If all three pass → proceed to prototype.
If any fail → see the Fix / Swap decision at the end.

三项均通过 → 进入样机阶段。
任一不通过 → 见末尾的修复/更换决策。

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

**Expected result / 预期结果:** 7–12 coils for a 72 mm spring with 2.2 mm wire.
72 mm弹簧、2.2 mm线径，预期有效圈数约为7–12圈。

**Quick formula cross-check / 快速公式校验:**
```
k_formula = (80,000 × 2.2⁴) / (8 × 17.5³ × n)
           = 43,700 / n   [N/m]
```
| n | k_formula |
|---|---|
| 7 | 6,243 N/m |
| 8 | 5,462 N/m |
| 9 | 4,856 N/m |
| 10 | 4,370 N/m |
| 12 | 3,642 N/m |
| 14 | 3,121 N/m ← target |

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

| k_measured | Result | fn at 4.95 kg/corner |
|---|---|---|
| < 2,500 N/m | ✗ Too soft — static sag > 19 mm, fn < 3.6 Hz | < 3.6 Hz |
| 2,500–3,500 N/m | ✓ **Ideal range** — fn 3.6–4.2 Hz | 3.6–4.2 Hz |
| 3,500–4,500 N/m | ⚠ Acceptable — fn 4.2–4.8 Hz, slightly stiff | 4.2–4.8 Hz |
| > 4,500 N/m | ✗ Too stiff — fn > 4.8 Hz, reduced isolation | > 4.8 Hz |

**If k is too high:** You have two options —
1. Source a softer spring (same OD/ID/free-length, thinner wire, e.g. 1.8 mm)
2. Put two shocks in series on a rocker arm (halves effective k)

**若k过高：** 有两个方案——
1. 换一根更软的弹簧（相同外径/内径/自由长，更细线径，例如1.8 mm）
2. 通过摇臂将两个减震器串联（等效k减半）

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
    [bottom eye]──── rigid plate (4.95 kg total including plate)
```

If you don't have a rig yet, use 500 g weight (close enough for a first indication):
若暂无测试台架，可用500 g砝码（作为初步判断已足够）：

1. Mount shock vertically, hang 500 g from bottom eye (or use actual 4.95 kg if rig available).
   竖直安装减震器，底部吊耳悬挂500 g（如有测试台架可用实际4.95 kg）。
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

### Required stroke for our design / 设计所需行程

| Scenario | Static sag δ | Dynamic allowance | **Total stroke needed** |
|---|---|---|---|
| Indoor, fn=4 Hz, k=3,127 N/m | 15.5 mm | ±15 mm | **≥ 45.5 mm** |
| Indoor, fn=4.5 Hz, k=4,000 N/m | 12.1 mm | ±13 mm | **≥ 38 mm** |
| Pavement, fn=3 Hz, k=1,758 N/m | 27.6 mm | ±20 mm | **≥ 68 mm** |

This shock provides **33 mm compression stroke** only. Measuring available rebound:

此减震器提供**33 mm压缩行程**，还需测量可用回弹量：

### Measure rebound travel / 测量回弹行程

1. Compress the shock fully by hand. Measure the eye-to-eye distance at full compression: **L_min = _____ mm**
   用手将减震器压缩至底，测量吊耳间距：**L_min = _____ mm**
2. Extend the shock fully (pull apart until it stops). Measure eye-to-eye: **L_max = _____ mm**
   将减震器完全拉伸（拉到底），测量吊耳间距：**L_max = _____ mm**
3. Total stroke = L_max − L_min = _____ mm
   总行程 = L_max − L_min = _____ mm
4. At static sag (k and mass known from Tests 1):
   在静态下沉量处（由测试1的k值和质量计算）：
   - Static sag δ = m·g/k = 4.95 × 9.81 / k_measured = _____ mm
   - Remaining bump travel = L_compression − δ = _____ mm  (need ≥ 15 mm)
   - Available rebound travel = L_extension − δ = _____ mm  (need ≥ 15 mm, currently ~15.5 mm: **tight!**)

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

Print and fill in as you test:
打印后测试时逐项填写：

```
Unit: RC coil-over 115mm / 33mm stroke / 3mm shaft

□ Step 0 — Active coil count:  n = _______ coils

□ Test 1 — Spring rate:
    100g deflection: _______ mm  → k = _______ N/m
    200g deflection: _______ mm  → k = _______ N/m
    300g deflection: _______ mm  → k = _______ N/m
    k_average = _______ N/m      → fn = _______ Hz
    PASS (2,500–4,500 N/m)?  [ ] YES  [ ] NO

□ Test 2 — Damping:
    Ring-down visible cycles: _______
    x₁ = _______ mm   xₙ = _______ mm   n_peaks = _______
    δ = _______        ζ = _______
    PASS (ζ ≥ 0.3)?  [ ] YES  [ ] NO → if NO, change oil and retest

□ Test 3 — Stroke:
    L_min (full bump):    _______ mm
    L_max (full droop):   _______ mm
    Total stroke:         _______ mm
    Static sag (m·g/k):  _______ mm
    Bump travel remaining: _______ mm  (need ≥ 15 mm)
    Rebound available:    _______ mm  (need ≥ 15 mm)
    PASS?  [ ] YES  [ ] NO → if NO, try preload or source longer unit

□ Overall verdict:
    [ ] ALL PASS — proceed to 4-unit prototype build
    [ ] k fail only — source replacement spring
    [ ] ζ fail only — change oil, retest
    [ ] stroke fail — adjust preload or source longer unit
    [ ] multiple fail — evaluate cost vs sourcing a different unit
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
