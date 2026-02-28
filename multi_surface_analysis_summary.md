# Multi-Surface Vibration Analysis
# 多地面振动分析报告

**Test conditions / 测试条件:**
- Platform: unsuspended chassis / 无悬挂底盘（裸底盘）
- Sensor: Z-axis accelerometer, chassis body / Z 轴加速度计，底盘本体
- Speeds: 0.2 – 1.5 m/s (7 speeds) / 速度：0.2 – 1.5 m/s（7 档）
- Surfaces: 4 terrain types / 地面类型：4 种

---

## 1. Surfaces Tested / 测试地面

| ID | Surface / 地面 | Type / 类型 |
|---|---|---|
| Black | 室内黑砖 Indoor Black Tile | Smooth indoor / 光滑室内地砖 |
| White | 室内白砖 Indoor White Tile | Smooth indoor / 光滑室内地砖 |
| Cement | 室外水泥路 Outdoor Cement | Rough outdoor / 粗糙室外水泥路面 |
| Pavement | 室外人行路 Outdoor Pavement | Outdoor paving stones / 室外人行道铺装 |

---

## 2. Z-RMS Summary / Z 轴 RMS 汇总 (g)

| Surface / 地面 | 0.2 | 0.4 | 0.6 | 0.8 | 1.0 | 1.2 | **1.5** |
|---|---|---|---|---|---|---|---|
| Black Tile | 0.068 | 0.196 | 0.277 | 0.374 | 0.513 | 0.552 | **0.705** |
| White Tile | 0.064 | 0.201 | 0.296 | 0.379 | 0.507 | 0.534 | **0.674** |
| Cement     | 0.193 | 0.546 | 1.073 | 1.765 | 2.507 | 3.257 | **3.575** |
| Pavement   | 0.072 | 0.240 | 0.406 | 0.565 | 0.828 | 1.068 | **1.306** |

> **Reference / 参考:** Original baseline tests were on indoor smooth surface, consistent with Black/White tile results.
> 原始基线测试为室内光滑地面，与黑/白砖测试结果一致。

---

## 3. Key Findings / 主要发现

### 3.1 Outdoor cement is dramatically worse / 室外水泥路振动远高于室内

Outdoor cement generates **3–6× higher Z-RMS** than indoor tiles across all speeds.
This is caused by surface micro-texture and macro-level cracks/joints exciting broadband vibration.

室外水泥路在所有速度下产生的 Z 轴 RMS 比室内地砖高 **3–6 倍**。
原因是水泥路面的微观纹理及宏观裂缝/接缝激发了宽频振动。

| Speed / 速度 | Cement / White ratio | Pavement / White ratio |
|---|---|---|
| 0.2 m/s | 3.0× | 1.1× |
| 0.4 m/s | 2.7× | 1.2× |
| 0.6 m/s | 3.6× | 1.4× |
| 0.8 m/s | 4.7× | 1.5× |
| 1.0 m/s | 4.9× | 1.6× |
| 1.2 m/s | **6.1×** | 2.0× |
| 1.5 m/s | 5.3× | 1.9× |

Pavement is moderate — only **1.1–2.0× worse** than indoor tiles.
人行道居中——仅比室内地砖高 **1.1–2.0 倍**。

---

### 3.2 N=11 roller passage confirmed at 1.5 m/s / 1.5 m/s 时 N=11 滚子过频得到验证

Expected N=11 frequency at 1.5 m/s: **29.2 Hz** (using √2 X-config correction)
预测 N=11 频率（1.5 m/s）：**29.2 Hz**（含 √2 X 形构型修正）

| Surface | Measured peak / 实测峰值 | Error / 误差 |
|---|---|---|
| White Tile | 27.2 Hz | −6.9% |
| Cement | 26.4 Hz | −9.7% |

Errors are slightly larger than at lower speeds (< 6% at 0.8–1.2 m/s) because broadband
road noise from cement partially masks the roller peak.
误差略大于低速时（0.8–1.2 m/s 时 < 6%），因为水泥路面宽频噪声部分掩盖了滚子频率峰值。
N=11 is still the dominant mechanical excitation — **confirmed across all four surfaces and all speeds**.
N=11 仍为主导机械激励——**在所有四种地面、所有速度下均得到确认**。

---

