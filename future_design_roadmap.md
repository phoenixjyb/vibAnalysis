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
  │                                  预测：0.007–0.030 g RMS（降低 94–95%）
  │  [LAYER 2] Robot arm structure  (rigid + structural damping)
  │  【第二层】机械臂结构（刚性 + 结构阻尼）
  ▼
Gimbal base / 云台基座  ──── NOT YET MEASURED / 尚未测量
  │
  │  Gimbal motors: correct Roll / Pitch / Yaw  (angular only)
  │  云台电机：修正 Roll / Pitch / Yaw（仅角运动）
  │  Cannot correct: X / Y / Z translation
  │  无法修正：X / Y / Z 平移
  ▼
Camera sensor / 相机传感器  ──── NOT YET MEASURED / 尚未测量
  │
  │  [LAYER 3] EIS / OIS  (residual translational correction)
  │  【第三层】EIS / OIS（残余平移补偿）
  ▼
Image / 图像
```

---

## 2. Why a Gimbal Cannot Fix Z-Axis Vibration / 为何云台无法消除 Z 轴振动

**EN:** A gimbal stabilises **rotation** (Roll, Pitch, Yaw) using motor feedback from an IMU. It has no actuator in the translational directions. Vertical (Z-axis) vibration is a pure translation — the camera sensor moves up and down regardless of what the gimbal motors do.

**中文：** 云台通过 IMU 反馈控制电机，仅能稳定**旋转**运动（翻滚、俯仰、偏航）。其在平移方向无执行机构。Z 轴振动是纯平移运动——无论云台电机如何动作，相机传感器均随之上下移动。

| Motion type / 运动类型 | Gimbal corrects? / 云台可修正？ | Source in this system / 系统来源 |
|-----------------------|-------------------------------|--------------------------------|
| Roll (rotation about optical axis) / 翻滚 | **Yes / 是** | Chassis tilt over bumps / 底盘过坎倾斜 |
| Pitch (tilt up/down) / 俯仰 | **Yes / 是** | Chassis tilt over bumps / 底盘过坎倾斜 |
| Yaw (pan left/right) / 偏航 | **Yes / 是** | Chassis rotation / 底盘转向 |
| Z translation (vertical bounce) / Z 轴平移（垂直弹跳） | **No / 否** | Roller impacts, road bumps / 滚子冲击、路面不平 |
| X/Y translation (lateral drift) / X/Y 轴平移（侧向漂移） | **No / 否** | Minor in this chassis / 本底盘中较小 |

**EN:** Z-vibration causes the following image artefacts that a gimbal cannot prevent:
- **Vertical image shift** per frame — objects appear to jump up and down in the video
- **Rolling-shutter jello effect** — CMOS sensors read out line by line; Z-bounce at 15.6–23.4 Hz (per-plate roller passage N=11) modulates each line differently, producing a wobbling distortion
- **Motion blur** — at slow shutter speeds, sensor displacement during exposure smears the image

**中文：** Z 轴振动导致以下图像缺陷，云台均无法阻止：
- **每帧垂直位移**——视频中物体上下跳动
- **卷帘快门果冻效应**——CMOS 传感器逐行读出，15.6–23.4 Hz 的 Z 向弹跳（N=11 单板滚子通过频率）使各行读出时刻不同，产生波浪形畸变
- **运动模糊**——慢速快门下，曝光期间的传感器位移使图像模糊

---

## 3. Why a Passive Isolator at the Gimbal Mount Does Not Work / 为何云台安装处的被动隔振器不可行

**EN:** An intuitive idea is to insert a rubber or gel isolator between the robot arm and the gimbal base. This fails for a robot arm for a fundamental geometric reason.

**中文：** 一个直觉上的想法是在机械臂与云台底座之间插入橡胶或凝胶隔振器。但对于关节臂机器人，这种方案因根本性的几何原因而不可行。

**The problem / 问题：**

**EN:** A passive isolator works by being **compliant** (low stiffness) in the isolation direction. But the robot arm can point in any direction in space. Under gravity, the weight of the gimbal and camera always pulls **downward**, regardless of arm pose. This means the isolator deflects in the direction of gravity — which is not aligned with the arm axis in general:

**中文：** 被动隔振器通过在隔振方向保持**柔顺性**（低刚度）来工作。但机械臂可指向空间中任意方向。在重力作用下，云台和相机的重量始终向**下**拉，无论臂的姿态如何。这意味着隔振器沿重力方向发生偏转——通常与臂轴不对齐：

```
Arm vertical (pointing up) / 臂竖直向上：
  Isolator compressed axially → gimbal sags straight down → tilt = small
  隔振器轴向压缩 → 云台竖直下沉 → 倾斜量小

