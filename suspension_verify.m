%% suspension_verify.m
% Independent verification of vibration analysis and suspension design
% using MATLAB toolbox functions:
%   - Signal Processing Toolbox : pspectrum, findpeaks, spectrogram, cpsd, tfestimate
%   - Control System Toolbox    : tf, bodemag, lsim, bodeplot
%   - System Identification     : spa (spectral analysis)
%   - Wavelet Toolbox           : cwt (stationarity check)
%
% Loads vibData.mat produced by vibration_analysis.m

clear; clc; close all;

%% ── Load data ─────────────────────────────────────────────────────────────
if ~exist('vibData.mat','file')
    error('vibData.mat not found. Run vibration_analysis.m first.');
end
load('vibData.mat','accZ','Fs','speeds','nSpeeds','colors','legendLabels');
fprintf('Loaded %d datasets.\n\n', nSpeeds);

Fs0 = Fs(1);            % 27027 Hz (same for all)
wheelCirc = pi * 5 * 0.0254;   % π × 0.127 m

fn_rec   = 4;           % recommended suspension natural frequency (Hz)
zeta_rec = 0.4;         % recommended damping ratio
wn       = 2*pi*fn_rec;

%% ═══════════════════════════════════════════════════════════════════════
%% PART A  –  VIBRATION ANALYSIS VERIFICATION
%% ═══════════════════════════════════════════════════════════════════════

%% A1: pspectrum  (Signal Processing Toolbox) — compare to manual Welch PSD
fprintf('=== A1: pspectrum vs manual Welch PSD ===\n');
fig_A1 = figure('Name','A1: pspectrum vs Welch PSD','Position',[50 50 1400 500]);
for i = 1:nSpeeds
    z   = accZ{i};
    % pspectrum with explicit frequency resolution
    [p_ps, f_ps] = pspectrum(z, Fs0, 'FrequencyResolution', 2.0);
    p_ps_db = 10*log10(p_ps);

    % our Welch PSD for comparison
    win = round(0.5 * Fs0);
    [pxx, f_w] = pwelch(z, hann(win), round(win/2), [], Fs0);
    pxx_db = 10*log10(pxx);

    subplot(2,3,i);
    plot(f_w,  pxx_db,  'b',  'LineWidth',0.8, 'DisplayName','Welch');  hold on;
    plot(f_ps, p_ps_db, 'r--','LineWidth',0.8, 'DisplayName','pspectrum');
    xlim([0 200]); xlabel('Frequency (Hz)'); ylabel('PSD (dB)');
    title(sprintf('%.1f m/s', speeds(i))); grid on;
    legend('FontSize',7,'Location','northeast');
end
sgtitle('A1: pspectrum (Signal Processing Toolbox) vs Welch PSD');

%% A2: findpeaks  — automated roller frequency identification
fprintf('\n=== A2: Dominant peaks via findpeaks (Signal Processing Toolbox) ===\n');
fprintf('Verifying roller count by matching peak frequencies to N×v/C\n\n');
fprintf('%-10s  %-12s  %-14s  %-15s  %-12s\n', ...
    'Speed','Peak(Hz)','Freq/speed','Events/rev','Best N match');
fprintf('%s\n', repmat('-',1,68));

fig_A2 = figure('Name','A2: findpeaks Roller Identification','Position',[50 50 1400 600]);
% Wheel: 2 plates × 11 rollers, staggered. Candidates include 11 (per-plate) and 22 (combined).
N_candidates = [6:24];

