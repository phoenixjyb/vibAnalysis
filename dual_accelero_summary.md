# Dual-Accelerometer Study — Chassis vs End-Effector
# 双加速度计研究 — 底盘与末端执行器对比

**Test date / 测试日期:** 2026-03-03
**Scripts / 分析脚本:** `dual_accelero_analysis.m` (Z + total), `dual_3d_analysis.m` (full X/Y/Z)
**Figures / 图表:** `results/dual_fig1–5_*.png`, `results/dual3d_fig1–6_*.png`

---

## 1. Test Setup / 测试配置

| Item / 项目 | Detail / 详情 |
|---|---|
| Sensor a (chassis) | Same chassis-body position as all previous tests / 与所有前期测试相同的底盘本体位置 |
| Sensor b (end-effector) | Arm tip; **X-axis mounted backwards** → X_corrected = −X_raw; Y, Z unaffected / 机械臂末端；**X轴反向安装**→X修正=-X原始；Y、Z不受影响 |
| Surfaces / 地面 | 4: Indoor Black, Indoor White, Pavement (outdoor), Cement (outdoor) / 4种：室内黑砖、室内白砖、室外人行道、室外水泥路 |
| Speeds / 速度 | 7: 0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.5 m/s |
| Files / 文件数 | 56 total (28 matched pairs: one 'a' chassis + one 'b' EE per condition) / 56个（28对：每工况一个'a'底盘+一个'b'末端） |
| Data location / 数据位置 | `testData/TestsDualAccelero/` |
| Sample rate / 采样率 | **Fs = 27,027 Hz** (hardcoded; CSV column-5 ≈ 26,820 Hz is inaccurate) |

---

## 2. Overview: The Arm Has Axis-Dependent Dynamics / 总体：机械臂振动传递具有强烈轴向依赖性

The arm does **not** behave as a simple low-pass filter. Its effect is strongly axis-dependent:

机械臂**并非**简单低通滤波器，其效果强烈依赖轴向：

| Axis / 轴 | Arm behaviour / 机械臂行为 | Speed range / 速度范围 |
|---|---|---|
| **Z (vertical / 竖向)** | Attenuates — strong low-pass filter / 衰减——强低通滤波 | ≥ 0.6 m/s all surfaces |
| **X (fore-aft / 前后)** | Amplifies via structural resonances at **~5.8 Hz** and **~11.5 Hz** / 通过~5.8 Hz和~11.5 Hz结构共振放大 | All speeds |
| **Y (lateral / 横向)** | Amplifies via structural resonance at **~9.1 Hz** (indoor) / **~9.9 Hz** (outdoor) / 通过~9.1 Hz共振放大 | All speeds |

---

## 3. Z-Axis Results — Arm as Low-Pass Filter / Z轴结果——机械臂作为低通滤波器

### 3.1 Z-axis RMS: chassis vs EE / Z轴RMS：底盘与末端执行器

| Speed | Indoor White |  | Pavement |  | Cement |  |
|---|---|---|---|---|---|---|
| **(m/s)** | **Chassis Z (g)** | **EE Z (g)** | **Chassis Z (g)** | **EE Z (g)** | **Chassis Z (g)** | **EE Z (g)** |
| 0.2 | 0.062 | 0.052 | 0.074 | 0.132 | 0.189 | 0.235 |
| 0.4 | 0.180 | 0.158 | 0.231 | 0.232 | 0.588 | 0.284 |
| 0.6 | 0.316 | 0.162 | 0.393 | 0.287 | 1.075 | 0.267 |
| 0.8 | 0.383 | 0.153 | 0.558 | 0.335 | 1.681 | 0.289 |
| 1.0 | 0.508 | 0.112 | 0.785 | 0.341 | 2.307 | 0.219 |
| 1.2 | 0.554 | 0.145 | 1.015 | 0.332 | 2.911 | 0.249 |
| 1.5 | 0.668 | 0.143 | 1.228 | 0.387 | 3.114 | 0.257 |

