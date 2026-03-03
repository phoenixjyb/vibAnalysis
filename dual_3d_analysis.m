%% dual_3d_analysis.m
% Full 3-axis (X/Y/Z) dual-accelerometer analysis: chassis (a) vs end-effector (b)
% Adapts multiaxis_analysis.m patterns to dual-sensor paired data.
%
% End-effector mounting note: X-axis points BACKWARDS → X_b_corrected = -X_raw
% (sign inversion; does not affect PSD, coherence, or RMS magnitudes)
%
% Figures saved to results/dual3d_fig*.png
%   Fig 1  – Per-axis RMS (X/Y/Z) — chassis vs EE, 4 subplots (one per surface)
%   Fig 2  – Axis variance fraction (% of total) — chassis vs EE
%   Fig 3  – Per-axis structural transmissibility T_X/Y/Z(f) — 4 surfaces
%   Fig 4  – 3-axis PSD overlay (solid=chassis, dashed=EE) — indoor white tile
%   Fig 5  – Cross-coherence chassis↔EE per axis — indoor white, 4 speeds
%   Fig 6  – Low-frequency zoom (0–30 Hz) — arm resonance region, all surfaces

clear; clc;
Fs      = 27027.0;
dataDir = 'testData/TestsDualAccelero';
outDir  = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

welch_win_s = 0.5;                      % Welch window length (s)
win         = round(welch_win_s * Fs);
novlp       = round(win/2);

axLabels = {'X','Y','Z'};
% Chassis: blue / orange / black.  EE same hue but lighter / dashed
axColors_ch = {[0.00 0.45 0.74], [0.85 0.33 0.10], [0.15 0.15 0.15]};
axColors_ee = {[0.40 0.75 1.00], [1.00 0.65 0.40], [0.55 0.55 0.55]};

surfLabel = containers.Map(...
    {'室内黑砖','室内白砖','室外人行道','室外水泥路'}, ...
    {'Indoor Black','Indoor White','Pavement','Cement'});

%% ── 1. DISCOVER & MATCH FILE PAIRS ──────────────────────────────────────
files  = dir(fullfile(dataDir,'*.csv'));
fnames = {files.name};
info   = struct('name',{},'sensor',{},'speed',{},'surface',{});
for i = 1:numel(fnames)
    tok = regexp(fnames{i}, '\d{4}_\d{12}-([ab])-([\d.]+)-(.+)\.csv','tokens');
    if isempty(tok), continue; end
    tok = tok{1};
    info(end+1).name    = fnames{i};
    info(end).sensor    = tok{1};
    info(end).speed     = str2double(tok{2});
    info(end).surface   = tok{3};
end
surfaces = unique({info.surface});
speeds   = sort(unique([info.speed]));
nSurf    = numel(surfaces);  nSpd = numel(speeds);
fprintf('Matched data: %d surfaces, %d speeds\n', nSurf, nSpd);

%% ── 2. LOAD ALL DATA ──────────────────────────────────────────────────────
% Storage: {nSurf × nSpd} cell arrays of column vectors
Xa = cell(nSurf,nSpd);  Ya = cell(nSurf,nSpd);  Za = cell(nSurf,nSpd);
Xb = cell(nSurf,nSpd);  Yb = cell(nSurf,nSpd);  Zb = cell(nSurf,nSpd);

for si = 1:nSurf
    for vi = 1:nSpd
        surf = surfaces{si};  spd = speeds(vi);
        iA = find(strcmp({info.sensor},'a') & strcmp({info.surface},surf) & [info.speed]==spd);
        iB = find(strcmp({info.sensor},'b') & strcmp({info.surface},surf) & [info.speed]==spd);
        if isempty(iA)||isempty(iB), continue; end

        [xa,ya,za] = loadAndClean(fullfile(dataDir, info(iA(1)).name));
        [xb,yb,zb] = loadAndClean(fullfile(dataDir, info(iB(1)).name));
        xb = -xb;   % correct EE X orientation

        N = min([numel(za),numel(zb)]);
        Xa{si,vi}=xa(1:N); Ya{si,vi}=ya(1:N); Za{si,vi}=za(1:N);
        Xb{si,vi}=xb(1:N); Yb{si,vi}=yb(1:N); Zb{si,vi}=zb(1:N);
    end
    fprintf('  Loaded: %s\n', surfLabel(surfaces{si}));
