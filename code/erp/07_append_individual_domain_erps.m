%% 07_append_individual_domain_erps.m
%
% Purpose:
%   Load individual ERPLAB .erp files for the three stimulus domains
%   (Algebraic, Graphical, Lexical), append them into a single ERP file
%   per participant, and save the appended ERP datasets.
%
% Inputs:
%   - Individual ERPLAB .erp files from
%     06_create_individual_erps_and_trial_counts.m
%
% Outputs:
%   - Appended ERPLAB .erp files containing all three stimulus domains
%     for each participant
%
% Domain codes:
%   A = Algebraic
%   G = Graphical
%   L = Lexical
%
% Notes:
%   Archived scripts included commented-out code for creating difference
%   waves. Difference waves are not created in this script.

clear; clc;

%% ------------------------------------------------------------------------
%  Project paths
% -------------------------------------------------------------------------

% Update projectPath before running.
projectPath = 'PATH_TO_PROJECT';

inputPath  = fullfile(projectPath, 'derivatives', 'erplab_individual_erps');
outputPath = fullfile(projectPath, 'derivatives', 'erplab_appended_erps');

%% ------------------------------------------------------------------------
%  Create output folder if needed
% -------------------------------------------------------------------------

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

%% ------------------------------------------------------------------------
%  Experimental information
% -------------------------------------------------------------------------

% Public anonymized participant identifiers are sequential: sub-01 to sub-27.
% Original laboratory participant numbers are not included in the public repository.
participantIDs = 1:27;

domains = struct( ...
    'code', {'A', 'G', 'L'}, ...
    'label', {'Algebraic', 'Graphical', 'Lexical'} ...
);

domainPrefixes = {domains.code};

%% ------------------------------------------------------------------------
%  Check input folder
% -------------------------------------------------------------------------

if ~exist(inputPath, 'dir')
    error('Input folder not found: %s', inputPath);
end

%% ------------------------------------------------------------------------
%  Start EEGLAB / ERPLAB
% -------------------------------------------------------------------------

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% ------------------------------------------------------------------------
%  Append ERP files across domains
% -------------------------------------------------------------------------

for participantID = participantIDs

    fprintf('\n====================================================\n');
    fprintf('Appending domain ERPs | Participant %02d\n', participantID);
    fprintf('====================================================\n');

    %% Define input ERP files
    %
    % Input files expected from script 06:
    %   <participantID>_<domainCode>.erp
    %
    % Example:
    %   01_A.erp
    %   01_G.erp
    %   01_L.erp

    erpFiles = cell(1, numel(domains));

    for d = 1:numel(domains)
        erpFiles{d} = sprintf('%02d_%s.erp', ...
            participantID, domains(d).code);
    end

    %% Check that all domain ERP files exist
    missingFile = false;

    for d = 1:numel(erpFiles)
        currentFile = fullfile(inputPath, erpFiles{d});

        if ~exist(currentFile, 'file')
            warning('ERP file not found: %s', currentFile);
            missingFile = true;
        end
    end

    if missingFile
        warning('Skipping participant %02d because one or more ERP files are missing.', ...
            participantID);
        continue;
    end

    %% Load individual ERP files
    [ERP, ALLERP] = pop_loaderp( ...
        'filename', erpFiles, ...
        'filepath', inputPath);

    %% Append ERP files across domains
    %
    % Prefixes are added to preserve the domain identity of each bin.

    ERP = pop_appenderp( ...
        ALLERP, ...
        'Erpsets', 1:numel(domains), ...
        'Prefixes', domainPrefixes);

    %% Save appended ERP file
    outputFile = sprintf('%02d_appended.erp', participantID);
    erpName    = sprintf('%02d_appended', participantID);

    ERP = pop_savemyerp( ...
        ERP, ...
        'erpname', erpName, ...
        'filename', outputFile, ...
        'filepath', outputPath, ...
        'Warning', 'on');

    fprintf('Saved appended ERP file: %s\n', fullfile(outputPath, outputFile));

    %% Clear ERP sets from memory
    ALLERP = pop_deleterpset( ...
        ALLERP, ...
        'Erpsets', 1:numel(domains), ...
        'Saveas', 'off');

    ERP = [];
    ALLERP = [];

    eeglab redraw;

end

fprintf('\nAppending individual domain ERPs completed.\n');