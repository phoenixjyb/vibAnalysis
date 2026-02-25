%% vibration_analysis.m
% Frequency-domain analysis of omni-wheel chassis Z-axis vibration
% Data: 6 CSV files at speeds 0.2–1.2 m/s, ~26820 Hz sample rate
%
% Usage: run from the vibAnalysis project root directory

clear; clc; close all;

%% ── Configuration ────────────────────────────────────────────────────────
dataDir = 'recomoProto1-190-logs-acc-diff-speeds';

files = {
    '0001_202602251145_0d2.csv', 0.2;
    '0001_202602251147_0d4.csv', 0.4;
    '0001_202602251148_0d6.csv', 0.6;
    '0001_202602251149_0d8.csv', 0.8;
    '0001_202602251150_1d0.csv', 1.0;
    '0001_202602251151_1d2.csv', 1.2;
};

% Wheel geometry
wheelDiameter_in = 5;
wheelDiameter_m  = wheelDiameter_in * 0.0254;   % 0.127 m
wheelCirc        = pi * wheelDiameter_m;          % ~0.3990 m

speeds  = cell2mat(files(:,2));
nSpeeds = numel(speeds);
colors  = lines(nSpeeds);
legendLabels = arrayfun(@(v) sprintf('%.1f m/s', v), speeds, 'UniformOutput', false);

%% ── Load data ────────────────────────────────────────────────────────────
fprintf('Loading data...\n');
accZ = cell(nSpeeds, 1);
Fs   = zeros(nSpeeds, 1);

for i = 1:nSpeeds
    fpath = fullfile(dataDir, files{i,1});
    fid   = fopen(fpath, 'r', 'n', 'UTF-8');
    fgetl(fid);   % skip Chinese header line
    % Columns: timestamp(str)  X(g)  Y(g)  Z(g)  Fs_declared(Hz)
    raw = textscan(fid, '%s %f %f %f %f', 'Delimiter', ',', 'CollectOutput', false);
    fclose(fid);
    accZ{i} = raw{4};           % Z acceleration (g)

    % Compute true Fs from first and last timestamp (mm:ss.mmm.uuu format).
    % The declared column-5 value is ~26820 Hz but timestamps show 37 µs steps
    % → 27027 Hz. Parse timestamps to get ground-truth sample rate.
    ts = raw{1};
    t_us = @(s) parseTimestamp_us(s);
    t1   = t_us(ts{1});
    t2   = t_us(ts{end});
    N    = numel(ts);
    Fs(i) = (N - 1) / ((t2 - t1) * 1e-6);   % Hz from first/last timestamp

    Fs_declared = raw{5}(1);
    fprintf('  [%d/%d] %s  →  %d samples | Fs declared=%.0f Hz, Fs from timestamps=%.1f Hz\n', ...
        i, nSpeeds, files{i,1}, N, Fs_declared, Fs(i));
end
fprintf('Done.\n\n');

%% ── Theoretical frequency table ──────────────────────────────────────────
rollerCounts = [8, 10, 12];
fprintf('Wheel diameter: %.4f m  |  Circumference: %.4f m\n\n', wheelDiameter_m, wheelCirc);
fprintf('%-10s  %-12s', 'Speed(m/s)', 'f_wheel(Hz)');
for nc = rollerCounts
    fprintf('  f_roller(N=%d)(Hz)', nc);
end
fprintf('\n%s\n', repmat('-',1,65));
for i = 1:nSpeeds
    fw = speeds(i) / wheelCirc;
    fprintf('%-10.1f  %-12.3f', speeds(i), fw);
    for nc = rollerCounts
        fprintf('  %18.3f', nc * fw);
    end
    fprintf('\n');
end
fprintf('\n');

%% ── RMS summary ──────────────────────────────────────────────────────────
fprintf('%-10s  %-12s  %-12s\n', 'Speed(m/s)', 'RMS_Z(g)', 'Peak_Z(g)');
fprintf('%s\n', repmat('-',1,38));
for i = 1:nSpeeds
    z = detrend(accZ{i}, 'constant');
    fprintf('%-10.1f  %-12.5f  %-12.5f\n', speeds(i), rms(z), max(abs(z)));
