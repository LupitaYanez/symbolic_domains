### 01_import_raw_eeg_to_eeglab.m

Imports raw Neuronic `.REC` EEG recordings into EEGLAB and prepares participant-by-domain datasets for preprocessing. The script adds event markers from external `.txt` files, assigns standard 10–20 channel locations, corrects signal polarity after import, and saves the resulting datasets as EEGLAB `.set` files.

**Inputs**
- Raw EEG recordings in `.REC` format
- Event files with latency, event type, and pulse information
- Standard 10–20 channel location file

**Outputs**
- EEGLAB `.set` files for each participant and stimulus domain

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical

### 02_bandpass_filter_eeg.m

Loads imported EEGLAB `.set` files and applies an offline band-pass filter to EEG channels. Filtered participant-by-domain datasets are saved as new EEGLAB `.set` files for subsequent preprocessing.

**Inputs**
- EEGLAB `.set` files from `01_import_raw_eeg_to_eeglab.m`

**Outputs**
- Filtered EEGLAB `.set` files

**Filtering parameters**
- Channels: `1:13`
- Band-pass filter: `0.1–18 Hz`
- Filter design: Butterworth IIR
- Filter order: `2`
- DC offset removal: enabled

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical

### 03_create_eventlist_and_epochs.m

Loads filtered EEGLAB `.set` files, creates ERPLAB event lists, updates event code labels, and creates epoched datasets for ERP preprocessing.

**Inputs**
- Filtered EEGLAB `.set` files from `02_bandpass_filter_eeg.m`
- ERPLAB event list definition file: `eList.txt`

**Outputs**
- EEGLAB datasets with ERPLAB event lists
- Epoched EEGLAB datasets
- Exported event list `.txt` files for each participant and stimulus domain

**Epoching parameters**
- Epoch window: `-100 to 500 ms`
- Baseline correction: prestimulus interval

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical

### 04_reject_behavioral_and_eeg_artifacts.m

Loads epoched EEGLAB datasets, marks epochs associated with incorrect or out-of-range behavioral responses, detects EEG/EOG artifacts, and removes contaminated epochs. Cleaned participant-by-domain datasets are saved as new EEGLAB `.set` files.

**Inputs**
- Epoched EEGLAB `.set` files from `03_create_eventlist_and_epochs.m`
- `IncorResp.mat` file containing epoch indices for incorrect or out-of-range behavioral responses

**Outputs**
- Cleaned EEGLAB `.set` files
- Artifact detection summary `.txt` files

**Behavioral exclusion**
- Incorrect responses
- Responses outside the valid RT range

**Artifact detection**
- Blink detection using EOG channels
- Step-like artifact detection using EOG channels
- Moving-window peak-to-peak artifact detection across EEG/EOG channels
- Flatline detection

**Artifact detection parameters**
- Blink channels: `12:13`
- Blink width: `200 ms`
- Blink cross-covariance threshold: `0.7`
- Step threshold: `40 µV`
- Moving-window peak-to-peak threshold: `100 µV`
- Flatline threshold: `-1 to 1 µV`
- Artifact detection window: `-100 to 500 ms`

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical

### 05_equalize_trials_per_bin.m

Loads cleaned EEGLAB datasets and removes extra epochs so that each bin has an equal number of accepted trials per participant and stimulus domain. The epoch indices to remove are read from external `_non-selected.txt` files.

**Inputs**
- Cleaned EEGLAB `.set` files from `04_reject_behavioral_and_eeg_artifacts.m`
- Text files containing epoch indices to remove

**Outputs**
- EEGLAB `.set` files with balanced trial counts per bin

**Trial equalization**
- Target accepted epochs per bin: `30`

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical

### 06_create_individual_erps_and_trial_counts.m

Creates individual ERP averages from equalized EEGLAB datasets and exports the final number of accepted trials per bin for each participant and stimulus domain.

**Inputs**
- Equalized EEGLAB `.set` files from `05_equalize_trials_per_bin.m`

**Outputs**
- Individual ERPLAB `.erp` files
- Excel file with accepted trial counts per bin: `TrialsPerBin.xlsx`

**Averaging parameters**
- Only good/accepted trials are included
- Boundary events are excluded
- Standard error of the mean is computed

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical


### 07_append_individual_domain_erps.m

Loads individual ERPLAB `.erp` files for the three stimulus domains and appends them into a single ERP file per participant. Domain prefixes are added to preserve the identity of algebraic, graphical, and lexical bins.

**Inputs**
- Individual ERPLAB `.erp` files from `06_create_individual_erps_and_trial_counts.m`

**Outputs**
- Appended ERPLAB `.erp` files containing all three stimulus domains for each participant

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical


### 08_export_erp_mean_amplitudes.m

