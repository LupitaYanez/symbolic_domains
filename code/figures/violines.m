%% Figure: Incremental changes with violins + points + within-subject SEM
clear; clc;

% --- Load data ---
infile = 'C:\Users\Neuro\Documents\MAESTRÍA FINAL\Artículo 2 4elem\2026\250-500_MeanAmpCentral.csv'; % ajusta ruta
T = readtable(infile);

ERPset = double(T.ERPset);Y      = double(T.Y);
Domain = double(T.Domain);   
Cond4  = double(T.Cond4);    

subs = unique(ERPset);
doms = unique(Domain);

%% ------------------------------------------------------------------------
% 1) Compute increments per subject x domain
%% ------------------------------------------------------------------------
incRows = [];

for si = 1:numel(subs)
    s = subs(si);

    for di = 1:numel(doms)
        d = doms(di);

        idx_sd = (ERPset==s & Domain==d);

        A = Y(idx_sd & Cond4==1);
        B = Y(idx_sd & Cond4==2);
        C = Y(idx_sd & Cond4==3);
        D = Y(idx_sd & Cond4==4);

        if isempty(A) || isempty(B) || isempty(C) || isempty(D)
            continue
        end

        incRows = [incRows; ...
            s, d, 1, B-A; ...
            s, d, 2, C-B; ...
            s, d, 3, D-C]; %#ok<AGROW>
    end
end

incT = array2table(incRows, 'VariableNames', ...
    {'ERPset','Domain','Step','IncY'});

%% ------------------------------------------------------------------------
% 2) Cousineau–Morey correction
%% ------------------------------------------------------------------------
k = 9; % 3 domains x 3 transitions
morey = sqrt(k/(k-1));

IncYws = nan(height(incT),1);
grandMean = mean(incT.IncY,'omitnan');

for si = 1:numel(subs)
    s = subs(si);
    idx_s = (incT.ERPset==s);
    subjMean = mean(incT.IncY(idx_s),'omitnan');
    IncYws(idx_s) = incT.IncY(idx_s) - subjMean + grandMean;
end

incT.IncYws = IncYws;

%% ------------------------------------------------------------------------
% 3) Plot violins
%% ------------------------------------------------------------------------
figure('Color','w'); hold on;

cols = [0 0 1;   % Algebraic
        0 1 0;   % Graphical
        1 0 0];  % Lexical

domainNames = {'Algebraic','Graphical','Lexical'};
xlabels = {'A-B','B-C','C-D'};

% horizontal offsets so the 3 violins fit inside each transition
offsets = [-0.22, 0, 0.22];
violinWidth = 0.16;

for step = 1:3
    for d = 1:3
        idx = (incT.Step==step & incT.Domain==d);
        y = incT.IncY(idx);
        yws = incT.IncYws(idx);
        c = cols(d,:);
        x0 = step + offsets(d);

        % --- violin from kernel density
        [f, yi] = ksdensity(y);
        f = f ./ max(f) * violinWidth;

        patch([x0+f, fliplr(x0-f)], [yi, fliplr(yi)], c, ...
            'FaceAlpha', 0.18, 'EdgeColor', c, 'LineWidth', 1);

        % --- jittered individual points
        xj = x0 + (rand(size(y))-0.5)*0.05;
        scatter(xj, y, 18, 'MarkerFaceColor', c, ...
            'MarkerEdgeColor', 'none');

        % --- mean and within-subject SEM
        m = mean(y,'omitnan');
        sd = std(yws,0,'omitnan');
        n = numel(unique(incT.ERPset(idx)));
        sem = (sd/sqrt(n))*morey;

        % mean point
        plot(x0, m, 'o', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 7);

        % error bar
        plot([x0 x0], [m-sem m+sem], 'Color', c, 'LineWidth', 2);
        cap = 0.05;
        plot([x0-cap x0+cap], [m-sem m-sem], 'Color', c, 'LineWidth', 2);
        plot([x0-cap x0+cap], [m+sem m+sem], 'Color', c, 'LineWidth', 2);
    end
end

set(gca, 'XTick', 1:3, 'XTickLabel', xlabels, 'FontSize', 12);
xlabel('Transition');
ylabel('Increment in amplitude (\muV)');
yline(0);
box off;
xlim([0.5 3.5]);

legend(domainNames, 'Location', 'best');

%% ------------------------------------------------------------------------
% 4) Export
%% ------------------------------------------------------------------------
try
    exportgraphics(gcf,'Figure_increments_violins.pdf','ContentType','vector');
catch
    print(gcf,'Figure_increments_violins.pdf','-dpdf');
end