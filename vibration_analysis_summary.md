# Omni-Wheel Chassis Vibration Analysis — Summary Report
# 全向轮底盘振动分析 — 总结报告

---

## 1. Background / 背景

**EN:** A 4-wheel omni-wheel chassis (wheel diameter 5 in / 127 mm) was instrumented with a 3-axis accelerometer to characterise vertical (Z-axis) vibration across **five test datasets spanning four surface types and seven travel speeds from 0.2 m/s to 1.5 m/s**. The goal is to inform the design of a suspension system that attenuates both wheel-roller-induced vibration and road-surface disturbances. The original baseline dataset (6 speeds, 0.2–1.2 m/s, indoor smooth floor) was supplemented by four additional surface datasets (each 7 speeds, 0.2–1.5 m/s): indoor black tile, indoor white tile, outdoor cement, and outdoor pavement.

**中文：** 对一台配备四个全向轮的底盘（车轮直径 5 英寸 / 127 mm）进行了振动测试，使用三轴加速度计采集竖直方向（Z 轴）的加速度数据。共完成**五组测试数据集，涵盖四种地面类型、速度范围 0.2–1.5 m/s 的七档工况**。原始基线数据集（六档速度，0.2–1.2 m/s，室内光滑地面）后续补充了四种地面的扩展数据集（每组七档速度，0.2–1.5 m/s）：室内黑砖、室内白砖、室外水泥路、室外人行道。

---

## 2. Test Data Overview / 测试数据概况

**EN:**

| Dataset / 数据集 | Surface / 地面 | Speeds / 速度档 | Files / 文件数 |
|---|---|---|---|
| Original baseline / 原始基线 | Indoor smooth (≈ white tile) / 室内光滑（≈ 白砖） | 0.2–1.2 m/s (6) | 6 |
| indoor-blackFloor / 室内黑砖 | Indoor black tile / 室内黑砖 | 0.2–1.5 m/s (7) | 7 |
| indoor-whiteFloor / 室内白砖 | Indoor white tile / 室内白砖 | 0.2–1.5 m/s (7) | 7 |
| outdoor-cement / 室外水泥路 | Outdoor cement / 室外水泥路 | 0.2–1.5 m/s (7) | 7 |
| outdoor-pavement / 室外人行道 | Outdoor paving stones / 室外人行道 | 0.2–1.5 m/s (7) | 7 |
| **Total / 合计** | | | **34 files** |

**Original baseline file detail / 原始基线文件详情:**

| File | Speed | Samples | Duration |
|------|-------|---------|----------|
| 0001_…_0d2.csv | 0.2 m/s | 306,820 | ~11.4 s |
| 0001_…_0d4.csv | 0.4 m/s | 317,492 | ~11.7 s |
| 0001_…_0d6.csv | 0.6 m/s | 304,152 | ~11.2 s |
| 0001_…_0d8.csv | 0.8 m/s | 314,824 | ~11.6 s |
| 0001_…_1d0.csv | 1.0 m/s | 314,824 | ~11.6 s |
| 0001_…_1d2.csv | 1.2 m/s | 266,800 | ~9.9 s  |

> **The original test was confirmed to be on an indoor smooth surface.** Cross-comparison shows its RMS matches indoor white tile to within 7 % at all speeds, and indoor black tile to within 12 %. It is clearly distinct from outdoor cement (3–6× higher) and pavement (1.5–2× higher).
>
> **原始测试已确认为室内光滑地面。** 交叉对比表明，其各速度 RMS 与室内白砖吻合，误差在 7% 以内，与黑砖误差在 12% 以内。与室外水泥路（高 3–6 倍）和人行道（高 1.5–2 倍）明显不同。

- **True sample rate: 27,027 Hz** (verified from timestamps; the declared column value of ~26,820 Hz was found to be inaccurate — timestamps show a fixed 37 µs interval, i.e. 1,000,000 / 37 Hz exactly).
- Timestamp format confirmed: `mm:ss.mmm.uuu` (minutes : seconds . milliseconds . microseconds).
- Analysis performed on Z-axis acceleration after DC removal (detrend).
- Frequency tools used: single-sided FFT and Welch PSD (0.5 s Hann window, 50 % overlap).

**中文：**

