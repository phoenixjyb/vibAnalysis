%% suspension_design.m
% Passive spring-damper suspension design for omni-wheel chassis
%
% Method: apply 1-DOF transmissibility to the MEASURED input PSD at each
% speed → predict payload RMS acceleration → compare to 0.1 g target.
% Then size spring stiffness k and damper coefficient c.
%
% Assumptions:
%   - 4-wheel chassis, 4 independent suspensions (one per corner)
%   - Total chassis + payload mass: 15–30 kg  →  per-corner sprung mass 3.75–7.5 kg
%   - Accelerometer was on the unsuspended chassis → measured Z-acc = wheel input
%   - 1-DOF quarter-car model (sprung mass + spring/damper, no tyre compliance)

clear; clc; close all;

%% ── Configuration ────────────────────────────────────────────────────────
% speeds, nSpeeds, colors, legendLabels are loaded from vibData.mat below.

% Design sweep
fn_sweep   = 2 : 0.5 : 6;          % suspension natural frequency (Hz)
zeta_sweep = [0.2, 0.3, 0.4, 0.5, 0.6];  % damping ratio

% Mass range (kg per corner = total / 4)
M_total_range = [15, 20, 25, 30];   % kg
n_wheels = 4;

g = 9.81;                           % m/s²
target_rms_g = 0.1;                 % g  (payload target)

% Welch window: 0.5 s
welch_win_s = 0.5;

%% ── Load data & compute input PSDs ──────────────────────────────────────
% Load pre-processed data saved by vibration_analysis.m
% (run vibration_analysis.m first if vibData.mat does not exist)
fprintf('Loading vibData.mat ...\n');
if ~exist('vibData.mat','file')
    error('vibData.mat not found. Run vibration_analysis.m first.');
end
load('vibData.mat', 'accZ', 'Fs', 'speeds', 'nSpeeds', 'colors', 'legendLabels');
fprintf('Loaded %d datasets.\n\n', nSpeeds);

% Compute Welch PSDs from loaded Z-acceleration data
fprintf('Computing input PSDs...\n');
pxx_in = cell(nSpeeds,1);
f_psd  = cell(nSpeeds,1);
for i = 1:nSpeeds
    z   = accZ{i};
    win = round(welch_win_s * Fs(i));
    [pxx_in{i}, f_psd{i}] = pwelch(z, hann(win), round(win/2), [], Fs(i));
    fprintf('  [%d/%d] %.1f m/s  N=%d  Fs=%.0f Hz\n', i, nSpeeds, speeds(i), numel(z), Fs(i));
end
fprintf('Done.\n\n');

%% ── Transmissibility function (1-DOF, acceleration) ─────────────────────
% T(r) = sqrt( (1+(2*zeta*r)^2) / ((1-r^2)^2 + (2*zeta*r)^2) )
% r = f / fn
transmissibility = @(f, fn, zeta) ...
    sqrt( (1 + (2*zeta*(f/fn)).^2) ./ ...
          ( (1-(f/fn).^2).^2 + (2*zeta*(f/fn)).^2 ) );

%% ── Predicted output RMS for each (fn, zeta, speed) ─────────────────────
% rms_out(i_fn, i_z, i_spd) in g
rms_out = zeros(numel(fn_sweep), numel(zeta_sweep), nSpeeds);

for i_fn = 1:numel(fn_sweep)
    fn = fn_sweep(i_fn);
    for i_z = 1:numel(zeta_sweep)
        zeta = zeta_sweep(i_z);
        for i_spd = 1:nSpeeds
            f   = f_psd{i_spd};
            pxx = pxx_in{i_spd};
            T   = transmissibility(f, fn, zeta);
            % avoid f=0 division  (T→1 at f→0 anyway)
            T(1) = 1;
            pxx_out = T.^2 .* pxx;
            df  = f(2) - f(1);
            rms_out(i_fn, i_z, i_spd) = sqrt(sum(pxx_out) * df);
        end
    end
end

%% ── Figure 1: Transmissibility curves ───────────────────────────────────
fig1 = figure('Name','Transmissibility Curves','Position',[50 50 1300 500]);

f_plot = 0.1 : 0.1 : 200;
fn_show   = [3, 4, 5];
zeta_show = [0.2, 0.4, 0.6];
ls = {'-','--',':'};

subplot(1,2,1);   % vary fn, fixed zeta=0.4
hold on;
cmap = lines(numel(fn_show));
for j = 1:numel(fn_show)
    T = transmissibility(f_plot, fn_show(j), 0.4);
    plot(f_plot, 20*log10(T), 'Color', cmap(j,:), 'LineWidth', 1.4, ...
        'DisplayName', sprintf('f_n = %d Hz', fn_show(j)));
