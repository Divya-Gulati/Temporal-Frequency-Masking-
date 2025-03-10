function plotFigure2(Figure2Data)
f = figure;
f.Position = [100 0 1300 900];
plotHandles_c= getPlotHandles(15,2,[0.05 0.08 0.25 0.81],0.011,0.005);
plotHandles_a= getPlotHandles(15,2,[0.36 0.08 0.25 0.81],0.011,0.005);
plotHandles_d= getPlotHandles(1,1,[0.70 0.55 0.26 0.38],0.01,0.095);
plotHandles_b= getPlotHandles(1,1,[0.70 0.1 0.26 0.38],0.01,0.095);

colorArray = [0.4 0.4 0.4; 0.7 0.03 0.3; 1 0.54 0.15];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TF = 15;
%%%% plotting fft - FS %%%%
gratingData = squeeze(mean(Figure2Data.fftST_grating_mean_FS(:,TF,:),1))'; % mean across both orientations
gratingDataSem = squeeze(mean(Figure2Data.fftST_grating_sem_FS(:,TF,:),1))';
FreqVals = Figure2Data.freqVals_FS;
Freq = FreqVals == 2*TF;

TFtoCover = 1:2:29;
FreqToPlot = 61;

for idel = 1:size(Figure2Data.fftST_plaid_mean_FS,1)
    for iTF = 1:length(TFtoCover)
        subplot(plotHandles_c(iTF,idel))
        
        plot(FreqVals(1:FreqToPlot),gratingData(1:FreqToPlot),'color',colorArray(1,:),'Linewidth',1.5);
        hold on;
        patch([FreqVals(1:FreqToPlot) fliplr(FreqVals(1:FreqToPlot))],[gratingData(1:FreqToPlot)-gratingDataSem(1:FreqToPlot) fliplr(gratingData(1:FreqToPlot)+gratingDataSem(1:FreqToPlot))],...
            colorArray(1,:),'EdgeColor','none','FaceColor',colorArray(1,:),'LineWidth',1, 'FaceAlpha',0.2);
        
        plaidData = squeeze(Figure2Data.fftST_plaid_mean_FS(idel,TFtoCover(iTF),:))';
        plaidDataSem = squeeze(Figure2Data.fftST_plaid_sem_FS(idel,TFtoCover(iTF),:))';
        deltaChange = plaidData(Freq)-gratingData(Freq);
        deltaChangeMean = mean([plaidData(Freq),gratingData(Freq)]);
        
        hold on;
        plot(FreqVals(1:FreqToPlot),plaidData(1:FreqToPlot),'color',colorArray(idel+1,:),'Linewidth',1.5);
        hold on;
        patch([FreqVals(1:FreqToPlot) fliplr(FreqVals(1:FreqToPlot))],[plaidData(1:FreqToPlot)-plaidDataSem(1:FreqToPlot) fliplr(plaidData(1:FreqToPlot)+plaidDataSem(1:FreqToPlot))],...
            colorArray(idel+1,:),'EdgeColor','none','FaceColor',colorArray(idel+1,:),'LineWidth',1, 'FaceAlpha',0.2);
        xlim([0 60]);ylim([0 25]);
        
        hold on;
        errorbar(2*TF+3,deltaChangeMean,abs(deltaChange/2),'r','LineWidth',1.2,'CapSize',3);
        xline(2*TFtoCover(iTF),'m:');
        xline(2*TF,'k:');
        text(40,20, [num2str(round(deltaChange,2)) '\muV'],'FontSize',8.5,'FontName','courier','Fontweight','bold');
        xticks([0 10 20 30 40 50]);
        yticks([0 10 20 30]);
        
        if iTF~=length(TFtoCover)
            set(gca,'YTickLabel',[]);
            set(gca,'XTickLabel',[]);
        end
        
        if idel == size(Figure2Data.fftST_plaid_mean_FS,1)
            yyaxis right;
            set(gca,'YTickLabel',[])
            ax = gca;
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = 'w';
            ylabel(gca, +TFtoCover(iTF),'Color','k','FontWeight','bold','FontName','courier');
        end
        box 'off';

        if iTF == 1
            if idel == 1
                title ('Parallel','color',colorArray(idel+1,:),'FontSize',13,'FontName','courier','Fontweight','bold');
            else
                title ('Orthogonal','color',colorArray(idel+1,:),'FontSize',13,'FontName','courier','Fontweight','bold');
            end
        end
    end
    if idel == 1
        ylabel('Amplitude (\muV)');
    end
    xlabel('Frequency (Hz)');
