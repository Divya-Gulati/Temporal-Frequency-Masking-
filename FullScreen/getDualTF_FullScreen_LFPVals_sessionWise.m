function [Results] =getDualTF_FullScreen_LFPVals_sessionWise(Indices,folderSourceString,gridType,timeRange,useERP,commonBaselineFlag,useCommonBadTrials,dcShiftCorrectionFlag,folderHighRMSElecs)

if ~exist('useERP','var');                                         useERP = 0;                                       end
if ~exist('commonBaselineFlag','var');                commonBaselineFlag = 0;               end
if ~exist('useCommonBadTrials','var');               useCommonBadTrials = 1;              end
if ~exist('dcShiftCorrectionFlag','var');               dcShiftCorrectionFlag =0;               end

% getting all experiment dates and names
[~,monkeyNames,expDates,protocolNames,~,arrayTypes,arraysToSave] = allProtocolsMonkeys;

% initializing variables %
Results.fftST_plaid =  cell(1,1);
Results.fftBL_plaid =  cell(1,1);
Results.ampdiff_plaid =  cell(1,1);
Results.fftST_grating =  cell(1,1);
Results.fftBL_grating =  cell(1,1);
Results.ampdiff_grating =  cell(1,1);
Results.ChangeInAmpNeg =  cell(1,1);

SessionCount = 1;

