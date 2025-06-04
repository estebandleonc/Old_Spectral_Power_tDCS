%% FREQUENCY BAND AND LOG-TRANSFORMATION
% This function log transforms the data and groups individual frequencies into theta, lower alpha and upper alpha bands.
% Author: Esteban León-Correa
% Last Updated: 28/05/25
% Compatible with FIELDTRIP 2023+

%% Key words
% A = Participants of the experimental group (tDCS)
% C = Participants of the control group

% PRE = pre_training session
% POST = post_training session
% FU = follow_up session

% LET = Letter Span
% COR = Corsi Test

%% FUNCTION FOR LOG TRANFORMATION AND CREATION OF FREQUENCY BANDS
function transformed_data = frequency_bands_transformation(grandavg_data)
    % Log transformation to improve sensitivity
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = 'log10';
    grandavg_data_log = ft_math(cfg, grandavg_data);

    % Initialise variables
    [num_subjects, num_channels, num_frequencies] = size(grandavg_data_log.powspctrm);
    peak_frequencies = zeros(num_subjects, num_channels);

    % Define alpha frequency range
    alpha_range = 8:12;

    % Step 1: Identify Individual Alpha Peak Frequency (IAF)
    for s = 1:num_subjects
        for ch = 1:num_channels
            % Extract power spectral data for the current subject and channel within alpha range
            power_spectrum = squeeze(grandavg_data_log.powspctrm(s, ch, alpha_range));

            % Find the index of the maximum power within alpha range
            [~, max_idx] = max(power_spectrum);

            % Select the corresponding frequency from the alpha range
            peak_freq = alpha_range(max_idx);

            % Store the peak frequency for the current subject and channel
            peak_frequencies(s, ch) = peak_freq;
        end
    end

    % Step 2: Adjust Frequency Bands for Each Individual
    adjusted_frequency_bands = zeros(num_subjects, num_channels, 5, 2);
    for p = 1:num_subjects
        % Determine individual alpha peak frequency (IAF)
        IAF = mean(peak_frequencies(p, :)); % Use mean of peak frequencies across channels

        % Define frequency bands based on IAF
        theta_lower = IAF - 5; % Theta band: 5 Hz below IAF
        theta_upper = IAF - 3; % Theta band: 3 Hz below IAF
        low_alpha_lower = IAF - 2; % Low-Alpha band: 2 Hz below IAF
        low_alpha_upper = IAF; % Low-Alpha band: IAF
        high_alpha_lower = IAF + 1; % High-Alpha band: 1 Hz above IAF
        high_alpha_upper = IAF + 2; % High-Alpha band: 2 Hz above IAF

        % Store adjusted frequency bands for each participant and channel
        adjusted_frequency_bands(p, :, 1, 1) = theta_lower;
        adjusted_frequency_bands(p, :, 1, 2) = theta_upper;
        adjusted_frequency_bands(p, :, 2, 1) = low_alpha_lower;
        adjusted_frequency_bands(p, :, 2, 2) = low_alpha_upper;
        adjusted_frequency_bands(p, :, 3, 1) = high_alpha_lower;
        adjusted_frequency_bands(p, :, 3, 2) = high_alpha_upper;
    end

    % Step 3: Extract Power Spectral Data within Adjusted Frequency Bands
    adjusted_power_spectral_data = zeros(num_subjects, num_channels, 3); % Adjusted to store three bands
    for p = 1:num_subjects
        for ch = 1:num_channels
            % Extract frequency bands for the current participant and channel
            frequency_bands = squeeze(adjusted_frequency_bands(p, ch, :, :));

            % Extract power spectral data within adjusted frequency bands
            theta_lower = frequency_bands(1, 1);
            theta_upper = frequency_bands(1, 2);
            low_alpha_lower = frequency_bands(2, 1);
            low_alpha_upper = frequency_bands(2, 2);
            high_alpha_lower = frequency_bands(3, 1);
            high_alpha_upper = frequency_bands(3, 2);

            % Calculate mean power within theta and alpha bands
            theta_power = mean(grandavg_data_log.powspctrm(p, ch, theta_lower:theta_upper), 'all');
            low_alpha_power = mean(grandavg_data_log.powspctrm(p, ch, low_alpha_lower:low_alpha_upper), 'all');
            high_alpha_power = mean(grandavg_data_log.powspctrm(p, ch, high_alpha_lower:high_alpha_upper), 'all');

            % Store power spectral data within adjusted frequency bands
            adjusted_power_spectral_data(p, ch, 1) = theta_power;
            adjusted_power_spectral_data(p, ch, 2) = low_alpha_power;
            adjusted_power_spectral_data(p, ch, 3) = high_alpha_power;
        end
    end

    % Include new matrix as power spectrum
    grandavg_data_log.powspctrm = adjusted_power_spectral_data;
    grandavg_data_log.freq = [1, 2, 3]; % Updated to represent the three bands

    % Return processed data
    transformed_data = grandavg_data_log;
end
