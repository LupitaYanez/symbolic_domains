%% 02_bandpass_filter_eeg.m
%
% Purpose:
%   Load imported EEGLAB .set files, apply an offline band-pass filter to
%   EEG channels, and save filtered datasets for subsequent preprocessing.
%
% Inputs:
%   - EEGLAB .set files from 01_import_raw_eeg_to_eeglab.m
%
% Outputs:
%   - Filtered EEGLAB .set files
%
% Filtering:
%   - Channels: 1-13
%   - Band-pass: 0.1-18 Hz
%   - Filter type: Butterworth IIR
%   - Order: 2
%   - Non-causal / zero-phase filtering through ERPLAB pop_basicfilter
%   - DC offset removed
%
% Domain codes:
%   A = Algebraic
%   G = Graphical
%   L = Lexical
%
% Notes:
%   This script documents the final filtering parameters used for the ERP
%   preprocessing pipeline.

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath  = fullfile(projectPath, 'derivatives', 'eeglab_imported');
outputPath = fullfile(projectPath, 'derivatives', 'eeglab_filtered');

%% ------------------------------------------------------------------------
%  Create output folder if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
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
%  Filtering parameters
% -------------------------------------------------------------------------

channelsToFilter = 1:13;

filterCutoff = [0.1 20];   % Hz
filterOrder  = 8;

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
%  Filtering loop
% -------------------------------------------------------------------------

for d = 1:numel(domains)

    domainCode  = domains(d).code;
    domainLabel = domains(d).label;

    fprintf('\n====================================================\n');
    fprintf('Filtering domain: %s (%s)\n', domainLabel, domainCode);
    fprintf('====================================================\n');

    for participantID = participantIDs

        fprintf('\nParticipant %02d | Domain %s\n', participantID, domainCode);

        %% Define filenames
        inputFile  = sprintf('%02d_%s.set', participantID, domainCode);
        outputFile = sprintf('%02d_%s_filt.set', participantID, domainCode);

        inputFilePath = fullfile(inputPath, inputFile);

        %% Skip missing files
        if ~exist(inputFilePath, 'file')
            warning('Input file not found. Skipping: %s', inputFilePath);
            continue;
        end

        %% Load EEGLAB dataset
        EEG = pop_loadset( ...
            'filename', inputFile, ...
            'filepath', inputPath);

        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

        EEG = eeg_checkset(EEG);

        %% Apply band-pass filter
        EEG = pop_basicfilter( ...
            EEG, ...
            channelsToFilter, ...
            'Boundary', 'boundary', ...
            'Cutoff', filterCutoff, ...
            'Design', 'butter', ...
            'Filter', 'bandpass', ...
            'Order', filterOrder, ...
            'RemoveDC', 'on');

        EEG = eeg_checkset(EEG);

        %% Save filtered dataset
        EEG = pop_saveset( ...
            EEG, ...
            'filename', outputFile, ...
            'filepath', outputPath);

        fprintf('Saved filtered dataset: %s\n', fullfile(outputPath, outputFile));

        %% Clear EEGLAB memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);

        EEG = [];
        CURRENTSET = 0;

    end
end

eeglab redraw;

fprintf('\nFiltering completed.\n');