end

%% ── 3. COMPUTE RMS & VARIANCE FRACTION ──────────────────────────────────
rms_a = zeros(nSurf,nSpd,3);   % (surf, spd, axis)  axis: 1=X 2=Y 3=Z
rms_b = zeros(nSurf,nSpd,3);
tot_a = zeros(nSurf,nSpd);
tot_b = zeros(nSurf,nSpd);

for si=1:nSurf; for vi=1:nSpd
    if isempty(Za{si,vi}), continue; end
    rms_a(si,vi,:) = [rms(Xa{si,vi}), rms(Ya{si,vi}), rms(Za{si,vi})];
    rms_b(si,vi,:) = [rms(Xb{si,vi}), rms(Yb{si,vi}), rms(Zb{si,vi})];
    tot_a(si,vi) = norm(squeeze(rms_a(si,vi,:)));
    tot_b(si,vi) = norm(squeeze(rms_b(si,vi,:)));
end; end

%% ── PRINT TABLE ──────────────────────────────────────────────────────────
fprintf('\n===== 3-AXIS RMS TABLE (g) =====\n');
for si=1:nSurf
    fprintf('\nSurface: %s\n', surfLabel(surfaces{si}));
    fprintf('Speed   Ch_X    Ch_Y    Ch_Z    EE_X    EE_Y    EE_Z    Ch_tot  EE_tot  EE/Ch\n');
    for vi=1:nSpd
        if tot_a(si,vi)==0, continue; end
        fprintf('%.1fm/s  %.4f  %.4f  %.4f  %.4f  %.4f  %.4f  %.4f  %.4f  %.2f\n', ...
            speeds(vi), rms_a(si,vi,1),rms_a(si,vi,2),rms_a(si,vi,3), ...
            rms_b(si,vi,1),rms_b(si,vi,2),rms_b(si,vi,3), tot_a(si,vi),tot_b(si,vi), ...
            tot_b(si,vi)/tot_a(si,vi));
    end
end

%% ── 4. FIGURE 1: Per-axis RMS — chassis vs EE, 4 surfaces ──────────────
fig1 = figure('Position',[30 30 1400 900]);
for si=1:nSurf
    ax=subplot(2,2,si); hold on;
    % Group bars: [ch_X ch_Y ch_Z ee_X ee_Y ee_Z] per speed
    ch_data = squeeze(rms_a(si,:,:));   % (nSpd × 3)
    ee_data = squeeze(rms_b(si,:,:));
    b = bar(speeds, [ch_data, ee_data],'grouped');
    cmap = [axColors_ch{:}; axColors_ee{:}];  % 6×3
    cols = [cell2mat(axColors_ch'); cell2mat(axColors_ee')];
    for k=1:6, b(k).FaceColor=cols(k,:); end
    xlabel('Speed (m/s)'); ylabel('RMS (g)');
    title(surfLabel(surfaces{si}));
    legend({'Ch-X','Ch-Y','Ch-Z','EE-X','EE-Y','EE-Z'},'Location','northwest','FontSize',7,'NumColumns',2);
    grid on; set(gca,'FontSize',9);
end
sgtitle('Fig 1: Per-axis RMS — Chassis (dark) vs End-Effector (light)','FontSize',12,'FontWeight','bold');
saveas(fig1, fullfile(outDir,'dual3d_fig1_peraxis_rms.png'));

