# Future Design Roadmap: Vibration Control for Camera Image Quality
# 未来设计路线图：面向相机图像质量的振动控制

*Builds on `vibration_analysis_summary.md` and `suspension_design_summary.md`.*
*基于 `vibration_analysis_summary.md` 与 `suspension_design_summary.md`。*

---

## 1. System Architecture / 系统架构

**EN:** The robot carries a camera on a gimbal at the end of an articulated arm. The full vibration transmission chain from ground to image is:

**中文：** 机器人通过关节臂末端的云台携带相机。从地面到图像的完整振动传递链如下：

```
Ground / 地面
  │  road surface irregularities, tile joints, bumps
  │  地面不平整、砖缝、障碍物
  ▼
Chassis / 底盘  ──── measured: 0.07–0.50 g RMS (0.2–1.2 m/s)
  │                 已测量：0.07–0.50 g RMS
  │  [LAYER 1] Passive spring-damper suspension  fn=4 Hz, ζ=0.4
  │  【第一层】被动弹簧-阻尼悬挂  fn=4 Hz，ζ=0.4
  ▼
Suspended chassis / 悬挂后底盘  ──── predicted: 0.007–0.030 g RMS (−94 to −95%)
  │                                  预测：0.007–0.030 g RMS
  │  [LAYER 2] Robot arm structure  (rigid + structural damping)
  │  【第二层】机械臂结构  （刚性 + 结构阻尼）
  ▼
Gimbal base / 云台基座  ──── NOT YET MEASURED / 尚未测量
  │
  │  Gimbal motors: correct Roll / Pitch / Yaw  (angular only)
  │  云台电机：修正 Roll / Pitch / Yaw  （仅角运动）
  │  Cannot correct: X / Y / Z translation
  │  无法修正：X / Y / Z 平移
  ▼
Camera sensor / 相机传感器  ──── NOT YET MEASURED / 尚未测量
  │
  │  [LAYER 3] EIS / OIS  (residual translational correction)
  │  【第三层】EIS / OIS  （残余平移补偿）
  ▼
Image / 图像
```

---

## 2. Why a Gimbal Cannot Fix Z-Axis Vibration / 为何云台无法消除 Z 轴振动

**EN:** A gimbal stabilises **rotation** (Roll, Pitch, Yaw) using motor feedback from an IMU. It has no actuator in the translational directions. Vertical (Z-axis) vibration is a pure translation — the camera sensor moves up and down regardless of what the gimbal motors do.

**中文：** 云台通过 IMU 反馈控制电机，仅能稳定**旋转**运动（翻滚、俯仰、偏航）。其在平移方向无执行机构。Z 轴振动是纯平移运动——无论云台电机如何动作，相机传感器均随之上下移动。

| Motion type / 运动类型 | Gimbal corrects? / 云台可修正？ | Source in this system / 系统来源 |
|-----------------------|-------------------------------|--------------------------------|
| Roll (rotation about optical axis) / 翻滚 | **Yes / 是** | Chassis tilt over bumps |
| Pitch (tilt up/down) / 俯仰 | **Yes / 是** | Chassis tilt over bumps |
| Yaw (pan left/right) / 偏航 | **Yes / 是** | Chassis rotation |
| Z translation (vertical bounce) / Z 轴平移（垂直弹跳） | **No / 否** | Roller impacts, road bumps |
| X/Y translation (lateral drift) / X/Y 轴平移（侧向漂移） | **No / 否** | Minor in this chassis |

**EN:** Z-vibration causes the following image artefacts that a gimbal cannot prevent:
- **Vertical image shift** per frame — objects appear to jump up and down
- **Rolling-shutter jello effect** — CMOS sensors read out line by line; Z-bounce at 16–23 Hz modulates each line differently, producing a wobbling distortion
- **Motion blur** — at slow shutter speeds, the sensor displacement during exposure smears the image

