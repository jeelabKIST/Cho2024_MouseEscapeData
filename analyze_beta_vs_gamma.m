%% Description
%{
This script computes burst occurrence rates for the beta (20-30 Hz) and
gamma (60-92 Hz) bands and tests whether burst rates of a mouse (in a 
solitary condition) change in response to threats instigated by a spider 
robot.
%}
%% Configure Library Path
UTIL_DIR = genpath('/Users/scho/Cho2024_MouseEscapeData/utils');
addpath(UTIL_DIR);
%% Load Data
data_path = '/Users/scho/Cho2024_MouseEscapeData/results/burst_info_solitary_%s.mat';
BETA_INFO = load(sprintf(data_path, 'beta')).BURST_INFO;
GAMMA_INFO = load(sprintf(data_path, 'gamma')).BURST_INFO;
beta_binary = BETA_INFO.binary;
gamma_binary = GAMMA_INFO.binary;
%% Set Hyperparameters
Fs = 1024;     % sampling frequency
nTrials = 64;  % total number of trials
nChannels = 2; % total number of channels
nStages = 4;   % total number of task stages
%% Compute Burst Occurrence Rates
beta_rates = zeros(nChannels, nTrials, length(beta_binary{1, 1})/Fs);
gamma_rates = zeros(nChannels, nTrials, length(gamma_binary{1, 1})/Fs);
for c = 1:nChannels
    for n = 1:nTrials
        beta_rates(c, n, :) = smooth_ma(beta_binary{n, c}, Fs);
        gamma_rates(c, n, :) = smooth_ma(gamma_binary{n, c}, Fs);
    end
end
%% Visualize Trial-Averaged Burst Occurrence Rates
plot_avg_burst_rate(beta_rates, gamma_rates, 1);
plot_avg_burst_rate(beta_rates, gamma_rates, 2);
%% Get Stage-Averaged Burst Occurrence Rates
beta_rates_stage = squeeze(mean(reshape(beta_rates, [nChannels, nTrials, 60, nStages]), 3));
gamma_rates_stage = squeeze(mean(reshape(gamma_rates, [nChannels, nTrials, 60, nStages]), 3));
% NOTE: We average burst rates over the duration of each stage (i.e., 60 s).
%% Visualize Stage-Averaged Burst Occurrence Rate Per Frequency Band
plot_stage_burst_rate_band(beta_rates_stage, gamma_rates_stage, 1);
plot_stage_burst_rate_band(beta_rates_stage, gamma_rates_stage, 2);
%% Perform Friedman's Test with Multiple Comparisons Correction
% [1] Check Normality Assumption for Each Channel and Stage
fprintf('Checking data normality ... \n');
for c = 1:nChannels
    for n = 1:nStages
        [h_beta, p_beta] = kstest(zscore(beta_rates_stage(c, :, n)));
        [h_gamma, p_gamma] = kstest(zscore(gamma_rates_stage(c, :, n)));
        fprintf('\t[Channel #%d, Stage #%d] Beta: %d (%d) | Gamma: %d (%d) \n', c, n, p_beta, h_beta, p_gamma, h_gamma);
    end
end
% NOTE: Since the data are burst rates and likely to follow Poisson-like
% distribution, it would be better to refrain from using tests that assume
% that data follows a normal distribution.
% [2] Check Equal Variance Assumption
fprintf('Checking data variance ... \n');
for c = 1:nChannels
    p_beta = vartestn(squeeze(beta_rates_stage(c, :, :)), 'TestType', 'LeveneQuadratic', 'Display', 'off');
    p_gamma = vartestn(squeeze(gamma_rates_stage(c, :, :)), 'TestType', 'LeveneQuadratic', 'Display', 'off');
    fprintf('\t[Channel #%d, Beta] p-value: %d \n', c, p_beta);
    fprintf('\t[Channel #%d, Gamma] p-value: %d \n', c, p_gamma);
end
% NOTE: Equal variance assumptions are tested for each channel and
% frequency band between four task stages.
% [3] Perform Friedman's Test with post-hoc Nemenyi's Test
fprintf('Running Friedman Test ... \n');
friedman_multcompare = cell(nChannels, 2);
for c = 1:nChannels
    [p_beta, tbl_beta, stats_beta] = friedman(squeeze(beta_rates_stage(c, :, :)), nStages, 'off');
    [p_gamma, tbl_gamma, stats_gamma] = friedman(squeeze(gamma_rates_stage(c, :, :)), nStages, 'off');
    fprintf('\t[Channel #%d, Beta] p-value: %d \n', c, p_beta);
    fprintf('\t[Channel #%d, Gamma] p-value: %d \n', c, p_gamma);
    friedman_multcompare{c, 1} = multcompare(stats_beta, 'CriticalValueType', 'tukey-kramer', 'Display', 'off');
    friedman_multcompare{c, 2} = multcompare(stats_gamma, 'CriticalValueType', 'tukey-kramer', 'Display', 'off');
end
% NOTE: In MATLAB, the Friedman's test with post-hoc Tukey's HSD procedure
% amounts to using the Nemenyi's test with Tukey-Kramer critical values as
% a post-hoc multiple comparisons test.