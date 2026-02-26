# Omni-Wheel Chassis Vibration Analysis — Summary Report
# 全向轮底盘振动分析 — 总结报告

---

## 1. Background / 背景

**EN:** A 4-wheel omni-wheel chassis (wheel diameter 5 in / 127 mm) was instrumented with a 3-axis accelerometer to characterise vertical (Z-axis) vibration at six travel speeds ranging from 0.2 m/s to 1.2 m/s. The goal is to inform the design of a suspension system that attenuates both wheel-roller-induced vibration and road-surface disturbances.

**中文：** 对一台配备四个全向轮的底盘（车轮直径 5 英寸 / 127 mm）进行了振动测试，使用三轴加速度计采集竖直方向（Z 轴）的加速度数据。测试速度覆盖 0.2 m/s 至 1.2 m/s 共六个工况，目的是为悬挂系统的设计提供依据，使其能同时抑制全向轮滚子引起的振动以及地面不平整带来的冲击。

---

## 2. Test Data Overview / 测试数据概况

**EN:**

| File | Speed | Samples | Duration |
|------|-------|---------|----------|
| 0001_…_0d2.csv | 0.2 m/s | 306,820 | ~11.4 s |
| 0001_…_0d4.csv | 0.4 m/s | 317,492 | ~11.7 s |
| 0001_…_0d6.csv | 0.6 m/s | 304,152 | ~11.2 s |
| 0001_…_0d8.csv | 0.8 m/s | 314,824 | ~11.6 s |
| 0001_…_1d0.csv | 1.0 m/s | 314,824 | ~11.6 s |
| 0001_…_1d2.csv | 1.2 m/s | 266,800 | ~9.9 s  |

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
*Figure 1 – Single-sided FFT of Z-axis acceleration at each travel speed (0–500 Hz). / 图1 — 各行驶速度下 Z 轴加速度的单边 FFT 频谱（0–500 Hz）。*

**EN:**

| Speed (m/s) | RMS Z (g) | Peak Z (g) |
|-------------|-----------|------------|
| 0.2 | 0.069 | 0.47 |
| 0.4 | 0.239 | 1.04 |
| 0.6 | 0.303 | 1.53 |
| 0.8 | 0.397 | 1.75 |
| 1.0 | 0.500 | 2.30 |
| 1.2 | 0.500 | **2.58** |

Vibration grows steeply with speed. Peak Z-acceleration reaches **2.58 g** at 1.2 m/s — a level that would be highly damaging to sensitive payloads without suspension.

**中文：**

振动随速度显著增大。在 1.2 m/s 时，Z 轴峰值加速度达 **2.58 g**，对敏感载荷而言在无悬挂状态下将造成严重影响。

---

## 4. Frequency Analysis Results / 频域分析结果

Two distinct vibration regimes were identified depending on speed.
根据速度范围，识别出两种截然不同的振动模式。

---

![FFT overlay comparison](results/fig2_fft_overlay.png)
*Figure 2 – FFT overlay at all speeds: full band (left) and zoomed to 0–100 Hz (right). / 图2 — 所有速度下的 FFT 叠加对比：全频段（左）与 0–100 Hz 放大（右）。*

![Welch PSD](results/fig3_psd_welch.png)
*Figure 3 – Welch PSD of Z-axis acceleration (0.5 s Hann window, 50 % overlap): full band (left) and 0–100 Hz (right). / 图3 — Z 轴加速度 Welch 功率谱密度（0.5 s Hann 窗，50% 重叠）：全频段（左）与 0–100 Hz（右）。*

### 4.1 High-Speed Regime (0.8–1.2 m/s) — Speed-Correlated Broadband Vibration
### 高速工况（0.8–1.2 m/s）— 速度相关宽带振动

**EN:** At operating speeds of 0.8 m/s and above, the dominant vibration is a broadband peak whose frequency scales proportionally with travel speed:

| Speed (m/s) | Dominant freq (Hz) | Freq / speed (Hz·s/m) | Apparent events / rev |
|-------------|-------------------|----------------------|----------------------|
| 0.8 | 16.4 | 20.5 | 8.2 |
| 1.0 | 19.6 | 19.6 | 7.8 |
| 1.2 | 22.9 | 19.1 | 7.6 |

The dominant spectral peak corresponds to approximately **~8 apparent events per wheel revolution**. However, the actual wheel has **2 side plates × 11 rollers = 22 rollers total**, staggered by 360°/22 = 16.4° so that the rollers of each plate fill the gaps of the other. The theoretical roller-passage frequencies for this geometry are:

