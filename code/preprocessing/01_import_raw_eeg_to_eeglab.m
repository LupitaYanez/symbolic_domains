%% 01_import_raw_eeg_to_eeglab.m
%
% Purpose:
%   Import raw Neuronic .REC EEG recordings into EEGLAB, add event markers,
%   assign standard 10-20 channel locations, correct signal polarity, and
%   save participant-by-domain datasets as EEGLAB .set files.
%
% Inputs:
%   - Raw EEG files in .REC format
%   - Event files in .txt format
%   - Standard 10-20 channel location file
%
% Outputs:
%   - EEGLAB .set files for each participant and stimulus domain
%
% Stimulus domains:
%   A = Algebraic
%   G = Graphical
%   L = Lexical
%
% Notes:
%   Signal polarity was corrected after import by multiplying channels 1-13
%   by -1. This step was required to match the expected ERP polarity
%   convention for the imported recordings.
% Mar’a Guadalupe Y‡–ez-Ramos 2017-2026

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

rawPath     = fullfile(projectPath, 'raw');
eventPath   = fullfile(projectPath, 'events');
outputPath  = fullfile(projectPath, 'derivatives', 'eeglab_imported');
configPath  = fullfile(projectPath, 'config');

chanlocFile = fullfile(configPath, 'standard-10-20.elp');

% EEGLAB standard lookup file.
% Update this path according to your local EEGLAB installation.
eeglabLookupFile = fullfile( ...
    'PATH_TO_EEGLAB', ...
    'plugins', ...
    'dipfit2.3', ...
    'standard_BESA', ...
    'standard-10-5-cap385.elp');

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
    'rawName', {'ALGEBRAICO', 'GRAFICO', 'LEXICO'}, ...
    'label', {'Algebraic', 'Graphical', 'Lexical'} ...
);

%% ------------------------------------------------------------------------
%  Check required paths and files
% -------------------------------------------------------------------------

if ~exist(rawPath, 'dir')
    error('Raw data folder not found: %s', rawPath);
end

if ~exist(eventPath, 'dir')
    error('Event folder not found: %s', eventPath);
end

if ~exist(chanlocFile, 'file')
    error('Channel location file not found: %s', chanlocFile);
end

if ~exist(eeglabLookupFile, 'file')
    warning(['EEGLAB lookup file not found: %s\n' ...
             'Channel locations may still load from chanlocFile, but check carefully.'], ...
             eeglabLookupFile);
end

%% ------------------------------------------------------------------------
%  Start EEGLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Import raw EEG recordings
% -------------------------------------------------------------------------

for d = 1:numel(domains)

    domainCode = domains(d).code;
    domainName = domains(d).rawName;
    domainLabel = domains(d).label;

    fprintf('\n====================================================\n');
    fprintf('Processing domain: %s (%s)\n', domainLabel, domainCode);
    fprintf('====================================================\n');

    for participantID = participantIDs

        fprintf('\nParticipant %02d | Domain %s\n', participantID, domainCode);

        %% Define filenames
        %
        % Raw files:
        %   <participantID><domainName>.REC
        % Example:
        %   1ALGEBRAICO.REC
        %
        % Event files:
        %   <participantID><domainCode>.txt
        % Example:
        %   1A.txt

        rawFile = fullfile(rawPath, ...
            sprintf('%d%s.REC', participantID, domainName));

        eventFile = fullfile(eventPath, ...
            sprintf('%d%s.txt', participantID, domainCode));

        datasetName = sprintf('%02d_%s', participantID, domainCode);

        outputFile = sprintf('%02d_%s.set', participantID, domainCode);

        %% Skip missing files
        if ~exist(rawFile, 'file')
            warning('Raw file not found. Skipping: %s', rawFile);
            continue;
        end

        if ~exist(eventFile, 'file')
            warning('Event file not found. Skipping: %s', eventFile);
            continue;
        end

        %% Import raw EEG recording
        EEG = pop_biosig(rawFile);

        [ALLEEG, EEG, CURRENTSET] = pop_newset( ...
            ALLEEG, EEG, 0, ...
            'setname', datasetName, ...
            'gui', 'off');

        EEG = eeg_checkset(EEG);

        %% Import event markers
        %
        % Expected event file columns:
        %   latency | type | pulse

        EEG = pop_importevent( ...
            EEG, ...
            'event', eventFile, ...
            'fields', {'latency', 'type', 'pulse'}, ...
            'timeunit', 1);

        EEG = eeg_checkset(EEG);

        %% Assign channel locations
        if exist(eeglabLookupFile, 'file')
            EEG = pop_chanedit( ...
                EEG, ...
                'lookup', eeglabLookupFile, ...
                'load', {chanlocFile, 'filetype', 'autodetect'});
        else
            EEG = pop_chanedit( ...
                EEG, ...
                'load', {chanlocFile, 'filetype', 'autodetect'});
        end

        EEG = eeg_checkset(EEG);

        %% Correct signal polarity
        %
        % The first 13 channels were inverted to correct the polarity of the
        % imported recordings.

        channelsToInvert = 1:13;

        channelOperations = arrayfun( ...
            @(ch) sprintf('ch%d = ch%d*(-1)', ch, ch), ...
            channelsToInvert, ...
            'UniformOutput', false);

        EEG = pop_eegchanoperator( ...
            EEG, ...
            channelOperations, ...
            'ErrorMsg', 'popup', ...
            'Warning', 'off');

        EEG = eeg_checkset(EEG);

        %% Save EEGLAB dataset
        EEG = pop_saveset( ...
            EEG, ...
            'filename', outputFile, ...
            'filepath', outputPath);

        fprintf('Saved dataset: %s\n', fullfile(outputPath, outputFile));

        %% Clear current dataset from EEGLAB memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);

        EEG = [];
        CURRENTSET = 0;

    end
end

eeglab redraw;

fprintf('\nImport completed.\n');