end
yline(20*log10(1/sqrt(2)), 'k:', '-3 dB', 'LabelHorizontalAlignment','left');
xline(sqrt(2)*min(fn_show), 'k:');
xlabel('Frequency (Hz)'); ylabel('Transmissibility (dB)');
title('Effect of Natural Frequency  (ζ = 0.4)');
legend('Location','northeast'); grid on; grid minor;
xlim([0 100]); ylim([-60 15]);

subplot(1,2,2);   % vary zeta, fixed fn=4 Hz
hold on;
cmap2 = cool(numel(zeta_show));
for j = 1:numel(zeta_show)
    T = transmissibility(f_plot, 4, zeta_show(j));
    plot(f_plot, 20*log10(T), 'Color', cmap2(j,:), 'LineWidth', 1.4, ...
        'DisplayName', sprintf('ζ = %.1f', zeta_show(j)));
end
yline(20*log10(1/sqrt(2)), 'k:', '-3 dB', 'LabelHorizontalAlignment','left');
xlabel('Frequency (Hz)'); ylabel('Transmissibility (dB)');
title('Effect of Damping Ratio  (f_n = 4 Hz)');
legend('Location','northeast'); grid on; grid minor;
xlim([0 100]); ylim([-60 15]);

sgtitle('1-DOF Passive Suspension Transmissibility');

%% ── Figure 2: Predicted output RMS vs fn  (one line per speed) ──────────
fig2 = figure('Name','Predicted Output RMS vs fn','Position',[50 50 1300 500]);

zeta_highlight = [0.3, 0.4, 0.5];
for col = 1:numel(zeta_highlight)
    i_z = find(zeta_sweep == zeta_highlight(col));
    subplot(1, numel(zeta_highlight), col);
    hold on;
    for i_spd = 1:nSpeeds
        plot(fn_sweep, squeeze(rms_out(:, i_z, i_spd)), ...
            'o-', 'Color', colors(i_spd,:), 'LineWidth', 1.2, ...
            'MarkerSize', 5, 'DisplayName', legendLabels{i_spd});
    end
    yline(target_rms_g, 'r--', 'LineWidth', 1.5, 'DisplayName', '0.1 g target');
    xlabel('Suspension natural frequency f_n (Hz)');
    ylabel('Predicted payload RMS (g)');
    title(sprintf('ζ = %.1f', zeta_highlight(col)));
    legend('Location','northeast','FontSize',7); grid on; grid minor;
    ylim([0 0.6]);
end
sgtitle('Predicted Payload Z-Acceleration RMS After Suspension');

%% ── Figure 3: Heatmap — which (fn, zeta) meets target at worst speed ─────
fig3 = figure('Name','Design Space Heatmap','Position',[50 50 900 500]);

worst_rms = max(rms_out, [], 3);   % worst case across all speeds
met_target = worst_rms <= target_rms_g;

subplot(1,2,1);
imagesc(zeta_sweep, fn_sweep, worst_rms);
colorbar; colormap('hot');
xlabel('Damping ratio ζ'); ylabel('Natural frequency f_n (Hz)');
title('Worst-speed predicted RMS (g)');
hold on;
% draw 0.1 g contour
[~, hc] = contour(zeta_sweep, fn_sweep, worst_rms, [target_rms_g target_rms_g], ...
    'w-', 'LineWidth', 2);
try, clabel(hc, 'FontSize', 9, 'Color', 'w'); catch, end

subplot(1,2,2);
imagesc(zeta_sweep, fn_sweep, double(met_target));
colormap(gca, [0.85 0.15 0.15; 0.15 0.75 0.15]);  % red=fail, green=pass
colorbar('Ticks',[0.25 0.75],'TickLabels',{'Fail (>0.1g)','Pass (≤0.1g)'});
xlabel('Damping ratio ζ'); ylabel('Natural frequency f_n (Hz)');
title(sprintf('Meets %.1f g target at ALL speeds?', target_rms_g));
grid on;

sgtitle('Suspension Design Space  (worst case across 0.2–1.2 m/s)');

%% ── Figure 4: Input vs predicted output PSD for recommended design ───────
fn_rec   = 4;     % Hz  — recommended
zeta_rec = 0.4;   % —

fig4 = figure('Name','Input vs Output PSD','Position',[50 50 1300 550]);
for i_spd = 1:nSpeeds
    subplot(2, 3, i_spd);
    f   = f_psd{i_spd};
    pxx = pxx_in{i_spd};
    T   = transmissibility(f, fn_rec, zeta_rec);  T(1)=1;

    plot(f, 10*log10(pxx),       'b',  'LineWidth',0.8, 'DisplayName','Input (no susp.)');
    hold on;
    plot(f, 10*log10(T.^2.*pxx), 'r-', 'LineWidth',0.8, 'DisplayName','Output (with susp.)');
    xlim([0 200]); ylim([-120 -20]);
    xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz)');
    title(sprintf('%.1f m/s', speeds(i_spd)));
    legend('FontSize',7,'Location','northeast'); grid on;
