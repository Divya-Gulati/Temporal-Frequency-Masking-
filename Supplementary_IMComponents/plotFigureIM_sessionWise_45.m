function plotFigureIM_sessionWise_45(FigureData)
TF = 1:2:29;
ContrastValuesLeft = [0,6.25,12.5,25];
ContrastValuesRight = [0,6.25,12.5,25];
uniquedeltaChange = [45];
colorArray = [0.4 0.4 0.4; 0.85 0.3 0.2];
colorScheme = winter(4);
FreqVals = 0:2:1998;

f = figure;
f.Position = [0 0 900 900];
plotHandles_a= getPlotHandles(15,2,[0.05 0.06 0.315 0.84],0.015,0.005);
plotHandles_b= getPlotHandles(2,4,[0.455 0.545 0.50 0.352],0.012,0.015,0);
plotHandles_c= getPlotHandles(2,4,[0.455 0.06 0.50 0.352],0.012,0.015,0);

tVal = TF == 15;
FreqToPlot = 31;

for iori = 1:length(FigureData.NumElecs_ECoG)
    
        plotHandles1= plotHandles_a;
        plotHandles2= plotHandles_b;
        plotHandles3= plotHandles_c;
        goodColor = 2;
    
    for iscale = 1:2
        
        if iscale == 1
            namea = '';
            NumElec = FigureData.NumElecs_M1;
        else
            namea = '_ECoG';
            NumElec = FigureData.NumElecs_ECoG;
        end
        
        clearvars gratingData gratingData_sem
        gratingData = squeeze(FigureData.(['fftST_grating' namea '_mean'])(iori,4,tVal,:))';
        gratingData_sem = squeeze(FigureData.(['fftST_grating' namea '_sem'])(iori,4,tVal,:))';
        
        clearvars imPlusData imPlusData_sem
        imPlusData = squeeze(FigureData.(['ampDiff_plaid_F1F2plus' namea '_mean'])(iori,:,:,:));
        imPlusData_sem = squeeze(FigureData.(['ampDiff_plaid_F1F2plus' namea '_sem'])(iori,:,:,:));
        
        clearvars imMinusData imMinusData_sem
        imMinusData = squeeze(FigureData.(['ampDiff_plaid_F1F2minus' namea '_mean'])(iori,:,:,:));
        imMinusData_sem = squeeze(FigureData.(['ampDiff_plaid_F1F2minus' namea '_sem'])(iori,:,:,:));
        
        for iTF = 1:length(TF)
            clearvars plaidData plaidData_sem
            plaidData = squeeze(FigureData.(['fftST_plaid' namea '_mean'])(iori,4,4,iTF,:))';
            plaidData_sem = squeeze(FigureData.(['fftST_plaid' namea '_sem'])(iori,4,4,iTF,:))';
            subplot(plotHandles1(iTF,iscale))
            plot(FreqVals(1:FreqToPlot),gratingData(1:FreqToPlot),'color',colorArray(1,:),'Linewidth',1.5);
            hold on;
            patch([FreqVals(1:FreqToPlot) fliplr(FreqVals(1:FreqToPlot))],[gratingData(1:FreqToPlot)-gratingData_sem(1:FreqToPlot) fliplr(gratingData(1:FreqToPlot)+gratingData_sem(1:FreqToPlot))],...
                colorArray(1,:),'EdgeColor','none','FaceColor',colorArray(1,:),'LineWidth',1, 'FaceAlpha',0.2);
            hold on;
            plot(FreqVals(1:FreqToPlot),plaidData(1:FreqToPlot),'color',colorArray(goodColor,:),'Linewidth',1.5);
            hold on;
            patch([FreqVals(1:FreqToPlot) fliplr(FreqVals(1:FreqToPlot))],[plaidData(1:FreqToPlot)-plaidData_sem(1:FreqToPlot) fliplr(plaidData(1:FreqToPlot)+plaidData_sem(1:FreqToPlot))],...
                colorArray(goodColor,:),'EdgeColor','none','FaceColor',colorArray(goodColor,:),'LineWidth',1, 'FaceAlpha',0.2);
            xlim([0 60]);ylim([0 30]);
            
            xline(15+TF(iTF),':','Linewidth',2,'color',[184 115 51]./255);
            xline(abs(15-TF(iTF)),':','Linewidth',2,'color',[92 64 51]./255);
            xticks([0 20 40 60]);
            yticks([0 10 20 30]);
            
            if iTF~=length(TF)
                set(gca,'YTickLabel',[]);
                set(gca,'XTickLabel',[]);
            end
            
            if iscale == 2
                yyaxis right;%set(gca,'YAxisLocation','right')
                set(gca,'YTickLabel',[])
                ax = gca;
                ax.YAxis(1).Color = 'k';
                ax.YAxis(2).Color = 'w';
                ylabel(gca, +TF(iTF),'Color','k','FontWeight','bold','FontName','courier');
            end
            box 'off';
            
            if iTF == 1
                if iscale == 1
                    title ('LFP','color','k','FontSize',13,'FontName','courier','Fontweight','bold');
                else
                    title ('ECoG','color','k','FontSize',13,'FontName','courier','Fontweight','bold');
                end
            end
        end
        if iscale == 1
            ylabel('Amplitude (\muV)');
        end
        xlabel('Frequency (Hz)');
        
        %%%%%%%%% change in Amp _IM%%%%
        
        for imPlot = 1:2
            
            if imPlot == 1
                IMdataMean = imMinusData;
                IMdataSem = imMinusData_sem;
                plotHandles_IM = plotHandles2;
            else
                IMdataMean = imPlusData;
                IMdataSem = imPlusData_sem;
                plotHandles_IM = plotHandles3;
            end
            
            MaxScaleIMM = max(IMdataMean,[],'all');
            MinScaleIMM = min(IMdataMean,[],'all');
            for iTarCon = 1:length(ContrastValuesLeft)
                subplot(plotHandles_IM(iscale,iTarCon))
                newDefaultColors = colorScheme;
                newColors = flipud(newDefaultColors);
                set(gca, 'ColorOrder', newColors, 'NextPlot', 'replacechildren');
                for iConRight = 1:length(ContrastValuesRight)
                    errorbar(TF,squeeze(IMdataMean(iTarCon,iConRight,:)),...
                        squeeze(IMdataSem(iTarCon,iConRight,:)),'o-','LineWidth',1.8);
                    hold on;
                end
                limits_y = [MinScaleIMM-2 ceil(MaxScaleIMM)+8];
                set(gca,'FontSize',9);ylim(limits_y);xticks(1:4:29);
                if iscale ~= 2 && iTarCon ~=1
                    set(gca,'YTickLabel',[])
                end
                
                if iscale ~= 2
                    set(gca,'XTickLabel',[])
                end
                
                if iscale == 2 && iTarCon ~=1
                    set(gca,'YTickLabel',[])
                end
                
                if imPlot == 2 && iscale == 1 && iTarCon ==1
                    legend('0','6.25','12.5','25','FontSize',6,'Fontname','Courier','Fontweight','bold','location','northeast');
                end
                
                if iscale == 2 && iTarCon ==1
                    xlabel({'Temporal Frequency',' of Mask (Hz)'},'FontSize',8);
                    if imPlot == 1
                        ylabel({'Change in Amplitude',' at {\it f_1 - f_2} (\muV)'},'FontSize',8);
                    else
                        ylabel({'Change in Amplitude',' at {\it f_1 + f_2} (\muV)'},'FontSize',8);
                    end
                end
                if iscale==1
                    title("Target at " + ContrastValuesLeft(iTarCon) + "%",'Fontname','Courier','FontSize',8);
                end
                if iTarCon == length(ContrastValuesLeft)
                    if iscale == 1
                        h = text(32,floor(MinScaleIMM)+1,'M2-Microelectrode','Fontsize',8,'Fontname','Courier','Fontweight','bold','color','k');
                        set(h,'Rotation',90);
                    else
                        h = text(32,[(mean(limits_y))-3.5],'M3 - ECoG','Fontsize',8,'Fontname','Courier','Fontweight','bold','color','k');
                        set(h,'Rotation',90);
                    end
                end
            end
            
            elecNum = ['N = ' num2str(NumElec)];
            text(13,ceil(MaxScaleIMM)+6.3,elecNum,'Fontsize',10,'Fontname','Courier','Fontweight','bold');
        end
    end
end

annotation(gcf,'textarrow',...
    [0.19 0.1] ,[0.937 0.5],...
    'String','Delta 45', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',16, 'color',colorArray(2,:),'FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.03 0.1] ,[0.935 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.39 0.1] ,[0.935 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.39 0.1] ,[0.465 0.5],...
    'String','C', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.63 0.1] ,[0.925 0.5],...
    'String','{\it f_1 - f_2}', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',16, 'color',colorArray(2,:),'FontWeight','bold', 'TextRotation',0,'Fontname','courier');

annotation(gcf,'textarrow',...
    [0.63 0.1] ,[0.46 0.5],...
    'String','{\it f_1 + f_2}', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',16, 'color',colorArray(2,:),'FontWeight','bold', 'TextRotation',0,'Fontname','courier');


end