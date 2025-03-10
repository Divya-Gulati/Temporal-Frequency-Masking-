function [ElecIds,params]= getGoodSpikingElecs_DualTFSmallStim(monkeyName,expDate,protocolName,folderSourceString,gridType,arrayType,timeRange,cutOffs,useCommonBadTrials,ConsiderHighRMSFlag,folderHighRMSElecs,ConsiderBadImpedanceFlag)

if ~exist('arrayType','var');                                      arrayType = 'Dual';                         end
if ~exist('timeRange','var');                                     timeRange = [0.25 0.75];               end
if ~exist('cutOffs','var');                                            cutOffs = [5000 1.5  1 0];              end
if ~exist('useCommonBadTrials','var');                  useCommonBadTrials = 1;            end
       
folderName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,protocolName);
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');

if ConsiderBadImpedanceFlag
    % find bad impedance electrodes
    badImpedanceCutoff = 2500;
    impedanceFileName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,'impedanceValues.mat');
    impedanceVals = load(impedanceFileName);
    badImpedanceElecs = find(impedanceVals.impedanceValues>badImpedanceCutoff) ;
else
    badImpedanceElecs = [];
end


% find bad elecs and trials
[badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,useCommonBadTrials);

if ConsiderHighRMSFlag
    %%% getting high RMS (good) electrodes
    rmsElecFile = fullfile(folderHighRMSElecs,monkeyName,[monkeyName gridType 'RFData.mat']);
    if exist(rmsElecFile,'file')
        rmsElecs = load(rmsElecFile,'highRMSElectrodes');
    else
        rmsElecs.highRMSElectrodes = 1:96;
        warning('WARNING: high RMS Elecs not found');
    end
else
    rmsElecs.highRMSElectrodes = 1:96;
end

electrodeNums= setdiff(rmsElecs.highRMSElectrodes,unique([badImpedanceElecs,horzcat(badElecs{:})]));


% % since this is a V1 protocol we don't need V4 electrodes or any
% % electrodes higher than 48
if strcmp(arrayType,'Dual')
    electrodeList{1} = intersect(electrodeNums,1:48);
elseif strcmp (arrayType,'Single')
    electrodeList{1} = electrodeNums;
end

% loading parameter combinations
parameters = load(fullfile(folderExtract,'parameterCombinations.mat'));
combParams = squeeze(makeCombinedParameterCombinations_FullScreenAndSmallPlaid(folderExtract));
paramCombs= combParams(1:end-1,1:end-1,1:end-1);

valsConLeft= parameters.cValsUnique;
valsConRight= parameters.cValsUnique2;
valsTFRight = parameters.tValsUnique2;
valsTFLeft = parameters.tValsUnique;

%%%% finding min of Con for Right side and max con for left side and for
%%%% that day's target TF
minConRight = min(valsConRight);
maxConLeft = max(valsConLeft);
ConL_num = valsConLeft == maxConLeft;
ConR_num = valsConRight == minConRight;
trialsparamsLeft = parameters.parameterCombinations{:,:,1,1,1,ConL_num};
trialsparamsRight = parameters.parameterCombinations2{:,:,1,1,1,ConR_num,16};
TrialsToCheck_Left= intersect(trialsparamsLeft,trialsparamsRight);

%%%% adding right side trials also when left side was at 0% contrast and TF
%%%% was equal to target Grating's TF
maxConRight = max(valsConRight);
minConLeft = min(valsConLeft);
ConL_numR = valsConLeft == minConLeft;
ConR_numR = valsConRight == maxConRight;
tf_num = valsTFRight == valsTFLeft;
addTrials = cell2mat(squeeze(paramCombs(ConL_numR,ConR_numR,tf_num)));
TrialsToCheck = [TrialsToCheck_Left,addTrials];

