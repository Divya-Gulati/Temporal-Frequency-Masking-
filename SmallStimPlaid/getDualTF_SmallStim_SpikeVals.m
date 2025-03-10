function [Results] = getDualTF_SmallStim_SpikeVals(Indices,folderSourceString,gridType, ...
    timeRange,useCommonBadTrials,...
    folderHighRMSElecs,UsegoodSpikingElecFlag,spikeElecCutOffs,SpikingtimeRange,...
    ConsiderHighRMSFlag,ConsiderBadImpedanceFlag)

if ~exist('useCommonBadTrials','var');               useCommonBadTrials = 1;                 end
if ~exist('UsegoodSpikingElecFlag','var');          UsegoodSpikingElecFlag =1;             end
if ~exist('spikeElecCutOffs','var');                         spikeElecCutOffs = [1000 1 1 1];     end
if ~exist('SpikingtimeRange','var');                     SpikingtimeRange = [0 0.2];              end
if ~exist('ConsiderHighRMSFlag','var');               ConsiderHighRMSFlag = 0;             end
if ~exist('ConsiderBadImpedanceFlag','var');      ConsiderBadImpedanceFlag = 0;    end

% getting all experiment dates and names
[~,monkeyNames,expDates,protocolNames,~,arrayTypes] = allProtocolsMonkeys;
iElecCount = 1;

