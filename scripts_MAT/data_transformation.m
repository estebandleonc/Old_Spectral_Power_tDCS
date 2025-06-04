%% GRAND AVERAGE AND DATA TRANSFORMATION
% This function computes the grand average for every WM phase, session and condition, log transforms the data and creates frequency bands.
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

%% FUNCTION TO APPLY LOG TRANSFORMATION AND FREQUENCY BAND CREATION TO GRAND AVERAGE POWER DATA
function grandavg_log = data_transformation(grandavg)
    % frequency_bands_transformation - Applies power spectrum transformation to grandavg data.
    %
    % Inputs:
    %   grandavg   - Structure with grand average data
    %   main_root  - Path to main project directory
    %
    % Output:
    %   grandavg_log - Structure with log-transformed and frequency-adjusted power data

    % Variables
    conditions = {'data_exp', 'data_control'};
    sessions = {'PRE', 'POST', 'FU'};
    WM_phase = {'ENC', 'INST', 'RETENTION', 'MANIPULATION', 'RET_RECALL', 'MAN_RECALL'};
    
    % Create struct to store data
    grandavg_log = struct();
    
    % Loop over datasets and sessions
    for d = 1:length(conditions)
        condition = conditions{d};
        for s = 1:length(sessions)
            session = sessions{s};

            % Identify if there are missing datasets
            if isfield(grandavg, condition) && isfield(grandavg.(condition), session)
                data_group = grandavg.(condition).(session);
            else
                fprintf('Missing data for %s - %s. Skipping.\n', condition, session);
                continue;
            end
    
            for w = 1:length(WM_phase)
                phase = WM_phase{w};
    
                % Check if all participants have this phase
                try
                    input_data = cellfun(@(x) x.(phase), data_group, 'UniformOutput', false);
                catch
                    fprintf('Phase %s missing for some participants in %s - %s. Skipping.\n', ...
                        phase, condition, session);
                    continue;
                end

                if all(cellfun(@isempty, input_data))
                    fprintf('No valid data for %s - %s - %s. Skipping.\n', condition, session, phase);
                    continue;
                end
    
                % Compute grand average
                cfg = [];
                cfg.channel        = 'all';
                cfg.foilim         = 'all';
                cfg.parameter      = 'powspctrm';
                cfg.keepindividual = 'yes';
                ga = ft_freqgrandaverage(cfg, input_data{:});
                
                % Transfer electrode info
                ga.elec = data_group{1}.(phase).elec;
    
                % Apply transformation function
                grandavg_log.(condition).(session).(phase) = frequency_bands_transformation(ga);
            end
        end
    end
end
