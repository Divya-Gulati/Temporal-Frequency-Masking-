%%%%% coco protcol Indices - 8 - for 15Hz 100421 GRF_002 %%%%%%%%
%%%%% dona protocol Indices - 13 and 14:  0205 GRF_002 & 1608 GRF_003 - 15Hz
close all;
clear; clc;

saveFlag = 1;
fileSaveDestination = 'E:\MonkeyData_DualTFSmallPaper\savedData'; % where to save processed Data

gridType = 'Microelectrode';
Indices =[{8};{[13 14]}]; % coco;dona; (M1,M2)%%%% saving Data for monkeys together %%%%%%
MonkeyID = {'M1','M2'};
timeRanges = [{[0.25 1.25]};{[0.25 1.25]}];
MaskFreqsToUses = [{(1:1:29)};{(1:1:29)}];
folderSourceString =  'E:\MonkeyData'; % location of extracted Data  (extracted data means raw data segmented in trials)

% Location of files that tell which electrodes to use - These are called
% highRMSElectrodes - they had stable receptive fields across days
parentFolder = cd;
sepStr = filesep;
Folder = parentFolder(1:max(strfind(parentFolder,sepStr))-1);
folderHighRMSElecs =fullfile(Folder,'ReceptiveFieldData');

commonBaselineFlag =1; % if want to use common baseline across different stimulus conditions
useERP= 0; % if 1 - do fft on trial avg else fft is done on each trial
useCommonBadTrials = 1; % 1- same bad Trial number across electrodes
dcShiftCorrectionFlag = 1; % 1- subtracting DC value during baseline period

Results = cell(1,length(Indices));

for iMon =1:length(Indices)
    
    indicesToUse = Indices{iMon,:};
    timeRange = timeRanges{iMon,:};
    MaskFreqsToUse=MaskFreqsToUses{iMon,:};
    
    Results{iMon} =getDualTF_FullScreen_LFPVals_sessionWise(indicesToUse,...
        folderSourceString,gridType,timeRange,useERP,commonBaselineFlag,...
        useCommonBadTrials,dcShiftCorrectionFlag,folderHighRMSElecs,MaskFreqsToUse);
    
end

if saveFlag == 1
    if length(Indices) == 1
        FileName = "FullScreen_HighRMSLFP_sessionWise_" + convertCharsToStrings(MonkeyID{iMon}) +"_" +gridType + ".mat";
        save(fullfile(fileSaveDestination,FileName),'Results');
    else
        FileName = "FullScreen_HighRMSLFP_sessionWise_"+gridType + ".mat";
        save(fullfile(fileSaveDestination,FileName),'Results');
    end
end