for i = 1:nSpeeds
    z   = accZ{i};
    win = round(0.5 * Fs0);
    [pxx, f] = pwelch(z, hann(win), round(win/2), [], Fs0);

    % Search 5–200 Hz band (above wheel rotation, well below Nyquist)
    band = f >= 5 & f <= 200;
    f_b  = f(band);
    p_b  = 10*log10(pxx(band));

    % findpeaks: MinPeakProminence filters out noise shoulders
    [pks, locs, ~, prom] = findpeaks(p_b, f_b, ...
        'MinPeakProminence', 6, 'SortStr', 'descend', 'NPeaks', 6);

    % For each peak, compute events/revolution and best roller count match.
    % X-configuration correction: wheel rolling speed = v_chassis / sqrt(2),
    % so wheel rotation rate = v_chassis / (sqrt(2) * wheelCirc).
    % ev_per_rev = peak_freq / (v_chassis / (sqrt(2)*wheelCirc))
    %            = peak_freq * sqrt(2) * wheelCirc / v_chassis
    ev_per_rev = locs(:)' * wheelCirc * sqrt(2) / speeds(i);   % 1×nPeaks
    [~, best_idx] = min(abs(bsxfun(@minus, N_candidates(:), ev_per_rev)), [], 1); % 1×nPeaks

    subplot(2,3,i);
    plot(f_b, p_b, 'Color', colors(i,:), 'LineWidth', 0.8); hold on;
    if ~isempty(locs)
        plot(locs, pks, 'rv', 'MarkerSize', 8, 'MarkerFaceColor','r');
        for p_i = 1:numel(locs)
            text(locs(p_i), pks(p_i)+1.5, sprintf('%.1fHz\n(N≈%d)', ...
                locs(p_i), N_candidates(best_idx(p_i))), ...
                'FontSize',6,'HorizontalAlignment','center');
        end
        % Print the most prominent peak
        fprintf('%-10.1f  %-12.2f  %-14.2f  %-15.2f  %-12d\n', ...
            speeds(i), locs(1), locs(1)/speeds(i), ev_per_rev(1), ...
            N_candidates(best_idx(1)));
    else
        fprintf('%-10.1f  (no prominent peaks found)\n', speeds(i));
    end
    xlabel('Frequency (Hz)'); ylabel('PSD (dB)'); xlim([0 200]);
    title(sprintf('%.1f m/s', speeds(i))); grid on;
end
sgtitle('A2: Roller Frequency Peaks via findpeaks (Signal Processing Toolbox)');

%% A3: spectrogram  — check signal stationarity (is speed truly steady-state?)
fprintf('\n=== A3: Spectrogram stationarity check (Signal Processing Toolbox) ===\n');
fig_A3 = figure('Name','A3: Spectrograms','Position',[50 50 1400 700]);
for i = 1:nSpeeds
    z   = accZ{i};
    win = round(0.5 * Fs0);   % 0.5 s window
    subplot(2,3,i);
    % spectrogram plots time-frequency heatmap
    spectrogram(z, hann(win), round(win/2), [], Fs0, 'yaxis');
    ylim([0 200]);
    title(sprintf('%.1f m/s', speeds(i)));
    colormap('jet');
end
sgtitle('A3: Spectrograms – Stationarity Check (Signal Processing Toolbox)');

%% A4: cwt (Wavelet Toolbox) — scalogram on highest-vibration run (1.2 m/s)
fprintf('=== A4: Continuous Wavelet Transform scalogram (Wavelet Toolbox) ===\n');
fig_A4 = figure('Name','A4: CWT Scalogram 1.2 m/s','Position',[50 50 900 500]);
z12  = accZ{nSpeeds};
N_cwt = min(numel(z12), round(3 * Fs0));  % first 3 seconds (to keep it fast)
t_cwt = (0:N_cwt-1) / Fs0;
[wt, f_cwt] = cwt(z12(1:N_cwt), Fs0, 'FrequencyLimits', [1 500]);
surface(t_cwt, f_cwt, abs(wt), 'EdgeColor','none');
axis tight; view(0,90); shading interp;
xlabel('Time (s)'); ylabel('Frequency (Hz)');
title('A4: CWT Scalogram – Z-accel at 1.2 m/s (Wavelet Toolbox)');
colorbar; colormap('jet');
% Overlay theoretical roller-passage lines: N=11 (per-plate) and N=22 (combined dual-plate).
% X-configuration correction: wheel rolling speed = v_chassis / sqrt(2).
hold on;
fw_12 = speeds(nSpeeds) / (sqrt(2) * wheelCirc);
yline(11 * fw_12, 'w--', sprintf('f_{roller}(N=11)=%.1fHz', 11*fw_12), 'LineWidth', 2);
yline(22 * fw_12, 'c--', sprintf('f_{roller}(N=22)=%.1fHz', 22*fw_12), 'LineWidth', 2);

%% ═══════════════════════════════════════════════════════════════════════
%% PART B  –  SUSPENSION DESIGN VERIFICATION
%% ═══════════════════════════════════════════════════════════════════════

%% B1: Suspension transfer function via Control System Toolbox tf/bodemag
fprintf('\n=== B1: Suspension TF via Control System Toolbox ===\n');

