%% 03_create_eventlist_and_epochs.m
%
% Purpose:
%   Load filtered EEGLAB datasets, create ERPLAB event lists, update event
%   code labels, and create epoched datasets for ERP preprocessing.
%
% Inputs:
%   - Filtered EEGLAB .set files from 02_bandpass_filter_eeg.m
%   - ERPLAB event list definition file: eList.txt
%
% Outputs:
%   - EEGLAB datasets with ERPLAB event lists
%   - Epoched EEGLAB datasets
%   - Exported event list text files for each participant and domain
%
% Epoching:
%   - Epoch window: -100 to 500 ms relative to stimulus onset
%   - Baseline correction: prestimulus interval
%
% Domain codes:
%   A = Algebraic
%   G = Graphical
%   L = Lexical
%
% Notes:
%   An event time-shift command was present in an archived draft script but
%   was commented out. Therefore, no event latency shift is applied here.

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath   = fullfile(projectPath, 'derivatives', 'eeglab_filtered');
outputPath  = fullfile(projectPath, 'derivatives', 'eeglab_epoched');
configPath  = fullfile(projectPath, 'config');

eventListDefinitionFile = fullfile(configPath, 'eList.txt');
exportedEventListPath   = fullfile(outputPath, 'event_lists');

%% ------------------------------------------------------------------------
%  Create output folders if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

if ~exist(exportedEventListPath, 'dir')
    mkdir(exportedEventListPath);
end

%% ------------------------------------------------------------------------
%  Experimental information
% -------------------------------------------------------------------------

participantIDs = 1:42;

domains = struct( ...
    'code', {'A', 'G', 'L'}, ...
    'label', {'Algebraic', 'Graphical', 'Lexical'} ...
);

%% ------------------------------------------------------------------------
%  Epoching parameters
% -------------------------------------------------------------------------

epochWindow = [-100 500];   % ms

%% ------------------------------------------------------------------------
%  Check required folders and files
% -------------------------------------------------------------------------

if ~exist(inputPath, 'dir')
    error('Input folder not found: %s', inputPath);
end

if ~exist(eventListDefinitionFile, 'file')
    error('ERPLAB event list definition file not found: %s', eventListDefinitionFile);
end

%% ------------------------------------------------------------------------
%  Start EEGLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Create event lists and epochs
% -------------------------------------------------------------------------

for d = 1:numel(domains)

    domainCode  = domains(d).code;
    domainLabel = domains(d).label;

    fprintf('\n====================================================\n');
    fprintf('Creating event lists and epochs: %s (%s)\n', domainLabel, domainCode);
    fprintf('====================================================\n');

    for participantID = participantIDs

        fprintf('\nParticipant %02d | Domain %s\n', participantID, domainCode);

        %% Define filenames
        inputFile = sprintf('%02d_%s_filt.set', participantID, domainCode);

        eventListExportFile = fullfile(exportedEventListPath, ...
            sprintf('%02d_%s_eventlist.txt', participantID, domainCode));

        outputFileEventList = sprintf('%02d_%s_filt_elist.set', ...
            participantID, domainCode);

        outputFileEpoched = sprintf('%02d_%s_filt_elist_epoched.set', ...
            participantID, domainCode);

        inputFilePath = fullfile(inputPath, inputFile);

        %% Skip missing files
        if ~exist(inputFilePath, 'file')
            warning('Input file not found. Skipping: %s', inputFilePath);
            continue;
        end

        %% Load filtered EEGLAB dataset
        EEG = pop_loadset( ...
            'filename', inputFile, ...
            'filepath', inputPath);

        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

        EEG = eeg_checkset(EEG);

        %% Create ERPLAB event list
        %
        % The event list definition file maps event codes to labels and bins.
        % Boundary events are coded as -99 / 'boundary'.

        EEG = pop_editeventlist( ...
            EEG, ...
            'AlphanumericCleaning', 'on', ...
            'BoundaryNumeric', {-99}, ...
            'BoundaryString', {'boundary'}, ...
            'ExportEL', eventListExportFile, ...
            'List', eventListDefinitionFile, ...
            'SendEL2', 'EEG&Text', ...
            'UpdateEEG', 'codelabel', ...
            'Warning', 'on');

        EEG = eeg_checkset(EEG);

        %% Overwrite EEG event codes with code labels
        EEG = pop_overwritevent(EEG, 'codelabel');

        EEG = eeg_checkset(EEG);

        %% Save dataset with event list
        EEG = pop_saveset( ...
            EEG, ...
            'filename', outputFileEventList, ...
            'filepath', outputPath);

        fprintf('Saved event-list dataset: %s\n', ...
            fullfile(outputPath, outputFileEventList));

        %% Create epoched dataset
        %
        % Epochs are time-locked to stimulus onset.
        % Baseline correction is applied using the prestimulus interval.

        EEG = pop_epochbin(EEG, epochWindow, 'pre');

        EEG = eeg_checkset(EEG);

        %% Save epoched dataset
        EEG = pop_saveset( ...
            EEG, ...
            'filename', outputFileEpoched, ...
            'filepath', outputPath);

        fprintf('Saved epoched dataset: %s\n', ...
            fullfile(outputPath, outputFileEpoched));

        %% Clear EEGLAB memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);

        EEG = [];
        CURRENTSET = 0;

    end
end

eeglab redraw;

fprintf('\nEvent list creation and epoching completed.\n');