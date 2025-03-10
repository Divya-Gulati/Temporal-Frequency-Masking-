clear;clc;
%close all;

Fs = 1000; % Sampling Frequency
T = 1; % Stimulus Duration

timeVals = 0:(1/Fs):(T-(1/Fs)); % time vector
FreqVals = 0:(1/T):((Fs)-1/T); % frequency vector

Z = 1;  %Semi-saturation
TF1 = 15;   %Target Frequency
MF = [1:2:13 17:2:29] ; %Mask Frequency
deltaOri = [0 90];% delta

Amp =1;             % Amplitude of the fundamental

x1 =Amp * sin(2 * pi * TF1 * timeVals); %target

CutOff = 6.5;
[B1,A1] = butter(2,CutOff/(Fs/2),'low');
nall = [1:4];

ori = 1; % sum and square ; 2- square and sum

for n_exp = 1:4
    exponent = nall(n_exp);
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
            x2 =Amp * sin(2 * pi * MF(iMF) * timeVals);
            
            Data.MaskWave(n_exp,iori,iMF,:)=x2;
            
            I1_pre = ((x1 + x2).^exponent);
            I2_pre= ((x1.^exponent) + (x2.^exponent));
            I1 = I1_pre-mean(I1_pre);
            I2 = I2_pre-mean(I2_pre);