Arm horizontal / 臂水平：
  Isolator bent sideways → gimbal tilts toward ground → large pose-dependent tilt
  隔振器侧向弯曲 → 云台向下倾斜 → 大的位姿相关倾斜

Arm at arbitrary angle / 臂任意角度：
  Complex deformation → tilt direction changes with every motion → unpredictable
  复杂变形 → 倾斜方向随每次运动而变化 → 不可预测
```

**Consequences / 后果：**

**EN:**
- The static sag direction changes with every arm movement, requiring the gimbal to constantly compensate with a changing offset — consuming actuator range
- The rotational compliance of the isolator **couples Z-vibration into angular motion** — the very motion the gimbal is correcting — so Z energy leaks into the angular channels and corrupts gimbal stabilisation
- At different arm poses the resonance frequency of the isolator-gimbal system shifts, making consistent vibration isolation impossible

**中文：**
- 静态下沉方向随每次臂运动而改变，要求云台持续补偿一个变化的偏置量——消耗执行器行程
- 隔振器的转动柔顺性将 **Z 轴振动耦合为角运动**——恰好是云台正在修正的运动——导致 Z 轴能量泄漏至角运动通道，破坏云台稳定性
- 在不同臂姿态下，隔振器-云台系统的共振频率发生变化，导致无法实现稳定一致的隔振效果

**Conclusion / 结论：** In a robot arm system, the passive chassis suspension is the correct and only practical layer for Z-axis isolation. All interfaces above it should be rigid.

在关节臂机器人系统中，被动底盘悬挂是 Z 轴隔振的正确且唯一实用的层次。其上方的所有连接界面均应保持刚性。

---

## 4. Vibration Control Strategy by Layer / 分层振动控制策略

### Layer 1 — Chassis Passive Suspension / 第一层——底盘被动悬挂

**Status: Designed ✓ / 状态：已设计 ✓**

**EN:** This is the **primary and most effective Z-isolation layer** in the system. It is mounted on the chassis — a fixed, orientation-independent location — and reduces Z-vibration before it enters any other structure. Because the chassis is always horizontal (or near-horizontal), the spring-damper always acts in the correct direction regardless of arm pose.

**中文：** 这是系统中**最主要、最有效的 Z 向隔振层**。安装在底盘上——固定且与位姿无关的位置——在振动进入其他结构之前进行衰减。由于底盘始终保持水平（或接近水平），弹簧-阻尼器始终沿正确方向工作，不受臂姿态影响。

| Parameter / 参数 | Value / 数值 |
|-----------------|-------------|
| Natural frequency / 固有频率 | 4 Hz |
| Damping ratio / 阻尼比 | 0.4 |
| Predicted Z RMS reduction / 预测 Z 向 RMS 减小 | 94–95% |
| Output RMS at 1.2 m/s / 1.2 m/s 时输出 RMS | 0.030 g |
| Minimum stroke / 最小行程 | 61 mm |

*See `suspension_design_summary.md` for full sizing details. / 详细尺寸参见 `suspension_design_summary.md`。*

---

### Layer 2 — Robot Arm Structure / 第二层——机械臂结构

**Status: To be designed / 状态：待设计**

**EN:** The arm should be **as rigid and well-damped as possible**. No compliant isolator at the gimbal mount. Two passive techniques can be applied to the arm structure itself without introducing orientation-dependent compliance:

**中文：** 机械臂应**尽量刚性且具有良好阻尼**。云台安装处不设置柔顺隔振器。以下两种被动技术可直接应用于臂结构，且不会引入与位姿相关的柔顺性：

**A. Constrained-layer damping (CLD) / 约束层阻尼**

**EN:** Bond a viscoelastic damping layer (e.g. 3M ISD 112, EAR C-1002) to the outer surface of arm links, constrained by a stiff outer skin. The viscoelastic layer dissipates energy through shear deformation when the arm flexes under vibration. This attenuates structural resonances without adding any compliance at the mount point — no orientation problem.

**中文：** 在臂杆外表面粘合黏弹性阻尼层（如 3M ISD 112、EAR C-1002），外侧用刚性约束层压紧。当臂杆在振动作用下弯曲时，黏弹性层通过剪切变形耗散能量，衰减结构共振。该技术不在安装点引入任何柔顺性，无位姿相关问题。

**B. Material selection / 材料选择**

**EN:** Carbon fibre arm links have higher specific stiffness than aluminium. If the arm currently uses aluminium, switching to carbon fibre raises structural resonance frequencies out of the problem frequency band (15.6–46.8 Hz — roller passage N=11/N=22 corrected for X-configuration), reducing response amplitude at those frequencies.

**中文：** 碳纤维臂杆比铝合金具有更高的比刚度。若当前使用铝合金，改用碳纤维可将结构共振频率提高至问题频带（15.6–46.8 Hz，即经 X 形构型修正后的 N=11/N=22 滚子通过频段）之上，从而降低该频段的响应幅值。

---

### Layer 3 — Camera-Side Mitigation / 第三层——相机端缓解

**Status: To be assessed after measurement / 状态：测量后评估**

**EN:** These techniques address residual Z-vibration that reaches the camera after Layers 1 and 2. They are all orientation-independent, as they operate on the image signal or within the camera body rather than through a mechanical interface.

**中文：** 以下技术针对经第一、二层后仍到达相机的残余 Z 向振动。这些方法均与位姿无关，因为它们作用于图像信号或相机内部，而非通过机械界面传递。

| Technique / 技术 | How it works / 原理 | Z-vibration effect / Z 向效果 | Orientation-safe? / 位姿无关？ |
|-----------------|-------------------|------------------------------|-------------------------------|
| EIS (Electronic Image Stabilisation) / 电子防抖 | IMU in camera warps or crops each frame / 相机内置 IMU 对每帧进行变形或裁剪 | Good for residual <30 Hz / 适合 30 Hz 以下残余振动 | Yes / 是 |
| OIS (Optical Image Stabilisation) / 光学防抖 | Shifts lens element or sensor / 移动镜片组或传感器 | Primarily angular, limited Z correction / 主要修正角运动，Z 向修正有限 | Yes / 是 |
| Global shutter camera / 全局快门相机 | Eliminates line-by-line readout / 消除逐行读出 | Eliminates jello effect entirely / 完全消除果冻效应 | Yes / 是 |
| Higher shutter speed / 更高快门速度 | Reduces exposure time, freezes motion / 缩短曝光时间，冻结运动 | Reduces per-frame blur / 减少每帧模糊 | Yes / 是 |
| Active Z linear actuator / 主动 Z 轴线性执行器 | Voice coil or piezo driven by accelerometer feedback / 音圈或压电执行器由加速度计反馈驱动 | Full Z translation correction / 完全修正 Z 向平移 | Yes (complex / 复杂) |

**EN:** **Recommendation:** EIS combined with a global shutter camera is the most practical and cost-effective combination for residual Z effects, once the chassis suspension and arm damping are in place.

**中文：** **建议：** 在底盘悬挂和机械臂阻尼就位后，EIS 结合全局快门相机是应对残余 Z 向影响最实用、最具成本效益的组合。

---

## 5. Second Accelerometer Measurement Plan / 第二加速度计测量方案

**EN:** Before committing to further design work, measure the actual vibration at the gimbal base to understand how much the robot arm transmits. This will quantify whether additional mitigation beyond the chassis suspension is needed, and identify which frequency bands require attention.

**中文：** 在开展进一步设计工作之前，先测量云台基座处的实际振动，了解机械臂的传递特性。这将量化除底盘悬挂之外是否还需要额外减振措施，并识别需要关注的频段。

### Sensor placement / 传感器布置

```
Accelerometer 1 (existing) / 加速度计 1（现有）:
  Mounted on suspended chassis
  安装于悬挂后底盘
  → measures suspension output / 测量悬挂输出

