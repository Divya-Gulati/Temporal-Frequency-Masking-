function [analogDataAllElec,elecfftST,elecfftBL,ampDiff,params] =saveLFPDataConTF_sessionWise(monkeyName,folderSourceString,gridType,useERP,commonBaselineFlag,useCommonBadTrials,ConsiderBadImpedanceFlag,ConsiderHighRMSFlag,folderHighRMSElecs,electrodesToProcess,goodSpikingFlag,checkClearTransientFlag,cutOffs)

if ~exist('useERP','var');                                        useERP = 1;                                               end
if ~exist('commonBaselineFlag','var');                commonBaselineFlag = 1;                       end
if ~exist('useCommonBadTrials','var');               useCommonBadTrials = 1;                      end
if ~exist('ConsiderBadImpedanceFlag','var');     ConsiderBadImpedanceFlag = 1;            end
if ~exist('ConsiderHighRMSFlag','var');              ConsiderHighRMSFlag = 1;                     end
if ~exist('electrodesToProcess','var');                  electrodesToProcess = [];                         end
if ~exist('goodSpikingFlag','var');                        goodSpikingFlag = 0;                               end

% getting the experiment Date and protocol Name - And arrayType and
% Number of Electrodes
[expDates,protocolNames,arrayType,timeRange,arraysToSave,TotalElecs,conToSave,tfToSave] = protocolInformationConTF(monkeyName,gridType);

if length(expDates) == 2
    expDates = unique(str2double(expDates),'stable');
else
    expDates = str2double(expDates);
end

% initializing variables %

if ~isempty(arraysToSave)
    analogDataAllElec = cell(1,length({arraysToSave}));
    elecfftST= cell(1,length({arraysToSave}));
    elecfftBL= cell(1,length({arraysToSave}));
    ampDiff= cell(1,length({arraysToSave}));
else
    analogDataAllElec = cell(1,1);
    elecfftST= cell(1,1);
    elecfftBL= cell(1,1);
    ampDiff= cell(1,1);
end

SessionCount_array1 = 1;
SessionCount_array2 = 1;

