%% surface_comparison.m
% Multi-surface vibration comparison across 4 terrain types
% Surfaces: indoor-blackFloor, indoor-whiteFloor, outdoor-cement, outdoor-pavement
% Speeds:   0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.5 m/s
% Extends baseline analysis (0.2–1.2 m/s) to 1.5 m/s.
%
% Outputs (saved to results/):
%   surf_fig1 — Z-RMS vs speed, all surfaces
%   surf_fig2 — PSD overlay at 1.5 m/s, all surfaces
%   surf_fig3 — PSD waterfall per surface (all speeds)
%   surf_fig4 — Dominant peak frequency vs speed (verify N=11 & cogging)
%   surf_fig5 — RMS heatmap (surface × speed)

clear; clc;

%% ── Constants ────────────────────────────────────────────────────────────
Fs         = 27027.0;          % true sample rate (Hz)
wheelCirc  = pi * 0.127;       % π × 0.127 m = 0.3990 m
g          = 9.81;             % m/s²
outDir     = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

%% ── Surface definitions ──────────────────────────────────────────────────
surfaces = struct( ...
    'id',   {'black','white','cement','pavement'}, ...
    'label',{'Indoor Black Tile / 室内黑砖', ...
             'Indoor White Tile / 室内白砖', ...
             'Outdoor Cement / 室外水泥路', ...
             'Outdoor Pavement / 室外人行路'}, ...
    'folder',{'testData/MoreTests/indoor-blackFloor', ...
              'testData/MoreTests/indoor-whiteFloor', ...
              'testData/MoreTests/outdoor-cement', ...
              'testData/MoreTests/outdoor-pavement'});
nSurf   = numel(surfaces);
colors  = lines(nSurf);

%% ── Speed list (from filenames) ──────────────────────────────────────────
speedList = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.5];
nSpeeds   = numel(speedList);

%% ── Helper: load one CSV, return Z-accel vector ─────────────────────────
function Z = loadCSV(fpath)
    fid = fopen(fpath, 'r');
    raw = textscan(fid, '%s%f%f%f%f', 'Delimiter', ',', ...
                   'HeaderLines', 1, 'CollectOutput', false);
    fclose(fid);
    Z = raw{4};           % column 4 = Z-axis (g)
    Z = Z(~isnan(Z));
end

%% ── Helper: find CSV for a given surface folder and speed ────────────────
function fpath = findCSV(folder, spd)
    tag   = sprintf('-a-%.1f-', spd);
    files = dir(fullfile(folder, '*.csv'));
    fpath = '';
    for k = 1:numel(files)
        if contains(files(k).name, tag)
            fpath = fullfile(folder, files(k).name);
            return;
        end
    end
end

%% ── Load all data, compute RMS and PSD ──────────────────────────────────
fprintf('Loading data ...\n');
RMS_mat  = nan(nSurf, nSpeeds);      % RMS(g) table
Pxx_cell = cell(nSurf, nSpeeds);     % Welch PSD
f_psd    = [];

for si = 1:nSurf
    for vi = 1:nSpeeds
        fpath = findCSV(surfaces(si).folder, speedList(vi));
        if isempty(fpath)
            fprintf('  MISSING: %s @ %.1f m/s\n', surfaces(si).id, speedList(vi));
            continue;
        end
        Z = loadCSV(fpath);
        RMS_mat(si, vi) = rms(Z);

        % Welch PSD
        nfft = 2^nextpow2(Fs);        % ~1-s segment, ~1 Hz resolution
        [Pxx, f] = pwelch(Z, hann(nfft), nfft/2, nfft, Fs);
        Pxx_cell{si, vi} = Pxx;
        if isempty(f_psd), f_psd = f; end

        fprintf('  Loaded: %-12s %.1f m/s  RMS=%.4f g  N=%d\n', ...
            surfaces(si).id, speedList(vi), RMS_mat(si,vi), numel(Z));
    end
end
fprintf('Done.\n\n');

%% ── Theoretical roller & cogging frequencies ────────────────────────────
% N=11 per-plate roller passage: f = N * v / (sqrt(2) * wheelCirc)
% Motor cogging: ~10.2 events/motor_rev, reducer=37.14
reducerRatio = 37.14;
cog_per_rev  = 10.2;      % events per motor rev (confirmed low-speed)

f_roller11 = @(v) 11 * v / (sqrt(2) * wheelCirc);
f_cogging  = @(v) cog_per_rev * (v / (sqrt(2)*wheelCirc)) * reducerRatio;

fprintf('Expected frequencies at 1.5 m/s:\n');
fprintf('  N=11 roller passage : %.1f Hz\n', f_roller11(1.5));
fprintf('  Motor cogging       : %.1f Hz\n', f_cogging(1.5));
fprintf('\n');

