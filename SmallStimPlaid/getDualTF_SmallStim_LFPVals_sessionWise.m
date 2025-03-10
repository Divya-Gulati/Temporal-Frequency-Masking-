function [Results] = getDualTF_SmallStim_LFPVals_sessionWise(Indices,folderSourceString,gridType, ...
    timeRange,useERP,useCommonBaselineFlag,useCommonBadTrials,dcShiftCorrectionFlag,...
    folderHighRMSElecs,UsegoodSpikingElecFlag,spikeElecCutOffs,SpikingtimeRange,...
    ConsiderHighRMSFlag,ConsiderBadImpedanceFlag,ElectrodesToRun,ImValFlag)

if ~exist('useERP','var');                                         useERP = 1;                                         end
if ~exist('commonBaselineFlag','var');                commonBaselineFlag = 1;                  end
if ~exist('useCommonBadTrials','var');               useCommonBadTrials = 1;                 end
if ~exist('dcShiftCorrectionFlag','var');               dcShiftCorrectionFlag =0;                  end
if ~exist('UsegoodSpikingElecFlag','var');          UsegoodSpikingElecFlag =0;             end
if ~exist('spikeElecCutOffs','var');                         spikeElecCutOffs = [0 0 0];               end
if ~exist('SpikingtimeRange','var');                     SpikingtimeRange = [0 0.2];              end
if ~exist('ConsiderHighRMSFlag','var');               ConsiderHighRMSFlag = 1;             end
if ~exist('ConsiderBadImpedanceFlag','var');      ConsiderBadImpedanceFlag = 1;    end
if ~exist('ImValFlag','var');                                     ImValFlag = 0;                                   end

[~,monkeyNames,expDates,protocolNames,~,arrayTypes] = allProtocolsMonkeys;

