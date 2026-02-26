%% multiaxis_analysis.m
% Three-axis (X, Y, Z) vibration analysis of omni-wheel chassis
%
% Extends vibration_analysis.m by loading all three accelerometer axes.
% Provides:
%   Fig 1 – Per-speed 3-axis Welch PSD overlay (0–500 Hz)
%   Fig 2 – Per-speed 3-axis Welch PSD overlay (0–100 Hz zoom)
%   Fig 3 – Per-axis RMS grouped bar chart vs speed
%   Fig 4 – Total vibration magnitude + per-axis variance contribution
%   Fig 5 – Cross-coherence between axis pairs (X-Y, X-Z, Y-Z)
%
% Requires: raw CSV files in recomoProto1-190-logs-acc-diff-speeds/
% Does NOT require vibData.mat (loads raw data directly)

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

speeds       = cell2mat(files(:,2));
nSpeeds      = numel(speeds);
colors       = lines(nSpeeds);
legendLabels = arrayfun(@(v) sprintf('%.1f m/s',v), speeds, 'UniformOutput', false);

Fs           = 27027.0;          % verified true sample rate (37 µs steps)
welch_win_s  = 0.5;              % Welch window length (s)

axLabels = {'X','Y','Z'};
axColors = {[0.0 0.45 0.74], [0.85 0.33 0.10], [0.10 0.10 0.10]};  % blue / red-orange / black

%% ── Load all three axes ──────────────────────────────────────────────────
fprintf('Loading data...\n');
accX = cell(nSpeeds,1);
accY = cell(nSpeeds,1);
accZ = cell(nSpeeds,1);

for i = 1:nSpeeds
    fpath = fullfile(dataDir, files{i,1});
    fid   = fopen(fpath, 'r');
    raw   = textscan(fid, '%s%f%f%f%f', 'Delimiter', ',', ...
                     'HeaderLines', 1, 'CollectOutput', false);
    fclose(fid);
    accX{i} = raw{2};   % column 2 – X acceleration (g)
    accY{i} = raw{3};   % column 3 – Y acceleration (g)
    accZ{i} = raw{4};   % column 4 – Z acceleration (g)
    fprintf('  [%d/%d] %.1f m/s  N=%d samples\n', i, nSpeeds, speeds(i), numel(accZ{i}));
end
fprintf('Done.\n\n');

%% ── RMS & Peak summary table ─────────────────────────────────────────────
rmsX     = zeros(nSpeeds,1);
rmsY     = zeros(nSpeeds,1);
rmsZ     = zeros(nSpeeds,1);
pkX      = zeros(nSpeeds,1);
pkY      = zeros(nSpeeds,1);
pkZ      = zeros(nSpeeds,1);
rmsTotal = zeros(nSpeeds,1);

for i = 1:nSpeeds
    x = detrend(accX{i},'constant');
    y = detrend(accY{i},'constant');
    z = detrend(accZ{i},'constant');
    rmsX(i) = rms(x);  rmsY(i) = rms(y);  rmsZ(i) = rms(z);
    pkX(i)  = max(abs(x));  pkY(i) = max(abs(y));  pkZ(i) = max(abs(z));
    rmsTotal(i) = sqrt(rmsX(i)^2 + rmsY(i)^2 + rmsZ(i)^2);
end

fprintf('%-8s  %-9s  %-9s  %-9s  %-9s  %-9s  %-9s  %-9s  %-14s\n', ...
    'Speed','RMS_X','RMS_Y','RMS_Z','Peak_X','Peak_Y','Peak_Z','RMS_total','Dominant axis');
fprintf('%s\n', repmat('-',1,96));
for i = 1:nSpeeds
    rmsVec  = [rmsX(i), rmsY(i), rmsZ(i)];
    [~,dom] = max(rmsVec);
    fprintf('%-8.1f  %-9.5f  %-9.5f  %-9.5f  %-9.4f  %-9.4f  %-9.4f  %-9.5f  %s\n', ...
        speeds(i), rmsX(i), rmsY(i), rmsZ(i), ...
        pkX(i), pkY(i), pkZ(i), rmsTotal(i), axLabels{dom});
end

fprintf('\nPer-axis variance as %% of total:\n');
fprintf('%-8s  %-10s  %-10s  %-10s\n','Speed','X (%)', 'Y (%)','Z (%)');
fprintf('%s\n', repmat('-',1,44));
for i = 1:nSpeeds
    varFracI = [rmsX(i)^2, rmsY(i)^2, rmsZ(i)^2] / rmsTotal(i)^2 * 100;
    fprintf('%-8.1f  %-10.1f  %-10.1f  %-10.1f\n', speeds(i), varFracI(1), varFracI(2), varFracI(3));
end
fprintf('\n');

%% ── Figure 1: 3-axis PSD per speed  (0–500 Hz) ──────────────────────────
fig1 = figure('Name','3-Axis PSD – 0–500 Hz','Position',[50 50 1400 700]);
win  = round(welch_win_s * Fs);

for i = 1:nSpeeds
    subplot(2,3,i); hold on;
    accAll = {accX{i}, accY{i}, accZ{i}};
    for ax = 1:3
        data     = detrend(accAll{ax},'constant');
        [pxx, f] = pwelch(data, hann(win), round(win/2), [], Fs);
        plot(f, 10*log10(pxx), 'Color', axColors{ax}, 'LineWidth', 0.9, ...
            'DisplayName', axLabels{ax});
    end
    xlim([0 500]); xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz  re g²)');
    title(sprintf('%.1f m/s', speeds(i))); grid on;
    legend('Location','northeast','FontSize',7);
end
sgtitle('3-Axis Welch PSD – X (blue) / Y (orange) / Z (black)  |  0–500 Hz');

