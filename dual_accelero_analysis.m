%% dual_accelero_analysis.m
% Dual-accelerometer analysis: chassis (a) vs end-effector (b)
% Sensor a: chassis, same position as previous tests
% Sensor b: end-effector, X-axis pointing BACKWARDS (X_corrected = -X_raw)
%
% Data: testData/TestsDualAccelero/
% Files matched by speed + surface (not timestamp — some pairs differ by 1 min)
% Output: results/dual_fig*.png, dualAccelData.mat

clear; clc;
Fs       = 27027.0;           % true sample rate (Hz) — ignore CSV column 5
dataDir  = 'testData/TestsDualAccelero';
outDir   = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

% -----------------------------------------------------------------------
% 1. DISCOVER AND MATCH FILE PAIRS
% -----------------------------------------------------------------------
files = dir(fullfile(dataDir,'*.csv'));
fnames = {files.name};

% Parse each filename: extract sensor(a/b), speed, surface
n = numel(fnames);
info = struct('name',{},'sensor',{},'speed',{},'surface',{});
for i = 1:n
    nm = fnames{i};
    % Pattern: 0001_YYYYMMDDHHHMM-[a|b]-SPEED-SURFACE.csv
    tok = regexp(nm, '\d{4}_\d{12}-([ab])-([\d.]+)-(.+)\.csv', 'tokens');
    if isempty(tok), continue; end
    tok = tok{1};
    info(end+1).name    = nm;
    info(end).sensor    = tok{1};
    info(end).speed     = str2double(tok{2});
    info(end).surface   = tok{3};
end

% Unique surfaces and speeds
surfaces = unique({info.surface});
speeds   = unique([info.speed]);

nSurf  = numel(surfaces);
nSpd   = numel(speeds);

fprintf('Found %d files across %d surfaces, %d speeds\n', numel(info), nSurf, nSpd);
fprintf('Surfaces: %s\n', strjoin(surfaces, ' | '));
fprintf('Speeds:   '); fprintf('%.1f ', speeds); fprintf('m/s\n\n');

% Surface display names (short English labels)
surfLabel = containers.Map(...
    {'室内黑砖','室内白砖','室外人行道','室外水泥路'}, ...
    {'Indoor Black','Indoor White','Pavement','Cement'});
surfShort = containers.Map(...
    {'室内黑砖','室内白砖','室外人行道','室外水泥路'}, ...
    {'BlkTile','WhtTile','Pavemnt','Cement'});

% -----------------------------------------------------------------------
% 2. DATA LOADING FUNCTION (nested)
% -----------------------------------------------------------------------
function [t, X, Y, Z] = loadCSV(fpath)
    fid = fopen(fpath, 'r');
    raw = textscan(fid, '%s%f%f%f%f', 'Delimiter', ',', ...
                   'HeaderLines', 1, 'CollectOutput', false);
    fclose(fid);
    t = (0:numel(raw{2})-1)';   % sample index (use Fs externally)
    X = raw{2};
    Y = raw{3};
    Z = raw{4};
end

% -----------------------------------------------------------------------
% 3. WELCH PSD HELPER
% -----------------------------------------------------------------------
function [f, psd] = welchPSD(sig, Fs)
    Nfft  = min(2^nextpow2(length(sig)/8), 2^17);
    novlp = round(Nfft * 0.5);
    win   = hann(Nfft);
    [psd, f] = pwelch(sig - mean(sig), win, novlp, Nfft, Fs);
end

% -----------------------------------------------------------------------
% 4. MAIN ANALYSIS LOOP
% -----------------------------------------------------------------------
% Storage arrays (nSurf × nSpd)
rms_a_X = nan(nSurf,nSpd);  rms_b_X = nan(nSurf,nSpd);
rms_a_Y = nan(nSurf,nSpd);  rms_b_Y = nan(nSurf,nSpd);
rms_a_Z = nan(nSurf,nSpd);  rms_b_Z = nan(nSurf,nSpd);
rms_b_tot = nan(nSurf,nSpd); rms_a_tot = nan(nSurf,nSpd);

% Store PSDs for plotting (cell arrays)
psd_a_Z = cell(nSurf,nSpd);
psd_b_Z = cell(nSurf,nSpd);
psd_f   = cell(nSurf,nSpd);
T_struct = cell(nSurf,nSpd);  % structural transmissibility sqrt(PSD_b/PSD_a)

