%% STATISTICAL ANALYSIS
% This function plots significant clusters.
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

%% Plot significant clusters
function has_significant_clusters = plot_cluster(stats)
    has_significant_clusters = false; 
    
    % Check for significant clusters
    if isfield(stats, 'posclusters')
        for j = 1:length(stats.posclusters)
            if stats.posclusters(j).prob <= 0.05
                has_significant_clusters = true;
                break;
            end
        end
    end

    if isfield(stats, 'negclusters')
        for j = 1:length(stats.negclusters)
            if stats.negclusters(j).prob <= 0.05
                has_significant_clusters = true;
                break;
            end
        end
    end
    
    % Plot significant clusters if they exist
    if has_significant_clusters
        cfg = [];
        cfg.highlightsymbolseries = ['*','*','.','.','.'];
        cfg.layout                = 'EEG1010.lay';
        cfg.contournum            = 0;
        cfg.markersymbol          = '.';
        cfg.alpha                 = 0.05;
        cfg.parameter             = 'stat';
        cfg.zlim                  = 'maxabs'; % Optional: auto-scale
    
        ft_clusterplot(cfg, stats);
    else
        disp('No significant clusters to plot');
    end
end