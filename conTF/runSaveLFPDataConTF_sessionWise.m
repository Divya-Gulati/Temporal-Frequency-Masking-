%%%%%%%% ConTF- Counterphase data for LFP highRMS Electrodes %%%%%%%%%%%

%%%% coco has two sizes ran in separate ConTFs protocol - 220421 (no spiking electrodes)
%%%% GRF-002 - FullScreen and
%%%% GRF_003 sigma is 1.5
%%%% both were ran for 7Con*8TF
%%%%  Stim Duration 800-700, white fixation dot
%%% but for saving we are using only 5*8

%%%% dona has two sizes ran in the same protocol - 2 sessions
%%%% 1500-1500, black fixation dot, 5Con*8TF
%%%% 060723 - GRF_001
%%%% 120624 - GRF_002_GRF_003_GRF_004_GRF_005_GRF_006 - special protocols
%%%% used for combining and then bad Trials were ran

%%% refer to protocolInformationConTF.m for more information %%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;
close all;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
monkeyNames = {'coco','dona'};
monkeyID = {'M1','M2'};
gridTypes = {'Microelectrode','Microelectrode'};
folderSourceString =  'E:\MonkeyData';   % loading the extracted data
fileSaveDestination = 'E:\MonkeyData_DualTFSmallPaper\savedData\conTF'; % location where files will be saved

% % %   getting high RMS (good) electrodes
parentFolder = cd;
sepStr = filesep;
Folder = parentFolder(1:max(strfind(parentFolder,sepStr))-1); 
folderHighRMSElecs =fullfile(Folder,'ReceptiveFieldData'); 

useCommonBadTrials = 1;

runLFPFlag = 1;
runLFPforGoodSpike = 0; % to save spiking data

saveLFPFlag = 1;
saveLFPforGoodSpike = 0;


% LFP Inputs
ConsiderHighRMSFlag = 1;
ConsiderBadImpedanceFlag = 1;
commonBaselineFlag = 1; % if want to use common baseline across different stimulus conditions
useERP= 0; % if 1 - averaging trials to get ERP and then taking FFT

% Spike Inputs
ConsiderBadImpedanceSpikeFlag = 0;
ConsiderHighRMSSpikeFlag = 0;
checkClearTransientFlag = 1;

%%% cutoff for selecting spiking units for each monkey - 1st Total spikes
%%% in that session, 2nd - SNR Value of the segment shape, 3rd - Delta
%%% Firing rate - spikes/sec (Stim-Baseline)
allCutOffs = {[0 0 0];[5000 1.2 1.3]}; % M1,M2
%%%  M1 doesn't have any spiking elecs


for iName = 1:length(monkeyNames)
    
    clearvars LFPResults 
    
    monkeyName = monkeyNames{iName};
    gridType = gridTypes{iName};
    electrodesToProcess = []; % if you want to process for specific electrodes instead of all high RMS % incase highRMSElecs Flag is zero and you want to save only selected electrodes
    
    if runLFPFlag == 1
        [LFPResults.analogDataAllElec,LFPResults.elecfftST,LFPResults.elecfftBL,LFPResults.ampDiff,LFPResults.params]...
            =saveLFPDataConTF_sessionWise(monkeyName,folderSourceString,gridType,...
            useERP,commonBaselineFlag,...
            useCommonBadTrials,ConsiderBadImpedanceFlag,ConsiderHighRMSFlag,...
            folderHighRMSElecs,electrodesToProcess);
    end
    
    if saveLFPFlag == 1
        FileName = convertCharsToStrings(monkeyName) +"_ConTF_highRMSLFP_sessionWise_" + gridType+".mat";
        save(fullfile(fileSaveDestination,FileName),'LFPResults');
    end
    
    if runLFPforGoodSpike == 1
        goodSpikingFlag = 1;
        if strcmpi(gridType,'Microelectrode') && ~strcmpi(monkeyName,'coco')
            cutOffs = allCutOffs{iName};
            [GoodSpikeLFPResults.analogDataAllElec,GoodSpikeLFPResults.elecfftST,...
                GoodSpikeLFPResults.elecfftBL,GoodSpikeLFPResults.ampDiff,GoodSpikeLFPResults.params]...
                =saveLFPDataConTF_sessionWise(monkeyName,folderSourceString,gridType,...
                useERP,commonBaselineFlag,...
                useCommonBadTrials,ConsiderBadImpedanceSpikeFlag,ConsiderHighRMSSpikeFlag,...
                folderHighRMSElecs,electrodesToProcess,goodSpikingFlag,checkClearTransientFlag,cutOffs);
            
            if saveLFPforGoodSpike == 1
                FileName = convertCharsToStrings(monkeyID{iName}) +"_ConTF_GoodSpikingLFP_sessionWise_" + gridType+".mat";
                save(fullfile(fileSaveDestination,FileName),'GoodSpikeLFPResults');
            end
        end
    end
    
end