%% ── 5. FIGURE 2: Variance fraction (%) — chassis vs EE ─────────────────
fig2 = figure('Position',[30 30 1400 700]);
for si=1:nSurf
    % Chassis
    subplot(2,4, si);
    vf = squeeze(rms_a(si,:,:)).^2 ./ tot_a(si,:)'.^2 * 100;
    ha = area(speeds, vf);
    ha(1).FaceColor=axColors_ch{1}; ha(2).FaceColor=axColors_ch{2}; ha(3).FaceColor=axColors_ch{3};
    for k=1:3, ha(k).FaceAlpha=0.8; end
    xlabel('Speed (m/s)'); ylabel('Variance %'); ylim([0 100]);
    title(sprintf('%s — Chassis', surfLabel(surfaces{si})));
    legend('X','Y','Z','Location','northeast','FontSize',7);
    grid on; set(gca,'FontSize',8);

    % End-effector
    subplot(2,4, si+4);
    vf = squeeze(rms_b(si,:,:)).^2 ./ tot_b(si,:)'.^2 * 100;
    he = area(speeds, vf);
    he(1).FaceColor=axColors_ee{1}; he(2).FaceColor=axColors_ee{2}; he(3).FaceColor=axColors_ee{3};
    for k=1:3, he(k).FaceAlpha=0.8; end
    xlabel('Speed (m/s)'); ylabel('Variance %'); ylim([0 100]);
    title(sprintf('%s — End-Effector', surfLabel(surfaces{si})));
    legend('X','Y','Z','Location','northeast','FontSize',7);
    grid on; set(gca,'FontSize',8);
end
sgtitle('Fig 2: Axis variance fraction (%) — Chassis (top) vs End-Effector (bottom)','FontSize',12,'FontWeight','bold');
saveas(fig2, fullfile(outDir,'dual3d_fig2_variance_fraction.png'));

%% ── 6. FIGURE 3: Per-axis structural transmissibility T_X/Y/Z(f) ────────
key_speeds_idx = [2 4 5 7];   % 0.4, 0.8, 1.0, 1.5 m/s
speed_cols = lines(numel(key_speeds_idx));
smooth_w   = 7;

fig3 = figure('Position',[30 30 1400 900]);
ax_titles = {'T_X(f)','T_Y(f)','T_Z(f)'};
for si=1:nSurf
    for axi=1:3   % axis
        spi = (si-1)*3 + axi;
        subplot(nSurf, 3, spi); hold on;
        yline(1,'k--','LineWidth',1.1);
        yline(2,'r:','LineWidth',0.9);
        legStr = {};
        for ki=1:numel(key_speeds_idx)
            vi = key_speeds_idx(ki);
            if isempty(Za{si,vi}), continue; end
            switch axi
                case 1, cha=Xa{si,vi}; eea=Xb{si,vi};
                case 2, cha=Ya{si,vi}; eea=Yb{si,vi};
                case 3, cha=Za{si,vi}; eea=Zb{si,vi};
            end
            [f,pA] = deal([]); [pA,f] = pwelch(cha,hann(win),novlp,[],Fs);
            pB     = pwelch(eea,hann(win),novlp,[],Fs);
            Tf     = sqrt(movmean(pB,smooth_w) ./ max(movmean(pA,smooth_w),1e-12));
            mask   = f<=300;
            plot(f(mask), Tf(mask), 'Color',speed_cols(ki,:), 'LineWidth',1.2);
            legStr{end+1} = sprintf('%.1f m/s',speeds(vi));
        end
        ylim([0 6]); xlim([0 300]);
        xlabel('Hz'); ylabel('T(f)');
        if si==1, title(ax_titles{axi}); end
        if axi==1, ylabel(sprintf('%s\nT(f)', surfLabel(surfaces{si}))); end
        if si==1 && axi==3
            legend([legStr, {'T=1','T=2'}],'Location','northeast','FontSize',7);
        end
        grid on; set(gca,'FontSize',8);
    end
end
sgtitle('Fig 3: Per-axis structural transmissibility EE/Chassis — T_X, T_Y, T_Z (0–300 Hz)','FontSize',11,'FontWeight','bold');
saveas(fig3, fullfile(outDir,'dual3d_fig3_peraxis_transmissibility.png'));

