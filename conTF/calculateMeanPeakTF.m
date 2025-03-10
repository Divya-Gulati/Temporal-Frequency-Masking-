%%%% finding mean peak TF for 100% contrast small stimulus %%%
clear;clc;
fileSaveDestination = 'E:\MonkeyDataAnalysis\conTF';
FileName = "Figure8Data_sessionWise.mat";
fullFileName = fullfile(fileSaveDestination,FileName);
load(fullFileName); 

% merging TF peaks for M1 and M2 %
mergedTFPeaks = vertcat(FigureData.TF_peak{:,1:2}); 

meanTFPeak = squeeze(mean(mergedTFPeaks,1,'omitNaN'));
stdTFpeak = squeeze(std(mergedTFPeaks,[],1,'omitNaN'));
N = size(mergedTFPeaks,1);
semTFPeak = stdTFpeak./sqrt(N);
