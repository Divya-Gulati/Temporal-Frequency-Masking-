function Figure2Data = getDataForFigure2_sessionWise(DataFileName_FullScreen,DataFileName_SmallStim,MonkeyNumber)
%%% loading full screen data file %%%%
clearvars Results
Results = load(DataFileName_FullScreen);
Results = Results.Results;
Results = Results(1, MonkeyNumber);  
allfieldNames_FS = fieldnames(Results{1,1});
fieldsTocombine_FS = [1:5 7];

for ifN = 1:length(fieldsTocombine_FS)

    clearvars name combName dataCombine dataMergedAcrossMonkeys
    name = cell2mat(allfieldNames_FS(fieldsTocombine_FS(ifN)));

    clearvars dataCombine
    dataCombine = cell(length(Results),2);
    
    for iMonId = 1:length(Results)
        clearvars temp_field temp_session 
        temp_field = cell2mat(Results{1, iMonId}.(name));
        temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
        
        for idelta = 1:size(temp_session,2)
            clearvars  tempdata tempIds tempGoodElecs
            tempdata = temp_session(:,idelta,:,:);
            tempIds = all(~isnan(tempdata),4); % removing extra electrodes - keeping only the good ones
            tempGoodElecs = tempdata(tempIds(:,1,1),:,:,:);
            dataCombine{iMonId,idelta} = tempGoodElecs; %%% getting data in a single variable for all monkeys %%%
            dataMerged.NumElecsEachMonkey_FS(idelta,iMonId) = size(tempGoodElecs,1);
        end
        
    end

    dataMergedAcrossMonkeys= arrayfun(@(col) cat(1, dataCombine{:, col}), 1:2, 'UniformOutput', false); % merging data across monkeys

    clearvars meanMerged semMerged
    for jdel = 1:size(dataMergedAcrossMonkeys,2)
        % taking average across electrodes
        clearvars N_elec 
        N_elec = size(dataMergedAcrossMonkeys{:,jdel},1);
        meanMerged(jdel,:,:) = squeeze(mean(dataMergedAcrossMonkeys{:,jdel},1));
        semMerged(jdel,:,:) = squeeze((std(dataMergedAcrossMonkeys{:,jdel},[],1))./sqrt(N_elec));
        dataMerged.NumElecs_FS(jdel,:) = N_elec;
    end
    
    combName = [name '_mean_FS'];
    dataMerged.(combName) = meanMerged;

    semCombName = [name '_sem_FS'];
    dataMerged.(semCombName) = semMerged;

end
dataMerged.freqVals_FS = Results{1, 1}.parameters{1, 1}.freqbins;

%%% loading small stimulus data %%%
clearvars Results
Results = load(DataFileName_SmallStim);
Results = Results.Results(:,MonkeyNumber); % taking only microelectrode data
allfieldNames_Small = fieldnames(Results{1,1});
fieldsTocombine_Small =[3:5 9:10];

for ifN = 1:length(fieldsTocombine_Small)

    for idelta = 1:size(Results,1) % across rows delta is changing and across columns monkeys
        clearvars name dataMergedAcrossMonkeys addName
        if idelta == 1; addName = 'parallel_small'; elseif idelta == 2; addName = 'orthogonal_small';  end

        name = cell2mat(allfieldNames_Small(fieldsTocombine_Small(ifN)));

        clearvars dataCombine
        dataCombine = cell(1,size(Results,2));
        for iMonId = 1:size(Results,2)
            clearvars temp_field temp_session tempIds tempGoodElecs
            temp_field = Results{idelta, iMonId}.(name);
            temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
            tempIds = all(~isnan(temp_session),5); % removing extra electrodes - keeping only the good ones
            tempGoodElecs = temp_session(tempIds(:,1,1),:,:,:,:);
            dataCombine{iMonId} = tempGoodElecs; %%% getting data in a single variable for both monkeys %%%
            NumElecsEachMonkey(idelta,iMonId) = size(tempGoodElecs,1);
        end

        dataMergedAcrossMonkeys= cat(1,dataCombine{:}); 
        % taking average across electrodes
        clearvars N_elec meanMerged semMerged
        N_elec = size(dataMergedAcrossMonkeys,1);
        meanMerged = squeeze(mean(dataMergedAcrossMonkeys,1));
        semMerged = squeeze((std(dataMergedAcrossMonkeys,[],1))./sqrt(N_elec));

        clearvars combName1 combName2 semCombName1 semCombName2
        combName1 = [name '_mean_' addName];
        dataMerged.(combName1) = meanMerged;

        semCombName1 = [name '_sem_' addName];
        dataMerged.(semCombName1) = semMerged;

        if strcmpi(name, 'changeInAmpSubtract')
            NumElecs(idelta) = N_elec;
        end
        
    end
end
dataMerged.freqVals_Small = Results{1, 1}.parameters{1, 1}.freqbins;
dataMerged.NumElecs_Small = NumElecs;
dataMerged.NumElecEachMonkey_small = NumElecsEachMonkey;

Figure2Data = dataMerged;
clearvars Results
end