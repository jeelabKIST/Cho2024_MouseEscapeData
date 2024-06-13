function plot_stage_burst_rate_band(br1_stage, br2_stage, channel_id, lbl_opt)
    %% Function: 'plot_stage_burst_rate'
    % DESCRIPTION
    % Plots burst occurrence rates of two conditions or groups per
    % frequency band, averaged over each task stage

    % USAGE
    % Full Input : plot_stage_burst_rate_band(br1_stage, br2_stage, channel_id, lbl_opt)
    % Example    : plot_stage_burst_rate_band(beta_rates_stage, gamma_rates_stage, 1)

    % INPUT
    %    Variable       Data Type              Description
    % 1. br1_stage      [double array]       : Stage-averaged burst rates of first condition / group
    % 2. br2_stage      [double array]       : Stage-averaged burst rates of second condition / group
    % 3. channel_id     [number N]           : LFP channel to use
    %                                          Note) 1 - mPFC; 2 - BLA
    % 4. lbl_opt        [boolean]            : whether to include x- and y-labels
    %                                          Default) false

    % NOTE
    % The dimension of `br1_stage` and `br2_stage` should be identical and 
    % [nChannels x nTrials x nStages].

    % Written by SungJun Cho, November 12, 2023
    % Last Modified on May 25, 2024
    %% Set Parameters
    % [1] Validation
    if ~ismember(channel_id, [1, 2])
        error("InputError: channel_id must be either 1 (PFC) or 2 (BLA).");
    end
    if nargin < 4
        lbl_opt = false;
    end
    nStages = size(br1_stage, 3);
    xaxis = 1:nStages;
    % [2] Set Visualization Parameters
    gray = [51, 48, 48]./255;
    orange = autumn(nStages + 2);
    green = summer(nStages + 2);
    %% Compute Descriptive Statistics of Burst Occurrence Rates
    % Select Channel
    br1_stage = squeeze(br1_stage(channel_id, :, :));
    br2_stage = squeeze(br2_stage(channel_id, :, :));
    % Compute First and Second Moments
    mean_br1_stage = mean(br1_stage, 1);
    mean_br2_stage = mean(br2_stage, 1);
    se_br1_stage = std(br1_stage, 1) ./ sqrt(size(br1_stage, 1));
    se_br2_stage = std(br2_stage, 1) ./ sqrt(size(br1_stage, 1));
    %% Visualize Bar Plots
    figure();
    er = cell(2, nStages);
    ticks = zeros(1, nStages);
    ax1 = subplot(1, 2, 1); hold on;
    bp1 = bar(1, mean_br1_stage);
    for n = 1:nStages
        ticks(n) = bp1(n).XEndPoints;
        er{1, n} = errorbar(bp1(n).XEndPoints, mean_br1_stage(n), se_br1_stage(n), se_br1_stage(n));
        bp1(n).CData = orange(n + 1, :);
    end
    xticks(ticks);
    xticklabels(xaxis);
    ylim([0 ax1.YLim(end) * 1.18]);
    ax2 = subplot(1, 2, 2); hold on;
    bp2 = bar(1, mean_br2_stage);
    for n = 1:nStages
        er{2, n} = errorbar(bp2(n).XEndPoints, mean_br2_stage(n), se_br2_stage(n), se_br2_stage(n));
        bp2(n).CData = green(n + 1, :);
    end
    xticks(ticks);
    xticklabels(xaxis);
    ylim([0 ax2.YLim(end) * 1.35]);
    if lbl_opt
        xlabel('Stages')
        ylabel('Stage-Averaged Burst Rates (/s)')
    end
    set([bp1, bp2], 'EdgeColor', 'none', 'FaceColor', 'flat', 'FaceAlpha', 0.8);
    set([er{:}], 'CapSize', 15, 'LineStyle', 'none', 'LineWidth', 2, 'Color', gray);
    set([ax1, ax2], 'Box', 'off', 'TickDir', 'out', 'LineWidth', 2, 'FontSize', 18);
    set(gcf, 'Color', 'w', 'Position', [777, 461, 644, 240]);
end