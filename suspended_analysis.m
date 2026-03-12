%% suspended_analysis.m
% Before-vs-after analysis of chassis Z-axis vibration with 4-bar linkage
% suspension installed.  Compares against unsuspended baseline (vibData.mat).
%
% Also provides:
%   - Ring-down analysis to extract measured fn and zeta
%   - Updated mass budget (1.4 kg per suspension unit)
%   - Motion-ratio correction for effective k/c at wheel
%
% Data:  testData/SuspendedTests/  — new CSVs recorded with suspension
% Baseline: vibData.mat (from vibration_analysis.m, unsuspended)
%
% Outputs (saved to results/):
%   sus_fig1 — RMS comparison: before vs after
%   sus_fig2 — PSD overlay: before vs after at each speed
%   sus_fig3 — PSD before/after at key speeds (1-panel per speed)
%   sus_fig4 — Ring-down analysis: measured fn and zeta (if bump data)
%   sus_fig5 — Transmissibility estimate from before/after PSD ratio
%   sus_fig6 — Reduction percentage vs speed
%
% Usage: run from the vibAnalysis project root directory.
%        Requires vibData.mat (run vibration_analysis.m first).

clear; clc; close all;

%% ── Suspension Parameters ──────────────────────────────────────────────
% These should be updated after physical measurements.

% Mass budget
M_total_old     = 25.0;       % kg — original chassis (no suspension hardware)
M_sus_each      = 1.4;        % kg — each suspension unit
n_corners       = 4;
M_total_new     = M_total_old + n_corners * M_sus_each;  % 30.6 kg

% Sprung / unsprung split — ESTIMATE until weighed
% Each 1.4 kg suspension: ~0.8 kg fixed bracket (sprung), ~0.6 kg moving (unsprung)
M_sus_sprung_each   = 0.8;    % kg — bracket portion (bolted to chassis)
M_sus_unsprung_each = 0.6;    % kg — moving linkage + lower block

M_motor_wheel   = 1.3;        % kg — motor + wheel per corner (unchanged)
M_unsprung_corner = M_motor_wheel + M_sus_unsprung_each;   % ~1.9 kg
M_unsprung_total  = n_corners * M_unsprung_corner;          % ~7.6 kg
M_sprung_total    = M_total_new - M_unsprung_total;         % ~23.0 kg
M_sprung_corner   = M_sprung_total / n_corners;             % ~5.75 kg

% Motion ratio — MUST BE MEASURED from actual linkage geometry
% MR = (coil-over compression) / (wheel vertical displacement)
% Push wheel up 10 mm, measure how much coil-over compresses.
% If MR not yet measured, set to 1.0 and note results are provisional.
MR = 1.0;   % <-- UPDATE after measurement

% Coil-over angle from vertical (degrees) — estimated from side-view CAD
theta_coilover_deg = 25;   % <-- UPDATE after measurement
theta_coilover = deg2rad(theta_coilover_deg);

% Effective correction factor: k_wheel = k_coilover * MR^2 * cos^2(theta)
MR_eff = MR * cos(theta_coilover);   % effective motion ratio including angle
fprintf('=== Suspension Parameters ===\n');
fprintf('  Total mass (new):       %.1f kg\n', M_total_new);
fprintf('  Sprung per corner:      %.2f kg  (estimate — weigh to confirm)\n', M_sprung_corner);
fprintf('  Unsprung per corner:    %.2f kg\n', M_unsprung_corner);
fprintf('  Motion ratio (MR):      %.2f  (UPDATE after measurement)\n', MR);
fprintf('  Coil-over angle:        %.1f°\n', theta_coilover_deg);
fprintf('  Effective MR (incl. angle): %.3f\n', MR_eff);
fprintf('  k_wheel = k_coilover × %.3f  (= MR² × cos²θ)\n', MR_eff^2);
fprintf('\n');

%% ── Constants ──────────────────────────────────────────────────────────
Fs         = 27027.0;           % true sample rate (Hz)
wheelCirc  = pi * 0.127;        % wheel circumference (m)
g_accel    = 9.81;              % m/s²
outDir     = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

