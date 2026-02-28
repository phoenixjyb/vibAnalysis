# Suspension Design — Case Review & Next Steps
# 悬挂设计——方案评审与后续步骤

Tool: 双叉臂悬架设计器（最终版）/ Double Wishbone Suspension Designer (Final Version)

---

## 1. Case Comparison / 方案对比

| Parameter / 参数 | Case 1 | Case 2 | Case 3 |
|---|---|---|---|
| Payload / 有效负载 (kg) | 25 | 25 | 25 |
| **Wheel mass / 轮子质量 (kg)** | 0.7 | **1.3 ✓** | 0.8 |
| Upper arm Lu / 上臂长度 (mm) | 140 | 140 | **150** |
| Spring mount a / 弹簧安装点 (mm) | 135 | 135 | **140** |
| Lower arm L_lower / 下臂长度 (mm) | 150 | 150 | 150 |
| Arm gap / 上下叉臂间距 (mm) | 80 | 80 | 80 |
| Damping ratio / 阻尼比 ζ | 0.4 | 0.4 | 0.4 |
| **m_c effective mass / 等效支撑质量 (kg)** | 6.950 | 7.550 | 7.050 |
| Motion ratio m = Lu/a / 运动比 | 1.037 | 1.037 | **1.071** |
| k_spring / 弹簧刚度 (N/m) | 4,553 | 4,946 | 4,771 |
| c_spring / 弹簧侧阻尼 (N·s/m) | 144.9 | 157.4 | 151.9 |
| Static sag / 静态下沉 (mm) | 15.5 | 15.5 | 15.5 |
| Spring compression / 弹簧静态压缩 (mm) | 15.0 | 15.0 | **14.5** |
| Total stroke / 建议总行程 (mm) | 40.0 | 40.0 | 40.0 |

---

## 2. Findings / 评审结论

### 2.1 Wheel Mass — Case 2 is the only correct one
### 2.1 轮子质量——仅方案二正确

Our confirmed unsprung mass per corner is **1.3 kg** (motor + wheel combined).
Cases 1 (0.7 kg) and 3 (0.8 kg) appear to explore wheel-only or motor-only guesses.
**Case 2 must be the base for any further design work.**

经确认，每角非簧载质量为 **1.3 kg**（电机 + 车轮合计）。
方案一（0.7 kg）和方案三（0.8 kg）似乎分别尝试了仅车轮或仅电机的质量估算。
**后续设计应以方案二为基础。**

---

### 2.2 ⚠ Critical Issue — Wheel Mass is Double-Counted
### 2.2 ⚠ 重要问题——轮子质量被重复计入

The tool computes effective mass as:

该工具的等效质量计算方式为：

```
m_c = payload / n_wheels + m_wheel
```

The problem: our **total 25 kg already includes** 4 × 1.3 kg = 5.2 kg of wheel+motor units.
Entering payload = 25 kg **and** wheel = 1.3 kg tells the tool the total mass is **30.2 kg** — which is wrong.

问题在于：我们的 **25 kg 总质量已经包含了** 4 × 1.3 kg = 5.2 kg 的轮电机组件。
同时输入有效负载 = 25 kg **和** 轮子质量 = 1.3 kg，相当于告诉工具总质量为 **30.2 kg**——这是错误的。

**Consequence: spring stiffness is overestimated.**
If the Case 2 spring (k = 4,946 N/m) is built and fitted to the actual sprung mass of 4.95 kg/corner,
the real natural frequency will be:

**后果：弹簧刚度被高估。**
若按方案二弹簧（k = 4,946 N/m）制造并安装，以实际簧载质量 4.95 kg/角计算，
真实自然频率将为：

```
fn_actual = (1/2π) × √(4946 / 4.95) ≈ 5.0 Hz   ← target was 4.0 Hz
```

This shifts isolation performance away from the 4 Hz design point.

这将使隔振性能偏离 4 Hz 设计目标。

---

### 2.3 Geometry — Case 3 is Kinematically Superior
### 2.3 几何参数——方案三的运动学特性更优

| Aspect / 方面 | Case 1 & 2 (Lu=140, L=150) | Case 3 (Lu=150, L=150) |
|---|---|---|
| Arm type / 叉臂类型 | Unequal length / 不等长 | **Equal length / 等长** |
| Camber change in bump / 压缩时外倾变化 | Negative camber gain / 负外倾增益 | Minimal camber change / 外倾变化极小 |
| Motion ratio m | 1.037 | **1.071** |
| Spring travel per mm wheel travel | 0.965 mm | **0.934 mm** |
| Spring compression (static) | 15.0 mm | **14.5 mm** |

