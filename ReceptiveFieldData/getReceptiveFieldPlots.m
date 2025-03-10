clear;clc;

subjectNames = {'coco','dona','alpaH'};
ElectrodesUsedinCocoForSmallStim = [55 56 61 65 72 73 74 75 76 79 83 89 93];

folderHighRMSElecs =cd; %fullfile(Folder,'ReceptiveFieldData');


for iName = 1:length(subjectNames)
    subjectName = subjectNames{iName};
    ArrayNum = 1;
    fileName = [subjectName 'MicroelectrodeRFData.mat'];
    datafile = load(fullfile(folderHighRMSElecs,subjectName,fileName));
    if strcmpi(subjectName,'dona')
        if ArrayNum == 1
            goodElecs = intersect(1:48,datafile.highRMSElectrodes); %V1
        else
            goodElecs = intersect(49:96,datafile.highRMSElectrodes); %V4
        end
    elseif strcmpi(subjectName,'coco')
        goodElecs = datafile.highRMSElectrodes;
    elseif strcmpi(subjectName,'alpaH')
        goodElecs = intersect(82:90,datafile.highRMSElectrodes); %ECoG
    end
    
    meanAzi{iName} = [datafile.rfStats(goodElecs).meanAzi];
    meanEle{iName} = [datafile.rfStats(goodElecs).meanEle];
    ElectrodesToPlot{iName} = goodElecs;
    sizeAzi{iName} = [datafile.rfStats(goodElecs).rfSizeAzi];
    sizeEle{iName} = [datafile.rfStats(goodElecs).rfSizeEle];

end

stimuliLocation = {[-3 -2.25],[-1.75 -2.5]};
stimuliSize= {1,1.5};
titleNames = {'M1 - Microelectrode','M2 - Microelectrode','M3 - ECoG'};

f =figure;
f.WindowState = 'maximized';
plotHandles = getPlotHandles(1,3,[0.07 0.3 0.85 0.5],0.05,0.05,0);
del = 0.01;
t = -pi:0.01:pi;

colorArray = [53 149 252;223 250 20;2 85 168;230 57 149]./255;

for ilen = 1:length(subjectNames)
    subplot(plotHandles(ilen))
    
    if ilen == 1
        plot(-10000,-10000,'+','markersize',50,'color','k');%colorArray(1,:)
        hold on;
        plot(-10000:1:-9990,-10000:1:-9990,':','linewidth',2,'color',colorArray(2,:));
        hold on;
        plot(-10000:1:-9990,-10000:1:-9990,'-','linewidth',2,'color',colorArray(3,:));
        hold on;
    end
    
    for ielec = 1:length(meanAzi{ilen})
        clearvars ellipse_major ellipse_minor x y
        ellipse_major = sizeAzi{ilen}(ielec);
        ellipse_minor = sizeEle{ilen}(ielec);
        x = meanAzi{ilen}(ielec)+(ellipse_major*cos(t));
        y = meanEle{ilen}(ielec)+(ellipse_minor*sin(t));
        patch(x,y,colorArray(2,:),'linewidth',1.5,'Edgecolor',colorArray(2,:),'FaceAlpha',0.08,'linestyle',':');%
        hold on;
        %         text(meanAzi{ilen}(ielec),meanEle{ilen}(ielec),num2str(ElectrodesToPlot{ilen}(ielec)));
        %         hold on;
    end
    
    for ielec = 1:length(meanAzi{ilen})
        plot(meanAzi{ilen}(ielec),meanEle{ilen}(ielec),'Marker','+','markersize',5,'linewidth',1.5,'color',colorArray(1,:))
        hold on;
    end
    
    title(titleNames{ilen},'FontName','courier','FontSize',15);
    set(gca,'XAxisLocation','top');

    if ilen<3
        hold on;
        viscircles (stimuliLocation{ilen},stimuliSize{ilen},'color',colorArray(3,:));
        set(gca,'YAxisLocation','right');%,'ydir','reverse'
        xlim([-4 0]);
        ylim([-4 0]);
    end
    
    Ylm=ylim;                          % get x, y axis limits
    Xlm=xlim;                          % so can position relative instead of absolute
    Xlb=mean(Xlm);                    % set horizontally at midpoint
    Jlb = mean(Ylm);                    % set vertically at midpoint
    
    if ilen<3
        Ylb=1.02*Ylm(1);
        Klb = 2.1*Xlb(1);
    else
        Ylb=0.9*Ylm(1);
        Klb = 0.9*Xlb(1);
    end
    
    hXLbl=xlabel('Azimuth (deg)','Position',[Xlb Ylb],'VerticalAlignment','top','HorizontalAlignment','center');
    if ilen == 1
        hYLbl=ylabel('Elevation (deg)','Position',[Klb Jlb],'VerticalAlignment','middle');
    end
    box off;
    if ilen == 1
        legend('Receptive field center','Receptive field boundary','Stimulus boundary','FontName','courier','Fontweight','bold')
    end
end

annotation('textbox',[0.05 0.82 0.02 0.05],'String','A','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')
annotation('textbox',[0.35 0.82 0.02 0.05],'String','B','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')
annotation('textbox',[0.65 0.82 0.02 0.05],'String','C','FontSize',18,'EdgeColor','none','Fontname','courier','Fontweight','bold')
