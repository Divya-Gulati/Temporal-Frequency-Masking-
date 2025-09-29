function dataMerged = getDataForChangeinAmp_EEG(DataFileName,fieldsTocombine,cutoff,saveDataForEachMonkeySeparatelyFlag)
%%% loading full screen data file %%%%
clearvars Results
Results = load(DataFileName);

EEGResults = Results.Results;

allfieldNames_Small = fieldnames(EEGResults{1,1});
fieldsTocombine_Small = fieldsTocombine;

for ifN = 1:length(fieldsTocombine_Small)
    
    for idelta = 1:size(EEGResults,1) % across rows delta is changing and across columns monkeys
        clearvars name dataMergedAcrossMonkeys addName
        
        name = cell2mat(allfieldNames_Small(fieldsTocombine_Small(ifN)));
        
        clearvars dataCombine
        dataCombine = cell(1,size(EEGResults,2));
        for iMonId = 1:size(EEGResults,2)
            
            if ifN == 1
                allVals = squeeze(EEGResults{idelta, iMonId}.ampDiff_grating(1,:,:,4,8)); % choosing electrodes above a certain cutoff
                allElecs = 1:size(EEGResults{idelta, iMonId}.ampDiff_grating,2);
                goodElecs = allElecs(allVals>cutoff);
                dataMerged.goodElecs{idelta, iMonId} = goodElecs;
            end
            
            clearvars temp_field temp_session tempIds tempGoodElecs
            temp_field = EEGResults{idelta, iMonId}.(name);
            temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
            tempIds = all(~isnan(temp_session),4); % removing extra electrodes - keeping only the good ones
            tempGoodElecs = temp_session(tempIds(:,1,1),:,:,:,:,:);
            dataCombine{iMonId} = tempGoodElecs(dataMerged.goodElecs{idelta, iMonId},:,:,:,:); %%% getting data in a single variable for both monkeys %%%
        end
        
        dataMergedAcrossMonkeys= cat(1,dataCombine{:}); 

        % taking average across electrodes
        clearvars N_elec meanMerged semMerged
        N_elec = size(dataMergedAcrossMonkeys,1);
        meanMerged = squeeze(mean(dataMergedAcrossMonkeys,1));
        semMerged = squeeze((std(dataMergedAcrossMonkeys,[],1))./sqrt(N_elec));
        NumElecs(idelta) = N_elec;
        
        clearvars combName semCombName 
        combName = [name '_mean'];
        dataMerged.(combName)(idelta,:,:,:,:) = meanMerged;
        
        semCombName = [name '_sem'];
        dataMerged.(semCombName)(idelta,:,:,:,:) = semMerged;
        
 
        if saveDataForEachMonkeySeparatelyFlag == 1
        %%% saving things for each monkey separately also %%%
        clearvars monkCombName1 monkCombName2 monkCombNameSem1 monkCombNameSem2
        NumElecsMonkeys(1,idelta) = size(dataCombine{1},1);
        monkCombName1 = [name '_mean_M1'];
        monkCombNameSem1 = [name '_sem_M1'];
        dataM1 = dataCombine{1};
        dataMerged.(monkCombName1)(idelta,:,:,:,:) = squeeze(mean(dataM1,1)); % averaging across Elecs
        dataMerged.(monkCombNameSem1)(idelta,:,:,:,:) = squeeze((std(dataM1,[],1))./sqrt(NumElecsMonkeys(1,idelta)));
        
        if size(EEGResults,2)>1
            NumElecsMonkeys(2,idelta) = size(dataCombine{2},1);
            monkCombName2 = [name '_mean_M2'];
            monkCombNameSem2 = [name '_sem_M2'];
            dataM2 = dataCombine{2};
            dataMerged.(monkCombName2)(idelta,:,:,:,:) = squeeze(mean(dataM2,1)); % averaging across Elecs
            dataMerged.(monkCombNameSem2)(idelta,:,:,:,:) = squeeze((std(dataM2,[],1))./sqrt(NumElecsMonkeys(2,idelta)));
        end
        end
    end
end
dataMerged.NumElecs_Small_BothMonkeysMerged = NumElecs;

if saveDataForEachMonkeySeparatelyFlag == 1
    dataMerged.NumElecs_M1 = NumElecsMonkeys(1,:);
    if size(EEGResults,2)>1
        dataMerged.NumElecs_M2 = NumElecsMonkeys(2,:);
    end
end

clearvars Results
end