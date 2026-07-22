%% 04_reject_behavioral_and_eeg_artifacts.m
%
% Purpose:
%   Load epoched EEGLAB datasets, mark incorrect/out-of-range behavioral
%   responses, detect EEG/EOG artifacts, and reject contaminated epochs.
%
% Inputs:
%   - Epoched EEGLAB .set files from 03_create_eventlist_and_epochs.m
%   - IncorResp.mat file containing epoch indices for incorrect or
%     out-of-range behavioral responses
%
% Outputs:
%   - Artifact-detection summary text files
%   - Cleaned EEGLAB .set files with behavioral and artifact-contaminated
%     epochs removed
%
% Behavioral exclusion:
%   - Incorrect responses
%   - Responses outside the valid RT range
%
% Artifact detection:
%   - Blink detection using EOG channels
%   - Step-like artifact detection using EOG channels
%   - Moving-window peak-to-peak artifact detection
%   - Flatline detection
%
% Domain codes:
%   A = Algebraic
%   G = Graphical
%   L = Lexical
%
% Notes:
%   Archived scripts used a fixed epoch count of 320. This version derives
%   the number of epochs from each dataset to avoid hard-coded assumptions.

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath  = fullfile(projectPath, 'derivatives', 'eeglab_epoched');
outputPath = fullfile(projectPath, 'derivatives', 'eeglab_cleaned');
configPath = fullfile(projectPath, 'config');

incorrectResponseFile = fullfile(configPath, 'IncorResp.mat');
summaryPath           = fullfile(outputPath, 'artifact_summaries');

%% ------------------------------------------------------------------------
%  Create output folders if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

if ~exist(summaryPath, 'dir')
    mkdir(summaryPath);
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
%  Artifact detection parameters
% -------------------------------------------------------------------------

% Channel definitions
eegChannels = 1:13;
eogChannels = 12:13;
flatlineChannels = 1:11;

% Artifact detection time window.
% This should match the final epoch window used in the preprocessing.
artifactWindow = [-100 500];   % ms

% Blink detection
blinkWidth = 200;      % ms
blinkCrossCov = 0.7;

% Step-like artifact detection
stepThreshold = 40;    % microvolts
stepWindowSize = 200;  % ms
stepWindowStep = 50;   % ms

% Moving-window peak-to-peak threshold
peakToPeakThreshold = 100;   % microvolts
peakToPeakWindowSize = 200;  % ms
peakToPeakWindowStep = 50;   % ms

% Flatline detection
flatlineDuration = 498;      % ms
flatlineThreshold = [-1 1];  % microvolts

%% ------------------------------------------------------------------------
%  Check required files
% -------------------------------------------------------------------------

if ~exist(inputPath, 'dir')
    error('Input folder not found: %s', inputPath);
end

if ~exist(incorrectResponseFile, 'file')
    error('Incorrect response file not found: %s', incorrectResponseFile);
end

%% ------------------------------------------------------------------------
%  Load incorrect response indices
% -------------------------------------------------------------------------

load(incorrectResponseFile, 'IncorResp');

if ~exist('IncorResp', 'var')
    error('The file %s does not contain a variable named IncorResp.', ...
        incorrectResponseFile);
end

%% ------------------------------------------------------------------------
%  Start EEGLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Behavioral and EEG artifact rejection
% -------------------------------------------------------------------------

rowIndex = 1;