end
fprintf('\n');

%% ── Figure 1: Individual FFT spectra ────────────────────────────────────
fig1 = figure('Name', 'Individual FFT – Z Acceleration', ...
    'Position', [50 50 1400 900]);

for i = 1:nSpeeds
    z  = detrend(accZ{i}, 'constant');
    N  = numel(z);
    fs = Fs(i);

    Z    = fft(z);
    freq = (0:N/2-1) * (fs/N);
    mag  = 2 * abs(Z(1:N/2)) / N;    % single-sided amplitude (g)

    subplot(3, 2, i);
    plot(freq, 20*log10(mag + 1e-9), 'Color', colors(i,:), 'LineWidth', 0.7);
    xlim([0 500]);
    ylim([-80 0]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (dB re 1 g)');
    title(sprintf('Speed = %.1f m/s', speeds(i)));
    grid on; grid minor;

    % Annotate wheel rotation frequency
    fw = speeds(i) / wheelCirc;
    xline(fw, 'r--', sprintf('f_w = %.2f Hz', fw), ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right');
end
sgtitle('Single-Sided FFT of Z-Axis Acceleration (per speed)');

%% ── Figure 2: Overlay FFT (two zoom levels) ─────────────────────────────
fig2 = figure('Name', 'Overlay FFT – Z Acceleration', ...
    'Position', [50 50 1400 550]);

xlims = {[0 500], [0 100]};
titles = {'Overlay FFT  (0–500 Hz)', 'Overlay FFT  (0–100 Hz)'};

for col = 1:2
    subplot(1, 2, col);
    hold on;
    for i = 1:nSpeeds
        z  = detrend(accZ{i}, 'constant');
        N  = numel(z);
        fs = Fs(i);
        Z    = fft(z);
        freq = (0:N/2-1) * (fs/N);
        mag  = 2 * abs(Z(1:N/2)) / N;
        plot(freq, 20*log10(mag + 1e-9), 'Color', colors(i,:), ...
            'LineWidth', 0.8, 'DisplayName', legendLabels{i});
    end
    xlim(xlims{col});
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (dB re 1 g)');
    title(titles{col});
    legend('Location', 'northeast');
    grid on; grid minor;
end
sgtitle('FFT Overlay – Z-Axis Acceleration');

%% ── Figure 3: Welch PSD (overlay, two zoom levels) ──────────────────────
% Welch reduces variance via averaging overlapping windowed segments.
% Use window length ~0.5 s → ~13000–14000 samples; 50% overlap.
fig3 = figure('Name', 'Welch PSD – Z Acceleration', ...
    'Position', [50 50 1400 550]);

xlims_psd = {[0 500], [0 100]};
titles_psd = {'Welch PSD  (0–500 Hz)', 'Welch PSD  (0–100 Hz)'};

for col = 1:2
    subplot(1, 2, col);
    hold on;
    for i = 1:nSpeeds
        z    = detrend(accZ{i}, 'constant');
        fs   = Fs(i);
        win  = round(0.5 * fs);   % 0.5-second Hann window
        [pxx, f] = pwelch(z, hann(win), round(win/2), [], fs);
        plot(f, 10*log10(pxx), 'Color', colors(i,:), ...
            'LineWidth', 0.9, 'DisplayName', legendLabels{i});
    end
    xlim(xlims_psd{col});
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz  re g²)');
    title(titles_psd{col});
    legend('Location', 'northeast');
    grid on; grid minor;
end
sgtitle('Welch PSD of Z-Axis Acceleration (50% overlap, 0.5 s Hann window)');

%% ── Figure 4: Waterfall / 3D comparison ─────────────────────────────────
fig4 = figure('Name', 'Waterfall PSD – Speed vs Frequency', ...
    'Position', [50 50 1000 700]);

fMax = 500;   % Hz
hold on;
for i = 1:nSpeeds
    z    = detrend(accZ{i}, 'constant');
    fs   = Fs(i);
    win  = round(0.5 * fs);
    [pxx, f] = pwelch(z, hann(win), round(win/2), [], fs);
    idx  = f <= fMax;
    % Offset each trace by its speed index for waterfall effect
    plot3(f(idx), repmat(speeds(i), sum(idx), 1), 10*log10(pxx(idx)), ...
        'Color', colors(i,:), 'LineWidth', 1.0, 'DisplayName', legendLabels{i});
end
xlabel('Frequency (Hz)');
ylabel('Speed (m/s)');
zlabel('PSD (dB/Hz  re g²)');
title('Waterfall PSD: Z-Axis Vibration vs Speed');
legend('Location', 'northeast');
view(45, 30);
grid on;

%% ── Figure 5: Peak-frequency vs speed scatter ────────────────────────────
fig5 = figure('Name', 'Dominant Frequency vs Speed', ...
    'Position', [50 50 800 500]);

peakFreqs = zeros(nSpeeds, 1);
for i = 1:nSpeeds
    z    = detrend(accZ{i}, 'constant');
    fs   = Fs(i);
    win  = round(0.5 * fs);
    [pxx, f] = pwelch(z, hann(win), round(win/2), [], fs);
    % Search within 10–500 Hz to avoid DC and wheel-rotation harmonics at <5 Hz
    band  = f >= 10 & f <= 500;
    [~, pk] = max(pxx(band));
    fb    = f(band);
    peakFreqs(i) = fb(pk);
end

plot(speeds, peakFreqs, 'ko-', 'LineWidth', 1.5, 'MarkerSize', 8, ...
    'MarkerFaceColor', 'k');
xlabel('Speed (m/s)');
ylabel('Dominant Frequency in 10–500 Hz band (Hz)');
title('Dominant Vibration Frequency vs Travel Speed');
grid on; grid minor;

% Overlay theoretical roller lines for N=8,10,12
hold on;
vLine = linspace(0.1, 1.4, 100);
lineStyles = {'b--', 'g--', 'm--'};
for ni = 1:numel(rollerCounts)
    nc = rollerCounts(ni);
    fRoller = nc * vLine / wheelCirc;
    plot(vLine, fRoller, lineStyles{ni}, 'LineWidth', 1.2, ...
        'DisplayName', sprintf('N=%d rollers theory', nc));
end
legend('Measured peak', 'N=8 theory', 'N=10 theory', 'N=12 theory', ...
    'Location', 'northwest');

fprintf('Dominant frequencies (10–500 Hz band):\n');
fprintf('%-10s  %-15s\n', 'Speed(m/s)', 'Peak freq(Hz)');
fprintf('%s\n', repmat('-', 1, 28));
for i = 1:nSpeeds
    fprintf('%-10.1f  %-15.2f\n', speeds(i), peakFreqs(i));
end

%% ── Save figures ─────────────────────────────────────────────────────────
outDir = 'results';
if ~exist(outDir, 'dir'), mkdir(outDir); end

saveas(fig1, fullfile(outDir, 'fig1_fft_individual.png'));
saveas(fig2, fullfile(outDir, 'fig2_fft_overlay.png'));
saveas(fig3, fullfile(outDir, 'fig3_psd_welch.png'));
saveas(fig4, fullfile(outDir, 'fig4_waterfall.png'));
saveas(fig5, fullfile(outDir, 'fig5_peak_freq_vs_speed.png'));
fprintf('\nFigures saved to ./%s/\n', outDir);

%% ── Helper: parse timestamp string 'mm:ss.mmm.uuu' → microseconds ───────
function us = parseTimestamp_us(str)
    % Format: mm:ss.mmm.uuu  (minutes:seconds.milliseconds.microseconds)
    parts = regexp(str, '^(\d+):(\d+)\.(\d+)\.(\d+)$', 'tokens', 'once');
    mm  = str2double(parts{1});
    ss  = str2double(parts{2});
    ms  = str2double(parts{3});
    uus = str2double(parts{4});
    us  = (mm * 60 + ss) * 1e6 + ms * 1e3 + uus;
end