### 3.2 Z-axis EE/Chassis ratio / Z轴EE/底盘比值

| Speed | Indoor White | Indoor Black | Pavement | Cement |
|---|---|---|---|---|
| 0.2 m/s | 0.83 | 0.69 | **1.77** | **1.24** |
| 0.4 m/s | 0.88 | **1.14** | 1.01 | 0.48 |
| 0.6 m/s | 0.51 | 0.57 | 0.73 | 0.25 |
| 0.8 m/s | 0.40 | 0.37 | 0.60 | 0.17 |
| 1.0 m/s | 0.22 | 0.26 | 0.43 | **0.09** |
| 1.2 m/s | 0.26 | 0.30 | 0.33 | **0.09** |
| 1.5 m/s | 0.21 | 0.22 | 0.32 | **0.08** |

**Bold = EE Z > chassis Z (arm amplifies on that axis at that speed/surface).**
**加粗 = EE Z > 底盘Z（该速度/地面下机械臂在该轴放大振动）。**

### 3.3 Z-axis key highlights / Z轴关键数据

- **Cement 1.5 m/s:** chassis Z = 3.11 g → EE Z = 0.26 g (**92% reduction**) / 水泥路1.5 m/s：底盘3.11 g → EE 0.26 g（**衰减92%**）
- **Indoor 1.0 m/s:** chassis Z = 0.51 g → EE Z = 0.11 g (**78% reduction**) / 室内1.0 m/s：底盘0.51 g → EE 0.11 g（**衰减78%**）
- **Z floor at high speed:** EE Z plateaus at ~0.14–0.26 g regardless of chassis level / **高速Z向下限：** EE Z趋于稳定在~0.14–0.26 g，与底盘振动水平无关
  - This floor is set by arm self-dynamics (gravity compliance, joint inertia), not chassis transmission / 该下限由机械臂自身动态特性（重力柔顺、关节惯量）决定，而非底盘传递
- **Pavement/Cement 0.2 m/s:** arm amplifies Z (ratio > 1) — N=11 (3.9 Hz) near arm bending frequency / **人行道/水泥路0.2 m/s：** 机械臂放大Z向（比值>1）——N=11（3.9 Hz）接近臂弯曲频率

---

## 4. Full 3-Axis Results — Per-Axis RMS / 全三轴结果——各轴RMS

### 4.1 Indoor White Tile — all axes / 室内白砖——全轴

| Speed | Ch_X | Ch_Y | Ch_Z | EE_X | EE_Y | EE_Z | Ch_total | EE_total | Ratio |
|---|---|---|---|---|---|---|---|---|---|
| 0.2 m/s | 0.029 | 0.039 | 0.062 | 0.048 | 0.057 | 0.052 | 0.079 | 0.091 | 1.15 |
| 0.4 m/s | 0.070 | 0.071 | 0.180 | 0.077 | 0.103 | 0.158 | 0.205 | 0.204 | 0.99 |
| 0.6 m/s | 0.102 | 0.100 | 0.316 | 0.157 | 0.158 | 0.162 | 0.347 | 0.276 | 0.80 |
| 0.8 m/s | 0.132 | 0.160 | 0.383 | 0.219 | 0.168 | 0.153 | 0.436 | 0.316 | 0.72 |
| 1.0 m/s | 0.187 | 0.252 | 0.508 | 0.224 | 0.256 | 0.112 | 0.597 | 0.358 | 0.60 |
| 1.2 m/s | 0.235 | 0.251 | 0.554 | 0.197 | 0.357 | 0.145 | 0.652 | 0.433 | 0.66 |
| 1.5 m/s | 0.280 | 0.290 | 0.668 | 0.286 | 0.331 | 0.143 | 0.780 | 0.460 | 0.59 |

### 4.2 Pavement — all axes / 人行道——全轴