for idate = 1:length(expDates)
    expDate = num2str(expDates(idate),'%06.f');
    
    if length(expDates) == 1
        pName = protocolNames;
    else
        pName = protocolNames(idate);
    end
    
    % getting highRMSElecs for this monkey %
    rmsElecs = getHighRMSElecs (monkeyName,gridType,folderHighRMSElecs,ConsiderHighRMSFlag,electrodesToProcess,TotalElecs{idate});
    
    for iprot = 1:length(pName)
        protocolName = pName{iprot};
        
        if strcmp(monkeyName,'coco')
            SessionCount_array1 = 1;
        end
        
        folderName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,protocolName);
        folderExtract = fullfile(folderName,'extractedData');
        folderSegment = fullfile(folderName,'segmentedData');
        
        %%% getting badImpedance electrodes
        badImpedanceElecs = gethighImpedanceElecs(monkeyName,folderSourceString,expDate,gridType,ConsiderBadImpedanceFlag);
        
        %%% find bad elecs and trials
        [badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,arraysToSave,useCommonBadTrials);
        
        %%% loading parameter combinations %%%
        parameters = load(fullfile(folderExtract,'parameterCombinations.mat'));
        
        
        if isfield( parameters , 'sValsUnique' )
            valsSigma = parameters.sValsUnique;
        else
            valsSigma = parameters.rValsUnique;
        end
        
        if isempty(conToSave)
            valsCon= parameters.cValsUnique;
        else
            valsCon = conToSave;
        end
        
        if isempty(tfToSave)
            valsTF = parameters.tValsUnique;
        else
            valsTF = tfToSave;
        end
        
        parameters.ConSaved = valsCon;
        parameters.TFSaved = valsTF;
        
        %%%%%%%%%% getting the final electrodes to run %%%%%%%%%%%
        electrodeList = getFinalGoodElectrodes(idate,arrayType,arraysToSave,rmsElecs,badImpedanceElecs,badElecs,TotalElecs);
        if goodSpikingFlag == 1
            electrodeList = getgoodSpikingElecsConTF(monkeyName,folderSegment,electrodeList(1,1),parameters,badTrials,timeRange,useCommonBadTrials,checkClearTransientFlag,cutOffs);
        end
        
        
        parameters.FinalElectrodeIds = electrodeList; % saving electrodeIds also
        
        %%% loading timeVals
        load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals');
        parameters.timeVals = timeVals;
        stPos = round(timeVals,4) >= timeRange(1) &  round(timeVals,4) < timeRange(2);
        blPos =  round(timeVals,4) >= -diff(timeRange) &  round(timeVals,4) < 0;
        
        %%% making Freqaxis
        Fs = round(1/(timeVals(2)-timeVals(1)));
        parameters.Freq = 0:1/diff(timeRange):Fs-1/diff(timeRange);
        for jj = 1:length(valsTF)
            fidxTF(jj) = find(parameters.Freq == 2*valsTF(jj)); %#ok<AGROW>
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if idate == 1 && iprot == 1
            TotalElectrodestoRun = TotalElecs{1, 1}{1, 1};
            if strcmp(monkeyName,'coco')
                analogDataAllElec(:,:) = {nan(length(expDates),length((TotalElectrodestoRun)),length(valsSigma)+1,length(valsCon),length(valsTF),length(timeVals))};
                elecfftST(:,:) ={nan(length(expDates),length(TotalElectrodestoRun),length(valsSigma)+1,length(valsCon),length(valsTF),length(parameters.Freq))};
                elecfftBL(:,:) = {nan(length(expDates),length(TotalElectrodestoRun),length(valsSigma)+1,length(valsCon),length(valsTF),length(parameters.Freq))};
                ampDiff(:,:) = {nan(length(expDates),length(TotalElectrodestoRun),length(valsSigma)+1,length(valsCon),length(valsTF))};
            elseif strcmp(monkeyName,'alpaH') || strcmp(monkeyName,'kesariH')
                TotalElectrodestoRun1 = TotalElecs{1, 1}{1, 1};
                analogDataAllElec(1,:) = {nan(length(expDates),length((TotalElectrodestoRun1)),length(valsSigma)+1,length(valsCon),length(valsTF),length(timeVals))};
                elecfftST(1,:) ={nan(length(expDates),length(TotalElectrodestoRun1),length(valsSigma)+1,length(valsCon),length(valsTF),length(parameters.Freq))};
                elecfftBL(1,:) = {nan(length(expDates),length(TotalElectrodestoRun1),length(valsSigma)+1,length(valsCon),length(valsTF),length(parameters.Freq))};
                ampDiff(1,:) = {nan(length(expDates),length(TotalElectrodestoRun1),length(valsSigma)+1,length(valsCon),length(valsTF))};
                TotalElectrodestoRun2 =TotalElecs{1, 1}{2, 1} ;
                analogDataAllElec(2,:) = {nan(length(expDates),length((TotalElectrodestoRun2)),length(valsSigma)+1,length(valsCon),length(valsTF),length(timeVals))};
                elecfftST(2,:) ={nan(length(expDates),length(TotalElectrodestoRun2),length(valsSigma)+1,length(valsCon),length(valsTF),length(parameters.Freq))};
                elecfftBL(2,:) = {nan(length(expDates),length(TotalElectrodestoRun2),length(valsSigma)+1,length(valsCon),length(valsTF),length(parameters.Freq))};
                ampDiff(2,:) = {nan(length(expDates),length(TotalElectrodestoRun2),length(valsSigma)+1,length(valsCon),length(valsTF))};
            else
                analogDataAllElec(:,:) = {nan(length(expDates),length((TotalElectrodestoRun)),length(valsSigma),length(valsCon),length(valsTF),length(timeVals))};
                elecfftST(:,:) ={nan(length(expDates),length(TotalElectrodestoRun),length(valsSigma),length(valsCon),length(valsTF),length(parameters.Freq))};
                elecfftBL(:,:) = {nan(length(expDates),length(TotalElectrodestoRun),length(valsSigma),length(valsCon),length(valsTF),length(parameters.Freq))};
                ampDiff(:,:) = {nan(length(expDates),length(TotalElectrodestoRun),length(valsSigma),length(valsCon),length(valsTF))};
            end
        end
        %%% doing fft for each array and each electrode
        for iArray = 1:size(electrodeList,2)
            for ielec = 1:length(electrodeList{iArray})
                disp(['elec' num2str(electrodeList{iArray}(ielec))]);
                clear analogDataGra
                analogDataGra = cell(length(valsSigma),length(valsCon),length(valsTF));
                
                clear analogData
                load(fullfile(folderSegment,'LFP',['elec' num2str(electrodeList{iArray}(ielec))]),'analogData');
                
                paramsConInd= ismember(fix(parameters.cValsUnique),fix(valsCon));
                paramsTFInd= ismember(round(parameters.tValsUnique),round(valsTF));
                conIDs = nonzeros(paramsConInd .* (1:1:length(parameters.cValsUnique)))';
                TFIDs = nonzeros(paramsTFInd .* (1:1:length(parameters.tValsUnique)))';
                
                for s = 1:length(valsSigma)
                    
                    if strcmp(monkeyName,'coco') && iprot == 2
                        sigmaIndex = s+1;
                    else
                        sigmaIndex = s;
                    end
                    
                    for c = 1:length(valsCon)
                        for t = 1:length(valsTF)
                            trialNums = [parameters.parameterCombinations{end,end,s,end,end,conIDs(c),TFIDs(t)}];
                            if useCommonBadTrials
                                trialNums = setdiff(trialNums,badTrials{iArray});
                            else
                                trialNums = setdiff(trialNums,badTrials{iArray}{1,electrodeList{iArray}(ielec)});
                            end
                            analogDataGra{s,c,t} = cat(1,analogDataGra{s,c,t},analogData(trialNums,:));
                            
                            % ERP
                            temp_erp = mean(analogData(trialNums,:),1) ;
                            erp = temp_erp - mean(temp_erp(blPos));
                            
                            if iArray == 1
                                analogDataAllElec{iArray}(SessionCount_array1,electrodeList{iArray}(ielec),sigmaIndex,c,t,:) =erp;
                            else
                                analogDataAllElec{iArray}(SessionCount_array2,electrodeList{iArray}(ielec),sigmaIndex,c,t,:) =erp;
                            end
                            
                        end
                    end
                end
                
                if commonBaselineFlag
                    allTrials_temp = reshape(analogDataGra,[],1);
                    allTrials = (cat(1, allTrials_temp{:}));
                end
                
                % FFT and AmpDiff
                for s = 1:length(valsSigma)
                    if strcmp(monkeyName,'coco') && iprot == 2
                        sigmaIndex = s+1;
                    else
                        sigmaIndex = s;
                    end
                    for c = 1:length(valsCon)
                        for t = 1:length(valsTF)
                            if useERP
                                fftST = abs(fft(mean(analogDataGra{s,c,t}(:,stPos),1)))./length(abs(fft(mean(analogDataGra{s,c,t}(:,stPos),1))));
                                if commonBaselineFlag
                                    fftBL = (abs(fft(mean(allTrials(:,blPos),1)))./length(abs(fft(mean(allTrials(:,blPos),1)))));
                                else
                                    fftBL = (abs(fft(mean(analogDataGra{s,c,t}(:,blPos),1)))./length(abs(fft(mean(analogDataGra{s,c,t}(:,blPos),1)))));
                                end
                            else
                                fftST = (mean(abs(fft(analogDataGra{s,c,t}(:,stPos),[],2)))./length(mean(abs(fft(analogDataGra{s,c,t}(:,stPos),[],2)))));
                                if commonBaselineFlag
                                    fftBL = (mean(abs(fft(allTrials(:,blPos),[],2)))./length(mean(abs(fft(allTrials(:,blPos),[],2)))));
                                else
                                    fftBL = (mean(abs(fft(analogDataGra{s,c,t}(:,blPos),[],2)))./length(mean(abs(fft(analogDataGra{s,c,t}(:,blPos),[],2)))));
                                end
                            end
                            
                            if iArray == 1
                                elecfftST{iArray}(SessionCount_array1,electrodeList{iArray}(ielec),sigmaIndex,c,t,:) = fftST;
                                elecfftBL{iArray}(SessionCount_array1,electrodeList{iArray}(ielec),sigmaIndex,c,t,:) = fftBL;
                                ampDiff{iArray}(SessionCount_array1,electrodeList{iArray}(ielec),sigmaIndex,c,t) = ((fftST(fidxTF(t) ))-(fftBL(fidxTF(t))));
                            else
                                elecfftST{iArray}(SessionCount_array2,electrodeList{iArray}(ielec),sigmaIndex,c,t,:) = fftST;
                                elecfftBL{iArray}(SessionCount_array2,electrodeList{iArray}(ielec),sigmaIndex,c,t,:) = fftBL;
                                ampDiff{iArray}(SessionCount_array2,electrodeList{iArray}(ielec),sigmaIndex,c,t) = ((fftST(fidxTF(t) ))-(fftBL(fidxTF(t))));
                            end
                            
                        end
                    end
                end
            end
        end
        if iArray == 1
            SessionCount_array1 = SessionCount_array1+1;
        else
            SessionCount_array2 = SessionCount_array2+1;
        end
        params{idate,iprot} = parameters; %#ok<AGROW>
        clearvars parameters
    end
