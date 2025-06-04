%% ANALYSIS OF NEUROPHYSIOLOGYCAL DATA
% This script conducts cluster-based permutation tests and plots significant clusters.
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

%% RUN ANALYSIS

% Add FIELDTRIP to path
fieldtrip_path = '\fieldtrip-20230613'; % <-- Adjust path
addpath(fieldtrip_path);

% Step 1: Define main directory
main_root = '\scripts_MAT'; % <-- Adjust path
addpath(main_root)

% Step 2: Define test of interest
test = 'LET'; % or 'COR'

% Step 3: Load data
grandavg = load_power_data(main_root, test);

% Step 4: Run transformation
grandavg_log = data_transformation(grandavg);

% Step 5: Conduct permutation tests
[stats_final, effect_sizes] = run_full_cluster_analysis(grandavg_log, test, main_root);

% Step 6:Export excel files with behavioural and neurophysiological data to conduct correlation analysis in Python
behaviour_data_folder = "\scripts_Py\data\behavioural_data_correlations.xlsx"; % <-- Adjust path
data_folder = "\scripts_Py\data"; % <-- Adjust path
correlation_data_export(grandavg_log, test, behaviour_data_folder, data_folder);