%% ── Data: new suspended-chassis recordings ─────────────────────────────
% Expected folder structure:
%   testData/SuspendedTests/<surface>/<csv files>
%
% File naming convention (same as MoreTests):
%   ...-a-<speed>-...csv   where speed is e.g. 0.2, 0.4, ... 1.5
%
% For initial indoor testing, a single folder suffices.
% Update dataDir and file list below when data is available.

dataDir_sus = 'testData/SuspendedTests';

% ── Check if suspended test data exists ─────────────────────────────────
if ~exist(dataDir_sus, 'dir')
    fprintf('╔══════════════════════════════════════════════════════════════╗\n');
    fprintf('║  DATA NOT YET AVAILABLE                                     ║\n');
    fprintf('║                                                             ║\n');
    fprintf('║  Expected data folder: testData/SuspendedTests/             ║\n');
    fprintf('║  Place CSV files there after recording, then re-run.        ║\n');
    fprintf('║                                                             ║\n');
    fprintf('║  For now, running parameter estimation and design preview.  ║\n');
    fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');
    hasNewData = false;
else
    % Auto-detect CSV files and extract speeds from filenames
    csvFiles = dir(fullfile(dataDir_sus, '**', '*.csv'));
    if isempty(csvFiles)
        fprintf('WARNING: %s exists but contains no CSV files.\n\n', dataDir_sus);
        hasNewData = false;
    else
        hasNewData = true;
        fprintf('Found %d CSV files in %s\n', numel(csvFiles), dataDir_sus);
    end
end

%% ── Load baseline (unsuspended) data ───────────────────────────────────
fprintf('Loading baseline data from vibData.mat ...\n');
if ~exist('vibData.mat','file')
    error('vibData.mat not found. Run vibration_analysis.m first.');
end
load('vibData.mat', 'accZ', 'Fs', 'speeds', 'nSpeeds', 'colors', 'legendLabels');
% Rename to avoid confusion
baseline_accZ   = accZ;
baseline_speeds = speeds;
baseline_nSpeeds = nSpeeds;
Fs_base = Fs;
fprintf('Loaded %d baseline datasets (unsuspended, 0.2–1.2 m/s).\n\n', baseline_nSpeeds);

%% ── Compute baseline PSDs ──────────────────────────────────────────────
fprintf('Computing baseline PSDs...\n');
welch_win_s = 0.5;
baseline_pxx = cell(baseline_nSpeeds, 1);
baseline_f   = cell(baseline_nSpeeds, 1);
baseline_rms = zeros(baseline_nSpeeds, 1);

for i = 1:baseline_nSpeeds
    z   = detrend(baseline_accZ{i}, 'constant');
    win = round(welch_win_s * Fs_base(i));
    [baseline_pxx{i}, baseline_f{i}] = pwelch(z, hann(win), round(win/2), [], Fs_base(i));
    baseline_rms(i) = rms(z);
end
fprintf('Done.\n\n');

%% ── Helper: load one CSV, return Z-accel vector ───────────────────────
function Z = loadCSV(fpath)
    fid = fopen(fpath, 'r');
    raw = textscan(fid, '%s%f%f%f%f', 'Delimiter', ',', ...
                   'HeaderLines', 1, 'CollectOutput', false);
    fclose(fid);
    Z = raw{4};           % column 4 = Z-axis (g)
    Z = Z(~isnan(Z));
end

%% ── Helper: extract speed from filename ────────────────────────────────
function spd = extractSpeed(fname)
    % Matches patterns like '-a-0.8-' or '-a-1.0-' or '-a-1.5-'
    tok = regexp(fname, '-a-(\d+\.?\d*)-', 'tokens');
    if ~isempty(tok)
        spd = str2double(tok{1}{1});
    else
        % Try simpler pattern: any decimal number in filename
        tok = regexp(fname, '(\d+\.\d+)', 'tokens');
        if ~isempty(tok)
            spd = str2double(tok{1}{1});
        else
            spd = NaN;
        end
    end
end

%% ════════════════════════════════════════════════════════════════════════
%  SECTION A: Design Preview (always runs — uses baseline + suspension params)
%% ════════════════════════════════════════════════════════════════════════

fprintf('=== DESIGN PREVIEW: Predicted performance with new mass budget ===\n\n');