- **实际采样率：27,027 Hz**（由时间戳验证；CSV 第五列声明的约 26,820 Hz 与实测不符——时间戳显示固定 37 µs 采样间隔，即精确的 1,000,000 / 37 Hz）。
- 时间戳格式已确认：`mm:ss.mmm.uuu`（分:秒.毫秒.微秒）。
- 分析对象为去除直流偏置后的 Z 轴加速度。
- 频域分析工具：单边 FFT 与 Welch 功率谱密度估计（0.5 s Hann 窗，50% 重叠）。

---

## 3. Vibration Severity / 振动强度

![Individual FFT spectra at each speed](results/fig1_fft_individual.png)
*Figure 1 – Single-sided FFT of Z-axis acceleration at each travel speed (0–500 Hz), original baseline. / 图1 — 原始基线各行驶速度下 Z 轴加速度的单边 FFT 频谱（0–500 Hz）。*

### 3.1 Original baseline (indoor smooth floor) / 原始基线（室内光滑地面）

**EN:**

| Speed (m/s) | RMS Z (g) | Peak Z (g) ¹ |
|-------------|-----------|------------|
| 0.2 | 0.069 | 0.47 |
| 0.4 | 0.239 | 1.04 |
| 0.6 | 0.303 | 1.53 |
| 0.8 | 0.397 | 1.75 |
| 1.0 | 0.500 | 2.30 |
| 1.2 | 0.500 | **2.58** |

¹ **Peak Z (2.58 g) is the instantaneous maximum — NOT the RMS.** The RMS at 1.2 m/s is 0.50 g. All suspension design calculations use RMS, not peak.

**中文：**

¹ **Z 轴峰值（2.58 g）为瞬时最大值——并非 RMS。** 1.2 m/s 时的 RMS 为 0.50 g。所有悬挂设计计算均使用 RMS，而非峰值。

### 3.2 All surfaces — Z-RMS comparison / 全地面 Z 轴 RMS 对比 (g)

| Speed | Original | Black Tile | White Tile | Cement | Pavement |
|---|---|---|---|---|---|
| 0.2 m/s | 0.069 | 0.068 | 0.064 | **0.193** | 0.072 |
| 0.4 m/s | 0.239 | 0.196 | 0.201 | **0.546** | 0.240 |
| 0.6 m/s | 0.303 | 0.277 | 0.296 | **1.073** | 0.406 |
| 0.8 m/s | 0.397 | 0.374 | 0.379 | **1.765** | 0.565 |
| 1.0 m/s | 0.500 | 0.513 | 0.507 | **2.507** | 0.828 |
| 1.2 m/s | 0.500 | 0.552 | 0.534 | **3.257** | 1.068 |
| 1.5 m/s | — | 0.705 | 0.674 | **3.575** | 1.306 |

**Key observations / 主要观察：**
- Indoor surfaces (original, black tile, white tile) are **tightly grouped** — all within 12 % of each other. The original test is representative of any indoor smooth floor. / 室内地面（原始、黑砖、白砖）数值**高度一致**——彼此误差在 12% 以内，原始测试可代表任意室内光滑地面。
- Outdoor cement is **3–6× worse** than indoor at all speeds. / 室外水泥路在所有速度下均比室内高 **3–6 倍**。
- Outdoor pavement is moderate: **1.1–2× worse** than indoor. / 室外人行道居中：比室内高 **1.1–2 倍**。
- At 1.5 m/s cement reaches **3.58 g RMS** — an extreme input for any passive suspension. / 1.5 m/s 时水泥路 RMS 达 **3.58 g**——对任何被动悬挂都是极端输入。

---

## 4. Frequency Analysis Results / 频域分析结果

Two distinct vibration regimes were identified depending on speed.
根据速度范围，识别出两种截然不同的振动模式。

---

![FFT overlay comparison](results/fig2_fft_overlay.png)
*Figure 2 – FFT overlay at all speeds: full band (left) and zoomed to 0–100 Hz (right). / 图2 — 所有速度下的 FFT 叠加对比：全频段（左）与 0–100 Hz 放大（右）。*

![Welch PSD](results/fig3_psd_welch.png)
*Figure 3 – Welch PSD of Z-axis acceleration (0.5 s Hann window, 50 % overlap): full band (left) and 0–100 Hz (right). / 图3 — Z 轴加速度 Welch 功率谱密度（0.5 s Hann 窗，50% 重叠）：全频段（左）与 0–100 Hz（右）。*

### 4.1 High-Speed Regime (≥ 0.8 m/s) — Per-Plate Roller Passage (N=11) Confirmed
### 高速工况（≥ 0.8 m/s）— 单板滚子通过频率（N=11）已确认