**中文：** Z 轴振动导致以下图像缺陷，云台均无法阻止：
- **每帧垂直位移**——物体上下跳动
- **卷帘快门果冻效应**——CMOS 传感器逐行读出，16–23 Hz 的 Z 向弹跳使各行读出时刻不同，产生波浪形畸变
- **运动模糊**——慢速快门下，曝光期间的传感器位移使图像模糊

---

## 3. Why a Passive Isolator at the Gimbal Mount Does Not Work / 为何云台安装处的被动隔振器不可行

**EN:** An intuitive idea is to insert a rubber or gel isolator between the robot arm and the gimbal base. This fails for a robot arm for a fundamental geometric reason.

**中文：** 一个直觉上的想法是在机械臂与云台底座之间插入橡胶或凝胶隔振器。但对于关节臂机器人，这种方案因根本性的几何原因而不可行。

**The problem / 问题：**

A passive isolator works by being **compliant** (low stiffness) in the isolation direction. But the robot arm can point in any direction in space. Under gravity, the weight of the gimbal and camera always pulls **downward**, regardless of arm pose. This means the isolator deflects in the direction of gravity — which is not aligned with the arm axis in general:

被动隔振器通过在隔振方向保持**柔顺性**（低刚度）来工作。但机械臂可指向空间中任意方向。在重力作用下，云台和相机的重量始终向**下**拉，无论臂的姿态如何。这意味着隔振器沿重力方向发生偏转——通常与臂轴不对齐：

```
Arm vertical (pointing up):
  Isolator compressed axially → gimbal sags straight down → tilt = small

Arm horizontal:
  Isolator bent sideways → gimbal tilts toward ground → large pose-dependent tilt

Arm at arbitrary angle:
  Complex deformation → tilt direction changes with every motion → unpredictable
```

**Consequences / 后果：**
- The static sag direction changes with every arm movement, requiring the gimbal to constantly compensate with a changing offset — consuming actuator range
- The rotational compliance of the isolator **couples Z-vibration into angular motion** — the very motion the gimbal is correcting — so some Z energy leaks into the angular channels and corrupts the gimbal stabilisation
- At different arm poses the resonance frequency of the isolator-gimbal system shifts, making consistent vibration isolation impossible

**结论：** 在关节臂末端插入被动隔振器会引入与位姿相关的静态倾斜耦合，并将 Z 轴振动转化为角运动干扰，整体效果适得其反。

---

## 4. Vibration Control Strategy by Layer / 分层振动控制策略

### Layer 1 — Chassis Passive Suspension / 第一层——底盘被动悬挂

**Status: Designed ✓ / 状态：已设计 ✓**

This is the **primary and most effective Z-isolation layer** in the system. It is mounted on the chassis (fixed, orientation-independent) and reduces Z-vibration before it enters any other structure.

这是系统中**最主要、最有效的 Z 向隔振层**。安装在底盘上（固定、与位姿无关），在振动进入其他结构之前进行衰减。

| Parameter / 参数 | Value / 数值 |
|-----------------|-------------|
| Natural frequency / 固有频率 | 4 Hz |
| Damping ratio / 阻尼比 | 0.4 |
| Predicted Z RMS reduction / 预测 Z 向 RMS 减小 | 94–95% |
| Output RMS at 1.2 m/s / 1.2 m/s 时输出 RMS | 0.030 g |

See `suspension_design_summary.md` for full sizing details.
详细尺寸参见 `suspension_design_summary.md`。

---

### Layer 2 — Robot Arm Structure / 第二层——机械臂结构

**Status: To be designed / 状态：待设计**

The arm should be **as rigid and well-damped as possible**. No compliant isolator at the gimbal mount. Two passive techniques can be applied to the arm itself:

机械臂应**尽量刚性且具有良好阻尼**。云台安装处不应设置柔顺隔振器。以下两种被动技术可直接应用于臂结构：

**A. Constrained-layer damping (CLD) / 约束层阻尼**
Bond a viscoelastic damping layer (e.g. 3M ISD 112, EAR C-1002) to the outer surface of arm links, constrained by a stiff outer skin. The viscoelastic layer dissipates energy through shear deformation when the arm flexes. This attenuates structural resonances without adding compliance at the mount point — no orientation problem.