%% ── Figure 2: 3-axis PSD per speed  (0–100 Hz zoom) ────────────────────
fig2 = figure('Name','3-Axis PSD – 0–100 Hz','Position',[50 50 1400 700]);

for i = 1:nSpeeds
    subplot(2,3,i); hold on;
    accAll = {accX{i}, accY{i}, accZ{i}};
    for ax = 1:3
        data     = detrend(accAll{ax},'constant');
        [pxx, f] = pwelch(data, hann(win), round(win/2), [], Fs);
        plot(f, 10*log10(pxx), 'Color', axColors{ax}, 'LineWidth', 0.9, ...
            'DisplayName', axLabels{ax});
    end
    xlim([0 100]); xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz  re g²)');
    title(sprintf('%.1f m/s', speeds(i))); grid on;
    legend('Location','northeast','FontSize',7);
end
sgtitle('3-Axis Welch PSD – X (blue) / Y (orange) / Z (black)  |  0–100 Hz');

%% ── Figure 3: Per-axis RMS grouped bar chart ────────────────────────────
fig3 = figure('Name','Per-Axis RMS vs Speed','Position',[50 50 900 500]);

hb = bar(speeds, [rmsX, rmsY, rmsZ], 'grouped');
hb(1).FaceColor = axColors{1};
hb(2).FaceColor = axColors{2};
hb(3).FaceColor = axColors{3};
legend('X','Y','Z','Location','northwest');
xlabel('Speed (m/s)'); ylabel('RMS Acceleration (g)');
title('Per-Axis RMS Acceleration vs Speed');
set(gca,'XTick',speeds);
grid on; grid minor;

%% ── Figure 4: Total vibration magnitude + axis contribution ─────────────
fig4 = figure('Name','Total Vibration Magnitude','Position',[50 50 1200 500]);

subplot(1,2,1);
plot(speeds, rmsTotal, 'ko-',  'LineWidth',1.8, 'MarkerSize',9, 'DisplayName','Total √(X²+Y²+Z²)');
hold on;
plot(speeds, rmsX, '--', 'Color',axColors{1}, 'LineWidth',1.3, 'MarkerSize',7, ...
    'Marker','^', 'DisplayName','X');
plot(speeds, rmsY, '--', 'Color',axColors{2}, 'LineWidth',1.3, 'MarkerSize',7, ...
    'Marker','s', 'DisplayName','Y');
plot(speeds, rmsZ, '--', 'Color',axColors{3}, 'LineWidth',1.3, 'MarkerSize',7, ...
    'Marker','d', 'DisplayName','Z');
xlabel('Speed (m/s)'); ylabel('RMS Acceleration (g)');
title('Total and Per-Axis RMS vs Speed');
legend('Location','northwest'); grid on; grid minor;

subplot(1,2,2);
varFrac = [rmsX.^2, rmsY.^2, rmsZ.^2] ./ rmsTotal.^2 * 100;
h = area(speeds, varFrac);
h(1).FaceColor = axColors{1};
h(2).FaceColor = axColors{2};
h(3).FaceColor = axColors{3};
for k = 1:3, h(k).FaceAlpha = 0.75; end
legend('X','Y','Z','Location','northeast');
xlabel('Speed (m/s)'); ylabel('Contribution to total variance (%)');
title('Per-Axis Variance Fraction of Total');
set(gca,'XTick',speeds); ylim([0 100]); grid on;

sgtitle('Total Vibration Magnitude and Per-Axis Contribution');

%% ── Figure 5: Cross-coherence between axis pairs ────────────────────────
fig5 = figure('Name','Cross-Coherence Between Axes','Position',[50 50 1400 700]);

pairs     = {{'X','Y',1,2}, {'X','Z',1,3}, {'Y','Z',2,3}};
spd_show  = [1, 4, 6];   % 0.2, 0.8, 1.2 m/s — low / mid-high / max speed

nPairs = numel(pairs);
nShow  = numel(spd_show);

for row = 1:nPairs
    pair = pairs{row};
    idxA = pair{3};  idxB = pair{4};
    for col = 1:nShow
        si = spd_show(col);
        accAll = {accX{si}, accY{si}, accZ{si}};
        a = detrend(accAll{idxA},'constant');
        b = detrend(accAll{idxB},'constant');
        [cxy, f] = mscohere(a, b, hann(win), round(win/2), [], Fs);

        subplot(nPairs, nShow, (row-1)*nShow + col);
        plot(f, cxy, 'Color', colors(si,:), 'LineWidth', 0.9);
        hold on;
        yline(0.5, 'k--', 'LineWidth', 0.8);   % significance threshold
        xlim([0 500]); ylim([0 1]);
        xlabel('Frequency (Hz)'); ylabel('Coherence');
        title(sprintf('%s–%s  |  %.1f m/s', pair{1}, pair{2}, speeds(si)));
        grid on;
    end
end
sgtitle('Cross-Coherence (0 = independent axes, 1 = fully coupled)');
annotation('textbox',[0.01 0.01 0.3 0.04],'String', ...
    'Dashed line = 0.5 coherence threshold', ...
    'EdgeColor','none','FontSize',8,'Color',[0.4 0.4 0.4]);

%% ── Save figures ─────────────────────────────────────────────────────────
outDir = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

saveas(fig1, fullfile(outDir,'multi_fig1_3axis_psd_500hz.png'));
saveas(fig2, fullfile(outDir,'multi_fig2_3axis_psd_100hz.png'));
saveas(fig3, fullfile(outDir,'multi_fig3_rms_comparison.png'));
saveas(fig4, fullfile(outDir,'multi_fig4_total_magnitude.png'));
saveas(fig5, fullfile(outDir,'multi_fig5_cross_coherence.png'));
fprintf('Figures saved to ./%s/\n', outDir);
