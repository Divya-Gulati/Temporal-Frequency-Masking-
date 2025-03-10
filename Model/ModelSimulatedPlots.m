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

[B1,A1] = butter(2,7/(Fs/2),'low');
[B2,A2] = butter(2,23/(Fs/2),'low');

for iori = 1:length(deltaOri) 
    
    if deltaOri(iori) == 0
        alpha1 = 1; %weights
        alpha2 = 0;
    elseif deltaOri(iori) == 90
        alpha1 = 0;
        alpha2 = 1;
    end
    
    for iMF = 1:length(MF)
        disp(MF(iMF));
        clear  x2
        x2 = (1).*(Amp * sin(2 * pi * MF(iMF) * timeVals));
        
        Data.MaskWave(iori,iMF,:)=x2;
        
        I1_pre = ((x1 + x2).^2);
        I2_pre= ((x1.^2) + (x2.^2));
        I1 = I1_pre-mean(I1_pre);
        I2 = I2_pre-mean(I2_pre);
        
        Data.withoutLPF_I(iori,iMF,:) = (alpha1.*I1)+((alpha2).*I2); % Ist and 2nd
        fft_withoutLPF_I = abs(fft(squeeze(Data.withoutLPF_I(iori,iMF,:))))./(length(Data.withoutLPF_I(iori,iMF,:)));
        Data.denom_fft_withoutLPF_I (iori,iMF,:)= fft_withoutLPF_I;
        Data.magnitude_withoutLPF_I(iori,iMF,:) = mean(squeeze(Data.withoutLPF_I(iori,iMF,:).^2));%sum(fft_withoutLPF_I(1:end).^2); %
        
        % normalization model
        normalization_I =Amp./((Z+squeeze(Data.magnitude_withoutLPF_I(iori,iMF,:)))');
        Data.Response_I (iori,iMF,:) = normalization_I;
        
        %%%%%%% low pass filtering the signals %%%%%%%
        LPF_I1 = (filtfilt(B1,A1,I1));
        LPF_I2 = (filtfilt(B2,A2,I2));
        
        Data.LPF_I(iori,iMF,:) = (alpha1.*LPF_I1)+((alpha2).*LPF_I2); % 3rd and 4th
        fftLPF_I = abs(fft(squeeze(Data.LPF_I(iori,iMF,:))))./(length(Data.LPF_I(iori,iMF,:)));
        Data.denom_LPF_I (iori,iMF,:)= fftLPF_I;
        Data.magnitude_LPF_I(iori,iMF,:) = mean(squeeze(Data.LPF_I(iori,iMF,:).^2));%sum(fftLPF_I(1:end).^2);%
        
        % normalization model
        normalization_LPF_I = Amp./((Z+squeeze(Data.magnitude_LPF_I(iori,iMF,:)))');
        Data.Response_LPF_I(iori,iMF,:) =normalization_LPF_I;
    end
end

f = figure;
set(f,'units','normalized','position',[0.1 0 0.78 1])

%f.WindowState = 'maximized';
MFChoice1 = 1;
MFChoice2 = 7;
MFChoice3 = 13;
colorArray = [[197 121 247]./255;[121 138 247]./255;[121 228 247]./255];% [0.3855 0.5 0.96;0 0.5 0.96;0.06 0.9 0.96;];%

plotHandles_a= getPlotHandles(4,1,[0.1 0.74 0.14 0.18],0.01,0.012,0);
plotHandles_b= getPlotHandles(4,1,[0.1 0.515 0.14 0.18],0.01,0.012,0);
plotHandles_c= getPlotHandles(4,1,[0.1 0.29 0.14 0.18],0.01,0.012,0);
plotHandles_d= getPlotHandles(4,1,[0.1 0.06 0.14 0.18],0.01,0.012,0);

plotHandles_e= getPlotHandles(4,1,[0.30 0.741 0.14 0.18],0.01,0.012,0);
plotHandles_f= getPlotHandles(4,1,[0.30 0.516 0.14 0.18],0.01,0.012,0);
plotHandles_g= getPlotHandles(4,1,[0.30 0.30 0.14 0.18],0.01,0.012,0);
plotHandles_h= getPlotHandles(4,1,[0.30 0.07 0.14 0.18],0.01,0.012,0);

plotHandles_i= getPlotHandles(1,1,[0.525 0.74 0.20 0.18],0.01,0.02,0);
plotHandles_j= getPlotHandles(1,1,[0.525 0.515 0.20 0.18],0.01,0.02,0);
plotHandles_k= getPlotHandles(1,1,[0.525 0.29 0.20 0.18],0.01,0.02,0);
plotHandles_l= getPlotHandles(1,1,[0.525 0.06 0.20 0.18],0.01,0.02,0);

plotHandles_m= getPlotHandles(1,1,[0.769 0.74 0.20 0.18],0.01,0.02,0);
plotHandles_n= getPlotHandles(1,1,[0.769 0.515 0.20 0.18],0.01,0.02,0);
plotHandles_o= getPlotHandles(1,1,[0.769 0.29 0.20 0.18],0.01,0.02,0);
plotHandles_p= getPlotHandles(1,1,[0.769 0.06 0.20 0.18],0.01,0.02,0);


for i = 1:4
    if i == 1
        plotHandles = plotHandles_a;
    elseif i == 2
        plotHandles = plotHandles_b;
    elseif i == 3
        plotHandles = plotHandles_c;
    elseif i == 4
        plotHandles = plotHandles_d;
    end
    
    subplot(plotHandles(1))
    plot(timeVals,x1,'color',[247 121 151]./255,'linewidth',2);%[247 121 151]./255%[0.99 0.47 0.71]
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{T}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
    if i == 1
        title ('Input Signal','Fontname','courier','Fontweight','bold','Fontsize',13,'color','b');
    end
    
    subplot(plotHandles(2))
    plot(timeVals,squeeze(Data.MaskWave(1,MFChoice1,:)),'linewidth',2,'color',colorArray(1,:));
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{M1}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
    
    subplot(plotHandles(3))
    plot(timeVals,squeeze(Data.MaskWave(1,MFChoice2,:)),'linewidth',2,'color',colorArray(2,:));
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{M2}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
    
    subplot(plotHandles(4))
    plot(timeVals,squeeze(Data.MaskWave(1,MFChoice3,:)),'linewidth',2,'color',colorArray(3,:));
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{M3}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

annotation('textbox',[0.29,0.855 0.18 0.1],'string','Normalization Term','FontSize',13,'edgecolor','none','Fontweight','bold','Fontname','courier','color','b');
eq1 = '\boldmath$(\sin\omega_{T} t+\sin\omega_{M} t)^2$';
eq2 = '\boldmath$(\sin\omega_{T} t)^2+(\sin\omega_{M} t)^2$';
eq3 = '\boldmath$LPF((\sin\omega_{T} t+\sin\omega_{M} t)^2)$';
eq4 = '\boldmath$LPF((\sin\omega_{T} t)^2+(\sin\omega_{M} t)^2)$';

clearvars plotHandles
for ip = 1:4
    
    if ip == 1
        plotHandles = plotHandles_e;
        eq =eq1;
        plotData = Data.withoutLPF_I;
        ori = 1;
        Equationlocation= [0.298 0.82 0.15 0.1];
    elseif ip == 2
        plotHandles = plotHandles_f;
        eq =eq2;
        plotData = Data.withoutLPF_I;
        ori = 2;
        Equationlocation= [0.292 0.595 0.15 0.1];
    elseif ip == 3
        plotHandles = plotHandles_g;
        eq =eq3;
        plotData =Data.LPF_I;
        ori = 1;
        Equationlocation= [0.28 0.37 0.15 0.1];
    elseif ip == 4
        plotHandles = plotHandles_h;
        eq =eq4;
        plotData =Data.LPF_I;
        ori = 2;
        Equationlocation=[0.277 0.145 0.15 0.1];
    end
    
    subplot(plotHandles(1))
    axis off; box off;
    annotation('textbox',Equationlocation,'string',eq,'FontSize',13,'edgecolor','none','Interpreter','latex','Fontweight','bold');
    
    subplot(plotHandles(2))
    plot(timeVals,squeeze(plotData(ori,MFChoice1,:)),'linewidth',2,'color',colorArray(1,:));
     ylim([-2 4]);
      axis off;
     set(gca, 'color', 'none');box off;
    
    subplot(plotHandles(3))
    plot(timeVals,squeeze(plotData(ori,MFChoice2,:)),'linewidth',2,'color',colorArray(2,:));
     ylim([-2 4]);
     axis off;
     set(gca, 'color', 'none');box off;
     
    subplot(plotHandles(4))
    plot(timeVals,squeeze(plotData(ori,MFChoice3,:)),'linewidth',2,'color',colorArray(3,:));
     ylim([-2 4]);
      axis off;
     set(gca, 'color', 'none');box off;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars plotHandles
for ipl = 1:4
    
    if ipl == 1
        plotHandles = plotHandles_i;
        localfun = Data.magnitude_withoutLPF_I ;
        ori = 1;
    elseif ipl == 2
        plotHandles = plotHandles_j;
        localfun = Data.magnitude_withoutLPF_I ;
        ori = 2;
    elseif ipl == 3
        plotHandles = plotHandles_k;
        localfun = Data.magnitude_LPF_I;
        ori = 1;
    elseif ipl == 4
        plotHandles = plotHandles_l;
        localfun = Data.magnitude_LPF_I;
        ori = 2;
    end
    
    subplot(plotHandles(1))
    
    plot(MF(1:7),localfun(ori,1:7),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    hold on;
    plot(MF(8:end),localfun(ori,8:end),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    
    
    hold on;
    plot(MF(MFChoice1),localfun(ori,MFChoice1),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(1,:),'markeredgecolor',colorArray(1,:));
    hold on;
    plot(MF(MFChoice2),localfun(ori,MFChoice2),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(2,:),'markeredgecolor',colorArray(2,:));
    hold on;
    plot(MF(MFChoice3),localfun(ori,MFChoice3),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(3,:),'markeredgecolor',colorArray(3,:));
    
    
    set(gca, 'color', 'none');box off;
    ylim([0 1.5]);
    xticks(1:2:29);
    %set(gca,'Ytick',[]);
    %ax = gca;
    %ax.YRuler.Visible = 'off';
    
    if ipl == 1
        title ('Suppression Profile','Fontname','courier','Fontweight','bold','Fontsize',13,'color','b');
    end
    
end
xlabel('Temporal Frequency of Mask (Hz)');
ylabel('Magnitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars plotHandles
for ipl = 1:4
    
    if ipl == 1
        plotHandles = plotHandles_m;
        localfun = Data.Response_I ;
        ori = 1;
    elseif ipl == 2
        plotHandles = plotHandles_n;
        localfun = Data.Response_I ;
        ori = 2;
    elseif ipl == 3
        plotHandles = plotHandles_o;
        localfun = Data.Response_LPF_I;
        ori = 1;
    elseif ipl == 4
        plotHandles = plotHandles_p;
        localfun = Data.Response_LPF_I;
        ori = 2;
    end
    
    subplot(plotHandles(1))
    
    plot(MF(1:7),localfun(ori,1:7),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    hold on;
    plot(MF(8:end),localfun(ori,8:end),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    
    
    hold on;
    plot(MF(MFChoice1),localfun(ori,MFChoice1),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(1,:),'markeredgecolor',colorArray(1,:));
    hold on;
    plot(MF(MFChoice2),localfun(ori,MFChoice2),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(2,:),'markeredgecolor',colorArray(2,:));
    hold on;
    plot(MF(MFChoice3),localfun(ori,MFChoice3),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(3,:),'markeredgecolor',colorArray(3,:));
    
    
    set(gca, 'color', 'none');box off;
    ylim([0 1]);
    xticks(1:2:29);
%     set(gca,'Ytick',[]);
%     ax = gca;
%     ax.YRuler.Visible = 'off';
    
    if ipl == 1
        title ('Response Profile','Fontname','courier','Fontweight','bold','Fontsize',13,'color','b');
    end
    
end
xlabel('Temporal Frequency of Mask (Hz)');
ylabel('Magnitude');

annotation(gcf,'textarrow',...
    [0.05 0.1] ,[0.885 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.05 0.1] ,[0.655 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.059 0.1] ,[0.4641 0.5],...
    'String','C', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.05 0.1] ,[0.234 0.5],...
    'String','D', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');