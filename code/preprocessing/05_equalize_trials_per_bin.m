%% 05_equalize_trials_per_bin.m
%
% Purpose:
%   Load cleaned EEGLAB datasets and remove extra epochs so that each bin
%   has an equal number of accepted trials per participant and stimulus
%   domain.
%
% Inputs:
%   - Cleaned EEGLAB .set files from
%     04_reject_behavioral_and_eeg_artifacts.m
%   - Text files containing epoch indices to remove
%
% Outputs:
%   - EEGLAB .set files with balanced trial counts per bin
%
% Trial equalization:
%   - Target number of accepted epochs per bin: 30
%
% Domain codes:
%   A = Algebraic
%   G = Graphical
%   L = Lexical
%
% Notes:
%   The epoch indices to remove were generated before this step and stored
%   in text files ending in "_non-selected.txt".
%
%   The original archived script used a fixed epoch count of 320. This
%   version derives the number of epochs from each dataset.

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath  = fullfile(projectPath, 'derivatives', 'eeglab_cleaned');
outputPath = fullfile(projectPath, 'derivatives', 'eeglab_equalized');

% Folder containing text files with epoch indices to remove.
nonSelectedPath = fullfile(projectPath, 'derivatives', 'non_selected_epochs');

%% ------------------------------------------------------------------------
%  Create output folder if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

%% ------------------------------------------------------------------------
%  Experimental information
% -------------------------------------------------------------------------

participantIDs = 1:30;

domains = struct( ...
    'code', {'A', 'G', 'L'}, ...
    'label', {'Algebraic', 'Graphical', 'Lexical'} ...
);

%% ------------------------------------------------------------------------
%  Trial equalization parameters
% -------------------------------------------------------------------------

targetTrialsPerBin = 30;

%% ------------------------------------------------------------------------
%  Check required folders
% -------------------------------------------------------------------------

if ~exist(inputPath, 'dir')
    error('Input folder not found: %s', inputPath);
end

if ~exist(nonSelectedPath, 'dir')
    error('Non-selected epochs folder not found: %s', nonSelectedPath);
end

%% ------------------------------------------------------------------------
%  Start EEGLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Equalize trial counts
% -------------------------------------------------------------------------

for participantID = participantIDs

    for d = 1:numel(domains)

        domainCode  = domains(d).code;
        domainLabel = domains(d).label;

        fprintf('\n====================================================\n');
        fprintf('Equalizing trials | Participant %02d | %s (%s)\n', ...
            participantID, domainLabel, domainCode);
        fprintf('====================================================\n');

        %% Define filenames
        %
        % Input files expected from script 04:
        %   <participantID>_<domainCode>_cleaned.set
        %
        % Non-selected epoch files:
        %   <participantID>_<domainCode>_non-selected.txt
        %
        % Output files:
        %   <participantID>_<domainCode>_equalized.set

        inputFile = sprintf('%02d_%s_cleaned.set', ...
            participantID, domainCode);

        nonSelectedFile = sprintf('%02d_%s_non-selected.txt', ...
            participantID, domainCode);

        outputFile = sprintf('%02d_%s_equalized.set', ...
            participantID, domainCode);

        inputFilePath = fullfile(inputPath, inputFile);
        nonSelectedFilePath = fullfile(nonSelectedPath, nonSelectedFile);

        %% Skip missing files
        if ~exist(inputFilePath, 'file')
            warning('Input file not found. Skipping: %s', inputFilePath);
            continue;
        end

        if ~exist(nonSelectedFilePath, 'file')
            warning('Non-selected epoch file not found. Skipping: %s', ...
                nonSelectedFilePath);
            continue;
        end

        %% Load cleaned dataset
        EEG = pop_loadset( ...
            'filename', inputFile, ...
            'filepath', inputPath);

        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

        EEG = eeg_checkset(EEG);

        nEpochs = EEG.trials;

        %% Read epoch indices to remove
        fileID = fopen(nonSelectedFilePath, 'r');

        if fileID == -1
            warning('Could not open file: %s. Skipping.', nonSelectedFilePath);
            continue;
        end

        epochsToRemove = fscanf(fileID, '%d');
        fclose(fileID);

        epochsToRemove = epochsToRemove(:)';
        epochsToRemove = epochsToRemove(epochsToRemove > 0);
        epochsToRemove = epochsToRemove(epochsToRemove <= nEpochs);

        %% Create rejection vector
        rejectExtraEpochs = false(1, nEpochs);
        rejectExtraEpochs(epochsToRemove) = true;

        fprintf('\nEpochs before equalization: %d\n', nEpochs);
        fprintf('Extra epochs removed: %d\n', sum(rejectExtraEpochs));
        fprintf('Target trials per bin: %d\n', targetTrialsPerBin);

        %% Remove extra epochs
        EEG = pop_rejepoch(EEG, rejectExtraEpochs, 0);

        EEG = eeg_checkset(EEG);

        fprintf('Epochs after equalization: %d\n', EEG.trials);

        %% Save equalized dataset
        EEG = pop_saveset( ...
            EEG, ...
            'filename', outputFile, ...
            'filepath', outputPath);

        fprintf('Saved equalized dataset: %s\n', ...
            fullfile(outputPath, outputFile));

        %% Clear EEGLAB memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);

        EEG = [];
        CURRENTSET = 0;

    end
end

eeglab redraw;

fprintf('\nTrial equalization completed.\n');