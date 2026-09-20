# Symbolic Domains ERP Dataset and Reproducible Analysis Resources

This repository provides de-identified participant-level preprocessed ERP signals, task-design files, stimulus materials, documentation, and analysis code associated with the publication:

**Yáñez-Ramos, M. G., Zarabozo Enríquez de Rivera, D., & González Garrido, A. A.**  
*Position-Related Centro-Parietal ERP Responses During Contextual Processing Across Symbolic Domains.*  
**Biological Psychology, 210**, 109374.  
https://doi.org/10.1016/j.biopsycho.2026.109374

## Dataset overview

The study examined how event-related potential (ERP) activity changes across successive positions in structured symbolic sequences. Participants processed four-element sequences from three symbolic domains:

- Lexical sentences
- Algebraic monomial operations
- Graphical line-based image compositions

The primary analyses focused on ERP mean amplitudes in the 250–500 ms interval, with additional analyses of early-window activity in the 0–180 ms interval.

The repository contains de-identified participant-level preprocessed ERP signal files derived directly from the original electrophysiological recordings. These files preserve participant-level responses and are not limited to group averages, figures, or final statistical summaries.

[Choose the correct statement:]

- Raw continuous EEG recordings are not included in this release.
- Raw continuous EEG recordings are available in: `[folder/path]`.

## Dataset summary

- Number of participants represented in the repository: `[N]`
- Unit of observation: participant-level ERP signal files
- Symbolic domains: lexical, algebraic, and graphical
- Experimental conditions: `[describe actual conditions]`
- Channels/electrodes: `[actual channels]`
- Time range: `[actual epoch range]`
- Sampling rate: `[actual sampling rate]`
- File formats: `[for example: .erp, .mat, .csv]`
- Processing level: preprocessed participant-level ERP data
- De-identification: direct personal identifiers have been removed
- Associated publication: https://doi.org/10.1016/j.biopsycho.2026.109374

See `docs/DATA_DICTIONARY.md` and `docs/DATASET_STRUCTURE.md` for detailed descriptions of files, variables, conditions, and processing levels.

## Repository contents

```text
code/
  Analysis scripts used for preprocessing, ERP analysis, statistical analysis,
  quality control, and figure generation.

derivatives/
  De-identified participant-level preprocessed ERP signal files and derived
  analysis outputs. Participant-level and group-level files are identified in
  docs/DATASET_STRUCTURE.md.

docs/
  Dataset documentation, file descriptions, data dictionary, variable
  definitions, processing workflow, and reuse instructions.

sourcedata/task_design/
  Task-design files, including trial order, timing, counterbalancing, and
  experimental-design metadata.

stimuli/instructions/
  Stimulus materials, participant instructions, and task-related documentation.

archive/unclassified/
  Archived or auxiliary files not required for the primary reproducibility
  workflow.
