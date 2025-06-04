import os
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.stats.multitest import multipletests
import seaborn as sns
from permutation_utils import permutation_spearman, bootstrap_ci
from macro_regions import get_macro_clusters


def analyse_features(data, feature_keyword, dataset_name, output_dir = 'outputs'):
    # Filter features based on the keyword
    X = data.filter(regex=f'{feature_keyword}').copy()
    y = data['Score']

    # Define macro clusters
    clusters = get_macro_clusters()

    # Calculate regional averages
    for region, channels in clusters.items():
        X[region] = X.loc[:, X.columns.str.contains('|'.join(channels))].mean(axis=1)

    # Keep only the macro region features
    X = X.loc[:, clusters.keys()]
    if X.empty:
        print(f"No features found for keyword: {feature_keyword}")
        return

    # Calculate permutation-based Spearman correlation for each feature
    correlation_results = []
    for column in X.columns:
        corr, p_empirical = permutation_spearman(X[column], y, n_permutations=1000, random_state=42)
        ci_low, ci_high = bootstrap_ci(X[column], y, random_state=42)
        correlation_results.append((column, corr, p_empirical, ci_low, ci_high))
    
    # Convert results to DataFrame
    correlation_df = pd.DataFrame(correlation_results, columns=['Feature', 
                                                                'Spearman Correlation', 
                                                                'Empirical p-value', 
                                                                'CI Lower', 
                                                                'CI Upper']
    )

    # Apply Benjamini-Hochberg correction
    rejected, p_adjusted, _, _ = multipletests(correlation_df['Empirical p-value'], method='fdr_bh')
    
    # Add adjusted p-values to DataFrame
    correlation_df['Adjusted p-value'] = p_adjusted

    # Filter for significant correlations (e.g., adjusted p-value < 0.05)
    sig_corr_adjusted = correlation_df[correlation_df['Adjusted p-value'] < 0.05].copy()

    # Check if there are any significant correlations
    if sig_corr_adjusted.empty:
        print(f"No significant correlations found for {feature_keyword} after correction.")
    else:
        # Sort by absolute value of correlation
        sig_corr_adjusted['Absolute Correlation'] = sig_corr_adjusted['Spearman Correlation'].abs()
        sig_corr_adjusted = sig_corr_adjusted.sort_values(by='Absolute Correlation', ascending=False)

        # Plot the significant correlation results
        plt.figure(figsize=(20, 16))
        sns.barplot(x='Spearman Correlation', y='Feature', data=sig_corr_adjusted, palette='viridis')
        plt.title(f'Significant Spearman Correlations between {feature_keyword} and Score (Adjusted) - {dataset_name}')
        plt.gca().set_ylabel('')  # Remove the label on the y-axis
        
        # Save plot
        os.makedirs(output_dir, exist_ok=True)
        plt.savefig(os.path.join(output_dir, f'{dataset_name}_{feature_keyword}.png'))
        plt.close()
        
        # Save correlations
        sig_corr_adjusted.to_excel(os.path.join(output_dir, f'{dataset_name}_{feature_keyword}.xlsx'), index=False)