function PRA_Nighttime_KAK
%% NIGHTTIME PRA DETECTION (MATLAB Version with Baseline Updating)
clc; clear; close all;

%% Setup
stationCode = 'KAK';
sampleRate = 'second';
outFolder = fullfile(pwd, 'INTERMAGNET_DOWNLOADS');
figFolder = fullfile(outFolder, 'figures');

if ~exist(outFolder, 'dir'), mkdir(outFolder); end
if ~exist(figFolder, 'dir'), mkdir(figFolder); end

today = dateshift(datetime('now', 'TimeZone', 'Asia/Tokyo'), 'start', 'day');
yesterday = today - days(1);

baseUrl = 'https://imag-data.bgs.ac.uk:443/GIN_V1/GINServices';
datesToGet = [yesterday, today];
dataAll = [];

%% STEP 1: Download and Read Data
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

    % Read IAGA2002
    fid = fopen(outFile, 'r');
    rawData = textscan(fid, '%s %s %f %f %f %f %f', 'HeaderLines', 26);
    fclose(fid);

    timestamps = datetime(strcat(rawData{1}, {' '}, rawData{2}), 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS', 'TimeZone', 'Asia/Tokyo');
    X = rawData{4}; Y = rawData{5}; Z = rawData{6};

    dataAll = [dataAll; table(timestamps, X, Y, Z)];
end

%% STEP 2: Filter Nighttime (20:00 to 04:00)
mask = (hour(dataAll.timestamps) >= 20) | (hour(dataAll.timestamps) <= 4);
nightData = dataAll(mask, :);

if height(nightData) < 3600
    warning('Not enough nighttime data.');
    return;
end

valid = isfinite(nightData.X) & isfinite(nightData.Y) & isfinite(nightData.Z);
nightData = nightData(valid, :);

timestamps = nightData.timestamps;
X = nightData.X;
Y = nightData.Y;
Z = nightData.Z;
G = hypot(X, Y);

%% STEP 3: PRA Calculation
Fs = 1; winLen = 3600; step = 3600;
f_low = 0.01; f_high = 0.05;

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
    warning('No valid PSD segments.');
    return;
end

PRA = S_Z ./ (S_G + eps);
tBase = timestamps(1);
tUTC = tBase + seconds(ctr - 1);

%% STEP 4: Update Baseline and Recalculate Threshold
baselineFile = fullfile(outFolder, 'PRA_Baseline.mat');

if isfile(baselineFile)
    loaded = load(baselineFile);
    allPRA = loaded.allPRA;
else
    allPRA = [];
end

% Append today's PRA
allPRA = [allPRA; PRA(:)];
save(baselineFile, 'allPRA');

% Calculate smarter threshold
thr = mean(allPRA) + 2 * std(allPRA);

% Detect anomalies
anomalyIdx = PRA > thr;

%% STEP 5: Plot PRA and PSD
figFile = fullfile(figFolder, sprintf('PRA_%s.png', datestr(today,'yyyymmdd')));
figure('visible', 'off');

subplot(2,1,1);
plot(tUTC, PRA, 'k-', 'LineWidth', 1.2); hold on;
yline(thr, '--r', 'Threshold');
scatter(tUTC(anomalyIdx), PRA(anomalyIdx), 'ro', 'filled');
xlabel('Time (Local)');
ylabel('PRA');
title(sprintf('PRA - %s Nighttime', stationCode));
grid on;
datetick('x','HH:MM');

subplot(2,1,2);
plot(tUTC, S_Z, 'b-', 'LineWidth', 1.2); hold on;
plot(tUTC, S_G, 'g--', 'LineWidth', 1.2);
xlabel('Time (Local)');
ylabel('Power');
legend('S_Z','S_G');
title('Power Spectral Density');
grid on;
datetick('x','HH:MM');

saveas(gcf, figFile);

%% STEP 6: Save Results
resultFile = fullfile(outFolder, sprintf('PRA_Night_%s.mat', datestr(today,'yyyymmdd')));
PRA_Result.tUTC = tUTC;
PRA_Result.PRA = PRA;
PRA_Result.S_Z = S_Z;
PRA_Result.S_G = S_G;
PRA_Result.thr = thr;
PRA_Result.anomalyIdx = anomalyIdx;
save(resultFile, 'PRA_Result');

% Save anomaly status
txtFile = fullfile(outFolder, 'anomaly_detected.txt');
fid = fopen(txtFile, 'w');
if any(anomalyIdx)
    fprintf(fid, 'Anomaly detected at:\n');
    fprintf(fid, '%s\n', datestr(tUTC(anomalyIdx)));
else
    fprintf(fid, 'No anomaly detected.\n');
end
fclose(fid);

%% STEP 7: Clean up raw IAGA files
iagaFiles = dir(fullfile(outFolder, '*.iaga2002'));
for k = 1:length(iagaFiles)
    delete(fullfile(outFolder, iagaFiles(k).name));
end

fprintf('✅ PRA Nighttime Analysis Completed\n');

end