params = cell(1,size(electrodeList,2));
for iArray = 1:size(electrodeList,2)
    for ielec = 1:length(electrodeList{iArray})
        disp(['elec' num2str(electrodeList{iArray}(ielec))]);
        segData = load(fullfile(folderSegment,'Segments',['elec' num2str(electrodeList{iArray}(ielec))]),'segmentData');
        spikeData = load(fullfile(folderSegment,'Spikes',['elec' num2str(electrodeList{iArray}(ielec)) '_SID0']),'spikeData');
        
        trialNums =TrialsToCheck;
        if useCommonBadTrials
            trialNums = setdiff(trialNums,badTrials{1,1});
        else
            trialNums = setdiff(trialNums,badTrials{1,electrodeList{iArray}(ielec)});
        end
        
        goodTrialsSpikeData = spikeData.spikeData(trialNums);
        
        SpikesOverall = size(segData.segmentData,2); % Number of spikes recorded in a session for one electrode
        
        snrVal = getSNR(segData.segmentData); % getting SNR
        
        % get spikeData only for 50% Contrast for baseline and stimulus to
        % calculate firing rate
        StimNumSpikes = getSpikeCounts(goodTrialsSpikeData,timeRange);
        BaseNumSpikes = getSpikeCounts(goodTrialsSpikeData,[-(diff(timeRange)) 0]);
        StimFiringRate = mean(StimNumSpikes)./diff(timeRange);
        BaseFiringRate = mean(BaseNumSpikes)./diff(timeRange);
        
        FiringRate = (StimFiringRate - BaseFiringRate);
        
        % PSTH
        binWidthMS = 10;
        [psthVals,timeaxis] = getPSTH(spikeData.spikeData(trialNums),binWidthMS,[-diff(timeRange) (timeRange(end)+timeRange(1))]);
        
        % Compute the mean firing rates psth way
        blPos = find(timeaxis>=-(diff(timeRange)),1)+ (1:(diff(timeRange))/(binWidthMS/1000));
        stPos = find(timeaxis>=timeRange(1),1)+ (1:(diff(timeRange))/(binWidthMS/1000)-1);
        
        clearvars baselineFiringRate stimulusFiringRate
        baselineFiringRate = mean(psthVals(blPos));
        stimulusFiringRate = mean(psthVals(stPos));
        PsthFiringRate  = stimulusFiringRate - baselineFiringRate;

        %%% saving params %%%%%%%%%
        params{iArray}(ielec).SpikesOverall = SpikesOverall;
        params{iArray}(ielec).snrValues = snrVal;
        params{iArray}(ielec).FiringRate = FiringRate;
        params{iArray}(ielec).PsthFiringRate = PsthFiringRate;
        params{iArray}(ielec).ElecID = electrodeList{iArray}(ielec);
        params{iArray}(ielec).StimFiringRate = StimFiringRate;
        
        checkClearTransientFlag = cutOffs(4);
        if checkClearTransientFlag
            transStimTimeRange = [0 0.15];
            transBaseTimeRange = [-0.5 0];
            StimNumTransSpikes = getSpikeCounts(goodTrialsSpikeData,transStimTimeRange);
            BaseNumTransSpikes = getSpikeCounts(goodTrialsSpikeData,transBaseTimeRange);
            TransStimFiringRate = mean(StimNumTransSpikes)./diff(transStimTimeRange);
            TransBaseFiringRate = mean(BaseNumTransSpikes)./diff(transBaseTimeRange);
            TransFiringRate = (TransStimFiringRate >= 1.5*(TransBaseFiringRate));
            params{iArray}(ielec).TransFiringRate = TransFiringRate;
        end  
        
    end
end



ElecIds = cell(1,size(params,2)); 
for isize = 1:size(params,2)
    electrodes = [params{1,isize}.ElecID];
    if checkClearTransientFlag
        indices = ([params{1,isize}.SpikesOverall]>= cutOffs(1) & [params{1,isize}.snrValues] >= cutOffs(2)  & round([params{1,isize}.StimFiringRate]) >= cutOffs(3) & ([params{1,isize}.TransFiringRate]) == 1);
    else
        indices = ([params{1,isize}.SpikesOverall]>= cutOffs(1) & [params{1,isize}.snrValues] >= cutOffs(2) & ([params{1,isize}.FiringRate]) >= cutOffs(3));
    end
    ElecIds{isize} = electrodes(indices);
end

end

function [badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,useCommonBadTrials)

if strcmp(arrayType,'Dual')
    badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrialsV1.mat');
else
    badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrials.mat');
end

badElecs = cell(1,length(badTrialsandElecsFile));
badTrials = cell(1,length(badTrialsandElecsFile));

for iB = 1:length(badTrialsandElecsFile)
    clearvars  x_badElecs x_badtrials
    if exist(badTrialsandElecsFile{iB},'file')
        x_badElecs = load(badTrialsandElecsFile{iB},'badElecs');
        badElecs{iB} =x_badElecs.badElecs;
        if useCommonBadTrials
            x_badtrials = load(badTrialsandElecsFile{iB},'badTrials'); % Loading common bad trials
            badTrials{iB} = x_badtrials.badTrials;
        else
            x_badtrials = load(badTrialsandElecsFile{iB},'allBadTrials'); % Loading bad trials for each elec
            badTrials{iB} = x_badtrials.allBadTrials;
        end
    else
        disp('Bad trial file does not exist');
        badElecs{iB} = [];
        badTrials{iB} = [];
    end
end

end