%% ════════════════════════════════════════════════════════════════════════
%% Fig 1 — Z-RMS vs speed, all surfaces
%% ════════════════════════════════════════════════════════════════════════
fig1 = figure('Name','Z-RMS vs Speed — All Surfaces','Position',[50 50 800 500]);
hold on; grid on;
for si = 1:nSurf
    plot(speedList, RMS_mat(si,:), '-o', 'Color', colors(si,:), ...
         'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', surfaces(si).label);
end
xlabel('Chassis Speed (m/s)');
ylabel('Z-Acceleration RMS (g)');
title('Vibration Level vs Speed — 4 Surfaces / 四种地面振动对比');
legend('Location','northwest','FontSize',9);
set(gca,'XTick', speedList, 'FontSize', 11);
xline(1.2, 'k--', 'Previous max 1.2 m/s', 'LabelVerticalAlignment','bottom');
saveas(fig1, fullfile(outDir, 'surf_fig1_rms_vs_speed.png'));
fprintf('Saved surf_fig1\n');

%% ════════════════════════════════════════════════════════════════════════
%% Fig 2 — PSD overlay at 1.5 m/s (new top speed)
%% ════════════════════════════════════════════════════════════════════════
fig2 = figure('Name','PSD at 1.5 m/s — All Surfaces','Position',[50 50 1000 500]);
ax = axes(fig2); hold(ax,'on'); grid(ax,'on');
for si = 1:nSurf
    if ~isempty(Pxx_cell{si, nSpeeds})
        plot(ax, f_psd, 10*log10(Pxx_cell{si,nSpeeds}), ...
             'Color', colors(si,:), 'LineWidth', 1.5, ...
             'DisplayName', surfaces(si).label);
    end
end
% Annotate key frequencies at 1.5 m/s
v15 = 1.5;
xline(ax, f_roller11(v15),  'r--', sprintf('N=11 %.1fHz', f_roller11(v15)), ...
      'LineWidth',1.5,'LabelVerticalAlignment','bottom');
xline(ax, 22*v15/(sqrt(2)*wheelCirc), 'm--', sprintf('N=22 %.1fHz', 22*v15/(sqrt(2)*wheelCirc)), ...
      'LineWidth',1,'LabelVerticalAlignment','bottom');
xline(ax, f_cogging(v15),   'b--', sprintf('Cogging %.0fHz', f_cogging(v15)), ...
      'LineWidth',1,'LabelVerticalAlignment','bottom');
xlim(ax, [0 500]); grid(ax,'on');
xlabel(ax,'Frequency (Hz)'); ylabel(ax,'PSD (dB re g²/Hz)');
title(ax,'PSD at 1.5 m/s — 4 Surfaces / 1.5 m/s 四地面功率谱密度对比');
legend(ax,'Location','northeast','FontSize',9);
set(ax,'FontSize',11);
saveas(fig2, fullfile(outDir, 'surf_fig2_psd_1p5ms.png'));
fprintf('Saved surf_fig2\n');

%% ════════════════════════════════════════════════════════════════════════
%% Fig 3 — PSD waterfall: each surface, all speeds (4-panel)
%% ════════════════════════════════════════════════════════════════════════
fig3 = figure('Name','PSD Waterfall per Surface','Position',[50 50 1400 900]);
speedColors = parula(nSpeeds);
for si = 1:nSurf
    ax = subplot(2, 2, si);
    hold(ax,'on'); grid(ax,'on');
    for vi = 1:nSpeeds
        if ~isempty(Pxx_cell{si,vi})
            plot(ax, f_psd, 10*log10(Pxx_cell{si,vi}), ...
                 'Color', speedColors(vi,:), 'LineWidth', 1.2, ...
                 'DisplayName', sprintf('%.1f m/s', speedList(vi)));
        end
    end
    xlim(ax,[0 500]); grid(ax,'on');
    xlabel(ax,'Frequency (Hz)'); ylabel(ax,'PSD (dB re g²/Hz)');
    title(ax, surfaces(si).label, 'FontSize', 10);
    legend(ax,'Location','northeast','FontSize',7);
    set(ax,'FontSize',9);
end
sgtitle('PSD by Surface & Speed / 各地面各速度功率谱密度', 'FontSize', 13);
saveas(fig3, fullfile(outDir, 'surf_fig3_psd_waterfall.png'));
fprintf('Saved surf_fig3\n');

