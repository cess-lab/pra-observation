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
threshFile = fullfile(outFolder, 'PRA_Thresholds.txt');
saveLogFile = fullfile(outFolder, 'anomaly_master_table.txt');
cumMatFile = fullfile(outFolder, 'PRA_all_results.mat');

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

%% Step 4: Threshold
todayClean = datetime(year(today), month(today), day(today));
todayThr = mean(PRA) + 2*std(PRA);

if isfile(threshFile)
    T = readtable(threshFile, 'Delimiter', '\t');
    T(T.Date == todayClean, :) = [];
else
    T = table('Size',[0 2], 'VariableTypes', ["datetime","double"], 'VariableNames', ["Date","Threshold"]);
end

newRow = table(todayClean, todayThr, 'VariableNames', T.Properties.VariableNames);
T = [T; newRow];
writetable(T, threshFile, 'Delimiter', '\t');

n = height(T);
if n >= 3
    thr = sum(T.Threshold(end-2:end) .* [0.2; 0.2; 0.6]);
elseif n == 2
    thr = sum(T.Threshold(end-1:end) .* [0.2; 0.8]);
else
    thr = T.Threshold(end);
end

anomalyIdx = PRA > thr;

%% Step 5: Save Figure
figFile = fullfile(figFolder, sprintf('PRA_%s.png', datestr(today, 'yyyymmdd')));
figure('visible', 'off');
subplot(2,1,1);
plot(tUTC, PRA, 'k-', 'LineWidth', 1.2); hold on;
yline(thr, '--r', 'Threshold');
scatter(tUTC(anomalyIdx), PRA(anomalyIdx), 'ro', 'filled');
xlabel('Time'); ylabel('PRA'); grid on; title('PRA');
subplot(2,1,2);
plot(tUTC, S_Z, 'b-', tUTC, S_G, 'g--', 'LineWidth', 1.2);
xlabel('Time'); ylabel('Power'); legend('S_Z','S_G'); grid on;
saveas(gcf, figFile);

%% Step 6: Save to Cumulative .mat File
if isfile(cumMatFile)
    load(cumMatFile, 'Results');
else
    Results = struct('date', [], 'tUTC', [], 'PRA', [], 'S_Z', [], 'S_G', [], 'thr', [], 'anomalyIdx', []);
end

entry.date = todayClean;
entry.tUTC = tUTC;
entry.PRA = PRA;
entry.S_Z = S_Z;
entry.S_G = S_G;
entry.thr = thr;
entry.anomalyIdx = anomalyIdx;

Results(end+1) = entry;
save(cumMatFile, 'Results');

%% Step 7: Append to anomaly_master_table.txt if anomaly
if any(anomalyIdx)
    tLocal = datetime(tUTC,'TimeZone','UTC'); tLocal.TimeZone = tz;
    anomalyTimes = tLocal(anomalyIdx);
    blocks = unique(dateshift(anomalyTimes,'start','hour'));
    blockStr = strjoin(arrayfun(@(b) sprintf('%s–%s', datestr(b,'HH:MM'), datestr(b+hours(1),'HH:MM')), blocks, 'UniformOutput', false), ', ');

    idxs = find(anomalyIdx);
    remarks = strings(1, numel(idxs));
    for j = 1:numel(idxs)
        idx = idxs(j);
        if idx == 1
            remarks(j) = "Unable to determine (No prior data)";
            continue;
        end
        dG = S_G(idx) - S_G(idx - 1);
        dZ = S_Z(idx) - S_Z(idx - 1);
        if dG < 0 && abs(dG) > abs(dZ)
            remarks(j) = "Anomaly due to drop in S_G";
        elseif dZ > 0 && abs(dZ) > abs(dG)
            remarks(j) = "Anomaly due to increase in S_Z";
        else
            remarks(j) = "Anomaly mixed S_G/S_Z change";
        end
    end

    rangeStr = string(sprintf('%s 20:00 - %s 04:00', datestr(today - 1, 'dd/mm/yyyy'), datestr(today, 'dd/mm/yyyy')));
    PRA_vals = join(string(round(PRA(anomalyIdx),2)), ', ');
    SZ_vals  = join(string(S_Z(anomalyIdx)), ', ');
    SG_vals  = join(string(S_G(anomalyIdx)), ', ');
    plotFile = string(sprintf('PRA_%s.png', datestr(today, 'yyyymmdd')));
    blockStr = string(blockStr);
    remark = string(strjoin(remarks, ', '));

    newRow = table(rangeStr, todayThr, PRA_vals, SZ_vals, SG_vals, remark, blockStr, plotFile, ...
        'VariableNames', {'Range','Threshold','PRA','SZ','SG','Remarks','Times','Plot'});

    if isfile(saveLogFile)
        old = readtable(saveLogFile, 'Delimiter','\t', 'TextType','string');
        missingInOld = setdiff(newRow.Properties.VariableNames, old.Properties.VariableNames);
        for c = missingInOld
            old.(c{1}) = repmat("", height(old), 1);
        end
        missingInNew = setdiff(old.Properties.VariableNames, newRow.Properties.VariableNames);
        for c = missingInNew
            newRow.(c{1}) = "";
        end
        old = old(:, newRow.Properties.VariableNames);
        combined = [old; newRow];
    else
        combined = newRow;
    end
    writetable(combined, saveLogFile, 'Delimiter','\t');
end

%% Step 8: Update README
try
    updateReadme();
catch err
    warning('README update failed: %s', err.message);
end

fprintf('✅ PRA Nighttime Analysis Completed\n');
end