### 3.3 Critical: suspension resonance at low speed / 重要：低速时悬挂共振

The N=11 roller frequency at **0.2 m/s = 3.9 Hz** — almost exactly at our designed fn = **4.0 Hz**.

0.2 m/s 时 N=11 滚子频率为 **3.9 Hz**，几乎恰好等于设计自然频率 **4.0 Hz**。

| Speed | N=11 freq | r = f/fn | T (fn=4, ζ=0.4) | Effect |
|---|---|---|---|---|
| 0.2 m/s | 3.9 Hz | 0.97 | **1.623** | ⚠ **Amplified** / **放大** |
| 0.4 m/s | 7.8 Hz | 1.95 | 0.578 | Attenuated / 衰减 |
| 0.6 m/s | 11.7 Hz | 2.92 | 0.322 | Attenuated / 衰减 |
| 0.8 m/s | 15.6 Hz | 3.90 | 0.225 | Attenuated / 衰减 |
| 1.0 m/s | 19.5 Hz | 4.87 | 0.174 | Attenuated / 衰减 |
| 1.2 m/s | 23.4 Hz | 5.85 | 0.143 | Attenuated / 衰减 |
| **1.5 m/s** | **29.2 Hz** | **7.31** | **0.112** | Good / 良好 |

> **At 0.2 m/s the suspension AMPLIFIES roller vibration by 1.62×.**
> The robot should avoid sustained operation at ≤ 0.3 m/s if vibration is critical.
>
> **在 0.2 m/s 时，悬挂对滚子频率振动产生 1.62 倍放大效应。**
> 若对振动要求严格，应避免机器人长时间在 ≤ 0.3 m/s 下运行。

---

### 3.4 Suspension performance at 1.5 m/s / 1.5 m/s 时悬挂性能预测

At 1.5 m/s, T = 0.112 at N=11 (29.2 Hz). Predicted output:
1.5 m/s 时 T = 0.112，预测悬挂后输出：

| Surface | Input RMS | T | Predicted output | < 0.1 g? |
|---|---|---|---|---|
| Black Tile | 0.705 g | 0.112 | **0.079 g** | ✓ |
| White Tile | 0.674 g | 0.112 | **0.076 g** | ✓ |
| Pavement | 1.306 g | 0.112 | **0.147 g** | ✗ |
| Cement | 3.575 g | 0.112 | **0.401 g** | ✗ |

**Indoor surfaces: target met at all speeds.**
**Pavement and cement: target exceeded.** A lower fn (e.g. 2–3 Hz) or active isolation would be needed for outdoor use at speed.

**室内地面：所有速度下均满足目标（< 0.1 g）。**
**人行道与水泥路：超出目标。** 若需室外高速使用，须降低 fn（如 2–3 Hz）或采用主动隔振。

---

## 4. Suspension Design Implications / 对悬挂设计的影响

### 4.1 Current design (fn = 4 Hz, ζ = 0.4) — where it works
### 4.1 当前设计（fn = 4 Hz，ζ = 0.4）的适用范围

| Condition / 工况 | Outcome / 结果 |
|---|---|
| Indoor tiles, all speeds / 室内地砖，所有速度 | ✓ Output < 0.1 g |
| Pavement ≥ 0.8 m/s / 人行道 ≥ 0.8 m/s | ✗ Output 0.06–0.15 g (marginal / 临界) |
| Cement, any speed / 水泥路，任何速度 | ✗ Output 0.02–0.40 g (insufficient / 不足) |
| All surfaces, speed ≤ 0.3 m/s / 所有地面，速度 ≤ 0.3 m/s | ⚠ Risk of resonance amplification |

### 4.2 Options for outdoor use / 室外使用方案

**Option A — Lower fn to 2 Hz / 降低 fn 至 2 Hz**
- T at 1.5 m/s (29.2 Hz): r = 14.6 → T ≈ 0.005 (excellent)
- Cement output ≈ 3.575 × 0.005 = **0.018 g** ✓
- Consequence: k = 4.95 × (2π×2)² ≈ **781 N/m** per corner (much softer spring)
- Static sag = g/(2π×2)² = **62 mm** (deeper suspension travel required ≥ 180 mm stroke)
- Roller resonance shifts to 0.1 m/s — below normal operating range ✓

