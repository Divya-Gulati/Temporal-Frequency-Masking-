clear; clc;

folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData'; % location of saved Data Files
FileName = "Figure2Data_sessionWise.mat"; % name of the file needed for plotting Figure 2
fullFileName = fullfile(folderSourceString,FileName);

if exist(fullFileName, 'file')
    load(fullFileName); % loading respective saved data %
else
    saveFlag =1;
    Figure2Data = getDataForFigure2_sessionWise(folderSourceString);
    if saveFlag == 1
        save(fullfile(folderSourceString,FileName),'Figure2Data');
    end
end
plotFigure2(Figure2Data)

% saveFolder = '';
% print(gcf,[saveFolder '\Figure2'],'-dtiff','-r600');
% savefig([saveFolder '\Figure2']);



