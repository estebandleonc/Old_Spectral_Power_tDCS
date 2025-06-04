%% CLUSTER-BASED PERMUTATION TESTS
% This function conducts cluster-based permuation tests
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

%% Conduct cluster based permutation test
function [stats, design] = run_cluster_perm(data_1, data_2, freq_range)

    % Prepare neighbours to determine clusters
    cfg                  = [];
    cfg.method           = 'triangulation'; % 'distance', 'triangulation' or 'template' depending on your preference
    cfg.minnbchan        = 2; % minimum number of neighborhood channels that is required for a selected sample to be included
    cfg.feedback         = 'no'; % to see a representation of the clusters
    cfg_neighb           = ft_prepare_neighbours(cfg, data_1);

    % Configuration for cluster-based permutation test for frequency data
    cfg = [];
    cfg.channel          = 'all';
    cfg.latency          = 'all'; % Not strictly necessary for freq data
    cfg.frequency        = freq_range; % [min max] for band of interestt
    cfg.method           = 'montecarlo'; % Permutation-based testing
    cfg.statistic        = 'ft_statfun_depsamplesT'; % Paired T-test
    cfg.correctm         = 'cluster'; % Multiple comparison correction
    cfg.clusteralpha     = 0.05; % Threshold for clustering
    cfg.clusterstatistic = 'maxsum'; % is the maximum of the cluster-level statistics. A cluster-level statistic is equal to the sum of the sample-specific T-statistics that belong to this cluster. And we take the largest of these cluster-level statistics of the different clusters.
    cfg.tail             = 0; % Two-sided test
    cfg.clustertail      = 0; % Two-sided test
    cfg.alpha            = 0.05; % Significance level
    cfg.numrandomization = 10000; % Number of permutations
    cfg.neighbours       = cfg_neighb; % Channel neighbourhood
    cfg.correcttail      = 'prob'; % Correct for two-tailed distribution

    % Design matrix for within-subjects comparison
    num_subjects = size(data_1.powspctrm, 1);
    design = [1:num_subjects 1:num_subjects; ones(1, num_subjects) 2*ones(1, num_subjects)];
    cfg.design = design;
    cfg.uvar = 1; % subject number
    cfg.ivar = 2; % condition (data_1 vs data_2)

    % Run permutation test
    stats = ft_freqstatistics(cfg, data_1, data_2);
