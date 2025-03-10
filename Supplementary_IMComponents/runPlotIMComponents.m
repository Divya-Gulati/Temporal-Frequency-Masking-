close all;
clear;clc;
folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData';

FileName = "Figure_IMData_0_90_sessionWise.mat";
fullFileName = fullfile(folderSourceString,FileName);

fieldsTocombine = [3 4 6 11:14];

if exist(fullFileName, 'file')
    load(fullFileName); % loading respective saved data %
else
    saveFlag =1;
    DataFileName = fullfile(folderSourceString,'SmallStimPlaid_HighRMSLFP_sessionWise_Microelectrode.mat');
    saveDataForEachMonkeySeparatelyFlag = 0;
    Figure_IMData = getDataForFigure3_sessionWise(DataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag);
    if saveFlag == 1
        save(fullfile(folderSourceString,FileName),'Figure_IMData');
    end
end

plotFigureIM_sessionWise(Figure_IMData)
%%%%%%%%%%%%%%%%%%%%%% 45 %%%%%%%%%%%%%%%%%%%%%%%%
FileName_45 = "Figure_IMData_45_sessionWise.mat";
fullFileName_45 = fullfile(folderSourceString,FileName_45);


if exist(fullFileName_45, 'file')
    load(fullFileName_45); % loading respective saved data %
else
    saveFlag =1;
    DataFileName_45 = fullfile(folderSourceString,'SmallStimPlaid_HighRMSLFP_sessionWise_fortyFive_Microelectrode.mat');
    saveDataForEachMonkeySeparatelyFlag_45 = 1;
    Figure_IMData_45 = getDataForFigure3_sessionWise(DataFileName_45,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag_45);
    if saveFlag == 1
        save(fullfile(folderSourceString,FileName_45),'Figure_IMData_45');
    end
end

plotFigureIM_sessionWise_45(Figure_IMData_45)