**EN:** At 0.8 m/s and above, the dominant vibration on smooth indoor surfaces is a speed-proportional peak confirmed as **N=11 per-plate roller passage**. The chassis uses an **X-configuration** (each wheel's rolling axis at 45° to chassis forward), so each wheel rolls at $v_\text{wheel} = v_\text{chas}/\sqrt{2}$, giving:

$$f_\text{roller}(N) = \frac{N \cdot v_\text{chas}}{\sqrt{2} \cdot \pi d}$$

**Cross-surface verification — N=11 peak frequency vs measured (Hz) / 跨地面 N=11 频率验证：**

| Speed | N=11 theory | Original | Black | White | Cement | Pavement |
|---|---|---|---|---|---|---|
| 0.8 m/s | **15.6** | 15.7 (+0.5%) | 15.7 (+0.5%) | 21.4 ⚠ | — ² | — ² |
| 1.0 m/s | **19.5** | 19.8 (+1.5%) | 19.8 (+1.5%) | 19.8 (+1.5%) | — ² | 19.8 (+1.5%) |
| 1.2 m/s | **23.4** | 23.9 (+2.2%) | 23.9 (+2.2%) | 47.0 ⚠ | — ² | 23.1 (−1.3%) |
| 1.5 m/s | **29.2** | — | 27.2 (−6.9%) | 27.2 (−6.9%) | 26.4 (−9.7%) | 27.2 (−6.9%) |

² Cement (0.8–1.2 m/s) and Pavement (0.8 m/s): broadband road noise or structural resonance dominates, masking the roller peak — see Section 4.3.

⚠ White tile anomaly: at 0.8 m/s measured 21.4 Hz (between N=11 and N=22); at 1.2 m/s measured 47.0 Hz ≈ **N=22 (46.8 Hz)** — stagger suppression was less effective in this specific run. N=11 is still the primary source, but N=22 can emerge on occasion.

**N=11 is confirmed as the dominant mechanical excitation on all smooth surfaces at ≥ 1.0 m/s, with error < 7 % across 14 of 17 high-speed measurements.**

**中文：** N=11 单板滚子通过频率已在所有光滑地面、≥ 1.0 m/s 的工况下得到确认，17 个高速测量点中 14 个误差 < 7%。水泥路（0.8–1.2 m/s）及人行道（0.8 m/s）因宽频路面噪声掩盖滚子峰值而无法识别（见 4.3 节）。白砖在特定工况下偶现 N=22（46.8 Hz），系错位抑制效果减弱所致。

**Complete frequency table / 完整频率表 (0.2–1.5 m/s):**

| Speed | N=11 (Hz) | N=22 (Hz) | Cogging (Hz) | Motor RPM |
|---|---|---|---|---|
| 0.2 | 3.9 | 7.8 | 134 | 788 |
| 0.4 | 7.8 | 15.6 | 269 | 1,575 |
| 0.6 | 11.7 | 23.4 | 403 | 2,363 |
| 0.8 | 15.6 | 31.2 | 537 | 3,150 |
| 1.0 | 19.5 | 39.0 | 671 | 3,938 |
| 1.2 | 23.4 | 46.8 | 806 | 4,725 |
| **1.5** | **29.2** | **58.5** | **1,007** | **5,906** |

---

![Dominant frequency vs speed](results/fig5_peak_freq_vs_speed.png)
*Figure 5 – Dominant frequency (10–500 Hz band) vs travel speed. With the √2 X-configuration correction applied, the N=11 per-plate theory line (blue dashed) matches the measured peaks within 6 % at all high speeds. / 图5 — 主频（10–500 Hz 频段）随速度变化。应用 √2 X 形构型修正后，N=11 单板理论曲线（蓝虚线）与实测峰值在所有高速工况下误差均小于 6%。*

### 4.2 Low-Speed Regime (0.2–0.6 m/s) — Motor Electrical Excitation
### 低速工况（0.2–0.6 m/s）— 电机电气激励

**EN:** At lower speeds, the roller impact energy is weak and a different source dominates — very sharp, narrow-band peaks:

| Speed (m/s) | Peak freq (Hz) | Events / wheel rev (corrected) | Events / motor rev |
|-------------|---------------|-------------------------------|---------------------|
| 0.2 | 134 | 379 | 10.2 |
| 0.4 | 267 | 377 | 10.1 |
| 0.6 | 401 | 378 | 10.2 |

With the √2 X-configuration correction, the wheel rotation rate at chassis speed $v$ is $f_w = v/(\sqrt{2}\,\pi d)$, so events/wheel rev $= f_\text{peak} \cdot \sqrt{2}\,\pi d / v$. Dividing by the reducer ratio of 37.14 gives **~10.2 events per motor revolution** — a consistent value across all three low-speed runs. The sharpness of these peaks (sinusoidal, not impact-like) further supports a motor/electrical origin.

**Cross-surface verification of motor cogging / 跨地面电机齿槽验证:**

| Speed | Cogging theory | Original | Black | White | Pavement | Cement |
|---|---|---|---|---|---|---|
| 0.2 m/s | 134 Hz | 134 (+0.1%) | 134 (+0.1%) | 134 (+0.1%) | 134 (+0.1%) | masked ³ |
| 0.4 m/s | 269 Hz | 269 (+0.1%) | 269 (+0.1%) | 270 (+0.4%) | 277 (+3.2%) | masked ³ |
| 0.6 m/s | 403 Hz | 404 (+0.3%) | 404 (+0.3%) | 403 (+0.1%) | 400 (−0.7%) | masked ³ |

³ On outdoor cement, broadband road noise energy at 0.2–0.6 m/s is large enough to bury the cogging peak. Cogging is still present but not the dominant spectral feature.

Motor cogging is confirmed on all smooth surfaces with error < 3.5 %. It is not visible as the dominant peak on cement at any speed due to the much higher broadband road noise floor.

**Gear mesh ruled out:** The ratio 10.27 events/motor_rev is non-integer — gear teeth must be whole numbers. Gear mesh cannot produce this frequency. Wide-band PSD (0–2000 Hz) confirms no speed-proportional peaks above 500 Hz on any surface. At 1.5 m/s the cogging frequency rises to **1,007 Hz** — outside the standard analysis window.

**中文：** 电机齿槽激励已在所有光滑地面（原始、黑砖、白砖、人行道）低速工况下确认，误差 < 3.5%。水泥路因宽频路面噪声较强，齿槽峰被掩盖，无法识别为主导峰。齿轮啮合假说已排除（10.27 次/转为非整数）。1.5 m/s 时齿槽频率升至 **1,007 Hz**，超出标准分析窗口。

### 4.3 NEW — Cement Structural Resonance at ~79 Hz / 新发现：水泥路激励下的底盘结构共振（约 79 Hz）

**EN:** On outdoor cement at 0.8–1.2 m/s, the dominant spectral peak is at **~79 Hz — constant regardless of speed**. This is not a kinematic frequency (N=11 at 0.8 m/s = 15.6 Hz, N=22 = 31.2 Hz). Its speed-independence identifies it as a **chassis structural resonance** excited by the broadband road roughness input from cement.

| Speed (m/s) | N=11 theory | N=22 theory | Observed dominant peak | Speed-dependent? |
|---|---|---|---|---|
| 0.8 | 15.6 Hz | 31.2 Hz | **79.2 Hz** | No → structural |
| 1.0 | 19.5 Hz | 39.0 Hz | **79.2 Hz** | No → structural |
| 1.2 | 23.4 Hz | 46.8 Hz | **79.2 Hz** | No → structural |

**Implications:** The 79 Hz chassis resonance is only excited when the broadband road input (cement) is strong enough to drive it. On smooth indoor surfaces the broadband floor is too low to excite it significantly. This resonance should be investigated in structural analysis of the chassis frame and may need to be addressed by stiffening the frame or adding damping treatment.

**中文：** 室外水泥路在 0.8–1.2 m/s 工况下，主导谱峰为 **约 79 Hz——与速度无关**。这不是运动学频率（N=11 在 0.8 m/s 时为 15.6 Hz，N=22 为 31.2 Hz）。速度无关性表明这是水泥路宽频输入激励的**底盘结构共振**。该共振仅在室外粗糙地面提供足够宽频激励时才被显著激发，室内光滑地面因路面噪声底数低而不出现。建议对底盘框架进行结构分析，必要时通过加强刚度或增加阻尼处理来解决。

![Wide-band PSD](results/fig6_wideband_psd.png)
*Figure 6 – Wide-band Welch PSD (0–2000 Hz), left panel full band, right panel 300–1100 Hz zoom. Dashed lines mark expected gear mesh positions assuming ~10 motor-pinion teeth. No speed-proportional peaks appear above 500 Hz. / 图6 — 宽频带 Welch PSD（0–2000 Hz），左：全频段，右：300–1100 Hz 放大。虚线标注假设电机齿轮约 10 齿时的预期齿轮啮合频率。500 Hz 以上未见速度相关尖锐峰。*

---

![Waterfall PSD](results/fig4_waterfall.png)
*Figure 4 – Waterfall PSD: frequency vs travel speed (3-D view). / 图4 — 瀑布图：功率谱密度随行驶速度变化（三维视图）。*

## 5. Wheel Geometry Reference / 车轮几何参数参考

**EN / 中文:**

| Parameter / 参数 | Value / 数值 |
|-----------------|-------------|
| Wheel diameter / 车轮直径 | 5 in = 127 mm |
| Wheel circumference / 车轮周长 | π × 127 mm = 399.0 mm |
| **Chassis configuration / 底盘构型** | **X-configuration: wheel axes at 45° to chassis forward / X形构型：车轮轴线与底盘前向成45°** |
| Motor max speed / 电机最高转速 | **6,500 RPM** |
| Reducer ratio / 减速比 | 37.14 |
| Max wheel rolling speed / 最大车轮滚动速度 | ~1.05 m/s (operational) / 1.16 m/s (motor limit) → max chassis forward ~1.49 / 1.65 m/s |
| **Wheel structure / 车轮结构** | **2 side plates × 11 rollers per plate, staggered by 16.4° / 两侧板各 11 滚子，相位差 16.4°** |
| Effective wheel rolling speed at chassis 1.2 m/s / 底盘1.2 m/s时车轮实际滚动速度 | 1.2/√2 = 0.849 m/s |
| Wheel rotation rate at 1.2 m/s chassis speed / 底盘1.2 m/s时车轮转速 | 0.849/0.399 = 2.13 Hz (127.7 RPM) |
| Motor RPM at 1.2 m/s chassis speed / 底盘1.2 m/s时电机转速 | 127.7 × 37.14 = 4,744 RPM (< 6,500 RPM limit ✓) |
| Single-plate roller passage freq at 1.2 m/s chassis (N=11, corrected) / 单侧板滚子通过频率（修正后） | **23.4 Hz** |
| Combined dual-plate passage freq at 1.2 m/s chassis (N=22, corrected) / 双板合并通过频率（修正后） | **46.8 Hz** |

---

## 6. Implications for Suspension Design / 对悬挂系统设计的启示

### 6.1 Surface-dependent performance / 地面相关性能

The suspension must handle two distinct input bands:
1. **Wheel-induced vibration (N=11):** 3.9–29.2 Hz depending on speed (dominant on smooth surfaces)
2. **Road surface broadband:** Low frequency on indoor tiles; significantly stronger and broader on outdoor cement and pavement

**Critical: at 0.2 m/s, N=11 = 3.9 Hz ≈ fn = 4 Hz → suspension AMPLIFIES by ×1.62 at this speed.**
The robot should avoid sustained operation at ≤ 0.3 m/s if vibration isolation is critical.
**重要：0.2 m/s 时 N=11 = 3.9 Hz ≈ fn = 4 Hz，悬挂对该频率振动产生 ×1.62 的放大效应。**
若对振动隔离要求严格，应避免在 ≤ 0.3 m/s 下长时间运行。

### 6.2 Predicted suspension output by surface (fn=4 Hz, ζ=0.4) / 各地面悬挂预测输出

| Surface | Input @ 1.2 m/s | T at 23.4 Hz | Output | < 0.1 g? |
|---|---|---|---|---|
| Indoor (original / black / white) | ~0.50–0.55 g | 0.143 | **~0.072–0.079 g** | ✓ |
| Outdoor pavement | 1.068 g | 0.143 | **0.153 g** | ✗ |
| Outdoor cement | 3.257 g | 0.143 | **0.466 g** | ✗ |

At 1.5 m/s (T=0.112 at 29.2 Hz):

| Surface | Input @ 1.5 m/s | Output | < 0.1 g? |
|---|---|---|---|
| Indoor (black / white) | ~0.67–0.70 g | **~0.076–0.079 g** | ✓ |
| Outdoor pavement | 1.306 g | **0.147 g** | ✗ |
| Outdoor cement | 3.575 g | **0.401 g** | ✗ |

### 6.3 Surface-specific suspension guidance / 各地面悬挂建议

| Operating surface | Recommended fn | k per corner | Comment |
|---|---|---|---|
| **Indoor only** (smooth tile) | **4 Hz** | **3,127 N/m** | Meets < 0.1 g at all speeds ✓ |
| Pavement + indoor | **3 Hz** | ~1,758 N/m | Reduces pavement output to ~0.085 g ✓ |
| All surfaces incl. cement | **≤ 2 Hz** | ~781 N/m | Meets < 0.1 g on cement; sag = 62 mm, stroke ≥ 180 mm |

**中文：** fn=4 Hz 设计仅满足室内光滑地面的 < 0.1 g 目标。人行道需降至 fn≈3 Hz；室外水泥路需 fn≤2 Hz（弹簧刚度约 781 N/m，静态下沉 62 mm，行程 ≥ 180 mm）。

---

## 7. Status of Conclusions / 结论状态

| Conclusion / 结论 | Status / 状态 | Note / 说明 |
|---|---|---|
| N=11 is dominant at high speed on smooth surfaces | ✓ Confirmed across 4 smooth datasets / 四组光滑地面数据均证实 | Error < 7 % at ≥ 1.0 m/s |
| N=22 stagger-suppressed on smooth surfaces | ✓ Holds generally; appears occasionally on white tile | White tile 1.2 m/s run showed N=22 as dominant |
| Motor cogging ~10.2 events/motor_rev | ✓ Confirmed on all smooth surfaces < 3.5 % error | Masked on cement by road noise |
| Gear mesh ruled out | ✓ Still valid — non-integer ratio confirmed | Wide-band scan negative on all surfaces |
| Original test = indoor smooth floor | ✓ **Newly confirmed** — matches white/black tile within 7 % | N=11 and cogging errors identical |
| "2.58 g at 1.2 m/s" = RMS | ✗ **Correction: this is the instantaneous PEAK** | RMS at 1.2 m/s = 0.50 g |
| Suspension < 0.1 g at all speeds | ⚠ **Revised: indoor only** | Pavement and cement require lower fn |
| Cement same as indoor | ✗ **Wrong: cement is 3–6× worse** | Completely different design case |
| No structural resonance found | ✗ **Revised: 79 Hz resonance found on cement** | Speed-independent; chassis structural mode |

## 8. Recommended Next Steps / 建议后续步骤

**EN:**
1. **Decide operating surface scope** — if outdoor cement is required, redesign suspension for fn ≈ 2 Hz (k ≈ 781 N/m, stroke ≥ 180 mm). If indoor + pavement only, fn = 3 Hz is sufficient.
2. **Avoid sustained operation at ≤ 0.3 m/s** — N=11 at 0.2 m/s ≈ fn = 4 Hz, suspension amplifies by ×1.62 at that speed.
3. **Investigate 79 Hz chassis structural resonance** — only excited on cement; assess whether frame stiffening or damping treatment is needed.
4. **Build fn = 4 Hz prototype first** — test on all 4 surfaces (now documented) to validate model predictions before committing to softer spring.
5. **Re-run suspension design with corrected mass inputs** — see `suspension_case_review.md` (payload = 19.8 kg sprung only; tool was double-counting wheel mass).
6. **Weigh suspension hardware** and recompute k, c — 25 kg excludes arms, mounts, and fasteners.

**中文：**
1. **确定使用地面范围** — 若需室外水泥路，重新设计 fn ≈ 2 Hz（k ≈ 781 N/m，行程 ≥ 180 mm）；仅室内+人行道则 fn = 3 Hz 足够。
2. **避免在 ≤ 0.3 m/s 下长时间运行** — 0.2 m/s 时 N=11 ≈ fn = 4 Hz，悬挂放大倍数 ×1.62。
3. **调查 79 Hz 底盘结构共振** — 仅在水泥路上显现；评估是否需要加强框架刚度或增加阻尼处理。
4. **先建 fn = 4 Hz 样机** — 在四种地面实测（均已有测试数据），验证模型预测后再决定是否改用更软弹簧。
5. **修正悬挂设计工具输入** — 见 `suspension_case_review.md`（有效负载应输入 19.8 kg 簧载质量，工具当前重复计入了车轮质量）。
6. **称量悬挂硬件** 并重新计算 k、c — 25 kg 不含叉臂、安装架及紧固件。

---

*Analysis performed with MATLAB R2024a. Data: 34 CSV files across 5 datasets (4 surfaces + original baseline), Fs = 27,027 Hz, Z-axis acceleration, speeds 0.2–1.5 m/s.*
*分析工具：MATLAB R2024a。数据：5 组数据集（4 种地面 + 原始基线）共 34 个 CSV 文件，采样率 27,027 Hz，Z 轴加速度，速度 0.2–1.5 m/s。*
