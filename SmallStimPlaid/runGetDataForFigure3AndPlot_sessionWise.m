clear; clc;
folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData';
saveDataForEachMonkeySeparatelyFlag = 0; % you can save change in Amp data  to generate a figure similar to figure 3 but for individual monkeys

FileName = "Figure3_LFPData_sessionWise.mat";
spikingFileName ="Figure3_SpikingData.mat";
EEGFileName = "Figure3_EEGData_sessionWise.mat";

fullLFPFileName = fullfile(folderSourceString,FileName);
fullSpikingFileName = fullfile(folderSourceString,spikingFileName);
fullEEGFileName = fullfile(folderSourceString,EEGFileName);
saveFlag = 1;

if exist(fullLFPFileName, 'file')
    load(fullLFPFileName); % loading respective saved data %
else
    
    DataFileName = fullfile(folderSourceString,'SmallStimPlaid_HighRMSLFP_sessionWise_Microelectrode.mat');
    fieldsTocombine = [5 9 10];
    Figure3_LFPData = getDataForFigure3_sessionWise(DataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag);
    if saveFlag == 1
        save(fullLFPFileName,'Figure3_LFPData');
    end
end

if exist(fullSpikingFileName, 'file')
    load(fullSpikingFileName);
else
    SpikingDataFileName =fullfile(folderSourceString,'SmallStimPlaid_GoodSpikeElecsSpike_Microelectrode.mat');
    fieldsTocombine = 14:18;
    Figure3_SpikingData = getDataForFigure_Spiking(SpikingDataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag);
    
    if saveFlag == 1
        save(fullSpikingFileName,'Figure3_SpikingData');
    end
end

if exist(fullEEGFileName, 'file')
    load(fullEEGFileName);
else
    DataFileName = fullfile(folderSourceString,'FullStimPlaid_sessionWise_EEG.mat');
    fieldsTocombine = [3 4 5 6 9 10];
    cutoff = 0.5; %uV
    Figure3_EEGData = getDataForChangeinAmp_EEG(DataFileName,fieldsTocombine,cutoff,saveDataForEachMonkeySeparatelyFlag);
    
    if saveFlag == 1
        save(fullEEGFileName,'Figure3_EEGData');
    end
end


plotFigure3_sessionWise(Figure3_LFPData,Figure3_SpikingData,Figure3_EEGData)

% saveFolder = '';
% print(gcf,[saveFolder '\Figure3'],'-dtiff','-r600');
% savefig([saveFolder '\Figure3']);