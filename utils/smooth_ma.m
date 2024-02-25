function smoothed_data = smooth_ma(data, Fs, win_sz)
    %% Function: 'smooth_ma'
    % DESCRIPTION
    % Smoothes input data with a forward moving average (boxcar) window

    % USAGE
    % Full Input : smooth_ma(data, Fs)
    % Example    : smooth_ma(input_vector, 1024)

    % INPUT
    %    Variable       Data Type             Description
    % 1. data           [1 x N array]       : input data array
    % 2. Fs             [number N]          : sampling rate for the input data
    % 3. win_sz         [number N]          : window size (in seconds)
    %                                         Default) 10 s

    % OUTPUT
    %    Variable         Data Type                 Description
    % 1. smoothed_data    [1 x N cell vector]     : a smoothed data array

    % Written by SungJun Cho, October 21, 2023
    % Last Modified on February 24, 2024
    %% Set Parameters
    if nargin < 3
        win_sz = 10; % 10s window
    end
    data_length = length(data);
    %% Smooth the Input Data
    start_idx = 1:Fs:data_length;
    end_idx = start_idx + (Fs * win_sz);
    end_idx(end_idx > data_length) = data_length;
    smoothed_data = zeros(size(end_idx));
    for i = 1:length(start_idx)
        smoothed_data(i) = mean(data(start_idx(i):end_idx(i)));
    end
end