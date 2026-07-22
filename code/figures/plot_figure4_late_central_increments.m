% plot_figure4_late_central_increments.m
%
% Purpose:
%   Plot adjacent amplitude increments in the late 250-500 ms window
%   within the central ROI.
%
%   Increments:
%       AB = B - A
%       BC = C - B
%       CD = D - C
%
%   Error bars are within-subject Cousineau-Morey SEMs computed across
%   the 3 domains x 3 transitions.
%
% Input file:
%   250-500_MeanAmpCentral.csv
%
% Required variables:
%   ERPset or x___ERPset
%   Y
%   Domain
%   Cond4
%
% Domains:
%   1 = Algebraic
%   2 = Graphical
%   3 = Lexical
%
% Sequence positions:
%   1 = A
%   2 = B
%   3 = C
%   4 = D
%
% Output:
%   Figure4_late_central_increments.pdf
%   Figure4_late_central_increments_summary.csv
%   Figure4_late_central_increments_subject_values.csv

clear; clc; close all;

%% ------------------------------------------------------------------------
% 1) Paths
%% ------------------------------------------------------------------------

projectPath = 'PATH_TO_PROJECT';

dataPath   = fullfile(projectPath, 'derivatives', 'erp_measurements');
outputPath = fullfile(projectPath, 'figures');

if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

inputFile = fullfile(dataPath, '250-500_MeanAmpCentral.csv');

%% ------------------------------------------------------------------------
% 2) Load data
%% ------------------------------------------------------------------------

T = readtable(inputFile);

varNames = T.Properties.VariableNames;

if ismember('ERPset', varNames)
    ERPset = double(T.ERPset);
elseif ismember('x___ERPset', varNames)
    ERPset = double(T.x___ERPset);
else
    error('ERPset variable not found.');
end

if ismember('Y', varNames)
    Y = double(T.Y);
else
    error('Y variable not found.');
end

if ismember('Domain', varNames)
    Domain = double(T.Domain);
else
    error('Domain variable not found.');
end

if ismember('Cond4', varNames)
    Cond4 = double(T.Cond4);
elseif ismember('SequencePosition', varNames)
    Cond4 = double(T.SequencePosition);
else
    error('Cond4 or SequencePosition variable not found.');
end

%% ------------------------------------------------------------------------
% 3) Settings
%% ------------------------------------------------------------------------

domainNames = {'Algebraic', 'Graphical', 'Lexical'};
transitionNames = {'B - A', 'C - B', 'D - C'};

% Colors: Algebraic = blue, Graphical = green, Lexical = red.
cols = [ ...
    0 0 1; ...
    0 0.6 0; ...
    1 0 0 ...
];

subs = unique(ERPset);
doms = 1:3;

%% ------------------------------------------------------------------------
% 4) Compute adjacent increments within participant x domain
%% ------------------------------------------------------------------------

incRows = [];

for si = 1:numel(subs)

    s = subs(si);

    for di = 1:numel(doms)

        d = doms(di);

        idx_sd = (ERPset == s & Domain == d);

        A = mean(Y(idx_sd & Cond4 == 1), 'omitnan');
        B = mean(Y(idx_sd & Cond4 == 2), 'omitnan');
        C = mean(Y(idx_sd & Cond4 == 3), 'omitnan');
        D = mean(Y(idx_sd & Cond4 == 4), 'omitnan');

        if any(isnan([A B C D]))
            warning('Missing value for participant %g, domain %g. Skipping.', s, d);
            continue
        end

        AB = B - A;
        BC = C - B;
        CD = D - C;

        incRows = [incRows; ...
            s, d, 1, AB; ...
            s, d, 2, BC; ...
            s, d, 3, CD]; %#ok<AGROW>
    end
end

incT = array2table(incRows, 'VariableNames', ...
    {'ERPset', 'Domain', 'Transition', 'Delta'});

%% ------------------------------------------------------------------------
% 5) Cousineau-Morey within-subject normalization
%% ------------------------------------------------------------------------

