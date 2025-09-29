clear;clc;

%%%%% getting Model Data %%%
filepath = 'E:\MonkeyData_DualTFSmallPaper\savedData';
savedestination = ("E:\MonkeyData_DualTFSmallPaper\savedData\Model");  % destination to save the model fits

load(fullfile(filepath,'SmallStimPlaid_HighRMSLFP_sessionWise_Microelectrode.mat'));
load(fullfile(filepath,'SmallStimPlaid_GoodSpikeElecsSpike_Microelectrode.mat'));
eegResults = load(fullfile(filepath,'FullStimPlaid_sessionWise_EEG.mat'));

badElecs = {[],[];[],[];[],[];[],[];[],[]}; % if you want to specify any electrode as bad for fitting from the get go

% Parameters
tfList = 1:2:29;%TF
dList = [0 90];%Delta
MonkeyID = {'M1','M2','M3','SPK','EEG'}; % M1,M2 - Microelectrode, M3-ECoG, SPK- Spiking data of M1,M2, EEG Data of M2 and M4
TargetFrequency = 15;
maskTFList = [1:2:13 17:2:29];

numTotalTF = length(tfList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_data = cell(5,2);
%%% getting eeg results for electrodes above 0.5uV cutoff
cutoff = 0.5;
for iMonkey = 1:size(eegResults.Results,2) % M2 and M4
    for idelta = 1:size(eegResults.Results,1)
        allVals = squeeze(eegResults.Results{idelta, iMonkey}.ampDiff_grating(1,:,:,4,8)); % choosing electrodes above a certain cutoff for grating at 25% contrast at 15Hz
        allElecs = 1:size(eegResults.Results{idelta, iMonkey}.ampDiff_grating,2);
        goodElecsEEG{idelta,iMonkey} = allElecs(allVals>cutoff);
    end
end

%Rearranging data for ampDiff_plaid and keeping just that %

for iMonkey = 1:size(Results,2)
    for idelta = 1:size(Results,1)
        clearvars temp_field temp_session tempIds tempGoodElecs
        temp_field = Results{idelta, iMonkey}.ampDiff_plaid;
        temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
        tempIds = all(~isnan(temp_session),4); % removing extra electrodes - keeping only the good ones
        tempGoodElecs = temp_session(tempIds(:,1,1),:,:,:,:);
        input_data{iMonkey,idelta} = tempGoodElecs;
        if iMonkey <=2
            input_data_EEG{iMonkey,idelta} = squeeze(eegResults.Results{idelta, iMonkey}.ampDiff_plaid(1,goodElecsEEG{idelta,iMonkey},:,:,:));
        end
    end
end
clearvars Results 

% getting spike results and adding them as 4th row in input_data
iSpikeResults = 2; % giving only high cutoff units for fitting 
clearvars temp_spike_field
for idelta = 1:size(SpikeResults,2)
    for  iMonkey = 1:size(SpikeResults,3)
        temp_spike_field{idelta,iMonkey} = squeeze(SpikeResults{iSpikeResults,idelta, iMonkey}.ampDiff_spike_plaid);
    end
    temp_input_dataSpike{idelta} = cat(1,temp_spike_field{idelta,:});
end

input_data(4,:)= temp_input_dataSpike;

%%% merging EEG data from both monkeys together and adding that as 5th row
%%% of input data
for idelta = 1:size(input_data_EEG,2)
    input_data{5,idelta} = cat(1,input_data_EEG{:,idelta});
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Model 1 - Untuned normalization model- Salelkar and Ray 2020
%  Model 2 - New reduced Model
ModelNames = {'Tuned_Normalization_Model','Optimal_Model'};

for modelNum = 1:length(ModelNames)
    clearvars d eData Parameters exitflag expVar n_temp
    % % initiating variables
    errorResidual = cell(size(input_data,1),size(input_data,2));
    estData = cell(size(input_data,1),size(input_data,2));
    Parameters = cell(size(input_data,1),size(input_data,2));
    exitflag = cell(size(input_data,1),size(input_data,2));
    expVar = cell(size(input_data,1),size(input_data,2));
    errorVar = cell(size(input_data,1),size(input_data,2));
    observedData= cell(size(input_data,1),size(input_data,2));
    
    %%%%%%%%%%%%
    
    for iMon =1:size(input_data,1) % monkey across rows
        

        cListLeft = [0 0.0625 0.125 0.25];%contrast
        cListRight = [0 0.0625 0.125 0.25];%contrast

        data_model = input_data(iMon,:);
        badElecs_TF = badElecs(iMon,:);
        
        targetTf = find(tfList==TargetFrequency);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        good_freqList = setdiff(1:numTotalTF,targetTf);
        
        % taking only 14 mask frequency - removing mask freq that is same
        % as target frequency
        clearvars mData
        mData = cell(1,size(data_model,2));
        
        for isize = 1:size(data_model,2)
            mData{1,isize}= data_model{1,isize}(:,:,:,good_freqList);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data Fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for idel =1:size(mData,2)
            
            clearvars goodElecs
            goodElecs = setdiff(1:size(mData{1,idel},1),badElecs_TF{1,idel});
   
            observedData{iMon,idel}=  mData{1,idel}(goodElecs,:,:,:);
            
            for ielec =1:size(goodElecs,2)
                
                dataToBeFitted = squeeze(mData{idel}(goodElecs(1,ielec),:,:,:));
                
                numTFs = size(mData{idel},4);
                
                % gets the starting values and bounds for the respective
                % mode, plaid and monkey
                [startPoint,lowerbound,upperbound] = getStartValsDualTFModel(numTFs,modelNum,dList(idel),MonkeyID{iMon});
                
                
                opts = optimoptions(@fmincon, 'algorithm','interior-point','StepTolerance',1e-15,...
                    'FunctionTolerance',1e-15,'OptimalityTolerance',1e-15...
                    ,'MaxIterations',1e4,'MaxFunctionEvaluations',1e10,...
                    'ConstraintTolerance',1e-15,'FiniteDifferenceType','central',...
                    'Display','iter-detailed');
                 
                clearvars params ef
                while true  
                    [params,~,ef,~] = fmincon(@(params) getResponsefit(params,cListLeft,cListRight,dataToBeFitted,modelNum,TargetFrequency,maskTFList),startPoint,[],[],[],[],lowerbound,upperbound,[],opts);
                    [errorResidual{iMon,idel}(ielec,:),estData{iMon,idel}(ielec,:,:,:)] = getResponsefit(params,cListLeft,cListRight,dataToBeFitted,modelNum,TargetFrequency,maskTFList);
                    if isreal(params) && isreal(estData{iMon,idel}(ielec,:,:,:)) 
                        break;
                    end
                end
                
                Parameters{iMon,idel}(ielec,:) = params;
                exitflag{iMon,idel}(ielec,:) = ef;
                
                clearvars expVarDenom_temp n_temp numerator_errorVar
                expVarDenom_temp = sum((dataToBeFitted(:)-mean(dataToBeFitted(:))).^2);
                n_temp = length(reshape(estData{iMon,idel}(ielec,:,:,:),1,[]));
                numerator_errorVar = sqrt(errorResidual{iMon,idel}(ielec,:)./n_temp);
                
                expVar{iMon,idel}(ielec,:) = 1 - ((errorResidual{iMon,idel}(ielec,:))./expVarDenom_temp);
                errorVar{iMon,idel}(ielec,:) = 1- (numerator_errorVar./mean(dataToBeFitted(:)));
                
            end
        end
    end
     
  
    SaveFilname = ("Model_LFPData_for_all_elecs_alldelta_allSession_"+ ModelNames{modelNum} +".mat");
    save(fullfile(savedestination,SaveFilname),'observedData','estData','errorResidual','Parameters','expVar','errorVar','exitflag','tfList','dList','cListLeft','cListRight','TargetFrequency','maskTFList');
end