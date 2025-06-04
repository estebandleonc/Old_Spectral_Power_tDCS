%% EFFECT SIZES - CLUSTER ANALYSIS
% This function calculates effect sizes of clusters.
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

%% Effect size function
function [effect_sizes] = effect_sizes_clusters(data_1, data_2, stats, freq_range, design)

    % Calculate effect size (Cohen's d)
    cfg = [];
    cfg.parameter       = 'powspctrm';
    cfg.frequency       = freq_range;
    cfg.method          = 'analytic';
    cfg.statistic       = 'cohensd';
    cfg.design          = design;
    cfg.ivar            = 1;
    effect_all          = ft_freqstatistics(cfg, data_1, data_2);

    % Obtain max effect (positive cluster - upper bound)
    [max_val, ind] = max(effect_all.cohensd(:));
    [i, j]   = ind2sub(size(effect_all.cohensd), ind);
    Pos.max_cohensd = max_val;
    Pos.max_label = effect_all.label{i};
    Pos.max_freq = effect_all.freq(j);
    
    % Obtain max effect (negative cluster - upper bound)
    [min_val, ind] = min(effect_all.cohensd(:));
    [i, j]   = ind2sub(size(effect_all.cohensd), ind);
    Neg.max_cohensd = min_val;
    Neg.max_label = effect_all.label{i};
    Neg.max_freq = effect_all.freq(j);
    
    % --------------------------------
    % Positive cluster
    % --------------------------------

    % Determine frequency and channels of the largest positive cluster
    if isfield(stats, 'posclusters') && ~isempty(stats.posclusters)
        [Pos.chan,Pos.freq] = find(stats.posclusterslabelmat==1);
        idx_freq_min = min(Pos.freq);
        idx_freq_max = max(Pos.freq);

        % Estimate rectangular window around this cluster for lower bound
        Pos.rect_freq_min = stats.freq(idx_freq_min);
        Pos.rect_freq_max = stats.freq(idx_freq_max);
        Pos.rect_chan = stats.label(any(stats.mask(:,idx_freq_min:idx_freq_max),2));

        % Calculate effect size for positive cluster (Cohen's d) within this rectangular window (lower bound)
        cfg                     = [];
        cfg.channel             = Pos.rect_chan;
        cfg.latency             = 'all';
        cfg.frequency           = [Pos.rect_freq_min Pos.rect_freq_max];
        cfg.avgoverchan         = 'yes';
        cfg.avgoverfreq         = 'yes';
        cfg.method              = 'analytic';
        cfg.statistic           = 'cohensd';
        cfg.design              = design;
        cfg.ivar                = 1;
        Pos.effect_rectangle    = ft_freqstatistics(cfg, data_1, data_2);
    else
        Pos = struct(); % no cluster found
    end

    % --------------------------------
    % Negative cluster
    % --------------------------------
    
    % Determine frequency and channels of the largest negative cluster
    if isfield(stats, 'negclusters') && ~isempty(stats.negclusters)
        [Neg.chan,Neg.freq] = find(stats.negclusterslabelmat==1);
        idx_freq_min = min(Neg.freq);
        idx_freq_max = max(Neg.freq);
    
        % Estimate rectangular window around this cluster for lower bound
        Neg.rect_freq_min = stats.freq(idx_freq_min);
        Neg.rect_freq_max = stats.freq(idx_freq_max);
        Neg.rect_chan = stats.label(any(stats.mask(:,idx_freq_min:idx_freq_max),2));
    
        % Calculate effect size for negative cluster (Cohen's d) within this rectangular window
        cfg                     = [];
        cfg.channel             = Neg.rect_chan;
        cfg.latency             = 'all';
        cfg.frequency           = [Neg.rect_freq_min Neg.rect_freq_max];
        cfg.avgoverchan         = 'yes';
        cfg.avgoverfreq         = 'yes';
        cfg.method              = 'analytic';
        cfg.statistic           = 'cohensd';
        cfg.design              = design;
        cfg.ivar                = 1;
        Neg.effect_rectangle    = ft_freqstatistics(cfg, data_1, data_2);
    else
        Neg = struct(); % no cluster found
    end
    
    % Save effect sizes
    effect_sizes.Pos = Pos;
    effect_sizes.Neg = Neg;
end