end
sgtitle(sprintf('Input vs Output PSD  (f_n=%.0f Hz, ζ=%.1f)', fn_rec, zeta_rec));

%% ── Spring & damper sizing table ─────────────────────────────────────────
fn_design   = [3, 4, 5];
zeta_design = [0.3, 0.4, 0.5];

fprintf('=======================================================================\n');
fprintf(' SPRING & DAMPER SIZING TABLE  (per corner, 4 corners)\n');
fprintf('=======================================================================\n');
fprintf(' Static deflection:  fn=3Hz → %.1f mm  |  fn=4Hz → %.1f mm  |  fn=5Hz → %.1f mm\n', ...
    g/(2*pi*3)^2*1000, g/(2*pi*4)^2*1000, g/(2*pi*5)^2*1000);
fprintf('\n');

for M = M_total_range
    m = M / n_wheels;
    fprintf('--- Total mass = %d kg  (%.2f kg per corner) ---\n', M, m);
    fprintf('%-6s  %-6s  %-12s  %-18s  %-18s\n', ...
        'fn(Hz)', 'zeta', 'k (N/m)', 'c (N·s/m)', 'Stroke_min (mm)');
    fprintf('%s\n', repmat('-',1,65));
    for fn = fn_design
        k = m * (2*pi*fn)^2;
        delta_st = m*g/k * 1000;        % mm  static sag
        stroke_min = 2 * (delta_st + 15);  % 2×(static sag + 15mm dynamic)
        for zeta = zeta_design
            c = 2 * zeta * sqrt(k * m);
            fprintf('%-6.0f  %-6.1f  %-12.1f  %-18.1f  %-18.1f\n', ...
                fn, zeta, k, c, stroke_min);
        end
    end
    fprintf('\n');
end

%% ── Recommended design summary ───────────────────────────────────────────
fprintf('=======================================================================\n');
fprintf(' RECOMMENDED DESIGN POINT\n');
fprintf('=======================================================================\n');
fprintf(' Natural frequency:   fn  = %.0f Hz\n', fn_rec);
fprintf(' Damping ratio:       zeta = %.1f\n', zeta_rec);
fprintf(' Static deflection:   %.1f mm\n', g/(2*pi*fn_rec)^2*1000);
fprintf(' Recommended stroke:  ≥ %.0f mm  (static sag + ±15 mm dynamic)\n', ...
    2*(g/(2*pi*fn_rec)^2*1000 + 15));
fprintf('\n');
fprintf(' Per-corner spring & damper values:\n');
fprintf(' %-14s  %-12s  %-12s  %-16s\n','Total mass','k (N/m)','c (N·s/m)','c (N·s/mm)');
fprintf(' %s\n', repmat('-',1,60));
for M = M_total_range
    m   = M / n_wheels;
    k   = m * (2*pi*fn_rec)^2;
    c   = 2 * zeta_rec * sqrt(k*m);
    fprintf(' %-14d  %-12.1f  %-12.1f  %-16.4f\n', M, k, c, c/1000);
end
fprintf('\n');

i_fn_rec = find(fn_sweep == fn_rec);
i_z_rec  = find(zeta_sweep == zeta_rec);
fprintf(' Predicted payload RMS with recommended suspension:\n');
fprintf(' %-12s  %-14s  %-14s  %-10s\n','Speed (m/s)','Input RMS (g)','Output RMS (g)','Reduction');
fprintf(' %s\n', repmat('-',1,55));
for i_spd = 1:nSpeeds
    z_in  = detrend(accZ{i_spd},'constant');
    rms_i = rms(z_in);
    rms_o = rms_out(i_fn_rec, i_z_rec, i_spd);
    fprintf(' %-12.1f  %-14.4f  %-14.4f  %-10.1f%%\n', ...
        speeds(i_spd), rms_i, rms_o, (1-rms_o/rms_i)*100);
end
fprintf('\n Target: < %.2f g RMS\n', target_rms_g);

%% ── Save figures ─────────────────────────────────────────────────────────
outDir = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

saveas(fig1, fullfile(outDir,'susp_fig1_transmissibility.png'));
saveas(fig2, fullfile(outDir,'susp_fig2_rms_vs_fn.png'));
saveas(fig3, fullfile(outDir,'susp_fig3_design_heatmap.png'));
saveas(fig4, fullfile(outDir,'susp_fig4_input_vs_output_psd.png'));
fprintf('Figures saved to ./%s/\n', outDir);

