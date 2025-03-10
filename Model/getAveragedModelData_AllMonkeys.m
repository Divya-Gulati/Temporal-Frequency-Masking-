function PlotData = getAveragedModelData_AllMonkeys(expVarCutOff,modelNum,fileName)

Data = load(fullfile(fileName),'exitflag','expVar','Parameters','estData','observedData','TargetFrequency','maskTFList');

for iMonkey = 1:size(Data.exitflag,1)
        MonkeyNum = iMonkey;
    for idel =1:size(Data.exitflag,2)
        clear lenElecs elecIDs
        lenElecs = 1:length(Data.exitflag{MonkeyNum, idel});
        elecIDs = Data.exitflag{MonkeyNum, idel}>0 & Data.expVar{MonkeyNum, idel}>=expVarCutOff(iMonkey) ;
        PlotData.goodElecIds{iMonkey, idel} = lenElecs(elecIDs)';
        PlotData.goodElecPercent{iMonkey, idel} = size(PlotData.goodElecIds{iMonkey, idel},1)./size(Data.exitflag{MonkeyNum, idel},1);
        
        %%%%%% getting parameters only for good elecIDs %%%%%
        
        %%% Parameters 1st two values are sigma and N and rest values are mask
        %%% frequencies except when target and mask frequency was same.
        PlotData.goodParameters{iMonkey,idel}=  Data.Parameters{MonkeyNum, idel}(PlotData.goodElecIds{iMonkey, idel},:);
        
        %%%getting fitted data and experimentally obtained for goodElecs %%%
        PlotData.good_fitted_data{iMonkey, idel} = Data.estData{MonkeyNum, idel}(PlotData.goodElecIds{iMonkey, idel},:,:,:);
        PlotData.exp_obt_data{iMonkey, idel} = Data.observedData{MonkeyNum, idel}(PlotData.goodElecIds{iMonkey, idel},:,:,:);
        
        %%% taking mean,median, sem of parameters %%%    
        PlotData.median_goodParams(iMonkey, idel,:)= median(PlotData.goodParameters{iMonkey, idel},1);
        PlotData.mean_goodParams(iMonkey, idel,:)= mean(PlotData.goodParameters{iMonkey, idel},1); 
        PlotData.sem_goodParams(iMonkey, idel,:)= (std(PlotData.goodParameters{iMonkey, idel},[],1))./sqrt(size(PlotData.goodParameters{iMonkey, idel},1));
        
        for iparam = 1:size(PlotData.goodParameters{iMonkey, idel},2)
            paramTocheck = PlotData.goodParameters{iMonkey, idel}(:,iparam);
            SEMedian = getSEMedian(paramTocheck,32);
            PlotData.medianSE_goodParams(iMonkey, idel,iparam) = SEMedian;
        end
        
        %%% calculating confidence intervals of parameters %%%
        ts = tinv([0.025  0.975],size(PlotData.goodParameters{iMonkey, idel},1)-1);      % T-Score
        PlotData.CI(iMonkey, idel,:,:) = squeeze(PlotData.mean_goodParams(iMonkey, idel,:))' + squeeze(ts.*PlotData.sem_goodParams(iMonkey, idel,:));
        
        %%%data mean and sem across elecs %%%
        PlotData.mean_exp_obt_data(iMonkey, idel,:,:,:)= squeeze(mean(PlotData.exp_obt_data{iMonkey, idel},1));
        PlotData.sem_exp_obt_data(iMonkey, idel,:,:,:)= squeeze((std(PlotData.exp_obt_data{iMonkey, idel},[],1)))./sqrt(size(PlotData.exp_obt_data{iMonkey, idel},1));
        PlotData.mean_good_fitted_data(iMonkey, idel,:,:,:)= squeeze(mean(PlotData.good_fitted_data{iMonkey, idel},1));
        PlotData.sem_good_fitted_data(iMonkey, idel,:,:,:)= squeeze((std(PlotData.good_fitted_data{iMonkey, idel},[],1)))./sqrt(size(PlotData.good_fitted_data{iMonkey, idel},1));
        
    end
end

if modelNum == 2
    GoodParameters = PlotData.goodParameters;
    [PlotData.estSuppressionData,PlotData.mean_SuppressionProfile,PlotData.sem_SuppressionProfile]=getSuppressionProfileFromModel(GoodParameters,Data.TargetFrequency,Data.maskTFList);
end

end

function [estSuppressionData,mean_SuppressionProfile,sem_SuppressionProfile]=getSuppressionProfileFromModel(GoodParameters,TargetFrequency,maskTFList)

Fs = 2000; % Sampling Frequency
estSuppressionData = cell(size(GoodParameters,1),size(GoodParameters,2));
mean_SuppressionProfile = double.empty([0 0 0]);
sem_SuppressionProfile= double.empty([0 0 0]);

for iMonkey = 1:size(GoodParameters,1)
    for iDel= 1:size(GoodParameters,2)
        for ilen = 1:size(GoodParameters{iMonkey,iDel},1)

            cutOff = GoodParameters{iMonkey,iDel}(ilen,end-3);
            alpha1 = GoodParameters{iMonkey,iDel}(ilen,end-2);
            alpha2 = GoodParameters{iMonkey,iDel}(ilen,end-1);
            scalingFactor = GoodParameters{iMonkey,iDel}(ilen,end);

            [BFilt,AFilt] = butter(2,cutOff/(Fs/2),'low');

            T = 0.8; % Stimulus Duration (in seconds)

            timeVals = 0:(1/Fs):(T-(1/Fs)); % time vector

            numTFs = length(maskTFList);

            targetWave = sin(2 * pi * TargetFrequency * timeVals);

            for iTF=1:numTFs

                maskWave = sin(2 * pi * maskTFList(iTF)* timeVals);

                inh1 = (targetWave+scalingFactor.*(maskWave)).^2;
                inh2 = (targetWave.^2) +scalingFactor.* (maskWave.^2);

                inh1 = inh1 - mean(inh1);
                inh2 = inh2 - mean(inh2);

                LPF_inh1 = filtfilt(BFilt,AFilt,inh1);
                LPF_inh2 = filtfilt(BFilt,AFilt,inh2);

                inhibitoryDrive = (alpha1.*(LPF_inh1))+((alpha2).*(LPF_inh2));

                mag_inhibitoryDrive = mean(inhibitoryDrive(1:end).^2);% fft_InhibitoryDrive = (abs(fft(inhibitoryDrive)))./(length(inhibitoryDrive)); sum(fft_InhibitoryDrive(1:end).^2); %can also be done this way - 

                estSuppressionData{iMonkey,iDel}(ilen,iTF) = mag_inhibitoryDrive;

            end
            estSuppressionData{iMonkey,iDel}(ilen,:)= estSuppressionData{iMonkey,iDel}(ilen,:)./max(estSuppressionData{iMonkey,iDel}(ilen,:));
        end
        mean_SuppressionProfile(iMonkey,iDel,:) = mean(estSuppressionData{iMonkey,iDel},1);
        sem_SuppressionProfile(iMonkey,iDel,:) = std(estSuppressionData{iMonkey,iDel},[],1)./sqrt(ilen);
    end
end
end