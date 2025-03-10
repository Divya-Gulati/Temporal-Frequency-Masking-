clear;clc;

%close all;

Fs = 2000; % Sampling Frequency
T = 0.8; % Stimulus Duration

timeVals = 0:(1/Fs):(T-(1/Fs)); % time vector
FreqVals = 0:(1/T):((Fs)-1/T); % frequency vector

Z = 1;  %Semi-saturation
TF1 = 15;   %Target Frequency
MF = [1:2:13 17:2:29] ; %Mask Frequency
deltaOri = [0 90];% delta

Amp =1;             % Amplitude of the fundamental

x1 =Amp * sin(2 * pi * TF1 * timeVals); %target
Data.fftX1 = (abs(fft(x1.^2'))./(length(x1)));
fIndex = find(FreqVals == 2*TF1);



for iCO = 1:30
    [B1,A1] = butter(2,iCO/(Fs/2),'low');
    [B2,A2] = butter(2,iCO/(Fs/2),'low');
    for iori = 1:length(deltaOri)
        
        if deltaOri(iori) == 0
            alpha1 = 1;
            alpha2 = 0;
        elseif deltaOri(iori) == 90
            alpha1 = 0;
            alpha2 = 1;
        end
        
        for iMF = 1:length(MF)
            disp(MF(iMF));
            clear  x2
            x2 = (1).*(Amp * sin(2 * pi * MF(iMF) * timeVals));
            
            Data.MaskWave(iCO,iori,iMF,:)=x2;
            
            I1_pre = ((x1 + x2).^2);
            I2_pre= ((x1.^2) + (x2.^2));
            I1 = I1_pre-mean(I1_pre);
            I2 = I2_pre-mean(I2_pre);
            %         I1 = I1_pre;
            %         I2 = I2_pre;
            
            Data.withoutLPF_I(iCO,iori,iMF,:) = (alpha1.*I1)+((alpha2).*I2); % Ist and 2nd
            fft_withoutLPF_I = abs(fft(squeeze(Data.withoutLPF_I(iCO,iori,iMF,:))))./(length(Data.withoutLPF_I(iCO,iori,iMF,:)));
            Data.denom_fft_withoutLPF_I (iCO,iori,iMF,:)= fft_withoutLPF_I;
            Data.magnitude_withoutLPF_I(iCO,iori,iMF,:) = mean(squeeze(Data.withoutLPF_I(iCO,iori,iMF,:).^2));%sum(fft_withoutLPF_I(1:end).^2); 
            
            % normalization model
            normalization_I =Amp./((Z+squeeze(Data.magnitude_withoutLPF_I(iCO,iori,iMF,:)))');
            Data.Response_I (iCO,iori,iMF,:) = normalization_I;
            
            %%%%%%% low pass filtering the signals %%%%%%%
            LPF_I1 = (filtfilt(B1,A1,I1));
            LPF_I2 = (filtfilt(B2,A2,I2));
            
            Data.LPF_I(iCO,iori,iMF,:) = (alpha1.*LPF_I1)+((alpha2).*LPF_I2); % 3rd and 4th
            fftLPF_I = abs(fft(squeeze(Data.LPF_I(iCO,iori,iMF,:))))./(length(Data.LPF_I(iCO,iori,iMF,:)));
            Data.denom_LPF_I (iCO,iori,iMF,:)= fftLPF_I;
            Data.magnitude_LPF_I(iCO,iori,iMF,:) =mean(squeeze(Data.LPF_I(iCO,iori,iMF,:).^2));%sum(fftLPF_I(1:end).^2);%
            
            % normalization model
            normalization_LPF_I = Amp./((Z+squeeze(Data.magnitude_LPF_I(iCO,iori,iMF,:)))');
            Data.Response_LPF_I(iCO,iori,iMF,:) =normalization_LPF_I;
        end
    end
end

localfun = Data.Response_LPF_I;

figure,
for iplot = 1:30
    subplot(5,6,iplot)
%     plot(MF(1:7),squeeze(localfun(iplot,1,1:7)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
%     hold on;
%     plot(MF(8:end),squeeze(localfun(iplot,1,8:end)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
%     
    hold on;
    plot(MF(1:7),squeeze(localfun(iplot,2,1:7)),'v-','color','r','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    hold on;
    plot(MF(8:end),squeeze(localfun(iplot,2,8:end)),'v-','color','r','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    
    
    title("Filter Cutoff (Hz) - " + iplot);
     box off;
     ylim([0 1.2]);
end

%%%%%%%%%%%%%%%%%%%%%%%%

localfun = Data.magnitude_LPF_I;

figure,
for iplot = 1:30
    subplot(5,6,iplot)
    plot(MF(1:7),squeeze(localfun(iplot,1,1:7)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','b','linewidth',2);
    
    hold on;
    plot(MF(1:7),squeeze(localfun(iplot,2,1:7)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','r','linewidth',2);
    
    hold on;
    plot(MF(8:end),squeeze(localfun(iplot,1,8:end)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','b','linewidth',2);
    
    hold on;
    plot(MF(8:end),squeeze(localfun(iplot,2,8:end)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','r','linewidth',2);
    
    title("Filter Cutoff (Hz) - " + iplot);
    
    if iplot == 25
        xlabel('Mask Temporal Frequency');
        ylabel('Magnitude');
        legend ('Summation followed by squaring','Squaring followed by summation');
    end
    box off;
    ylim([0 1.2]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


localfun = Data.magnitude_LPF_I;

figure,
colorsArray = turbo(30);
for iplot = 1:30
    subplot(1,2,1)
    hold on;
    plot(MF(1:7),squeeze(localfun(iplot,1,1:7)),'v-','color',colorsArray(iplot,:),'MarkerSize',7,'linewidth',2);
    
    subplot(1,2,2)
    hold on;
    plot(MF(1:7),squeeze(localfun(iplot,2,1:7)),'v-','color',colorsArray(iplot,:),'MarkerSize',7,'linewidth',2);
end


hold on;
for iplot = 1:30
    subplot(1,2,1)
    hold on;
    plot(MF(8:end),squeeze(localfun(iplot,1,8:end)),'v-','color',colorsArray(iplot,:),'MarkerSize',7,'linewidth',2);
    
    if iplot == 30
        title ('Summation followed by squaring');
        ylim([0 1.2]);
        box off;
        xlabel('Mask Temporal Frequency');
        ylabel('Magnitude');
    end
    
    subplot(1,2,2)
    hold on;
    plot(MF(8:end),squeeze(localfun(iplot,2,8:end)),'v-','color',colorsArray(iplot,:),'MarkerSize',7,'linewidth',2);
    
    if iplot == 30
        box off;
        ylim([0 0.2]);
        title ('Squaring followed by summation');
        xlabel('Mask Temporal Frequency');
        ylabel('Magnitude');
    end
end


legend('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30')