end
end

function rmsElecs = getHighRMSElecs (monkeyName,gridType,folderHighRMSElecs,ConsiderHighRMSFlag,electrodesToProcess,TotalElecs)

if strcmpi(gridType,'Microelectrode') && ConsiderHighRMSFlag == 1
    rmsElecs = load(fullfile(folderHighRMSElecs,monkeyName,[monkeyName gridType 'RFData.mat']),'highRMSElectrodes');
    
    if strcmpi (monkeyName,'kesariH')
        rmsElecs_second = load(fullfile(folderHighRMSElecs,monkeyName,[monkeyName gridType 'RFData_Two.mat']),'highRMSElectrodes');
        rmsElecs.highRMSElectrodes = union(rmsElecs.highRMSElectrodes,rmsElecs_second.highRMSElectrodes);
    end
else
    if ~isempty(electrodesToProcess)
        rmsElecs.highRMSElectrodes = electrodesToProcess;
    else
        rmsElecs.highRMSElectrodes  = TotalElecs{:};
    end
end

end

function badImpedanceElecs = gethighImpedanceElecs(monkeyName,folderSourceString,expDate,gridType,ConsiderBadImpedanceFlag)

if strcmpi(gridType,'Microelectrode') && ConsiderBadImpedanceFlag == 1 && ~strncmp(monkeyName,'alpa',4)
    % % % find bad impedance electrodes
    badImpedanceCutoff = 2500;
    impedanceFileName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,'impedanceValues.mat');
    impedanceVals = load(impedanceFileName);
    badImpedanceElecs = find(impedanceVals.impedanceValues>badImpedanceCutoff) ;
