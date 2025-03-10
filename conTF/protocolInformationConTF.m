% protocolInformation for conTF protocols

function  [expDates,protocolNames,arrayType,timeRange,arraysToSave,TotalElecs,conToSave,tfToSave] = protocolInformationConTF(monkeyName,gridType)

%%%%%%%%%%%%%%%%%%%%%% coco, Microelectrode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(monkeyName,'coco') && strcmpi(gridType,'Microelectrode')
    arrayType = 'Single';
    timeRange = [0.25 0.75];
    arraysToSave = [];
    expDates{1} = '220421'; protocolNames{1} = 'GRF_003'; TotalElecs{1} =  {1:96};% Small Stimulus
    expDates{2} = '220421'; protocolNames{2} = 'GRF_002'; TotalElecs{2} =  {1:96}; % Full Screen
end

%%%%%%%%%%%%%%%%%%%%%% dona, Microelectrode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(monkeyName,'dona') && strcmpi(gridType,'Microelectrode')
    arrayType = 'Dual';
    timeRange = [0.25 1.25];arraysToSave = 'V1';
    % Both FullScreen and Small Stimulus in same protocol
    expDates{1} = '060723'; protocolNames{1} = 'GRF_001';  TotalElecs{1} = {(1:48);(49:96)}; % V1 and V4 order
    expDates{2} = '120624'; protocolNames{2} = 'GRF_002_GRF_003_GRF_004_GRF_005_GRF_006'; % special protocol required for merging
    TotalElecs{2} = {(1:48);(49:96)};
end


end
