# tDCS-EEG Study Analysis

## Description:
This project investigated the behavioural and neural effects of transcranial direct current stimulation (tDCS) on distinct working memory (WM) phases (encoding, retention, manipulation, and recall) in older adults. Over three weeks, participants completed six sessions of adaptive WM training paired with either active or sham tDCS targeting the left dorsolateral prefrontal cortex (DLPFC). Neural activity was recorded using a 64-channels EEG (BrainVision Recorder), with a focus on theta and alpha frequency bands.

Participants completed two WM tests (Letter Span and Corsi Test) with both retention and manipulation conditions. The training tasks were adaptive versions of Digit Span (incorporating arithmetic operations, similar to the OSPAN) and a visuospatial N-back task.


## Contents
This repository includes:
- Scripts_MAT: MATLAB scripts and functions for EEG data cleaning, spectral analysis, frequency band creation, cluster-based permutation testing (Monte Carlo), plotting of results, and calculation of effect sizes.
- Scripts_Py: Python scripts for conducting cluster-based Spearman correlations to explore associations between behavioural and neural changes.
- Scripts_R: R scripts for visualising behavioural data and performing linear mixed-effects modelling (LMEMs) to examine training, transfer, and long-term effects, as well as individual differences.


## Requirements:
- Microsoft Excel 2010 or later
(used to load behavioural datasets in .xlsx format located in scripts_MAT/behavioural_data/, which are required by preprocessing_pipeline.m; and in scripts_Py/data, which are required by correlation_data_export.m and main.py)
- IBM SPSS Statistics 30.0 or later
(required to open behavioural datasets in .sav format, also used during behavioural data processing)
- Python 3.10 or later (see required libraries in requirements.txt inside of the scripts_Py folder)
(for cluster-based neural-behavioural correlation analyses)
- MATLAB R2021 or later
(Required toolboxes: EEGLAB, FieldTrip)
- RStudio 2023b or later (see required libraries in requirements.txt inside of the scripts_R folder)
(for running the R scripts with behavioural data analysis)


## Data
**1. Behavioural Data:**
- Stored in .xlsx format in scripts_MAT/behavioural_data/, which are required by preprocessing_pipeline.m; and in scripts_Py/data, which are required by correlation_data_export.m and main.py)
- Stored in .sav format in scripts_R/scripts/datasets/, which are required for statistical analysis of behavioural data in R.

**2. EEG Example Data:**
- Located in scripts_MAT/example_data/
- Use these datasets to test and familiarise yourself with the EEG preprocessing and analysis pipelines


## How to Use
**1. Clone or download** this repository.

**2. EEG preprocessing:**
- Use preprocessing_pipeline.m in scripts_MAT/ to convert raw EEG data into epochs for each WM phase.
- Requires EEGLAB.
- This pipeline is participant-, session-, and test-specific, and includes visual inspection and manual (or automated) rejection of bad channels, segments, and ICA components.

**3. Spectral analysis:**
- Use spectral_analysis_pipeline.m in scripts_MAT/ to compute and plot the power spectrum.
- Requires FieldTrip.
- Manual inspection for artifact rejection is included.

**4. Statistical analysis:**
- Run main.m in scripts_MAT/ to conduct cluster-based permutation tests, calculate effect sizes (with confidence bounds), and visualise significant clusters.

**5. Behavioural analysis:**
- Run Analysis_tests.R in scripts_R/scripts/ to visualise Letter Span and Corsi Test results, run LMEMs for transfer and long-term effects and explore individual differences.

**6. Training data analysis:**
- Run Analysis_training.R in scripts_R/scripts/ to visualise training task performance, run LMEMs for training effects and explore individual differences.

**7. Predictive modelling:**
- Run Analysis_training_tests.R in scripts_R/scripts/ to conduct linear regressions linking training performance to WM test improvements.

**8. Neural-behavioural correlations:**
- Run main.py in scripts_Py/ to compute cluster-based Spearman correlations between EEG and behavioural outcomes


## License:
Distributed under the MIT Licence.

## Author:
Esteban León-Correa
Cognitive Psychologist
Edge Hill University 