Exports ERP mean-amplitude measurements from the final appended participant-level `.erp` files. Measurements are extracted for congruent bins (`1:12`) across the early sensory window (`0–180 ms`) and the late context-sensitive window (`250–500 ms`) using channels `1:11`. Outputs are saved as wide-format text files for subsequent statistical analysis in SPSS.



### 09b_early_window_roi_position_model.sps

Analyzes early ERP activity in the `0–180 ms` window across all sequence positions and scalp regions.

This analysis tests whether early activity changes across sequence position and whether any position-related effect depends on scalp region or stimulus domain. It serves as a complementary control analysis to determine whether the progressive centro-parietal pattern observed in the late window is already present in the early sensory window.

**Inputs**
- Wide-format ERPLAB mean-amplitude table for the `0–180 ms` window

**ROIs**
- Occipital: `O1/O2`
- Parietal: `P3/Pz/P4`
- Central: `C3/Cz/C4`
- Frontal: `F3/Fz/F4`

**Processing steps**
- Computes ROI means for each domain, sequence position, and scalp region
- Converts the data from wide to long format
- Creates categorical factors for:
  - `Domain`
  - `SequencePosition`
  - `ROI`
- Codes sequence position as an ordinal predictor:
  - `A = 0`
  - `B = 1`
  - `C = 2`
  - `D = 3`
- Optionally codes region as a posterior-to-anterior ordinal predictor:
  - `Occipital = 0`
  - `Parietal = 1`
  - `Central = 2`
  - `Frontal = 3`

**Model 1: ROI × Position model**
- Linear mixed-effects model with fixed effects of:
  - `Domain`
  - `ROI`
  - `Position`
  - `Domain × ROI`
  - `Domain × Position`
  - `ROI × Position`
  - `Domain × ROI × Position`
- Random slope of `Position` by participant

**Model 2: Ordinal posterior-to-anterior model**
- Linear mixed-effects model testing whether the posterior-to-anterior gradient changes across sequence position or domain.

**Outputs**
- Test of early regional differences across ROIs
- Test of whether early activity changes across sequence position
- Test of whether any position-related change differs by ROI
- Test of whether the posterior-to-anterior gradient changes across sequence position or domain

**Stimulus domains**
- `A`: Algebraic
- `G`: Graphical
- `L`: Lexical

**Sequence positions**
- `A`: first sequence element
- `B`: second sequence element
- `C`: third sequence element
- `D`: final completion element



### 10_late_window_roi_position_model.sps

Computes regional ROI mean amplitudes in the 250–500 ms window and tests whether the sequence-position effect varies across scalp regions.

**Inputs**
- Wide-format ERPLAB mean-amplitude table for the `250–500 ms` window

**ROIs**
- Frontal: `F3/Fz/F4`
- Central: `C3/Cz/C4`
- Parietal: `P3/Pz/P4`
- Occipital: `O1/O2`

**Processing steps**
- Computes ROI means for each stimulus domain and sequence position
- Converts the data from wide to long format
- Creates categorical factors for `Domain`, `SequencePosition`, and `ROI`
- Codes sequence position as an ordinal predictor:
  - `A = 0`
  - `B = 1`
  - `C = 2`
  - `D = 3`

**Model**
- Linear mixed-effects model with fixed effects of:
  - `Domain`
  - `ROI`
  - `Position`
  - `Domain × ROI`
  - `Domain × Position`
  - `ROI × Position`
  - `Domain × ROI × Position`
- Random slope of `Position` by participant

**Outputs**
- Test of whether the position-related increase differs across scalp regions (`ROI × Position`)
- Test of whether this regional pattern differs across domains (`Domain × ROI × Position`)
- Planned slope contrasts comparing selected ROIs


### 11_late_transition_model_parietal.sps

Computes adjacent transition differences (`B–A`, `C–B`, `D–C`) in the 250–500 ms window within the parietal ROI (`P3/Pz/P4`). The script reshapes the data from wide to long format and runs a linear mixed-effects model with `Domain`, `Transition`, and their interaction as fixed effects, and participant as a random intercept.

**Inputs**
- Wide-format ERPLAB mean-amplitude table for the `250–500 ms` window

**Outputs**
- Mixed-model results for transition effects
- Bonferroni-adjusted comparisons among transitions


### 11_late_transition_model_central.sps

Computes adjacent transition differences in the 250–500 ms window within the central ROI (`C3/Cz/C4`) and tests whether the size of the increase differs across sequence transitions (`B–A`, `C–B`, `D–C`) using a linear mixed-effects model.


### 12_behavioral_accuracy_rt_anova.sps

Analyzes behavioral performance across the three stimulus domains.

The script runs two repeated-measures ANOVAs with `Domain` as a within-subject factor with three levels: algebraic, graphical, and lexical.

**Input variables**

Reaction time:

```text
Alg_TR
Gra_TR
Lex_TR

