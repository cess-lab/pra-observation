function PRA_Nighttime_KAK
%% NIGHTTIME PRA DETECTION (Final Integrated Version)
clc; clear; close all;

%% Parameters
stationCode = 'KAK';
sampleRate = 'second';
tz = 'Asia/Tokyo';
Fs = 1; winLen = 3600; step = 3600;
f_low = 0.01; f_high = 0.05;

today = datetime('today','TimeZone',tz);
yesterday = today - days(1);

baseUrl = 'https://imag-data.bgs.ac.uk:443/GIN_V1/GINServices';
outFolder = fullfile(pwd, 'INTERMAGNET_DOWNLOADS');
figFolder = fullfile(outFolder, 'figures');
thresholdFile = fullfile(outFolder, 'PRA_Thresholds.txt');

if ~exist(outFolder, 'dir'), mkdir(outFolder); end
if ~exist(figFolder, 'dir'), mkdir(figFolder); end

%% Step 1: Download and Read Data (Yesterday + Today)
datesToGet = [yesterday, today];
dataAll = table();

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
        "format=iaga2002"];
    
    url = baseUrl + "?" + strjoin(params, '&');
    fprintf('Downloading: %s\n', dateStr);
    
    try
        websave(outFile, url);
    catch
        warning('Download failed for %s', dateStr);
        return;
    end
    
    % Parse data
    fid = fopen(outFile, 'r');
    raw = textscan(fid, '%s %s %f %f %f %f %f', 'HeaderLines', 26);
    fclose(fid);
    
    dt = datetime(strcat(raw{1}, {' '}, raw{2}), 'InputFormat','yyyy-MM-dd HH:mm:ss.SSS', 'TimeZone', tz);
    X = raw{4}; Y = raw{5}; Z = raw{6};
    
    dataAll = [dataAll; table(dt, X, Y, Z)];
end

%% Step 2: Filter Nighttime Window (20:00–04:00)
startTime = datetime(yesterday.Year, yesterday.Month, yesterday.Day, 20,0,0, 'TimeZone', tz);
endTime   = datetime(today.Year, today.Month, today.Day, 4,0,0, 'TimeZone', tz);
nightData = dataAll(dataAll.dt >= startTime & dataAll.dt <= endTime, :);

if height(nightData) < winLen
    warning('Not enough nighttime data.');
    return;
end

valid = isfinite(nightData.X) & isfinite(nightData.Y) & isfinite(nightData.Z);
nightData = nightData(valid, :);

X = nightData.X; Y = nightData.Y; Z = nightData.Z;
G = hypot(X, Y);

%% Step 3: PRA Calculation
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
    S_Z(end+1) = sum(PSDz(idx));
    S_G(end+1) = sum(PSDg(idx));
    ctr(end+1) = c;
end

if isempty(S_Z)
    warning('No valid PSD windows.');
    return;
end

PRA = S_Z ./ (S_G + eps);
tBase = datetime(yesterday.Year, yesterday.Month, yesterday.Day, 20, 0, 0, 'TimeZone', tz);
tUTC = tBase + seconds(ctr - 1);

%% Step 4: Threshold Calculation and Tracking
todayClean = datetime(year(today), month(today), day(today));
todayThr = mean(PRA) + 2*std(PRA);

if isfile(thresholdFile)
    T = readtable(thresholdFile, 'Delimiter', '\t');
    T(T.Date == todayClean, :) = []; % remove today's duplicate
else
    T = table('Size',[0 2], 'VariableTypes', ["datetime","double"], 'VariableNames', ["Date","Threshold"]);
end

newRow = table(todayClean, todayThr, 'VariableNames', T.Properties.VariableNames);
T = [T; newRow];
writetable(T, thresholdFile, 'Delimiter', '\t');

% Weighted threshold
n = height(T);
if n >= 3
    thr = sum(T.Threshold(end-2:end) .* [0.2; 0.2; 0.6]) / 1.0;
elseif n == 2
    thr = sum(T.Threshold(end-1:end) .* [0.2; 0.8]) / 1.0;
else
    thr = T.Threshold(end);
end

anomalyIdx = PRA > thr;

%% Step 5: Plot Figure
figFile = fullfile(figFolder, sprintf('PRA_%s.png', datestr(today, 'yyyymmdd')));
try
    figure('visible', 'off');
    
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

    saveas(gcf, figFile);
catch plotErr
    warning('Plotting failed: %s', plotErr.message);
end

%% Step 6: Save Outputs
resultFile = fullfile(outFolder, sprintf('PRA_Night_%s.mat', datestr(today,'yyyymmdd')));
PRA_Result = struct('tUTC', tUTC, 'PRA', PRA, 'S_Z', S_Z, 'S_G', S_G, ...
                    'thr', thr, 'anomalyIdx', anomalyIdx);
save(resultFile, 'PRA_Result');

%% MASTER LOG UPDATE (Append to anomaly_master_log.txt)
if any(anomalyIdx)
    masterLog = fullfile(outFolder, 'anomaly_master_log.txt');
    rangeStr = sprintf('%s 20:00 - %s 04:00', datestr(today - 1, 'dd/mm/yyyy'), datestr(today, 'dd/mm/yyyy'));
    PRA_vals = sprintf('%.2f, ', PRA(anomalyIdx)); PRA_vals = strip(PRA_vals(1:end-2));
    S_Z_vals = sprintf('%.2e, ', S_Z(anomalyIdx)); S_Z_vals = strip(S_Z_vals(1:end-2));
    S_G_vals = sprintf('%.2e, ', S_G(anomalyIdx)); S_G_vals = strip(S_G_vals(1:end-2));

    remarks = "Anomalies due to low $S_G$ instead of high $S_Z$";
    newRow = table({rangeStr}, thr, {PRA_vals}, {S_Z_vals}, {S_G_vals}, {remarks}, ...
        'VariableNames', {'Range','Threshold','PRA','SZ','SG','Remarks'});

    if isfile(masterLog)
        old = readtable(masterLog, 'Delimiter','\t');
        combined = [old; newRow];
    else
        combined = newRow;
    end

    writetable(combined, masterLog, 'Delimiter','\t');
end

%% Step 7: Cleanup and README Update
delete(fullfile(outFolder, '*.iaga2002'));

try
    updateReadme(); % update README.md
catch err
    warning('README update failed: %s', err.message);
end

fprintf('✅ PRA Nighttime Analysis Completed\n');
end
