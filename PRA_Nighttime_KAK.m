%% NIGHTTIME PRA DETECTION (KAK) ACROSS 2 DAYS
clc; clear; close all;

%% PARAMETERS
stationCode = 'KAK';
sampleRate = 'second';
tz = 'Asia/Tokyo';
Fs = 1; winLen = 3600; step = 3600;
f_low = 0.01; f_high = 0.05;

% Set dates
today = datetime('today','TimeZone',tz);
yesterday = today - days(1);

baseUrl = 'https://imag-data.bgs.ac.uk:443/GIN_V1/GINServices';

% Output folder
outFolder = fullfile(pwd, 'INTERMAGNET_DOWNLOADS');
if ~exist(outFolder, 'dir'), mkdir(outFolder); end

%% DOWNLOAD BOTH YESTERDAY AND TODAY
datesToGet = [yesterday, today];
dataAll = table(); % to store all data

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
    catch ME
        warning('Download failed: %s', ME.message); return;
    end

    % Read file
    fid = fopen(outFile, 'r');
    rawData = textscan(fid, '%s %s %f %f %f %f %f', 'HeaderLines', 26);
    fclose(fid);

    % Parse
    dt = datetime(strcat(rawData{1}, {' '}, rawData{2}), 'InputFormat','yyyy-MM-dd HH:mm:ss.SSS', 'TimeZone', tz);
    X = rawData{4}; Y = rawData{5}; Z = rawData{6};
    tbl = table(dt, X, Y, Z);
    dataAll = [dataAll; tbl]; %#ok<AGROW>
end

%% STEP 2: Extract Nighttime Window (20:00–04:00)
% Define full window
startTime = datetime(yesterday.Year, yesterday.Month, yesterday.Day, 20, 0, 0, 'TimeZone', tz);
endTime   = datetime(today.Year, today.Month, today.Day, 4, 0, 0, 'TimeZone', tz);
nightMask = dataAll.dt >= startTime & dataAll.dt <= endTime;

nightData = dataAll(nightMask, :);
if height(nightData) < winLen
    warning('Not enough data for PRA analysis.');
    return;
end

% Clean missing values
valid = isfinite(nightData.X) & isfinite(nightData.Y) & isfinite(nightData.Z);
nightData = nightData(valid, :);

%% STEP 3: PRA ANALYSIS (Raw S_Z / S_G)
X = nightData.X; Y = nightData.Y; Z = nightData.Z;
G = hypot(X, Y);

S_Z = []; S_G = []; ctr = [];
for s = 1:step:(length(Z) - winLen + 1)
    e = s + winLen - 1;
    c = (s + e) / 2;
    segZ = Z(s:e); segG = G(s:e);
    f = (0:winLen-1) * (Fs/winLen);
    idx = f >= f_low & f <= f_high;
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

PRA = S_Z ./ (S_G + eps);

%% STEP 4: Time Alignment for Plotting
tBase = datetime(yesterday.Year, yesterday.Month, yesterday.Day, 20, 0, 0, 'TimeZone', tz);
tUTC = tBase + seconds(ctr-1);

%% STEP 5: Threshold and Plot
thr = mean(PRA) + 2*std(PRA);
anomalyIdx = PRA > thr;

% Display
if any(anomalyIdx)
    fprintf('[%s] %d anomalies detected at:\n', datestr(today), nnz(anomalyIdx));
    disp(tUTC(anomalyIdx)');
else
    fprintf('[%s] No anomalies detected.\n', datestr(today));
end

% Plot
figure;

subplot(2,1,1);
plot(tUTC, PRA, 'k-', 'LineWidth', 1.2); hold on;
yline(thr, '--r', 'Threshold');
scatter(tUTC(anomalyIdx), PRA(anomalyIdx), 'ro', 'filled');
xlabel('Time (Local)'); ylabel('PRA');
title(sprintf('PRA - %s on %s Nighttime', stationCode, datestr(today,'yyyy-mm-dd')));
grid on; xtickformat('HH:mm');
xlim([tBase tBase + hours(8)]);

subplot(2,1,2);
plot(tUTC, S_Z, 'b-', 'LineWidth', 1.2); hold on;
plot(tUTC, S_G, 'g--', 'LineWidth', 1.2);
xlabel('Time (Local)'); ylabel('Power');
legend({'S_Z','S_G'}); grid on; xtickformat('HH:mm');
title('S_Z and S_G (Power Spectral Density)');
xlim([tBase tBase + hours(8)]);

% Save
PRA_Result.tUTC = tUTC;
PRA_Result.PRA = PRA;
PRA_Result.S_Z = S_Z;
PRA_Result.S_G = S_G;
PRA_Result.thr = thr;
PRA_Result.anomalyIdx = anomalyIdx;
save(fullfile(outFolder, sprintf('PRA_Night_%s.mat', datestr(today, 'yyyymmdd'))), 'PRA_Result');

% Save figure
figFolder = fullfile(outFolder, 'figures');
if ~exist(figFolder, 'dir'), mkdir(figFolder); end
saveas(gcf, fullfile(figFolder, sprintf('PRA_%s.png', datestr(today,'yyyymmdd'))));

% Save anomaly flag separately
if any(anomalyIdx)
    fid = fopen(fullfile(outFolder, 'anomaly_detected.txt'), 'w');
    fprintf(fid, 'Anomaly detected at:\n');
    fprintf(fid, '%s\n', string(tUTC(anomalyIdx)));
    fclose(fid);
else
    fid = fopen(fullfile(outFolder, 'anomaly_detected.txt'), 'w');
    fprintf(fid, 'No anomaly detected.\n');
    fclose(fid);
end