| Speed | Ch_X | Ch_Y | Ch_Z | EE_X | EE_Y | EE_Z | Ch_total | EE_total | Ratio |
|---|---|---|---|---|---|---|---|---|---|
| 0.2 m/s | 0.051 | 0.069 | 0.074 | 0.166 | 0.163 | 0.132 | 0.113 | 0.267 | **2.36** |
| 0.4 m/s | 0.109 | 0.130 | 0.231 | 0.291 | 0.310 | 0.232 | 0.287 | 0.484 | **1.69** |
| 0.6 m/s | 0.136 | 0.153 | 0.393 | 0.340 | 0.371 | 0.287 | 0.443 | 0.579 | **1.31** |
| 0.8 m/s | 0.184 | 0.212 | 0.558 | 0.436 | 0.431 | 0.335 | 0.624 | 0.698 | 1.12 |
| 1.0 m/s | 0.245 | 0.292 | 0.785 | 0.481 | 0.587 | 0.341 | 0.872 | 0.832 | 0.95 |
| 1.2 m/s | 0.305 | 0.329 | 1.015 | 0.470 | 0.624 | 0.332 | 1.109 | 0.849 | 0.77 |
| 1.5 m/s | 0.366 | 0.388 | 1.228 | 0.515 | 0.593 | 0.387 | 1.338 | 0.876 | 0.65 |

### 4.3 Cement — all axes / 水泥路——全轴

| Speed | Ch_X | Ch_Y | Ch_Z | EE_X | EE_Y | EE_Z | Ch_total | EE_total | Ratio |
|---|---|---|---|---|---|---|---|---|---|
| 0.2 m/s | 0.101 | 0.121 | 0.189 | 0.302 | 0.328 | 0.235 | 0.246 | 0.504 | **2.05** |
| 0.4 m/s | 0.176 | 0.209 | 0.588 | 0.380 | 0.474 | 0.284 | 0.649 | 0.670 | 1.03 |
| 0.6 m/s | 0.256 | 0.289 | 1.075 | 0.422 | 0.568 | 0.267 | 1.142 | 0.756 | 0.66 |
| 0.8 m/s | 0.390 | 0.415 | 1.681 | 0.470 | 0.600 | 0.289 | 1.775 | 0.815 | 0.46 |
| 1.0 m/s | 0.522 | 0.543 | 2.307 | 0.355 | 0.587 | 0.219 | 2.427 | 0.720 | **0.30** |
| 1.2 m/s | 0.669 | 0.655 | 2.911 | 0.359 | 0.637 | 0.249 | 3.058 | 0.772 | **0.25** |
| 1.5 m/s | 0.762 | 0.751 | 3.114 | 0.400 | 0.627 | 0.257 | 3.292 | 0.786 | **0.24** |

### 4.4 Indoor Black Tile — all axes / 室内黑砖——全轴

| Speed | Ch_X | Ch_Y | Ch_Z | EE_X | EE_Y | EE_Z | Ch_total | EE_total | Ratio |
|---|---|---|---|---|---|---|---|---|---|
| 0.2 m/s | 0.028 | 0.038 | 0.062 | 0.050 | 0.055 | 0.043 | 0.078 | 0.086 | 1.10 |
| 0.4 m/s | 0.082 | 0.064 | 0.190 | 0.088 | 0.155 | 0.216 | 0.216 | 0.280 | **1.30** |
| 0.6 m/s | 0.100 | 0.102 | 0.319 | 0.182 | 0.160 | 0.183 | 0.349 | 0.304 | 0.87 |
| 0.8 m/s | 0.130 | 0.173 | 0.391 | 0.243 | 0.188 | 0.145 | 0.447 | 0.339 | 0.76 |
| 1.0 m/s | 0.180 | 0.250 | 0.498 | 0.311 | 0.298 | 0.128 | 0.585 | 0.449 | 0.77 |
| 1.2 m/s | 0.243 | 0.260 | 0.695 | 0.272 | 0.490 | 0.212 | 0.781 | 0.599 | 0.77 |
| 1.5 m/s | 0.286 | 0.296 | 0.685 | 0.338 | 0.375 | 0.150 | 0.800 | 0.527 | 0.66 |

