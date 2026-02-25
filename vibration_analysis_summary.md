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

### 4.1 High-Speed Regime (0.8–1.2 m/s) — Roller Impact Vibration
### 高速工况（0.8–1.2 m/s）— 滚子冲击振动

**EN:** At operating speeds of 0.8 m/s and above, the dominant vibration is a broad-band peak whose frequency scales proportionally with travel speed:

| Speed (m/s) | Dominant freq (Hz) | Freq / speed (Hz·s/m) | Events / revolution |
|-------------|-------------------|----------------------|---------------------|
| 0.8 | 16.4 | 20.5 | 8.2 |
| 1.0 | 19.6 | 19.6 | 7.8 |
| 1.2 | 22.9 | 19.1 | 7.6 |

Average: **~8 events per wheel revolution**, which matches the roller passage frequency for a wheel with **N ≈ 8 rollers**. Theoretical roller passage frequency (N = 8): f = 8 × v / (π × 0.127) Hz.

| Speed | Theoretical (N=8) | Measured |
|-------|-------------------|---------|
| 0.8 m/s | 16.0 Hz | 16.4 Hz |
| 1.0 m/s | 20.1 Hz | 19.6 Hz |
| 1.2 m/s | 24.1 Hz | 22.9 Hz |

Agreement is good (< 5 % deviation). **This confirms the dominant vibration source at operating speed is each roller making and breaking contact with the floor.**

**中文：** 在 0.8 m/s 及以上速度时，主导振动为宽带峰，其频率与行驶速度成正比，折算结果约为每转 8 次冲击，与 **N ≈ 8 个滚子**的全向轮滚子通过频率高度吻合（误差 < 5%）。**这证实了在正常运行速度下，主要振动源为滚子周期性接触地面产生的冲击。**

---

![Dominant frequency vs speed](results/fig5_peak_freq_vs_speed.png)
*Figure 5 – Dominant frequency (10–500 Hz band) vs travel speed, overlaid with theoretical roller passage lines for N = 8, 10, 12. / 图5 — 主频（10–500 Hz 频段）随速度变化，叠加 N = 8、10、12 滚子的理论通过频率曲线。*

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
| Roller passage freq at 1.2 m/s (N=8) / 滚子通过频率 | ~24 Hz |
| Roller passage freq at 1.2 m/s (N=10) / 滚子通过频率 | ~30 Hz |
| Roller passage freq at 1.2 m/s (N=12) / 滚子通过频率 | ~36 Hz |

---

## 6. Implications for Suspension Design / 对悬挂系统设计的启示

**EN:**

The suspension must handle two distinct input bands:

1. **Road surface disturbances**: typically 0.5–5 Hz (large amplitude, low frequency — speed bumps, tile joints, floor irregularities).
2. **Roller impact vibration**: **16–24 Hz** at the intended operating speed range of 0.8–1.2 m/s (moderate amplitude, periodic).

A spring-damper suspension with a **natural frequency of 3–5 Hz** is recommended as a starting point:
- Provides a frequency ratio of **3–8× above the roller band**, giving good attenuation (transmissibility well below 1) via the 1/r² roll-off above resonance.
- Soft enough to absorb low-frequency road disturbances without transmitting them to the chassis.
- The damping ratio should be chosen to avoid amplification at the suspension's own natural frequency (ζ ≈ 0.3–0.5 is typical for this class of application).

Motor electrical excitation (134–670 Hz range) is high frequency and low amplitude at low speeds; a 3–5 Hz suspension will attenuate it strongly and it is unlikely to be a design driver.

**中文：**

悬挂系统需应对两类不同频段的输入：

1. **地面不平整扰动**：通常在 0.5–5 Hz（低频、大幅值，如台阶、地砖缝隙等）。
2. **滚子冲击振动**：在 0.8–1.2 m/s 正常运行速度下约为 **16–24 Hz**（中等幅值、周期性）。

建议以**固有频率 3–5 Hz** 的弹簧-阻尼悬挂作为初步设计基准：
- 与滚子振动频段之比约为 **3–8 倍**，利用共振点以上 1/r² 的衰减特性，可有效降低传递率；
- 足够柔软，可吸收低频地面扰动而不传递至底盘；
- 阻尼比建议取 **ζ ≈ 0.3–0.5**，以避免在悬挂固有频率处发生放大。

电机电气激励（134–670 Hz）频率高、幅值相对小，3–5 Hz 悬挂对其衰减效果极强，通常不构成设计约束。

---

## 7. Recommended Next Steps / 建议后续步骤

**EN:**
1. **Confirm roller count** — physically count rollers on one wheel or check the datasheet to verify N = 8 and validate the frequency match.
2. **Quarter-car model** — size spring stiffness and damper coefficient for the target 3–5 Hz natural frequency given the supported mass per wheel.
3. **Transmissibility target** — define acceptable Z-axis acceleration at the payload (e.g. < 0.5 g RMS) and verify via simulation.
4. **Prototype and retest** — rerun the same speed sweep with suspension installed and compare PSDs.

**中文：**
1. **确认滚子数量** — 实物清点或查阅规格书，验证 N = 8 的假设；
2. **四分之一车模型** — 根据每轮承载质量，计算达到目标 3–5 Hz 固有频率所需的弹簧刚度和阻尼系数；
3. **传递率目标** — 明确载荷处允许的最大 Z 向加速度（如 RMS < 0.5 g），并通过仿真验证；
4. **样机复测** — 安装悬挂后重复相同速度扫描，对比前后功率谱密度曲线。

---

*Analysis performed with MATLAB R2024a. Data: 6 CSV files, ~27,027 Hz, Z-axis acceleration, speeds 0.2–1.2 m/s.*
*分析工具：MATLAB R2024a。数据：6 个 CSV 文件，采样率 ~27,027 Hz，Z 轴加速度，速度 0.2–1.2 m/s。*
