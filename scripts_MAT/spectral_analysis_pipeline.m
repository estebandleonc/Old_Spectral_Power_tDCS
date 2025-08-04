%% EEG PROCESSING SCRIPT
% This script conducts spectral analysis on EEG data using FIELDTRIP
% Author: Esteban León-Correa
% Last Updated: 24/05/25
% Compatible with FIELDTRIP 2023+

%% Key words
% A = Participants of the experimental group
% C = Participants of the control group

% PRE = pre_training session
% POST = post_training session
% FU = follow_up session

% LET = Letter Span
% COR = Corsi Test

%% SETUP
clear; clc;

% === Paths ===
main_root = '\scripts_MAT'; % <-- Adjust path
data_path = fullfile(main_root, 'preprocessed_data');
output_path = fullfile(main_root, 'processed_data');
graphs_path = fullfile(output_path, 'graphs');
excel_path = fullfile(main_root, 'behavioural_data');
fieldtrip_path = '\fieldtrip-20230613'; % <-- Adjust path

% === Participant ===
subject_id = 'C18'; % adjust according to participant code
test = 'LET'; % can also be 'COR'
session = 'POST'; % can also be 'POST' or 'FU'
base_filename = [subject_id ' - ' test ' - ' session];
task_phases = {'ENC', 'INST', 'RETENTION', 'MANIPULATION', 'RET - RECALL', 'MAN - RECALL'};

% Add FIELDTRIP to path
addpath(fieldtrip_path);

% Import behavioural data
behav_path = fullfile(excel_path, subject_id, test, [base_filename '.xlsx']);
behav_data = readtable(behav_path);

%%  CONDUCT ANALYSIS AND PLOT RESULTS

% Pre-allocate structures to avoid errors later
data_struct = struct();
valid_trials = struct();
segmented_data_struct = struct();
clean_data_struct = struct();
power_data_struct = struct();

% To keep track of which phases were loaded successfully
processed_phases = {};

for i = 1:length(task_phases)
    
    phase = task_phases{i};
    fieldname = matlab.lang.makeValidName(phase); % cleans names like 'RET - RECALL' and convert them to 'RET_RECALL'
    dataset_name =  [data_path '\' subject_id '\' test '\' base_filename ' - FINAL - ' phase '.set'];

    % Check if dataset exists
    if ~isfile(dataset_name)
        fprintf('Dataset not found, skipping: %s\n', dataset_name);
        continue;
    end

    try
        % Load datasets
        cfg = [];
        cfg.dataset = dataset_name;
        data_struct.(fieldname) = ft_preprocessing(cfg);
    
        % Identify valid trials (trials with at least 3/6 correct answers - 50%)
        valid_trials.(fieldname) = get_valid_trials(test, behav_data, fieldname);

        % Skip if fewer than 7 valid trials out of 24 (>30%)
        if length(valid_trials.(fieldname)) < 7
            fprintf('Phase "%s" has fewer than 7 valid trials. Skipping.\n', phase);
            continue
        end
    
        % Segment valid trials into 1-sec epochs
        cfg = [];
        cfg.trials = valid_trials.(fieldname);
        cfg.length = 1;
        segmented_data_struct.(fieldname) = ft_redefinetrial(cfg, data_struct.(fieldname));
    
        % Look for noisy trials
        cfg = [];
        cfg.layout = 'EEG1010.lay';
        cfg.method = 'summary';
        clean_data_struct.(fieldname) = ft_rejectvisual(cfg, segmented_data_struct.(fieldname));

        % Skip if fewer than 15 valid epochs
        if length(clean_data_struct.(fieldname).trial) < 15
            fprintf('Phase "%s" has fewer than 15 valid epochs. Skipping.\n', phase);
            continue
        end
    
        % Calculate power spectrum (hanning taper)
        cfg = [];
        cfg.output = 'pow';
        cfg.channel = 'all'; % change the channels according to the interest
        cfg.trials = 'all'; % change number trials according to the interest
        cfg.method = 'mtmfft'; % Fast Fourier Transformation
        cfg.taper = 'hanning'; % we can change the taper method
        cfg.foi = 2:0.5:40; % 1/cfg.length  = 1;
        power_data_struct.(fieldname) = ft_freqanalysis(cfg, clean_data_struct.(fieldname));
    
        % Plot topographical maps
        cfg = [];
        cfg.layout      = 'EEG1010.lay';
        cfg.channel     = 'all'; % change channels to display
        cfg.trials      = 'all'; % change trials to display
        cfg.parameter   = 'powspctrm'; % we show the power spectrum
        figure ('Name', sprintf('Topography - %s - %s', fieldname, base_filename));
        ft_topoplotER(cfg,power_data_struct.(fieldname));
        colorbar
        saveas(gcf, fullfile(graphs_path, sprintf('Topoplot_%s_%s.png', fieldname, base_filename)));
        close(gcf)

        % Add this phase to the list of processed phases
        processed_phases{end+1} = fieldname;
    catch ME
        fprintf('Error processing phase "%s": %s\n', phase, ME.message);
        continue
    end
end

% Plot results of FFT (only processed phases)
if ~isempty(processed_phases)
    figure('Name','Comparison of power spectrum');
    hold on;
    for i = 1:length(processed_phases)
        fieldname = processed_phases{i};
        plot(power_data_struct.(fieldname).freq, power_data_struct.(fieldname).powspctrm(63,:))
    end
    legend(processed_phases, 'Interpreter','none')
    xlabel('Frequency (Hz)');
    ylabel('absolute power (uV^2)');
    saveas(gcf, fullfile(graphs_path, sprintf('comparison_power_spectrum_%s.png', base_filename)));
    close(gcf)
end
    
% Save power spectrum
save(fullfile(output_path, sprintf("power_data_struct_%s.mat", base_filename)), "power_data_struct");

%% FUNCTION TO IDENTIFY VALID TRIALS IN EXCEL FILE

function valid_trials = get_valid_trials(test, behav_data, task_name)

    % Define condition filters based on test type
    switch upper(test)
        case 'LET'
            retention_cond = 'Forward';
            manipulation_cond = 'Alphabetical';
            score_field = 'total_corr';
        case 'COR'
            retention_cond = 'Forward';
            manipulation_cond = 'Backward';
            score_field = 'correct_answer';
        otherwise
            error('Unknown test type: %s', test);
    end

    % Determine which condition to use based on task_name
    switch upper(task_name)
        case {'ENC', 'INST'}
            rows = find(strcmp(behav_data.condition, retention_cond) | strcmp(behav_data.condition, manipulation_cond));
            start_row = 5;  % skip first 4 (practice) trials
        case {'RETENTION', 'RET_RECALL'}
            rows = find(strcmp(behav_data.condition, retention_cond));
            start_row = 3;
        case {'MANIPULATION', 'MAN_RECALL'}
            rows = find(strcmp(behav_data.condition, manipulation_cond));
            start_row = 3;
        otherwise
            error('Unknown task name: %s', task_name);
    end

    % Check if enough trials exist after skipping practice
    if length(rows) < start_row
        valid_trials = [];
        return;
    end

    % Select analysis rows
    analysis_rows = rows(start_row:end);
    reindexed_rows = 1:length(analysis_rows);

    % Apply accuracy filter
    scores = behav_data.(score_field)(analysis_rows);
    valid = scores >= 3;

    valid_trials = reindexed_rows(valid);
end
