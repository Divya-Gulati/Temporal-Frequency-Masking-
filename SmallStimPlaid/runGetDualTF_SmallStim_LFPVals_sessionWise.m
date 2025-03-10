%close all;
clear;clc;

runHighRmsLFPFlag = 1;  % to process extracted LFP Data (extracted data means raw data segmented in trials)
runGoodSpikeElecSpikeFlag = 1; % to process extracted Spiking Data

highRmsSaveLFPFlag = 1; % to save processed LFP Data
runGoodSpikeElecSpikeSaveFlag =1; %to save processed Spiking Data


folderSourceString = 'E:/MonkeyData'; % location of extracted Data
fileSaveDestination = 'E:\MonkeyData_DualTFSmallPaper\savedData'; % where to save processed Data
% Location of files that tell which electrodes to use - These are called
% highRMSElectrodes - they had stable receptive fields across days
parentFolder = cd;
sepStr = filesep;
Folder = parentFolder(1:max(strfind(parentFolder,sepStr))-1); 
folderHighRMSElecs =fullfile(Folder,'ReceptiveFieldData'); 

Indices_parallel = {(9), [15 16 17 18 19 20 21 22],[1 2]}; % protocol Indices
Indices_orthogonal = {(10), [23 24 25 26],[3 4 5]};

% electrodes which had good ERP were chosen for M1, M2 -all highRMS had good ERP, M3 - only ECoG electrodes
LFPElectrodesToRun_parallel = {[55 56 61 65 72 73 75 76 83 89 93],[],[82 85 86 88 89]}; 
LFPElectrodesToRun_orthogonal = {[55 61 72 74 75 76 79 83 89 93],[],[82 85 86 88 89]};

gridType = 'Microelectrode';
LFPtimeRange = [0.25 0.75];% LFP Analysis Period - Stim-InterStim was 800-700ms

SpikingtimeRange = [0 0.2];% Spike Analysis Period
spikeElecCutOffs_AllMonkeys =  {[2000 1.9 1 1], [4000 1.2 2 1],[]}; % TotalSpikesInTheSession SNR Stimulus Firing Rate  TransientFlag

useERP= 0; % if 1 - do fft on trial avg else fft is done on each trial
useCommonBaselineFlag = 1; % 1 - same baseline across all protocols
useCommonBadTrials = 1; % 1- same bad Trial number across electrodes 
dcShiftCorrectionFlag = 1; % 1- subtracting DC value during baseline period
ImValFlag = 1; % save IM component Data too

if runHighRmsLFPFlag == 1
    UsegoodSpikingElecFlag = 0; % 1 - Do LFP analysis on only those electrodes which had good firing rate also 
    ConsiderHighRMSFlag = 1; % 1- Do LFP analysis on electrodes which had stable receptive field across days
    ConsiderBadImpedanceFlag = 1; % 1 - Remove electrodes which had high Impedance on that day
    Results = cell(1,length(Indices_parallel));
end

if runGoodSpikeElecSpikeFlag == 1
    UsegoodSpikingElecFlagSpike = 1;
    ConsiderHighRMSFlagSpike = 0;
    ConsiderBadImpedanceFlagSpike = 0;
    SpikeResults = cell(1,length(Indices_parallel)-1); % 3rd monkey doesn't have spiking data
end



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
        spikeElecCutOffs = spikeElecCutOffs_AllMonkeys{iMon};
        ElectrodesToRun = ElectrodesToRunBothMonkey{iMon};
        
        if runGoodSpikeElecSpikeFlag == 1
            if iMon<length(Indices_parallel)
                [SpikeResults{idelta,iMon}] = getDualTF_SmallStim_SpikeVals(indicesToUse,folderSourceString,gridType, ...
                    LFPtimeRange,useCommonBadTrials,...
                    folderHighRMSElecs,UsegoodSpikingElecFlagSpike,spikeElecCutOffs,SpikingtimeRange,...
                    ConsiderHighRMSFlagSpike,ConsiderBadImpedanceFlagSpike);
            end
        end
        [Results{idelta,iMon}] = getDualTF_SmallStim_LFPVals_sessionWise(indicesToUse,folderSourceString,gridType, ...
            LFPtimeRange,useERP,useCommonBaselineFlag,useCommonBadTrials,dcShiftCorrectionFlag,folderHighRMSElecs,...
            UsegoodSpikingElecFlag,spikeElecCutOffs,SpikingtimeRange,...
            ConsiderHighRMSFlag,ConsiderBadImpedanceFlag,ElectrodesToRun,ImValFlag);
        
    end
end

if highRmsSaveLFPFlag == 1
    FileName = "SmallStimPlaid_HighRMSLFP_sessionWise_" + gridType+".mat";
    save(fullfile(fileSaveDestination,FileName),'Results','-v7.3');
end

if runGoodSpikeElecSpikeSaveFlag == 1
    FileName = "SmallStimPlaid_GoodSpikeElecsSpike_" + gridType+".mat";
    save(fullfile(fileSaveDestination,FileName),'SpikeResults');
end