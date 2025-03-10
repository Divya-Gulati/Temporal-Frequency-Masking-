function plotFigure3_sessionWise(Figure3_LFPData,Figure3_SpikingData,dataType)
TF = 1:2:29;
ContrastValuesLeft = [0,6.25,12.5,25];
ContrastValuesRight = [0,6.25,12.5,25];
uniquedeltaChange = [0 90];

if contains(dataType,'ampDiff')
    PlaidAvgECoG = Figure3_LFPData.ampDiff_plaid_ECoG_mean;
    PlaidSemECoG = Figure3_LFPData.ampDiff_plaid_ECoG_sem;
    PlaidAvgLFP = Figure3_LFPData.ampDiff_plaid_mean;
    PlaidSemLFP = Figure3_LFPData.ampDiff_plaid_sem;
    PlaidAvgSpiking = Figure3_SpikingData.PsthSpikeAmpChange;
    PlaidSemSpiking = zeros(2,4,4,15);
elseif contains(dataType,'Subtract')
    PlaidAvgECoG = Figure3_LFPData.changeInAmpSubtract_ECoG_mean;
    PlaidSemECoG = Figure3_LFPData.changeInAmpSubtract_ECoG_sem;
    PlaidAvgLFP = Figure3_LFPData.changeInAmpSubtract_mean;
    PlaidSemLFP = Figure3_LFPData.changeInAmpSubtract_sem;
    PlaidAvgSpiking = Figure3_SpikingData.PsthSpikeAmpChange;
    PlaidSemSpiking = zeros(2,4,4,15);
end

colorArray1 = winter(4);
colorArray2 = winter(4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure;
f.WindowState = 'maximized';
plotHandles_a= getPlotHandles(3,length(ContrastValuesRight),[0.07 0.08 0.4 0.80],0.01,0.03,0);
plotHandles_b= getPlotHandles(3,length(ContrastValuesRight),[0.54 0.08 0.4 0.80],0.01,0.03,0);

for ilen = 1:3
    if ilen == 2
        ChngeInAmpData = PlaidAvgECoG;
        ChngeInAmpSemData = PlaidSemECoG;
        NumElec = Figure3_LFPData.NumElecs_ECoG;
        ylimMax = 30;
    elseif ilen == 1
        ChngeInAmpData = PlaidAvgLFP;
        ChngeInAmpSemData = PlaidSemLFP;
        NumElec = Figure3_LFPData.NumElecs_Small_BothMonkeysMerged;
        ylimMax = 8;
    elseif ilen == 3
        ChngeInAmpData = PlaidAvgSpiking;
        ChngeInAmpSemData = PlaidSemSpiking;
        NumElec = Figure3_SpikingData.NumElecs_Small_BothMonkeysMerged;
        ylimMax = 5;
    end
    
    MaxScale = max(ChngeInAmpData,[],'all');
    
    for ioriDelta = 1:length(uniquedeltaChange)
        
        if ioriDelta == 1
            plotHandles = plotHandles_a;
            colorArray = colorArray1;
        else
            plotHandles = plotHandles_b;
            colorArray = colorArray2;
        end
        
        for iConLeft = 1:length(ContrastValuesLeft)
            subplot(plotHandles(ilen,iConLeft))
            newDefaultColors = colorArray;
            newColors = flipud(newDefaultColors);
            set(gca, 'ColorOrder', newColors, 'NextPlot', 'replacechildren');
            set(gca,'FontSize',12);ylim([0 ylimMax]);xticks(1:4:29);
            
            for iConRight = 1:length(ContrastValuesRight)
                errorbar(TF,squeeze(ChngeInAmpData(ioriDelta,iConLeft,iConRight,:)),...
                    squeeze(ChngeInAmpSemData(ioriDelta,iConLeft,iConRight,:)),'o-','LineWidth',1.8);
                hold on;
            end
            
            if iConLeft == length(ContrastValuesLeft)
                elecNum = ['N = ' num2str(NumElec(ioriDelta))];
                text(16,ceil(MaxScale),elecNum,'Fontsize',12,'Fontname','Courier','Fontweight','bold');
            end
            
            if ilen ~= 3 && iConLeft ~=1
                set(gca,'YTickLabel',[])
            end
            
            if ilen ~= 3
                set(gca,'XTickLabel',[])
            end
            
            if ilen == 3 && iConLeft ~=1
                set(gca,'YTickLabel',[])
            end
            
            if ilen == 3 && iConLeft ==1
                if ioriDelta == 1
                    legend('0','6.25','12.5','25','FontSize',9,'Fontname','Courier','Fontweight','bold');
                end
                xlabel({'Temporal Frequency',' of Mask (Hz)'},'FontSize',10.5);
                ylabel({'Change in Amplitude',' at 30Hz  (\muV)'},'FontSize',10.5);
            end
            if ilen==1
                title("Target at " + ContrastValuesLeft(iConLeft) + "%",'FontName','courier','Fontweight','bold','Fontsize',12);
            end
            if iConLeft == length(ContrastValuesLeft)
                if ilen == 1
                    h = text(32,0.6,'Pop. Avg LFP (M1 & M2)','Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                elseif ilen == 2
                    h = text(32,7,'M3 - ECoG','Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                else
                    h = text(32,0.1,'Pop. Avg Spiking (M1 & M2)','Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                end
            end
        end
    end
end
annotation(gcf,'textarrow',...
    [0.055 0.1] ,[0.90 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.52 0.1] ,[0.92 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.23 0.1] ,[0.93 0.5],...
    'String','Parallel', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','FontName','courier');

annotation(gcf,'textarrow',...
    [0.7 0.1] ,[0.945 0.5],...
    'String','Orthogonal', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','FontName','courier');

end