---

## 5. Total EE/Chassis Ratio — All Surfaces / 总RMS EE/底盘比值——全地面

| Speed | Indoor White | Indoor Black | Pavement | Cement |
|---|---|---|---|---|
| 0.2 m/s | 1.15 | 1.10 | **2.36** | **2.05** |
| 0.4 m/s | 0.99 | **1.30** | **1.69** | 1.03 |
| 0.6 m/s | 0.80 | 0.87 | **1.31** | 0.66 |
| 0.8 m/s | 0.72 | 0.76 | 1.12 | 0.46 |
| 1.0 m/s | 0.60 | 0.77 | 0.95 | **0.30** |
| 1.2 m/s | 0.66 | 0.77 | 0.77 | **0.25** |
| 1.5 m/s | 0.59 | 0.66 | 0.65 | **0.24** |

**Bold = ratio > 1 (EE more than chassis). The arm crosses from amplification to attenuation at different speeds per surface — earlier on smooth indoor surfaces (≈ 0.4 m/s), later on rough outdoor surfaces (≈ 0.8–1.0 m/s).**
**加粗=比值>1（EE大于底盘）。从放大转向衰减的速度因地面不同而异——室内光滑地面约0.4 m/s，室外粗糙地面约0.8–1.0 m/s。**

---

## 6. Arm Structural Resonance Frequencies / 机械臂结构共振频率

Identified by per-axis structural transmissibility T(f) = √(PSD_EE / PSD_chassis), peaks located by `findpeaks` in 2–20 Hz range across all surface/speed combinations.

通过各轴结构传递率T(f) = √(PSD末端/PSD底盘)，在所有地面/速度组合的2–20 Hz范围内用`findpeaks`定位峰值。

| Axis / 轴 | Primary resonance / 主共振 | Secondary resonance / 次共振 | Peak T / 峰值T | Confirmed on / 验证地面 |
|---|---|---|---|---|
| **X (fore-aft / 前后)** | **~5.8 Hz** | **~11.5 Hz** | up to **7.4×** | All 4 surfaces / 全部4种地面 |
| **Y (lateral / 横向)** | **~9.1 Hz** | — | up to **7.5×** | Indoor (both) / 室内（两种） |
| **Y (lateral / 横向)** | **~9.9 Hz** | — | up to **5.4×** | Pavement, Cement / 人行道、水泥路 |
| Z (vertical / 竖向) | < 3 Hz (below range) | — | < 1.0 above 6 Hz | All surfaces |

### Physical interpretation / 物理解释

| Mode / 模态 | Frequency / 频率 | Likely mechanism / 可能机制 |
|---|---|---|
| X-axis 1st bending | ~5.8 Hz | Fore-aft bending of arm in travel direction; close to suspension fn (4 Hz) — chassis pitching couples into arm tip / 机械臂沿行进方向前后弯曲；接近悬挂fn（4 Hz）——底盘俯仰与臂末端耦合 |
| X-axis 2nd bending | ~11.5 Hz | Second bending mode or bending-torsion coupling in fore-aft plane / 前后平面内二阶弯曲模态或弯曲-扭转耦合 |
| Y-axis 1st bending | ~9.1–9.9 Hz | Lateral bending of arm; excited by chassis roll and lateral wheel forces / 机械臂侧向弯曲；由底盘横滚和侧向轮力激励 |
| Z isolation onset | > ~6 Hz | Arm mass inertia blocks vertical force transmission above isolation frequency / 隔振频率以上臂质量惯量阻断竖向力传递 |

> **These are structural modes of the arm/linkage assembly — confirmed as speed-independent by appearance at 0.4, 0.8, and 1.0 m/s on all four surfaces.**
> **这些是机械臂/连杆组件的结构模态——在全部四种地面0.4、0.8、1.0 m/s处均稳定出现，与速度无关，已确认。**