for si = 1:nSurf
    surf = surfaces{si};
    for vi = 1:nSpd
        spd = speeds(vi);

        % Find matching a and b files
        idxA = find(strcmp({info.sensor},'a') & ...
                    strcmp({info.surface},surf) & ...
                    [info.speed] == spd);
        idxB = find(strcmp({info.sensor},'b') & ...
                    strcmp({info.surface},surf) & ...
                    [info.speed] == spd);

        if isempty(idxA) || isempty(idxB)
            fprintf('  MISSING pair: %s %.1f m/s\n', surf, spd);
            continue;
        end

        fpathA = fullfile(dataDir, info(idxA(1)).name);
        fpathB = fullfile(dataDir, info(idxB(1)).name);

        [~, Xa, Ya, Za] = loadCSV(fpathA);
        [~, Xb, Yb, Zb] = loadCSV(fpathB);

        % Correct end-effector X direction (X points backwards → invert)
        Xb = -Xb;

        % Use shortest common length (in case files differ slightly)
        N = min([length(Za), length(Zb)]);
        Za = Za(1:N); Xa = Xa(1:N); Ya = Ya(1:N);
        Zb = Zb(1:N); Xb = Xb(1:N); Yb = Yb(1:N);

        % Remove gravity component (DC offset)
        Za = Za - mean(Za);  Xa = Xa - mean(Xa);  Ya = Ya - mean(Ya);
        Zb = Zb - mean(Zb);  Xb = Xb - mean(Xb);  Yb = Yb - mean(Yb);

        % RMS
        rms_a_Z(si,vi) = rms(Za);  rms_b_Z(si,vi) = rms(Zb);
        rms_a_X(si,vi) = rms(Xa);  rms_b_X(si,vi) = rms(Xb);
        rms_a_Y(si,vi) = rms(Ya);  rms_b_Y(si,vi) = rms(Yb);
        rms_a_tot(si,vi) = sqrt(rms(Za)^2 + rms(Xa)^2 + rms(Ya)^2);
        rms_b_tot(si,vi) = sqrt(rms(Zb)^2 + rms(Xb)^2 + rms(Yb)^2);

        % Welch PSD (Z-axis — vertical, primary vibration direction)
        [fa, pA] = welchPSD(Za, Fs);
        [~,  pB] = welchPSD(Zb, Fs);

        psd_a_Z{si,vi} = pA;
        psd_b_Z{si,vi} = pB;
        psd_f{si,vi}   = fa;

        % Structural transmissibility T(f) = sqrt(PSD_ee / PSD_chassis)
        % Smooth slightly to reduce noise ratio
        smooth_win = 5;
        pA_sm = movmean(pA, smooth_win);
        pB_sm = movmean(pB, smooth_win);
        T_struct{si,vi} = sqrt(max(pB_sm,0) ./ max(pA_sm, 1e-12));
    end
    fprintf('Processed surface: %s\n', surfLabel(surf));
end

% -----------------------------------------------------------------------
% 5. FIGURE 1 — Z-axis RMS: chassis vs end-effector, all surfaces/speeds
% -----------------------------------------------------------------------
fig1 = figure('Position',[50 50 1400 800]);
for si = 1:nSurf
    subplot(2,2,si);
    bar_data = [rms_a_Z(si,:)', rms_b_Z(si,:)'];
    b = bar(speeds, bar_data, 'grouped');
    b(1).FaceColor = [0.25 0.45 0.75];   % chassis — blue
    b(2).FaceColor = [0.85 0.33 0.10];   % end-effector — orange
    xlabel('Chassis speed (m/s)');
    ylabel('Z-axis RMS (g)');
    title(sprintf('%s — Chassis vs End-Effector Z-RMS', surfLabel(surfaces{si})));
    legend({'Chassis (a)','End-Effector (b)'},'Location','northwest');
    grid on; set(gca,'FontSize',10);
end
sgtitle('Fig 1: Z-axis RMS — Chassis vs End-Effector (all surfaces)', 'FontSize',13,'FontWeight','bold');
saveas(fig1, fullfile(outDir,'dual_fig1_rms_comparison.png'));

