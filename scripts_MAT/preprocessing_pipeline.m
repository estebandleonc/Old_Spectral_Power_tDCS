%% EEG PREPROCESSING SCRIPT
% This script preprocesses EEG data using EEGLAB and prepares it for spectral analysis
% Author: Esteban León-Correa
% Last Updated: 23/05/25
% Compatible with EEGLAB 2022.1+

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
data_path = fullfile(main_root, 'data'); <-- Adjust path
output_path = fullfile(main_root, 'preprocessed_data');
eeglab_path = '\eeglab2022.1'; % <-- Adjust path

% === Participant ===
subject_id = 'NN'; % adjust according to participant code
test = 'LET'; % can also be 'COR'
session = 'PRE'; % can also be 'POST' or 'FU'
base_filename = [subject_id ' - ' test ' - ' session];

% Add EEGLAB to path
addpath(eeglab_path);
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% IMPORT DATA
EEG = pop_loadbv(fullfile(data_path, subject_id, test), [base_filename '.vhdr']);
EEG.setname = base_filename;

% Visual check
pop_eegplot(EEG, 1, 1, 1);

% Ensure output directory exists
output_dir = fullfile(output_path, subject_id, test);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

pop_saveset(EEG, 'filename', [base_filename ' - raw.set'], 'filepath', output_dir);

%% PREPARE DATA: CUT, RESAMPLE, CHANNEL EDIT
EEG = pop_select(EEG, 'time', [13 1741]); % <-- Adjust as needed
EEG = pop_resample(EEG, 512);
lookup_path = fullfile(eeglab_path, 'plugins', 'dipfit5.3', 'standard_BEM', 'elec', 'standard_1005.elc');
EEG = pop_chanedit(EEG, 'append',63,'changefield',{64,'labels','Cz'}, ...
    'lookup',lookup_path, ...
    'setref',{'1:63','Cz'});
pop_saveset(EEG, 'filename', [base_filename ' - Preparation.set'], 'filepath', output_dir);

%% FILTERING
EEG = pop_eegfiltnew(EEG, 'locutoff',1);
EEG = pop_eegfiltnew(EEG, 'hicutoff',40);

% Remove line noise
EEG = pop_cleanline(EEG, ...
    'chanlist', 1:63, ...
    'linefreqs', [24 48 50], ... # electric artifact at 24Hz
    'plotfigures', 0);
pop_saveset(EEG, 'filename', [base_filename ' - filtered.set'], 'filepath', output_dir);

%% REMOVE BAD SEGMENTS MANUALLY
% STEP 1: Visual inspection
pop_eegplot(EEG, 1, 1, 1);

% Alternatively, if you know the start and end of the segments you want to reject, you can input them here and you will not need to remove bad segments manually
% EEG = eeg_eegrej(EEG, [start1 end1; start2 end2]); 

%% STEP 2: Save the cleaned data (run this after rejection)
pop_saveset(EEG, 'filename', [base_filename ' - clean.set'], 'filepath', output_dir);

%% DETECT BAD CHANNELS
EEG_bad_chan = pop_clean_rawdata(EEG, ...
    'FlatlineCriterion', 5, ...
    'ChannelCriterion', 0.8, ...
    'LineNoiseCriterion', 4, ...
    'Highpass', 'off', ...
    'BurstCriterion', 'off', ...
    'WindowCriterion', 'off', ...
    'BurstRejection', 'off');

vis_artifacts(EEG_bad_chan, EEG);

%% REMOVE BAD CHANNELS (manually update labels below)
bad_channels = {}; % e.g., {'Fp1','F8'}
EEG.urchanlocs = EEG.chanlocs;
EEG = pop_select(EEG, 'nochannel', bad_channels);
pop_saveset(EEG, 'filename', [base_filename ' - no_bad_channels.set'], 'filepath', output_dir);

%% ICA PROCESSING
% Downsample for ICA
EEG_ica = pop_resample(EEG, 256);
EEG_ica = pop_runica(EEG_ica, 'extended', 1);

