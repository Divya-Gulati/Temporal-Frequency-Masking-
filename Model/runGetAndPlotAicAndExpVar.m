clear;clc;
folderSourceString = 'E:\MonkeyData_DualTFSmallPaper\savedData\Model';

fileString = 'Model_LFPData_for_all_elecs_alldelta_allSession_';

ModelNames = {'Tuned_Normalization_Model','Optimal_Model'};

for iname = 1:length(ModelNames)
    FileNames{iname} = [fileString ModelNames{iname} '.mat'];
end

[akaikeInfoCrit,expVarAll] = getAicAndExpVar(folderSourceString,FileNames);

plotAicAndExpVar (akaikeInfoCrit,expVarAll);

%%%%%% finding delta AIC values averaging across monkey and electrodes %%%%

for icol = 1:size(akaikeInfoCrit,2)
    minVal = min(mean([vertcat(akaikeInfoCrit{:,icol})]),[],'all');
    deltaAIC{1,icol} = mean([vertcat(akaikeInfoCrit{:,icol})])-minVal;
end