% Transmissibility function (1-DOF acceleration)
T_func = @(f, fn, zeta) sqrt( (1 + (2*zeta*(f/fn)).^2) ./ ...
    ( (1-(f/fn).^2).^2 + (2*zeta*(f/fn)).^2 ) );

% Sweep fn for the new sprung mass, assuming various k_wheel values
fn_sweep = 2:0.25:8;
zeta_test = [0.2, 0.3, 0.4, 0.5];

% Predicted output RMS for each (fn, zeta, speed)
rms_pred = zeros(numel(fn_sweep), numel(zeta_test), baseline_nSpeeds);
for i_fn = 1:numel(fn_sweep)
    fn = fn_sweep(i_fn);
    for i_z = 1:numel(zeta_test)
        zeta = zeta_test(i_z);
        for i_spd = 1:baseline_nSpeeds
            f   = baseline_f{i_spd};
            pxx = baseline_pxx{i_spd};
            T   = T_func(f, fn, zeta);
            T(1) = 1;
            df  = f(2) - f(1);
            rms_pred(i_fn, i_z, i_spd) = sqrt(sum(T.^2 .* pxx) * df);
        end
    end
end

% Print sizing table for new mass
fprintf('Per-corner sizing at M_sprung = %.2f kg:\n', M_sprung_corner);
fprintf('  (k_wheel = k_coilover × MR_eff² = k_coilover × %.3f)\n\n', MR_eff^2);

fprintf('%-8s  %-12s  %-12s  %-12s  %-14s\n', ...
    'fn(Hz)', 'k_wheel', 'k_coilover', 'sag(mm)', 'worst RMS(g)');
fprintf('%s\n', repmat('-', 1, 65));
fn_show = [3, 3.5, 4, 4.5, 5, 6];
i_z04 = find(zeta_test == 0.4);
for fn = fn_show
    k_w = M_sprung_corner * (2*pi*fn)^2;
    k_co = k_w / MR_eff^2;  % coil-over spring rate needed
    sag = M_sprung_corner * g_accel / k_w * 1000;  % mm
    i_fn = find(abs(fn_sweep - fn) < 0.01);
    if ~isempty(i_fn)
        worst = max(rms_pred(i_fn, i_z04, :));
    else
        worst = NaN;
    end
    fprintf('%-8.1f  %-12.0f  %-12.0f  %-12.1f  %-14.4f\n', ...
        fn, k_w, k_co, sag, worst);
end
fprintf('\n');

% Key reference frequencies
fprintf('Key excitation frequencies (for suspension resonance avoidance):\n');
for v = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2]
    f_N11 = 11 * v / (sqrt(2) * wheelCirc);
    fprintf('  v=%.1f m/s: N=11 → %.1f Hz\n', v, f_N11);
end
fprintf('\n');

%% ════════════════════════════════════════════════════════════════════════
%  SECTION B: Measured data analysis (only if new data exists)
%% ════════════════════════════════════════════════════════════════════════