% -----------------------------------------------------------------------
% 6. FIGURE 2 — PSD overlay (chassis vs EE) per surface, 4 key speeds
% -----------------------------------------------------------------------
key_speeds = [0.4 0.8 1.2 1.5];
colors_spd = lines(numel(key_speeds));
fig2 = figure('Position',[50 50 1400 900]);

for si = 1:nSurf
    ax = subplot(2,2,si);
    hold on;
    legEntries = {};
    for ki = 1:numel(key_speeds)
        kspd = key_speeds(ki);
        vi = find(speeds == kspd);
        if isempty(vi) || isempty(psd_a_Z{si,vi}), continue; end
        f  = psd_f{si,vi};
        pA = psd_a_Z{si,vi};
        pB = psd_b_Z{si,vi};
        mask = f <= 500;
        plot(f(mask), 10*log10(pA(mask)), '-',  'Color', colors_spd(ki,:), 'LineWidth',1.2);
        plot(f(mask), 10*log10(pB(mask)), '--', 'Color', colors_spd(ki,:), 'LineWidth',1.0);
        legEntries{end+1} = sprintf('%.1fm/s Chassis', kspd);
        legEntries{end+1} = sprintf('%.1fm/s EE',      kspd);
    end
    xlabel('Frequency (Hz)'); ylabel('PSD (dB re g²/Hz)');
    title(surfLabel(surfaces{si}));
    legend(legEntries, 'Location','northeast','FontSize',7,'NumColumns',2);
    grid on; xlim([0 500]); set(gca,'FontSize',9);

    % Mark N=11 frequencies
    wheelCirc = 0.399;
    for vi_mark = 1:nSpd
        f11 = 11 * speeds(vi_mark) / (sqrt(2) * wheelCirc);
        if f11 <= 500
            xline(ax, f11, ':', 'Color',[0.5 0.5 0.5],'LineWidth',0.8);
        end
    end
end
sgtitle('Fig 2: Z-axis PSD — Chassis (solid) vs End-Effector (dashed)', 'FontSize',13,'FontWeight','bold');
saveas(fig2, fullfile(outDir,'dual_fig2_psd_overlay.png'));

% -----------------------------------------------------------------------
% 7. FIGURE 3 — Structural transmissibility T(f) = sqrt(PSD_ee/PSD_chassis)
% -----------------------------------------------------------------------
fig3 = figure('Position',[50 50 1400 900]);
for si = 1:nSurf
    ax = subplot(2,2,si);
    hold on;
    legEntries = {};
    for ki = 1:numel(key_speeds)
        kspd = key_speeds(ki);
        vi = find(speeds == kspd);
        if isempty(vi) || isempty(T_struct{si,vi}), continue; end
        f = psd_f{si,vi};
        T = T_struct{si,vi};
        mask = f <= 500;
        plot(f(mask), T(mask), '-', 'Color', colors_spd(ki,:), 'LineWidth',1.3);
        legEntries{end+1} = sprintf('%.1f m/s', kspd);
    end
    yline(1.0, 'k--', 'LineWidth',1.2);   % T=1 reference
    yline(2.0, 'r:', 'LineWidth',1.0);    % T=2 warning level
    xlabel('Frequency (Hz)'); ylabel('Transmissibility T(f)');
    title(sprintf('%s — Arm structural T(f)', surfLabel(surfaces{si})));
    legend([legEntries, {'T=1 (no change)','T=2 warning'}], ...
           'Location','northeast','FontSize',8);
    grid on; xlim([0 500]); ylim([0 5]);
    set(gca,'FontSize',9);
end
sgtitle('Fig 3: Arm Structural Transmissibility — End-Effector / Chassis', ...
    'FontSize',13,'FontWeight','bold');
saveas(fig3, fullfile(outDir,'dual_fig3_transmissibility.png'));

% -----------------------------------------------------------------------
% 8. FIGURE 4 — 3-axis RMS: chassis vs EE for indoor white tile
% (representative clean surface)
% -----------------------------------------------------------------------
si_ref = find(strcmp(surfaces,'室内白砖'));
if isempty(si_ref), si_ref = 1; end  % fallback

fig4 = figure('Position',[50 50 1000 700]);
axes_labels = {'X (fwd/bkwd)','Y (lateral)','Z (vertical)'};
rms_data_a = [rms_a_X(si_ref,:); rms_a_Y(si_ref,:); rms_a_Z(si_ref,:)];
rms_data_b = [rms_b_X(si_ref,:); rms_b_Y(si_ref,:); rms_b_Z(si_ref,:)];