%% ── 7. FIGURE 4: 3-axis PSD overlay — indoor white tile ─────────────────
si_ref = find(strcmp(surfaces,'室内白砖')); if isempty(si_ref), si_ref=1; end
show_vi = [2 4 5 7];   % 0.4, 0.8, 1.0, 1.5 m/s
fig4 = figure('Position',[30 30 1400 900]);
for ki=1:numel(show_vi)
    vi = show_vi(ki);
    if isempty(Za{si_ref,vi}), continue; end
    subplot(2,2,ki); hold on;
    allCh = {Xa{si_ref,vi}, Ya{si_ref,vi}, Za{si_ref,vi}};
    allEE = {Xb{si_ref,vi}, Yb{si_ref,vi}, Zb{si_ref,vi}};
    for axi=1:3
        [pA,f] = pwelch(allCh{axi},hann(win),novlp,[],Fs);
        pB     = pwelch(allEE{axi},hann(win),novlp,[],Fs);
        mask   = f<=300;
        plot(f(mask),10*log10(pA(mask)),'-', 'Color',axColors_ch{axi},'LineWidth',1.1,'DisplayName',sprintf('%s Chassis',axLabels{axi}));
        plot(f(mask),10*log10(pB(mask)),'--','Color',axColors_ee{axi},'LineWidth',0.9,'DisplayName',sprintf('%s EE',axLabels{axi}));
    end
    xlabel('Frequency (Hz)'); ylabel('PSD (dB re g²/Hz)');
    title(sprintf('%.1f m/s — Indoor White', speeds(vi)));
    legend('Location','northeast','FontSize',7,'NumColumns',2);
    grid on; set(gca,'FontSize',9);
end
sgtitle('Fig 4: 3-axis PSD — Chassis solid / EE dashed — Indoor White Tile','FontSize',12,'FontWeight','bold');
saveas(fig4, fullfile(outDir,'dual3d_fig4_3axis_psd_overlay.png'));

%% ── 8. FIGURE 5: Cross-coherence chassis↔EE per axis ────────────────────
show_vi2 = [1 2 4 7];   % 0.2, 0.4, 0.8, 1.5 m/s
col4 = lines(numel(show_vi2));
fig5 = figure('Position',[30 30 1400 700]);
for axi=1:3
    subplot(1,3,axi); hold on;
    legStr = {};
    for ki=1:numel(show_vi2)
        vi = show_vi2(ki);
        if isempty(Za{si_ref,vi}), continue; end
        switch axi
            case 1, ch=Xa{si_ref,vi}; ee=Xb{si_ref,vi};
            case 2, ch=Ya{si_ref,vi}; ee=Yb{si_ref,vi};
            case 3, ch=Za{si_ref,vi}; ee=Zb{si_ref,vi};
        end
        [cxy,f] = mscohere(ch, ee, hann(win), novlp, [], Fs);
        mask = f<=300;
        plot(f(mask),cxy(mask),'Color',col4(ki,:),'LineWidth',1.0);
        legStr{end+1} = sprintf('%.1f m/s',speeds(vi));
    end
    yline(0.5,'k--','LineWidth',1.0);
    xlabel('Frequency (Hz)'); ylabel('Coherence');
    title(sprintf('%s-axis: Chassis ↔ End-Effector', axLabels{axi}));
    legend([legStr,{'0.5 threshold'}],'Location','northeast','FontSize',8);
    xlim([0 300]); ylim([0 1]); grid on; set(gca,'FontSize',9);
end
sgtitle('Fig 5: Cross-coherence chassis↔EE per axis — Indoor White Tile','FontSize',12,'FontWeight','bold');
saveas(fig5, fullfile(outDir,'dual3d_fig5_coherence.png'));

%% ── 9. FIGURE 6: Low-frequency zoom 0–30 Hz — arm resonance region ──────
fig6 = figure('Position',[30 30 1400 900]);
vi_hi = find(speeds==1.0);   % 1.0 m/s — clearest N=11 and arm modes
if isempty(vi_hi), vi_hi=5; end