if ~hasNewData
    fprintf('Skipping measured-data analysis (no suspended test data yet).\n');
    fprintf('Place CSVs in testData/SuspendedTests/ and re-run.\n\n');

    % Still save the design preview figures
    fprintf('Generating design preview figures from baseline data...\n\n');

    % ── sus_fig1: Predicted RMS reduction at zeta=0.4 for various fn ────
    fig1 = figure('Name','Predicted RMS — New Mass Budget','Position',[50 50 1000 600]);
    hold on; grid on;
    plot(baseline_speeds, baseline_rms, 'k-s', 'LineWidth', 2, ...
        'MarkerSize', 8, 'MarkerFaceColor', 'k', 'DisplayName', 'Baseline (no suspension)');
    fn_plot = [3, 4, 5];
    cmap = lines(numel(fn_plot));
    for j = 1:numel(fn_plot)
        i_fn = find(abs(fn_sweep - fn_plot(j)) < 0.01);
        rms_v = squeeze(rms_pred(i_fn, i_z04, :));
        plot(baseline_speeds, rms_v, 'o--', 'Color', cmap(j,:), 'LineWidth', 1.5, ...
            'MarkerSize', 6, 'DisplayName', sprintf('Predicted fn=%dHz ζ=0.4', fn_plot(j)));
    end
    yline(0.1, 'r:', 'Target 0.1g', 'LineWidth', 1.5);
    xlabel('Chassis Speed (m/s)'); ylabel('Z-Acceleration RMS (g)');
    title(sprintf('Predicted RMS — Sprung Mass %.2f kg/corner (MR_{eff}=%.2f)', ...
        M_sprung_corner, MR_eff));
    legend('Location', 'northwest');
    saveas(fig1, fullfile(outDir, 'sus_fig1_predicted_rms.png'));
    fprintf('Saved sus_fig1 (predicted RMS)\n');

    % ── sus_fig2: Design heatmap for new mass ──────────────────────────
    fig2 = figure('Name','Design Space — New Mass','Position',[50 50 900 500]);
    worst_rms = max(rms_pred, [], 3);
    imagesc(zeta_test, fn_sweep, worst_rms);
    colorbar; colormap('hot');
    hold on;
    [~, hc] = contour(zeta_test, fn_sweep, worst_rms, [0.1 0.1], 'w-', 'LineWidth', 2);
    try, clabel(hc, 'FontSize', 9, 'Color', 'w'); catch, end
    xlabel('Damping Ratio ζ'); ylabel('Natural Frequency f_n (Hz)');
    title(sprintf('Worst-Speed RMS (g) — %.2f kg/corner sprung', M_sprung_corner));
    saveas(fig2, fullfile(outDir, 'sus_fig2_design_heatmap_newmass.png'));
    fprintf('Saved sus_fig2 (design heatmap)\n');

    fprintf('\nDesign preview complete. Awaiting test data.\n');
    return;
end

%% ── Load suspended test data ───────────────────────────────────────────
fprintf('\n=== Loading suspended chassis test data ===\n');

sus_accZ   = {};
sus_speeds = [];
sus_files  = {};

for k = 1:numel(csvFiles)
    fpath = fullfile(csvFiles(k).folder, csvFiles(k).name);
    spd   = extractSpeed(csvFiles(k).name);
    if isnan(spd)
        fprintf('  SKIP (no speed in name): %s\n', csvFiles(k).name);
        continue;
    end
    Z = loadCSV(fpath);
    if numel(Z) < 1000
        fprintf('  SKIP (too few samples): %s (%d samples)\n', csvFiles(k).name, numel(Z));
        continue;
    end
    sus_accZ{end+1}   = Z;        %#ok<SAGROW>
    sus_speeds(end+1)  = spd;      %#ok<SAGROW>
    sus_files{end+1}   = csvFiles(k).name; %#ok<SAGROW>
    fprintf('  Loaded: %s  speed=%.1f m/s  N=%d  RMS=%.4f g\n', ...
        csvFiles(k).name, spd, numel(Z), rms(detrend(Z,'constant')));
end
sus_nFiles = numel(sus_accZ);
fprintf('Loaded %d suspended-chassis datasets.\n\n', sus_nFiles);

% Sort by speed
[sus_speeds, sortIdx] = sort(sus_speeds);
sus_accZ  = sus_accZ(sortIdx);
sus_files = sus_files(sortIdx);

% Compute suspended PSDs
sus_pxx = cell(sus_nFiles, 1);
sus_f   = cell(sus_nFiles, 1);
sus_rms = zeros(sus_nFiles, 1);

for i = 1:sus_nFiles
    z   = detrend(sus_accZ{i}, 'constant');
    win = round(welch_win_s * Fs);
    [sus_pxx{i}, sus_f{i}] = pwelch(z, hann(win), round(win/2), [], Fs);
    sus_rms(i) = rms(z);
end

%% ── Find matching baseline speeds ─────────────────────────────────────
% For each suspended speed, find the closest baseline speed (within 0.05 m/s)
match_base = nan(sus_nFiles, 1);
for i = 1:sus_nFiles
    [dv, idx] = min(abs(baseline_speeds - sus_speeds(i)));
    if dv < 0.05
        match_base(i) = idx;
    end
end

%% ════════════════════════════════════════════════════════════════════════
%% Fig 1 — RMS Comparison: Before vs After
%% ════════════════════════════════════════════════════════════════════════
fig1 = figure('Name','RMS Before vs After Suspension','Position',[50 50 1000 600]);
hold on; grid on;

