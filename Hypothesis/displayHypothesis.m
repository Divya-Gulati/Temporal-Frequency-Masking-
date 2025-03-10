%%%%% Display Hypothesis %%%

clear;clc;close all;

load('HypothesisData.mat');

hFig1 = figure;
set(hFig1,'units','normalized','position',[0.05 0.05 0.7 0.7])

hPlot_model = getPlotHandles(1,1,[0.05 0.5 0.38 0.45],0.05,0.05,1);

hPlot = getPlotHandles(1,1,[0.07 0.1 0.36 0.2],0.05,0.05,1);

hPlot1 = getPlotHandles(2,2,[0.50 0.1 0.45 0.80],0.03,0.065,0);

Cp = [0 0 1];

A = Hypothesis_data{1};

% FIGURE IA : Equation
subplot(hPlot_model(1,1))

model = imread('Figure1 - model.png');
imshow(model);
axis off; box off;
annotation('textbox',[0.04 0.89 0.02 0.05],'String','A','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')

eq = '{\boldmath$R_{(f_{Target})} = [\frac{L_{amp}  c_{Target}}{\sqrt{{\sigma}^2 + c_{Target}^2+S(\delta \theta,\delta f)c_{Mask}^2}}]^n$}';
annotation('textbox',[0.07 0.43 0.3 0.05],'string',eq,'FontSize',17,'edgecolor','none','Interpreter','latex');


%FIGURE 1B: Temporal frequency tuning curve
p = polyfit(1:2:29,A,4);
fit = polyval(p,1:2:29);

subplot(hPlot(1,1))
plot(1:2:29,fit,'--','Color','k','LineWidth',3)
hold on;
plot(15,fit(8),'o','MarkerSize',7,'MarkerFaceColor',Cp,'MarkerEdgeColor',Cp);
hold on;
plot(15,fit(8),'o','MarkerSize',12,'MarkerEdgeColor',Cp)
box off;
yticklabels({});
xlabel('Grating Temporal Frequency (Hz)','FontSize',11)
ylabel({'2F amplitude' 'response (\muV)'},'FontSize',11)
annotation('textbox',[0.04 0.30 0.05 0.05],'String','B','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')

%FIGURE 1C: Non-Specific (Hypothesis 1)
subplot(hPlot1(1,1))
plot([1 13],[A(8) A(8)],':','Color',Cp,'LineWidth',3)
hold on;
plot([17 29],[A(8) A(8)],':','Color',Cp,'LineWidth',3)
hold on;
plot([1 29],[A(4)+10 A(4)+10],'-','Color',[0.7 0.03 0.3],'LineWidth',3)
box off;
yticks([])
xticklabels({});
ylabel('Amplitude response (\muV)','FontSize', 11)
title('Non-specific','FontSize',12,'Fontname','courier','Fontweight','bold')
ylim([5 30]);
annotation('textbox',[0.47 0.89 0.02 0.05],'String','C','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')


%FIGURE 1D: SSVEP-specific (Hypothesis 2)
subplot(hPlot1(1,2))
p = polyfit([1:2:13 17:2:29],(-1.35*A([1:7 9:15])),4);
fitp = polyval(p,[1:2:13 17:2:29]);
plot(1:2:13,fitp(1:7),':','color',Cp,'LineWidth',3)
hold on;
plot(17:2:29,fitp(8:14),':','color',Cp,'LineWidth',3)

p = polyfit(1:2:29,A,4);
fit = polyval(p,1:2:29);
plot(1:2:29,fit,'-','Color',[0.7 0.03 0.3],'LineWidth',3)
box off;
yticks([])
title('SSVEP gain-specific','FontSize',12,'Fontname','courier','Fontweight','bold')
ylim([-24 20]);xticklabels({});
annotation('textbox',[0.715 0.89 0.02 0.05],'String','D','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')


%FIGURE 1E: Low-frequency(Hypothesis 3)
subplot(hPlot1(2,1))
f = 1:2:29;
tau = 0.03;
LPF = (6*(1./sqrt((2*pi*f*tau).^2 + 1)))+5;
plot(1:2:29,LPF,'-','Color',[0.7 0.03 0.3],'LineWidth',3); hold on;


LowFreqData= Hypothesis_data{2};
p = polyfit([1:6 8:29],0.35*(LowFreqData([1:6 8:29])),3);
fitp = polyval(p,1:29);
plot(1:14,fitp(1:14),':','color',Cp,'LineWidth',3)
hold on;
plot(16:29,fitp(16:29),':','color',Cp,'LineWidth',3)
box off;
yticks([])
ylabel('Amplitude response (\muV)','FontSize', 11)
xlabel('Temporal Frequency of Mask (Hz)','FontSize', 11)
title('Low-frequency','FontSize',12,'Fontname','courier','Fontweight','bold')
ylim([0 12])
annotation('textbox',[0.47 0.47 0.02 0.05],'String','E','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')

%FIGURE 1F: Target frequency specific (Hypothesis 4)
subplot(hPlot1(2,2))
TargetFreqData= Hypothesis_data{3};
p = polyfit([1:14 16:29],0.25*((TargetFreqData([1:14 16:29]))),3);
fitp = polyval(p,1:1:29);
plot(1:29,((1./fitp)*3)+6.5,'-','Color',[0.7 0.03 0.3],'LineWidth',3);hold on;
plot(1:14,fitp(1:14),':','color',Cp,'LineWidth',3)
hold on;
plot(16:29,fitp(16:29),':','color',Cp,'LineWidth',3)
hold on;
box off;
yticks([])
xlabel('Temporal Frequency of Mask (Hz)','FontSize', 11)
title('Target frequency','FontSize',12,'Fontname','courier','Fontweight','bold')
ylim([0.5 10]);
annotation('textbox',[0.715 0.47 0.02 0.05],'String','F','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')

% saveFolder = 'D:\OneDrive - Indian Institute of Science\divya\MonkeyDataAnalysis\Figures_Final';
% print(gcf,[saveFolder '\Figure1'],'-dtiff','-r600');
% savefig([saveFolder '\Figure1_Hypothesis']);