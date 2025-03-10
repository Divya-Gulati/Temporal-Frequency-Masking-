function plotFigure8_ConTFSize(FigureData,TFValues,ContrastValues,FitQualityCutOff,useAvgFitFlag)

if ~exist('useAvgFitFlag','var');    useAvgFitFlag = 1; end

f = figure;
f.WindowState = 'maximized';
plotHandles1= getPlotHandles(length(TFValues),2,[0.10 0.06 0.33 0.85],0.015,0.03);
plotHandles2 =  getPlotHandles(2,2,[0.53 0.4 0.4 0.51],0.03,0.045);
plotHandles3 =  getPlotHandles(1,1,[0.53 0.075 0.4 0.25],0.02,0.02,0);

%%%%% plotting ERP for max contrast for the representative electrode %%%%%%
ERPdata = squeeze(FigureData.erpDataSingleElec (:,end,:,:));

clearvars yminVal ymaxVal
yminVal = floor(min(ERPdata,[],'all'))+3;%floor(min(ERPdata,[],'all')/100)*100;
ymaxVal = ceil(max(ERPdata,[],'all')/100)*100;

timeAxis = FigureData.timeValues ;
colorArray = [0.6554 0.0461 0.0100; 0.7411 0.0505 0.4253; 0.7695 0.1313 0.8356; 0.6235 0.4439 0.9916;0.3855 0.6525 0.9680; 0.0618 0.8018 0.8415; 0.2250 0.9130 0.6262; 0.5582 0.9969 0.0832];

iplot = [2 1];
for iSize = 1:size(ERPdata,1)
    for iTF = 1:size(ERPdata,2)
        subplot(plotHandles1(iTF,iplot(iSize)))
        clearvars dataToPlot
        dataToPlot = squeeze(ERPdata(iSize,iTF,:));
        plot(timeAxis,dataToPlot,'color',colorArray(iTF,:),'linewidth',1.5)
        ylim([yminVal ymaxVal]);xlim([-0.5 2]);

        if iTF == 1
            if iSize == 1
                title('Small Stimuli - 1.5 degrees','Fontsize',12,'FontName','Courier','FontWeight','bold');
            else
                title('Full-field Stimuli','Fontsize',12,'FontName','Courier','FontWeight','bold');
            end
        end
        
        if iTF ~= size(ERPdata,2)
            set(gca,'xticklabel',[]);
        end
        
        if  iplot(iSize) == size(ERPdata,1)
            set(gca,'yticklabel',[]);
            set(gca,'YAxisLocation','right')
            set(gca,'YTickLabel',[])
            ylabel(gca, num2str(TFValues(iTF)) + "Hz ",'Color',colorArray(iTF,:),'Fontsize',13,'FontWeight','bold');
        end
    end
    
    if iplot(iSize) == 1
        if iTF == size(ERPdata,2)
            ylabel('Amplitude (\muV)');%,'FontWeight','bold'
        end
    end
    
    if iTF == size(ERPdata,2)
        xlabel('Time (seconds)');%,'FontWeight','bold'
    end
    
end

%%%%% plotting change in amplitude for the representative electrode %%%%%%
changeInAmp_SingleElec = FigureData.ChangeinAmpSingleElec ;
changeInAmpFits_SingleElec = squeeze(FigureData.ChangeAmpSingleElecFitTFResponse);
xaxisVals = 1:0.1:100;
[Peaks,indices] = (max(changeInAmpFits_SingleElec,[],3));


newDefaultColors = gray(length(ContrastValues)+2);
newline = flipud(newDefaultColors);
clearvars  yminVal ymaxVal
ymaxVal = round(ceil(max(changeInAmp_SingleElec,[],'all')/15)*15);
yminVal = round(floor(min(changeInAmp_SingleElec,[],'all')/1)*1);

