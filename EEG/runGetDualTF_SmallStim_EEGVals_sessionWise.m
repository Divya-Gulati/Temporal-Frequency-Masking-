%close all;
clear;clc;

SaveEEGFlag = 1; % to save processed LFP Data

folderSourceString = 'E:\MonkeyData'; % location of extracted Data
fileSaveDestination = 'E:\MonkeyData_DualTFSmallPaper\savedData'; % where to save processed Data
% Location of files that tell which electrodes to use - These are called
% highRMSElectrodes - they had stable receptive fields across days
parentFolder = cd;
sepStr = filesep;
Folder = parentFolder(1:max(strfind(parentFolder,sepStr))-1); 
folderHighRMSElecs =fullfile(Folder,'ReceptiveFieldData'); 

Indices_parallel = {(34),(35)};% protocol Indices
Indices_orthogonal = {(37),(36)};%

% electrodes all high RMS and EEG electrodes for M4
LFPElectrodesToRun_parallel = {(97:114),(97:114)};
LFPElectrodesToRun_orthogonal = {(97:114),(97:114)};

gridType = 'Microelectrode';
LFPtimeRange = [0.25 0.75];% LFP Analysis Period - Stim-InterStim was 800-700ms

useERP= 0; % if 1 - do fft on trial avg else fft is done on each trial
useCommonBaselineFlag = 1; % 1 - same baseline across all protocols
useCommonBadTrials = 1; % 1- same bad Trial number across electrodes 
dcShiftCorrectionFlag = 1; % 1- subtracting DC value during baseline period
ImValFlag = 1; % save IM component Data too

SpikingtimeRange = [];
UsegoodSpikingElecFlag = 0; % 1 - Do LFP analysis on only those electrodes which had good firing rate also
ConsiderHighRMSFlag = 1; % 1- Do LFP analysis on electrodes which had stable receptive field across days
ConsiderBadImpedanceFlag = 1; % 1 - Remove electrodes which had high Impedance on that day
Results = cell(1,length(Indices_parallel));


for idelta = 1:2 % relative orientation difference between the two gratings (0 or 90)
    if idelta == 1
        Indices = Indices_parallel;
        ElectrodesToRunBothMonkey = LFPElectrodesToRun_parallel;
    elseif idelta == 2
        Indices = Indices_orthogonal;
        ElectrodesToRunBothMonkey = LFPElectrodesToRun_orthogonal;
    end
    
    for iMon = 1:length(Indices_parallel)
        
        indicesToUse = Indices{iMon};
        spikeElecCutOffs = [];
        ElectrodesToRun = ElectrodesToRunBothMonkey{iMon};
        

        [Results{idelta,iMon}] = getDualTF_SmallStim_LFPVals_sessionWise(indicesToUse,folderSourceString,gridType, ...
            LFPtimeRange,useERP,useCommonBaselineFlag,useCommonBadTrials,dcShiftCorrectionFlag,folderHighRMSElecs,...
            UsegoodSpikingElecFlag,spikeElecCutOffs,SpikingtimeRange,...
            ConsiderHighRMSFlag,ConsiderBadImpedanceFlag,ElectrodesToRun,ImValFlag);
        
    end
end


if SaveEEGFlag == 1
    FileName = "FullStimPlaid_sessionWise_EEG.mat";
    save(fullfile(fileSaveDestination,FileName),'Results','-v7.3');
end

