"""
EEG Feature Correlation Analysis
--------------------------------
This script loads EEG data and performs permutation-based Spearman correlations 
between macro-clustered EEG features and behavioural changes in scores in the 
Letter Span and Corsi Test from pre- to post-training session. Results are 
corrected using Benjamini-Hochberg FDR and visualised using bar plots.

Author: Esteban León-Correa
Last Updated: 28/05/2025
"""

from run_analysis import run_analysis

if __name__ == "__main__":

    # Adjust paths if necessary
    paths = {
        'LET_RET': 'data/LET_RET.xlsx',
        'LET_RET_tDCS': 'data/tDCS_LET_RET.xlsx',
        'LET_RET_Control': 'data/Control_LET_RET.xlsx',
        'LET_MAN': 'data/LET_MAN.xlsx',
        'LET_MAN_tDCS': 'data/tDCS_LET_MAN.xlsx',
        'LET_MAN_Control': 'data/Control_LET_MAN.xlsx',
        'COR_RET': 'data/COR_RET.xlsx',
        'COR_RET_tDCS': 'data/tDCS_COR_RET.xlsx',
        'COR_RET_Control': 'data/Control_COR_RET.xlsx',
        'COR_MAN': 'data/COR_MAN.xlsx',
        'COR_MAN_tDCS': 'data/tDCS_COR_MAN.xlsx',
        'COR_MAN_Control': 'data/Control_COR_MAN.xlsx'
        }

    features = {
        'RET': ['ENC_RET', 'RET_REC', 'ENC_REC_RET'],
        'MAN': ['ENC_MAN', 'MAN_REC', 'ENC_REC_MAN']
        }
    
    bands = ["theta", "Low Alpha", "High Alpha"]

    # Run
    for dataset_name, path in paths.items():
        final_features = "RET" if "RET" in dataset_name else "MAN"
        run_analysis(path, dataset_name, features[final_features], bands)