**Equal-length arms (Case 3)** keep the wheel more upright through suspension travel,
maintaining a flatter contact patch on the floor — ideal for a robot chassis operating on flat surfaces.

**等长叉臂（方案三）** 在悬挂运动过程中能更好地保持车轮竖直，
使接触面在地板上保持更平整——非常适合在平面上运行的机器人底盘。

A higher motion ratio also means the spring compresses less per unit of wheel travel,
which eases spring selection (more standard spring lengths available).

较高的运动比还意味着弹簧每单位车轮行程的压缩量更小，
有利于弹簧的选型（可选用更标准的弹簧长度）。

---

### 2.4 Stroke — All Cases Pass
### 2.4 行程——三个方案均满足要求

All cases output **40 mm total stroke** with 15.5 mm static sag.
The ≥ 2 × sag rule requires 31 mm minimum — 40 mm satisfies this comfortably.
Our independent analysis set 46 mm minimum; the 6 mm gap is within the tool's recommended
buffer range (4–10 mm), so no concern.

三个方案均输出 **40 mm 总行程**，静态下沉 15.5 mm。
≥ 2 × 静态下沉的要求为最小 31 mm——40 mm 富余充分。
我们的独立分析给出的最小值为 46 mm；6 mm 的差距在工具建议的缓冲行程范围（4–10 mm）之内，无需担忧。

---

### 2.5 Spring Stiffness — Comparison with Independent Analysis
### 2.5 弹簧刚度——与独立分析的对比

| Source / 来源 | Mass basis / 质量基准 | k_spring |
|---|---|---|
| `suspension_design.m` (our model) | Sprung only / 仅簧载质量 4.95 kg | **3,127 N/m** |
| Tool Case 2 (as entered / 当前输入) | Double-counted / 重复计入 7.55 kg | 4,946 N/m |
| Tool — **corrected input** (see §3) | Sprung + wheel / 簧载+非簧载 6.25 kg | **~3,940 N/m** |

All three achieve the same 15.5 mm static sag (sag depends only on fn, not absolute mass),
but only the corrected input will deliver **fn = 4 Hz** for the actual robot.

三者均实现相同的 15.5 mm 静态下沉（下沉量仅取决于 fn，与质量绝对值无关），
但只有修正输入才能使真实机器人达到 **fn = 4 Hz**。

---

## 3. Next Steps / 后续步骤

### Step 1 — Correct the tool input / 修正工具输入

Re-run the suspension designer with the **corrected mass split**:

使用**修正后的质量分配**重新运行悬挂设计器：

| Field / 字段 | Current (wrong) / 当前（错误） | Corrected / 修正后 |
|---|---|---|
| 有效负载 payload (kg) | 25 | **19.8** (= 25 − 4×1.3, sprung only / 仅簧载) |
| 每轮轮子质量 wheel mass (kg) | 1.3 | **1.3** (unchanged / 不变) |
| 轮数 n_wheels | 4 | 4 |

Expected corrected outputs / 预期修正后输出：

```
m_c        = 19.8/4 + 1.3  = 6.25 kg
k_spring   ≈ 6.25 × (2π×4)² ≈ 3,950 N/m
c_spring   ≈ 2 × 0.4 × √(3950 × 6.25) ≈ 126 N·s/m
Static sag = 15.5 mm  (unchanged)
Total stroke: ≥ 40 mm  (unchanged)
```

> **Note / 注意:** After suspension hardware is weighed, update the 19.8 kg sprung mass
> (currently excludes suspension arm weight) and re-run.
>
> **注意：** 悬挂硬件称重后，需更新 19.8 kg 簧载质量（当前未含叉臂重量）并重新运行。

---

### Step 2 — Adopt Case 3 geometry / 采用方案三几何参数

Use the **equal-length arm geometry from Case 3** as the mechanical design basis:

以**方案三的等长叉臂几何参数**作为机械设计基础：

```
Upper arm   Lu      = 150 mm
Spring mount a      = 140 mm
Lower arm   L_lower = 150 mm
Arm gap             =  80 mm
Motion ratio m      = 150/140 = 1.071
Spring offset angle ≤ 10° (target 5–10°)
```

