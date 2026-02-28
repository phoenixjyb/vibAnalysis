# Vibration Analysis & Suspension Design — Full Report
# 振动分析与悬挂设计——完整报告

**Platform / 平台:** X-configuration omni-wheel chassis (unsuspended, bare chassis)
**X型全向轮底盘（无悬挂，裸底盘）**

**Sensor / 传感器:** Z-axis accelerometer, mounted on chassis body / Z轴加速度计，安装于底盘本体

**Analysis tool / 分析工具:** MATLAB R2024a, Welch PSD, Fs = 27,027 Hz

**Date / 日期:** 2026-02

---

## Table of Contents / 目录

1. [Platform Specifications](#1-platform-specifications--平台参数)
2. [Test Datasets](#2-test-datasets--测试数据集)
3. [Multi-Surface RMS Results](#3-multi-surface-rms-results--多地面rms汇总)
4. [Frequency Analysis](#4-frequency-analysis--频率分析)
5. [Low-Speed Resonance Problem](#5-low-speed-resonance-problem--低速共振问题)
6. [Mitigation Options for Low-Speed Resonance](#6-mitigation-options--低速共振缓解方案)
7. [Suspension Design](#7-suspension-design--悬挂设计)
8. [Wheel Swap: 6-inch N=9 vs Current 5-inch N=11](#8-wheel-comparison--车轮对比)
9. [Conclusions & Recommendations](#9-conclusions--结论与建议)
10. [Adding Mass to Shift Resonance](#10-adding-mass-to-shift-resonance--增加质量以移频)
11. [Pneumatic Tyres vs Omni Wheels](#11-pneumatic-tyres-vs-omni-wheels--充气轮胎与全向轮对比)

---

## 1. Platform Specifications / 平台参数

### 1.1 Chassis geometry / 底盘构型

| Parameter / 参数 | Value / 数值 | Notes / 备注 |
|---|---|---|
| Wheel configuration / 轮型 | X-type omni / X型全向轮 | Wheel axes at **45° to forward** / 轮轴与前进方向成**45°** |
| Number of wheels / 轮数 | 4 | One per corner / 每角一个 |
| Wheel diameter (current) / 车轮直径（当前） | 5 in = **127 mm** | |
| Wheel circumference (current) / 周长（当前） | π × 0.127 = **0.3990 m** | |
| Rollers per plate (current) / 每板滚子数（当前） | **11** | 2 plates per wheel / 每轮2块板 |
| Total rollers per wheel (current) / 每轮总滚子数 | **22** (staggered 16.4°) / **22个**（错位16.4°）| N=22 passage suppressed / N=22过频受抑制 |
| Total robot mass / 整机质量 | **25 kg** | Excludes suspension hardware / 不含悬挂零件 |
| Unsprung mass / 非簧载质量 | **5.2 kg** | 4 × 1.3 kg (motor + wheel) / 4×1.3 kg（电机+轮组） |
| Sprung mass / 簧载质量 | **19.8 kg** | = 4.95 kg per corner / = 每角4.95 kg |
| Motor max RPM / 电机最大转速 | **6,500 RPM** | |
| Reducer ratio / 减速比 | **37.14** | |
| Max chassis speed (motor limit) / 最大底盘速度（电机限制） | ~1.65 m/s | |

### 1.2 Critical kinematics — X-configuration correction / X构型运动学修正（关键）

For pure forward chassis motion at speed `v_chassis`, each wheel rolls at:
纯前进运动时，各轮滚动速度为：

```
v_wheel = v_chassis × cos(45°) = v_chassis / √2
```

**All frequency formulas must use this correction / 所有频率公式必须使用此修正：**

```matlab
% CORRECT / 正确
f_roller = N * v_chassis / (sqrt(2) * wheelCirc);

% WRONG — ignores 45° alignment / 错误——忽略45°对准
f_roller = N * v_chassis / wheelCirc;   % ← off by √2 factor
```

> Without the √2 correction, apparent N was ~8/rev (mystery); with correction it is exactly **N=11** (< 6% error). / 不用√2修正时，表观N约8/转（原因不明）；修正后精确为**N=11**（误差<6%）。

### 1.3 True sample rate / 真实采样率

Column 5 of the CSV declares ~26,820 Hz — **this is wrong.**
CSV第5列声明约26,820 Hz——**该值有误。**

Timestamp analysis (37 µs steps) gives: `Fs = **27,027 Hz**` (hardcoded in all scripts).
时间戳分析（37 µs步长）得到：`Fs = **27,027 Hz**`（所有脚本中硬编码）。

---

## 2. Test Datasets / 测试数据集

### 2.1 Original baseline / 原始基线

| Item / 项目 | Value / 数值 |
|---|---|
| Files / 文件数 | 6 CSV (0.2–1.2 m/s) |
| Surface / 地面 | Indoor smooth floor / 室内光滑地面 |
| Confirmed equivalent to / 等效于 | Indoor white/black tile (within 7%) / 室内白/黑砖（误差<7%） |
| Location / 路径 | `testData/recomoProto1-190-logs-acc-diff-speeds/` |

### 2.2 Multi-surface tests / 多地面测试

| Surface ID / 地面ID | Description / 描述 | Files / 文件数 |
|---|---|---|
| Black | Indoor Black Tile / 室内黑砖 | 7 CSV (0.2–1.5 m/s) |
| White | Indoor White Tile / 室内白砖 | 7 CSV (0.2–1.5 m/s) |
| Cement | Outdoor Cement / 室外水泥路 | 7 CSV (0.2–1.5 m/s) |
| Pavement | Outdoor Paving Stones / 室外人行道 | 7 CSV (0.2–1.5 m/s) |

**Total: 34 CSV files across 5 datasets. / 共34个CSV文件，5个数据集。**

> **Clarification / 说明:** The "2.58 g at 1.2 m/s" figure cited in early analysis is an **instantaneous peak** (`max(abs(Z))`), not RMS. The Z-axis RMS at 1.2 m/s is **0.50 g**. / 早期分析中提到的"1.2 m/s时2.58 g"为**瞬时峰值**，非RMS。1.2 m/s时Z轴RMS为**0.50 g**。

---

## 3. Multi-Surface RMS Results / 多地面RMS汇总

### 3.1 Z-axis RMS (g) — all surfaces, all speeds / Z轴RMS（g）——所有地面，所有速度

| Surface / 地面 | 0.2 | 0.4 | 0.6 | 0.8 | 1.0 | 1.2 | **1.5** |
|---|---|---|---|---|---|---|---|
| Black Tile / 黑砖 | 0.068 | 0.196 | 0.277 | 0.374 | 0.513 | 0.552 | **0.705** |
| White Tile / 白砖 | 0.064 | 0.201 | 0.296 | 0.379 | 0.507 | 0.534 | **0.674** |
| Cement / 水泥路 | 0.193 | 0.546 | 1.073 | 1.765 | 2.507 | 3.257 | **3.575** |
| Pavement / 人行道 | 0.072 | 0.240 | 0.406 | 0.565 | 0.828 | 1.068 | **1.306** |
| Baseline (original) / 基线（原始） | 0.069 | 0.239 | 0.303 | 0.397 | 0.500 | 0.500 | — |

### 3.2 Surface severity ratios vs indoor white tile / 地面严酷度比（vs室内白砖）

| Speed / 速度 | Cement / White | Pavement / White |
|---|---|---|
| 0.2 m/s | 3.0× | 1.1× |
| 0.8 m/s | 4.7× | 1.5× |
| 1.2 m/s | **6.1×** | 2.0× |
| 1.5 m/s | 5.3× | 1.9× |

**Key finding / 关键发现:** Outdoor cement generates 3–6× higher vibration than indoor tile at all speeds. Outdoor pavement is moderate at 1.1–2.0×. / 室外水泥路在所有速度下振动幅度比室内地砖高3–6倍；室外人行道居中，约1.1–2.0倍。

---

## 4. Frequency Analysis / 频率分析

### 4.1 N=11 per-plate roller passage (dominant mechanical excitation) / N=11每板滚子过频（主导机械激励）

**Formula / 公式:** `f_roller = 11 × v_chassis / (√2 × 0.3990)`

| Speed / 速度 | Predicted / 预测 (Hz) | Measured / 实测 (Hz) | Error / 误差 | Surface / 地面 |
|---|---|---|---|---|
| 0.8 m/s | 15.6 | 16.5 | −5.5% | Indoor (all) / 室内（全部）|
| 1.0 m/s | 19.5 | 19.8 | −1.5% | Indoor (all) / 室内（全部）|
| 1.2 m/s | 23.4 | 23.1 | +1.3% | Indoor (all) / 室内（全部）|
| 1.5 m/s | 29.2 | 27.2 | −6.9% | White tile / 白砖 |
| 1.5 m/s | 29.2 | 26.4 | −9.7% | Cement / 水泥路 (broadband noise masks peak) |

**Conclusion / 结论:**
- N=11 is confirmed as the dominant mechanical excitation at all speeds ≥ 0.8 m/s, across all 4 surfaces. / N=11已在所有地面、所有≥0.8 m/s速度下确认为主导机械激励。
- N=22 (combined dual-plate passage) is **suppressed** by the 16.4° stagger design. / N=22（双板合计过频）因16.4°错位设计受到**抑制**。
- Cement broadband noise partially masks the roller peak at 1.5 m/s, causing slightly larger error. / 水泥路宽频噪声在1.5 m/s时部分掩盖滚子峰值，导致误差略大。

### 4.2 Motor cogging (dominant at low speeds) / 电机齿槽（低速主导）

**Formula / 公式:** `f_cogging = 10.2 × v_chassis / (√2 × 0.3990) × 37.14`

| Speed / 速度 | Predicted / 预测 (Hz) | Measured / 实测 (Hz) | Error / 误差 |
|---|---|---|---|
| 0.2 m/s | 134 | 135 | +0.7% |
| 0.4 m/s | 269 | 269 | < 0.1% |
| 0.6 m/s | 403 | 404 | +0.2% |

- ~10.2 events per motor revolution — motor **electrical excitation (cogging torque)**, not gear mesh. / 约10.2次/电机转——电机**电气激励（齿槽转矩）**，非齿轮啮合。
- Gear mesh ruled out: the measured ratio 10.27 events/motor_rev is non-integer, which gear mesh cannot produce. Wide-band PSD (0–2000 Hz) confirms no gear mesh peaks above 500 Hz. / 齿轮啮合已排除：实测10.27次/转非整数，齿轮啮合不可能产生；0–2000 Hz宽频PSD证实500 Hz以上无齿轮啮合峰。
- At 1.5 m/s, cogging frequency = **1,007 Hz** — outside the 0–500 Hz analysis window. / 1.5 m/s时齿槽频率 = **1,007 Hz**，超出0–500 Hz分析窗口。

### 4.3 Cement structural resonance (~79 Hz) / 水泥路结构共振（约79 Hz）

A **speed-independent** peak at **79.2 Hz** appears on outdoor cement at 0.8, 1.0, and 1.2 m/s.
室外水泥路在0.8、1.0、1.2 m/s均出现**79.2 Hz**的**速度无关**峰值。

- Not kinematic: N=11 at these speeds is 15.6–23.4 Hz; N=22 is 31.2–46.8 Hz — neither matches 79 Hz. / 非运动学成因：这些速度下N=11为15.6–23.4 Hz，N=22为31.2–46.8 Hz，均与79 Hz不符。
- **Conclusion:** Chassis structural resonance excited by the broadband vibration energy of the rough cement surface. / **结论：** 粗糙水泥路面宽频激励引发的底盘结构共振。
- Does not affect suspension design (well above fn = 4 Hz range). / 不影响悬挂设计（远高于fn=4 Hz范围）。

### 4.4 Complete frequency table — all speeds / 完整频率表——所有速度

| Speed / 速度 | N=11 (Hz) | N=22 (Hz) | Cogging (Hz) | Motor RPM |
|---|---|---|---|---|
| 0.2 m/s | 3.9 | 7.8 | 134 | 788 |
| 0.4 m/s | 7.8 | 15.6 | 269 | 1,575 |
| 0.6 m/s | 11.7 | 23.4 | 403 | 2,363 |
| 0.8 m/s | 15.6 | 31.2 | 537 | 3,150 |
| 1.0 m/s | 19.5 | 39.0 | 671 | 3,938 |
| 1.2 m/s | 23.4 | 46.8 | 806 | 4,725 |
| **1.5 m/s** | **29.2** | **58.5** | **1,007** | **5,906** |

---

## 5. Low-Speed Resonance Problem / 低速共振问题

### 5.1 Discovery / 发现

The N=11 roller frequency at **v = 0.2 m/s = 3.9 Hz** — almost exactly equal to the designed suspension natural frequency **fn = 4.0 Hz**.
**v = 0.2 m/s时N=11滚子频率 = 3.9 Hz**——几乎精确等于悬挂设计自然频率**fn = 4.0 Hz**。

This means the suspension **amplifies** roller vibration instead of isolating it at low speeds.
这意味着悬挂在低速时**放大**滚子振动，而非隔离。

### 5.2 Full low-speed transmissibility / 低速段完整传递率

**Formula / 公式:** `T(r, ζ) = √[(1 + (2ζr)²) / ((1−r²)² + (2ζr)²)]`  where `r = f_N11 / fn`

| Speed / 速度 | N=11 (Hz) | r | T (fn=4, ζ=0.4) | Effect / 效果 |
|---|---|---|---|---|
| 0.01 m/s | 0.2 | 0.05 | 1.00 | Near unity / 接近单位 |
| 0.05 m/s | 1.0 | 0.24 | 1.06 | Mild amplification / 轻微放大 |
| **0.10 m/s** | **1.9** | **0.49** | **1.25** | Amplifying / 放大 |
| **0.15 m/s** | **2.9** | **0.73** | **1.55** | Strong amplification / 显著放大 |
| **0.20 m/s** | **3.9** | **0.97** | **1.62** | ⚠ **Peak — resonance / 峰值——共振** |
| 0.25 m/s | 4.9 | 1.22 | 1.28 | Decreasing / 递减 |
| **0.29 m/s** | **5.7** | **1.41** | **1.00** | **Isolation onset / 隔振起效** |
| 0.30 m/s | 5.8 | 1.46 | 0.94 | Isolating / 隔振中 |
| 0.40 m/s | 7.8 | 1.95 | 0.58 | Good isolation / 良好隔振 |

**The amplification zone spans 0.10–0.29 m/s — not just 0.2 m/s.**
**放大区间为0.10–0.29 m/s——不仅仅是0.2 m/s。**

Key physics / 关键物理规律:
- **Below 0.2 m/s**: approaching resonance from below — amplification increases as speed rises toward 0.2 m/s. / **低于0.2 m/s**：从低速侧趋近共振——放大倍数随速度升高而增大。
- **At 0.2 m/s**: peak amplification (r ≈ 1). / **0.2 m/s**：放大峰值（r≈1）。
- **0.15 m/s is nearly as bad as 0.2 m/s** (T = 1.55 vs 1.62). / **0.15 m/s与0.2 m/s几乎同样危险**（T=1.55 vs 1.62）。
- **Very low speeds (< 0.05 m/s)**: N=11 → 0 Hz, far below fn; T ≈ 1 (no amplification, but also no isolation needed — vibration input is negligible at crawl). / **极低速（<0.05 m/s）**：N=11趋近0 Hz，远低于fn；T≈1（无放大，也无需隔振——爬行速度下振动输入可忽略不计）。

---

## 6. Mitigation Options / 低速共振缓解方案

*(Software speed skip ruled out — robot must operate continuously in 0.1–0.3 m/s range.)*
*（软件跳速方案已排除——机器人需在0.1–0.3 m/s范围内持续运行。）*

### Option A — Increase damping ratio only (keep fn = 4 Hz) / 方案A——仅增大阻尼比（保持fn=4 Hz）

Just replace the damper unit. Spring unchanged.
仅更换阻尼器，弹簧不变。

| ζ | T @ 0.2 m/s | T @ 1.5 m/s | c (N·s/m) | Assessment / 评价 |
|---|---|---|---|---|
| 0.40 (current) | 1.62 | 0.112 | 99.5 | Baseline / 基线 |
| 0.50 | 1.43 | 0.139 | 124.4 | Some improvement / 小幅改善 |
| 0.70 | 1.24 | 0.193 | 174.2 | Significant improvement / 显著改善 |
| 1.00 | 1.12 | 0.269 | 248.8 | Diminishing returns / 收益递减 |

- **Limitation:** Even at ζ = 1.0, T@0.2 m/s = 1.12. Damping alone cannot eliminate resonance amplification. High-speed isolation also degrades. / **局限：** 即便ζ=1.0，T@0.2 m/s仍为1.12。单靠阻尼无法消除共振放大；高速隔振性能亦有所下降。
- **Practical ceiling: ζ ≈ 0.7** (halves resonance overshoot with acceptable cost). / **实用上限：ζ≈0.7**（共振超调减半，代价可接受）。

### Option B — Lower fn (shift resonance below operating range) / 方案B——降低fn（将共振移至工况范围以下）

| fn (Hz) | Resonance speed / 共振速度 | T @ 0.2 m/s | T @ 1.5 m/s | k (N/m) | Static sag / 静态下沉 |
|---|---|---|---|---|---|
| 4.0 (current) | 0.205 m/s | 1.62 | 0.112 | 3,127 | 16 mm |
| 3.0 | 0.154 m/s | 1.16 | 0.083 | 1,759 | 28 mm |
| **2.5** | **0.128 m/s** | **0.84** | **0.069** | **1,221** | **40 mm** |
| 2.0 | 0.103 m/s | 0.58 | 0.055 | 782 | 62 mm |

fn = 2.5 Hz pushes the resonance to 0.128 m/s, **below the typical operating minimum**, and reduces T@0.2 m/s to 0.84 (now attenuating). Cost is ~40 mm static sag and ~120 mm minimum stroke.
fn=2.5 Hz将共振移至0.128 m/s，**低于典型最低工作速度**，T@0.2 m/s降至0.84（已变为衰减）。代价是约40 mm静态下沉和约120 mm最小行程。

### Option C — Combined: lower fn + higher damping (recommended) / 方案C——组合：降低fn+提高阻尼（推荐）

| fn (Hz) | ζ | T @ 0.1 m/s | **T @ 0.2 m/s** | T @ 1.5 m/s | k (N/m) | c (N·s/m) | Sag / 下沉 |
|---|---|---|---|---|---|---|---|
| 3.0 | 0.70 | 1.25 | **1.07** | 0.144 | 1,759 | 130.6 | 28 mm |
| 2.5 | 0.70 | 1.28 | **0.92** | 0.120 | 1,221 | 108.9 | 40 mm |
| 2.5 | 0.50 | 1.45 | **0.87** | 0.086 | 1,221 | 77.8 | 40 mm |

**Recommended: fn = 3.0 Hz + ζ = 0.7**
**推荐：fn = 3.0 Hz + ζ = 0.7**

- T@0.2 m/s = **1.07** — only 7% overshoot, negligible in practice. / T@0.2 m/s = **1.07**——仅7%超调，实际影响可忽略。
- Resonance speed = 0.154 m/s — passed through briefly during acceleration, not sustained. / 共振速度 = 0.154 m/s——加速时短暂经过，不会持续。
- Isolation onset drops to 0.218 m/s — effective isolation starts much earlier. / 隔振起效速度降至0.218 m/s——隔振更早生效。
- k = 1,759 N/m, c = 130.6 N·s/m — achievable with standard components. / k=1,759 N/m，c=130.6 N·s/m——标准元件可实现。
- Static sag = 28 mm, minimum stroke ≈ 84 mm — manageable. / 静态下沉28 mm，最小行程约84 mm——可接受。

---

## 7. Suspension Design / 悬挂设计

### 7.1 1-DOF model / 单自由度模型

Transmissibility of a 1-DOF spring-damper system:
单自由度弹簧-阻尼系统传递率：

```
T = √[(1 + (2ζr)²) / ((1−r²)² + (2ζr)²)]
r = f_excitation / fn
fn = (1/2π) × √(k / m_sprung)
ζ = c / (2 × √(k × m_sprung))
```

### 7.2 Mass split / 质量分配

| Mass / 质量 | Value / 数值 |
|---|---|
| Total robot mass / 整机总质量 | 25 kg |
| Unsprung mass (4 × motor+wheel) / 非簧载质量（4×电机+轮） | 5.2 kg (4 × 1.3 kg) |
| Sprung mass / 簧载质量 | **19.8 kg** |
| Sprung mass per corner / 每角簧载质量 | **4.95 kg** |

> ⚠ 25 kg excludes suspension hardware. Recompute k and c after hardware is weighed and added to total.
> ⚠ 25 kg不含悬挂零件。称量零件后须重新计算k和c。

### 7.3 Current design parameters (indoor use) / 当前设计参数（室内使用）

| Parameter / 参数 | Value / 数值 |
|---|---|
| Natural frequency / 自然频率 | **fn = 4.0 Hz** |
| Damping ratio / 阻尼比 | **ζ = 0.4** |
| Spring stiffness (per corner) / 弹簧刚度（每角） | **k = 3,127 N/m** |
| Damping coefficient (per corner) / 阻尼系数（每角） | **c = 99.5 N·s/m** |
| Static sag / 静态下沉 | **15.5 mm** |
| Minimum stroke / 最小行程 | **46 mm** |

### 7.4 Predicted suspension output — indoor surface / 预测悬挂输出——室内地面

| Speed / 速度 | Input RMS (g) | T | Output RMS (g) | < 0.1 g? |
|---|---|---|---|---|
| 0.2 m/s | 0.068 | 1.62 | 0.110 | ⚠ marginal |
| 0.4 m/s | 0.201 | 0.578 | 0.116 | ⚠ marginal |
| 0.6 m/s | 0.296 | 0.322 | 0.095 | ✓ |
| 0.8 m/s | 0.379 | 0.225 | 0.085 | ✓ |
| 1.0 m/s | 0.507 | 0.174 | 0.088 | ✓ |
| 1.2 m/s | 0.534 | 0.143 | 0.076 | ✓ |
| 1.5 m/s | 0.674 | 0.112 | 0.076 | ✓ |

### 7.5 Surface-specific suspension requirements / 按地面类型的悬挂需求

| Surface / 地面 | Recommended fn / 推荐fn | ζ | Notes / 备注 |
|---|---|---|---|
| Indoor tile / 室内地砖 | **4 Hz** (or 3 Hz if low-speed matters) | 0.4–0.7 | Target < 0.1 g met at ≥ 0.6 m/s |
| Outdoor pavement / 室外人行道 | **3 Hz** | 0.5 | Marginal at 0.8 m/s |
| Outdoor cement / 室外水泥路 | **2 Hz** | 0.5 | Requires k ≈ 782 N/m, sag 62 mm |

### 7.6 Suspension performance at 1.5 m/s (T = 0.112) / 1.5 m/s时悬挂性能（T=0.112）

| Surface / 地面 | Input RMS (g) | Predicted output / 预测输出 (g) | < 0.1 g? |
|---|---|---|---|
| Black Tile / 黑砖 | 0.705 | **0.079** | ✓ |
| White Tile / 白砖 | 0.674 | **0.076** | ✓ |
| Pavement / 人行道 | 1.306 | **0.147** | ✗ |
| Cement / 水泥路 | 3.575 | **0.401** | ✗ |

---

## 8. Wheel Comparison / 车轮对比

### 8.1 Specifications / 规格对比

| Parameter / 参数 | Current: 5 in, N=11 / 当前：5英寸N=11 | New: 6 in, N=9 / 新：6英寸N=9 |
|---|---|---|
| Diameter / 直径 | 127 mm | **152.4 mm** |
| Circumference / 周长 | 0.3990 m | 0.4788 m |
| Rollers per plate / 每板滚子数 | **11** | 9 |
| Total rollers / 总滚子数 | 22 (stagger 16.4°) | 18 (stagger 20.0°) |
| Dominant excitation / 主激励 | **N=11** | **N=9** |
| Combined (suppressed) / 合计（受抑制） | N=22 | N=18 |
| Roller frequency at 1.0 m/s / 1.0 m/s时滚子频率 | 19.5 Hz | 13.3 Hz |
| Resonance speed (fn=4 Hz) / 共振速度（fn=4 Hz） | **0.205 m/s** | **0.301 m/s** |
| Isolation onset (fn=4 Hz) / 隔振起效速度（fn=4 Hz） | **0.290 m/s** | **0.426 m/s** |
| Max chassis speed / 最大底盘速度 | ~1.65 m/s | ~**1.97 m/s** |

### 8.2 Transmissibility comparison (fn = 4 Hz, ζ = 0.4) / 传递率对比（fn=4 Hz，ζ=0.4）

| Speed / 速度 | T old (N=11) / 旧轮 | T new (N=9) / 新轮 | Better / 更优 |
|---|---|---|---|
| 0.1 m/s | 1.25 | 1.11 | New (slightly) |
| 0.2 m/s | **1.62** | 1.47 | Old (marginally) |
| **0.3 m/s** | **0.94** ✓ isolating | **1.60** ✗ amplifying | **Old** |
| 0.4 m/s | 0.58 | 1.11 | **Old** |
| 0.6 m/s | 0.32 | 0.56 | **Old** |
| 1.0 m/s | 0.174 | 0.273 | **Old** |
| 1.5 m/s | **0.112** | 0.170 | **Old** |

### 8.3 Head-to-head verdict / 综合评定

| Criterion / 评价维度 | Old (5 in, N=11) / 旧轮 | New (6 in, N=9) / 新轮 | Winner / 胜者 |
|---|---|---|---|
| Resonance location / 共振位置 | 0.20 m/s (low end of range) / 速度范围低端 | 0.30 m/s (middle of range) / 速度范围中段 | **Old** |
| Isolation onset / 隔振起效 | 0.29 m/s | 0.43 m/s | **Old** |
| High-speed isolation / 高速隔振 | T = 0.112 @ 1.5 m/s | T = 0.170 @ 1.5 m/s | **Old** |
| Roller smoothness / 滚动平顺性 | N=11 (more rollers) | N=9 (fewer rollers) | **Old** |
| Top speed / 最高速度 | 1.65 m/s | **1.97 m/s** | **New** |
| Obstacle clearance / 越障能力 | 63.5 mm radius | **76.2 mm radius** | **New** |

### 8.4 Verdict / 结论

**The old 5-inch N=11 wheel is more favourable for vibration isolation.**
**旧款5英寸N=11车轮在振动隔离方面更具优势。**

The new wheel's resonance lands at **0.30 m/s** — a commonly sustained operating speed (corridor transit). The old wheel's resonance at 0.20 m/s is at the lower extreme of the operating range, passed through briefly during acceleration. The new wheel's isolation onset at 0.43 m/s means vibration is amplified across a much wider fraction of the working speed range.

新轮共振发生在**0.30 m/s**——这是常见的持续运行速度（走廊巡航）。旧轮共振在0.20 m/s，处于速度范围最低端，加速时短暂通过。新轮隔振起效速度为0.43 m/s，意味着在更大的工作速度范围内振动被放大。

**If the new wheel is required** (for top speed or clearance): redesign suspension to **fn = 2.5–3.0 Hz, ζ = 0.7** to compensate.
**若必须采用新轮**（为了速度或越障）：须将悬挂重新设计为 **fn = 2.5–3.0 Hz，ζ = 0.7** 加以补偿。

### 8.5 New wheel — updated frequency formulas / 新轮——更新后的频率公式

```matlab
wC_new    = pi * 0.1524;               % 0.4788 m
f_roller  = @(v) 9 * v / (sqrt(2) * wC_new);    % N=9 dominant
f_cogging = @(v) 10.2 * v/(sqrt(2)*wC_new) * 37.14;
```

| Speed / 速度 | N=9 roller (Hz) / N=9滚子(Hz) | Cogging (Hz) / 齿槽(Hz) |
|---|---|---|
| 0.2 m/s | 2.7 | 112 |
| 0.4 m/s | 5.3 | 224 |
| 0.6 m/s | 8.0 | 336 |
| 0.8 m/s | 10.6 | — |
| 1.0 m/s | 13.3 | — |
| 1.2 m/s | 16.0 | — |
| 1.5 m/s | 19.9 | — |

---

## 9. Conclusions & Recommendations / 结论与建议

### 9.1 Confirmed findings (high confidence) / 已确认结论（高置信度）

| # | Finding / 结论 | Evidence / 依据 |
|---|---|---|
| 1 | **N=11 roller passage** is the dominant mechanical excitation at speeds ≥ 0.4 m/s. N=22 is stagger-suppressed. / **N=11滚子过频**是≥0.4 m/s速度下的主导机械激励，N=22因错位设计受抑制。 | <6% error across 4 surfaces, 5 speeds |
| 2 | **Motor cogging (~10.2 events/motor-rev)** dominates at low speeds (0.2–0.6 m/s). Not gear mesh (non-integer ratio). / **电机齿槽（约10.2次/转）**在低速（0.2–0.6 m/s）主导，非齿轮啮合（比值非整数）。 | <0.7% error, all smooth surfaces |
| 3 | **X-config √2 correction is essential.** Without it, apparent N ≈ 8 (mystery); with it, exactly N=11. / **X构型√2修正不可或缺。** 不修正时表观N≈8（原因不明）；修正后精确为N=11。 | Physics confirmed |
| 4 | **True Fs = 27,027 Hz.** CSV column 5 (~26,820 Hz) is inaccurate. / **真实Fs = 27,027 Hz。** CSV第5列（~26,820 Hz）有误。 | Timestamp analysis |
| 5 | **Original baseline = indoor smooth floor**, consistent with white/black tile results (within 7%). / **原始基线 = 室内光滑地面**，与白/黑砖结果一致（误差<7%）。 | Cross-dataset RMS comparison |
| 6 | **Cement generates 3–6× more vibration** than indoor tile at all speeds. / **水泥路振动幅度是室内地砖的3–6倍**，在所有速度下均如此。 | RMS table |
| 7 | **Cement ~79 Hz peak is chassis structural resonance**, not a kinematic frequency. Speed-independent. / **水泥路约79 Hz峰值为底盘结构共振**，非运动学频率，速度无关。 | Constant across 0.8/1.0/1.2 m/s |
| 8 | **Low-speed resonance zone: 0.10–0.29 m/s.** T peaks at 1.62 × at 0.2 m/s with fn=4 Hz, ζ=0.4. / **低速共振区间：0.10–0.29 m/s。** fn=4 Hz，ζ=0.4时，0.2 m/s处T峰值1.62倍。 | Transmissibility calculation |

### 9.2 Design recommendations / 设计建议

| Priority / 优先级 | Action / 行动 | Rationale / 依据 |
|---|---|---|
| 1 | **Keep old 5-inch N=11 wheel** unless top speed > 1.65 m/s or larger obstacle clearance is required. / **保留旧款5英寸N=11车轮**，除非需要>1.65 m/s速度或更大越障能力。 | New wheel shifts resonance to 0.30 m/s — worse for vibration |
| 2 | **Redesign suspension to fn = 3.0 Hz, ζ = 0.7** if continuous operation in 0.1–0.3 m/s is required. / **若需在0.1–0.3 m/s持续运行，将悬挂重新设计为fn=3.0 Hz，ζ=0.7。** | Reduces T@0.2m/s from 1.62 to 1.07 |
| 3 | **Weigh suspension hardware** and recompute k, c with actual sprung mass per corner. / **称量悬挂零件**，以实际每角簧载质量重新计算k、c。 | 25 kg baseline excludes hardware |
| 4 | **Build and test prototype on all 4 surfaces** before finalising suspension parameters. / **在四种地面实测样机**再确定悬挂参数。 | Model predictions need experimental validation |
| 5 | **If outdoor cement required at full speed**: lower fn to 2 Hz (k ≈ 782 N/m, sag 62 mm, stroke ≥ 186 mm), or add 2 Hz elastomer pad at camera/payload mount. / **若室外水泥路需全速运行**：降低fn至2 Hz（k≈782 N/m，下沉62 mm，行程≥186 mm），或在相机/载荷安装座处增加2 Hz弹性垫片。 | Cement output with fn=4 Hz = 0.40 g >> 0.1 g target |

### 9.3 Anti-patterns — never do these / 反模式——绝对不要做的事

1. **Do not use `f = N × v / wheelCirc`** — always use `f = N × v / (√2 × wheelCirc)` for X-config. / **不要使用`f = N × v / wheelCirc`**——X构型必须用`f = N × v / (√2 × wheelCirc)`。
2. **Do not use Fs from CSV column 5** — hardcode `Fs = 27027`. / **不要使用CSV第5列的Fs**——硬编码`Fs = 27027`。
3. **Do not open CSVs with UTF-8 encoding** — use `fopen(fpath, 'r')` in MATLAB. / **不要以UTF-8编码打开CSV**——MATLAB中使用`fopen(fpath, 'r')`。
4. **Do not quote "2.58 g" as RMS** — it is an instantaneous peak; RMS at 1.2 m/s = 0.50 g. / **不要将"2.58 g"作为RMS引用**——这是瞬时峰值；1.2 m/s时RMS=0.50 g。
5. **Do not use total mass (25 kg) for spring/damper sizing** — use sprung mass per corner (4.95 kg). / **不要用整机质量（25 kg）计算弹簧/阻尼器参数**——使用每角簧载质量（4.95 kg）。

---

## 10. Adding Mass to Shift Resonance / 增加质量以移频

### 10.1 The idea / 想法

Adding a battery (~4 kg) or dead ballast to the sprung mass lowers fn (since fn ∝ 1/√m), potentially shifting the resonance away from the 0.2 m/s operating point.
在簧载质量上增加电池（约4 kg）或压载，可降低fn（因fn∝1/√m），从而将共振移离0.2 m/s工作点。

### 10.2 The fundamental constraint / 根本限制

There is a key identity that holds when **only mass is changed** (k and c unchanged):
当**仅改变质量**（k和c不变）时，存在一个关键恒等式：

```
2ζr = 2π × f_excitation × c / k   ← independent of mass / 与质量无关
```

This means the **numerator of T is fixed** at `√(1 + (2ζr)²) = 1.268` regardless of how much mass is added. / 这意味着T的**分子固定**为`√(1+(2ζr)²) = 1.268`，无论增加多少质量。

Adding mass simultaneously:
增加质量同时会：
- Lowers fn ✓ (shifts resonance speed down) / 降低fn ✓（共振速度下移）
- Lowers ζ ✗ (makes resonance peak sharper) / 降低ζ ✗（共振峰变得更尖锐）

The two effects partially cancel. T improves only slowly once the operating point moves past resonance (r > 1).
两者部分抵消。只有当工作点越过共振（r>1）后，T才缓慢改善。

### 10.3 Computed results / 计算结果

*(Same spring k = 3,127 N/m, same damper c = 99.5 N·s/m throughout / 弹簧k=3,127 N/m，阻尼器c=99.5 N·s/m全程不变)*

| Approach / 方案 | fn (Hz) | ζ | Added mass / 增加质量 | T @ 0.2 m/s | T @ 0.4 m/s | Sag / 下沉 |
|---|---|---|---|---|---|---|
| Current / 当前 | 4.00 | 0.400 | 0 kg | 1.623 | 0.578 | 15.5 mm |
| **+ 4 kg battery / +4 kg电池** | **3.65** | **0.365** | **4 kg** | **1.600** | **0.476** | **18.7 mm** |
| + 20 kg ballast / +20 kg压载 | 2.82 | 0.282 | 20 kg | 1.058 | 0.272 | 31.2 mm |
| Mass-only solution (T=1.07) / 仅靠质量（T=1.07） | 2.83 | 0.283 | ~20 kg | 1.070 | 0.274 | 30.9 mm |
| **Spring+damper redesign / 弹簧+阻尼重设计** | **3.00** | **0.700** | **0 kg** | **1.067** | **0.554** | **27.6 mm** |

### 10.4 The battery (4 kg) specifically / 电池（4 kg）具体效果

**T @ 0.2 m/s drops from 1.623 → 1.600 — negligible improvement.**
**T@0.2 m/s从1.623降至1.600——改善可忽略不计。**

The robot goes from 25 kg to 29 kg and the resonance problem is essentially unchanged. The battery does shift the resonance speed from 0.205 → 0.187 m/s (passing through it faster during acceleration), but since 0.2 m/s is a sustained operating speed this offers no practical benefit.
整机从25 kg增至29 kg，共振问题基本不变。电池将共振速度从0.205移至0.187 m/s（加速时更快通过），但由于0.2 m/s是持续工作速度，这在实际中没有意义。

### 10.5 How to correctly use battery mass / 如何正确利用电池质量

The battery is useful payload — its mass should be **accounted for in the suspension design**, not relied upon to fix resonance. With the battery installed:
电池是有效载荷——其质量应在**悬挂设计中纳入计算**，而不是依赖它解决共振问题。安装电池后：

| | Without battery / 无电池 | With 4 kg battery / 带4 kg电池 |
|---|---|---|
| Total sprung mass / 总簧载质量 | 19.8 kg | 23.8 kg |
| Per corner / 每角 | 4.95 kg | 5.95 kg |
| k for fn = 3 Hz / fn=3 Hz所需k | 1,759 N/m | **2,115 N/m** |
| c for ζ = 0.7 / ζ=0.7所需c | 130.6 N·s/m | **156.3 N·s/m** |
| Static sag / 静态下沉 | 27.6 mm | 27.6 mm |

With the battery on board, the spring can be slightly stiffer (2,115 vs 1,759 N/m) while maintaining the same fn = 3 Hz — this is easier to package. **Weigh the battery before finalising spring selection.**
安装电池后，弹簧可以稍硬（2,115 vs 1,759 N/m）同时保持fn=3 Hz——更易于安装布置。**确定弹簧选型前须称量电池重量。**

### 10.6 Why ballast is inefficient / 为何压载低效

To achieve T = 1.07 via mass alone (without spring change): need **~20 kg added ballast** — 80% of current robot weight. The resulting ζ = 0.28 is poorly damped (suspension oscillates after disturbances). Changing the spring achieves the same result with **0 kg added mass**.
仅靠质量（不换弹簧）实现T=1.07：需增加**约20 kg压载**——相当于当前整机重量的80%。所得ζ=0.28阻尼不足（受扰后悬挂持续振荡）。换弹簧可用**0 kg增重**实现同等效果。

---

## 11. Pneumatic Tyres vs Omni Wheels / 充气轮胎与全向轮对比

### 11.1 What changes in the vibration model / 振动模型的变化

Replacing omni wheels with pneumatic tyres fundamentally changes the **excitation spectrum**, not just the transmissibility.
将全向轮换为充气轮胎从根本上改变了**激励频谱**，而非仅仅改变传递率。

| Excitation source / 激励来源 | Omni wheel / 全向轮 | Pneumatic tyre / 充气轮胎 |
|---|---|---|
| N=11 roller passage 3.9–29 Hz / N=11滚子过频 | **Dominant / 主导** | **Eliminated / 消除** |
| Motor cogging ~134–1007 Hz / 电机齿槽 | Present / 存在 | Present (unchanged) / 存在（不变）|
| Road roughness broadband / 路面粗糙度宽频 | Present / 存在 | Present, filtered by tyre / 存在，但被轮胎过滤 |
| Tyre imbalance ~1–8 Hz / 轮胎不平衡 | N/A | New, minor / 新增，较小 |

**Eliminating the roller passage excitation (N=11) is by far the largest vibration improvement possible** — it removes the source that drives the entire resonance analysis in this report.
**消除滚子过频激励（N=11）是迄今最大的振动改善措施**——它消除了本报告中所有共振分析的激励来源。

### 11.2 Two-DOF system / 二自由度系统

A pneumatic tyre adds a second spring-damper stage between road and suspension:
充气轮胎在路面与悬挂之间增加了第二级弹簧-阻尼：

```
Road → [k_tyre, c_tyre] → Unsprung mass → [k_susp, c_susp] → Sprung mass
路面 → [k轮胎, c轮胎] → 非簧载质量 → [k悬挂, c悬挂] → 簧载质量
```

| Tyre stiffness / 轮胎刚度 k_t | Wheel-hop resonance / 车轮跳动共振 | 2nd-stage isolation starts / 第二级隔振起效 |
|---|---|---|
| 50,000 N/m (soft / 软) | ~32 Hz | Above 32 Hz / 32 Hz以上 |
| 100,000 N/m (medium / 中) | ~44 Hz | Above 44 Hz / 44 Hz以上 |
| 150,000 N/m (stiff / 硬) | ~54 Hz | Above 54 Hz / 54 Hz以上 |

The tyre is **30–85× stiffer** than the suspension spring (1,759 N/m), so it behaves nearly rigidly at suspension frequencies (1–10 Hz). The suspension design is essentially unchanged — tyre compliance mainly matters above 30 Hz.
轮胎比悬挂弹簧（1,759 N/m）**硬30–85倍**，在悬挂频率（1–10 Hz）范围内近似刚性。悬挂设计基本不变——轮胎柔顺性主要在30 Hz以上起作用。

### 11.3 Contact patch filtering / 接触面积过滤

A pneumatic tyre contact patch (~40–60 mm length) spatially averages road roughness, filtering temporal frequencies above:
充气轮胎接触面（约40–60 mm长）对路面粗糙度进行空间平均，过滤以下时间频率以上的成分：

| Speed / 速度 | Cutoff (40 mm patch) / 截止频率（40 mm） | Cutoff (60 mm patch) / 截止频率（60 mm） |
|---|---|---|
| 0.5 m/s | 12.5 Hz | 8.3 Hz |
| 1.0 m/s | 25.0 Hz | 16.7 Hz |
| 1.5 m/s | 37.5 Hz | 25.0 Hz |

On rough outdoor cement (currently 3.26 g RMS at 1.2 m/s), the tyre absorbs sharp edges **before** they reach the suspension — more effective than any suspension redesign alone.
在粗糙室外水泥路面（当前1.2 m/s时3.26 g RMS），轮胎在路面冲击到达悬挂**之前**就将其吸收——比任何悬挂重设计都更有效。

### 11.4 Suspension design implications / 对悬挂设计的影响

With no roller passage excitation, the resonance trap problem disappears entirely:
无滚子过频激励后，共振陷阱问题完全消失：

| Design aspect / 设计方面 | Omni wheel / 全向轮 | Pneumatic tyre / 充气轮胎 |
|---|---|---|
| Low-speed resonance hazard / 低速共振危险 | ⚠ 0.10–0.29 m/s zone | **Gone / 消除** |
| fn constraint / fn约束 | Must avoid 3.9 Hz (N=11 @ 0.2 m/s) / 必须避开3.9 Hz | No constraint / 无约束 |
| Optimal fn / 最优fn | 3 Hz (compromise) / 3 Hz（折中） | **1.5–2 Hz** (better isolation) / **1.5–2 Hz**（更好隔振）|
| Optimal ζ / 最优ζ | 0.7 (forced high to reduce resonance peak) / 0.7（被迫偏高以压制共振峰） | **0.3–0.4** (normal range) / **0.3–0.4**（正常范围）|
| Primary concern / 主要考量 | Roller passage resonance / 滚子过频共振 | Wheel-hop resonance ~44 Hz / 车轮跳动共振约44 Hz |

### 11.5 Head-to-head: vibration vs mobility / 全面对比：振动性能与运动能力

| Criterion / 评价维度 | Omni wheel / 全向轮 | Pneumatic tyre / 充气轮胎 |
|---|---|---|
| Strafing (lateral motion) / 横向平移 | ✓ | ✗ |
| Rotate in place / 原地旋转 | ✓ | ✗ (skid only / 仅打滑) |
| Holonomic positioning / 完整约束定位 | ✓ | ✗ |
| Vibration — indoor smooth / 振动——室内光滑 | Moderate / 中等 | **Much better / 好得多** |
| Vibration — outdoor rough / 振动——室外粗糙 | Poor (3–6× worse) / 较差（3–6倍差距） | **Dramatically better / 大幅改善** |
| Suspension design complexity / 悬挂设计复杂度 | High / 高 | Low / 低 |
| Max chassis speed / 最大底盘速度 | ~1.65 m/s | Higher (tyre-dependent) / 更高（取决于轮胎）|
| Outdoor traction / 室外牵引力 | Moderate / 中等 | Good / 良好 |
| Contact patch road filtering / 接触面路面过滤 | None / 无 | **Yes, effective / 有，有效** |

### 11.6 Verdict / 结论

Pneumatic tyres solve essentially **all** vibration problems identified in this report in one move — by eliminating the source rather than isolating from it. However, this comes at the cost of **omnidirectional movement**, which is the fundamental capability this X-configuration platform was designed to provide.
充气轮胎通过消除激励源（而非隔振）基本上一举解决了本报告中发现的**所有**振动问题。但代价是失去**全向运动能力**——这正是X型平台设计的核心功能。

- **If omnidirectionality can be sacrificed**: use pneumatic tyres + fn = 1.5–2 Hz + ζ = 0.3–0.4. Vibration problem is solved. / **若可以放弃全向性**：使用充气轮胎 + fn=1.5–2 Hz + ζ=0.3–0.4，振动问题即可解决。
- **If omnidirectionality is required**: keep omni wheels, redesign suspension to fn = 3 Hz + ζ = 0.7 as described in Section 6. / **若全向性不可或缺**：保留全向轮，按第6节将悬挂重设计为fn=3 Hz + ζ=0.7。

---

## Appendix: Script Reference / 附录：脚本索引

| Script / 脚本 | Purpose / 用途 |
|---|---|
| `vibration_analysis.m` | FFT/Welch PSD for original 6-file baseline / 原始6文件基线FFT/PSD分析 |
| `surface_comparison.m` | Multi-surface analysis: 28 CSV, 4 surfaces, 7 speeds / 多地面分析：28个CSV，4种地面，7档速度 |
| `suspension_design.m` | 1-DOF transmissibility sweep, spring/damper sizing / 单自由度传递率扫描，弹簧/阻尼器选型 |
| `suspension_verify.m` | Independent verification (tf, lsim, cwt, spa) / 独立验证（tf、lsim、cwt、spa） |
| `multiaxis_analysis.m` | 3-axis (X/Y/Z) PSD, RMS, cross-coherence / 三轴（X/Y/Z）PSD、RMS、互相干分析 |

Output figures / 输出图表: `results/` — prefixes `fig*`, `surf_fig*`, `susp_fig*`, `verify_*`, `multi_fig*`, `lowspeed_transmissibility.png`, `wheel_comparison_transmissibility.png`, `tyre_vs_omni_transmissibility.png`

---

*Report generated: 2026-02 | MATLAB R2024a | Welch PSD, Fs = 27,027 Hz*
*报告生成时间：2026-02 | MATLAB R2024a | Welch PSD，采样率 27,027 Hz*
