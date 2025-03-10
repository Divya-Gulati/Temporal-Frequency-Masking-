function PlotModelFitsAllMonkeys(PlotData,TargetTF,TFList,ConList,DeltaList,modelNum)

colorArray = [0.7 0.03 0.3; 1 0.54 0.15];
labels = {'M1 - Microelectrode','M2 - Microelectrode','M3 - ECoG'};

f = figure;
f.WindowState = 'maximized';
plotHandles_a= getPlotHandles(3,4,[0.04 0.08 0.28 0.80],0.001,0.03,0);
plotHandles_b= getPlotHandles(3,1,[0.345 0.08 0.12 0.80],0.001,0.03,0);

plotHandles_c= getPlotHandles(3,4,[0.53 0.08 0.28 0.80],0.001,0.03,0);
plotHandles_d= getPlotHandles(3,1,[0.835 0.08 0.12 0.80],0.001,0.03,0);

good_freqList = setdiff(TFList,TargetTF);
tf_index = find(TFList == TargetTF);

for iMonkey = 1:size(PlotData.goodParameters,1)
    for idel=1:size(PlotData.goodParameters,2)
        if idel == 1
            plotHandles = plotHandles_b;
        else
            plotHandles= plotHandles_d;
        end
        subplot(plotHandles(iMonkey,1))
        
        if modelNum == 1
            data = squeeze(PlotData.mean_goodParams(iMonkey,idel,end-13:end));
            stdData = squeeze(PlotData.sem_goodParams(iMonkey,idel,end-13:end));
        else
            data = squeeze(PlotData.mean_SuppressionProfile(iMonkey,idel,1:end));
            stdData = squeeze(PlotData.sem_SuppressionProfile(iMonkey,idel,1:end));
        end
        errorbar(good_freqList,data,stdData,'v','color',colorArray(idel,:),'MarkerSize',7,'MarkerFaceColor',colorArray(idel,:));
        xticks(good_freqList);xticklabels(good_freqList);
        hold on; plot(good_freqList(1:tf_index-1),data(1:tf_index-1),':','color',colorArray(idel,:),'linewidth',2);
        hold on; plot(good_freqList(tf_index:end),data(tf_index:end),':','color',colorArray(idel,:),'linewidth',2);
        legend(num2str(DeltaList(idel)));
        if iMonkey ~= size(PlotData.goodParameters,1)
            set(gca,'XtickLabel',[]);
        end
        
        if iMonkey == size(PlotData.goodParameters,1)
            xlabel({'Temporal Frequency','of Mask (Hz)'});
            ylabel('Supression Values');
        end
        
        yyaxis right;%set(gca,'YAxisLocation','right')
        set(gca,'YTickLabel',[])
        ax = gca;
        ax.YAxis(1).Color = 'k';
        ax.YAxis(2).Color = 'w';
        ylabel(gca, labels(iMonkey) ,'Color','k','FontSize',11,'Fontname','courier','Fontweight','bold');
        box off;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    maxScale = max(PlotData.mean_good_fitted_data(iMonkey,:,:,:,:)+PlotData.sem_good_fitted_data(iMonkey,:,:,:,:),[],'all');
    %minScale = min(PlotData.mean_good_fitted_data(iMonkey,:,:,:,:)+PlotData.sem_good_fitted_data(iMonkey,:,:,:,:),[],'all');
    for iori = 1: size(PlotData.mean_exp_obt_data,2)
        if iori == 1
            plotHandles=plotHandles_a;
        else
            plotHandles=plotHandles_c;
        end
        for iConL = 1:size(PlotData.mean_exp_obt_data,3)
            subplot(plotHandles(iMonkey,iConL))
            newDefaultColors = winter(length(ConList));
            newgColors = flipud(newDefaultColors);
            for iConR = 1:length(ConList)
                plot(good_freqList,squeeze(PlotData.mean_exp_obt_data(iMonkey,iori,iConL,iConR,:)),'o','color',newgColors(iConR,:),'lineWidth',2,'MarkerSize',4);
                hold on;
            end
            for iConR = 1:length(ConList)
                hold on;
                plot(good_freqList(1:tf_index-1),squeeze(PlotData.mean_good_fitted_data(iMonkey,iori,iConL,iConR,(1:tf_index-1))),':','color',newgColors(iConR,:),'lineWidth',2,'MarkerSize',4);
            end
            
            for iConR = 1:length(ConList)
                hold on;
                plot(good_freqList(tf_index:end),squeeze(PlotData.mean_good_fitted_data(iMonkey,iori,iConL,iConR,(tf_index:end))),':','color',newgColors(iConR,:),'lineWidth',2,'MarkerSize',4);
            end
            
            for iConR = 1:length(ConList)
                hold on;
                patch([good_freqList(1:tf_index-1) fliplr(good_freqList(1:tf_index-1))], ...
                    [squeeze(PlotData.mean_good_fitted_data(iMonkey,iori,iConL,iConR,(1:tf_index-1)))'-squeeze(PlotData.sem_good_fitted_data(iMonkey,iori,iConL,iConR,(1:tf_index-1)))'...
                    fliplr(squeeze(PlotData.mean_good_fitted_data(iMonkey,iori,iConL,iConR,(1:tf_index-1)))'+squeeze(PlotData.sem_good_fitted_data(iMonkey,iori,iConL,iConR,(1:tf_index-1)))')],...
                    newgColors(iConR,:),'EdgeColor','none','FaceColor',newgColors(iConR,:),'LineWidth',0.1, 'FaceAlpha',0.2);
                
                hold on;
                
                patch([good_freqList(tf_index:end) fliplr(good_freqList(tf_index:end))], ...
                    [squeeze(PlotData.mean_good_fitted_data(iMonkey,iori,iConL,iConR,(tf_index:end)))'-squeeze(PlotData.sem_good_fitted_data(iMonkey,iori,iConL,iConR,(tf_index:end)))'...
                    fliplr(squeeze(PlotData.mean_good_fitted_data(iMonkey,iori,iConL,iConR,(tf_index:end)))'+squeeze(PlotData.sem_good_fitted_data(iMonkey,iori,iConL,iConR,(tf_index:end)))')],...
                    newgColors(iConR,:),'EdgeColor','none','FaceColor',newgColors(iConR,:),'LineWidth',0.1, 'FaceAlpha',0.2);
            end
            
            ylim([-0.1 maxScale+1])
            xticks([1 5 9 13 17 21 25 29]);
            
            if iMonkey ~= size(PlotData.goodParameters,1)
                set(gca,'xticklabels',[]);
            end
            
            if iConL ~= 1
                set(gca,'yticklabels',[]);
            end
            
            if iConL == 1  && iMonkey == size(PlotData.goodParameters,1)
                xlabel({'Temporal Frequency','of Mask (Hz)'},'Fontsize',10);
                ylabel({'Change in Amplitude',' at 30Hz (\muV)'},'Fontsize',10);
            end
            
            
            if iMonkey == 1
                title ("Target at " +ConList(iConL)*100 + "%",'Fontname','courier','Fontweight','bold','Fontsize',9);
                if iConL == 1
                    legend('0- Obs','6.25- Obs','12.5- Obs','25- Obs','0- Fit','6.25- Fit','12.5- Fit','25- Fit','Fontsize',8,'Location','best','Fontname','courier','Fontweight','bold');
                end
            end
            
            if size(PlotData.goodElecIds{iMonkey, iori},1)> 1
                if  iConL == 4
                    text(0.5,0.3 ,"GoodFitsElecs = " +num2str(round(100*PlotData.goodElecPercent{iMonkey,iori},1))+"%",'FontSize',8);
                end
            end
            box off;
        end
    end
end

 annotation(gcf,'textarrow',...
        [0.020 0.1] ,[0.898 0.5],...
        'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
        'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');
    
    annotation(gcf,'textarrow',...
        [0.49 0.1] ,[0.914 0.5],...
        'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
        'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');
    
    annotation(gcf,'textarrow',...
        [0.18 0.1] ,[0.93 0.5],...
        'String','Parallel', 'HeadStyle', 'none', 'LineStyle', 'none',...
        'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','Fontname','courier');
    
    annotation(gcf,'textarrow',...
        [0.625 0.1] ,[0.935 0.5],...
        'String','Orthogonal', 'HeadStyle', 'none', 'LineStyle', 'none',...
        'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','Fontname','courier');
end