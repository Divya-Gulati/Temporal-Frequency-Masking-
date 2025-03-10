clear; clc;
folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData';
saveDataForEachMonkeySeparatelyFlag = 0; % you can save change in Amp data  to generate a figure similar to figure 3 but for individual monkeys

FileName = "Figure3_LFPData_sessionWise.mat";
spikingFileName ="Figure3_SpikingData.mat";

fullFileName = fullfile(folderSourceString,FileName);
fullSpikingFileName = fullfile(folderSourceString,spikingFileName);

if exist(fullFileName, 'file')
    load(fullFileName); % loading respective saved data %
    load(fullSpikingFileName);
else
    saveFlag =1;
    
    DataFileName = fullfile(folderSourceString,'SmallStimPlaid_HighRMSLFP_sessionWise_Microelectrode.mat');
    fieldsTocombine = [5 9 10];
    Figure3_LFPData = getDataForFigure3_sessionWise(DataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag);
    
    SpikingDataFileName = fullfile(folderSourceString,'SmallStimPlaid_GoodSpikeElecsSpike_Microelectrode.mat');
    fieldsTocombine = 14:18;
    Figure3_SpikingData = getDataForFigure_Spiking(SpikingDataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag);
    
    if saveFlag == 1
        save(fullfile(folderSourceString,FileName),'Figure3_LFPData');
        save(fullfile(folderSourceString,spikingFileName),'Figure3_SpikingData');
    end
end

dataType = 'ampDiff'; % or 'Subtract'
plotFigure3_sessionWise(Figure3_LFPData,Figure3_SpikingData,dataType)

% saveFolder = '';
% print(gcf,[saveFolder '\Figure3'],'-dtiff','-r600');
% savefig([saveFolder '\Figure3']);