在臂杆外表面粘合黏弹性阻尼层（如 3M ISD 112、EAR C-1002），外层用刚性约束层压紧。当臂杆弯曲时，黏弹性层通过剪切变形耗散能量，衰减结构共振。不在安装点引入柔顺性，无位姿问题。

**B. Material selection / 材料选择**
Carbon fibre arm links have higher specific stiffness than aluminium. If the arm currently uses aluminium, switching to carbon fibre raises structural resonances out of the problem frequency band (16–66 Hz), reducing response amplitude.

碳纤维臂杆比铝合金具有更高比刚度。若当前使用铝合金，改用碳纤维可将结构共振提高至问题频带（16–66 Hz）之上，降低响应幅值。

---

### Layer 3 — Camera-Side Mitigation / 第三层——相机端缓解

**Status: To be assessed after measurement / 状态：测量后评估**

These techniques address residual Z-vibration that reaches the camera after Layers 1 and 2:

以下技术针对经第一、二层后仍到达相机的残余 Z 向振动：

| Technique / 技术 | How it works / 原理 | Z-vibration effectiveness / Z 向效果 | Orientation-safe? / 位姿安全？ |
|-----------------|-------------------|--------------------------------------|-------------------------------|
| EIS (Electronic Image Stabilisation) / 电子防抖 | IMU in camera warps/crops frame | Good for <30 Hz residual | Yes |
| OIS (Optical Image Stabilisation) / 光学防抖 | Shifts lens element or sensor | Primarily angular, limited Z | Yes |
| Global shutter camera / 全局快门相机 | Eliminates line-by-line readout | Eliminates jello effect | Yes |
| Higher shutter speed / 更高快门速度 | Reduces exposure time, freezes motion | Reduces blur per frame | Yes |
| Active Z linear actuator / 主动 Z 轴线性执行器 | Voice coil / piezo driven by accelerometer | Full Z correction | Yes (complex) |

**Recommendation / 建议:** EIS + global shutter camera is the most practical combination for residual Z effects once the chassis suspension and arm damping are in place.

---

## 5. Second Accelerometer Measurement Plan / 第二加速度计测量方案

**EN:** Before committing to further design work, measure the actual vibration at the gimbal base to understand what the arm transmits. This quantifies whether additional mitigation beyond the chassis suspension is needed.

**中文：** 在开展进一步设计工作之前，先测量云台基座处的实际振动，了解机械臂的传递特性。这将量化除底盘悬挂之外是否还需要额外减振措施。

### Sensor placement / 传感器布置

```
Accelerometer 1 (existing): on suspended chassis
                             安装于悬挂后底盘

Accelerometer 2 (new):      rigidly bolted to gimbal base plate,
                             as close to gimbal motor housing as possible
                             刚性固定于云台底板，尽量靠近云台电机壳体
```

Run both simultaneously (or repeat identical speed sweeps) to allow direct comparison.
两者同步运行（或在相同条件下重复速度扫描），以便直接对比。

### Measurements to extract / 需提取的量

| Measurement / 测量量 | MATLAB function | Purpose / 目的 |
|---------------------|----------------|---------------|
| Gimbal-base PSD at each speed / 各速度下云台基座 PSD | `pwelch` | Absolute vibration level at gimbal |
| Arm transmissibility / 臂传递率 | `tfestimate(chassis, gimbal)` | Which frequencies are amplified / attenuated |
| Coherence / 相干性 | `mscohere` | Confirms causal relationship between chassis and gimbal vibration |
| RMS reduction from chassis to gimbal / 底盘到云台 RMS 减小 | — | Total isolation effectiveness assessment |

### Pass/fail criterion / 通过/失败判据

EN: The gimbal-base Z-RMS must be below the **image blur budget** — the maximum acceptable acceleration derived from camera optics. This depends on your specific camera; a preliminary criterion is derived as follows.