end

%%%% plotting fft - SmallStim %%%%
TFtoCoverSmall = 1:2:29;
tVal = TFtoCoverSmall == TF;
gratingParallelData = squeeze((Figure2Data.fftST_plaid_mean_parallel_small(1,4,tVal,:)))'; 
gratingParallelDataSem = squeeze(mean(Figure2Data.fftST_plaid_sem_parallel_small(1,4,tVal,:),1))';

gratingOrthogonallData = squeeze((Figure2Data.fftST_plaid_mean_orthogonal_small(1,4,tVal,:)))'; 
gratingOrthogonalDataSem = squeeze(mean(Figure2Data.fftST_plaid_sem_orthogonal_small(1,4,tVal,:),1))';

FreqValsSmall = Figure2Data.freqVals_Small;
FreqSmall = FreqValsSmall == 2*TF;
FreqToPlotSmall = 31;

for idel = 1:2
    
    if idel == 1
        gratData = gratingParallelData;
        gratSemData =gratingParallelDataSem;
        pData = Figure2Data.fftST_plaid_mean_parallel_small;
        pDataSEM = Figure2Data.fftST_plaid_sem_parallel_small;
    else
        gratData = gratingOrthogonallData;
        gratSemData =gratingOrthogonalDataSem;
        pData = Figure2Data.fftST_plaid_mean_orthogonal_small;
        pDataSEM = Figure2Data.fftST_plaid_sem_orthogonal_small;
    end
    
    
    for iTF = 1:length(TFtoCoverSmall)
        subplot(plotHandles_a(iTF,idel))
        
        plot(FreqValsSmall(1:FreqToPlotSmall),gratData(1:FreqToPlotSmall),'color',colorArray(1,:),'Linewidth',1.5);
        hold on;
        patch([FreqValsSmall(1:FreqToPlotSmall) fliplr(FreqValsSmall(1:FreqToPlotSmall))],[gratData(1:FreqToPlotSmall)-gratSemData(1:FreqToPlotSmall) fliplr(gratData(1:FreqToPlotSmall)+gratSemData(1:FreqToPlotSmall))],...
            colorArray(1,:),'EdgeColor','none','FaceColor',colorArray(1,:),'LineWidth',1, 'FaceAlpha',0.2);
        
        plaidData = squeeze(pData(4,4,(iTF),:))';
        plaidDataSem = squeeze(pDataSEM(4,4,(iTF),:))';
        deltaChange = plaidData(FreqSmall)-gratData(FreqSmall);
        deltaChangeMean = mean([plaidData(FreqSmall),gratData(FreqSmall)]);
        
        hold on;
        plot(FreqValsSmall(1:FreqToPlotSmall),plaidData(1:FreqToPlotSmall),'color',colorArray(idel+1,:),'Linewidth',1.5);
        hold on;
        patch([FreqValsSmall(1:FreqToPlotSmall) fliplr(FreqValsSmall(1:FreqToPlotSmall))],[plaidData(1:FreqToPlotSmall)-plaidDataSem(1:FreqToPlotSmall) fliplr(plaidData(1:FreqToPlotSmall)+plaidDataSem(1:FreqToPlotSmall))],...
            colorArray(idel+1,:),'EdgeColor','none','FaceColor',colorArray(idel+1,:),'LineWidth',1, 'FaceAlpha',0.2);
        xlim([0 60]);ylim([0 8.5]);
        
        hold on;
        errorbar(2*TF+3,deltaChangeMean,abs(deltaChange/2),'r','LineWidth',1.2,'CapSize',3);
        xline(2*TFtoCoverSmall(iTF),'m:');
        xline(2*TF,'k:');
        text(40,7, [num2str(round(deltaChange,2)) '\muV'],'FontSize',8.5,'FontName','courier','Fontweight','bold');
        xticks([0 10 20 30 40 50]);
        yticks([0 4 8]);
        
        if iTF~=length(TFtoCoverSmall)
            set(gca,'YTickLabel',[]);
            set(gca,'XTickLabel',[]);
        end
        
        if idel == size(Figure2Data.fftST_plaid_mean_FS,1)
            yyaxis right;
            set(gca,'YTickLabel',[])
            ax = gca;
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = 'w';
            ylabel(gca, +TFtoCoverSmall(iTF),'Color','k','FontWeight','bold','FontName','courier');
        end
        box 'off';

        if iTF == 1
            if idel == 1
                title ('Parallel','color',colorArray(idel+1,:),'FontSize',13,'FontName','courier','Fontweight','bold');
            else
                title ('Orthogonal','color',colorArray(idel+1,:),'FontSize',13,'FontName','courier','Fontweight','bold');
            end
        end
    end
    if idel == 1
        ylabel('Amplitude (\muV)');
    end
    xlabel('Frequency (Hz)');