else
    badImpedanceElecs = [];
end

end

function [badTrials,badElecs] = getbadTrialsAndElecs(folderSegment,arrayType,arrayToSave,useCommonBadTrials)

if strcmp(arrayType,'Dual')
    if strcmp(arrayToSave,'V1')
        badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrialsV1.mat');
    elseif strcmp(arrayToSave,'V4')
        badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrialsV4.mat');
    elseif strcmp(arrayToSave,'Both')
        badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrials.mat');
    end
else
    badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrials.mat');
end

if strcmp(arrayType,'Hybrid')
    badTrialsandElecsFile{1} = fullfile(folderSegment,'badTrials.mat');
    badTrialsandElecsFile{2} = fullfile(folderSegment,'badTrialsECoG.mat');
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
        disp("Bad trial file does not exist for array_" +num2str(iB));
        badElecs{iB} = [];
        badTrials{iB} = [];
    end
end
end

function electrodeList = getFinalGoodElectrodes(idate,arrayType,arraysToSave,rmsElecs,badImpedanceElecs,badElecs,TotalElecs)

electrodeNum= setdiff(rmsElecs.highRMSElectrodes,unique([badImpedanceElecs,horzcat(badElecs{:})]));

if ~isempty(electrodeNum)
    if strcmpi(arrayType,'Hybrid')
        electrodeList{1} = intersect(TotalElecs{idate}{1},electrodeNum);
        electrodeList{2} = intersect(TotalElecs{idate}{2},electrodeNum);
    elseif strcmpi(arrayType,'Dual')
        electrodes_temp = intersect(cell2mat(TotalElecs{idate}),electrodeNum);
        if strcmpi(arraysToSave,'V1')
            electrodeList{1} = intersect(electrodes_temp,1:48);
        elseif strcmpi(arraysToSave,'V4')
            electrodeList{1} = intersect(electrodes_temp,49:96);
        elseif strcmpi(arraysToSave,'Both')
            electrodeList{1} = intersect(electrodes_temp,1:48);
            electrodeList{2} = intersect(electrodes_temp,49:96);
        end
    else
        electrodeList{1} = intersect(cell2mat(TotalElecs{idate}),electrodeNum);
    end
else
    electrodeList = TotalElecs{idate};
end
end