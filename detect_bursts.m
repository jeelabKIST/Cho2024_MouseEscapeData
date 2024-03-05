%% Description
%{
This script detects transient neural oscillatory bursts from the mouse LFP
signals, bandpass filtered by the user-defined frequency range. The time
point and amplitude of the detected bursts, along with their binary event
markings, will be saved as an output.
%}
%% Configure Library Path
UTIL_DIR = genpath('/Users/scho/Cho2024_MouseEscapeData/utils');
addpath(UTIL_DIR);
%% Set Hyperparameters (User-Defined)
mouse_ids = 1:8;
exp_condition = 'solitary';
if strcmp(exp_condition, 'solitary')
    session_ids = 1:8;
elseif strcmp(exp_condition, 'group')
    session_ids = 9:16;
end
n_mouse = length(mouse_ids);
n_session = length(session_ids);
freq_band = 'beta';
if strcmp(freq_band, 'beta')
    lo_f = 20;
    hi_f = 30;
elseif strcmp(freq_band, 'gamma')
    lo_f = 60;
    hi_f = 92;
elseif strcmp(freq_band, 'low_gamma')
    lo_f = 35;
    hi_f = 55;
end
% lo_f: low frequency band
% hi_f: high frequency band
%% Preallocate Outputs
BURST_INFO = struct();
BURST_INFO.btimes = cell(n_mouse * n_session, 2); % burst time points
BURST_INFO.bursts = cell(n_mouse * n_session, 2); % burst amplitudes
BURST_INFO.binary = cell(n_mouse * n_session, 2); % binary burst time stamps
% data size: (total # of trials x # of channels)
%% Detect Bursts
DATA_DIR = '/Users/scho/Cho2024_MouseEscapeData/data_BIDS/';
lfp_data_path = '%ssub-%02d/ses-%02d/eeg/';
trial_id = 1;
for m_idx = mouse_ids
    for s_idx = session_ids
        fprintf(['Processing Mouse #' num2str(m_idx) ' Session #' num2str(s_idx) ' ... \n']);
        % [1] Load Data
        lfp_data_name = dir([sprintf(lfp_data_path, DATA_DIR, m_idx, s_idx) '*.set']);
        LFP = pop_loadset('filename', lfp_data_name.name, 'filepath', lfp_data_name.folder, 'verbose', 'off');
        % [2] Apply Bandpass Filtering
        [LFP, ~, ~] = pop_eegfiltnew(LFP, lo_f, hi_f);
        % NOTE: Signals are filtered using the Hamming windowed sinc FIR 
        % filter in the EEGLAB software (v2023.0).
        % [3] Define Variables
        times = LFP.times;         % time array
        data = double(LFP.data);   % LFP recordings
        Fs = LFP.srate;            % sampling frequency
        Nyq = Fs / 2;              % Nyquist frequency
        n_channels = size(data,2); % number of channels
        % [4] Apply IIR Notch Filter to Signals
        w0 = 60 / Nyq;
        q_factor = 35;
        bw = w0 / q_factor;
        [b, a] = iirnotch(w0, bw);
        data = filtfilt(b, a, data');
        % [5] Detect Bursts from Bandpass-Filtered Signals
        threshold_factor = 2.0;
        [btime_pfc, burst_pfc, binary_events_pfc] = detect_burst_timeseries( ...
            Fs, times, data(:, 1), lo_f, hi_f, threshold_factor);
        [btime_bla, burst_bla, binary_events_bla] = detect_burst_timeseries( ...
            Fs, times, data(:, 2), lo_f, hi_f, threshold_factor);
        % [6] Store Burst Detections
        BURST_INFO.btimes(trial_id, :) = {btime_pfc, btime_bla};
        BURST_INFO.bursts(trial_id, :) = {burst_pfc, burst_bla};
        BURST_INFO.binary(trial_id, :) = {binary_events_pfc, binary_events_bla};
        trial_id = trial_id + 1;
    end
end
%% Save Burst Detections
% [1] Make a directory to save outputs (if necessary)
save_dir = fullfile(pwd, 'results');
if ~exist(save_dir, 'dir')
    mkdir(save_dir)
end
% [2] Save detected bursts
save_path = fullfile(save_dir, ['burst_info_' exp_condition '_' freq_band '.mat']);
if isfile(save_path)
    warning('Save attempt failed. A file with the specified name already exists.');
else
    fprintf(['Saving output file "' save_path '" ... \n']);
    save(save_path,'BURST_INFO');
end