end

%%%%% Plotting change in amplitude subtracted from grating condition %%%%%%
subplot(plotHandles_d(1))
dataToPlot_AD_FS = Figure2Data.ChangeInAmpNeg_mean_FS;
semToPlot_AD_FS = Figure2Data.ChangeInAmpNeg_sem_FS;

for isize = 1:size(dataToPlot_AD_FS,1)
    errorbar(1:1:29,dataToPlot_AD_FS(isize,:),...
        semToPlot_AD_FS(isize,:),semToPlot_AD_FS(isize,:),'d-','color',colorArray(isize+1,:)...
        ,'capsize',2,"MarkerFaceColor",colorArray(isize+1,:),'lineWidth',1.5);
    hold on;
end


title ('Full-field Stimuli','color','k','FontSize',12,'FontName','courier','Fontweight','bold');
box 'off';ylim([-12 12]);
text(1,10,[ 'N = ' num2str(Figure2Data.NumElecs_FS)],'FontName','courier','FontSize',11,'FontWeight','bold');
ylabel('Change in Amplitude at 30Hz (\muV)');

subplot(plotHandles_b(1))
dataToPlot_parallel_ampDiff = squeeze(Figure2Data.changeInAmpSubtract_mean_parallel_small(4,4,:));
semToPlot_parallel_ampDiff = squeeze(Figure2Data.changeInAmpSubtract_sem_parallel_small(4,4,:));
dataToPlot_orthogonal_ampDiff = squeeze(Figure2Data.changeInAmpSubtract_mean_orthogonal_small(4,4,:));
semToPlot_orthogonal_ampDiff = squeeze(Figure2Data.changeInAmpSubtract_sem_orthogonal_small(4,4,:));

errorbar(1:2:29,dataToPlot_parallel_ampDiff,semToPlot_parallel_ampDiff,semToPlot_parallel_ampDiff,'d-','color',...
    colorArray(2,:),'capsize',2,"MarkerFaceColor",colorArray(2,:),'lineWidth',1.5);
hold on;
errorbar(1:2:29,dataToPlot_orthogonal_ampDiff,semToPlot_orthogonal_ampDiff,semToPlot_orthogonal_ampDiff,'d-','color',...
    colorArray(3,:),'capsize',2,"MarkerFaceColor",colorArray(3,:),'lineWidth',1.5);
hold on;
title ('Small Stimuli','color','k','FontSize',12,'FontName','courier','Fontweight','bold');
box 'off';

ylim([-4 3.5]);
text(1,2.8,[ 'N = ' num2str(Figure2Data.NumElecs_Small(1))],'FontName','courier','FontSize',11,'color',colorArray(2,:),'FontWeight','bold');
text(1,2.3,[ 'N = ' num2str(Figure2Data.NumElecs_Small(2))],'FontName','courier','FontSize',11,'color',colorArray(3,:),'FontWeight','bold');
xlabel('Temporal Frequency of Mask (Hz)');
ylabel('Change in Amplitude at 30Hz (\muV)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
annotation(gcf,'textarrow',...
    [0.035 0.1] ,[0.93 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.34 0.1] ,[0.93 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.18 0.1] ,[0.932 0.5],...
    'String','Full-field Stimuli', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',15, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.42 0.1] ,[0.932 0.5],...
    'String','Small Stimuli', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',15, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.665 0.1] ,[0.945 0.5],...
    'String','C', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.665 0.1] ,[0.493 0.5],...
    'String','D', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');





end