% Baseline
plot(baseline_speeds, baseline_rms, 'ks-', 'LineWidth', 2, 'MarkerSize', 8, ...
    'MarkerFaceColor', 'k', 'DisplayName', 'Baseline (no suspension)');

% Suspended
plot(sus_speeds, sus_rms, 'ro-', 'LineWidth', 2, 'MarkerSize', 8, ...
    'MarkerFaceColor', 'r', 'DisplayName', 'With suspension');

yline(0.1, 'b:', 'Target 0.1g', 'LineWidth', 1.5);
xlabel('Chassis Speed (m/s)'); ylabel('Z-Acceleration RMS (g)');
title('Vibration Before vs After Suspension / 安装悬挂前后振动对比');
legend('Location', 'northwest');
set(gca, 'FontSize', 11);
saveas(fig1, fullfile(outDir, 'sus_fig1_rms_comparison.png'));
fprintf('Saved sus_fig1\n');

%% ════════════════════════════════════════════════════════════════════════
%% Fig 2 — PSD Overlay: Before vs After at each matched speed
%% ════════════════════════════════════════════════════════════════════════
nMatched = sum(~isnan(match_base));
if nMatched > 0
    nCols = min(nMatched, 3);
    nRows = ceil(nMatched / nCols);
    fig2 = figure('Name','PSD Before vs After','Position',[50 50 1400 400*nRows]);

    plotIdx = 0;
    for i = 1:sus_nFiles
        bi = match_base(i);
        if isnan(bi), continue; end
        plotIdx = plotIdx + 1;
        subplot(nRows, nCols, plotIdx); hold on; grid on;

        % Baseline PSD
        plot(baseline_f{bi}, 10*log10(baseline_pxx{bi}), 'b', 'LineWidth', 1.2, ...
            'DisplayName', 'Before (no susp.)');
        % Suspended PSD
        plot(sus_f{i}, 10*log10(sus_pxx{i}), 'r', 'LineWidth', 1.2, ...
            'DisplayName', 'After (with susp.)');

        xlim([0 200]); ylim([-120 -20]);
        xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz)');
        title(sprintf('%.1f m/s  |  RMS: %.3f → %.3f g (%.0f%%)', ...
            sus_speeds(i), baseline_rms(bi), sus_rms(i), ...
            (1 - sus_rms(i)/baseline_rms(bi))*100));
        legend('FontSize', 7, 'Location', 'northeast');
    end
    sgtitle('PSD Before vs After Suspension / 功率谱密度对比');
    saveas(fig2, fullfile(outDir, 'sus_fig2_psd_before_after.png'));
    fprintf('Saved sus_fig2\n');
end

%% ════════════════════════════════════════════════════════════════════════
%% Fig 3 — Measured transmissibility estimate (PSD ratio)
%% ════════════════════════════════════════════════════════════════════════
if nMatched > 0
    fig3 = figure('Name','Estimated Transmissibility','Position',[50 50 1400 400*nRows]);

    plotIdx = 0;
    for i = 1:sus_nFiles
        bi = match_base(i);
        if isnan(bi), continue; end
        plotIdx = plotIdx + 1;
        subplot(nRows, nCols, plotIdx); hold on; grid on;

        % Interpolate baseline PSD onto suspended frequency grid
        pxx_base_interp = interp1(baseline_f{bi}, baseline_pxx{bi}, sus_f{i}, 'linear', NaN);

        % T(f) estimate = sqrt(PSD_after / PSD_before)
        valid = pxx_base_interp > 0 & ~isnan(pxx_base_interp);
        T_est = nan(size(sus_f{i}));
        T_est(valid) = sqrt(sus_pxx{i}(valid) ./ pxx_base_interp(valid));

        plot(sus_f{i}, 20*log10(T_est), 'k', 'LineWidth', 0.8);
        yline(0, 'r--', '0 dB (unity)', 'LineWidth', 1);
        xlim([0 200]); ylim([-40 20]);
        xlabel('Frequency (Hz)'); ylabel('T(f) estimate (dB)');
        title(sprintf('%.1f m/s — Transmissibility Estimate', sus_speeds(i)));
    end
    sgtitle('Estimated T(f) = √(PSD_{after}/PSD_{before}) / 传递率估算');
    saveas(fig3, fullfile(outDir, 'sus_fig3_transmissibility_est.png'));
    fprintf('Saved sus_fig3\n');
