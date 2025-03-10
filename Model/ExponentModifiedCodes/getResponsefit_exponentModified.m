function [d,estData] = getResponsefit_exponentModified(params,cList,dataToBeFitted,modelNum,TargetFrequency,maskTFList)

numContrasts = length(cList);
sigma = params(1); % sigma(f_target)
Lamp = params(2);
n = params(3);

if modelNum==1 %Untuned normalization model- Salelkar and Ray 2020
    
    S = params(end-13:end); % suppression for each mask frequency
    numTFs = length(S);
    estData = zeros(numContrasts,numContrasts,numTFs);
    for icT = 1:numContrasts % target contrast
        cT = cList(icT);
        for iM = 1:numContrasts % mask contrast
            cM = cList(iM);
            for iTF=1:numTFs
                Lt = Lamp;
                estData(icT,iM,iTF) = ((Lt.*cT)./sqrt((sigma).^2+cT.^2+S(iTF).*(cM.^2))).^n; % Equation 3
            end
        end
    end
    
elseif modelNum==2 %New Model
    
    cutOff = params(end-3);
    alpha1 = params(end-2);
    alpha2 = params(end-1);
    scalingFactor = params(end);
    
    Fs = 2000; % Sampling Frequency
    FilterOrder = 2;
    [BFilt,AFilt] = butter(FilterOrder,cutOff/(Fs/2),'low');
    
    T = 0.8; % Stimulus Duration (in seconds)
    
    timeVals = 0:(1/Fs):(T-(1/Fs)); % time vector
 
    numTFs = length(maskTFList);
    estData = zeros(numContrasts,numContrasts,numTFs);
    
    for icT = 1:numContrasts % target contrast
        cT = cList(icT);
        targetWave = sin(2 * pi * TargetFrequency * timeVals);
        
        for iM = 1:numContrasts % mask contrast
            cM = cList(iM);
            
            for iTF=1:numTFs
                
                maskWave = sin(2 * pi * maskTFList(iTF)* timeVals);
                
                Lt = Lamp;
                
                excitatoryDrive = Lt.*cT;
                
                inh1 = (targetWave+scalingFactor.*(maskWave)).^2;
                inh2 = (targetWave.^2) + scalingFactor.*(maskWave.^2);
                
                inh1 = inh1 - mean(inh1);
                inh2 = inh2 - mean(inh2);
                
                LPF_inh1 = filtfilt(BFilt,AFilt,inh1);
                LPF_inh2 = filtfilt(BFilt,AFilt,inh2);
                
                inhibitoryDrive = (alpha1.*(LPF_inh1))+((alpha2).*(LPF_inh2));
                
                mag_inhibitoryDrive = mean(inhibitoryDrive(1:end).^2); %fft_InhibitoryDrive = (abs(fft(inhibitoryDrive)))./(length(inhibitoryDrive));%sum(fft_InhibitoryDrive(1:end).^2);
                
                normalization = (excitatoryDrive./sqrt((sigma).^2+cT.^2+(mag_inhibitoryDrive.*(cM.^2)))).^n;
                
                normalization(isnan(normalization))=0;
                
                estData(icT,iM,iTF) = normalization;
                
            end
        end
    end
end

if ~exist('dataToBeFitted','var')
    d=0;
else
    d = sum((dataToBeFitted(:) - estData(:)).^2);
end
end