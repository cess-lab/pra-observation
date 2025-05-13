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
        T = sortrows(T, 'Range', 'descend');
        if height(T) > 5, T = T(1:5,:); end

        fprintf("[4] Processing %d rows from anomaly log...\n", height(T));
        for i = 1:height(T)
            try
                praStr = ""; szStr = ""; sgStr = "";

                if ~isempty(T.PRA(i))
                    praVals = strsplit(string(T.PRA(i)), ',');
                    praStr = strjoin(arrayfun(@(x) sprintf('%.2f', str2double(strtrim(x))), praVals, 'UniformOutput', false), '<br>');
                end
                if ~isempty(T.SZ(i))
                    szVals  = strsplit(string(T.SZ(i)), ',');
                    szStr = strjoin(arrayfun(@(x) sprintf('%.2f', str2double(strtrim(x))), szVals, 'UniformOutput', false), '<br>');
                end
                if ~isempty(T.SG(i))
                    sgVals  = strsplit(string(T.SG(i)), ',');
                    sgStr = strjoin(arrayfun(@(x) sprintf('%.2f', str2double(strtrim(x))), sgVals, 'UniformOutput', false), '<br>');
                end

                remVals = strsplit(string(T.Remarks(i)), ',');
                remStr = strjoin(strtrim(remVals), '<br>');

                rowLine = sprintf("| %s | %s | %.2f | %s | %s | %s | %s | ![📈](INTERMAGNET_DOWNLOADS/figures/%s) |", ...
                    string(T.Range(i)), string(T.Times(i)), double(T.Threshold(i)), praStr, szStr, sgStr, remStr, string(T.Plot(i)));
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
