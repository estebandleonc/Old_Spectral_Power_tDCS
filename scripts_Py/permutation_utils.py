from scipy.stats import spearmanr
import numpy as np

#%% FUNCTION FOR PERMUTATION
def permutation_spearman(x, y, n_permutations=1000, random_state=None):
    rng = np.random.default_rng(random_state)
    observed_corr, _ = spearmanr(x, y)
    permuted_corrs = []

    for _ in range(n_permutations):
        y_permuted = rng.permutation(y)
        corr, _ = spearmanr(x, y_permuted)
        permuted_corrs.append(corr)

    permuted_corrs = np.array(permuted_corrs)
    # Two-tailed empirical p-value
    p_empirical = np.mean(np.abs(permuted_corrs) >= np.abs(observed_corr))
    
    return observed_corr, p_empirical

#%% FUNCTION FOR BOOTSTRAPPING
def bootstrap_ci(x, y, n_bootstraps=1000, ci=95, random_state=None):
    rng = np.random.default_rng(random_state)
    corrs = []
    n = len(x)
    for _ in range(n_bootstraps):
        idx = rng.integers(0, n, n)
        corr, _ = spearmanr(x.iloc[idx], y.iloc[idx])
        corrs.append(corr)
    lower = np.percentile(corrs, (100 - ci) / 2)
    upper = np.percentile(corrs, 100 - (100 - ci) / 2)
    return lower, upper