end

%% ════════════════════════════════════════════════════════════════════════
%% Fig 4 — Ring-down analysis: extract fn and zeta from transient
%% ════════════════════════════════════════════════════════════════════════
% Look for bump/transient data: files with 'bump' or 'ringdown' in name
bump_idx = [];
for i = 1:sus_nFiles
    if contains(lower(sus_files{i}), 'bump') || contains(lower(sus_files{i}), 'ring')
        bump_idx(end+1) = i; %#ok<SAGROW>
    end
end

if ~isempty(bump_idx)
    fig4 = figure('Name','Ring-Down Analysis','Position',[50 50 1200 400*numel(bump_idx)]);

    for bi = 1:numel(bump_idx)
        idx = bump_idx(bi);
        z = detrend(sus_accZ{idx}, 'constant');
        t = (0:numel(z)-1) / Fs;

        % Find the transient: peak above 3× RMS
        z_rms = rms(z);
        [z_peak, i_peak] = max(abs(z));
        if z_peak < 3 * z_rms
            fprintf('  Ring-down %s: no clear transient found (peak/RMS = %.1f)\n', ...
                sus_files{idx}, z_peak/z_rms);
            continue;
        end

        % Extract window: from peak to peak + 2 seconds
        i_start = max(i_peak - round(0.1*Fs), 1);
        i_end   = min(i_peak + round(2.0*Fs), numel(z));
        z_win   = z(i_start:i_end);
        t_win   = t(i_start:i_end) - t(i_start);

        % Find positive peaks in the ring-down (after the main peak)
        z_after = z_win(round(0.1*Fs):end);  % skip first 0.1s
        t_after = t_win(round(0.1*Fs):end);
        [pks, locs] = findpeaks(z_after, 'MinPeakHeight', 0.3*max(z_after), ...
            'MinPeakDistance', round(Fs/20));  % expect fn < 20 Hz

        if numel(pks) >= 3
            % Logarithmic decrement: delta = ln(pks(i)/pks(i+1))
            deltas = log(pks(1:end-1) ./ pks(2:end));
            delta_mean = mean(deltas);

            % zeta = delta / sqrt(4*pi^2 + delta^2)
            zeta_meas = delta_mean / sqrt(4*pi^2 + delta_mean^2);

            % fn from peak spacing
            peak_times = t_after(locs);
            periods = diff(peak_times);
            fd_meas = 1 / mean(periods);   % damped natural frequency
            fn_meas = fd_meas / sqrt(1 - zeta_meas^2);  % undamped

            fprintf('  Ring-down %s:\n', sus_files{idx});
            fprintf('    Measured fd = %.2f Hz (damped)\n', fd_meas);
            fprintf('    Measured fn = %.2f Hz (undamped)\n', fn_meas);
            fprintf('    Measured zeta = %.3f\n', zeta_meas);
            fprintf('    Log decrement = %.3f (mean of %d intervals)\n', delta_mean, numel(deltas));

            % Back-calculate effective k_wheel
            k_eff = M_sprung_corner * (2*pi*fn_meas)^2;
            c_eff = 2 * zeta_meas * sqrt(k_eff * M_sprung_corner);
            fprintf('    Implied k_wheel = %.0f N/m\n', k_eff);
            fprintf('    Implied c_wheel = %.1f N·s/m\n', c_eff);
            fprintf('    Implied k_coilover = %.0f N/m  (if MR_eff=%.2f)\n', ...
                k_eff / MR_eff^2, MR_eff);
        else
            zeta_meas = NaN; fn_meas = NaN;
            fprintf('  Ring-down %s: fewer than 3 peaks found — cannot extract zeta.\n', sus_files{idx});
        end

        % Plot
        subplot(numel(bump_idx), 2, 2*(bi-1)+1);
        plot(t_win, z_win, 'b', 'LineWidth', 0.6); grid on;
        xlabel('Time (s)'); ylabel('Z-accel (g)');
        title(sprintf('Ring-Down: %s', sus_files{idx}), 'Interpreter', 'none');
        if numel(pks) >= 3
            hold on;
            plot(t_after(locs), pks, 'rv', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
            text(0.5, 0.9, sprintf('f_n = %.1f Hz\nζ = %.3f', fn_meas, zeta_meas), ...
                'Units', 'normalized', 'FontSize', 11, 'BackgroundColor', 'w');
        end

        subplot(numel(bump_idx), 2, 2*(bi-1)+2);
        nfft = 2^nextpow2(numel(z_win));
        [pxx_bump, f_bump] = pwelch(z_win, hann(min(nfft, numel(z_win))), [], nfft, Fs);
        plot(f_bump, 10*log10(pxx_bump), 'k', 'LineWidth', 1); grid on;
        xlim([0 50]); xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz)');
        title('Ring-Down Spectrum');
        if ~isnan(fn_meas)
            xline(fn_meas, 'r--', sprintf('f_n=%.1fHz', fn_meas), 'LineWidth', 1.5);
        end
    end
    sgtitle('Ring-Down Analysis — Measured f_n and ζ / 衰减振荡分析');
    saveas(fig4, fullfile(outDir, 'sus_fig4_ringdown.png'));
    fprintf('Saved sus_fig4\n');