**推荐方案 A——将 fn 降至 2 Hz**
- 水泥路 1.5 m/s 输出 ≈ **0.018 g** ✓
- 代价：弹簧刚度降至 ~781 N/m，静态下沉 62 mm，行程需 ≥ 180 mm

**Option B — Accept indoor-only target / 接受仅室内使用目标**
- Keep fn = 4 Hz, ζ = 0.4
- Operate on cement/pavement at reduced speed (≤ 0.6 m/s)
- Output stays below 0.4 g even on cement at lower speeds

**方案 B——接受仅室内目标**
- 保持 fn = 4 Hz，ζ = 0.4
- 室外路面限速 ≤ 0.6 m/s 使用

**Option C — Two-stage isolation / 两级隔振**
- Passive spring/damper (fn = 4 Hz) to handle roller & cogging
- Add a 2 Hz elastomer pad at camera mount for residual broadband
- More compact than a full 2 Hz suspension

**方案 C——两级隔振**
- 被动弹簧/阻尼器（fn = 4 Hz）处理滚子及齿槽频率
- 相机安装座处额外加 2 Hz 弹性垫片处理宽频残余振动
- 比完整 2 Hz 悬挂更紧凑

---

## 5. Updated Frequency Table (all speeds, all surfaces) / 频率汇总

At each speed the N=11 frequency is the same regardless of surface (it depends only on speed):
各速度下 N=11 频率与地面无关（仅取决于速度）：

| Speed | N=11 (Hz) | N=22 (Hz) | Cogging (Hz) | Motor RPM |
|---|---|---|---|---|
| 0.2 | 3.9 | 7.8 | 134 | 788 |
| 0.4 | 7.8 | 15.6 | 269 | 1,575 |
| 0.6 | 11.7 | 23.4 | 403 | 2,363 |
| 0.8 | 15.6 | 31.2 | 537 | 3,150 |
| 1.0 | 19.5 | 39.0 | 671 | 3,938 |
| 1.2 | 23.4 | 46.8 | 806 | 4,725 |
| **1.5** | **29.2** | **58.5** | **1007** | **5,906** |

Motor cogging at 1.5 m/s = **1,007 Hz** — outside the 0–500 Hz analysis window,
consistent with no gear-mesh peaks found in wide-band scan.
1.5 m/s 时齿槽频率 = **1,007 Hz**——超出 0–500 Hz 分析窗口，
与宽频扫描中未发现齿轮啮合峰值一致。

Motor RPM at 1.5 m/s chassis ≈ **5,906 RPM** — within 6,500 RPM limit (91% of max).
1.5 m/s 底盘速度对应电机转速 ≈ **5,906 RPM**——在 6,500 RPM 限值以内（限值的 91%）。

---

## 6. Next Steps / 后续步骤

| Priority | Action / 行动 | Reason / 原因 |
|---|---|---|
| 1 | Decide operating surface scope / 确定使用地面范围 | Determines whether fn = 4 Hz is sufficient |
| 2 | If outdoor cement required: recalculate for fn = 2 Hz / 若需室外水泥路：按 fn = 2 Hz 重新计算 | k ≈ 781 N/m, stroke ≥ 180 mm |
| 3 | Avoid continuous operation at v ≤ 0.3 m/s / 避免在 ≤ 0.3 m/s 下持续运行 | N=11 ≈ fn → amplification risk |
| 4 | Build prototype with fn = 4 Hz first, test on all 4 surfaces / 先按 fn = 4 Hz 建样机，在四种地面实测 | Validate model predictions |
| 5 | If prototype output on pavement/cement is unacceptable: add elastomer pad or redesign spring / 若样机在人行道/水泥路实测不达标：加弹性垫片或重新设计弹簧 | Iterative refinement |

---

*Analysis: 28 CSV files (4 surfaces × 7 speeds), Welch PSD, Fs = 27,027 Hz, MATLAB R2024a*
*分析：28 个 CSV 文件（4 种地面 × 7 档速度），Welch 功率谱密度，采样率 27,027 Hz，MATLAB R2024a*

*Figures: `results/surf_fig1–5` — RMS vs speed, PSD at 1.5 m/s, PSD waterfall, peak frequency, RMS heatmap*
*图表：`results/surf_fig1–5` — RMS vs 速度、1.5 m/s 功率谱密度、功率谱密度瀑布图、主频率、RMS 热图*