% Define file paths
file_clean = fullfile(output_path, subject_id, test, [base_filename ' - clean.set']);
file_no_bad_channels = fullfile(output_path, subject_id, test, [base_filename ' - no_bad_channels.set']);

% Reload respective dataset at 512Hz
if isfile(file_no_bad_channels)
    EEG = pop_loadset('filename', [base_filename ' - no_bad_channels.set'], 'filepath', fullfile(output_path, subject_id, test));
    fprintf('Loaded: %s\n', [base_filename ' - no_bad_channels.set']);
elseif isfile(file_clean)
    EEG = pop_loadset('filename', [base_filename ' - clean.set'], 'filepath', fullfile(output_path, subject_id, test));
    fprintf('Loaded: %s\n', [base_filename ' - clean.set']);
else
    error('Neither clean nor no_bad_channels dataset found');
end

% Apply ICA weights from downsampled dataset
EEG.icaweights = EEG_ica.icaweights;
EEG.icasphere = EEG_ica.icasphere;
EEG.icachansind = EEG_ica.icachansind;
EEG.icawinv = EEG_ica.icawinv;

% Label & reject components
EEG = pop_iclabel(EEG, 'default');
EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
pop_selectcomps(EEG, 1:EEG.nbchan);

pop_saveset(EEG, 'filename', [base_filename ' - preICA.set'], 'filepath', output_dir);

%% Final component rejection
EEG = pop_subcomp(EEG, [], 0);
pop_saveset(EEG, 'filename', [base_filename ' - ICA.set'], 'filepath', output_dir);

%% INTERPOLATE + REREFERENCE
EEG = pop_interp(EEG, EEG.urchanlocs, 'spherical');
EEG = pop_reref(EEG, [],'refloc',struct('labels',{'Cz'},'type',{''},'theta',{177.4959},'radius',{0.029055},'X',{-9.167},'Y',{-0.4009},'Z',{100.244},'sph_theta',{-177.4959},'sph_phi',{84.77},'sph_radius',{100.6631},'urchan',{64},'ref',{''},'datachan',{0}));
pop_saveset(EEG, 'filename', [base_filename ' - FINAL.set'], 'filepath', output_dir);

%% EPOCH EXTRACTION
EEG_enc         = pop_epoch(EEG, {'S  1'}, [0 8.5]);
EEG_instruc     = pop_epoch(EEG, {'S  2'}, [0 1]);
EEG_ret         = pop_epoch(EEG, {'S  3'}, [0 7.5]);
EEG_man         = pop_epoch(EEG, {'S  4'}, [0 10]);
EEG_ret_recall  = pop_epoch(EEG, {'S  5'}, [0 4]);
EEG_man_recall  = pop_epoch(EEG, {'S  6'}, [0 4]);

% Save all epochs
pop_saveset(EEG_enc, 'filename', [base_filename ' - FINAL - ENC.set'], 'filepath', fullfile(output_path, subject_id, test));
pop_saveset(EEG_instruc, 'filename', [base_filename ' - FINAL - INST.set'], 'filepath', fullfile(output_path, subject_id, test));
pop_saveset(EEG_ret, 'filename', [base_filename ' - FINAL - RETENTION.set'], 'filepath', fullfile(output_path, subject_id, test));
pop_saveset(EEG_man, 'filename', [base_filename ' - FINAL - MANIPULATION.set'], 'filepath', fullfile(output_path, subject_id, test));
pop_saveset(EEG_ret_recall, 'filename', [base_filename ' - FINAL - RET - RECALL.set'], 'filepath', fullfile(output_path, subject_id, test));
pop_saveset(EEG_man_recall, 'filename', [base_filename ' - FINAL - MAN - RECALL.set'], 'filepath', fullfile(output_path, subject_id, test));

%% Load dataset if needed

% Define the file path
filename = 'A16 - LET - PRE - FINAL - MAN - RECALL.set'; % example
filepath = fullfile('C:\Users\Esteban\Desktop\Github\tDCS\scripts_MAT\preprocessed_data\A16\LET');  % adjust to your folder structure

% Load the dataset
EEG = pop_loadset('filename', filename, 'filepath', filepath);
