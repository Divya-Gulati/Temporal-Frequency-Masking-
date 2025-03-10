function [FigureData] = getDataforFigure8_sessionWise(folderSourceString,monkeyNames,gridTypes,representativemonkeyID,representativeElectrodeID)

datafile = cell(1,length(monkeyNames));
for iload = 1:length(monkeyNames)
    datafile{iload} = load(fullfile(folderSourceString,...
        strcat(monkeyNames{iload}, '_ConTF_highRMSLFP_sessionWise_', gridTypes{iload}, '.mat') ));
end
% %% loaded data has usually has cells indicating arrays and with each
% cell ist dimension is electrodes, followed by sigma, contrast,tf and
% then values
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% removing extra electrodes - bad electrodes and averaging electrodes across sessions %%%%
ChangeinAmp = [];
ChangeinAmpBothMonkeysSep = cell(1,length(datafile));
for ilenC = 1:length(datafile)
    clearvars ids temp temp_allgoodElecs
    temp = squeeze(mean(datafile{1, ilenC}.LFPResults.ampDiff{1,1},1,'omitNan')); % mean across sessions
    ids = all(~isnan(temp),4);
    temp_allgoodElecs = temp(ids(:,1,1),:,:,:);
    ChangeinAmpBothMonkeysSep{ilenC}= temp_allgoodElecs; %%% getting change in Amplitude in a single variable for both monkeys %%%
    ChangeinAmp = [ChangeinAmp;temp_allgoodElecs]; %#ok<AGROW>
end

%%% getting change in Amplitude for a single electrode %%%
FigureData.ChangeinAmpSingleElec= squeeze(ChangeinAmpBothMonkeysSep{1, representativemonkeyID}(representativeElectrodeID,:,:,:));

%%% getting the ERP data for a single electrode %%%
%%% taking mean across sessions first for erp Data %%%
meanERPAllElecs = squeeze(mean(datafile{1, representativemonkeyID}.LFPResults.analogDataAllElec{1,1},1,'omitNan'));
clearvars ids temp_allgoodElecs
ids = all(~isnan(meanERPAllElecs),5);
temp_allgoodElecs = meanERPAllElecs(ids(:,1,1,1),:,:,:,:);
FigureData.erpDataSingleElec= squeeze(temp_allgoodElecs(representativeElectrodeID,:,:,:,:));
FigureData.timeValues = datafile{1, representativemonkeyID}.LFPResults.params{1, 1}.timeVals;

%%%% averaging change in amplitude data for both monkeys %%%%

%%% averaging across electrodes and calculating SEM %%%
N = size(ChangeinAmp,1);
meanChangeinAmp = mean(ChangeinAmp,1,'omitNaN');
FigureData.averageChangeInAmp = squeeze(meanChangeinAmp);
FigureData.semChangeInAmp = squeeze((std(ChangeinAmp,[],1))./sqrt(N));
FigureData.LengthOfAllElecs = num2str(N);
%%%% adding/concatenating monkey averaged data in third cell for giving
%%%% this as input to fitting funtion %%%%
ChangeinAmpBothMonkeysSep{ilenC+1}= meanChangeinAmp;

tFVals = datafile{1, 1}.LFPResults.params{1, 1}.TFSaved;

[FigureData.TFResponse,FigureData.FitQuality,FigureData.TF_peak] =runGetTFRespParams(ChangeinAmpBothMonkeysSep,tFVals);

% getting fits for the choosen Electrode
FigureData.ChangeAmpSingleElecFitTFResponse = FigureData.TFResponse{1, representativemonkeyID}(representativeElectrodeID,:,:,:);
FigureData.ChangeAmpSingleElecFitTF_peak = FigureData.TF_peak{1, representativemonkeyID}(representativeElectrodeID,:,:);

end

function [TFResponse,FitQuality,TF_peak] =runGetTFRespParams(Results,tFVals,highLimit)

if ~exist('highLimit','var'); highLimit = 100; end

% fitting options
opt = optimoptions('lsqcurvefit');
opt.Display = 'off';
opt.TolX = 1e-12;
opt.TolFun = 1e-12;
opt.TolPCG = 1e-12;
opt.MaxIter = 1e5;
opt.MaxFunEvals = 1e12;
opt.FiniteDifferenceType = 'central';
opt. FunValCheck = 'on';