% 3 domains x 3 transitions = 9 within-subject cells.
k = 9;
morey = sqrt(k / (k - 1));

incT.DeltaWS = nan(height(incT), 1);

grandMean = mean(incT.Delta, 'omitnan');
subs2 = unique(incT.ERPset);

for si = 1:numel(subs2)

    s = subs2(si);
    idx_s = (incT.ERPset == s);

    subjMean = mean(incT.Delta(idx_s), 'omitnan');

    incT.DeltaWS(idx_s) = incT.Delta(idx_s) - subjMean + grandMean;
end

%% ------------------------------------------------------------------------
% 6) Aggregate by Domain x Transition
%% ------------------------------------------------------------------------

summaryRows = [];

for d = 1:3

    for tr = 1:3

        idx_cell = (incT.Domain == d & incT.Transition == tr);

        MeanDelta = mean(incT.Delta(idx_cell), 'omitnan');
        SDws      = std(incT.DeltaWS(idx_cell), 0, 'omitnan');
        Nsub      = numel(unique(incT.ERPset(idx_cell)));

        SEMws = (SDws / sqrt(Nsub)) * morey;

        Lower = MeanDelta - SEMws;
        Upper = MeanDelta + SEMws;

        summaryRows = [summaryRows; ...
            d, tr, MeanDelta, SEMws, Lower, Upper, Nsub]; %#ok<AGROW>
    end
end

summaryT = array2table(summaryRows, 'VariableNames', ...
    {'Domain', 'Transition', 'MeanDelta', 'SEMws', 'Lower', 'Upper', 'N'});

%% ------------------------------------------------------------------------
% 7) Plot Figure 4
%% ------------------------------------------------------------------------

figure('Color', 'w', 'Position', [100 100 650 450]);
hold on;

for d = 1:3

    idx = (summaryT.Domain == d);

    x = summaryT.Transition(idx);
    [x, ord] = sort(x);

    m  = summaryT.MeanDelta(idx); m  = m(ord);
    lo = summaryT.Lower(idx);     lo = lo(ord);
    up = summaryT.Upper(idx);     up = up(ord);

    c = cols(d, :);

    plot(x, m, '-o', ...
        'LineWidth', 2, ...
        'Color', c, ...
        'MarkerFaceColor', c, ...
        'MarkerEdgeColor', c, ...
        'MarkerSize', 7);

    % Manual error bars.
    cap = 0.08;

    for i = 1:numel(x)

        plot([x(i) x(i)], [lo(i) up(i)], ...
            'LineWidth', 1.5, ...
            'Color', c);

        plot([x(i)-cap x(i)+cap], [lo(i) lo(i)], ...
            'LineWidth', 1.5, ...
            'Color', c);

        plot([x(i)-cap x(i)+cap], [up(i) up(i)], ...
            'LineWidth', 1.5, ...
            'Color', c);
    end
end

yline(0, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);

set(gca, ...
    'XTick', 1:3, ...
    'XTickLabel', transitionNames, ...
    'FontSize', 12, ...
    'LineWidth', 1);

xlim([0.75 3.25]);

xlabel('Adjacent transition');
ylabel('Amplitude increment (\muV)');

legend(domainNames, 'Location', 'northwest', 'Box', 'off');

box off;

%% ------------------------------------------------------------------------
% 8) Export
%% ------------------------------------------------------------------------

figureFile  = fullfile(outputPath, 'Figure4_late_central_increments.pdf');
summaryFile = fullfile(outputPath, 'Figure4_late_central_increments_summary.csv');
subjectFile = fullfile(outputPath, 'Figure4_late_central_increments_subject_values.csv');

try
    exportgraphics(gcf, figureFile, 'ContentType', 'vector');
catch
    print(gcf, figureFile, '-dpdf', '-painters');
end

writetable(summaryT, summaryFile);
writetable(incT, subjectFile);

fprintf('Saved figure: %s\n', figureFile);
fprintf('Saved summary table: %s\n', summaryFile);
fprintf('Saved subject-level values: %s\n', subjectFile);