for si=1:nSurf
    subplot(2,2,si); hold on;
    if isempty(Za{si,vi_hi}), continue; end

    allCh = {Xa{si,vi_hi}, Ya{si,vi_hi}, Za{si,vi_hi}};
    allEE = {Xb{si,vi_hi}, Yb{si,vi_hi}, Zb{si,vi_hi}};

    % Finer frequency resolution for low-freq: use longer window
    win_lf = min(round(2*Fs), numel(Za{si,vi_hi})/4);
    win_lf = 2^floor(log2(win_lf));

    for axi=1:3
        [pA,f] = pwelch(allCh{axi},hann(win_lf),round(win_lf/2),[],Fs);
        pB     = pwelch(allEE{axi},hann(win_lf),round(win_lf/2),[],Fs);
        mask   = f<=30;
        plot(f(mask),10*log10(pA(mask)),'-', 'Color',axColors_ch{axi},'LineWidth',1.2,'DisplayName',sprintf('%s Chassis',axLabels{axi}));
        plot(f(mask),10*log10(pB(mask)),'--','Color',axColors_ee{axi},'LineWidth',1.0,'DisplayName',sprintf('%s EE',axLabels{axi}));
    end

    % Mark N=11 and suspension fn
    wheelCirc=0.399;
    f11 = 11*speeds(vi_hi)/(sqrt(2)*wheelCirc);
    xline(f11,   'b:',  sprintf('N=11 %.1fHz',f11),  'LabelVerticalAlignment','bottom','FontSize',7);
    xline(4.0,   'k--', 'Susp fn 4Hz',               'LabelVerticalAlignment','bottom','FontSize',7);
    xline(4.76,  'r--', 'Pad fn 4.76Hz',              'LabelVerticalAlignment','bottom','FontSize',7);

    xlabel('Frequency (Hz)'); ylabel('PSD (dB re g²/Hz)');
    title(sprintf('%s — %.1f m/s', surfLabel(surfaces{si}), speeds(vi_hi)));
    legend('Location','northeast','FontSize',7,'NumColumns',2);
    xlim([0 30]); grid on; set(gca,'FontSize',9);
end
sgtitle('Fig 6: Low-frequency PSD (0–30 Hz) — Chassis solid / EE dashed — 1.0 m/s','FontSize',12,'FontWeight','bold');
saveas(fig6, fullfile(outDir,'dual3d_fig6_lowfreq_arm_resonance.png'));

%% ── 10. PRINT ARM RESONANCE FINDINGS ────────────────────────────────────
fprintf('\n===== ARM RESONANCE INVESTIGATION =====\n');
fprintf('Looking for EE amplification peaks (T>1) in X and Y axes...\n\n');
for si=1:nSurf
    fprintf('Surface: %s\n', surfLabel(surfaces{si}));
    for vi=[2 4 5]   % 0.4, 0.8, 1.0 m/s
        if isempty(Za{si,vi}), continue; end
        win_lf = min(round(2*Fs), numel(Za{si,vi})/4);
        win_lf = 2^floor(log2(win_lf));
        for axi=1:2   % X and Y only (horizontal modes)
            switch axi
                case 1, ch=Xa{si,vi}; ee=Xb{si,vi};
                case 2, ch=Ya{si,vi}; ee=Yb{si,vi};
            end
            [pA,f] = pwelch(ch,hann(win_lf),round(win_lf/2),[],Fs);
            pB     = pwelch(ee,hann(win_lf),round(win_lf/2),[],Fs);
            Tf     = sqrt(movmean(pB,5)./max(movmean(pA,5),1e-12));
            % Find peaks > 1.5 in 2–20 Hz
            mask   = f>=2 & f<=20;
            Tf_lf  = Tf(mask);  f_lf = f(mask);
            [pk_val, pk_idx] = findpeaks(Tf_lf,'MinPeakHeight',1.5,'MinPeakProminence',0.3);
            if ~isempty(pk_val)
                fprintf('  %.1f m/s %s-axis: peaks at ', speeds(vi), axLabels{axi});
                fprintf('%.1fHz(T=%.1f) ', [f_lf(pk_idx), pk_val]');
                fprintf('\n');
            end
        end
    end
    fprintf('\n');
end

fprintf('Analysis complete. Figures saved to %s/dual3d_fig*.png\n', outDir);

%% ── LOCAL FUNCTION ───────────────────────────────────────────────────────
function [x,y,z] = loadAndClean(fpath)
    fid = fopen(fpath,'r');
    raw = textscan(fid,'%s%f%f%f%f','Delimiter',',','HeaderLines',1,'CollectOutput',false);
    fclose(fid);
    x = detrend(raw{2},'constant');
    y = detrend(raw{3},'constant');
    z = detrend(raw{4},'constant');
end
