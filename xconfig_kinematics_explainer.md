# X-Configuration Omni-Wheel Kinematics: The √2 Factor
# X 形构型全向轮运动学：√2 系数的由来

---

## 1. Setup / 构型说明

A 4-wheel omni-wheel chassis in **X-configuration**: each wheel's rolling axis is oriented at **45° to the chassis forward direction**.

四轮全向轮底盘采用 **X 形构型**：每个车轮的滚动轴与底盘前进方向成 **45° 角**。

```
          North / 前方 (+Y)
              ↑
    FL (NE) ╲   ╱ FR (NW)
              ╳
    RL (SE) ╱   ╲ RR (SW)
```

| Wheel / 车轮 | Rolling direction / 滚动方向 |
|---|---|
| FL (front-left / 左前) | NE (+X+Y)/√2 |
| FR (front-right / 右前) | NW (−X+Y)/√2 |
| RL (rear-left / 左后) | SE (+X−Y)/√2 |
| RR (rear-right / 右后) | SW (−X−Y)/√2 |

---

## 2. The No-Slip Constraint / 无打滑约束

For a rolling wheel, the contact patch cannot slip in the rolling direction.
This gives one scalar constraint per wheel:

对于滚动车轮，接触点在滚动方向上不能打滑。
每个车轮产生一个标量约束：

$$v_{\text{rolling},i} = \hat{r}_i \cdot \mathbf{v}_{\text{chassis}}$$

Where / 其中：
- $\hat{r}_i$ = unit vector of wheel $i$'s rolling direction / 车轮 $i$ 的滚动方向单位向量
- $\mathbf{v}_{\text{chassis}}$ = chassis velocity vector (North = +Y) / 底盘速度向量（向北 = +Y）
- $v_{\text{rolling},i}$ = tread (rim) speed — a **scalar** / 轮缘（踏面）速度——**标量**

For pure North motion $\mathbf{v}_{\text{chassis}} = (0,\, v_c)$:

对于纯前进运动 $\mathbf{v}_{\text{chassis}} = (0,\, v_c)$：

$$v_{\text{rolling}} = (0,\, v_c) \cdot \frac{(1,1)}{\sqrt{2}} = \frac{v_c}{\sqrt{2}}$$

**The wheel tread speed is always slower than the chassis speed by a factor of √2.**
**轮缘速度始终比底盘速度慢 √2 倍。**

---

## 3. What "Rolling Speed" Actually Means / "滚动速度"的真正含义

There are two distinct velocities. Do not confuse them.

存在两种截然不同的速度，切勿混淆。

| Velocity / 速度 | What it is / 含义 | Direction / 方向 |
|---|---|---|
| **v_chassis** | Whole robot body + wheel hub / 整个机器人本体及轮毂 | North / 正北 |
| **v_rolling** | Rim speed past the contact patch (tread speed) / 轮缘掠过接触点的速度（踏面速度） | Along rolling axis (NE) / 沿滚动轴（东北方向） |

The wheel **hub** moves **North** with the chassis.
The **1 m/s** motor limit is the tread speed — it is **not** the velocity of the wheel hub.

车轮**轮毂**随底盘向**北**运动。
电机的 **1 m/s** 上限是踏面速度——**不是**轮毂的速度。

---

## 4. The Common Misconception / 常见误解

> "The wheel rolls at 1 m/s in the NE direction.
>  The North component is 1/√2 ≈ 0.707 m/s.
>  Therefore the chassis goes at 0.707 m/s."

> "车轮以 1 m/s 向东北方向滚动。
>  向北的分量为 1/√2 ≈ 0.707 m/s。
>  因此底盘速度为 0.707 m/s。"

**This is wrong.** / **这是错误的。**

The projection `v_tread × cos(45°)` gives the correct formula — but **in the wrong direction**.

投影计算 `v_tread × cos(45°)` 的公式是对的，但**方向用反了**。

| Formula / 公式 | Correct use / 适用情形 |
|---|---|
| `v_chassis × cos(45°) = v_tread` | Chassis moves North → find tread speed ✓ |
| `v_tread × cos(45°) = v_chassis` | **Would only be valid if the chassis body were moving NE** ✗ |