Accelerometer 2 (new) / 加速度计 2（新增）:
  Rigidly bolted to gimbal base plate,
  as close to gimbal motor housing as possible
  刚性固定于云台底板，尽量靠近云台电机壳体
  → measures what the camera actually receives / 测量相机实际接收的振动
```

**EN:** Run both simultaneously (preferred), or repeat identical speed sweeps with each accelerometer in turn. Simultaneous measurement allows direct transfer function estimation via `tfestimate`.

**中文：** 优先同步运行两个传感器；或依次在相同条件下重复速度扫描。同步测量可通过 `tfestimate` 直接估计传递函数。

### Measurements to extract / 需提取的量

| Measurement / 测量量 | MATLAB function | Purpose / 目的 |
|---------------------|----------------|---------------|
| Gimbal-base PSD at each speed / 各速度下云台基座 PSD | `pwelch` | Absolute vibration level at gimbal / 云台处绝对振动水平 |
| Arm transmissibility / 臂传递率 | `tfestimate(chassis, gimbal)` | Which frequencies are amplified or attenuated / 哪些频率被放大或衰减 |
| Coherence / 相干性 | `mscohere` | Confirms causal link between chassis and gimbal signals / 确认底盘与云台信号的因果关系 |
| RMS reduction chassis → gimbal / 底盘至云台 RMS 减小 | — | Overall isolation effectiveness / 总体隔振效果评估 |

### Pass/fail criterion — image blur budget / 通过/失败判据——图像模糊容差

**EN:** The gimbal-base Z-RMS must stay below the **image blur budget**: the maximum acceptable acceleration derived from camera optics and shutter speed. For a camera at subject distance `L` (m), focal length `f_mm` (mm), sensor width `w_mm` (mm), image width `px` pixels, shutter speed `t_exp` (s):

**中文：** 云台基座 Z 向 RMS 必须低于**图像模糊容差**：由相机光学参数和快门速度推导的最大允许加速度。对于拍摄距离 `L`（m）、焦距 `f_mm`（mm）、传感器宽度 `w_mm`（mm）、图像宽度 `px` 像素、快门速度 `t_exp`（s）的相机：

```
Angular resolution per pixel / 每像素角分辨率:
  θ_px = w_mm / (f_mm × px)        [rad/pixel]