for jIndex = 1:length(Indices) % running it for all protocol indices
    
    monkeyName = monkeyNames{Indices(jIndex)};
    expDate = expDates{Indices(jIndex)};
    protocolName = protocolNames{Indices(jIndex)};
    arrayType = arrayTypes{Indices(jIndex)};
    
    folderName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,protocolName);
    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');
    
    % find bad elecs and trials
    [badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,useCommonBadTrials);
    
    if UsegoodSpikingElecFlag
        [ElecIds,~]= getGoodSpikingElecs_DualTFSmallStim(monkeyName,expDate,protocolName,folderSourceString,gridType,...
            arrayType,SpikingtimeRange,spikeElecCutOffs,useCommonBadTrials,ConsiderHighRMSFlag,folderHighRMSElecs,ConsiderBadImpedanceFlag);
        clearvars  electrodeNums
        electrodeNums = ElecIds{1,1};
    else 
        if ConsiderHighRMSFlag == 1
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
        
        if ConsiderBadImpedanceFlag == 1
            % find bad impedance electrodes
            badImpedanceCutoff = 2500;
            impedanceFileName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,'impedanceValues.mat');
            impedanceVals = load(impedanceFileName);
            badImpedanceElecs = find(impedanceVals.impedanceValues>badImpedanceCutoff) ;
        else
            badImpedanceElecs = [];
        end
        
        electrodeNumber= setdiff(rmsElecs.highRMSElectrodes,unique([badImpedanceElecs,horzcat(badElecs{:})]));
        
        % % since this is a V1 protocol we don't need V4 electrodes or any
        % % electrodes higher than 48
        if strcmp(arrayType,'Dual')
            electrodeNums= intersect(electrodeNumber,1:48);
        elseif strcmp (arrayType,'Single')
            electrodeNums = electrodeNumber;
        end
    end
    
    disp(['length of elecs' num2str(length(electrodeNums))]);
    Results.ElecIds{jIndex} = electrodeNums;
    %%%%%%% loading parameter combinations and timeVals %%%%%%%%%
    
    Results.parameters{jIndex}= load(fullfile(folderExtract,'parameterCombinations.mat'));
    freqTF = Results.parameters{jIndex}.tValsUnique2 == Results.parameters{jIndex}.tValsUnique;
    
    if ~isempty(electrodeNums)
        for  iElec = 1:length(electrodeNums)
            disp(['elec' num2str(electrodeNums(iElec))]);
            
            clear goodTrialsSpikeDataGrating goodTrialsSpikeDataPlaid
            goodTrialsSpikeDataGrating = cell(1,length(Results.parameters{jIndex}.cValsUnique2),length(Results.parameters{jIndex}.tValsUnique2));
            goodTrialsSpikeDataPlaid = cell(length(Results.parameters{jIndex}.cValsUnique),length(Results.parameters{jIndex}.cValsUnique2),length(Results.parameters{jIndex}.tValsUnique2));
            
            % getting spike data
            spikeData = load(fullfile(folderSegment,'Spikes',['elec' num2str(electrodeNums(iElec)) '_SID0']),'spikeData');
            
            % grating
            for Con = 1
                for Con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                    for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                        trialNums = Results.parameters{jIndex}.parameterCombinations{1,1,1,1,1,1};
                        trialNums = intersect(trialNums,Results.parameters{jIndex}.parameterCombinations2{1,1,1,1,1,Con2,tf});
                        if useCommonBadTrials
                            trialNums = setdiff(trialNums,badTrials{1,1});
                        else
                            trialNums = setdiff(trialNums,badTrials{1,1}{1,electrodeNums(ielec)});
                        end
                        goodTrialsSpikeDataGrating{1,Con2,tf} = spikeData.spikeData(trialNums);
                    end
                end
            end
            
            % plaid
            for Con = 1:length(Results.parameters{jIndex}.cValsUnique)
                for Con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                    for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                        trialNums = Results.parameters{jIndex}.parameterCombinations{1,1,1,1,1,Con};
                        trialNums = intersect(trialNums,Results.parameters{jIndex}.parameterCombinations2{1,1,1,1,1,Con2,tf});
                        if useCommonBadTrials
                            trialNums = setdiff(trialNums,badTrials{1,1});
                        else
                            trialNums = setdiff(trialNums,badTrials{1,1}{1,electrodeNums(ielec)});
                        end
                        goodTrialsSpikeDataPlaid{Con,Con2,tf} = spikeData.spikeData(trialNums);
                    end
                end
            end
            %%%% grating data %%%
            for con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                    clearvars gratingData StimNumSpikes BaseNumSpikes StimFiringRate BaseFiringRate
                    gratingData = goodTrialsSpikeDataGrating{1,con2,tf};
                    
                    StimNumSpikes = getSpikeCounts(gratingData,timeRange);
                    BaseNumSpikes = getSpikeCounts(gratingData,[-(diff(timeRange)) 0]);
                    StimFiringRate = mean(StimNumSpikes)./diff(timeRange);
                    BaseFiringRate = mean(BaseNumSpikes)./diff(timeRange);
                    
                    Results.FiringRate_grating(iElecCount,1,con2,tf,:) = (StimFiringRate - BaseFiringRate);
                    
                    % PSTH
                    binWidthMS = 10;
                    [Results.psthVals_grating(iElecCount,1,con2,tf,:),timeaxis] = getPSTH(gratingData,binWidthMS,[-diff(timeRange) (timeRange(end)+timeRange(1))]);
                    
                    % Compute the mean firing rates psth way
                    blPos = find(timeaxis>=-(diff(timeRange)),1)+ (1:(diff(timeRange))/(binWidthMS/1000));
                    stPos = find(timeaxis>=timeRange(1),1)+ (1:(diff(timeRange))/(binWidthMS/1000)-1);
                    
                    clearvars baselineFiringRate stimulusFiringRate
                    baselineFiringRate = mean(Results.psthVals_grating(iElecCount,1,con2,tf,blPos));
                    stimulusFiringRate = mean(Results.psthVals_grating(iElecCount,1,con2,tf,stPos));
                    Results.PsthFiringRate_grating(iElecCount,1,con2,tf,:)  = stimulusFiringRate - baselineFiringRate;
                    
                    % compute raster
                    Results.rasterData_grating{iElecCount,1,con2,tf}= gratingData;
                    
                    % computing fft and Change in Amplitude based on PSTH
                    clearvars fftblData fftstData
                    baseRange = [-diff(timeRange) 0];
                    [fftblData,~]=getFFTPsth(squeeze(Results.psthVals_grating(iElecCount,1,con2,tf,:)),timeaxis,baseRange);
                    [fftstData,freqVals]=getFFTPsth(squeeze(Results.psthVals_grating(iElecCount,1,con2,tf,:)),timeaxis,timeRange);
                    Results.PsthfftST_grating(iElecCount,1,con2,tf,:) = fftstData;
                    Results.PsthfftBL_grating(iElecCount,1,con2,tf,:) = fftblData;
                    
                    fidxMaskTF_spike = find(round(freqVals,2) == 2*Results.parameters{jIndex}.tValsUnique2(tf));
                    
                    Results.ampDiff_spike_grating(iElecCount,1,con2,tf,:) = (fftstData(fidxMaskTF_spike)-fftblData(fidxMaskTF_spike));
                end
            end
            
            %%%% plaid data %%%
            for con1 = 1:length(Results.parameters{jIndex}.cValsUnique)
                for con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                    for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                        clearvars gratingData StimNumSpikes BaseNumSpikes StimFiringRate BaseFiringRate
                        plaidData = goodTrialsSpikeDataPlaid{con1,con2,tf};
                        
                        StimNumSpikes = getSpikeCounts(plaidData,timeRange);
                        BaseNumSpikes = getSpikeCounts(plaidData,[-(diff(timeRange)) 0]);
                        StimFiringRate = mean(StimNumSpikes)./diff(timeRange);
                        BaseFiringRate = mean(BaseNumSpikes)./diff(timeRange);
                        
                        Results.FiringRate_plaid(iElecCount,con1,con2,tf,:) = (StimFiringRate - BaseFiringRate);
                        
                        % PSTH
                        binWidthMS = 10;
                        [Results.psthVals_plaid(iElecCount,con1,con2,tf,:),timeaxis] = getPSTH(plaidData,binWidthMS,[-diff(timeRange) (timeRange(end)+timeRange(1))]);
                        
                        % Compute the mean firing rates psth way
                        blPos = find(timeaxis>=-(diff(timeRange)),1)+ (1:(diff(timeRange))/(binWidthMS/1000));
                        stPos = find(timeaxis>=timeRange(1),1)+ (1:(diff(timeRange))/(binWidthMS/1000)-1);
                        
                        clearvars baselineFiringRate stimulusFiringRate
                        baselineFiringRate = mean(Results.psthVals_plaid(iElecCount,con1,con2,tf,blPos));
                        stimulusFiringRate = mean(Results.psthVals_plaid(iElecCount,con1,con2,tf,stPos));
                        Results.PsthFiringRate_plaid(iElecCount,con1,con2,tf,:)  = stimulusFiringRate - baselineFiringRate;
                        
                        % compute raster
                        Results.rasterData_plaid{iElecCount,con1,con2,tf}= plaidData;
                        
                        % computing fft and Change in Amplitude based on PSTH
                        clearvars fftblData fftstData
                        baseRange = [-diff(timeRange) 0];
                        [fftblData,~]=getFFTPsth(squeeze(Results.psthVals_plaid(iElecCount,con1,con2,tf,:)),timeaxis,baseRange);
                        [fftstData,freqVals]=getFFTPsth(squeeze(Results.psthVals_plaid(iElecCount,con1,con2,tf,:)),timeaxis,timeRange);
                        Results.PsthfftST_plaid(iElecCount,con1,con2,tf,:) = fftstData;
                        Results.PsthfftBL_plaid(iElecCount,con1,con2,tf,:) = fftblData;
                        
                        fidxTargetTF_spike = find(round(freqVals,2) == 2*Results.parameters{jIndex}.tValsUnique);
                        
                        Results.ampDiff_spike_plaid(iElecCount,con1,con2,tf,:) = (fftstData(fidxTargetTF_spike)-fftblData(fidxTargetTF_spike));
                    end
                end
                Results.changeInAmpNeg(iElecCount,con1,:,:)  = Results.ampDiff_spike_plaid(iElecCount,con1,:,:) - repmat(Results.ampDiff_spike_plaid(iElecCount,1,4,freqTF) ,1,1,length(Results.parameters{jIndex}.cValsUnique2),length(Results.parameters{jIndex}.tValsUnique2));
                Results.changeInAmpSubtract(iElecCount,con1,:,:)  = Results.ampDiff_spike_plaid(iElecCount,con1,:,:) - repmat(Results.ampDiff_spike_plaid(iElecCount,con1,1,:) ,1,1,length(Results.parameters{jIndex}.cValsUnique2),1);
            end
            Results.parameters{jIndex}.PsthTimeAxis = timeaxis;
            Results.parameters{jIndex}.PsthFreqVals = freqVals;
            iElecCount = iElecCount+1;
        end
    end
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

function [fftData,freqVals]=getFFTPsth(psthData,xs,stimRange)
% psthData of dimension samples x 1
% xs = time points corresponding to the psth data points.
% stimRange = the time range in which fft needs to be computed.
stimPos = intersect(find(xs>=stimRange(1)),find(xs<stimRange(2)));
tValsStim = xs(stimPos);
Fs = 1/(tValsStim(2)-tValsStim(1));
deltaFs = Fs/length(stimPos) ; % this is equivalent to using 1/diff(stimRange);
freqVals = 0:deltaFs:Fs-1/deltaFs;
fftData = abs(fft(psthData(stimPos)))./length(freqVals);
end