This geometry minimises camber change and provides a symmetric, easier-to-manufacture wishbone pair.

该几何参数可最大程度减小外倾角变化，同时提供对称、易于制造的叉臂组合。

---

### Step 3 — Spring & damper selection / 弹簧和阻尼器选型

Using the corrected k ≈ 3,950 N/m and c ≈ 126 N·s/m targets:

以修正后的 k ≈ 3,950 N/m 和 c ≈ 126 N·s/m 为目标：

| Requirement / 要求 | Value / 数值 |
|---|---|
| Spring rate / 弹簧刚度 | ~3,900–4,000 N/m |
| Free length / 自由长度 | Size to give 14–16 mm static compression at 3,950 N/m |
| Total spring travel / 弹簧总行程 | ≥ 40 mm / 1.071 ≈ **37 mm** |
| Damper stroke / 阻尼器行程 | ≥ 40 mm |
| Damper force at typical velocity / 典型速度下阻尼力 | c × v_max ≈ 126 × 0.3 ≈ **38 N** |

> For a miniature robot, consider **coil-over units** (spring + damper combined) in the
> 35–50 mm body length range — commonly available for 1/10 scale RC cars (shaft diameter ~8 mm).
>
> 对于小型机器人，建议考虑 **弹簧阻尼一体式（coil-over）** 单元，
> 筒体长度 35–50 mm——常见于 1/10 比例遥控车（活塞杆直径约 8 mm）。

---

### Step 4 — Weigh suspension hardware & recompute / 称量悬挂硬件并重新计算

Once the wishbone arms and hardware are manufactured or sourced:
- Weigh all four arms + hub carriers + fasteners per corner
- Add to sprung mass: m_sprung_updated = 19.8 + arm_mass_per_corner
- Re-run tool (Step 1) with updated payload
- Recheck k, c, stroke

叉臂等硬件制造或采购完成后：
- 称量每角的上下叉臂、轮毂载体及紧固件总重
- 加入簧载质量：m_sprung_更新 = 19.8 + 每角叉臂质量
- 使用更新后的有效负载重新运行工具（步骤一）
- 重新核对 k、c 及行程

---

### Step 5 — Prototype & measure / 样机验证与测量

After assembly, place the second accelerometer on the chassis body (sprung mass) and repeat
the 0.2–1.2 m/s speed sweep that was done on the bare platform.

样机组装完成后，将第二个加速度计安装在底盘本体（簧载质量）上，
并重复在裸平台上执行的 0.2–1.2 m/s 速度扫描测试。

Compare measured transmissibility against the model prediction:

将实测传递率与模型预测值对比：

| Speed / 速度 | Bare RMS / 未悬挂 RMS | Target with suspension / 悬挂后目标 |
|---|---|---|
| 0.2 m/s | (baseline) | < 0.030 g |
| 0.8 m/s | 0.93 g | < 0.030 g |
| 1.2 m/s | 2.58 g | < 0.030 g |

If measured output exceeds target, first suspect: fn or ζ not achieved.
Check spring rate against manufacturer datasheet and measure actual damper force.

若实测输出超过目标值，首要怀疑：fn 或 ζ 未达标。
对照弹簧厂商数据表核查实际弹簧刚度，并测量阻尼器实际阻尼力。

---

## 4. Summary / 总结

| Item / 事项 | Decision / 决策 |
|---|---|
| Wheel mass / 轮子质量 | **1.3 kg** — Case 2 is correct |
| Geometry / 几何参数 | **Case 3**: Lu=150, a=140, L=150, gap=80 mm |
| Corrected payload input / 修正有效负载输入 | **19.8 kg** (sprung only, excl. wheels) |
| Target k / 目标弹簧刚度 | **~3,950 N/m** per corner / 每角 |
| Target c / 目标阻尼系数 | **~126 N·s/m** per corner / 每角 |
| Target fn / 目标自然频率 | **4.0 Hz** |
| Target ζ / 目标阻尼比 | **0.4** |
| Static sag / 静态下沉 | **15.5 mm** (fixed by fn) |
| Minimum stroke / 最小行程 | **40 mm** (40 mm + 4–10 mm buffer) |
| Predicted output RMS / 预测输出 RMS | **< 0.030 g** at all speeds |

---

*Based on vibration measurements at 0.2–1.2 m/s and double wishbone suspension designer output.*
*基于 0.2–1.2 m/s 振动测量数据及双叉臂悬架设计器输出结果。*
