%% Description
%{
This script computes burst occurrence rates of the specified frequency
band for the solitary and group conditions and tests whether burst rates of
mice change in response to task condition.
%}
%% Configure Library Path
UTIL_DIR = genpath('/Users/scho/Cho2024_MouseEscapeData/utils');
addpath(UTIL_DIR);
%% Load Data
data_path = '/Users/scho/Cho2024_MouseEscapeData/results/burst_info_%s_%s.mat';
freq_band = 'beta';
SOLIT_INFO = load(sprintf(data_path, 'solitary', freq_band)).BURST_INFO;
GROUP_INFO = load(sprintf(data_path, 'group', freq_band)).BURST_INFO;
solit_binary = SOLIT_INFO.binary;
group_binary = GROUP_INFO.binary;
%% Delete Unavailable Trials
empty_flag = and(~cellfun('isempty', solit_binary(:, 1)), ~cellfun('isempty', group_binary(:, 1)));
solit_binary = solit_binary(empty_flag, :);
group_binary = group_binary(empty_flag, :);
%% Set Hyperparameters
Fs = 1024;     % sampling frequency
nChannels = 2; % total number of channels
nStages = 4;   % total number of task stages
nTrials = length(solit_binary); % total number of trials
%% Compute Burst Occurrence Rates
% [1] For Solitary Condition
solit_rates = zeros(nChannels, nTrials, length(solit_binary{1, 1})/Fs);
for c = 1:nChannels
    for n = 1:nTrials
        solit_rates(c, n, :) = smooth_ma(solit_binary{n, c}, Fs);
    end
end
% [2] For Group Condition
group_rates = zeros(nChannels, nTrials, length(group_binary{1, 1})/Fs);
for c = 1:nChannels
    for n = 1:nTrials
        group_rates(c, n, :) = smooth_ma(group_binary{n, c}, Fs);
    end
end
%% Get Stage-Averaged Burst Occurrence Rate
solit_rates_stage = squeeze(mean(reshape(solit_rates, [nChannels, nTrials, 60, nStages]), 3));
group_rates_stage = squeeze(mean(reshape(group_rates, [nChannels, nTrials, 60, nStages]), 3));
% NOTE: We average burst rates over the duration of each stage (i.e., 60 s).
%% Perform Wilcoxon Signed-Rank Test with Bonferroni Correction
% [1] Compute descriptive statistics
solit_rates_mean = squeeze(mean(solit_rates_stage, 2));
solit_rates_std = squeeze(std(solit_rates_stage, 0, 2));
group_rates_mean = squeeze(mean(group_rates_stage, 2));
group_rates_std = squeeze(std(group_rates_stage, 0, 2));
% [2] Check Normality Assumption for Each Channel and Stage
fprintf('Checking data normality ... \n');
for c = 1:nChannels
    for n = 1:nStages
        [h_solit, p_solit] = kstest(zscore(solit_rates_stage(c, :, n)));
        [h_group, p_group] = kstest(zscore(group_rates_stage(c, :, n)));
        fprintf('\t[Channel #%d, Stage #%d] Solitary: %d (%d) | Group: %d (%d) \n', c, n, p_solit, h_solit, p_group, h_group);
    end
end
% [3] Check Equal Variance Assumption
fprintf('Checking data variance ... \n');
for c = 1:nChannels
    for n = 1:nStages
        temp_data = [squeeze(solit_rates_stage(c, :, n)); squeeze(group_rates_stage(c, :, n))]';
        p_ev = vartestn(temp_data, 'TestType', 'LeveneQuadratic', 'Display', 'off');
        fprintf('\t[Channel #%d, Solitary vs. Group] p-value: %d \n', c, p_ev);
    end
end
% [4] Check for Symmetry of Pairwise Differences Assumption
verbose = true;
for c = 1:nChannels
    for n = 1:nStages
        diff = solit_rates_stage(c, :, n) - group_rates_stage(c, :, n);
        if verbose
            figure(); boxplot(diff);
            ylabel('Pairwise Difference (Solitary - Group)');
            title(['Channel #' num2str(c) ' | Stage #' num2str(n)]);
            set(gcf, 'Color', 'white');
        end
    end
end
% [5] Perform Wilcoxon Signed-Rank Test
fprintf('Running Wilcoxon Signed-Rank Test ... \n');
wilcoxon_pvals = zeros(nChannels, nStages); % p-values
wilcoxon_stats = zeros(nChannels, nStages); % test statistics
for c = 1:nChannels
    for n = 1:nStages
        [p, h, stat] = signrank(solit_rates_stage(c, :, n), group_rates_stage(c, :, n));
        wilcoxon_pvals(c, n) = p;
        wilcoxon_stats(c, n) = stat.signedrank;
    end
end
bonferroni_alpha = 0.05 / nStages; % Bonferroni correction with n=4 stages
wilcoxon_sig = wilcoxon_pvals < bonferroni_alpha; % results of hypothesis testings