---

## 7. Structural Transmissibility Figures / 结构传递率图

### Figure reference / 图表索引

| Figure / 图 | File / 文件 | Content / 内容 |
|---|---|---|
| dual3d_fig1 | `results/dual3d_fig1_peraxis_rms.png` | Per-axis RMS grouped bar: chassis (dark) vs EE (light), 4 surfaces / 各轴RMS分组柱状图：底盘（深色）vs末端执行器（浅色），4种地面 |
| dual3d_fig2 | `results/dual3d_fig2_variance_fraction.png` | Axis variance fraction (%) area plots — chassis top row, EE bottom row / 轴方差占比面积图——顶行底盘，底行末端执行器 |
| dual3d_fig3 | `results/dual3d_fig3_peraxis_transmissibility.png` | Per-axis T_X/Y/Z(f): 4 surfaces × 3 axes grid (0–300 Hz) / 各轴传递率：4种地面×3轴网格（0–300 Hz） |
| dual3d_fig4 | `results/dual3d_fig4_3axis_psd_overlay.png` | 3-axis PSD overlay (solid=chassis, dashed=EE) — Indoor White Tile, 4 speeds / 三轴PSD叠图（实线=底盘，虚线=末端执行器）——室内白砖，4档速度 |
| dual3d_fig5 | `results/dual3d_fig5_coherence.png` | Cross-coherence chassis↔EE per axis — Indoor White Tile / 各轴底盘↔末端执行器互相干——室内白砖 |
| dual3d_fig6 | `results/dual3d_fig6_lowfreq_arm_resonance.png` | Low-frequency PSD (0–30 Hz) at 1.0 m/s — arm resonance region, all surfaces / 0–30 Hz低频PSD（1.0 m/s）——机械臂共振区域，全部地面 |
| dual_fig1–5 | `results/dual_fig1–5_*.png` | Z-axis PSD, transmissibility, RMS summary (from dual_accelero_analysis.m) / Z轴PSD、传递率、RMS汇总 |

---

## 8. Interaction with Suspension and Sandwich Isolator Design / 与悬挂和夹层隔振设计的关系

### 8.1 What changes / 哪些结论改变

Nothing in the suspension/sandwich design parameters changes. The findings add an important layer on top.
悬挂/夹层设计参数不变。本研究发现在原有结论之上增加了重要内涵。

### 8.2 Full vibration chain analysis / 完整振动传递链分析

```
Ground → Wheel → Chassis → [Suspension + Sandwich] → Body / Arm base → [Arm structure] → EE tip
地面  →  车轮 →   底盘   →    [悬挂 + 夹层]       →   车体/机械臂基座  →   [臂结构]    →  末端执行器
```

| Chain link / 传递链节 | Effect on Z / Z向效果 | Effect on X/Y / X/Y向效果 |
|---|---|---|
| Suspension (fn=4 Hz, ζ=0.4) | Attenuates strongly above 5.7 Hz: T ≈ 0.22 at N=11 (19.5 Hz) / 5.7 Hz以上强衰减：N=11（19.5 Hz）处T≈0.22 | Minimal — high lateral stiffness by design / 极小——设计上具有高侧向刚度 |
| Sandwich pad (fn=4.76 Hz) | Additional Z attenuation in 10–100 Hz range / 10–100 Hz范围额外Z向衰减 | Minimal / 极小 |
| Arm structure | Attenuates Z at ≥ 0.6 m/s (78–92%); Z floor set by arm dynamics / ≥0.6 m/s时衰减Z（78–92%）；Z下限由臂动态特性决定 | Amplifies X by ~1.7–3×, Y by ~1.1–2.7× via structural resonances / 通过结构共振放大X~1.7–3倍，Y~1.1–2.7倍 |

### 8.3 Predicted EE vibration — indoor, after full isolation chain / EE预测振动——室内，完整隔振链后