for iMonkey =1:size(Results,2)
    for iElec = 1:size(Results{1, iMonkey},1)
        for iSize = 1:size(Results{1, iMonkey},2)
            for iCon = 1:size(Results{1, iMonkey},3)
                disp(num2str([iMonkey iElec iSize iCon]));
                initcoeffs = [100 0.05 100 0.06];
                if iMonkey == 1
                    tfTuningMeasure = squeeze(Results{1, iMonkey}(iElec,iSize,iCon,(2:end)))';
                    tempFreq = tFVals(2:end);
                else
                    tfTuningMeasure = squeeze(Results{1, iMonkey}(iElec,iSize,iCon,(1:end)))';
                    tempFreq = tFVals(1:end);
                end
                [coeffs,FitQuality{1, iMonkey}(iElec,iSize,iCon,:),...
                    diffExpFun,~]...
                    = fitTemporalFrequencyResponse(tempFreq,tfTuningMeasure,opt,initcoeffs); %#ok<AGROW>
                [TFResponse{1, iMonkey}(iElec,iSize,iCon,:),TF_peak{1, iMonkey}(iElec,iSize,iCon,:)]...
                    = getTFRespParams(coeffs,diffExpFun,highLimit);  %#ok<AGROW> %,tempFreq,tfTuningMeasure,iElec,iSize
            end
        end
    end
end
end

function [coeffs,fitQuality,diffExpFun,exitFlag] = fitTemporalFrequencyResponse(tFVals,tfTuningMeasure,opt,initcoeffs)

if ~exist('initcoeffs','var'); initcoeffs = rand(1,4); end
if ~exist('opt','var'); opt = optimoptions('lsqcurvefit'); opt.Display = 'off'; end

diffExpFun = @(c,tf) c(1)*exp(-c(2)*tf)-c(3)*exp(-c(4)*tf); % difference of exponentials
[coeffs,~,~,exitFlag] = lsqcurvefit(diffExpFun,initcoeffs,tFVals,tfTuningMeasure, ...
    [0 0 0 0],[Inf Inf Inf Inf],opt);
fitQuality = 1-(sum((tfTuningMeasure-(diffExpFun(coeffs,tFVals))).^2)/sum((tfTuningMeasure-mean(tfTuningMeasure)).^2));

end

function [TFResponse,TF_peak,TF_highcutoff,TF_trough] = getTFRespParams(fitCoeffs,diffExpFun,highLimit,TFValues,TFResp)

if ~exist('highLimit','var'); highLimit = 100; end

% get model
TFArrayFit = 1:0.1:highLimit;
TFResponse = diffExpFun(fitCoeffs,TFArrayFit);

% find temporal frequency at which response reaches low
[~,trough_index] = min(TFResponse);
if trough_index > 1 && trough_index < length(TFResponse)
    %warning('Temporal frequency response fit inverted!');
    TF_trough = TFArrayFit(trough_index);
else
    TF_trough = inf;
end

% find model temporal frequency at which response peaks
[peak_resp,peak_index] = max(TFResponse);
if peak_index == 1
    %warning('Temporal frequency response fit low-pass.');
    TF_peak = 0;
elseif peak_index == length(TFResponse)
    %warning('Temporal frequency response fit high-pass or band-stop.');
    TF_peak = inf;
else
    TF_peak = TFArrayFit(peak_index);
end

% find model temporal frequency at which response drops to half maximum
[~,high_cutoff_index] = find(TFResponse > peak_resp/2,1,'last');
if isempty(high_cutoff_index) || high_cutoff_index == length(TFArrayFit)
    % warning(['No high cutoff found above peak TF and within ' num2str(highLimit) ' cps.']);
    TF_highcutoff = inf;
else
    TF_highcutoff = TFArrayFit(high_cutoff_index+1);
end

if exist('TFResp','var') && ~isempty(TFResp)
    % show results
    figure,
    plot(TFValues,TFResp,'Marker','o','MarkerFaceColor','b','MarkerEdgeColor','b'); hold on
    plot(TFArrayFit,diffExpFun(fitCoeffs,TFArrayFit),'r');
    %     xlim([TFArrayFit(2) TFArrayFit(end)]);
    set(gca,'XScale','log'); %legend('Data','Fit');
    %     y = ylim; ylim([0 y(2)]);
    xlabel('Temporal frequency (cps)'); ylabel('TF Response');
    if ~isinf(TF_peak)
        plot(TF_peak,TFResponse(peak_index),'Marker','^','MarkerEdgeColor','k','MarkerFaceColor','k');
    end
    if ~isinf(TF_highcutoff)
        plot(TF_highcutoff,TFResponse(high_cutoff_index),'Marker','*','MarkerEdgeColor','k','MarkerFaceColor','k');
    end
end
end