%             I1 = I1_pre;
%             I2 = I2_pre;
            
            %%%%%%% low pass filtering the signals %%%%%%%
            LPF_I1 = (filtfilt(B1,A1,I1));
            LPF_I2 = (filtfilt(B1,A1,I2));
            
            Data.LPF_I(n_exp,iori,iMF,:) = (alpha1.*LPF_I1)+((alpha2).*LPF_I2); % 3rd and 4th
            fftLPF_I = abs(fft(squeeze(Data.LPF_I(n_exp,iori,iMF,:))))./(length(Data.LPF_I(n_exp,iori,iMF,:)));
            if deltaOri(iori) == 0
                Data.Unfiltered_LPF_I(n_exp,iori,iMF,:)=  abs(fft(I1));
            elseif deltaOri(iori) == 90
                Data.Unfiltered_LPF_I(n_exp,iori,iMF,:)=  abs(fft(I2));
            end
            Data.magnitude_LPF_I(n_exp,iori,iMF,:) = mean(squeeze(Data.LPF_I(n_exp,iori,iMF,:)).^2);%sum(fftLPF_I(1:end).^2);
            
            % normalization model
            normalization_LPF_I = Amp./((Z+squeeze(Data.magnitude_LPF_I(n_exp,iori,iMF,:)))');
            Data.Response_LPF_I(n_exp,iori,iMF,:) =normalization_LPF_I;
        end
    end
end

f = figure;
f.WindowState = 'maximized';
%set(f,'units','normalized','position',[0.1 0 0.78 1])

%f.WindowState = 'maximized';
MFChoice1 = 6;
MFChoice2 = 9;
colorArray =[[111 116 237]./255;[130 0 28]./255];%[[35 85 240]./255;[240 147 34]./255];

plotHandles_a= getPlotHandles(3,1,[0.05 0.74 0.10 0.18],0.01,0.012,0);
plotHandles_b= getPlotHandles(3,1,[0.05 0.515 0.10 0.18],0.01,0.012,0);
plotHandles_c= getPlotHandles(3,1,[0.05 0.29 0.10 0.18],0.01,0.012,0);
plotHandles_d= getPlotHandles(3,1,[0.05 0.06 0.10 0.18],0.01,0.012,0);

plotHandles_e= getPlotHandles(3,1,[0.20 0.741 0.13 0.18],0.01,0.012,0);
plotHandles_f= getPlotHandles(3,1,[0.20 0.516 0.13 0.18],0.01,0.012,0);
plotHandles_g= getPlotHandles(3,1,[0.20 0.30 0.13 0.18],0.01,0.012,0);
plotHandles_h= getPlotHandles(3,1,[0.20 0.07 0.13 0.18],0.01,0.012,0);

plotHandles_i= getPlotHandles(1,1,[0.39 0.74 0.20 0.18],0.01,0.02,0);
plotHandles_j= getPlotHandles(1,1,[0.39 0.515 0.20 0.18],0.01,0.02,0);
plotHandles_k= getPlotHandles(1,1,[0.39 0.29 0.20 0.18],0.01,0.02,0);
plotHandles_l= getPlotHandles(1,1,[0.39 0.06 0.20 0.18],0.01,0.02,0);

plotHandles_m= getPlotHandles(1,1,[0.64 0.74 0.14 0.18],0.01,0.02,0);
plotHandles_n= getPlotHandles(1,1,[0.64 0.515 0.14 0.18],0.01,0.02,0);
plotHandles_o= getPlotHandles(1,1,[0.64 0.29 0.14 0.18],0.01,0.02,0);
plotHandles_p= getPlotHandles(1,1,[0.64 0.06 0.14 0.18],0.01,0.02,0);

plotHandles_q= getPlotHandles(1,1,[0.835 0.74 0.14 0.18],0.01,0.02,0);
plotHandles_r= getPlotHandles(1,1,[0.835 0.515 0.14 0.18],0.01,0.02,0);
plotHandles_s= getPlotHandles(1,1,[0.835 0.29 0.14 0.18],0.01,0.02,0);
plotHandles_t= getPlotHandles(1,1,[0.835 0.06 0.14 0.18],0.01,0.02,0);

%%
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
    plot(timeVals,x1,'color',[0.35 0.35 0.35],'linewidth',2);%[247 121 151]./255%[0.99 0.47 0.71]
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{T}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
    if i == 1
        title ('Input Signal','Fontname','courier','Fontweight','bold','Fontsize',13,'color','k');
    end
    
    subplot(plotHandles(2))
    plot(timeVals,squeeze(Data.MaskWave(1,1,MFChoice1,:)),'linewidth',2,'color',colorArray(1,:));
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{M1}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
    
    subplot(plotHandles(3))
    plot(timeVals,squeeze(Data.MaskWave(1,1,MFChoice2,:)),'linewidth',2,'color',colorArray(2,:));
    box off;
    h = gca;
    set(h,'xcolor','none');set(h,'ycolor','none');set(h,'color','none');
    h.XAxis.Label.Color=[0 0 0]; h.XAxis.Label.Visible='Off';
    h.YAxis.Label.Color=[0 0 0]; h.YAxis.Label.Visible='On';
    ylabel('\omega_{M2}','Fontname','courier','Fontweight','bold','Fontsize',15,'color','k');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
annotation('textbox',[0.20,0.855 0.18 0.1],'string','Normalization Term','FontSize',13,'edgecolor','none','Fontweight','bold','Fontname','courier','color','k');
eq1 =  '\boldmath$LPF((\sin\omega_{T} t+\sin\omega_{M} t)^1)$';
eq2 =  '\boldmath$LPF((\sin\omega_{T} t+\sin\omega_{M} t)^2)$';
eq3 = '\boldmath$LPF((\sin\omega_{T} t+\sin\omega_{M} t)^3)$';
eq4 =  '\boldmath$LPF((\sin\omega_{T} t+\sin\omega_{M} t)^4)$';

clearvars plotHandles
plotData =Data.LPF_I;
for ip = 1:4
    if ip == 1
        plotHandles = plotHandles_e;
        eq =eq1;
        Equationlocation= [0.19 0.82 0.15 0.1];
    elseif ip == 2
        plotHandles = plotHandles_f;
        eq =eq2;
        Equationlocation= [0.19 0.595 0.15 0.1];
    elseif ip == 3
        plotHandles = plotHandles_g;
        eq =eq3;
        Equationlocation= [0.19 0.37 0.15 0.1];
    elseif ip == 4
        plotHandles = plotHandles_h;
        eq =eq4;
        Equationlocation=[0.19 0.145 0.15 0.1];
    end
    
    subplot(plotHandles(1))
    axis off; box off;
    annotation('textbox',Equationlocation,'string',eq,'FontSize',13,'edgecolor','none','Interpreter','latex','Fontweight','bold');
    
    subplot(plotHandles(2))
    plot(timeVals,squeeze(plotData(ip,ori,MFChoice1,:)),'linewidth',2,'color',colorArray(1,:));
    ylim([-4 4]);
    axis off;
    set(gca, 'color', 'none');box off;
    
    subplot(plotHandles(3))
    plot(timeVals,squeeze(plotData(ip,ori,MFChoice2,:)),'linewidth',2,'color',colorArray(2,:));
    ylim([-4 4]);
    axis off;
    set(gca, 'color', 'none');box off;
 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars plotHandles
selectedFFT = Data.Unfiltered_LPF_I;
for iplot = 1:4
    if iplot == 1
        plotHandles = plotHandles_i;
    elseif iplot == 2
        plotHandles = plotHandles_j;
    elseif iplot == 3
        plotHandles = plotHandles_k;
    elseif iplot == 4
        plotHandles = plotHandles_l;
    end
    clearvars data
    subplot(plotHandles(1))
    data = squeeze(selectedFFT(iplot,ori,MFChoice1,:));
    data2 = squeeze(selectedFFT(iplot,ori,MFChoice2,:));
    
    stem(FreqVals,data,'color',colorArray(1,:),'lineWidth',2);
    hold on;
    stem(FreqVals,data2,'color',colorArray(2,:),'lineWidth',2,'lineStyle','--');
    xlim([0 80]);
    box off;
    set(gca, 'color', 'none');
    ylim([0 1500]);
%     ax = gca;
%     ax.YRuler.Visible = 'off';
    if iplot == 1
        title ('FFT of the Inhibitory Drive','Fontname','courier','Fontweight','bold','Fontsize',12,'color','k');
    end
    
end
xlabel('Frequency (Hz)');
ylabel('Amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars plotHandles
localfun = Data.magnitude_LPF_I;
for ipl = 1:4  
    if ipl == 1
        plotHandles = plotHandles_m;
    elseif ipl == 2
        plotHandles = plotHandles_n;
    elseif ipl == 3
        plotHandles = plotHandles_o;
    elseif ipl == 4
        plotHandles = plotHandles_p;
    end
    
    subplot(plotHandles(1))
    
    plot(MF(1:7),squeeze(localfun(ipl,ori,1:7)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    hold on;
    plot(MF(8:end),squeeze(localfun(ipl,ori,8:end)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    
    
    hold on;
    plot(MF(MFChoice1),squeeze(localfun(ipl,ori,MFChoice1)),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(1,:),'markeredgecolor',colorArray(1,:));
    hold on;
    plot(MF(MFChoice2),squeeze(localfun(ipl,ori,MFChoice2)),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(2,:),'markeredgecolor',colorArray(2,:));
    
    set(gca, 'color', 'none');box off;
    ylim([0 5]);
    xticks(1:2:29);
    %set(gca,'Ytick',[]);
    %ax = gca;
    %ax.YRuler.Visible = 'off';
    
    if ipl == 1
        title ('Suppression Profile','Fontname','courier','Fontweight','bold','Fontsize',13,'color','k');
    end
    
end
xlabel('Temporal Frequency of Mask (Hz)');
ylabel('Magnitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars plotHandles
localfun = Data.Response_LPF_I;
for ipl = 1:4
    if ipl == 1
        plotHandles = plotHandles_q;
    elseif ipl == 2
        plotHandles = plotHandles_r;
    elseif ipl == 3
        plotHandles = plotHandles_s;
    elseif ipl == 4
        plotHandles = plotHandles_t;
    end
    
    subplot(plotHandles(1))
    
    plot(MF(1:7),squeeze(localfun(ipl,ori,1:7)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    hold on;
    plot(MF(8:end),squeeze(localfun(ipl,ori,8:end)),'v-','color','k','MarkerSize',7,'MarkerFaceColor','k','linewidth',2);
    
    
    hold on;
    plot(MF(MFChoice1),squeeze(localfun(ipl,ori,MFChoice1)),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(1,:),'markeredgecolor',colorArray(1,:));
    hold on;
    plot(MF(MFChoice2),squeeze(localfun(ipl,ori,MFChoice2)),'v-','MarkerSize',8,'MarkerFaceColor',colorArray(2,:),'markeredgecolor',colorArray(2,:));
  
    set(gca, 'color', 'none');box off;
    ylim([0 1]);
    xticks(1:2:29);
    %     set(gca,'Ytick',[]);
    %     ax = gca;
    %     ax.YRuler.Visible = 'off';
    
    if ipl == 1
        title ('Response Profile','Fontname','courier','Fontweight','bold','Fontsize',13,'color','k');
    end
    
end
xlabel('Temporal Frequency of Mask (Hz)');
ylabel('Magnitude');

annotation(gcf,'textarrow',...
    [0.0085 0.1] ,[0.885 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.015 0.1] ,[0.655 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.015 0.1] ,[0.45 0.5],...
    'String','C', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.015 0.1] ,[0.235 0.5],...
    'String','D', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');