for ind = 1:length(Indices) % running it for all protocol indices
    
    monkeyName = monkeyNames{Indices(ind)};
    expDate = expDates{Indices(ind)};
    protocolName = protocolNames{Indices(ind)};
    arrayType =  arrayTypes{Indices(ind)};           
    arrayToSave = arraysToSave{Indices(ind)};
    
    folderName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,protocolName);
    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');
    
    %%% getting high RMS (good) electrodes
    rmsElecFile = fullfile(folderHighRMSElecs,monkeyName,[monkeyName gridType 'RFData.mat']);
    if exist(rmsElecFile,'file')
        rmsElecs = load(rmsElecFile,'highRMSElectrodes');
    else
        rmsElecs.highRMSElectrodes = 1:96;
        warning('WARNING: high RMS Elecs not found');
    end
    
    % find bad impedance electrodes
    badImpedanceCutoff = 2500;
    impedanceFileName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,'impedanceValues.mat');
    impedanceVals = load(impedanceFileName);
    badImpedanceElecs = find(impedanceVals.impedanceValues>badImpedanceCutoff) ;
    
    [badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,arrayToSave,useCommonBadTrials);
    
    electrodeNums= setdiff(rmsElecs.highRMSElectrodes,unique([badImpedanceElecs,horzcat(badElecs{:})]));
    
    if strcmp(arrayType,'Dual')
        if strcmpi(arrayToSave,'V1')
            electrodeList{1} = intersect(electrodeNums,1:48);
        elseif  strcmpi(arrayToSave,'V4')
            electrodeList{1} = intersect(electrodeNums,49:96);
        elseif strcmpi(arrayToSave,'Both')
            electrodeList{1} = intersect(electrodeNums,1:48);
            electrodeList{2} = intersect(electrodeNums,49:96);
        end
    elseif strcmp (arrayType,'Single')
        electrodeList{1} = electrodeNums;
    end
    
    %%%%%%% loading parameter combinations and timeVals %%%%%%%%%
    
    Results.parameters{ind}= load(fullfile(folderExtract,'parameterCombinations.mat'));
    tVals = load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals');
    timeVals = round(tVals.timeVals,5);
    Results.parameters{ind}.timeVals = timeVals;
    
    Fs = round(1/(tVals.timeVals(2)-tVals.timeVals(1))); % Sampling Rate
    freqbins = round(0:1/diff(timeRange):Fs-1/diff(timeRange),2); % Frequency axis
    Results.parameters{ind}.freqbins = freqbins;
    count = length(freqbins); % N - length of fft
    
    %index for Target and Mask Frequency
    fid_MaskFreq = zeros(1,length(Results.parameters{ind}.tValsUnique2));
    fid_TargetFreq = freqbins == 2*Results.parameters{ind}.tValsUnique;
    for j = 1:length(Results.parameters{ind}.tValsUnique2)
        fid_MaskFreq(j) = find(freqbins == 2*Results.parameters{ind}.tValsUnique2(j));
    end
    
    % stimulus and baseline period
    stPos = timeVals >= timeRange(1) & timeVals < timeRange(2);
    blPos = timeVals >= -diff(timeRange) & timeVals < 0;
    
    % delta calculation %
    targetOri = Results.parameters{ind}.oValsUnique;
    MaskOri =  Results.parameters{ind}.oValsUnique2;
    Delta = abs(MaskOri-targetOri);
    
    if ind == 1
        if strcmp(arrayType,'Dual')
            TotalElectrodestoRun = 1:48;
        elseif strcmp (arrayType,'Single')
            TotalElectrodestoRun = 1:96;
        end
        Results.fftST_plaid(:,:) = {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq),length(freqbins))};
        Results.fftBL_plaid (:,:) = {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq),length(freqbins))};
        Results.ampdiff_plaid(:,:) =  {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq))};
        Results.fftST_grating(:,:) = {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq),length(freqbins))};
        Results.fftBL_grating(:,:) = {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq),length(freqbins))};
        Results.ampdiff_grating(:,:) = {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq))};
        Results.ChangeInAmpNeg (:,:) = {nan(length(Indices),length((TotalElectrodestoRun)),length(Delta),length(fid_MaskFreq))};
    end
    
    
    for iArray = 1:size(electrodeList,2)
        for ielec = 1:length(electrodeList{iArray})
            disp(['elec ' num2str(electrodeList{iArray}(ielec))]);
            
            clear analogDataAllGra analogDataAllPld
            analogDataAllGra = cell(length(Results.parameters{ind}.oValsUnique2),length(Results.parameters{ind}.tValsUnique2));
            analogDataAllPld = cell(length(Results.parameters{ind}.oValsUnique2),length(Results.parameters{ind}.tValsUnique2));
            
            clear analogData dcShiftCorrection
            load(fullfile(folderSegment,'LFP',['elec' num2str(electrodeList{iArray}(ielec))]),'analogData');
            
            if dcShiftCorrectionFlag == 1
                % correcting for dc shift
                dcShiftCorrection = mean(mean(analogData(:,blPos),1)); % doing baseline correction
                analogData = analogData-dcShiftCorrection;
            end
            
            for del = 1:length(Delta)
                if Delta(del) == 0
                    order = 1;
                elseif Delta(del) == 90
                    order = 2;
                end
                for t = 1:length(Results.parameters{ind}.tValsUnique2)
                    % grating case - left side at 0 %
                    clearvars trialNums
                    trialNums = Results.parameters{ind}.parameterCombinations{1,1,1,1,1,1,1};
                    trialNums = intersect(trialNums,Results.parameters{ind}.parameterCombinations2{1,1,1,1,del,1,t});
                    if useCommonBadTrials
                        trialNums = setdiff(trialNums,badTrials{1,iArray});
                    else
                        trialNums = setdiff(trialNums,badTrials{1,iArray}{1,electrodeList{iArray}(ielec)});
                    end
                    analogDataAllGra{del,t} = analogData(trialNums,:);
                    % plaid case - left side at 50%
                    clearvars trialNums
                    trialNums = Results.parameters{ind}.parameterCombinations{1,1,1,1,1,2,1};
                    trialNums = intersect(trialNums,Results.parameters{ind}.parameterCombinations2{1,1,1,1,del,1,t});
                    if useCommonBadTrials
                        trialNums = setdiff(trialNums,badTrials{1,iArray});
                    else
                        trialNums = setdiff(trialNums,badTrials{1,iArray}{1,electrodeList{iArray}(ielec)});
                    end
                    analogDataAllPld{order,t} = analogData(trialNums,:);
                end
            end
            
            if commonBaselineFlag        %common baseline for each electrode
                % removing bad trials from the analog Data - so that
                % we only take good trials baseline data
                clearvars analogDataTrialsForGoodBaseline
                allTrials = 1:size(analogData,1);
                if useCommonBadTrials
                    goodTrials = setdiff(allTrials,badTrials{1,iArray});
                else
                    goodTrials = setdiff(allTrials,badTrials{1,iArray}{1,electrodeList{iArray}(ielec)});
                end
                analogDataTrialsForGoodBaseline = analogData(goodTrials,:);
            end
            
            for o = 1:length(Delta)
                for t = 1:length(Results.parameters{ind}.tValsUnique2)
                    
                    % combining grating data across orientations %
                    clearvars conGra allOriGratingData
                    conGra = analogDataAllGra(:,t);
                    allOriGratingData = vertcat([],conGra{:});
                    
                    if commonBaselineFlag        %common baseline for each electrode
                        
                        % %%% calculating fft for grating and plaid case %%%
                        
                        if useERP
                            fftBL_plaid = (abs(fft(mean(analogDataTrialsForGoodBaseline(:,blPos),1))))./count;
                            fftST_plaid = (abs(fft(mean(analogDataAllPld{o,t}(:,stPos),1))))./count;
                            
                            fftBL_grating = (abs(fft(mean(analogDataTrialsForGoodBaseline(:,blPos),1))))./count;
                            fftST_grating = (abs(fft(mean(allOriGratingData(:,stPos),1))))./count;
                        else
                            fftBL_plaid = mean(abs(fft(analogDataTrialsForGoodBaseline(:,blPos),[],2)),1)./count;
                            fftST_plaid = mean(abs(fft(analogDataAllPld{o,t}(:,stPos),[],2)),1)./count;
                            
                            fftBL_grating = mean(abs(fft(analogDataTrialsForGoodBaseline(:,blPos),[],2)),1)./count;
                            fftST_grating = mean(abs(fft(allOriGratingData(:,stPos),[],2)),1)./count;
                        end
                        
                    else  % individual trial baseline
                        
                        if useERP
                            fftBL_plaid = (abs(fft(mean(analogDataAllPld{o,t}(:,blPos),1))))./count;
                            fftST_plaid = (abs(fft(mean(analogDataAllPld{o,t}(:,stPos),1))))./count;
                            
                            fftBL_grating = (abs(fft(mean(allOriGratingData(:,blPos),1))))./count;
                            fftST_grating = (abs(fft(mean(allOriGratingData(:,stPos),1)))./count);
                        else
                            fftBL_plaid = mean(abs(fft(analogDataAllPld{o,t}(:,blPos),[],2)),1)./count;
                            fftST_plaid = mean(abs(fft(analogDataAllPld{o,t}(:,stPos),[],2)),1)./count;
                            
                            fftBL_grating = mean(abs(fft(allOriGratingData(:,blPos),[],2)),1)./count;
                            fftST_grating = mean(abs(fft(allOriGratingData(:,stPos),[],2)),1)./count;
                        end
                    end
                    
                    %Results for plaid case
                    Results.fftST_plaid{iArray}(SessionCount,electrodeList{iArray}(ielec),o,t,:) = fftST_plaid;            %fft stimulus
                    Results.fftBL_plaid{iArray}(SessionCount,electrodeList{iArray}(ielec),o,t,:) = fftBL_plaid;            %fft baseline
                    temp_plaid =  fftST_plaid-fftBL_plaid;
                    Results.ampdiff_plaid{iArray}(SessionCount,electrodeList{iArray}(ielec),o,t) = temp_plaid(fid_TargetFreq); % change in amplitude plaid case
                    %Results for grating case
                    Results.fftST_grating{iArray}(SessionCount,electrodeList{iArray}(ielec),o,t,:) = fftST_grating;           %fft stimulus
                    Results.fftBL_grating{iArray}(SessionCount,electrodeList{iArray}(ielec),o,t,:) = fftBL_grating;           %fft baseline
                    temp_grating =  fftST_grating- fftBL_grating;
                    Results.ampdiff_grating{iArray}(SessionCount,electrodeList{iArray}(ielec),o,t) = temp_grating(fid_MaskFreq(t));
                    clearvars fftST_plaid fftBL_plaid temp_plaid fftBL_grating fftST_grating temp_grating
                end
            end
            
            %%%%%% subtracting change in amplitude for plaid case from grating
            %%%%%% case
            clear gratingCaseAmp plaidCaseAmp
            selectedFreq = Results.parameters{ind}.tValsUnique2 == Results.parameters{ind}.tValsUnique;
            gratingCaseAmp = mean(Results.ampdiff_grating{iArray}(SessionCount,electrodeList{iArray}(ielec),:,selectedFreq));
            Results.ChangeInAmpNeg{iArray}(SessionCount,electrodeList{iArray}(ielec),:,:) = Results.ampdiff_plaid{iArray}(SessionCount,electrodeList{iArray}(ielec),:,:) - repmat(gratingCaseAmp,1,1,size(Results.ampdiff_plaid{iArray},3),size(Results.ampdiff_plaid{iArray},4));
        end
    end
    SessionCount = SessionCount+1;
end
end

function [badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,arrayToSave,useCommonBadTrials)

if strcmp(arrayType,'Dual')
    if strcmpi(arrayToSave,'V1')
        badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrialsV1.mat');
    elseif strcmpi(arrayToSave,'V4')
        badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrialsV4.mat');
    elseif strcmpi(arrayToSave,'Both')
        badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrialsV1.mat');
        badTrialsandElecsFile{2} = fullfile(folderSegment,'badTrialsV4.mat');
    end
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