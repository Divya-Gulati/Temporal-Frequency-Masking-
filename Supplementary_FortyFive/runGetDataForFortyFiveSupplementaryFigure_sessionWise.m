clear; clc;
folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData';
FileName = "FigureFortyFiveSupplementary_FigureData_sessionWise.mat";
fullFileName = fullfile(folderSourceString,FileName);
saveDataForEachMonkeySeparatelyFlag = 1;
fieldsTocombine = [5 9 10];

if exist(fullFileName, 'file')
    load(fullFileName); % loading respective saved data %
else
    saveFlag =1;
    DataFileName = fullfile(folderSourceString,'SmallStimPlaid_HighRMSLFP_sessionWise_fortyFive_Microelectrode.mat');
    Figure_Data = getDataForFigure3_sessionWise(DataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag);
    
    if saveFlag == 1
        save(fullfile(folderSourceString,FileName),'Figure_Data');
    end
end

