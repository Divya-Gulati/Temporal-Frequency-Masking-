function Figure2Data = getDataForFigure2_sessionWise(folderSourceString)
%%% loading full screen data file %%%%
clearvars Results
Results = load(fullfile(folderSourceString,'FullScreen_HighRMSLFP_sessionWise_Microelectrode.mat'));
Results = Results.Results;
allfieldNames_FS = fieldnames(Results{1,1});
fieldsTocombine_FS = [1:5 7];

for ifN = 1:length(fieldsTocombine_FS)

    clearvars name combName dataCombine dataMergedAcrossMonkeys
    name = cell2mat(allfieldNames_FS(fieldsTocombine_FS(ifN)));

    clearvars dataCombine
    dataCombine = cell(1,length(Results));
    for iMonId = 1:length(Results)
        clearvars temp_field temp_session tempIds tempGoodElecs
        temp_field = cell2mat(Results{1, iMonId}.(name));
        temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
        tempIds = all(~isnan(temp_session),4); % removing extra electrodes - keeping only the good ones
        tempGoodElecs = temp_session(tempIds(:,1,1),:,:,:);
        dataCombine{iMonId} = tempGoodElecs; %%% getting data in a single variable for both monkeys %%%
    end

    dataMergedAcrossMonkeys= cat(1,dataCombine{:}); % merging dataacross monkeys

    % taking average across electrodes
    clearvars N_elec meanMerged semMerged
    N_elec = size(dataMergedAcrossMonkeys,1);
    meanMerged = squeeze(mean(dataMergedAcrossMonkeys,1));
    semMerged = squeeze((std(dataMergedAcrossMonkeys,[],1))./sqrt(N_elec));

    combName = [name '_mean_FS'];
    dataMerged.(combName) = meanMerged;

    semCombName = [name '_sem_FS'];
    dataMerged.(semCombName) = semMerged;

    if strcmpi(name, 'ChangeInAmpNeg')
        dataMerged.NumElecsEachMonkey_FS = [size(dataCombine{1,1},1) size(dataCombine{1, 2},1)];
    end

end
dataMerged.freqVals_FS = Results{1, 1}.parameters{1, 1}.freqbins;
dataMerged.NumElecs_FS = N_elec;

%%% loading small stimulus data %%%
clearvars Results
Results = load(fullfile(folderSourceString,'SmallStimPlaid_HighRMSLFP_sessionWise_Microelectrode.mat'));
Results = Results.Results(:,1:end-1); % taking only microelectrode data

allfieldNames_Small = fieldnames(Results{1,1});
fieldsTocombine_Small =[3:5 9:10];

for ifN = 1:length(fieldsTocombine_Small)

    for idelta = 1:size(Results,1) % across rows delta is changing and across columns monkeys
        clearvars name dataMergedAcrossMonkeys addName
        if idelta == 1; addName = 'parallel_small'; elseif idelta == 2; addName = 'orthogonal_small';  end

        name = cell2mat(allfieldNames_Small(fieldsTocombine_Small(ifN)));

        clearvars dataCombine
        dataCombine = cell(1,length(Results));
        for iMonId = 1:length(Results)
            clearvars temp_field temp_session tempIds tempGoodElecs
            temp_field = Results{idelta, iMonId}.(name);
            temp_session = squeeze(mean(temp_field,1,'omitNaN')); % mean of electrodes across sessions
            tempIds = all(~isnan(temp_session),5); % removing extra electrodes - keeping only the good ones
            tempGoodElecs = temp_session(tempIds(:,1,1),:,:,:,:);
            dataCombine{iMonId} = tempGoodElecs; %%% getting data in a single variable for both monkeys %%%
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
            NumElecsEachMonkey(idelta,:) = [size(dataCombine{1},1) size(dataCombine{2},1)];
        end
        
    end
end
dataMerged.freqVals_Small = Results{1, 1}.parameters{1, 1}.freqbins;
dataMerged.NumElecs_Small = NumElecs;
dataMerged.NumElecEachMonkey_small = NumElecsEachMonkey;

Figure2Data = dataMerged;
clearvars Results
end