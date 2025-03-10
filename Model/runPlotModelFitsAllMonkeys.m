clear;clc; %close all;

%%%%%%% calculating average parameters %%%%%%%%%
filepath ='E:\MonkeyData_DualTFSmallPaper\savedData\Model';%
expVarCutOffs = {[0.8 0.8 0.8],[0.8 0.8 0.8]}; % cutOff for Explained Variance 
fileString = 'Model_LFPData_for_all_elecs_alldelta_allSession_';


%  Model 1 - tuned normalization model- Salelkar and Ray 2020
%  Model 2 - Optimal-tuned normalization Model
ModelNames = {'Tuned_Normalization_Model','Optimal_Model'};

for imodelNums =1:2
    expVarCutOff = expVarCutOffs{imodelNums};
    
    Name = [fileString ModelNames{imodelNums} '.mat'];
    fileName = fullfile(filepath,Name);
    %%%%% taking only those electrodes which have positive exitflag and expVar>0.8 %%%%%%
    PlotData = getAveragedModelData_AllMonkeys(expVarCutOff,imodelNums,fileName);
    
    TargetTF = 15;
    TFList = 1:2:29;
    DeltaList = [0 90];
    ConList = [0 0.0625 0.125 0.25];
    PlotModelFitsAllMonkeys(PlotData,TargetTF,TFList,ConList,DeltaList,imodelNums);
    
    %save(fullfile(filepath,['PlotData',ModelNames{imodelNums}]),'PlotData');
    %run only first time then comment it
end


