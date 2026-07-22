% plot_figure3_relative_to_A.m
%
% Purpose:
%   Plot late ERP amplitudes relative to sequence position A
%   for parietal and central ROIs.
%
%   For each participant and domain:
%       Relative amplitude = amplitude at each position - amplitude at A
%
%   Error bars are within-subject Cousineau-Morey SEMs computed across
%   the 3 domains x 4 sequence positions.
%
% Input files:
%   250-500_MeanAmpParietal.csv
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

% ROI input files.
roiNames = {'Parietal', 'Central'};

inputFiles = { ...
    fullfile(dataPath, '250-500_MeanAmpParietal.csv'), ...
    fullfile(dataPath, '250-500_MeanAmpCentral.csv') ...
};

%% ------------------------------------------------------------------------
% 2) Figure settings
%% ------------------------------------------------------------------------

figure('Color', 'w', 'Position', [100 100 1000 420]);

% Colors: Algebraic = blue, Graphical = green, Lexical = red.
cols = [ ...
    0 0 1; ...
    0 0.6 0; ...
    1 0 0 ...
];

domainNames = {'Algebraic', 'Graphical', 'Lexical'};
xlabels = {'A', 'B', 'C', 'D'};

allSummary = table();

%% ------------------------------------------------------------------------
% 3) Loop across ROIs
%% ------------------------------------------------------------------------

for gg = 1:2

    infile = inputFiles{gg};
    roiName = roiNames{gg};

    T = readtable(infile);

    % ---------------------------------------------------------------------
    % Flexible variable reading.
    % ---------------------------------------------------------------------

    varNames = T.Properties.VariableNames;

    if ismember('ERPset', varNames)
        ERPset = double(T.ERPset);
    elseif ismember('x___ERPset', varNames)
        ERPset = double(T.x___ERPset);
    else
        error('ERPset variable not found in %s.', infile);
    end

    if ismember('Y', varNames)
        Y = double(T.Y);
    else
        error('Y variable not found in %s.', infile);
    end

    if ismember('Domain', varNames)
        Domain = double(T.Domain);
    else
        error('Domain variable not found in %s.', infile);
    end

    if ismember('Cond4', varNames)
        Cond4 = double(T.Cond4);
    else
        error('Cond4 variable not found in %s.', infile);
    end

    subs = unique(ERPset);
    doms = unique(Domain);

    %% --------------------------------------------------------------------
    % 4) Compute Y relative to A within subject x domain
    %% --------------------------------------------------------------------

    Yrel = nan(size(Y));

    for si = 1:numel(subs)

        s = subs(si);

        for di = 1:numel(doms)

            d = doms(di);

            idx_sd = (ERPset == s & Domain == d);
            idx_A  = (idx_sd & Cond4 == 1);

            A0 = mean(Y(idx_A), 'omitnan');

            Yrel(idx_sd) = Y(idx_sd) - A0;
        end
    end

    %% --------------------------------------------------------------------
    % 5) Cousineau-Morey within-subject normalization
    %% --------------------------------------------------------------------

    k = 12; % 3 domains x 4 positions.
    morey = sqrt(k / (k - 1));

    Yws = nan(size(Yrel));
    grandMean = mean(Yrel, 'omitnan');

    for si = 1:numel(subs)

        s = subs(si);
        idx_s = (ERPset == s);

        subjMean = mean(Yrel(idx_s), 'omitnan');

        Yws(idx_s) = Yrel(idx_s) - subjMean + grandMean;
    end

    %% --------------------------------------------------------------------
    % 6) Aggregate by Domain x Position
    %% --------------------------------------------------------------------

    cellRows = [];

    for di = 1:numel(doms)

        d = doms(di);

        for cnd = 1:4

            idx_cell = (Domain == d & Cond4 == cnd);

            MeanY = mean(Yrel(idx_cell), 'omitnan');
            SDws  = std(Yws(idx_cell), 0, 'omitnan');
            Nsub  = numel(unique(ERPset(idx_cell)));

            SEMws = (SDws / sqrt(Nsub)) * morey;

            Lower = MeanY - SEMws;
            Upper = MeanY + SEMws;

            % Position A is the reference point.
            if cnd == 1
                Lower = MeanY;
                Upper = MeanY;
            end

            cellRows = [cellRows; d, cnd, MeanY, SEMws, Lower, Upper, Nsub]; %#ok<AGROW>
        end
    end

    cellT = array2table(cellRows, 'VariableNames', ...
        {'Domain', 'Cond4', 'MeanY', 'SEMws', 'Lower', 'Upper', 'N'});

    cellT.ROI = repmat(string(roiName), height(cellT), 1);

    allSummary = [allSummary; cellT]; %#ok<AGROW>

    %% --------------------------------------------------------------------
    % 7) Plot panel
    %% --------------------------------------------------------------------

    subplot(1, 2, gg);
    hold on;

    for d = 1:3

        c = cols(d, :);

        idx = (cellT.Domain == d);
        x = cellT.Cond4(idx);
        [x, ord] = sort(x);

        m  = cellT.MeanY(idx);  m  = m(ord);
        lo = cellT.Lower(idx);  lo = lo(ord);
        up = cellT.Upper(idx);  up = up(ord);

        plot(x, m, '-o', ...
            'LineWidth', 2, ...
            'Color', c, ...
            'MarkerFaceColor', c, ...
            'MarkerEdgeColor', c, ...
            'MarkerSize', 6);

        % Manual error bars.
        cap = 0.08;

        for i = 1:numel(x)

            if x(i) == 1
                continue; % no error bars for A
            end

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

    title(roiName);
    xlabel('Sequence position');
    ylabel('Amplitude relative to A (\muV)');

    set(gca, ...
        'XTick', 1:4, ...
        'XTickLabel', xlabels, ...
        'FontSize', 12, ...
        'LineWidth', 1);

    xlim([0.75 4.25]);
    box off;

    if gg == 1
        legend(domainNames, 'Location', 'northwest', 'Box', 'off');
    end
end

%% ------------------------------------------------------------------------
% 8) Export
%% ------------------------------------------------------------------------

figureFile = fullfile(outputPath, 'Figure3_relative_to_A.pdf');
summaryFile = fullfile(outputPath, 'Figure3_relative_to_A_summary.csv');

try
    exportgraphics(gcf, figureFile, 'ContentType', 'vector');
catch
    print(gcf, figureFile, '-dpdf', '-painters');
end

writetable(allSummary, summaryFile);

fprintf('Saved figure: %s\n', figureFile);
fprintf('Saved summary table: %s\n', summaryFile);