% 1-DOF base excitation: T(s) = (2*zeta*wn*s + wn^2) / (s^2 + 2*zeta*wn*s + wn^2)
% Identical transmissibility for both displacement and acceleration inputs.
num_tf = [2*zeta_rec*wn,  wn^2];
den_tf = [1,  2*zeta_rec*wn,  wn^2];
sys_rec = tf(num_tf, den_tf);

fprintf('Suspension transfer function (fn=%dHz, zeta=%.1f):\n', fn_rec, zeta_rec);
sys_rec

% Bode magnitude plot — compare to our manual formula
fig_B1 = figure('Name','B1: Suspension Transmissibility – Bode vs Manual','Position',[50 50 1200 550]);

f_plot = logspace(-1, 3, 2000);   % 0.1 – 1000 Hz
w_plot = 2*pi*f_plot;

% Control System Toolbox: bodemag
[mag_bode, ~] = bode(sys_rec, w_plot);
mag_bode_db   = 20*log10(squeeze(mag_bode)');  % transpose → row vector to match T_manual_db

% Our manual formula
r = f_plot / fn_rec;
T_manual = sqrt( (1+(2*zeta_rec*r).^2) ./ ((1-r.^2).^2 + (2*zeta_rec*r).^2) );
T_manual_db = 20*log10(T_manual);

subplot(1,2,1);
semilogx(f_plot, mag_bode_db, 'b-',  'LineWidth', 1.8, 'DisplayName', 'Control System Toolbox tf/bode'); hold on;
semilogx(f_plot, T_manual_db, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Manual formula');
xlabel('Frequency (Hz)'); ylabel('Transmissibility (dB)');
title(sprintf('Transmissibility: tf/bode vs Manual  (f_n=%dHz, ζ=%.1f)', fn_rec, zeta_rec));
legend('Location','southwest'); grid on;
xline(fn_rec,       'k:', sprintf('f_n=%dHz',fn_rec));
xline(fn_rec*sqrt(2),'g:', 'f_n√2 (isolation start)');
yline(0,            'k:');

% Difference
subplot(1,2,2);
semilogx(f_plot, mag_bode_db - T_manual_db, 'k-', 'LineWidth',1.2);
xlabel('Frequency (Hz)'); ylabel('Difference (dB)');
title('Discrepancy: tf/bode − Manual (should be ~0)');
grid on; ylim([-0.1 0.1]);

sgtitle('B1: Suspension Transmissibility – Control System Toolbox Verification');

% Quantify max discrepancy
max_diff = max(abs(mag_bode_db - T_manual_db));
fprintf('Max discrepancy between tf/bode and manual formula: %.2e dB\n', max_diff);

%% B2: Multiple configurations — Bode comparison
fprintf('\n=== B2: Bode comparison across fn and zeta (Control System Toolbox) ===\n');
fn_vals   = [3, 4, 5];
zeta_vals = [0.3, 0.4, 0.5];
fig_B2 = figure('Name','B2: Bode – Multiple Suspension Configs','Position',[50 50 1300 550]);

subplot(1,2,1);   % vary fn, fixed zeta=0.4
hold on;
cm = lines(numel(fn_vals));
for j = 1:numel(fn_vals)
    wn_j = 2*pi*fn_vals(j);
    sys_j = tf([2*0.4*wn_j, wn_j^2], [1, 2*0.4*wn_j, wn_j^2]);
    [m,~] = bode(sys_j, w_plot);
    semilogx(f_plot, 20*log10(squeeze(m)), 'Color',cm(j,:), 'LineWidth',1.4, ...
        'DisplayName', sprintf('f_n=%dHz', fn_vals(j)));
end
yline(0,'k:');
xline(11*speeds(end)/(sqrt(2)*wheelCirc), 'b--', sprintf('N=11: %.1fHz', 11*speeds(end)/(sqrt(2)*wheelCirc)));
xline(22*speeds(end)/(sqrt(2)*wheelCirc), 'm--', sprintf('N=22: %.1fHz', 22*speeds(end)/(sqrt(2)*wheelCirc)));
xlabel('Frequency (Hz)'); ylabel('Transmissibility (dB)');
title('Effect of f_n  (ζ = 0.4)');
legend('Location','southwest'); grid on;

subplot(1,2,2);   % vary zeta, fixed fn=4
hold on;
cm2 = cool(numel(zeta_vals));
for j = 1:numel(zeta_vals)
    sys_j = tf([2*zeta_vals(j)*wn, wn^2], [1, 2*zeta_vals(j)*wn, wn^2]);
    [m,~] = bode(sys_j, w_plot);
    semilogx(f_plot, 20*log10(squeeze(m)), 'Color',cm2(j,:), 'LineWidth',1.4, ...
        'DisplayName', sprintf('ζ=%.1f', zeta_vals(j)));
end
yline(0,'k:'); xline(11*speeds(end)/(sqrt(2)*wheelCirc),'m--');
xlabel('Frequency (Hz)'); ylabel('Transmissibility (dB)');
title('Effect of ζ  (f_n = 4 Hz)');
legend('Location','southwest'); grid on;

sgtitle('B2: Suspension Transmissibility – Control System Toolbox Bode Plots');

%% B3: lsim (Control System Toolbox) — time-domain simulation vs PSD method
fprintf('\n=== B3: lsim time-domain simulation vs PSD-based RMS (Control System Toolbox) ===\n');
fprintf('%-12s  %-18s  %-18s  %-12s\n', 'Speed (m/s)', 'PSD method RMS(g)', 'lsim RMS(g)', 'Diff(%)');
fprintf('%s\n', repmat('-',1,65));

rms_psd  = zeros(nSpeeds,1);
rms_lsim = zeros(nSpeeds,1);

for i = 1:nSpeeds
    z   = accZ{i};
    N   = numel(z);
    t   = (0:N-1)' / Fs0;

    % PSD method RMS (from suspension_design.m approach)
    win = round(0.5 * Fs0);
    [pxx, f] = pwelch(z, hann(win), round(win/2), [], Fs0);
    r_freq = f / fn_rec;  r_freq(1) = 1e-6;
    T_sq  = (1+(2*zeta_rec*r_freq).^2) ./ ((1-r_freq.^2).^2 + (2*zeta_rec*r_freq).^2);
    rms_psd(i) = sqrt(sum(T_sq .* pxx) * (f(2)-f(1)));

    % lsim: feed the actual measured acceleration into the suspension TF
    x_out = lsim(sys_rec, z, t);
    rms_lsim(i) = rms(x_out - mean(x_out));

    diff_pct = abs(rms_lsim(i) - rms_psd(i)) / rms_psd(i) * 100;
    fprintf('%-12.1f  %-18.5f  %-18.5f  %-12.2f\n', ...
        speeds(i), rms_psd(i), rms_lsim(i), diff_pct);
end
fprintf('\n');

% Plot comparison
fig_B3 = figure('Name','B3: lsim vs PSD method','Position',[50 50 1300 500]);

subplot(1,2,1);
plot(speeds, rms_psd,  'bo-', 'LineWidth',1.5, 'MarkerSize',8, 'DisplayName','PSD method'); hold on;
plot(speeds, rms_lsim, 'rs-', 'LineWidth',1.5, 'MarkerSize',8, 'DisplayName','lsim (Control System Toolbox)');
yline(0.1, 'k--', '0.1 g target', 'LineWidth',1.2);
xlabel('Speed (m/s)'); ylabel('Payload RMS (g)');
title('Predicted vs Simulated Output RMS After Suspension');
legend('Location','northwest'); grid on; grid minor;

subplot(1,2,2);
% Time-domain snippet: 1.2 m/s
i_sp = nSpeeds;
z12  = accZ{i_sp};
N_plot = round(1.0 * Fs0);   % 1 second
t_plot = (0:N_plot-1)' / Fs0;
x_out12 = lsim(sys_rec, z12(1:N_plot), t_plot);
plot(t_plot, z12(1:N_plot),      'b',  'LineWidth',0.6, 'DisplayName','Input (unsuspended)');
hold on;
plot(t_plot, x_out12,            'r',  'LineWidth',0.8, 'DisplayName','Output (with suspension)');
xlabel('Time (s)'); ylabel('Acceleration (g)');
title(sprintf('lsim Time-Domain: 1.2 m/s first 1 s  (f_n=%dHz, ζ=%.1f)', fn_rec, zeta_rec));
legend('Location','northeast'); grid on;

sgtitle('B3: lsim Time-Domain Simulation – Control System Toolbox Verification');

%% B4: spa (System Identification Toolbox) — data-driven spectral estimate
fprintf('=== B4: Spectral analysis via spa (System Identification Toolbox) ===\n');
fig_B4 = figure('Name','B4: spa vs Welch PSD','Position',[50 50 1400 500]);

for i = 1:nSpeeds
    z   = accZ{i};
    % spa: smoothed non-parametric spectral estimate using iddata
    dat  = iddata(z, [], 1/Fs0);   % output-only iddata (no input)
    g    = spa(dat);               % spectral estimate

    % Extract frequency and amplitude
    f_spa = g.Frequency / (2*pi);  % rad/s → Hz
    p_spa = squeeze(g.SpectrumData);  % power spectrum

    % Welch for comparison
    win = round(0.5 * Fs0);
    [pxx, f_w] = pwelch(z, hann(win), round(win/2), [], Fs0);

    subplot(2,3,i);
    plot(f_w,   10*log10(pxx),    'b',  'LineWidth',0.8, 'DisplayName','Welch'); hold on;
    plot(f_spa, 10*log10(p_spa),  'r--','LineWidth',0.8, 'DisplayName','spa (SysID)');
    xlim([0 200]); xlabel('Frequency (Hz)'); ylabel('PSD (dB)');
    title(sprintf('%.1f m/s', speeds(i))); grid on;
    legend('FontSize',7,'Location','northeast');
end
sgtitle('B4: spa (System Identification Toolbox) vs Welch PSD');

%% B5: Pole-zero and step response of suspension TF
fprintf('\n=== B5: Suspension TF properties (Control System Toolbox) ===\n');
fprintf('Poles of recommended suspension (fn=%dHz, zeta=%.1f):\n', fn_rec, zeta_rec);
p = pole(sys_rec);
fprintf('  p1 = %.4f + %.4fi  (|p|=%.4f, freq=%.2f Hz)\n', ...
    real(p(1)), imag(p(1)), abs(p(1)), abs(p(1))/(2*pi));
fprintf('  p2 = %.4f + %.4fi\n\n', real(p(2)), imag(p(2)));

% Damped natural frequency from poles
wd = abs(imag(p(1))) / (2*pi);
sigma = -real(p(1));
zeta_check  = sigma / abs(p(1));
wn_check    = abs(p(1)) / (2*pi);
fprintf('From pole analysis:\n');
fprintf('  Damped natural freq wd = %.3f Hz\n', wd);
fprintf('  Undamped natural freq wn (from poles) = %.3f Hz  (expected: %.3f Hz)\n', wn_check, fn_rec);
fprintf('  Damping ratio (from poles) = %.4f  (expected: %.4f)\n\n', zeta_check, zeta_rec);

fig_B5 = figure('Name','B5: TF Properties','Position',[50 50 1200 500]);
subplot(1,3,1);
pzmap(sys_rec); title('Pole-Zero Map'); grid on;

subplot(1,3,2);
step(sys_rec); title(sprintf('Step Response (f_n=%dHz, ζ=%.1f)', fn_rec, zeta_rec)); grid on;

subplot(1,3,3);
hold on;
for j = 1:numel(fn_vals)
    wn_j = 2*pi*fn_vals(j);
    sys_j = tf([2*0.4*wn_j wn_j^2],[1 2*0.4*wn_j wn_j^2]);
    impulse(sys_j, 3);
end
title('Impulse Response (ζ=0.4, varying f_n)'); grid on;
legend(arrayfun(@(f) sprintf('f_n=%dHz',f), fn_vals,'UniformOutput',false));

sgtitle('B5: Suspension TF Characterisation (Control System Toolbox)');

%% ── Save figures ──────────────────────────────────────────────────────────
outDir = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end
saveas(fig_A1, fullfile(outDir,'verify_A1_pspectrum_vs_welch.png'));
saveas(fig_A2, fullfile(outDir,'verify_A2_findpeaks_roller.png'));
saveas(fig_A3, fullfile(outDir,'verify_A3_spectrogram.png'));
saveas(fig_A4, fullfile(outDir,'verify_A4_cwt_scalogram.png'));
saveas(fig_B1, fullfile(outDir,'verify_B1_bode_vs_manual.png'));
saveas(fig_B2, fullfile(outDir,'verify_B2_bode_configs.png'));
saveas(fig_B3, fullfile(outDir,'verify_B3_lsim_vs_psd.png'));
saveas(fig_B4, fullfile(outDir,'verify_B4_spa_vs_welch.png'));
saveas(fig_B5, fullfile(outDir,'verify_B5_tf_properties.png'));
fprintf('Figures saved to ./%s/\n', outDir);
