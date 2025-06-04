import pandas as pd
from analyse_features import analyse_features

def run_analysis(data_path, dataset_name, features, bands, output_dir = 'outputs'):
    data = pd.read_excel(data_path)
    for f in features:
        for b in bands:
            feature_keyword = f"{f}_{b}"
            analyse_features(data, feature_keyword, dataset_name, output_dir)