Max allowable displacement / 最大允许位移  (0.5 pixel shift limit / 0.5 像素位移限制):
  d_max = 0.5 × θ_px × L           [m]

Max allowable acceleration at frequency f / 频率 f 处最大允许加速度:
  A_max(f) = d_max × (2π f)²       [m/s²]  →  divide by 9.81 for g / 除以 9.81 得 g 值
```

**EN:** This gives a frequency-dependent **acceleration budget curve**. Plotting this alongside the measured gimbal-base PSD immediately shows which frequency bands degrade image quality and by how much.

**中文：** 这给出了一条频率相关的**加速度容差曲线**。将其与测量的云台基座 PSD 叠加绘制，可直观显示哪些频段会影响图像质量以及影响程度。

---

## 6. Proposed Next Analysis Scripts / 建议后续分析脚本

**EN:** Once the second accelerometer data is available, three new MATLAB scripts are recommended to complete the analysis and design chain.

**中文：** 获得第二加速度计数据后，建议开发以下三个 MATLAB 脚本以完成完整的分析与设计链路。

| Script / 脚本 | Purpose / 用途 |
|--------------|---------------|
| `camera_vibration_analysis.m` | Load gimbal-base data; compute PSD, RMS, `tfestimate` arm transmissibility, `mscohere` coherence; identify arm structural resonances / 加载云台基座数据；计算 PSD、RMS、臂传递率、相干性；识别臂结构共振 |
| `image_blur_budget.m` | Input camera specs; output frequency-dependent acceleration budget curve; overlay against measured PSD to produce pass/fail map per frequency band / 输入相机参数；输出频率相关加速度容差曲线；与测量 PSD 叠加，生成各频段通过/失败图 |
| `arm_damping_design.m` | If CLD treatment needed: size damping layer using identified resonance frequencies; predict attenuation from standard CLD analytical models / 如需约束层阻尼处理：根据识别的共振频率确定阻尼层尺寸；用标准 CLD 解析模型预测衰减量 |

---

## 7. Summary of Recommended Actions / 建议行动摘要

| Priority / 优先级 | Action / 行动 | Addresses / 针对问题 | Complexity / 复杂度 |
|------------------|--------------|---------------------|-------------------|
| 1 — Immediate / 立即 | Install chassis passive suspension (fn=4 Hz, ζ=0.4) / 安装底盘被动悬挂 | Z-vibration 0–100 Hz, 94% reduction / Z 向振动 0–100 Hz，降低 94% | Low / 低 |
| 2 — Measure first / 先测量 | Add accelerometer at gimbal base; run speed sweep / 在云台基座添加加速度计并进行速度扫描测试 | Quantify arm transmission / 量化机械臂传递特性 | Low / 低 |
| 3 — If arm transmits >budget / 若臂传递超限 | Apply constrained-layer damping to arm links / 在臂杆上施加约束层阻尼 | Structural resonances 20–100 Hz / 20–100 Hz 结构共振 | Medium / 中 |
| 4 — Camera selection / 相机选型 | Prefer global shutter + EIS / 优先选用全局快门 + EIS 相机 | Eliminates jello; corrects residual Z / 消除果冻效应；修正残余 Z 向 | Medium / 中 |
| 5 — If still insufficient / 若仍不足 | Higher shutter speed or active Z-stage / 提高快门速度或使用主动 Z 轴平台 | Residual Z at camera sensor / 相机传感器处的残余 Z 向振动 | Medium–High / 中高 |

**EN: Do NOT:**
- Insert a passive isolator between arm and gimbal — orientation-dependent sag corrupts gimbal stabilisation and couples Z-vibration into angular motion
- Rely on the gimbal to correct Z-axis translational vibration — it only controls rotation

**中文：不要：**
- 在机械臂与云台之间插入被动隔振器——与位姿相关的静态下沉会破坏云台稳定性，并将 Z 轴振动耦合为角运动
- 依赖云台修正 Z 轴平移振动——云台仅控制旋转运动

---

## 8. Design Dependency Map / 设计依赖关系图

```
【底盘悬挂 — 已完成 / Chassis suspension — DONE】
                    │
                    ▼
     【测量云台基座振动 / Measure gimbal-base vibration】
          camera_vibration_analysis.m
                    │
          ┌─────────┴──────────┐
          ▼                    ▼
  在容差以内？               超出容差？
  Within budget?             Exceeds budget?
          │                    │
          ▼                    ▼
      完成 / Done       【识别问题频段 / Identify problem bands】
   继续监测 / Monitor        image_blur_budget.m
                                    │
               ┌────────────────────┼────────────────────┐
               ▼                    ▼                    ▼
       20–100 Hz            15.6–23.4 Hz            135–670 Hz
     臂结构共振           N=11滚子通过（已确认）        电机齿槽
    Arm resonance        N=11 roller passage        Motor cogging
                         (confirmed, X-config)     (~10.2/motor rev)
               │                    │                    │
      约束层阻尼              EIS + 全局快门          电机安装处
     CLD on arm links       global shutter +        阻尼减振垫
    arm_damping_design.m       EIS camera           damping mounts
```

---

*This document reflects design understanding as of the completion of chassis vibration characterisation and passive suspension design. Update when gimbal-base accelerometer data becomes available.*

*本文档反映底盘振动特性表征和被动悬挂设计完成时的设计认识。获得云台基座加速度计数据后请更新本文档。*
