function updateReadme
% UPDATE README.MD WITH LATEST PRA FIGURE
fprintf('🔄 Updating README.md with PRA figure...\n');

% Get today's date (Tokyo time)
tz = 'Asia/Tokyo';
today = datetime('now', 'TimeZone', tz);
todayStr = datestr(today, 'yyyy-mm-dd');
todayFile = sprintf('PRA_%s.png', datestr(today, 'yyyymmdd'));
figurePath = fullfile('INTERMAGNET_DOWNLOADS', 'figures', todayFile);

if ~isfile(figurePath)
    warning('❌ PRA figure not found: %s', figurePath);
    return;
end

% Convert for URL-friendly path
imageURL = strrep(figurePath, ' ', '%20');

%% Build README content
lines = [
    "## Daily PRA Nighttime Detection";
    "";
    sprintf("> Last updated on: %s (Japan Local Time)", datestr(today, 'dd mmm yyyy, HH:MM'));
    "";
    sprintf("![Latest PRA Plot](%s)", imageURL);
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
    "- [Khairul Adib Yusof](https://github.com/syaifulafrizal)";
];

% Write to README.md
writelines(lines, 'README.md');
fprintf('✅ README.md successfully updated.\n');
end