else
    fprintf('No ring-down / bump test data found.\n');
    fprintf('  (Name files with "bump" or "ringdown" to trigger ring-down analysis)\n\n');
end

%% ════════════════════════════════════════════════════════════════════════
%% Fig 5 — Reduction percentage vs speed
%% ════════════════════════════════════════════════════════════════════════
if nMatched > 0
    fig5 = figure('Name','Reduction vs Speed','Position',[50 50 800 500]);
    matched_speeds = [];
    reductions = [];
    for i = 1:sus_nFiles
        bi = match_base(i);
        if isnan(bi), continue; end
        matched_speeds(end+1) = sus_speeds(i); %#ok<SAGROW>
        reductions(end+1) = (1 - sus_rms(i)/baseline_rms(bi)) * 100; %#ok<SAGROW>
    end

    bar(matched_speeds, reductions, 0.5, 'FaceColor', [0.2 0.6 0.3]);
    xlabel('Chassis Speed (m/s)'); ylabel('RMS Reduction (%)');
    title('Z-Vibration Reduction with Suspension / 悬挂减振效果');
    grid on;
    yline(0, 'k-');
    for j = 1:numel(matched_speeds)
        text(matched_speeds(j), reductions(j) + 2, sprintf('%.0f%%', reductions(j)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    set(gca, 'FontSize', 11);
    saveas(fig5, fullfile(outDir, 'sus_fig5_reduction_pct.png'));
    fprintf('Saved sus_fig5\n');
end

%% ── Summary table ──────────────────────────────────────────────────────
fprintf('\n=== SUMMARY ===\n\n');
fprintf('%-10s  %-14s  %-14s  %-12s\n', 'Speed', 'Before (g)', 'After (g)', 'Reduction');
fprintf('%s\n', repmat('-', 1, 55));
for i = 1:sus_nFiles
    bi = match_base(i);
    if isnan(bi)
        fprintf('%-10.1f  %-14s  %-14.4f  %-12s\n', ...
            sus_speeds(i), 'N/A', sus_rms(i), 'N/A (no baseline)');
    else
        red = (1 - sus_rms(i)/baseline_rms(bi)) * 100;
        fprintf('%-10.1f  %-14.4f  %-14.4f  %-12.1f%%\n', ...
            sus_speeds(i), baseline_rms(bi), sus_rms(i), red);
    end
end
fprintf('\n');

fprintf('Suspension parameters used:\n');
fprintf('  Sprung mass/corner: %.2f kg (estimate)\n', M_sprung_corner);
fprintf('  Motion ratio:       %.2f (UPDATE after measurement)\n', MR);
fprintf('  Coil-over angle:    %.1f°\n', theta_coilover_deg);
fprintf('  MR_eff:             %.3f\n', MR_eff);
fprintf('\n');
fprintf('Figures saved to ./%s/\n', outDir);
