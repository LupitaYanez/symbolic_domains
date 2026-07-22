%% 06_create_individual_erps_and_trial_counts.m
%
% Purpose:
%   Create individual ERP averages from equalized EEGLAB datasets and export
%   the final number of accepted trials per bin for each participant and
%   stimulus domain.
%
% Inputs:
%   - Equalized EEGLAB .set files from 05_equalize_trials_per_bin.m
%
% Outputs:
%   - Individual ERPLAB .erp files
%   - Excel file with the number of accepted trials per bin
%
% Averaging:
%   - Only good/accepted trials are included
%   - Boundary events are excluded
%   - Standard error of the mean (SEM) is computed
%
% Domain codes:
%   A = Algebraic
%   G = Graphical
%   L = Lexical

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath  = fullfile(projectPath, 'derivatives', 'eeglab_equalized');
outputPath = fullfile(projectPath, 'derivatives', 'erplab_individual_erps');
qcPath     = fullfile(projectPath, 'derivatives', 'quality_control');

trialCountFile = fullfile(qcPath, 'TrialsPerBin.xlsx');

%% ------------------------------------------------------------------------
%  Create output folders if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

if ~exist(qcPath, 'dir')
    mkdir(qcPath);
end

%% ------------------------------------------------------------------------
%  Experimental information
% -------------------------------------------------------------------------

participantIDs = 1:30;

domains = struct( ...
    'code', {'A', 'G', 'L'}, ...
    'label', {'Algebraic', 'Graphical', 'Lexical'}, ...
    'sheet', {1, 2, 3} ...
);

%% ------------------------------------------------------------------------
%  Check input folder
% -------------------------------------------------------------------------

if ~exist(inputPath, 'dir')
    error('Input folder not found: %s', inputPath);
end

%% ------------------------------------------------------------------------
%  Start EEGLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Create individual ERP averages and export trial counts
% -------------------------------------------------------------------------

for d = 1:numel(domains)

    domainCode  = domains(d).code;
    domainLabel = domains(d).label;
    sheetNumber = domains(d).sheet;

    fprintf('\n====================================================\n');
    fprintf('Creating ERPs | Domain: %s (%s)\n', domainLabel, domainCode);
    fprintf('====================================================\n');

    for participantID = participantIDs

        fprintf('\nParticipant %02d | Domain %s\n', participantID, domainCode);

        %% Define filenames
        %
        % Input files expected from script 05:
        %   <participantID>_<domainCode>_equalized.set
        %
        % Output ERP files:
        %   <participantID>_<domainCode>.erp

        inputFile = sprintf('%02d_%s_equalized.set', ...
            participantID, domainCode);

        erpName = sprintf('%02d_%s', participantID, domainCode);

        outputFile = sprintf('%02d_%s.erp', ...
            participantID, domainCode);

        inputFilePath = fullfile(inputPath, inputFile);

        %% Skip missing files
        if ~exist(inputFilePath, 'file')
            warning('Input file not found. Skipping: %s', inputFilePath);
            continue;
        end

        %% Load equalized EEGLAB dataset
        EEG = pop_loadset( ...
            'filename', inputFile, ...
            'filepath', inputPath);

        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

        EEG = eeg_checkset(EEG);

        %% Create ERP average
        ERP = pop_averager( ...
            EEG, ...
            'Criterion', 'good', ...
            'ExcludeBoundary', 'on', ...
            'SEM', 'on');

        %% Save individual ERP file
        ERP = pop_savemyerp( ...
            ERP, ...
            'erpname', erpName, ...
            'filename', outputFile, ...
            'filepath', outputPath);

        fprintf('Saved ERP file: %s\n', fullfile(outputPath, outputFile));

        %% Export number of accepted trials per bin
        acceptedTrials = ERP.ntrials.accepted;

        rowNumber = participantID + 1;

        % Column A: participant ID
        participantRange = sprintf('A%d:A%d', rowNumber, rowNumber);
        xlswrite(trialCountFile, participantID, sheetNumber, participantRange);

        % Columns B onward: accepted trials per bin
        trialRange = sprintf('B%d:%s%d', ...
            rowNumber, ...
            char('A' + numel(acceptedTrials)), ...
            rowNumber);

        xlswrite(trialCountFile, acceptedTrials, sheetNumber, trialRange);

        fprintf('Accepted trials per bin exported for participant %02d.\n', ...
            participantID);

        %% Clear EEGLAB memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);

        EEG = [];
        ERP = [];
        CURRENTSET = 0;

    end
end

eeglab redraw;

fprintf('\nIndividual ERP creation and trial count export completed.\n');