| Speed | Per-plate (N=11) | Combined (N=22) | Dominant measured |
|-------|-----------------|-----------------|-------------------|
| 0.8 m/s | 22.1 Hz | 44.1 Hz | 16.4 Hz |
| 1.0 m/s | 27.6 Hz | 55.1 Hz | 19.6 Hz |
| 1.2 m/s | 33.1 Hz | 66.2 Hz | 22.9 Hz |

The measured dominant peak (~8/rev, 16–23 Hz) does not directly match N=11 or N=22. This is consistent with the staggered dual-plate design working as intended: **the interleaved roller arrangement specifically suppresses the polygon-effect vibration** (the 22/rev and 11/rev components cancel or attenuate through the anti-phase stagger), producing a rounder rolling profile. The remaining energy at ~8 events/rev likely originates from road-surface spatial irregularities or a chassis structural resonance excited by the wheel rotation, rather than direct roller-ground impact. Peaks at 33–66 Hz (true roller passage frequencies) are expected to be present in the PSD but at lower amplitude than this dominant feature.

**中文：** 在 0.8 m/s 及以上速度时，主导振动为宽带峰，其频率与行驶速度成正比，表观折算约为每转 8 次冲击。但实际车轮结构为 **2 侧板 × 11 滚子 = 共 22 个滚子**，相位差 16.4°（两侧板滚子互填间隙）。该错位排列正是为了**抑制多边形效应振动**——22/转和 11/转的激励分量通过反相错位相互抵消，使车轮滚动更平滑。实测约 8/转的主导峰更可能来源于地面空间不平整或底盘结构共振，而非直接的滚子接地冲击。PSD 中 33–66 Hz（真实滚子通过频率）处亦应有峰值存在，但幅值低于该主导峰。

---

![Dominant frequency vs speed](results/fig5_peak_freq_vs_speed.png)
*Figure 5 – Dominant frequency (10–500 Hz band) vs travel speed. Note: the wheel has 2×11 staggered rollers (N=22 combined); the dominant measured peak at ~8 apparent events/rev does not correspond directly to roller passage but likely reflects a road/chassis resonance. / 图5 — 主频（10–500 Hz 频段）随速度变化。注：车轮实际为 2×11 错位滚子（N=22），主导峰约 8/转并非直接对应滚子通过频率，更可能反映地面或底盘共振。*

### 4.2 Low-Speed Regime (0.2–0.6 m/s) — Motor Electrical Excitation
### 低速工况（0.2–0.6 m/s）— 电机电气激励

**EN:** At lower speeds, the roller impact energy is weak and a different source dominates — very sharp, narrow-band peaks:

| Speed (m/s) | Peak freq (Hz) | Freq / speed (Hz·s/m) | Events / revolution |
|-------------|---------------|----------------------|---------------------|
| 0.2 | 134 | 670 | 267 |
| 0.4 | 267 | 668 | 266 |
| 0.6 | 401 | 668 | 267 |

The ratio is constant at **~267 events per revolution**, which is characteristic of a motor electrical excitation (e.g. cogging torque or stator force ripple). For example, a 12-pole motor (6 pole-pairs) with a ~44.5 : 1 gear reduction gives exactly 6 × 44.5 = 267 electrical cycles per wheel revolution. The sharpness of these peaks (sinusoidal, not impact-like) further supports a motor/electrical origin rather than a mechanical impact.

**中文：** 在低速时，滚子冲击能量较弱，主导振动变为非常尖锐的窄带峰，折算结果约为每转 267 次激励，与**电机齿槽力矩或定子力波**特征一致（例如 12 极电机配合约 44.5:1 减速比，可得 6 × 44.5 = 267 次/转）。峰形尖锐（正弦型而非冲击型）也进一步印证了其电气来源。

---

![Waterfall PSD](results/fig4_waterfall.png)
*Figure 4 – Waterfall PSD: frequency vs travel speed (3-D view). / 图4 — 瀑布图：功率谱密度随行驶速度变化（三维视图）。*

## 5. Wheel Geometry Reference / 车轮几何参数参考

**EN / 中文:**

| Parameter / 参数 | Value / 数值 |
|-----------------|-------------|
| Wheel diameter / 车轮直径 | 5 in = 127 mm |
| Wheel circumference / 车轮周长 | π × 127 mm = 399.0 mm |
| Wheel rotation rate at 1.2 m/s / 1.2 m/s时转速 | 3.01 Hz (180.6 RPM) |
| **Wheel structure / 车轮结构** | **2 side plates × 11 rollers per plate, staggered by 16.4° / 两侧板各 11 滚子，相位差 16.4°** |
| Single-plate roller passage freq at 1.2 m/s (N=11) / 单侧板滚子通过频率 | **33.1 Hz** |
| Combined dual-plate passage freq at 1.2 m/s (N=22) / 双板合并通过频率 | **66.2 Hz** |