%% ════════════════════════════════════════════════════════════════════════
%% Fig 4 — Dominant peak frequency vs speed (verify N=11 & cogging)
%% ════════════════════════════════════════════════════════════════════════
fig4 = figure('Name','Dominant Peak Frequency vs Speed','Position',[50 50 900 550]);
ax4 = axes(fig4); hold(ax4,'on'); grid(ax4,'on');

% Theoretical N=11 and cogging lines
vLine = linspace(0.1, 1.6, 100);
plot(ax4, vLine, f_roller11(vLine), 'r-',  'LineWidth', 2, 'DisplayName', 'N=11 theory');
plot(ax4, vLine, f_cogging(vLine),  'b-',  'LineWidth', 2, 'DisplayName', 'Cogging theory');

% Extract dominant peaks from measured data
mkrs = {'o','s','^','d'};
for si = 1:nSurf
    peak_f = nan(1, nSpeeds);
    for vi = 1:nSpeeds
        if isempty(Pxx_cell{si,vi}), continue; end
        Pxx = Pxx_cell{si,vi};
        % Search below 50 Hz for roller peaks, above 50 Hz for cogging
        % Low-speed (<=0.6): dominant is cogging (>50 Hz)
        % High-speed (>=0.8): dominant is roller (<50 Hz)
        if speedList(vi) <= 0.6
            mask = f_psd > 50 & f_psd < 600;
        else
            mask = f_psd > 5  & f_psd < 50;
        end
        [~, idx] = max(Pxx(mask));
        f_sub = f_psd(mask);
        peak_f(vi) = f_sub(idx);
    end
    plot(ax4, speedList, peak_f, mkrs{si}, 'Color', colors(si,:), ...
         'MarkerSize', 10, 'LineWidth', 1.5, 'MarkerFaceColor', colors(si,:), ...
         'DisplayName', surfaces(si).label);
end

xlabel(ax4,'Chassis Speed (m/s)'); ylabel(ax4,'Dominant Peak Frequency (Hz)');
title(ax4,'Peak Frequency vs Speed / 主频率随速度变化（验证 N=11 和齿槽）');
legend(ax4,'Location','northwest','FontSize',9);
set(ax4,'XTick', speedList, 'FontSize',11);
saveas(fig4, fullfile(outDir, 'surf_fig4_peak_freq.png'));
fprintf('Saved surf_fig4\n');

%% ════════════════════════════════════════════════════════════════════════
%% Fig 5 — RMS heatmap (surface × speed)
%% ════════════════════════════════════════════════════════════════════════
fig5 = figure('Name','RMS Heatmap','Position',[50 50 800 350]);
imagesc(RMS_mat);
colorbar; colormap(hot);
set(gca, 'XTick', 1:nSpeeds, 'XTickLabel', arrayfun(@(v) sprintf('%.1f',v), speedList,'UniformOutput',false));
set(gca, 'YTick', 1:nSurf,   'YTickLabel', {'Black Tile','White Tile','Cement','Pavement'});
xlabel('Speed (m/s)'); ylabel('Surface');
title('Z-RMS (g) Heatmap — Surface × Speed / 振动 RMS 热图');
% Annotate cells
for si = 1:nSurf
    for vi = 1:nSpeeds
        if ~isnan(RMS_mat(si,vi))
            text(vi, si, sprintf('%.3f', RMS_mat(si,vi)), ...
                 'HorizontalAlignment','center','Color','white','FontSize',8,'FontWeight','bold');
        end
    end
end
saveas(fig5, fullfile(outDir, 'surf_fig5_rms_heatmap.png'));
fprintf('Saved surf_fig5\n');

%% ── Print summary table ──────────────────────────────────────────────────
fprintf('\n══ Z-RMS Summary (g) ══\n');
fprintf('%-16s', 'Surface');
for vi = 1:nSpeeds, fprintf('%7.1fm/s', speedList(vi)); end
fprintf('\n%s\n', repmat('-',1,16+nSpeeds*9));
surfShort = {'BlackTile','WhiteTile','Cement','Pavement'};
for si = 1:nSurf
    fprintf('%-16s', surfShort{si});
    for vi = 1:nSpeeds
        if isnan(RMS_mat(si,vi)), fprintf('%9s','—');
        else, fprintf('%9.4f', RMS_mat(si,vi)); end
    end
    fprintf('\n');
end

fprintf('\nExpected frequencies at 1.5 m/s:\n');
fprintf('  N=11 roller passage : %.2f Hz\n', f_roller11(1.5));
fprintf('  N=22 (staggered)    : %.2f Hz\n', 22*1.5/(sqrt(2)*wheelCirc));
fprintf('  Motor cogging       : %.1f Hz\n', f_cogging(1.5));
fprintf('\nDone — figures saved to %s/\n', outDir);
