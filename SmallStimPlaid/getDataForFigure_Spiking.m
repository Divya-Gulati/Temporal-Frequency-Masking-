function dataMerged = getDataForFigure_Spiking(DataFileName,fieldsTocombine,saveDataForEachMonkeySeparatelyFlag)
%%% loading full screen data file %%%%
clearvars Results
Results = load(DataFileName);
Results = Results.SpikeResults;

for iSpikeLen = 1:size(Results,1)
    
    allfieldNames_Small = fieldnames(Results{iSpikeLen,1,1});
    fieldsTocombine_Small = fieldsTocombine;
    
    for ifN = 1:length(fieldsTocombine_Small)
        
        for idelta = 1:size(Results,2) % across rows delta is changing and across columns monkeys
            clearvars name dataMergedAcrossMonkeys addName
            
            name = cell2mat(allfieldNames_Small(fieldsTocombine_Small(ifN)));
            
            dataMergedAcrossMonkeys= cat(1,Results{iSpikeLen,idelta, 1}.(name),Results{iSpikeLen,idelta, 2}.(name));
            
            % taking average across electrodes
            clearvars N_elec meanMerged semMerged
            N_elec = size(dataMergedAcrossMonkeys,1);
            meanMerged = squeeze(mean(dataMergedAcrossMonkeys,1,'omitNaN'));
            semMerged = squeeze((std(dataMergedAcrossMonkeys,[],1,'omitNaN'))./sqrt(N_elec));
            NumElecs(iSpikeLen,idelta) = N_elec;
            
            clearvars combName1 combName2 semCombName1 semCombName2
            combName1 = [name '_mean'];
            dataMerged.(combName1)(iSpikeLen,idelta,:,:,:,:) = meanMerged;
            
            semCombName1 = [name '_sem'];
            dataMerged.(semCombName1)(iSpikeLen,idelta,:,:,:,:) = semMerged;
            
            if saveDataForEachMonkeySeparatelyFlag == 1
                %%% saving things for each monkey separately also %%%
                clearvars monkCombName1 monkCombName2 monkCombNameSem1 monkCombNameSem2 monkCombName3 monkCombNameSem3
                monkCombName1 = [name '_mean_M1'];
                monkCombNameSem1 = [name '_sem_M1'];
                monkCombName2 = [name '_mean_M2'];
                monkCombNameSem2 = [name '_sem_M2'];
                dataM1 = Results{iSpikeLen,idelta, 1}.(name);
                dataM2 = Results{iSpikeLen,idelta, 2}.(name);
                NumElecsM1(iSpikeLen,idelta,:) = size(dataM1,1);
                NumElecsM2(iSpikeLen,idelta) = size(dataM2,1);
                
                
                if strcmpi(name,'ampDiff_spike_plaid')
                    maxdataM1 = max(dataM1,[],[2 3 4]);
                    dataM1 = dataM1./maxdataM1;
                    maxdataM2 = max(dataM2,[],[2 3 4]);
                    dataM2 = dataM2./maxdataM2;
                end
                
                dataMerged.(monkCombName1)(iSpikeLen,idelta,:,:,:,:) = squeeze(mean(dataM1,1)); % averaging across Elecs
                dataMerged.(monkCombNameSem1)(iSpikeLen,idelta,:,:,:,:) = squeeze((std(dataM1,[],1))./sqrt(NumElecsM1(iSpikeLen,idelta)));
                dataMerged.(monkCombName2)(iSpikeLen,idelta,:,:,:,:) = squeeze(mean(dataM2,1)); % averaging across Elecs
                dataMerged.(monkCombNameSem2)(iSpikeLen,idelta,:,:,:,:) = squeeze((std(dataM2,[],1))./sqrt(NumElecsM2(iSpikeLen,idelta)));
            end
        end
    end
    dataMerged.NumElecs_Small_BothMonkeysMerged = NumElecs;
    
    
    % change in Amp of average PSTH %
    xFreqVals = Results{1,1, 1}.parameters{1,1, 1}.PsthFreqVals;
    xFreq = round(xFreqVals) == 2*Results{1,1, 1}.parameters{1,1, 1}.tValsUnique;
    dataMerged.PsthSpikeAmpChange = dataMerged.PsthfftST_plaid_mean(:,:,:,:,:,xFreq)- dataMerged.PsthfftBL_plaid_mean(:,:,:,:,:,xFreq);
    
    
    if saveDataForEachMonkeySeparatelyFlag == 1
        dataMerged.NumElecs_M1 = NumElecsM1;
        dataMerged.NumElecs_M2 = NumElecsM2;
        dataMerged.PsthSpikeAmpChangeM1 =dataMerged.PsthfftST_plaid_mean_M1(:,:,:,:,:,xFreq)- dataMerged.PsthfftBL_plaid_mean_M1(:,:,:,:,:,xFreq);
        dataMerged.PsthSpikeAmpChangeM2 =dataMerged.PsthfftST_plaid_mean_M2(:,:,:,:,:,xFreq)- dataMerged.PsthfftBL_plaid_mean_M2(:,:,:,:,:,xFreq);
    end
end
clearvars Results
end