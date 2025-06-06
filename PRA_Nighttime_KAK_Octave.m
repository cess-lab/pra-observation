%% NIGHTTIME PRA DETECTION (Octave Version)
clc; clear; close all;

graphics_toolkit("gnuplot");  % Safe for GitHub Actions (no GUI)

%% STEP 1: Setup and Dates
stationCode = 'KAK';
sampleRate = 'second';

today = floor(now);            % today at 00:00
yesterday = today - 1;         % yesterday at 00:00

% Build base URL
baseUrl = 'https://imag-data.bgs.ac.uk:443/GIN_V1/GINServices';

outFolder = fullfile(pwd, 'INTERMAGNET_DOWNLOADS');
if ~exist(outFolder, 'dir'), mkdir(outFolder); end

datesToGet = [yesterday, today];
dataAll = [];

for d = 1:2
    dateStr = datestr(datesToGet(d), 'yyyy-mm-dd');
    outFile = fullfile(outFolder, sprintf('%s_%s.iaga2002', stationCode, datestr(datesToGet(d), 'yyyymmdd')));
    params = [
        "Request=GetData", ...
        "observatoryIagaCode=" + stationCode, ...
        "samplesPerDay=" + sampleRate, ...
        "dataStartDate=" + dateStr, ...
        "dataDuration=1", ...
        "publicationState=adjusted", ...
        "orientation=native", ...
        "format=iaga2002"
    ];
    url = baseUrl + "?" + strjoin(params, '&');

    fprintf('Downloading: %s\n', dateStr);
    try
        websave(outFile, url);
    catch
        warning('Download failed: %s', dateStr); 
        return;
    end

    % Read IAGA2002 file
    fid = fopen(outFile, 'r');
    rawData = textscan(fid, '%s %s %f %f %f %f %f', 'HeaderLines', 26);
    fclose(fid);

    % Build timestamps
    dt = datenum(strcat(rawData{1}, {' '}, rawData{2}));
    X = rawData{4}; Y = rawData{5}; Z = rawData{6};

    % Append
    dataAll = [dataAll; [dt, X, Y, Z]]; %#ok<AGROW>
end

%% STEP 2: Nighttime Filtering (20:00 to 04:00)
startTime = datenum(datevec(yesterday) + [0 0 0 20 0 0]);
endTime   = datenum(datevec(today)    + [0 0 0 4 0 0]);

mask = (dataAll(:,1) >= startTime) & (dataAll(:,1) <= endTime);
nightData = dataAll(mask, :);

if size(nightData,1) < 3600
    warning('Not enough nighttime data.');
    return;
end

% Remove missing
valid = all(isfinite(nightData(:,2:4)), 2);
nightData = nightData(valid, :);

timestamps = nightData(:,1);
X = nightData(:,2);
Y = nightData(:,3);
Z = nightData(:,4);

G = hypot(X, Y);

%% STEP 3: PRA Analysis
Fs = 1;                      % Hz
winLen = 3600;               % 1-hour window
step = 3600;                 % 1-hour step
f_low = 0.01; f_high = 0.05;  % Frequency band

S_Z = []; S_G = []; ctr = [];
for s = 1:step:(length(Z) - winLen + 1)
    e = s + winLen - 1;
    c = (s + e) / 2;
    segZ = Z(s:e);
    segG = G(s:e);
    f = (0:winLen-1) * (Fs / winLen);
    idx = (f >= f_low) & (f <= f_high);
    if ~any(idx), continue; end
    PSDz = abs(fft(segZ)).^2 / winLen;
    PSDg = abs(fft(segG)).^2 / winLen;
    S_Z(end+1) = sum(PSDz(idx)); %#ok<AGROW>
    S_G(end+1) = sum(PSDg(idx)); %#ok<AGROW>
    ctr(end+1) = c;              %#ok<AGROW>
end

if isempty(S_Z)
    warning('No valid PSD windows.');
    return;
end

% PRA calculation
PRA = S_Z ./ (S_G + eps);

% Get time vector (based on datenum)
tBase = startTime;
tUTC = tBase + (ctr-1) / (24*3600);

% Threshold
thr = mean(PRA) + 2*std(PRA);
anomalyIdx = PRA > thr;

%% STEP 4: Plot Results
figFolder = fullfile(outFolder, 'figures');
if ~exist(figFolder, 'dir'), mkdir(figFolder); end

figure('visible','off');  % No GUI needed
subplot(2,1,1);
plot(tUTC, PRA, 'k-', 'LineWidth', 1.2); hold on;
yline(thr, '--r', 'Threshold');
plot(tUTC(anomalyIdx), PRA(anomalyIdx), 'ro', 'MarkerFaceColor','r');
datetick('x','HH:MM');
xlabel('Time (Local)');
ylabel('PRA');
title(sprintf('PRA - %s Nighttime', stationCode));
grid on;

subplot(2,1,2);
plot(tUTC, S_Z, 'b-', 'LineWidth', 1.2); hold on;
plot(tUTC, S_G, 'g--', 'LineWidth', 1.2);
datetick('x','HH:MM');
xlabel('Time (Local)');
ylabel('Power');
legend('S_Z','S_G');
title('Power Spectral Density');
grid on;

saveas(gcf, fullfile(figFolder, sprintf('PRA_%s.png', datestr(today,'yyyymmdd'))));

%% STEP 5: Save Result
PRA_Result.tUTC = tUTC;
PRA_Result.PRA = PRA;
PRA_Result.S_Z = S_Z;
PRA_Result.S_G = S_G;
PRA_Result.thr = thr;
PRA_Result.anomalyIdx = anomalyIdx;

save(fullfile(outFolder, sprintf('PRA_Night_%s.mat', datestr(today,'yyyymmdd'))), 'PRA_Result');

% Anomaly text file for easy checking
fid = fopen(fullfile(outFolder, 'anomaly_detected.txt'), 'w');
if any(anomalyIdx)
    fprintf(fid, 'Anomaly detected at:\n');
    fprintf(fid, '%s\n', datestr(tUTC(anomalyIdx)));
else
    fprintf(fid, 'No anomaly detected.\n');
end
fclose(fid);

fprintf('Nighttime PRA Analysis Completed.\n');
