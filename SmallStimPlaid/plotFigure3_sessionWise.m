function plotFigure3_sessionWise(Figure3_LFPData,Figure3_SpikingData,Figure3_EEGData)
TF = 1:2:29;
ContrastValuesLeft = [0,6.25,12.5,25];
ContrastValuesRight = [0,6.25,12.5,25];
uniquedeltaChange = [0 90];

PlaidAvgECoG = Figure3_LFPData.ampDiff_plaid_ECoG_mean;
PlaidSemECoG = Figure3_LFPData.ampDiff_plaid_ECoG_sem;
PlaidAvgLFP = Figure3_LFPData.ampDiff_plaid_mean;
PlaidSemLFP =  Figure3_LFPData.ampDiff_plaid_sem;
PlaidAvgSpiking =squeeze(Figure3_SpikingData.ampDiff_spike_plaid_mean(2,:,:,:,:));
PlaidSemSpiking = squeeze(Figure3_SpikingData.ampDiff_spike_plaid_sem(2,:,:,:,:));
PlaidElecAvgSpiking = squeeze(Figure3_SpikingData.PsthSpikeAmpChange(1,:,:,:,:));
PlaidElecSemSpiking = zeros(2,4,4,15);
PlaidAvgEEG = Figure3_EEGData.ampDiff_plaid_mean;
PlaidSemEEG =  Figure3_EEGData.ampDiff_plaid_sem;

colorArray1 = winter(4);
colorArray2 = winter(4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure;
f.WindowState = 'maximized';
plotHandles_a= getPlotHandles(5,length(ContrastValuesLeft),[0.045 0.079 0.42 0.844],0.01,0.01,0);
plotHandles_b= getPlotHandles(5,length(ContrastValuesLeft),[0.54 0.079 0.42 0.844],0.01,0.01,0);

for ilen = 1:5
    if ilen == 2
        ChngeInAmpData = PlaidAvgECoG;
        ChngeInAmpSemData = PlaidSemECoG;
        NumElec = Figure3_LFPData.NumElecs_ECoG;
        ylimMax = 30;
        ylimMin = -2;
    elseif ilen == 1
        ChngeInAmpData = PlaidAvgLFP;
        ChngeInAmpSemData = PlaidSemLFP;
        NumElec =Figure3_LFPData.NumElecs_Small_BothMonkeysMerged;
        ylimMax = 7;
        ylimMin = -0.5;
    elseif ilen == 3
        ChngeInAmpData = PlaidElecAvgSpiking;
        ChngeInAmpSemData = PlaidElecSemSpiking;
        NumElec = Figure3_SpikingData.NumElecs_Small_BothMonkeysMerged(1,:);
        ylimMax = 4.5;
        ylimMin = -0.4;
    elseif ilen == 4
        ChngeInAmpData = PlaidAvgSpiking;
        ChngeInAmpSemData = PlaidSemSpiking;
        NumElec = Figure3_SpikingData.NumElecs_Small_BothMonkeysMerged(2,:);
        ylimMax = 13;
        ylimMin = -1;
    elseif ilen == 5
        ChngeInAmpData = PlaidAvgEEG;
        ChngeInAmpSemData = PlaidSemEEG;
        NumElec = Figure3_EEGData.NumElecs_Small_BothMonkeysMerged;
        ylimMax = 2.5;
        ylimMin = -0.4;
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
            set(gca,'FontSize',12);ylim([ylimMin ylimMax]);xticks(1:4:29);
            
            for iConRight = 1:length(ContrastValuesRight)
                errorbar(TF,squeeze(ChngeInAmpData(ioriDelta,iConLeft,iConRight,:)),...
                    squeeze(ChngeInAmpSemData(ioriDelta,iConLeft,iConRight,:)),'o-','LineWidth',1.8);
                hold on;
            end
            
            if iConLeft ==1% length(ContrastValuesLeft)
                elecNum = ['N = ' num2str(NumElec(ioriDelta))];
                text(18,floor(ylimMax),elecNum,'Fontsize',12,'Fontname','Courier','Fontweight','bold');
            end
            
            if ilen == 1
                yticks([0 3 6]);
            elseif ilen == 2
                yticks([0 14 28]);
            elseif ilen == 4
                yticks([0 6 12]);
            end
            
            if ilen ~= 5 && iConLeft ~=1
                set(gca,'YTickLabel',[])
            end
            
            if ilen ~= 5
                set(gca,'XTickLabel',[])
            end
            
            if ilen == 5 && iConLeft ~=1
                set(gca,'YTickLabel',[])
            end
            
            if ilen == 5 && iConLeft ==1
                if ioriDelta == 1
                    legend('0','6.25','12.5','25','FontSize',9,'Fontname','Courier','Fontweight','bold','location','NorthWest'); legend('boxoff')
                end
                xlabel({'Temporal Frequency',' of Mask (Hz)'},'FontSize',10.5);
                ylabel({'Change in Amplitude',' at 30Hz  (\muV)'},'FontSize',10.5);
            end
            if ilen==1
                title("Target at " + ContrastValuesLeft(iConLeft) + "%",'FontName','courier','Fontweight','bold','Fontsize',12);
            end
            if iConLeft == length(ContrastValuesLeft)
                if ilen == 1
                    h = text(33.5,0.5,{'Pop. Avg LFP',' (M1 & M2)'},'Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                elseif ilen == 2
                    h = text(33.5,10,{'ECoG', '(M3)'},'Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                elseif ilen == 3
                    h = text(33.5,-0.28,{'Pop. Avg Spiking','   (M1 & M2)'},'Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                elseif ilen == 4
                    h = text(33.5,0.9,{'Pop. Spiking', ' (M1 & M2)'},'Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                elseif ilen == 5
                    h = text(33.5,-0.1,{'Pop. Avg EEG','  (M2 & M4)'},'Fontsize',9.5,'Fontname','Courier','Fontweight','bold','color','k');
                    set(h,'Rotation',90);
                end
            end
        end
    end
end
annotation(gcf,'textarrow',...
    [0.02 0.1] ,[0.955 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.51 0.1] ,[0.97 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.256 0.2] ,[0.955 0.5],...
    'String','Parallel', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','FontName','courier');

annotation(gcf,'textarrow',...
    [0.7 0.2] ,[0.97 0.5],...
    'String','Orthogonal', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'color','k','FontName','courier');

end