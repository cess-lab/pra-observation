function updateReadme()
%% Update README.md with today's PRA Nighttime plot only
clc;

% --- Top Section ---
TopString = [... 
    "## Continuous Monitoring of Nighttime Polarization Ratio Anomalies (PRA)";
    "  ";
    compose("> Last updated on: %s (UTC)", datetime('now', Format = 'dd MMMM yyyy, hh:mm aa', TimeZone = 'UTC'));
    "  "];

% --- PRA Nighttime Plot Section ---
todayDateStr = datestr(datetime('now', 'TimeZone', 'Asia/Tokyo'), 'yyyymmdd');
PRAPlotPath = fullfile('INTERMAGNET_DOWNLOADS', 'figures', sprintf('PRA_%s.png', todayDateStr));

if exist(PRAPlotPath, 'file')
    PRAPlotURL = replace(PRAPlotPath, ' ', '%20'); % URL-safe
    PRASection = [... 
        "## Daily PRA Nighttime Analysis  ";
        "  ";
        sprintf("> Date analyzed: %s (Japan Local Time)", datestr(datetime('now', 'TimeZone', 'Asia/Tokyo'), 'dd MMM yyyy'));
        "  ";
        sprintf('![PRA Nighttime Plot](%s)', PRAPlotURL);
        "  "];
else
    PRASection = ["## Daily PRA Nighttime Analysis  "; "*No PRA plot available for today.*  "; "  "];
end

% --- Bottom Section ---
BottomString = [... 
    "---";
    "  ";
    "### About This Project";
    "  ";
    "This system automatically:";
    "1. downloads geomagnetic field data from [INTERMAGNET](https://www.intermagnet.org/data-donnee/download-eng.php) stations,";
    "2. processes the nighttime data (20:00–04:00 LT) to calculate the Polarization Ratio (PRA),";
    "3. identifies anomalies based on dynamically updated thresholding, and";
    "4. updates the detection results and figures into this repository automatically.";
    "  ";
    "Nighttime window analysis is performed daily around 03:00 AM Japan Standard Time (UTC+9).";
    "  ";
    "### Contributor";
    "  ";
    "- [Khairul Adib Yusof](https://github.com/khairuladib94)"];

% --- Combine and Write to README ---
FullString = [TopString; PRASection; BottomString];
writelines(FullString, 'README.md');

fprintf('✅ README.md successfully updated.\n');

end