for jsize = 1:size(changeInAmp_SingleElec,1)
    subplot(plotHandles2(1,iplot(jsize)))
    for iCon = 1:size(changeInAmp_SingleElec,2)
        clearvars dataToPlot
        dataToPlot = squeeze(changeInAmpFits_SingleElec(jsize,iCon,:));
        semilogx(xaxisVals,dataToPlot,'linewidth',2,'color',newline(iCon+2,:));
        hold on;xlim([0.8 64]);
    end
    
    for jTF = 1:size(changeInAmp_SingleElec,3)
        for jCon = 1:size(changeInAmp_SingleElec,2)
            clearvars dataToPlot
            dataToPlot = squeeze(changeInAmp_SingleElec(jsize,jCon,jTF));
            semilogx(TFValues(jTF),dataToPlot,'o','linewidth',1,'MarkerFaceColor',colorArray(jTF,:),'MarkerEdgeColor',newline(jCon+2,:),'markerSize',10,'color','k');
            hold on; ylim([yminVal ymaxVal]); xlim([0.8 64]);
        end
    end
    
    for jCon = 1:size(Peaks,2)
        semilogx(xaxisVals(indices(jsize,jCon)),Peaks(jsize,jCon),'^','linewidth',2,'MarkerFaceColor',newline(jCon+2,:),'MarkerEdgeColor',newline(jCon+2,:),'markerSize',6);
        hold on;xlim([0.8 64]);
    end
    
    set(gca,'box','off');
    
    if iplot(jsize) == 1
        ylabel ('Change in Amplitude at {\it 2f} (\muV)');%,'FontWeight','bold'
        text(1,ymaxVal-2.5,'Representative Electrode','color','k','FontWeight','bold','fontname','courier');
    end
    
    if jsize == 1
        title('Small Stimuli - 1.5 degrees','Fontsize',12,'FontName','Courier');%,'FontWeight','bold'
    else
        title('Full-field Stimuli','Fontsize',12,'FontName','Courier');%,'FontWeight','bold'
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% plotting change in amplitude for electrode average %%%%%%
changeInAmp_ElecAvg =FigureData.averageChangeInAmp;
changeInAmp_ElecSem = FigureData.semChangeInAmp;

if useAvgFitFlag
    changeInAmpFits_ElecAvg =squeeze(FigureData.TFResponse{1, 3});
    clearvars Peaks indices
    [Peaks,indices] = (max(squeeze(FigureData.TFResponse{1, 3}),[],3));
else
    TF_ResponseMerge = vertcat(FigureData.TFResponse{1, 1},FigureData.TFResponse{1, 2});
    FitQualityMerged = vertcat(FigureData.FitQuality{1, 1},FigureData.FitQuality{1, 2});
    goodFitElecs = repmat(FitQualityMerged  >= 0.75,[1,1,1,size(TF_ResponseMerge,4)]);
    goodFitElecs =  goodFitElecs.*1;
    goodFitElecs(goodFitElecs == 0) = NaN;
    changeInAmpFits_ElecAvg =squeeze(mean(TF_ResponseMerge.*goodFitElecs,1,'omitnan'));
    clearvars Peaks indices
    [Peaks,indices] = (max(squeeze(mean(TF_ResponseMerge.*goodFitElecs,1,'omitnan'))  ,[],3));
end

clearvars  yminVal ymaxVal
ymaxVal = round(ceil(max(changeInAmp_ElecAvg,[],'all')/15)*15);
yminVal = min(changeInAmp_ElecAvg,[],'all')-1;
Cons = {'0%','12.5%','25%','50%','100%'};


for jsize = 1:size(changeInAmp_ElecAvg,1)
    subplot(plotHandles2(2,iplot(jsize)))
    for iCon = 1:size(changeInAmp_ElecAvg,2)
        clearvars dataToPlot
        dataToPlot = squeeze(changeInAmpFits_ElecAvg(jsize,iCon,:));
        semilogx(xaxisVals,dataToPlot,'linewidth',2,'color',newline(iCon+2,:));
        hold on;
    end
    
    for jTF = 1:size(changeInAmp_ElecAvg,3)
        for jCon = 1:size(changeInAmp_ElecAvg,2)
            clearvars dataToPlot
            dataToPlot = squeeze(changeInAmp_ElecAvg(jsize,jCon,jTF));
            semData = squeeze(changeInAmp_ElecSem(jsize,jCon,jTF));
            e= errorbar(TFValues(jTF),dataToPlot,semData,semData,...
                'o','linewidth',1,'MarkerFaceColor',colorArray(jTF,:),'MarkerEdgeColor',newline(jCon+2,:),'markerSize',10,'color','k');
            e.CapSize = 0;
            hold on; ylim([yminVal ymaxVal]);xlim([0 64]);
        end
    end
    set(gca,'XScale','log');
    
    for jCon = 1:size(Peaks,2)
        semilogx(xaxisVals(indices(jsize,jCon)),Peaks(jsize,jCon),'^','linewidth',2,'MarkerFaceColor',newline(jCon+2,:),'MarkerEdgeColor',newline(jCon+2,:),'markerSize',6);
        hold on;
    end
    
    xlim([0.8 64]);
    xlabel('Temporal Frequency (Hz)');%,'FontWeight','bold'
    set(gca,'box','off');
    
    if iplot(jsize) == 1
        ylabel ('Change in Amplitude at {\it 2f} (\muV)');%,'FontWeight','bold'
        string =" Pop. Avg (N=" + FigureData.LengthOfAllElecs+ ")";
        text(1,ymaxVal-2,string,'color','k','FontWeight','bold','fontname','courier');
    else
        legend(Cons,'location','northeast','Fontsize',9.5,'fontname','courier','FontWeight','bold');%legend('boxoff');
    end
    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Large Stim vs Small Stim Comparison Plot  %%%%%%%%%%%%%%%
