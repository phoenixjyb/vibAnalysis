# CLAUDE.md — vibAnalysis Project Guide

Automatically read by Claude Code at the start of every session in this directory.
Read this before touching any code or analysis.

---

## 1. Critical Physics — X-Configuration Geometry (DO NOT GET THIS WRONG AGAIN)

The chassis is an **X-configuration omni-wheel platform**: each wheel's rolling axis
points NE/SE/SW/NW — at **45° to the chassis forward direction**.

For pure forward chassis motion at speed `v_chassis`, each wheel rolls at:

```
v_wheel = v_chassis × cos(45°) = v_chassis / sqrt(2)
```

All frequency calculations must use the corrected wheel speed:

```matlab
% CORRECT — always use sqrt(2) * wheelCirc
fw       = v_chassis / (sqrt(2) * wheelCirc);
f_roller = N * v_chassis / (sqrt(2) * wheelCirc);

% WRONG — do NOT use this (ignores 45° alignment)
fw       = v_chassis / wheelCirc;          % ← off by factor √2
```

**Why this matters:** Using the uncorrected formula made the dominant high-speed peaks
appear to be "~8 apparent events/rev", which was a mystery. With the √2 correction they
are exactly **N=11 per-plate roller passage** (< 6% error at all high-speed runs).

---

## 2. Verified Physical Results

| Finding | Value | Notes |
|---------|-------|-------|
| Wheel diameter | 5 in = 127 mm | |
| Wheel circumference | π × 0.127 = 0.3990 m | `wheelCirc` in all scripts |
| Wheel structure | 2 side plates × 11 rollers each | staggered 16.4° (= 360°/22) |
| Chassis configuration | X-type, wheel axes at 45° to forward | see `ref-info/` folder |
| True sample rate | **27,027 Hz** (37 µs steps) | column-5 declared ~26,820 Hz is WRONG |
| Motor max RPM | ~6,000 RPM | |
| Reducer ratio | 37.14 | |
| Max wheel rolling speed | ~1.05 m/s | → max chassis forward speed ~1.49 m/s |
| Motor RPM at 1.2 m/s chassis | 4,744 RPM | safely below 6,000 RPM limit |

### High-speed vibration (0.8–1.2 m/s chassis)

| Speed (m/s) | Dominant peak (Hz) | N=11 corrected (Hz) | Error |
|-------------|-------------------|---------------------|-------|
| 0.8 | 16.5 | 15.6 | −5.5% |
| 1.0 | 19.8 | 19.5 | −1.5% |
| 1.2 | 23.1 | 23.4 | +1.3% |

**Conclusion: dominant peaks = per-plate roller passage (N=11). Mystery solved.**
N=22 combined passage (31.3–46.8 Hz) is suppressed by the staggered dual-plate design.

### Low-speed vibration (0.2–0.6 m/s chassis)

| Speed (m/s) | Peak (Hz) | Events/wheel_rev (corrected) | Events/motor_rev |
|-------------|-----------|------------------------------|-----------------|
| 0.2 | 135 | ~379 | ~10.2 |
| 0.4 | 269 | ~377 | ~10.1 |
| 0.6 | 404 | ~378 | ~10.2 |

**Conclusion: ~10.2 events/motor_rev — motor electrical excitation (cogging torque).**
Previous (uncorrected) calculation gave ~267 events/wheel_rev and ~7.2/motor_rev — INCORRECT.

### Suspension design result

- Recommended: `fn = 4 Hz`, `ζ = 0.4` per corner
- Predicted output: < 0.030 g RMS at all speeds (target < 0.1 g)
- Static sag: 15.5 mm; minimum stroke: 61 mm

---

## 3. MATLAB Execution Rules

### Always use MCP tools — NEVER Bash + matlab -batch

```
✓  mcp__matlab__run_matlab_file(script_path)
✓  mcp__matlab__evaluate_matlab_code(project_path, code)
✗  Bash: /Applications/MATLAB_R2024a.app/bin/matlab -batch "..."
```

**Reason:** `-batch` mode has UTF-8 encoding issues with the Chinese CSV headers.
`textscan` reads only 2 rows instead of ~300,000.

### Data loading pattern (CSV files have Chinese headers)

```matlab
fid = fopen(fpath, 'r');                          % NO encoding argument
raw = textscan(fid, '%s%f%f%f%f', 'Delimiter', ',', ...
               'HeaderLines', 1, 'CollectOutput', false);
fclose(fid);
% Columns: 1=timestamp, 2=X(g), 3=Y(g), 4=Z(g), 5=declared_Fs(ignore)
```

Do NOT use `fopen(fpath, 'UTF-8')` + `fgetl` — Chinese bytes in UTF-8 mode corrupt
the file pointer and produce only 2 valid data rows.

### Working directory for MCP

Always set `project_path = '/Users/yanbo/Projects/vibAnalysis'`.

---

## 4. Project Scripts — What Each Does

| Script | Purpose | Requires |
|--------|---------|----------|
| `vibration_analysis.m` | FFT/Welch PSD, frequency table, saves `vibData.mat` | raw CSVs |
| `suspension_design.m` | 1-DOF transmissibility sweep, spring/damper sizing | `vibData.mat` |
| `suspension_verify.m` | Independent toolbox verification (tf, lsim, cwt, spa) | `vibData.mat` |
| `multiaxis_analysis.m` | 3-axis (X/Y/Z) PSD, RMS, cross-coherence | raw CSVs (standalone) |

Output figures go to `results/` with prefixes: `fig*`, `susp_fig*`, `verify_*`, `multi_fig*`.

---

## 5. Git / LFS

- `*.csv` files are tracked by **Git LFS** (`.gitattributes`)
- If CSV files appear as pointer text (small files), restore with: `git lfs checkout`
- Remote: `git@github.com:phoenixjyb/vibAnalysis.git`
- LFS objects are cached locally even without a remote push

---

## 6. Key Anti-Patterns (Lessons Learned)

1. **Never compute roller/wheel frequency as `v / wheelCirc`** — always `v / (sqrt(2) * wheelCirc)` for this X-config chassis.
2. **Never use `Fs` column from CSV** — it reads ~26,820 Hz but true rate is 27,027 Hz. Always hardcode `Fs = 27027.0`.
3. **Never open CSV with UTF-8 encoding** — use plain `fopen(fpath, 'r')`.
4. **Never run MATLAB via Bash** — use MCP tools only.
5. **N=11 is the dominant mechanical excitation**, not N=8 or N=22. N=22 is stagger-suppressed.