中文：云台基座 Z 向 RMS 必须低于**图像模糊容差**——由相机光学参数推导的最大允许加速度。具体数值取决于相机参数，初步判据推导如下。

For a camera at distance `L` (m) to subject, focal length `f_mm`, sensor width `w_mm`, image width `px` pixels, shutter speed `t_exp` (s):

```
Angular resolution per pixel:  θ_px = w_mm / (f_mm × px)  [rad/pixel]
Max allowable displacement:    d_max = 0.5 × θ_px × L      [m]  (0.5 pixel shift limit)
Vibration amplitude at freq f: A = d_max × (2π f)²         [m/s² = 9.81 × g]
```

This gives a frequency-dependent **acceleration budget curve**. Any measured PSD exceeding this curve will degrade image quality.

---

## 6. Proposed Next Analysis Scripts / 建议后续分析脚本

Once the second accelerometer data is available, three new MATLAB scripts are recommended:

获得第二加速度计数据后，建议开发以下三个 MATLAB 脚本：

| Script / 脚本 | Purpose / 用途 |
|--------------|---------------|
| `camera_vibration_analysis.m` | Load gimbal-base accelerometer data; compute PSD, RMS, and `tfestimate` arm transmissibility; identify arm resonances |
| `image_blur_budget.m` | Input camera specs (focal length, sensor size, resolution, shutter speed, subject distance); output frequency-dependent acceleration budget curve; overlay against measured camera-mount PSD to show pass/fail at each frequency band |
| `arm_damping_design.m` | If CLD treatment is needed: size the damping layer thickness and coverage area using the identified arm resonance frequencies; predict attenuation from standard CLD models |

---

## 7. Summary of Recommended Actions / 建议行动摘要

**EN:**

| Priority / 优先级 | Action / 行动 | Addresses / 针对问题 | Complexity / 复杂度 |
|------------------|--------------|---------------------|-------------------|
| 1 — Immediate / 立即 | Install chassis passive suspension (fn=4 Hz, ζ=0.4) | Z-vibration 0–100 Hz, 94% reduction | Low |
| 2 — Measure first / 先测量 | Add accelerometer at gimbal base; run speed sweep | Quantify what arm transmits | Low |
| 3 — If arm transmits >budget | Apply constrained-layer damping to arm links | Structural resonances 20–100 Hz | Medium |
| 4 — Camera selection | Prefer global shutter + EIS | Eliminates jello; corrects residual Z | Medium |
| 5 — If still insufficient | Higher shutter speed or active Z-stage | Residual Z at camera sensor | Medium–High |

**Do NOT:**
- Insert a passive isolator between arm and gimbal — orientation-dependent sag corrupts gimbal stabilisation
- Rely on the gimbal to correct Z-axis translational vibration — it cannot

**中文：**

**不要：**
- 在机械臂与云台之间插入被动隔振器——位姿相关的静态下沉会破坏云台稳定性
- 依赖云台修正 Z 轴平移振动——云台无此能力

---

## 8. Design Dependency Map / 设计依赖关系图

```
[Chassis suspension - DONE]
         │
         ▼
[Measure gimbal-base vibration] ──── camera_vibration_analysis.m
         │
         ├─── Within budget? ──YES──► Done. Monitor after suspension install.
         │
         └─── Exceeds budget? ─────► [image_blur_budget.m: identify problem bands]
                                              │
                          ┌──────────────────┬┴──────────────────┐
                          ▼                  ▼                   ▼
                   20–100 Hz          16–23 Hz residual    135–670 Hz motor
                   arm resonance      speed-correlated     cogging
                          │                  │                   │
                   CLD on arm links    EIS / global        Damping at
                   arm_damping_design   shutter camera     motor mounts
```

---

*This document reflects design understanding as of the completion of chassis vibration characterisation and passive suspension design. Update when gimbal-base accelerometer data becomes available.*

*本文档反映底盘振动特性表征和被动悬挂设计完成时的设计认识。获得云台基座加速度计数据后请更新本文档。*
