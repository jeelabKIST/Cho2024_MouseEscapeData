%% Description
%{
This script depicts examplary burst events in mouse LFP signals and further
visualizes a summary of time series-based burst detection method.
%}
%% Configure Library Path
UTIL_DIR = genpath('/Users/scho/Cho2024_MouseEscapeData/utils');
addpath(UTIL_DIR);
%% Set Hyperparameters (User-Defined)
% [1] For Analysis
mouse_id = 1;
session_id = 1;
beta_fb = [20, 30];  % beta frequency range (unit: Hz)
gamma_fb = [60, 92]; % gamma frequency range (unit: Hz)
threshold_factor = 2.0;
% [2] For Visualization
gray = "#333030";
orange = "#ff7f0e";
green = "#2ca02c";
brown = "#A71D31";
wheat = "#F5DFBB";
%% Summary #1: Burst Detection on LFP Signals
DATA_DIR = '/Users/scho/Cho2024_MouseEscapeData/data_BIDS/';
eeg_data_path = '%ssub-%02d/ses-%02d/eeg/';
fprintf(['Processing Mouse #' num2str(mouse_id) ' Session #' num2str(session_id) ' ... \n']);
% [1] Load Data
eeg_data_name = dir([sprintf(eeg_data_path, DATA_DIR, mouse_id, session_id) '*.set']);
EEG = pop_loadset('filename', eeg_data_name.name, 'filepath', eeg_data_name.folder, 'verbose', 'off');
% [2] Apply Bandpass Filtering
[EEG_beta, ~, ~] = pop_eegfiltnew(EEG, beta_fb(1), beta_fb(2));
[EEG_gamma, ~, ~] = pop_eegfiltnew(EEG, gamma_fb(1), gamma_fb(2));
% NOTE: Signals are filtered using the Hamming windowed sinc FIR filter
% in the EEGLAB software (v2023.0).
% [3] Define Variables
times = EEG.times;
Fs = EEG.srate;
Nyq = Fs / 2;
raw_data = EEG.data';
data_beta = double(EEG_beta.data);
data_gamma = double(EEG_gamma.data);
n_channels = size(raw_data,2);
% [4] Apply an IIR Notch Filter to Signals
w0 = 60 / Nyq;
q_factor = 35;
bw = w0 / q_factor;
[b, a] = iirnotch(w0, bw);
data_beta = filtfilt(b, a, data_beta');
data_gamma = filtfilt(b, a, data_gamma');
% [5] Detect Bursts from Bandpass-Filtered Signals
for n = 1:n_channels
    [btime_beta, burst_beta, binary_events_beta] = detect_burst_timeseries( ...
        Fs, times, data_beta(:, n), beta_fb(1), beta_fb(2), threshold_factor);
    [btime_gamma, burst_gamma, binary_events_gamma] = detect_burst_timeseries( ...
        Fs, times, data_gamma(:, n), gamma_fb(1), gamma_fb(2), threshold_factor);
    % [6] Visualize Burst Detections
    figure(); hold on;
    % (A) Plot Raw Signals
    plot(times, raw_data(:,n), 'Color', gray, 'LineWidth', 2);
    plot(times, data_beta(:,n)-0.5, 'Color', gray, 'LineWidth', 2)
    plot(times, data_gamma(:,n)-0.8, 'Color', gray, 'LineWidth', 2);
    % (B) Plot Bursts
    plot_bursts(btime_beta, burst_beta, 0.5, orange);
    plot_bursts(btime_gamma, burst_gamma, 0.8, green);
    % (C) Plot a Scale Bar
    if n == n_channels
        line([94.8, 94.9], [-1.0, -1.0], 'LineWidth', 4, 'Color', 'k');
        line([94.9, 94.9], [-0.9, -1.0], 'LineWidth', 4, 'Color', 'k');
        text(94.85, -1.06, '100ms', 'FontSize', 20, 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center');
        text(94.91, -0.95, '0.1mV', 'FontSize', 20, 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
    end
    % (D) Configure Figure Settings
    set(gca, 'Box', 'off', 'TickLength', [0, 0], 'XLim', [93.7, 94.9], ...
        'XColor', 'none', 'YColor', 'none', 'Color', 'none');
    set(gcf, 'Color', 'w', 'Position', [476, 473, 758, 393]);
end
%% Summary #2: Burst Detection Algorithm (Bandpass-Filtering)
% [1] Get Threshold
thr = mean(data_gamma(:,2)) + threshold_factor*std(data_gamma(:,2));
subthr = mean(data_gamma(:,2)) + (threshold_factor-1)*std(data_gamma(:,2));
durthr = 3 * (Fs / (sum(gamma_fb) / 2));
% [2] Plot Burst Detection Process
figure(); hold on;
for b = 1:length(btime_gamma)
    btime_mid = btime_gamma{b}(round(length(btime_gamma{b})/2));
    rectangle('Position', [btime_mid - (durthr/(Fs*2)), min(data_gamma(:,2)), durthr/Fs, abs(min(data_gamma(:,2))) + max(data_gamma(:,2))], 'EdgeColor', wheat, 'FaceColor', wheat);
end
plot(times, data_gamma(:,2), 'Color', gray, 'LineWidth', 3);
yln_thr = yline(thr, 'Color', brown, 'LineWidth', 3, 'LineStyle', '-.', 'alpha', 1);
yln_subthr = yline(subthr, 'Color', brown, 'LineWidth', 3, 'LineStyle', '-', 'alpha', 1);
plot_bursts(btime_gamma, burst_gamma, 0, green, 3);
set(gca, 'TickLength', [0, 0], 'XColor', 'none', 'YColor', 'none', 'Color', 'none', 'XLim', [94.3, 94.5]);
set(gcf, 'Color', 'w');
% [3] Plot Zoom-In Visualization (Selected BLA Burst)
figure(); hold on;
start = find(times >= btime_gamma{3}(1)-0.025, 1, 'first');
stop = find(times <= btime_gamma{3}(end)+0.025, 1, 'last');
plot(times(start:stop), data_gamma(start:stop,2), 'Color', gray, 'LineWidth', 4);
plot(btime_gamma{3}, burst_gamma{3}, 'Color', green, 'LineWidth', 4);
line([times(stop)-0.025, times(stop)-0.005], [-0.08, -0.08], 'LineWidth', 4, 'Color', 'k');
line([times(stop)-0.005, times(stop)-0.005], [-0.06, -0.08], 'LineWidth', 4, 'Color', 'k');
text(times(stop)-0.015, -0.087, '20ms', 'FontSize', 28, 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
text(times(stop)-0.003, -0.07, '20μV', 'FontSize', 28, 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left');
set(gca, 'TickLength', [0, 0], 'XColor', 'none', 'YColor', 'none', 'Color', 'none', ...
    'XLim', [btime_gamma{3}(1)-0.03, btime_gamma{3}(end)+0.03]);
set(gcf, 'Color', 'w');
%% [4] Plot Manual Legend Box
leg_fig = figure(); hold on;
pl = cell(1, 5);
pl{1} = plot(rand(1,2), rand(1,2), 'Color', gray);
pl{2} = plot(rand(1,2), rand(1,2), 'Color', green);
pl{3} = plot(rand(1,2), rand(1,2), 'Color', brown, 'LineStyle', ':');
pl{4} = plot(rand(1,2), rand(1,2), 'Color', brown);
pl{5} = plot(rand(1,2), rand(1,2), 'Color', wheat);
lgnd = legend('Filtered Signal', 'Detected Burst', 'Amplitude Threshold', 'Amplitude Sub-threshold', ...
       'Duration Threshold', 'FontSize', 34, 'Color', 'w', 'NumColumns', 1);
lgnd.LineWidth = 4;
lgnd.ItemTokenSize = [50, 8];
make_custom_legend(leg_fig, lgnd, 'line');
set([pl{:}], 'LineWidth', 10);
set(gca, 'Color', 'none');
set(gcf, 'Color', 'w');
%% Appendix: Auxiliary Functions
% Function #1: Visualize Burst Detections
function plot_bursts(btime, burst, gap, color, lw)
    % [1] Validate Arguments
    if nargin < 5, lw = 2; end
    if nargin < 4, color = 'r'; end
    if nargin < 3, gap = 0; end
    % [2] Plot Bursts
    for b = 1:length(btime)
        plot(btime{b}, burst{b} - gap, 'Color', color, 'LineWidth', lw);
    end
end