| Speed | Predicted EE Z | Predicted EE X | Predicted EE Y | **EE total** |
|---|---|---|---|---|
| 0.4 m/s | ~0.009 g | ~0.08–0.10 g | ~0.09–0.11 g | **~0.09–0.13 g** |
| 0.8 m/s | ~0.004 g | ~0.15–0.22 g | ~0.13–0.19 g | **~0.15–0.22 g** |
| 1.0 m/s | ~0.002 g | ~0.19–0.26 g | ~0.19–0.26 g | **~0.19–0.26 g** |

**The suspension + sandwich are highly effective for Z — but EE total is dominated by X/Y arm resonances that they cannot address. The practical EE total after full isolation is ~0.1–0.26 g (indoor), limited by arm structural dynamics.**

**悬挂+夹层对Z向极为有效——但EE总振动由X/Y臂共振主导，悬挂/夹层无法解决。室内完整隔振后EE总振动约0.1–0.26 g，受机械臂结构动态特性限制。**

### 8.4 Suspension/sandwich conclusions that HOLD / 悬挂/夹层结论中**维持不变**的部分

| Conclusion / 结论 | Status / 状态 |
|---|---|
| fn = 4 Hz, ζ = 0.4 for indoor use | ✓ Unchanged / 不变 |
| k = 3,127–4,958 N/m, c = 99.5–157.8 N·s/m per corner | ✓ Unchanged / 不变 |
| Sandwich fn_pad = 4.76 Hz | ✓ Unchanged / 不变 |
| Outdoor pavement: fn ≈ 3 Hz; cement: fn ≈ 2 Hz | ✓ Unchanged / 不变 |
| Avoid ≤ 0.3 m/s sustained operation | ✓ Strengthened — arm also resonates near 5.8 Hz at low speed / 进一步强化——低速时机械臂同样在约5.8 Hz共振 |
| Body/electronics Z protection target < 0.1 g | ✓ Achieved by suspension alone (< 0.030 g worst-case indoor) |

### 8.5 New conclusion added by dual-sensor study / 双传感器研究新增结论

> **Arm horizontal (X/Y) stiffness is the dominant bottleneck for end-effector precision — not chassis Z vibration. The suspension and sandwich isolator cannot address this. The next engineering step is arm structural stiffening or active joint damping.**
>
> **机械臂水平（X/Y轴）刚度是末端执行器精度的主要瓶颈——而非底盘Z向振动。悬挂和夹层隔振器无法解决这一问题。下一步工程重点是机械臂结构加强或主动关节阻尼。**

---

## 9. Current EE Vibration State (No Isolation) / 当前EE振动状态（无隔振）

For reference — what the arm tip currently experiences without any suspension or sandwich:
参考值——当前无任何悬挂或夹层时机械臂末端承受的振动：

| Speed | Surface | EE Z (g) | EE total (g) | EE suitable for precision? |
|---|---|---|---|---|
| 0.2 m/s | Indoor | 0.052 | 0.091 | ⚠ Marginal / 临界 |
| 0.2 m/s | Pavement | 0.132 | 0.267 | ✗ No |
| 0.2 m/s | Cement | 0.235 | 0.504 | ✗ No |
| 0.4 m/s | Indoor | 0.158 | 0.204 | ✗ No |
| 0.8 m/s | Indoor | 0.153 | 0.316 | ✗ No |
| 1.0 m/s | Indoor | 0.112 | 0.358 | ✗ No |
| 1.0 m/s | Pavement | 0.341 | 0.832 | ✗ No |
| 1.0 m/s | Cement | 0.219 | 0.720 | ✗ No |
| 1.5 m/s | Cement | 0.257 | 0.786 | ✗ No |

**Current state: the robot must be fully stopped (v = 0) for any arm precision task on any surface.**
**当前状态：在任何地面执行任何机械臂精度任务前，机器人必须完全停止（v = 0）。**

---

## 10. Design Recommendations / 设计建议

