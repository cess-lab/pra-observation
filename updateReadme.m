function updateReadme
% UPDATE README.MD WITH LATEST PRA FIGURE AND ANOMALY SUMMARY TABLE
fprintf('🔄 Updating README.md with PRA figure and anomaly table...\n');

% Setup
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
header = [
    "## Daily PRA Nighttime Detection";
    "";
    sprintf("> Last updated on: %s (Japan Local Time)", datestr(timestamp, 'dd mmm yyyy, HH:MM'));
    "";
    sprintf("![Latest PRA Plot](%s)", imageURL);
    ""
];

%% Section 2: Anomaly Table (Last 5 Anomalies)
logFile = fullfile('INTERMAGNET_DOWNLOADS', 'anomaly_master_table.txt');
if isfile(logFile)
    T = readtable(logFile, 'Delimiter', '\t', 'TextType', 'string');
    T = sortrows(T, 'Range', 'descend');
    T = T(~cellfun(@isempty, T.PRA), :);
    if height(T) > 5, T = T(1:5,:); end

    tableLines = [
        "## Recent Anomaly Summary (Last 5 Anomalies)";
        "";
        "| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |";
        "|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|"
    ];

    for i = 1:height(T)
        praVals = strsplit(T.PRA(i), ',');
        szVals  = strsplit(T.SZ(i), ',');
        sgVals  = strsplit(T.SG(i), ',');
        remVals = strsplit(T.Remarks(i), ',');

        praStr = strjoin(arrayfun(@(x) sprintf('%.2f', str2double(strtrim(x))), praVals, 'UniformOutput', false), '<br>');
        szStr  = strjoin(arrayfun(@(x) sprintf('%.2f', str2double(strtrim(x))), szVals, 'UniformOutput', false), '<br>');
        sgStr  = strjoin(arrayfun(@(x) sprintf('%.2f', str2double(strtrim(x))), sgVals, 'UniformOutput', false), '<br>');
        remStr = strjoin(strtrim(remVals), '<br>');

        tableLines(end+1) = sprintf("| %s | %s | %.2f | %s | %s | %s | %s | ![📈](INTERMAGNET_DOWNLOADS/figures/%s) |", ...
            T.Range(i), T.Times(i), T.Threshold(i), praStr, szStr, sgStr, remStr, T.Plot(i));
    end
else
    tableLines = [
        "## Recent Anomaly Summary (Last 5 Anomalies)";
        "";
        "_No anomalies logged yet._"
    ];
end

%% Section 3: Footer
footer = [
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
    "- [Nur Syaiful Afrizal](https://github.com/syaifulafrizal)";
];

%% Combine and Write README
finalText = [header; tableLines; footer];
writelines(cellstr(finalText), 'README.md');
fprintf('✅ README.md successfully updated.\n');
end