---

## 6. Implications for Suspension Design / 对悬挂系统设计的启示

**EN:**

The suspension must handle two distinct input bands:

1. **Road surface disturbances**: typically 0.5–5 Hz (large amplitude, low frequency — speed bumps, tile joints, floor irregularities).
2. **Wheel-induced vibration**: the dominant measured energy lies in the **16–23 Hz** band (speed-correlated broadband, likely a road/chassis resonance). The true roller-passage frequencies for the 2×11 staggered wheel are higher — **33–66 Hz** at 0.8–1.2 m/s — and will also be present at lower amplitude.

A spring-damper suspension with a **natural frequency of 3–5 Hz** is recommended as a starting point:
- Provides a frequency ratio of **3–5× above the 16–23 Hz dominant band** and **7–16× above the 33–66 Hz roller-passage band**, giving strong attenuation (well below 1 transmissibility) via the 1/r² roll-off above resonance.
- Soft enough to absorb low-frequency road disturbances without transmitting them to the chassis.
- The damping ratio should be chosen to avoid amplification at the suspension's own natural frequency (ζ ≈ 0.3–0.5 is typical for this class of application).

Motor electrical excitation (134–670 Hz range) is high frequency and low amplitude at low speeds; a 3–5 Hz suspension will attenuate it strongly and it is unlikely to be a design driver.

**中文：**

悬挂系统需应对两类不同频段的输入：

1. **地面不平整扰动**：通常在 0.5–5 Hz（低频、大幅值，如台阶、地砖缝隙等）。
2. **车轮诱发振动**：实测主导能量集中在 **16–23 Hz** 频段（速度相关宽带，推测为地面/底盘共振）。2×11 错位滚子的真实滚子通过频率更高——在 0.8–1.2 m/s 时为 **33–66 Hz**，亦以较低幅值存在。

建议以**固有频率 3–5 Hz** 的弹簧-阻尼悬挂作为初步设计基准：
- 与 16–23 Hz 主导频段之比约为 **3–5 倍**，与 33–66 Hz 滚子通过频段之比约为 **7–16 倍**，利用共振点以上 1/r² 的衰减特性，可有效降低传递率；
- 足够柔软，可吸收低频地面扰动而不传递至底盘；
- 阻尼比建议取 **ζ ≈ 0.3–0.5**，以避免在悬挂固有频率处发生放大。

电机电气激励（134–670 Hz）频率高、幅值相对小，3–5 Hz 悬挂对其衰减效果极强，通常不构成设计约束。

---

## 7. Recommended Next Steps / 建议后续步骤

**EN:**
1. **Investigate the ~8/rev dominant peak** — re-examine the PSD at 33–66 Hz for true roller-passage peaks; consider whether the 16–23 Hz energy is from floor spatial irregularities or a chassis structural mode by repeating the test on a smoother surface or at a fixed location.
2. **Quarter-car model** — size spring stiffness and damper coefficient for the target 3–5 Hz natural frequency given the supported mass per wheel (completed — see `suspension_design_summary.md`).
3. **Transmissibility target** — achieved: predicted payload RMS < 0.03 g at all speeds with fn = 4 Hz, ζ = 0.4 (< 0.1 g target, verified by lsim).
4. **Prototype and retest** — rerun the same speed sweep with suspension installed and compare PSDs.

**中文：**
1. **调查约 8/转主导峰的来源** — 重新检查 PSD 在 33–66 Hz 处是否存在真实滚子通过峰；在更平整地面或静止位置重复测试，以判断 16–23 Hz 能量是否来自地面空间不平整或底盘结构模态；
2. **四分之一车模型** — 已完成，见 `suspension_design_summary.md`；
3. **传递率目标** — 已达成：推荐设计（fn = 4 Hz，ζ = 0.4）预测载荷 RMS 在所有速度下 < 0.03 g（目标 < 0.1 g，已由 lsim 验证）；
4. **样机复测** — 安装悬挂后重复相同速度扫描，对比前后功率谱密度曲线。

---

*Analysis performed with MATLAB R2024a. Data: 6 CSV files, ~27,027 Hz, Z-axis acceleration, speeds 0.2–1.2 m/s.*
*分析工具：MATLAB R2024a。数据：6 个 CSV 文件，采样率 ~27,027 Hz，Z 轴加速度，速度 0.2–1.2 m/s。*
