function plot_avg_burst_rate(burst1_rates, burst2_rates, channel_id, lbl_opt)
    %% Function: 'plot_avg_burst_rate'
    % DESCRIPTION
    % Plots trial-averaged burst occurrence rates of two conditions or
    % groups

    % USAGE
    % Full Input : plot_avg_burst_rate(burst1_rates, burst2_rates, channel_id, lbl_opt)
    % Example    : plot_avg_burst_rate(beta_rates, gamma_rates, 2)

    % INPUT
    %    Variable         Data Type              Description
    % 1. burst1_rates     [double array]       : Burst rates of first condition / group
    % 2. burst2_rates     [double array]       : Burst rates of second condition / group
    % 3. channel_id       [number N]           : LFP channel to use
    %                                            Note) 1 - mPFC; 2 - BLA
    % 4. lbl_opt          [boolean]            : whether to include x- and y-labels
    %                                            Default) false

    % NOTE
    % The dimension of `burst1_rates` and `burst2_rates` should be
    % identical and [nChannels x nTrials x nTimes].

    % Written by SungJun Cho, November 12, 2023
    % Last Modified on February 24, 2024
    %% Set Parameters
    % [1] Validation
    if ~ismember(channel_id, [1, 2])
        error("InputError: channel_id must be either 1 (PFC) or 2 (BLA).");
    end
    if nargin < 4
        lbl_opt = false;
    end
    % [2] Set Visualization Parameters
    orange = "#ff7f0e";
    green = "#2ca02c";
    %% Compute Average Burst Occurrence Rate
    avg_burst1_rates = mean(squeeze(burst1_rates(channel_id, :, :)), 1);
    avg_burst2_rates = mean(squeeze(burst2_rates(channel_id, :, :)), 1);
    if length(avg_burst1_rates) ~= length(avg_burst2_rates)
        error("ComputeError: Beta and gamma burst rates should have an equal length.");
    end
    %% Visualize Average Burst Rates
    figure(); hold on;
    times = 1:length(avg_burst1_rates);
    xline(60, '--', 'Threat Onset', 'Color', 'k', 'LineWidth', 3, 'LabelHorizontalAlignment', 'left', 'FontSize', 16); % plot stimulus onset
    plot(times, avg_burst1_rates, 'Color', orange, 'LineWidth', 3);
    plot(times, avg_burst2_rates, 'Color', green, 'LineWidth', 3);
    if lbl_opt
        xlabel('Time (s)');
        ylabel('Average Burst Occurence Rate (/s)');
    end
    lgnd = legend('', 'Beta', 'Gamma');
    set(lgnd, 'Box', 'off');
    set(gca, 'TickDir', 'out', 'LineWidth', 3, 'XLim', [0, times(end)], 'FontSize', 18);
    set(gcf, 'Color', 'w', 'Position', [777, 461, 560, 240]);
end