subplot(plotHandles3(1))
newColors_dots =flipud(gray(7));
newColors_dots =newColors_dots(4:7,:);

Cons = {'12.5%','25%','50%','100%'};
Monkeys = {'M1','M2'};
vec = [-Inf:-Inf+20];
for icon = 1:length(Cons)
    hold on;
    plot(vec,'color',newColors_dots(icon,:),'lineWidth',20);
end

scatter(Inf,Inf,1,'d','MarkerFaceColor','w','MarkerEdgeColor','k');
scatter(Inf,Inf,1,'o','MarkerFaceColor','w','MarkerEdgeColor','k');

AllLargeStim = []; AllSmallStim = [];
for iMonkey = 1:2
    dataInput = FigureData.TFResponse{iMonkey};
    FitQuality =FigureData.FitQuality{iMonkey};
    [SmallStim,LargeStim] = LargeSmallComparison(dataInput,FitQuality,FitQualityCutOff);
    
    for i= 2:size(LargeStim,2) % number of contrasts - removing zero percent
        hold on;
        if iMonkey == 1
            scatter(LargeStim(:,i),SmallStim(:,i),150,'d',"filled",'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',newColors_dots(i-1,:));
        else
            scatter(LargeStim(:,i),SmallStim(:,i),150,"filled",'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',newColors_dots(i-1,:));
        end
        hold on;
    end   
    AllLargeStim= [AllLargeStim;LargeStim];
    AllSmallStim = [AllSmallStim;SmallStim];  
end

LargeStimVals =  reshape(AllLargeStim(:,[2:5]),1,[]);
SmallStimVals = reshape(AllSmallStim(:,[2:5]),1,[]);
[pValues,rejectVals] = signrank(LargeStimVals,SmallStimVals,'tail','right');
if rejectVals== 1
    FinalVals = pValues;
end
string = ['p = ' num2str(FinalVals)];
text(12,1.5,string,'color','k','FontWeight','bold','fontname','courier','Fontsize',12);

hold on;
plot([0.1 35],[0.1 35],'b:','linewidth',1.5);

ylim([1 25]);set(gca,'Xscale','log') ;
xlim([1 25]);set(gca,'Yscale','log') ;
ylabel('Small Stimuli Preferred TF (Hz)');%,'FontName','Courier','FontWeight','bold'
xlabel('Full-field Stimuli Preferred TF (Hz)','VerticalAlignment','top','HorizontalAlignment','center');%,'Position',[4 0.33],,'FontWeight','bold'

legend([Cons Monkeys],'location','northwest','Fontsize',11,'fontname','courier','FontWeight','bold');%legend('boxoff');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
annotation("textbox",[.065 .845 .1 .1],'String','A','FontSize',18,'FontWeight','Bold','EdgeColor','none','FontName','Courier');
annotation("textbox",[.485 .84 .1 .1],'String','B','FontSize',18,'FontWeight','Bold','EdgeColor','none','FontName','Courier');
annotation("textbox",[.485 .565 .1 .1],'String','C','FontSize',18,'FontWeight','Bold','EdgeColor','none','FontName','Courier');
annotation("textbox",[.485 .26 .1 .1],'String','D','FontSize',18,'FontWeight','Bold','EdgeColor','none','FontName','Courier');


end

function [SmallStim,LargeStim] = LargeSmallComparison(TFResponse,FitQuality,cutOff)
xaxisVals = 1:0.1:100;

[~,index] = max(TFResponse,[],4);
xAxVal = xaxisVals(index);

GoodFits = FitQuality>= cutOff;
GoodVals = xAxVal.*GoodFits;
GoodVals (GoodVals == 0) = NaN;

% making preferred TF = 1 as NaN
GoodVals (GoodVals <= 1.5) = NaN;

% making preferred TF > 50 as NaN
GoodVals (GoodVals > 50) = NaN;

SmallStim =  squeeze(GoodVals(:,1,:));
LargeStim = squeeze(GoodVals(:,2,:));

end