function plotFigure_Supplementary_FortyFive_sessionWise(Figure_Data,dataType,GoodFitsData,ModelNames,TargetTF,TFList)
TF = 1:2:29;
ContrastValuesLeft = [0,6.25,12.5,25];
ContrastValuesRight = [0,6.25,12.5,25];
uniquedeltaChange = 45;
labels = {'M2 - Microelectrode','M3 - ECoG'};
if contains(dataType,'ampDiff')
    PlaidAvgECoG = Figure_Data.ampDiff_plaid_ECoG_mean;
    PlaidSemECoG = Figure_Data.ampDiff_plaid_ECoG_sem;
    PlaidAvgM1 = Figure_Data.ampDiff_plaid_mean_M1;
    PlaidSemM1 = Figure_Data.ampDiff_plaid_sem_M1;
elseif contains(dataType,'Subtract')
    PlaidAvgECoG = Figure_Data.changeInAmpSubtract_ECoG_mean;
    PlaidSemECoG = Figure_Data.changeInAmpSubtract_ECoG_sem;
    PlaidAvgM1 = Figure_Data.changeInAmpSubtract_mean_M1;
    PlaidSemM1 = Figure_Data.changeInAmpSubtract_sem_M1;
end

colorArray1 = winter(4);
colorArray2 = [0.85 0.3 0.2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure;
f.WindowState = 'maximized';
plotHandles_a= getPlotHandles(2,4,[0.04 0.08 0.35 0.83],0.007,0.1,0);
plotHandles_b= getPlotHandles(2,4,[0.46 0.545 0.36 0.367],0.007,0.03,0);
plotHandles_c= getPlotHandles(2,1,[0.86 0.545 0.09 0.367],0.007,0.03,0);
plotHandles_d= getPlotHandles(2,4,[0.46 0.08 0.36 0.367],0.007,0.03,0);
plotHandles_e= getPlotHandles(2,1,[0.86 0.08 0.09 0.367],0.007,0.03,0);


for iMonkey = 1:2
    if iMonkey == 2
        ChngeInAmpData = PlaidAvgECoG;
        ChngeInAmpSemData = PlaidSemECoG;
        NumElec = Figure_Data.NumElecs_ECoG;
    elseif iMonkey == 1
        ChngeInAmpData = PlaidAvgM1;
        ChngeInAmpSemData = PlaidSemM1;
        NumElec = Figure_Data.NumElecs_M1;
    end
    
    MaxScale = max(ChngeInAmpData,[],'all');
    
    for ioriDelta = 1:length(uniquedeltaChange)
        
        plotHandles = plotHandles_a;
        colorArray = colorArray1;
        
        for iConLeft = 1:length(ContrastValuesLeft)
            subplot(plotHandles(iMonkey,iConLeft))
            newDefaultColors = colorArray;
            newColors = flipud(newDefaultColors);
            set(gca, 'ColorOrder', newColors, 'NextPlot', 'replacechildren');
            set(gca,'FontSize',12);ylim([0 ceil(MaxScale)+3]);xticks(1:4:29);
            
            for iConRight = 1:length(ContrastValuesRight)
                errorbar(TF,squeeze(ChngeInAmpData(ioriDelta,iConLeft,iConRight,:)),...
                    squeeze(ChngeInAmpSemData(ioriDelta,iConLeft,iConRight,:)),'o-','LineWidth',1.8);
                hold on;
            end
            
            if iConLeft == length(ContrastValuesLeft)
                elecNum = ['N = ' num2str(NumElec(ioriDelta))];
                text(16,ceil(MaxScale) +2,elecNum,'Fontsize',12,'Fontname','Courier','Fontweight','bold');
            end
            
% 
%             if iMonkey ~= 2
%                 set(gca,'XTickLabel',[])
%             end
            
            if  iConLeft ~=1
                set(gca,'YTickLabel',[])
            end
            
            if iMonkey == 2 && iConLeft ==1
                if ioriDelta == 1
                    legend('0','6.25','12.5','25','FontSize',9,'Fontname','Courier','Fontweight','bold');
                end
                xlabel({'Temporal Frequency','of Mask (Hz)'},'FontSize',10);
                ylabel('Change in Amplitude at 30Hz  (\muV)','FontSize',10);
            end
            if iMonkey==1
                title("Target at " + ContrastValuesLeft(iConLeft) + "%",'FontName','courier','Fontweight','bold','Fontsize',11);
            end
            if iConLeft == length(ContrastValuesLeft)
                if iMonkey == 1
                    h = text(32,3,labels{1},'Fontsize',11,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                else
                    h = text(32,7,labels{2},'Fontsize',11,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                end
            end
        end
    end
end

good_freqList = setdiff(TFList,TargetTF);
tf_index = find(TFList == TargetTF);

for iModel = 1:size(GoodFitsData,2)
    for iMonkey= 1:size(GoodFitsData{1, iModel}.goodParameters,1)
        if iMonkey == 1
            plotHandles_SupressionProfile = plotHandles_c;
            plotHandles_FitData = plotHandles_b;
        else
            plotHandles_SupressionProfile= plotHandles_e;
            plotHandles_FitData = plotHandles_d;
        end
        
        subplot(plotHandles_SupressionProfile(iModel,1));
        
        if iModel == 1
            data = squeeze(GoodFitsData{1, iModel}.mean_goodParams(iMonkey,1,end-13:end));
            stdData = squeeze(GoodFitsData{1, iModel}.sem_goodParams(iMonkey,1,end-13:end));
        else
            data = squeeze(GoodFitsData{1, iModel}.mean_SuppressionProfile(iMonkey,1,1:end));
            stdData = squeeze(GoodFitsData{1, iModel}.sem_SuppressionProfile(iMonkey,1,1:end));
        end
        errorbar(good_freqList,data,stdData,'v','color',colorArray2(1,:),'MarkerSize',7,'MarkerFaceColor',colorArray2(1,:));
        xticks(good_freqList);xticklabels(good_freqList);
        hold on; plot(good_freqList(1:tf_index-1),data(1:tf_index-1),':','color',colorArray2(1,:),'linewidth',2);
        hold on; plot(good_freqList(tf_index:end),data(tf_index:end),':','color',colorArray2(1,:),'linewidth',2);
        legend('45');
        if iModel ~= size(GoodFitsData{1, iModel}.goodParameters,1)
            set(gca,'XtickLabel',[]);
        end
        if iModel == size(GoodFitsData{1, iModel}.goodParameters,1)
            xlabel({'Temporal Frequency','of Mask (Hz)'});
            ylabel('Supression Values');
        end
        yyaxis right;%set(gca,'YAxisLocation','right')
        set(gca,'YTickLabel',[])
        ax = gca;
        ax.YAxis(1).Color = 'k';
        ax.YAxis(2).Color = 'w';
        ylabel(gca, ModelNames(iModel) ,'Color','k','FontSize',9,'Fontname','courier','Fontweight','bold');
        box off;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        maxScale = max(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,:,:,:,:)+GoodFitsData{1, iModel}.sem_good_fitted_data(iMonkey,:,:,:,:),[],'all');
        for iConL = 1:size(GoodFitsData{1, iModel}.mean_exp_obt_data,3)
            subplot(plotHandles_FitData(iModel,iConL))
        newDefaultColors = winter(length(ContrastValuesLeft));
            newgColors = flipud(newDefaultColors);
            for iConR = 1:length(ContrastValuesLeft)
                plot(good_freqList,squeeze(GoodFitsData{1, iModel}.mean_exp_obt_data(iMonkey,1,iConL,iConR,:)),'o','color',newgColors(iConR,:),'lineWidth',2,'MarkerSize',4);
                hold on;
            end
            
            for iConR = 1:length(ContrastValuesLeft)
                hold on;
                plot(good_freqList(1:tf_index-1),squeeze(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,1,iConL,iConR,(1:tf_index-1))),':','color',newgColors(iConR,:),'lineWidth',2,'MarkerSize',4);
            end
            
            for iConR = 1:length(ContrastValuesLeft)
                hold on;
                plot(good_freqList(tf_index:end),squeeze(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,1,iConL,iConR,(tf_index:end))),':','color',newgColors(iConR,:),'lineWidth',2,'MarkerSize',4);
            end
            
            for iConR = 1:length(ContrastValuesLeft)
                hold on;
                patch([good_freqList(1:tf_index-1) fliplr(good_freqList(1:tf_index-1))], ...
                    [squeeze(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,1,iConL,iConR,(1:tf_index-1)))'-squeeze(GoodFitsData{1, iModel}.sem_good_fitted_data(iMonkey,1,iConL,iConR,(1:tf_index-1)))'...
                    fliplr(squeeze(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,1,iConL,iConR,(1:tf_index-1)))'+squeeze(GoodFitsData{1, iModel}.sem_good_fitted_data(iMonkey,1,iConL,iConR,(1:tf_index-1)))')],...
                    newgColors(iConR,:),'EdgeColor','none','FaceColor',newgColors(iConR,:),'LineWidth',0.1, 'FaceAlpha',0.2);
                
                hold on;
                
                patch([good_freqList(tf_index:end) fliplr(good_freqList(tf_index:end))], ...
                    [squeeze(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,1,iConL,iConR,(tf_index:end)))'-squeeze(GoodFitsData{1, iModel}.sem_good_fitted_data(iMonkey,1,iConL,iConR,(tf_index:end)))'...
                    fliplr(squeeze(GoodFitsData{1, iModel}.mean_good_fitted_data(iMonkey,1,iConL,iConR,(tf_index:end)))'+squeeze(GoodFitsData{1, iModel}.sem_good_fitted_data(iMonkey,1,iConL,iConR,(tf_index:end)))')],...
                    newgColors(iConR,:),'EdgeColor','none','FaceColor',newgColors(iConR,:),'LineWidth',0.1, 'FaceAlpha',0.2);
            end
            
            ylim([-0.1 maxScale+1])
            xticks([1 5 9 13 17 21 25 29]);
            
            if iModel ~= size(GoodFitsData{1, iModel}.goodParameters,1)
                set(gca,'xticklabels',[]);
            end
            
            if iConL ~= 1
                set(gca,'yticklabels',[]);
            end
            
            if iConL == 1  && iModel == size(GoodFitsData{1, iModel}.goodParameters,1)
                xlabel({'Temporal Frequency','of Mask (Hz)'},'Fontsize',10);
                ylabel({'Change in Amplitude','at 30Hz  (\muV)'},'Fontsize',10);
            end
            
            
            if iModel == 1
                title ("Target at " +ContrastValuesLeft(iConL) + "%",'Fontname','courier','Fontweight','bold','Fontsize',9);
            end
            
            if iModel == size(GoodFitsData{1, iModel}.goodParameters,1)
                if iConL == 1
                    legend('0- Obs','6.25-Obs','12.5- Obs','25- Obs','0- Fit','6.25-Fit','12.5- Fit','25- Fit','Fontsize',7.5,'Location','best','Fontname','courier','Fontweight','bold');
                end
            end
            
            if size(GoodFitsData{1, iModel}.goodElecIds{iMonkey, 1},1)> 1
                if  iConL == 4
                    text(0.5,0.3 ,"GoodFitsElecs = " +num2str(round(100*GoodFitsData{1, iModel}.goodElecPercent{iMonkey,1},1))+"%",'FontSize',8);
                end
            end
            box off;
        end
    end
end


annotation(gcf,'textarrow',...
    [0.015 0.1] ,[0.91 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.425 0.1] ,[0.91 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.425 0.1] ,[0.46 0.5],...
    'String','C', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.21 0.1] ,[0.95 0.5],...
    'String','Delta 45 - Observed Data', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',14, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','FontName','courier');

annotation(gcf,'textarrow',...
    [0.555 0.1] ,[0.965 0.5],...
    'String','Delta 45 - Model Fits', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',14, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','FontName','courier');

annotation(gcf,'textarrow',...
    [0.865 0.1] ,[0.83 0.5],...
    'String','M2-Microelectrode', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',13, 'color','k','FontWeight','bold', 'TextRotation',90,'color','k','FontName','courier');

annotation(gcf,'textarrow',...
    [0.93 0.1] ,[0.33 0.5],...
    'String','M3-ECoG', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',13, 'color','k','FontWeight','bold', 'TextRotation',90,'color','k','FontName','courier');

end