for ax_i = 1:3
    subplot(1,3,ax_i);
    bar(speeds, [rms_data_a(ax_i,:)', rms_data_b(ax_i,:)'], 'grouped');
    xlabel('Speed (m/s)'); ylabel('RMS (g)');
    title(axes_labels{ax_i});
    legend({'Chassis','End-Effector'},'Location','northwest');
    grid on; set(gca,'FontSize',10);
end
sgtitle(sprintf('Fig 4: 3-axis RMS — %s (Indoor White Tile)', 'Chassis vs End-Effector'), ...
    'FontSize',12,'FontWeight','bold');
saveas(fig4, fullfile(outDir,'dual_fig4_3axis_rms.png'));

% -----------------------------------------------------------------------
% 9. FIGURE 5 — RMS amplification ratio EE/Chassis (Z-axis heatmap)
% -----------------------------------------------------------------------
ratio_Z = rms_b_Z ./ rms_a_Z;  % > 1 means arm amplifies, < 1 means attenuates

fig5 = figure('Position',[50 50 900 550]);
surf_labels_short = cellfun(@(s) surfLabel(s), surfaces, 'UniformOutput', false);
imagesc(speeds, 1:nSurf, ratio_Z);
colormap(gca, cool(256));
colorbar;
set(gca, 'YTick', 1:nSurf, 'YTickLabel', surf_labels_short);
xlabel('Chassis speed (m/s)');
title('Fig 5: Z-axis RMS ratio — End-Effector / Chassis');
clim_val = max(abs(ratio_Z(~isnan(ratio_Z))));
clim([0 max(clim_val, 2)]);
% Add text labels
for si = 1:nSurf
    for vi = 1:nSpd
        if ~isnan(ratio_Z(si,vi))
            text(speeds(vi), si, sprintf('%.2f', ratio_Z(si,vi)), ...
                'HorizontalAlignment','center','FontSize',8,'Color','k');
        end
    end
end
saveas(fig5, fullfile(outDir,'dual_fig5_ratio_heatmap.png'));

% -----------------------------------------------------------------------
% 10. PRINT SUMMARY TABLES
% -----------------------------------------------------------------------
fprintf('\n========================================================\n');
fprintf('TABLE 1: Z-axis RMS (g) — Chassis (a) vs End-Effector (b)\n');
fprintf('========================================================\n');
for si = 1:nSurf
    fprintf('\nSurface: %s\n', surfLabel(surfaces{si}));
    fprintf('Speed   Chassis  EE      Ratio(EE/Ch)\n');
    for vi = 1:nSpd
        if ~isnan(rms_a_Z(si,vi))
            fprintf('%.1f m/s  %.4f   %.4f   %.2f\n', speeds(vi), ...
                rms_a_Z(si,vi), rms_b_Z(si,vi), ratio_Z(si,vi));
        end
    end
end

fprintf('\n========================================================\n');
fprintf('TABLE 2: Total RMS (g) = sqrt(X²+Y²+Z²)\n');
fprintf('========================================================\n');
for si = 1:nSurf
    fprintf('\nSurface: %s\n', surfLabel(surfaces{si}));
    fprintf('Speed   Chassis  EE      Ratio\n');
    for vi = 1:nSpd
        if ~isnan(rms_a_tot(si,vi))
            fprintf('%.1f m/s  %.4f   %.4f   %.2f\n', speeds(vi), ...
                rms_a_tot(si,vi), rms_b_tot(si,vi), ...
                rms_b_tot(si,vi)/rms_a_tot(si,vi));
        end
    end
end

% -----------------------------------------------------------------------
% 11. SAVE DATA
% -----------------------------------------------------------------------
save(fullfile(outDir,'dualAccelData.mat'), ...
    'speeds','surfaces','surfLabel', ...
    'rms_a_X','rms_a_Y','rms_a_Z','rms_a_tot', ...
    'rms_b_X','rms_b_Y','rms_b_Z','rms_b_tot', ...
    'ratio_Z', 'psd_a_Z','psd_b_Z','psd_f','T_struct');

fprintf('\nAnalysis complete. Results saved to results/dual_fig*.png and results/dualAccelData.mat\n');
