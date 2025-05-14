function updateReadme
% UPDATE README.MD WITH LATEST PRA FIGURE AND ANOMALY SUMMARY TABLE
fprintf('🔄 Updating README.md with PRA figure and anomaly table...\n');

try
    %% Setup
    fprintf("[1] Initializing figure setup...\n");
    tz = 'Asia/Tokyo';
    figDir = fullfile('INTERMAGNET_DOWNLOADS', 'figures');
    files = dir(fullfile(figDir, 'PRA_*.png'));
    if isempty(files)
        warning('❌ No PRA figure found.');
        return;
    end

    [~, idx] = max([files.datenum]);
    latestFile = files(idx).name;
    figurePath = fullfile(figDir, latestFile);
    todayFile = latestFile;

    imageURL = strrep(figurePath, ' ', '%20');
    timestamp = datetime('now','TimeZone','Asia/Tokyo');

    %% Section 1: PRA Figure Section
    fprintf("[2] Preparing header section...\n");
    header = {
        "## Daily PRA Nighttime Detection";
        "";
        sprintf("> Last updated on: %s (Japan Local Time)", datestr(timestamp, 'dd mmm yyyy, HH:MM'));
        "";
        sprintf("![Latest PRA Plot](%s)", imageURL);
        ""
    };

    %% Section 2: Anomaly Table (Last 5 Anomalies)
    fprintf("[3] Reading anomaly log table...\n");
    logFile = fullfile('INTERMAGNET_DOWNLOADS', 'anomaly_master_table.txt');
    tableLines = {
        "## Recent Anomaly Summary (Last 5 Anomalies)";
        "";
        "| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |";
        "|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|"
    };

    if isfile(logFile)
        T = readtable(logFile, 'Delimiter', '\t', 'TextType', 'string');
        % Extract first date from each Range (first 10 characters)
        try
            firstDates = extractBetween(T.Range, 1, 10);  % e.g. "06/05/2025"
            T.RangeDate = datetime(firstDates, 'InputFormat', 'dd/MM/yyyy');
            T = sortrows(T, 'RangeDate', 'descend');
            T.RangeDate = [];  % clean up helper column
        catch err
            warning("⚠️ Failed to parse or sort Range dates: %s", err.message);
        end

        % Group by Range (one row per day)
        [uniqueDays, ~, ic] = unique(T.Range);
        summaryRows = cell(length(uniqueDays),1);

        for j = 1:length(uniqueDays)
            idxs = find(ic == j);

            % Concatenate data from multiple rows on the same day
            rng = T.Range(idxs(1));
            timeStr = strjoin(unique(T.Times(idxs)), ', ');
            thr = max(T.Threshold(idxs));
            praStr = strjoin(arrayfun(@(x) string(x), unique(T.PRA(idxs))), '<br>');
            szStr = strjoin(arrayfun(@(x) string(x), unique(T.SZ(idxs))), '<br>');
            sgStr = strjoin(arrayfun(@(x) string(x), unique(T.SG(idxs))), '<br>');
            remStr = strjoin(unique(T.Remarks(idxs)), '<br>');
            plt = T.Plot(idxs(end));

            summaryRows{j} = table(rng, timeStr, thr, praStr, szStr, sgStr, remStr, plt, ...
                'VariableNames', {'Range', 'Times', 'Threshold', 'PRA', 'SZ', 'SG', 'Remarks', 'Plot'});
        end

        S = vertcat(summaryRows{:});
        S = flipud(S);  % show most recent first
        if height(S) > 5, S = S(1:5,:); end

        fprintf("[4] Processing %d consolidated rows...\n", height(S));

        for i = 1:height(S)
            try
                rowRange  = string(S.Range(i));    if ismissing(rowRange),  rowRange = "(missing)"; end
                rowTime   = string(S.Times(i));    if ismissing(rowTime),   rowTime = "-"; end
                rowThresh = double(S.Threshold(i));

                rowPRA    = string(S.PRA(i));      if ismissing(rowPRA),    rowPRA = "-"; end
                rowSZ     = string(S.SZ(i));       if ismissing(rowSZ),     rowSZ = "-"; end
                rowSG     = string(S.SG(i));       if ismissing(rowSG),     rowSG = "-"; end
                rowRem    = string(S.Remarks(i));  if ismissing(rowRem),    rowRem = "-"; end
                rowPlot   = string(S.Plot(i));     if ismissing(rowPlot),   rowPlot = "missing_plot.png"; end

                rowLine = sprintf("| %s | %s | %.2f | %s | %s | %s | %s | ![📈](INTERMAGNET_DOWNLOADS/figures/%s) |", ...
                    rowRange, rowTime, rowThresh, rowPRA, rowSZ, rowSG, rowRem, rowPlot);

                tableLines{end+1} = rowLine;
            catch rowErr
                warning("⚠️ Failed to process row %d: %s", i, rowErr.message);
            end
        end
    else
        tableLines{end+1} = "_No anomalies logged yet._";
    end

    %% Section 3: Footer
    fprintf("[5] Appending footer info...\n");
    footer = {
        "";
        "---";
        "### About This Project";
        "This repository provides automated daily analysis of nighttime geomagnetic field data";
        "from the Kakioka observatory (KAK) using the Polarization Ratio Analysis (PRA) method.";
        "";
        "- Detection Time Window: 20:00–04:00 (Local Time)";
        "- Frequency Band: 0.01–0.05 Hz";
        "- Anomalies flagged when PRA > threshold";
        "- Threshold calculated based on weighted mean of recent days";
        "- Results stored in a cumulative `.mat` file for long-term monitoring";
        "- README updated automatically each day via GitHub Actions";
        "";
        "### Author";
        "- [Nur Syaiful Afrizal](https://github.com/syaifulafrizal)"
    };

    %% Combine and Write README
    fprintf("[6] Writing README.md...\n");
    finalText = [header; tableLines; footer];
    finalText = cellfun(@char, finalText, 'UniformOutput', false);
    writelines(finalText, 'README.md');
    fprintf('✅ README.md successfully updated.\n');

catch mainErr
    warning('🚨 README update failed: %s', mainErr.message);
end
end
