%% IMPORT PROCESSED  DATA FILES
% This function imports EEG processed data of the pre-training, post-training and follow_up sessions of two WM tests
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

%% FUNCTION TO IMPORT DATASETS

function [grandavg] = load_power_data(main_root, test)
% load_power_data - Loads power data structs for experimental and control groups.
%
% Inputs:
%   main_root - Path to the root folder of the project
%   test      - 'LET' or 'COR' to select the test
%
% Outputs:
%   data_exp     - Structure with loaded data for experimental group
%   data_control - Structure with loaded data for control group
    
    % Path
    data_path = fullfile(main_root, 'processed_data');

    % Define the subject numbers to include
    EXP = [7:11, 13, 15:17, 19:25]; % experimental group
    CONTROL = [6:14, 17:18, 20, 22:23, 25, 27]; % control group
    
    % Variables
    session = {'PRE', 'POST', 'FU'};
    condition = {'A', 'C'}; % A = tDCS, C = Control

    % Create struct to hold data
    grandavg = struct();
    
    % Import datasets
    for c = 1:length(condition)
        current_condition = condition{c}; 
    
        % Choose subject list and data struct
        if strcmp(current_condition, 'A')
            subject_list = EXP;
        elseif strcmp(current_condition, 'C')
            subject_list = CONTROL;
        else
            fprintf('Unknown condition: %s\n', current_condition);
            continue;
        end
    
        for s = 1:length(session) % loop over sessions
            current_session = session{s}; 
            
            % Preallocate with empty cells
            session_data = cell(1, length(subject_list));
                
            for i = 1:length(subject_list)
                % Construct the directory path for each subject
                filePath = fullfile(data_path, sprintf('power_data_struct_%s%d - %s - %s.mat', current_condition, subject_list(i), test, current_session));
            
                % Check if the file exists
                if exist(filePath, 'file') == 2
                    % Load the file
                    loadedData = load(filePath);
                        
                    % Extract the variable name from the loaded data
                    variableName = fieldnames(loadedData);
                        
                    % Store the loaded data in the cell array
                    session_data{i} = loadedData.(variableName{1});
                else
                    % Display a message indicating that the file was not found
                    fprintf('File not found: %s\n', filePath);
                end
            end

            % Remove empty cells
            session_data = session_data(~cellfun('isempty', session_data));

            % Save data into the appropriate struct
            if strcmp(current_condition, 'A')
                grandavg.data_exp.(current_session) = session_data;
            else
                grandavg.data_control.(current_session) = session_data;
            end
        end
    end
end