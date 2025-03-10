%%%%%%%% figure 8 %%%%%%%%%%%
%%%%%%%%%%% dona and coco ConTF - small and full screen - LFP %%%%%%%%%%
clear;clc;
fileSaveDestination = 'E:\MonkeyData_DualTFSmallPaper\savedData\conTF';
FileName = "Figure8Data_sessionWise.mat";
fullFileName = fullfile(fileSaveDestination,FileName);
if exist(fullFileName, 'file')
    load(fullFileName); % loading respective saved data %
else
    folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData\conTF';
    monkeyNames = {'M1','M2'};
    gridTypes = {'Microelectrode','Microelectrode'};
    representativemonkeyID = 2; % ID of Representative monkey
    representativeElectrodeID = 7; % ID of Representative electrode (for figure display)
    saveFlag = 1;
    [FigureData] = getDataforFigure8_sessionWise(folderSourceString,monkeyNames,gridTypes,representativemonkeyID,representativeElectrodeID);
    
    if saveFlag == 1
        save(fullfile(fileSaveDestination,FileName),'FigureData');
    end
end


%%%%% In this plot we are plotting ERP and Change in Amplitude %%%%%%
TFValues = [0 1 2 4 8 16 32 50];
ContrastValues = [0,12.5,25,50,100];
FitQualityCutOff = 0.6;
plotFigure8_ConTFSize(FigureData,TFValues,ContrastValues,FitQualityCutOff)