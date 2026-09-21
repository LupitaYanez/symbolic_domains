# Symbolic Domains ERP Dataset and Reproducible Analysis Resources

This repository contains de-identified participant-level preprocessed ERP signal files, task-design files, stimulus materials, documentation, and MATLAB analysis code associated with the publication:

**Yáñez-Ramos, M. G., Zarabozo Enríquez de Rivera, D., & González Garrido, A. A.**  
*Position-related centro-parietal ERP responses during contextual processing across symbolic domains.*  
**Biological Psychology, 210**, 109374.  
https://doi.org/10.1016/j.biopsycho.2026.109374

## Overview

This study examined how event-related potential (ERP) activity changes across successive positions in structured symbolic sequences.

Participants processed four-element sequences from three symbolic domains:

- Lexical sentences
- Algebraic monomial operations
- Graphical line-based image compositions

The principal analyses focused on ERP mean amplitudes in the 250–500 ms interval. Additional analyses examined early-window activity in the 0–180 ms interval.

The repository provides participant-level electrophysiological data and the associated experimental and analytical resources needed to examine the dataset, understand the task design, reproduce the principal analyses, and develop secondary analyses.

## Data and resources included

The repository includes:

- De-identified participant-level preprocessed ERP signal files
- Behavioral and electrophysiological derived-analysis files
- Task order, timing, counterbalancing, and design metadata
- Stimulus materials and participant instructions
- MATLAB scripts for preprocessing, ERP analysis, statistical analysis, quality control, and figure generation
- Documentation describing the dataset, variables, task structure, and analysis workflow

The participant-level files preserve individual electrophysiological responses and are not limited to group averages, final figures, or statistical summaries.

## Repository structure

```text
code/
  MATLAB scripts used for preprocessing, ERP analysis, statistical analysis,
  quality control, and figure generation.

derivatives/
  De-identified participant-level preprocessed ERP signal files and derived
  behavioral, electrophysiological, statistical, and figure-related outputs.

docs/
  Documentation describing the dataset, task structure, variables,
  processing level, file organization, and analysis workflow.

sourcedata/task_design/
  Task-design files, including trial order, timing, counterbalancing,
  and experimental-design metadata.

stimuli/instructions/
  Stimulus materials, participant instructions, and task-related documentation.

archive/unclassified/
  Archived or auxiliary files not required for the primary reproducibility workflow.
```

## Participant-level ERP data

The `derivatives/` directory contains de-identified preprocessed ERP signal files organized at the participant level.

These files were derived directly from the original electrophysiological recordings and preserve individual-level responses across the lexical, algebraic, and graphical domains. Participant identifiers are coded and do not contain names or direct personal identifiers.

The repository distinguishes participant-level ERP files from group averages, statistical summaries, quality-control outputs, and publication-ready figures. Additional descriptions of the files, variables, and processing levels are provided in the `docs/` directory.

## Reproducibility

The repository supports examination and reproduction of the principal analyses reported in the associated publication.

The analysis resources are organized by processing stage and include:

- Behavioral-data processing
- EEG/ERP preprocessing
- Participant-level ERP analysis
- ERP amplitude extraction
- Quality control
- Statistical analysis
- Scientific figure generation

The task-design files, stimuli, instructions, participant-level ERP signals, derived outputs, and analysis scripts are provided together so that users can understand the relationship between the experimental design, the electrophysiological data, and the reported results.

Users should consult the documentation in `docs/` before running or modifying the analysis scripts.

## Educational use

This repository is also designed as an instructional resource for graduate-level training in:

- EEG/ERP data organization
- Data cleaning and quality control
- Participant-level electrophysiological analysis
- Statistical analysis
- Scientific visualization
- Reproducible research workflows
- Open and reusable neuroscience resources

The repository can support guided exercises in which students follow the workflow from experimental design and participant-level ERP signals to statistical results and scientific figures.

It also supports instructional activities related to the doctoral course *Seminario de Estudio Dirigido IV: Limpieza y análisis de datos*, Doctorado en Ciencia del Comportamiento, Orientación en Neurociencia, Universidad de Guadalajara, and is intended to remain reusable for future graduate-level courses.

## Ethics and data protection

The associated study was approved by the Ethics Committee of the Institute of Neuroscience, University of Guadalajara, under approval number **ET062017-248**.

All participants provided informed consent. The files shared in this repository have been de-identified.

Users must not attempt to re-identify participants or combine these data with external information for re-identification purposes. Any reuse of the resource must comply with applicable ethical and institutional requirements.

## Contributors

### María Guadalupe Yáñez-Ramos

Repository creator and curator. Contributions to the associated study included conceptualization, methodology, investigation, formal analysis, software, data curation, visualization, project administration, and manuscript preparation.

### Daniel Zarabozo Enríquez de Rivera

Contributions to the associated study included conceptualization, methodology, validation, supervision, resources, project administration, and manuscript review and editing.

### Andrés Antonio González Garrido

Contributions to the associated study included conceptualization, validation, supervision, and manuscript review and editing.

## Citation

When using the data, materials, or code, please cite the associated publication:

Yáñez-Ramos, M. G., Zarabozo Enríquez de Rivera, D., & González Garrido, A. A. (2026). Position-related centro-parietal ERP responses during contextual processing across symbolic domains. *Biological Psychology, 210*, 109374. https://doi.org/10.1016/j.biopsycho.2026.109374

The repository may be cited as:

Yáñez-Ramos, M. G. (2026). *Symbolic Domains ERP Dataset and Reproducible Analysis Resources*. GitHub. https://github.com/LupitaYanez/symbolic_domains

## License and conditions of reuse

The MIT License included in this repository applies to the analysis code.

The participant-level data, stimulus materials, task-design files, and documentation must be used in accordance with the ethical conditions described above. Users should cite both the associated publication and this repository when reusing the resource.

The software license does not authorize attempts to re-identify participants or uses that conflict with applicable ethical, institutional, or legal requirements.

## Contact

**María Guadalupe Yáñez-Ramos**  
ORCID: https://orcid.org/0000-0002-3198-7018  
Email: yanez.ramos.mg@gmail.com
