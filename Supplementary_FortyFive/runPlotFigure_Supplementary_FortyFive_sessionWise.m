clear; clc;
folderSourceString = 'E:\MonkeyDataAnalysis\Plaid\';
FileName = "FigureFortyFiveSupplementary_FigureData_sessionWise.mat";
fullFileName = fullfile(folderSourceString,FileName);
load(fullFileName); 

%%%%%%% calculating average parameters %%%%%%%%%
filepath ='E:\MonkeyDataAnalysis\Model';%
expVarCutOffs = {[0.8 0.8],[0.8 0.8]};
fileString = 'Model_LFPData_for_all_elecs_FortyFivedelta_allSession_';

%  Model 1 - Tuned normalization model- Salelkar and Ray 2020
%  Model 2 - New reduced Model - I am calling it optimal model
ModelNames = {'Tuned_Normalization_Model','Optimal_Model'};

GoodFitsData = cell(1,size(ModelNames,2));
for imodelNums =1:2
    expVarCutOff = expVarCutOffs{imodelNums};

    Name = [fileString ModelNames{imodelNums} '.mat'];
    fileName = fullfile(filepath,Name);
    %%%%% taking only those electrodes which have positive exitflag and expVar>0.8 %%%%%%
   PlotData = getAveragedModelData_AllMonkeys(expVarCutOff,imodelNums,fileName);
   GoodFitsData{imodelNums} = PlotData;
   
    save(fullfile(filepath,['PlotData_FortyFivedelta',ModelNames{imodelNums}]),'PlotData');
    %run only first time then comment it
end

TargetTF = 15;
TFList = 1:2:29;
dataType = 'ampDiff';
Model_Names = {'Original Tuned','Optimal Tuned'};
plotFigure_Supplementary_FortyFive_sessionWise(Figure_Data,dataType,GoodFitsData,Model_Names,TargetTF,TFList)

% saveFolder = 'D:\OneDrive - Indian Institute of Science\divya\MonkeyDataAnalysis\Figures_Final';
% print(gcf,[saveFolder '\Figure_'],'-dtiff','-r600');
% savefig([saveFolder '\Figure_']);