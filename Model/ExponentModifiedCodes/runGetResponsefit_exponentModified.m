clear;clc;

%%%%% getting Model Data %%%
filepath = 'E:\MonkeyDataAnalysis\Plaid';

spikeFlag =0;

if spikeFlag == 1
    load(fullfile(filepath,'SmallStimPlaid_GoodSpikeElecsSpike_Microelectrode.mat'));
    badElecs = {[],[];[],[];[],[]};
else
    load(fullfile(filepath,'SmallStimPlaid_HighRMSLFP_sessionWise_Microelectrode.mat'));
    badElecs = {[],[];[],[];[],[]};
end


% Parameters
cList = [0 0.0625 0.125 0.25];%contrast
tfList = 1:2:29;%TF
dList = [0 90];%Delta
MonkeyID = {'M1','M2','M3'};
TargetFrequency = 15;
maskTFList = [1:2:13 17:2:29];

numTotalTF = length(tfList);
numContrasts  = length(cList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rearranging data for ampDiff_plaid and keeping just that %

for iMonkey = 1:size(Results,2)
    for idelta = 1:size(Results,1)
        clearvars temp_field temp_session tempIds tempGoodElecs
        temp_field = Results{idelta, iMonkey}.ampDiff_plaid;
        temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
        tempIds = all(~isnan(temp_session),4); % removing extra electrodes - keeping only the good ones
        tempGoodElecs = temp_session(tempIds(:,1,1),:,:,:,:);
        input_data{iMonkey,idelta} = tempGoodElecs;
    end
end
clearvars Results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  Model 1 - Untuned normalization model- Salelkar and Ray 2020
%  Model 2 - New reduced Model
ModelNames = {'Tuned_Normalization_Model','Optimal_Model'};

for modelNum =1:length(ModelNames)
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
            
            %%%%%% averaging across electrodes for spikes %%%%%%%
            if spikeFlag == 1
                mData{1,idel}= mean(mData{1,idel}(goodElecs,:,:,:),1);
                goodElecs = 1:size(mData{1,idel},1);
            end
            
            observedData{iMon,idel}=  mData{1,idel}(goodElecs,:,:,:);
            
            for ielec = 1:size(goodElecs,2)
                
                dataToBeFitted = squeeze(mData{idel}(goodElecs(1,ielec),:,:,:));
                
                numTFs = size(mData{idel},4);
                
                [startPoint,lowerbound,upperbound] = getStartValsDualTFModel_exponentModified(numTFs,modelNum,dList(idel),MonkeyID{iMon});
                
                %scaling = 10*ones(1,length(startPoint));
                
                opts = optimoptions(@fmincon, 'algorithm','interior-point','StepTolerance',1e-15,...
                    'FunctionTolerance',1e-15,'OptimalityTolerance',1e-15...
                    ,'MaxIterations',1e4,'MaxFunctionEvaluations',1e10,...
                    'ConstraintTolerance',1e-15,'FiniteDifferenceType','central',...
                    'Display','iter-detailed');%,'TypicalX',scaling
                 
                clearvars params ef
                while true  
                    [params,~,ef,~] = fmincon(@(params) getResponsefit_exponentModified(params,cList,dataToBeFitted,modelNum,TargetFrequency,maskTFList),startPoint,[],[],[],[],lowerbound,upperbound,[],opts);
                    [errorResidual{iMon,idel}(ielec,:),estData{iMon,idel}(ielec,:,:,:)] = getResponsefit_exponentModified(params,cList,dataToBeFitted,modelNum,TargetFrequency,maskTFList);
                    if isreal(params) && isreal(estData{iMon,idel}(ielec,:,:,:)) %&& ef == 1
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
     
    if spikeFlag == 1
        SaveFilname = ("Model_SpikeData_for_all_elecs_alldelta_allSession_ExponentModified"+ ModelNames{modelNum} +".mat");
    else 
        SaveFilname = ("Model_LFPData_for_all_elecs_alldelta_allSession_ExponentModified"+ ModelNames{modelNum} +".mat");
    end
    
    destination = ("E:\MonkeyDataAnalysis\Model");%
    save(fullfile(destination,SaveFilname),'observedData','estData','errorResidual','Parameters','expVar','errorVar','exitflag','tfList','dList','cList','TargetFrequency','maskTFList');
end