SessionCount = 1;

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
        if isempty(ElectrodesToRun)
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
                TotalElectrodestoRun = 1:48;
            elseif strcmp (arrayType,'Single')
                electrodeNums = electrodeNumber;
                TotalElectrodestoRun = 1:96;
            end
        else
            electrodeNums = ElectrodesToRun;
            TotalElectrodestoRun = 1:length(electrodeNums);
        end
    end
    
    disp(['length of elecs' num2str(length(electrodeNums))]);
    Results.ElecIds{jIndex} = electrodeNums;
    %%%%%%% loading parameter combinations and timeVals %%%%%%%%%
    
    Results.parameters{jIndex}= load(fullfile(folderExtract,'parameterCombinations.mat'));
    tVals = load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals');
    timeVals = round(tVals.timeVals,5);
    Results.parameters{jIndex}.timeVals = timeVals;
    
    Fs = round(1/(tVals.timeVals(2)-tVals.timeVals(1))); % Sampling Rate
    freqbins = round(0:1/diff(timeRange):Fs-1/diff(timeRange),2); % Frequency axis
    Results.parameters{jIndex}.freqbins = freqbins;
    count = length(freqbins); % N - length of fft
    
    %index for Target and Mask Frequency
    fid_MaskFreq = zeros(1,length(Results.parameters{jIndex}.tValsUnique2));
    fid_TargetFreq = freqbins == 2*Results.parameters{jIndex}.tValsUnique;
    
    if ImValFlag == 1
        F1F2plus = Results.parameters{jIndex}.tValsUnique+Results.parameters{jIndex}.tValsUnique2;
        F1F2minus = abs(Results.parameters{jIndex}.tValsUnique-Results.parameters{jIndex}.tValsUnique2);
        TwiceF1F2plus= (2*Results.parameters{jIndex}.tValsUnique)+(2.*Results.parameters{jIndex}.tValsUnique2);
        TwiceF1F2minus= abs((2*Results.parameters{jIndex}.tValsUnique)-(2.*Results.parameters{jIndex}.tValsUnique2));
        fid_F1F2plus = zeros(1,length(Results.parameters{jIndex}.tValsUnique2));
        fid_F1F2minus = zeros(1,length(Results.parameters{jIndex}.tValsUnique2));
        fid_TwiceF1F2plus= zeros(1,length(Results.parameters{jIndex}.tValsUnique2));
        fid_TwiceF1F2minus= zeros(1,length(Results.parameters{jIndex}.tValsUnique2));
    end
    
    for jfreq = 1:length(Results.parameters{jIndex}.tValsUnique2)
        fid_MaskFreq(jfreq) = find(freqbins == 2*Results.parameters{jIndex}.tValsUnique2(jfreq));
        if ImValFlag == 1
            fid_F1F2plus(jfreq) = find(freqbins == F1F2plus(jfreq));
            fid_F1F2minus(jfreq) = find(freqbins == F1F2minus(jfreq));
            fid_TwiceF1F2plus(jfreq)= find(freqbins == TwiceF1F2plus(jfreq));
            fid_TwiceF1F2minus(jfreq)= find(freqbins == TwiceF1F2minus(jfreq));
        end
    end
    
    freqTF = Results.parameters{jIndex}.tValsUnique2 == Results.parameters{jIndex}.tValsUnique;
    % stimulus and baseline period
    stPos = timeVals >= timeRange(1) & timeVals < timeRange(2);
    blPos = timeVals >= -diff(timeRange) & timeVals < 0;
    
    if jIndex == 1
        Results.fftST_plaid = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq),length(freqbins));
        Results.fftBL_plaid  = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq),length(freqbins));
        Results.ampDiff_plaid = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
        Results.fftST_grating = nan(length(Indices),length((TotalElectrodestoRun)),1,length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq),length(freqbins));
        Results.fftBL_grating= nan(length(Indices),length((TotalElectrodestoRun)),1,length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq),length(freqbins));
        Results.ampDiff_grating = nan(length(Indices),length((TotalElectrodestoRun)),1,length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
        Results.changeInAmpNeg = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
        Results.changeInAmpSubtract= nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
        
        if ImValFlag == 1
            Results.ampDiff_plaid_F1F2plus = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
            Results.ampDiff_plaid_F1F2minus  = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
            Results.ampDiff_plaid_TwiceF1F2plus  = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
            Results.ampDiff_plaid_TwiceF1F2minus = nan(length(Indices),length((TotalElectrodestoRun)),length(Results.parameters{1, 1}.cValsUnique),length(Results.parameters{1, 1}.cValsUnique),length(fid_MaskFreq));
        end
    end
    
    if ~isempty(electrodeNums)
        for  iElec = 1:length(electrodeNums)
            disp(['elec' num2str(electrodeNums(iElec))]);
            
            clear analogDataAllGra analogDataAllPld
            analogDataAllGra = cell(1,length(Results.parameters{jIndex}.cValsUnique2),length(Results.parameters{jIndex}.tValsUnique2));
            analogDataAllPld = cell(length(Results.parameters{jIndex}.cValsUnique),length(Results.parameters{jIndex}.cValsUnique2),length(Results.parameters{jIndex}.tValsUnique2));
            
            clear analogData dcShiftCorrection
            load(fullfile(folderSegment,'LFP',['elec' num2str(electrodeNums(iElec))]),'analogData');
            
            if dcShiftCorrectionFlag == 1
                % correcting for dc shift
                dcShiftCorrection = mean(mean(analogData(:,blPos),1)); % doing baseline correction
                analogData = analogData-dcShiftCorrection;
            end
            
            
            if  isempty(ElectrodesToRun)
                ElecSaveOrder = electrodeNums(iElec);
            else
                ElecSaveOrder = iElec;
            end
            
            % grating
            for Con = 1
                for Con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                    for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                        trialNums = Results.parameters{jIndex}.parameterCombinations{1,1,1,1,1,1};
                        trialNums = intersect(trialNums,Results.parameters{jIndex}.parameterCombinations2{1,1,1,1,1,Con2,tf});
                        if useCommonBadTrials
                            trialNums = setdiff(trialNums,badTrials{1,1});
                        else
                            trialNums = setdiff(trialNums,badTrials{1,1}{1,electrodeNums(iElec)});
                        end
                        analogDataAllGra{1,Con2,tf} = cat(1,analogDataAllGra{1,Con2,tf},analogData(trialNums,:));
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
                            trialNums = setdiff(trialNums,badTrials{1,1}{1,electrodeNums(iElec)});
                        end
                        analogDataAllPld{Con,Con2,tf} = cat(1,analogDataAllPld{Con,Con2,tf},analogData(trialNums,:));
                    end
                end
            end
            
            if commonBaselineFlag        %common baseline for each electrode
                % removing bad trials from the analog Data - so that
                % we only take good trials baseline data
                clearvars analogDataTrialsForGoodBaseline
                allTrials = 1:size(analogData,1);
                if useCommonBadTrials
                    goodTrials = setdiff(allTrials,badTrials{1,1});
                else
                    goodTrials = setdiff(allTrials,badTrials{1,1}{1,electrodeNums(iElec)});
                end
                analogDataTrialsForGoodBaseline = analogData(goodTrials,:);
            end
            
            %%%% grating data %%%
            for Con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                    
                    if useCommonBaselineFlag
                        if useERP
                            fftBL = (abs(fft(mean(analogDataTrialsForGoodBaseline(:,blPos),1))))./count;
                            fftST = (abs(fft(mean(analogDataAllGra{1,Con2,tf}(:,stPos),1)))/count);
                        else
                            fftBL =mean(abs(fft(analogDataTrialsForGoodBaseline(:,blPos),[],2)),1)./count;
                            fftST = (mean(abs(fft(analogDataAllGra{1,Con2,tf}(:,stPos),[],2)))/count);
                        end
                        
                    else % individual trial baseline
                        
                        if useERP
                            fftBL = (abs(fft(mean(analogDataAllGra{1,Con2,tf}(:,blPos),1)))/count);
                            fftST = (abs(fft(mean(analogDataAllGra{1,Con2,tf}(:,stPos),1)))/count);
                        else
                            fftBL = (mean(abs(fft(analogDataAllGra{1,Con2,tf}(:,blPos),[],2)))/count);
                            fftST = (mean(abs(fft(analogDataAllGra{1,Con2,tf}(:,stPos),[],2)))/count);
                        end
                        
                    end
                    % gain for TF2 in absence of TF1
                    Results.fftST_grating(SessionCount,ElecSaveOrder,1,Con2,tf,:) = fftST;
                    Results.fftBL_grating(SessionCount,ElecSaveOrder,1,Con2,tf,:) = fftBL;
                    Results.ampDiff_grating(SessionCount,ElecSaveOrder,1,Con2,tf)  = (fftST(fid_MaskFreq(tf))-fftBL(fid_MaskFreq(tf)));
                end
            end
            
            %%%% plaid data %%%
            for Con1 = 1:length(Results.parameters{jIndex}.cValsUnique)
                for Con2 = 1:length(Results.parameters{jIndex}.cValsUnique2)
                    for tf = 1:length(Results.parameters{jIndex}.tValsUnique2)
                        
                        if useCommonBaselineFlag
                            if useERP
                                fftBL1 = (abs(fft(mean(analogDataTrialsForGoodBaseline(:,blPos),1))))./count;
                                fftST1 = (abs(fft(mean(analogDataAllPld{Con1,Con2,tf}(:,stPos),1)))/count);
                            else
                                fftBL1 = mean(abs(fft(analogDataTrialsForGoodBaseline(:,blPos),[],2)),1)./count;
                                fftST1 = (mean(abs(fft(analogDataAllPld{Con1,Con2,tf}(:,stPos),[],2)))/count);
                            end
                        else
                            if useERP
                                fftBL1 = (abs(fft(mean(analogDataAllPld{Con1,Con2,tf}(:,blPos),1)))/count);
                                fftST1 = (abs(fft(mean(analogDataAllPld{Con1,Con2,tf}(:,stPos),1)))/count);
                            else
                                fftBL1 = (mean(abs(fft(analogDataAllPld{Con1,Con2,tf}(:,blPos),[],2)))/count);
                                fftST1 = (mean(abs(fft(analogDataAllPld{Con1,Con2,tf}(:,stPos),[],2)))/count);
                            end
                        end
                        %gain for TF1 (centre TF) as function of TF2
                        Results.fftST_plaid(SessionCount,ElecSaveOrder,Con1,Con2,tf,:) = fftST1;
                        Results.fftBL_plaid(SessionCount,ElecSaveOrder,Con1,Con2,tf,:)= fftBL1;
                        Results.ampDiff_plaid(SessionCount,ElecSaveOrder,Con1,Con2,tf)  = (fftST1(fid_TargetFreq)- fftBL1(fid_TargetFreq));
                        
                        if ImValFlag == 1
                            Results.ampDiff_plaid_F1F2plus(SessionCount,ElecSaveOrder,Con1,Con2,tf)  = (fftST1(fid_F1F2plus(tf))- fftBL1(fid_F1F2plus(tf)));
                            Results.ampDiff_plaid_F1F2minus(SessionCount,ElecSaveOrder,Con1,Con2,tf)  = (fftST1(fid_F1F2minus(tf))- fftBL1(fid_F1F2minus(tf)));
                            Results.ampDiff_plaid_TwiceF1F2plus(SessionCount,ElecSaveOrder,Con1,Con2,tf)  = (fftST1(fid_TwiceF1F2plus(tf))- fftBL1(fid_TwiceF1F2plus(tf)));
                            Results.ampDiff_plaid_TwiceF1F2minus(SessionCount,ElecSaveOrder,Con1,Con2,tf)  = (fftST1(fid_TwiceF1F2minus(tf))- fftBL1(fid_TwiceF1F2minus(tf)));
                        end
                        
                    end
                end
                
                Results.changeInAmpNeg(SessionCount,ElecSaveOrder,Con1,:,:)  = Results.ampDiff_plaid(SessionCount,ElecSaveOrder,Con1,:,:) - repmat(Results.ampDiff_plaid(SessionCount,ElecSaveOrder,1,4,freqTF),1,1,1,length(Results.parameters{jIndex}.cValsUnique2),length(Results.parameters{jIndex}.tValsUnique2));
                Results.changeInAmpSubtract(SessionCount,ElecSaveOrder,Con1,:,:)  = Results.ampDiff_plaid(SessionCount,ElecSaveOrder,Con1,:,:) - repmat(Results.ampDiff_plaid(SessionCount,ElecSaveOrder,Con1,1,:) ,1,1,1,length(Results.parameters{jIndex}.cValsUnique2),1);
                
            end
        end
    end
    SessionCount = SessionCount+1;
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