| Priority / 优先级 | Action / 行动 | Reason / 原因 |
|---|---|---|
| **1** | **Measure arm natural frequencies directly** (tap test with EE accelerometer) / **直接测量机械臂固有频率**（末端加速度计锤击测试） | Verify 5.8, 9.1, 11.5 Hz; map mode shapes / 验证5.8、9.1、11.5 Hz；绘制振型图 |
| **2** | **Stiffen arm linkages in X (fore-aft) and Y (lateral) directions** / **加强机械臂连杆在X（前后）和Y（横向）方向的刚度** | Target: raise arm fn_X above 15 Hz and fn_Y above 12 Hz (clear of N=11 band) / 目标：将臂X向fn提高至15 Hz以上，Y向fn提高至12 Hz以上 |
| **3** | **Avoid ≤ 0.3 m/s sustained driving on outdoor surfaces** / **避免在室外路面≤0.3 m/s持续行驶** | N=11 (3.9 Hz) ≈ suspension fn AND near arm X-mode (5.8 Hz) — double resonance risk / N=11（3.9 Hz）≈悬挂fn且接近臂X模态（5.8 Hz）——双重共振风险 |
| **4** | **Evaluate adding structural damping to arm** (constrained-layer treatment, elastomer joints) / **评估为机械臂增加结构阻尼**（约束层处理、弹性体关节） | Reduce peak T at 5.8/9.1/11.5 Hz from current 7× to < 2× / 将5.8/9.1/11.5 Hz处峰值T从当前7倍降至2倍以下 |
| **5** | **Define EE vibration spec as 3D total RMS, not Z-only** / **将EE振动规格定义为三维总RMS而非仅Z轴** | Z-only spec is met after suspension+sandwich; total RMS is not / Z向规格在加装悬挂+夹层后可达标；总RMS则不然 |
| **6** | **Verify with prototype after arm stiffening** / **机械臂加强后在样机上验证** | All predictions are based on current arm dynamics; stiffened arm will show different T(f) / 所有预测基于当前臂动态特性；加强后的臂将呈现不同的T(f) |

---

## 11. Low-Speed Operating Restriction — Updated / 低速运行限制——更新

The restriction "avoid ≤ 0.3 m/s sustained operation" from the suspension study is **further strengthened** by the dual-sensor findings:

来自悬挂研究的"避免≤0.3 m/s持续运行"限制因双传感器发现得到**进一步强化**：

- At 0.2 m/s: N=11 = 3.9 Hz ≈ suspension fn (4 Hz) → suspension **amplifies** chassis Z by ×1.62
- At 0.2 m/s: same N=11 (3.9 Hz) is close to arm X-axis primary resonance (~5.8 Hz) → arm **amplifies** X/Y by 2–3×
- Combined effect on pavement at 0.2 m/s: EE total = 0.27 g (×2.36 chassis)
- Combined effect on cement at 0.2 m/s: EE total = 0.50 g (×2.05 chassis)

**After adding suspension + sandwich:** the suspension resonance at 0.2 m/s will actually increase chassis-to-body Z transmission — the body will see ×1.62 chassis Z at 3.9 Hz instead of attenuation. The arm then amplifies this further. **Low-speed operation is the worst case, not the easiest.**

**加装悬挂+夹层后：** 0.2 m/s时悬挂共振会增大底盘到车体的Z向传递——车体在3.9 Hz处将看到×1.62的底盘Z而非衰减。机械臂随后进一步放大。**低速工况是最恶劣工况，而非最简单工况。**

---

*Scripts: `dual_accelero_analysis.m`, `dual_3d_analysis.m` | Data: `testData/TestsDualAccelero/` (56 files)*
*See also: `suspension_design_summary.md`, `multi_surface_analysis_summary.md`, `full_analysis_report.md §14`*
*另见：`suspension_design_summary.md`、`multi_surface_analysis_summary.md`、`full_analysis_report.md §14`*
