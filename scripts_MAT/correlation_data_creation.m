%% Import neurophysiological data: absolute power
function final_correlations = correlation_data_creation(grandavg_data)
    
    % Create a struct to store data
    diff_grand_avg = struct();
    correlation_data = struct();
    final_correlations = struct();
    
    % Variables
    conditions = {'data_exp', 'data_control'};
    sessions = {'PRE', 'POST', 'FU'};
    WM_phase = {'ENC', 'INST', 'RETENTION', 'MANIPULATION', 'RET_RECALL', 'MAN_RECALL'};
    comparisons = {'ENC_RET', 'RET_REC', 'ENC_REC_RET', 'ENC_MAN', 'MAN_REC', 'ENC_REC_MAN'};

    % Loop over datasets and sessions
    for d = 1:length(conditions)
        condition = conditions{d};
        for s = 1:length(sessions)
            session = sessions{s};

            % Identify if there are missing datasets
            if isfield(grandavg_data, condition) && isfield(grandavg_data.(condition), session)
                data_group = grandavg_data.(condition).(session);
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
            end

            % Compute differences between WM phases
            try
                diff_grand_avg.(condition).(session).ENC_RET     = grandavg_data.(condition).(session).RETENTION.powspctrm - grandavg_data.(condition).(session).ENC.powspctrm;
                diff_grand_avg.(condition).(session).ENC_MAN     = grandavg_data.(condition).(session).MANIPULATION.powspctrm - grandavg_data.(condition).(session).ENC.powspctrm;
                diff_grand_avg.(condition).(session).RET_REC     = grandavg_data.(condition).(session).RET_RECALL.powspctrm - grandavg_data.(condition).(session).RETENTION.powspctrm;
                diff_grand_avg.(condition).(session).MAN_REC     = grandavg_data.(condition).(session).MAN_RECALL.powspctrm - grandavg_data.(condition).(session).MANIPULATION.powspctrm;
                diff_grand_avg.(condition).(session).ENC_REC_RET = grandavg_data.(condition).(session).RET_RECALL.powspctrm - grandavg_data.(condition).(session).ENC.powspctrm;
                diff_grand_avg.(condition).(session).ENC_REC_MAN = grandavg_data.(condition).(session).MAN_RECALL.powspctrm - grandavg_data.(condition).(session).ENC.powspctrm;
            catch ME
                fprintf("Error computing differences for %s - %s: %s\n", condition, session, ME.message);
            end
        end

        % Compute differences between conditions for each WM phase
        try
            correlation_data.ENC_RET.(condition)     = diff_grand_avg.(condition).POST.ENC_RET - diff_grand_avg.(condition).PRE.ENC_RET;
            correlation_data.RET_REC.(condition)     = diff_grand_avg.(condition).POST.RET_REC - diff_grand_avg.(condition).PRE.RET_REC;
            correlation_data.ENC_REC_RET.(condition) = diff_grand_avg.(condition).POST.ENC_REC_RET - diff_grand_avg.(condition).PRE.ENC_REC_RET;
            correlation_data.ENC_MAN.(condition)     = diff_grand_avg.(condition).POST.ENC_MAN - diff_grand_avg.(condition).PRE.ENC_MAN;
            correlation_data.MAN_REC.(condition)     = diff_grand_avg.(condition).POST.MAN_REC - diff_grand_avg.(condition).PRE.MAN_REC;
            correlation_data.ENC_REC_MAN.(condition) = diff_grand_avg.(condition).POST.ENC_REC_MAN - diff_grand_avg.(condition).PRE.ENC_REC_MAN;
        catch ME
            fprintf("Error computing differences for %s: %s\n", condition, ME.message);
        end
    end

    % Concatenate data_exp and data_control into final_correlations
    for i = 1:length(comparisons)
        comp = comparisons{i};

        if isfield(correlation_data, comp) && ...
           isfield(correlation_data.(comp), 'data_exp') && ...
           isfield(correlation_data.(comp), 'data_control')

            final_correlations.(comp) = cat(1, ...
                correlation_data.(comp).data_exp, ...
                correlation_data.(comp).data_control);
        else
            fprintf('Skipping %s: missing data for one or both groups.\n', comp);
        end
    end
end
