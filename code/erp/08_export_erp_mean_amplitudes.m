%% 08_export_erp_mean_amplitudes.m
%
% Purpose:
%   Load final appended ERPLAB .erp files for the participants included in
%   the final analysis and export mean-amplitude measurements for predefined
%   ERP time windows.
%
% Inputs:
%   - Appended ERPLAB .erp files from 07_append_individual_domain_erps.m
%
% Outputs:
%   - Wide-format text files containing ERP mean-amplitude measurements
%
% Measurement windows:
%   - Early sensory window:       0-180 ms
%   - Late context-sensitive window: 250-500 ms
%
% Measurement:
%   - Mean amplitude relative to prestimulus baseline
%   - Export format: wide
%
% Bins:
%   - 1:12, corresponding to congruent bins across domains and sequence
%     positions
%
% Channels:
%   - 1:11, corresponding to scalp EEG channels included in the analysis
%
% Notes:
%   The final analyzed sample included 27 participants. Participants with
%   incomplete recordings or excessive movement/artifacts were excluded.

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath  = fullfile(projectPath, 'derivatives', 'erplab_appended_erps');
outputPath = fullfile(projectPath, 'derivatives', 'erp_measurements');

%% ------------------------------------------------------------------------
%  Create output folder if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

%% ------------------------------------------------------------------------
%  Participants included in final analysis
% -------------------------------------------------------------------------

includedParticipants = [ ...
    1  2  3  4  5 ...
    6  7  8  9 10 ...
    11 12 13 14 15 ...
    16 17 18 19 ...
    21 23 24 25 26 ...
    28 29 30];

nParticipants = numel(includedParticipants);

%% ------------------------------------------------------------------------
%  ERP measurement parameters
% -------------------------------------------------------------------------

% Congruent bins used in the final ERP analyses.
binsToMeasure = 1:12;

% EEG channels included in measurement export.
% Expected scalp channels:
% 1:11 = F3, Fz, F4, C3, Cz, C4, P3, Pz, P4, O1, O2
channelsToMeasure = 1:11;

% Measurement windows in milliseconds
lateWindow  = [250 500];
earlyWindow = [0 180];

% Output files
lateOutputFile  = fullfile(outputPath, 'All250-500_MeanAmp_congruent_wide.txt');
earlyOutputFile = fullfile(outputPath, 'All0-180_MeanAmp_congruent_wide.txt');

%% ------------------------------------------------------------------------
%  Check input folder
% -------------------------------------------------------------------------

if ~exist(inputPath, 'dir')
    error('Input folder not found: %s', inputPath);
end

%% ------------------------------------------------------------------------
%  Create list of ERP files
% -------------------------------------------------------------------------

erpFiles = cell(1, nParticipants);

for i = 1:nParticipants
    participantID = includedParticipants(i);
    erpFiles{i} = sprintf('%02d_appended.erp', participantID);
end

%% ------------------------------------------------------------------------
%  Check that all ERP files exist
% -------------------------------------------------------------------------

missingFiles = {};

for i = 1:nParticipants
    currentFile = fullfile(inputPath, erpFiles{i});

    if ~exist(currentFile, 'file')
        missingFiles{end+1} = currentFile; %#ok<SAGROW>
    end
end

if ~isempty(missingFiles)
    fprintf('\nMissing ERP files:\n');
    fprintf('%s\n', missingFiles{:});
    error('One or more ERP files are missing. Check inputPath and filenames.');
end

%% ------------------------------------------------------------------------
%  Start EEGLAB / ERPLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Load final appended ERP files
% -------------------------------------------------------------------------

[ERP, ALLERP] = pop_loaderp( ...
    'filename', erpFiles, ...
    'filepath', inputPath);

fprintf('\nLoaded %d appended ERP files.\n', nParticipants);

%% ------------------------------------------------------------------------
%  Export late-window mean amplitudes: 250-500 ms
% -------------------------------------------------------------------------

ALLERP = pop_geterpvalues( ...
    ALLERP, ...
    lateWindow, ...
    binsToMeasure, ...
    channelsToMeasure, ...
    'Baseline', 'pre', ...
    'Binlabel', 'on', ...
    'Erpsets', 1:nParticipants, ...
    'FileFormat', 'wide', ...
    'Filename', lateOutputFile, ...
    'Fracreplace', 'NaN', ...
    'InterpFactor', 3, ...
    'Measure', 'meanbl', ...
    'PeakOnset', 1, ...
    'Resolution', 2);

fprintf('Saved late-window measurements: %s\n', lateOutputFile);

%% ------------------------------------------------------------------------
%  Export early-window mean amplitudes: 0-180 ms
% -------------------------------------------------------------------------

ALLERP = pop_geterpvalues( ...
    ALLERP, ...
    earlyWindow, ...
    binsToMeasure, ...
    channelsToMeasure, ...
    'Baseline', 'pre', ...
    'Binlabel', 'on', ...
    'Erpsets', 1:nParticipants, ...
    'FileFormat', 'wide', ...
    'Filename', earlyOutputFile, ...
    'Fracreplace', 'NaN', ...
    'InterpFactor', 3, ...
    'Measure', 'meanbl', ...
    'PeakOnset', 1, ...
    'Resolution', 2);

fprintf('Saved early-window measurements: %s\n', earlyOutputFile);

%% ------------------------------------------------------------------------
%  Finish
% -------------------------------------------------------------------------

eeglab redraw;

fprintf('\nERP mean-amplitude export completed.\n');