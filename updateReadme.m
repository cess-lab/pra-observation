function updateReadme
% UPDATE README.MD WITH LATEST PRA FIGURE AND ANOMALY SUMMARY TABLE
fprintf('🔄 Updating README.md with PRA figure and anomaly table...\n');

% Setup
tz = 'Asia/Tokyo';
today = datetime('now', 'TimeZone', tz);
todayStr = datestr(today, 'yyyy-mm-dd');
todayFile = sprintf('PRA_%s.png', datestr(today, 'yyyymmdd'));
figurePath = fullfile('INTERMAGNET_DOWNLOADS', 'figures', todayFile);

if ~isfile(figurePath)
    warning('❌ PRA figure not found: %s', figurePath);
    return;
end

imageURL = strrep(figurePath, ' ', '%20'); % URL encode

%% Section 1: PRA Figure Section
header = [
    "## Daily PRA Nighttime Detection";
    "";
    sprintf("> Last updated on: %s (Japan Local Time)", datestr(today, 'dd mmm yyyy, HH:MM'));
    "";
    sprintf("![Latest PRA Plot](%s)", imageURL);
    ""
];

%% Section 2: Anomaly Table (Last 5 Anomalies)
logFile = fullfile('INTERMAGNET_DOWNLOADS', 'anomaly_master_log.txt');
if isfile(logFile)
    T = readtable(logFile, 'Delimiter', '\t', 'TextType', 'string');
    T = sortrows(T, 'Range', 'descend');  % Sort by Range (Observation window)
    if height(T) > 5, T = T(1:5,:); end

    % Markdown table header
    tableLines = [
        "## Recent Anomaly Summary (Last 5 Anomalies)";
        "";
        "| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plots |";
        "|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|-------|"
    ];

    % Rows
    for i = 1:height(T)
        plotFile = sprintf("INTERMAGNET_DOWNLOADS/figures/PRA_%s.png", erase(T.Range(i), {'/', ' ', ':'}));
        tableLines(end+1) = sprintf("| %s | %s | %.2f | %s | %s | %s | %s | <a href='%s'>📈</a> |", ...
            T.Range(i), T.Times(i), T.Threshold(i), T.PRA{i}, ...
            T.SZ{i}, T.SG{i}, T.Remarks{i}, plotFile);
    end
else
    tableLines = [
        "## Recent Anomaly Summary (Last 5 Anomalies)";
        "";
        "_No anomalies logged yet._";
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
    "";
    "### Author";
    "- [Nur Syaiful Afrizal](https://github.com/syaifulafrizal)";
];

%% Combine and Write README
finalText = [header; tableLines; footer];
writelines(finalText, 'README.md');
fprintf('✅ README.md successfully updated.\n');
end