for participantID = participantIDs

    for d = 1:numel(domains)

        domainCode  = domains(d).code;
        domainLabel = domains(d).label;

        fprintf('\n====================================================\n');
        fprintf('Artifact rejection | Participant %02d | %s (%s)\n', ...
            participantID, domainLabel, domainCode);
        fprintf('====================================================\n');

        %% Define filenames
        %
        % Input files expected from script 03:
        %   <participantID>_<domainCode>_filt_elist_epoched.set
        %
        % Example:
        %   01_A_filt_elist_epoched.set

        inputFile = sprintf('%02d_%s_filt_elist_epoched.set', ...
            participantID, domainCode);

        outputFile = sprintf('%02d_%s_cleaned.set', ...
            participantID, domainCode);

        summaryFile = fullfile(summaryPath, ...
            sprintf('%02d_%s_artifact_summary.txt', ...
            participantID, domainCode));

        inputFilePath = fullfile(inputPath, inputFile);

        %% Skip missing files
        if ~exist(inputFilePath, 'file')
            warning('Input file not found. Skipping: %s', inputFilePath);
            rowIndex = rowIndex + 1;
            continue;
        end

        %% Load epoched dataset
        EEG = pop_loadset( ...
            'filename', inputFile, ...
            'filepath', inputPath);

        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

        EEG = eeg_checkset(EEG);

        nEpochs = EEG.trials;

        %% Mark incorrect or out-of-range behavioral responses
        %
        % IncorResp is expected to contain epoch indices to reject.
        % Empty entries or zeros are ignored.

        incorrectEpochs = false(1, nEpochs);

        if rowIndex <= size(IncorResp, 1)

            currentIncorrect = IncorResp(rowIndex, :);
            currentIncorrect = currentIncorrect(currentIncorrect > 0);
            currentIncorrect = currentIncorrect(currentIncorrect <= nEpochs);

            incorrectEpochs(currentIncorrect) = true;

        else
            warning('No IncorResp row found for participant %02d, domain %s.', ...
                participantID, domainCode);
        end

        %% Synchronize artifact flags
        EEG = pop_syncroartifacts( ...
            EEG, ...
            'Direction', 'bidirectional');

        EEG = eeg_checkset(EEG);

        %% Detect blink artifacts
        EEG = pop_artblink( ...
            EEG, ...
            'Blinkwidth', blinkWidth, ...
            'Channel', eogChannels, ...
            'Crosscov', blinkCrossCov, ...
            'Flag', [1 4], ...
            'Twindow', artifactWindow);

        EEG = eeg_checkset(EEG);

        %% Detect step-like artifacts
        EEG = pop_artstep( ...
            EEG, ...
            'Channel', eogChannels, ...
            'Flag', [1 3], ...
            'Threshold', stepThreshold, ...
            'Twindow', artifactWindow, ...
            'Windowsize', stepWindowSize, ...
            'Windowstep', stepWindowStep);

        EEG = eeg_checkset(EEG);

        %% Detect moving-window peak-to-peak artifacts
        EEG = pop_artmwppth( ...
            EEG, ...
            'Channel', eegChannels, ...
            'Flag', [1 2], ...
            'Threshold', peakToPeakThreshold, ...
            'Twindow', artifactWindow, ...
            'Windowsize', peakToPeakWindowSize, ...
            'Windowstep', peakToPeakWindowStep);

        EEG = eeg_checkset(EEG);

        %% Detect flatline artifacts
        EEG = pop_artflatline( ...
            EEG, ...
            'Channel', flatlineChannels, ...
            'Duration', flatlineDuration, ...
            'Flag', [1 5], ...
            'Threshold', flatlineThreshold, ...
            'Twindow', artifactWindow);

        EEG = eeg_checkset(EEG);

        %% Save artifact detection summary
        EEG = pop_summary_AR_eeg_detection(EEG, summaryFile);

        %% Combine artifact and behavioral rejection flags
        %
        % ERPLAB stores artifact rejection flags in EEG.reject.rejmanual.

        if isfield(EEG.reject, 'rejmanual') && ~isempty(EEG.reject.rejmanual)
            artifactEpochs = logical(EEG.reject.rejmanual);
        else
            artifactEpochs = false(1, nEpochs);
        end

        % Ensure artifact vector has the same length as the number of epochs
        if numel(artifactEpochs) < nEpochs
            artifactEpochs(numel(artifactEpochs)+1:nEpochs) = false;
        elseif numel(artifactEpochs) > nEpochs
            artifactEpochs = artifactEpochs(1:nEpochs);
        end

        epochsToReject = artifactEpochs | incorrectEpochs;

        fprintf('\nEpochs in dataset: %d\n', nEpochs);
        fprintf('Behavioral exclusions: %d\n', sum(incorrectEpochs));
        fprintf('Artifact exclusions: %d\n', sum(artifactEpochs));
        fprintf('Total rejected epochs: %d\n', sum(epochsToReject));

        %% Reject marked epochs
        EEG = pop_rejepoch(EEG, epochsToReject, 0);

        EEG = eeg_checkset(EEG);

        %% Save cleaned dataset
        EEG = pop_saveset( ...
            EEG, ...
            'filename', outputFile, ...
            'filepath', outputPath);

        fprintf('Saved cleaned dataset: %s\n', fullfile(outputPath, outputFile));

        %% Clear EEGLAB memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);

        EEG = [];
        CURRENTSET = 0;

        %% Move to next row of IncorResp
        rowIndex = rowIndex + 1;

    end
end

eeglab redraw;

fprintf('\nBehavioral and EEG artifact rejection completed.\n');