The chassis moves **North**, not NE. The tread speed is the *consequence* of chassis motion, not the *cause*.

底盘向**正北**运动，而非东北。踏面速度是底盘运动的*结果*，而非*原因*。

---

## 5. Correct Relationship / 正确关系

$$\boxed{v_{\text{rolling}} = \frac{v_{\text{chassis}}}{\sqrt{2}}}
\qquad \Longleftrightarrow \qquad
\boxed{v_{\text{chassis}} = v_{\text{rolling}} \times \sqrt{2}}$$

| Given / 已知 | Find / 求 | Result / 结果 |
|---|---|---|
| v_chassis = 1.0 m/s (North) | v_rolling per wheel / 各轮踏面速度 | 0.707 m/s |
| v_rolling = 1.0 m/s (max) | v_chassis max / 底盘最大速度 | **1.414 m/s** |

---

## 6. Physical Intuition / 物理直觉

When the chassis travels **1 m North**, trace what the contact patch does:

当底盘向北行驶 **1 m** 时，追踪接触点的运动：

```
Chassis displacement:  1.000 m  (North / 正北)
    ↓  project onto NE rolling axis (cos 45°)
    ↓  投影到东北滚动轴（cos 45°）
Rolling distance:      0.707 m  ← tread only unwinds this much
                                   踏面仅展开这么多
Perpendicular (NW):    0.707 m  ← absorbed by passive rollers (free slip)
                                   由被动滚子吸收（自由滑动）
```

> **The wheel only needs to spin far enough to cover the diagonal "shadow" of the chassis's northward path.**
> The perpendicular component slips freely through the passive rollers — that is the entire purpose of an omni-wheel.

> **车轮只需旋转足够的量，以覆盖底盘前进路径的对角线"投影"即可。**
> 垂直分量通过被动滚子自由滑动——这正是全向轮的核心原理。

---

## 7. Verification — Inverse & Forward Kinematics / 验证——逆运动学与正运动学

**Inverse kinematics** (chassis → wheels) / **逆运动学**（底盘 → 车轮）

```
v_chassis = 1.000 m/s North
FL (NE): +0.7071 m/s
FR (NW): +0.7071 m/s
RL (SE): −0.7071 m/s   (rolling NW at 0.707 m/s)
RR (SW): −0.7071 m/s   (rolling NE at 0.707 m/s)
|v_rolling| = 0.7071 m/s = v_chassis / √2  ✓
```

**Forward kinematics** (wheels → chassis) via pseudo-inverse W⁺ = ½ Wᵀ:
**正运动学**（车轮 → 底盘），使用伪逆 W⁺ = ½ Wᵀ：

```
W^T W = 2I  →  W⁺ = ½ Wᵀ
4 wheels × (±0.7071 m/s) → v_chassis = [0; 1.000] m/s  ✓
```

All four wheels cooperate: each contributes 1/√2 northward, combined through the pseudo-inverse scaling of ½:
四个车轮协同工作：每个车轮贡献 1/√2 的北向分量，通过伪逆的 ½ 缩放合并：

$$v_{\text{chassis,N}} = \frac{1}{2} \times 4 \times \frac{1}{\sqrt{2}} \times v_{\text{rolling}} = v_{\text{rolling}} \times \sqrt{2}$$

---

## 8. Project Numbers / 项目数值

| Parameter / 参数 | Value / 数值 |
|---|---|
| Motor max RPM / 电机最大转速 | 6,500 RPM |
| Gear reducer ratio / 减速比 | 37.14 |
| Wheel diameter / 车轮直径 | 127 mm (5 in) |
| Max wheel rolling speed / 最大轮缘速度 | 6500 ÷ 37.14 × π × 0.127 ÷ 60 = **1.164 m/s** |
| Max chassis speed / 最大底盘速度 | 1.164 × √2 = **1.646 m/s** |
| At 1.2 m/s chassis / 底盘 1.2 m/s 时轮缘速度 | 1.2 ÷ √2 = **0.849 m/s** (72% of limit / 限值的 72%) |

---

*Generated from measured data and verified kinematics — MATLAB R2024a*
*基于实测数据与验证运动学生成 — MATLAB R2024a*
