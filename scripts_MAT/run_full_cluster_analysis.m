%% FULL STATISTICAL ANALYSIS
% This function conducts cluster-based permutation tests, effect sizes and plots significant clusters.
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

%% Cluster based permutation tests, graphs and effect sizes
function [stats_final, effect_sizes] = run_full_cluster_analysis(grandavg_log, test, main_root)

    % File path to save data
    folderpath_data = fullfile(main_root, 'statistics_data');
    
    % File path to save graphs
    folderpath_graphs = fullfile(main_root, 'statistics_data\graphs');
    
    % Define the frequency bands
    frequency_bands = {'theta', 1; 'low_alpha', 2; 'high_alpha', 3};
    
    % Variables
    WM_phase = {'ENC', 'INST', 'RETENTION', 'MANIPULATION', 'RET_RECALL', 'MAN_RECALL'};
    comparison_pairs = {
        {'data_exp', 'PRE', 'POST', 'FU', 'tDCS'},
        {'data_control', 'PRE', 'POST', 'FU', 'Control'}
        };
    
    % Create strct to store data
    stats_final = struct();
    effect_sizes = struct();
    
    % Loop over datasets and sessions
    for pair_idx = 1:length(comparison_pairs)
        condition = comparison_pairs{pair_idx}{1};
        pre_session = comparison_pairs{pair_idx}{2};
        post_session = comparison_pairs{pair_idx}{3};
        fu_session = comparison_pairs{pair_idx}{4};
        group_label = comparison_pairs{pair_idx}{5};
    
        % Loop for each WM phase
        for w = 1:length(WM_phase)
            phase = WM_phase{w};
    
            % Safely check for required fields
            if ~isfield(grandavg_log, condition)
                fprintf('Dataset "%s" not found. Skipping.\n', condition);
                continue
            end
    
            % Create struct to check if data is available
            dataset_struct = grandavg_log.(condition);
    
            if ~isfield(dataset_struct, pre_session) || ...
               ~isfield(dataset_struct, post_session)
                fprintf('Session data missing for %s (%s or %s). Skipping phase "%s".\n', ...
                        condition, pre_session, post_session, phase);
                continue
            end
    
            % Check if specific phase exists
            pre_has_phase = isfield(dataset_struct.(pre_session), phase);
            post_has_phase = isfield(dataset_struct.(post_session), phase);
            fu_has_phase = isfield(dataset_struct, fu_session) && ...
                           isfield(dataset_struct.(fu_session), phase);
    
            if ~(pre_has_phase && post_has_phase)
                fprintf('Missing phase "%s" in %s pre/post. Skipping.\n', phase, condition);
                continue
            end
    
            % Extract data (using dynamic fieldnames)
            pre  = dataset_struct.(pre_session).(phase);
            post = dataset_struct.(post_session).(phase);
    
            if fu_has_phase
                fu = dataset_struct.(fu_session).(phase);
            else
                fu = []; % Mark as missing
            end
        
            % Loop over each frequency band
            for i = 1:size(frequency_bands, 1)
                band_name = frequency_bands{i, 1};
                freq_range = frequency_bands{i, 2};
                
                % Run cluster based permutation test between pre- and post-training sessions
                [stats, design] = run_cluster_perm(pre, post, freq_range);
                stats_final.(group_label).(phase).(band_name).pre_post = stats;
                
                % Plot significant clusters if they exist
                sig = plot_cluster(stats);
                
                if sig
                    % Save plot
                    plot_name = sprintf('Significant_clusters_%s_%s_%s_%s.png', group_label, phase, band_name, test);
                    filepath_graphs = fullfile(folderpath_graphs, plot_name);
                    saveas(gcf, filepath_graphs);
                    close(gcf);
                
                    % Calculate effect size
                    effect_sizes.(group_label).(phase).(band_name).pre_post = effect_sizes_clusters(pre, post, stats, freq_range, design);
                else
                    fprintf('No significant clusters: %s-%s-%s (pre-post)\n', group_label, phase, band_name);
                end
    
                % Run statistical analysis of follow-up session if data is available
                if ~isempty(fu)
                    % Exclude participants with no FU (only from POST)
                    if strcmp(group_label, 'tDCS')
                        % Remove A13 (index 6) and A23 (index 14) from POST
                        post.powspctrm([6 14],:,:,:) = [];
                    elseif strcmp(group_label, 'Control')
                        % Remove C9 (index 4) and C10 (index 5) from POST
                        post.powspctrm([4 5],:,:,:) = [];
                    end
    
                    % Run cluster based permutation test between post-training and follow_up sessions
                    [stats, design] = run_cluster_perm(post, fu, freq_range, cfg_neighb);
                    stats_final.(group_label).(phase).(band_name).post_fu = stats;
    
                    % Plot significant clusters if they exist
                    sig = plot_cluster(stats);
    
                    if sig
                        % Save plot
                        plot_name = sprintf('Significant_clusters_%s_%s_%s_%s_FU.png', group_label, phase, band_name, test);
                        filepath_graphs = fullfile(folderpath_graphs, plot_name);
                        saveas(gcf, filepath_graphs);
                        close(gcf);
        
                        % Calculate effect size
                        effect_sizes.(group_label).(phase).(band_name).post_fu = effect_sizes_clusters(post, fu, stats, freq_range, design);
                    else
                        fprintf('No significant clusters: %s-%s-%s (post-fu)\n', group_label, phase, band_name);
                    end
                    fprintf('No FU data for %s phase "%s". Skipping post-FU comparison.\n', group_label, phase);
                end
            end
        end
    end
    
    % Save files
    save(fullfile(folderpath_data, sprintf('stats_final_%s.mat', test)), 'stats_final'); % stats
    save(fullfile(folderpath_data, sprintf('effect_sizes_%s.mat', test)), 'effect_sizes'); % effect sizes
end
