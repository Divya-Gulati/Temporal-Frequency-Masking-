function [taskNames,monkeyNames,expDates,protocolNames,stimTypes,arrayTypes,arraysToSave] = allProtocolsMonkeys

% Target TF -15;Delta 0; Con 0 6.25 12.5 25
taskNames{1} = 'DualTFFullScreen';   monkeyNames{1} = 'alpaH'; expDates{1} = '070220';  protocolNames{1} = 'GRF_001';  stimTypes{1} = 4; arrayTypes{1} = 'ECoG';  arraysToSave{1} = {[]}; 
taskNames{2} = 'DualTFFullScreen';   monkeyNames{2} = 'alpaH'; expDates{2} = '210220';  protocolNames{2} = 'GRF_001';  stimTypes{2} = 4; arrayTypes{2} = 'ECoG';  arraysToSave{2} = {[]}; 

% Target TF -15;Delta 90; Con 0 6.25 12.5 25
taskNames{3} = 'DualTFFullScreen';   monkeyNames{3} = 'alpaH'; expDates{3} = '050220';  protocolNames{3} = 'GRF_001';  stimTypes{3} = 4; arrayTypes{3} = 'ECoG';  arraysToSave{3} = {[]}; 
taskNames{4} = 'DualTFFullScreen';   monkeyNames{4} = 'alpaH'; expDates{4} = '180220';  protocolNames{4} = 'GRF_001';  stimTypes{4} = 4; arrayTypes{4} = 'ECoG';  arraysToSave{4} = {[]}; 
taskNames{5} = 'DualTFFullScreen';   monkeyNames{5} = 'alpaH'; expDates{5} = '190220';  protocolNames{5} = 'GRF_001';  stimTypes{5} = 4; arrayTypes{5} = 'ECoG';  arraysToSave{5} = {[]}; 

% Target TF -15;Delta 45; Con 0 6.25 12.5 25
taskNames{6} = 'DualTFFullScreen';   monkeyNames{6} = 'alpaH'; expDates{6} = '060220';  protocolNames{6} = 'GRF_001';  stimTypes{6} = 4; arrayTypes{6} = 'ECoG';  arraysToSave{6} = {[]}; 
taskNames{7} = 'DualTFFullScreen';   monkeyNames{7} = 'alpaH'; expDates{7} = '200220';  protocolNames{7} = 'GRF_001';  stimTypes{7} = 4; arrayTypes{7} = 'ECoG';  arraysToSave{7} = {[]}; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Target TF -15; Con- 0 50; Delta- 0 90
taskNames{8} = 'DualTFFullScreen';  monkeyNames{8} = 'coco';    expDates{8} = '100421';     protocolNames{8} = 'GRF_002';     stimTypes{8} = 3;  arrayTypes{8} = 'Single'; arraysToSave{8} = {[]}; 

% Target TF -15; Con 0 6.25 12.5 25
taskNames{9} = 'DualTFSmall';          monkeyNames{9} = 'coco';    expDates{9} = '280321';     protocolNames{9} = 'GRF_004';     stimTypes{9} = 4;   arrayTypes{9} = 'Single'; arraysToSave{9} = {[]}; %Delta 0; 
taskNames{10} ='DualTFSmall';        monkeyNames{10} = 'coco';   expDates{10} = '290321';  protocolNames{10} = 'GRF_003';   stimTypes{10} = 4; arrayTypes{10} = 'Single'; arraysToSave{10} = {[]}; %Delta 90;

% 5 Con 8TF
taskNames{11} = 'ConTFSize';           monkeyNames{11} = 'coco';   expDates{11} = '220421';  protocolNames{11} = 'GRF_002';   stimTypes{11} = 4; arrayTypes{11} = 'Single'; arraysToSave{11} = {[]}; % Full screen stimulus
taskNames{12} = 'ConTFSize';           monkeyNames{12} = 'coco';   expDates{12} = '220421';  protocolNames{12} = 'GRF_003';   stimTypes{12} = 4; arrayTypes{12} = 'Single'; arraysToSave{12} = {[]}; % Small Stimulus

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Target TF -15; Con- 0 50; Delta- 0 90
taskNames{13} = 'DualTFFullScreen';  monkeyNames{13} = 'dona';   expDates{13} = '020523';  protocolNames{13} = 'GRF_002';   stimTypes{13} = 3;  arrayTypes{13} = 'Dual'; arraysToSave{13} = 'V1'; 
taskNames{14} = 'DualTFFullScreen';  monkeyNames{14} = 'dona';   expDates{14} = '160823';  protocolNames{14} = 'GRF_003';   stimTypes{14} = 3;  arrayTypes{14} = 'Dual'; arraysToSave{14} = 'V1'; 

% Target TF -15; Delta 0; Con 0 6.25 12.5 25
taskNames{15} = 'DualTFSmall';          monkeyNames{15} = 'dona';   expDates{15} = '280623';  protocolNames{15} = 'GRF_002';   stimTypes{15} = 4;  arrayTypes{15} = 'Dual'; arraysToSave{15} = 'V1'; 
taskNames{16} = 'DualTFSmall';          monkeyNames{16} = 'dona';   expDates{16} = '280423';  protocolNames{16} = 'GRF_004';   stimTypes{16} = 4;  arrayTypes{16} = 'Dual'; arraysToSave{16} = 'V1'; 
taskNames{17} = 'DualTFSmall';          monkeyNames{17} = 'dona';   expDates{17} = '060523';  protocolNames{17} = 'GRF_003';   stimTypes{17} = 4;  arrayTypes{17} = 'Dual'; arraysToSave{17} = 'V1'; 
taskNames{18} ='DualTFSmall';           monkeyNames{18} = 'dona';   expDates{18} = '100523';  protocolNames{18} = 'GRF_002';   stimTypes{18} = 4;  arrayTypes{18} = 'Dual'; arraysToSave{18} = 'V1'; 
taskNames{19} = 'DualTFSmall';          monkeyNames{19} = 'dona';   expDates{19} = '241223';  protocolNames{19} = 'GRF_002';   stimTypes{19} = 4;  arrayTypes{19} = 'Dual'; arraysToSave{19} = 'V1'; 
taskNames{20} = 'DualTFSmall';          monkeyNames{20} = 'dona';   expDates{20} = '261223';  protocolNames{20} = 'GRF_002';   stimTypes{20} = 4;  arrayTypes{20} = 'Dual'; arraysToSave{20} = 'V1'; 
taskNames{21} = 'DualTFSmall';          monkeyNames{21} = 'dona';   expDates{21} = '250423';  protocolNames{21} = 'GRF_003';   stimTypes{21} = 4;  arrayTypes{21} = 'Dual'; arraysToSave{21} = 'V1'; 
taskNames{22} = 'DualTFSmall';          monkeyNames{22} = 'dona';   expDates{22} = '010623';  protocolNames{22} = 'GRF_002';   stimTypes{22} = 4;  arrayTypes{22} = 'Dual'; arraysToSave{22} = 'V1'; 

% Target TF -15; Delta 90; Con 0 6.25 12.5 25
taskNames{23} ='DualTFSmall';           monkeyNames{23} = 'dona';   expDates{23} = '140523';  protocolNames{23} = 'GRF_002';   stimTypes{23} = 4;  arrayTypes{23} = 'Dual'; arraysToSave{23} = 'V1'; 
taskNames{24} = 'DualTFSmall';          monkeyNames{24} = 'dona';   expDates{24} = '190523';  protocolNames{24} = 'GRF_002';   stimTypes{24} = 4;  arrayTypes{24} = 'Dual'; arraysToSave{24} = 'V1'; 
taskNames{25} = 'DualTFSmall';          monkeyNames{25} = 'dona';   expDates{25} = '230523';  protocolNames{25} = 'GRF_002';   stimTypes{25} = 4;  arrayTypes{25} = 'Dual'; arraysToSave{25} = 'V1'; 
taskNames{26} = 'DualTFSmall';          monkeyNames{26} = 'dona';   expDates{26} = '270523';  protocolNames{26} = 'GRF_002';   stimTypes{26} = 4;  arrayTypes{26} = 'Dual'; arraysToSave{26} = 'V1'; 

% Target TF -15; Delta 45; Con 0 6.25 12.5 25
taskNames{27} = 'DualTFSmall';          monkeyNames{27} = 'dona';   expDates{27} = '020623';  protocolNames{27} = 'GRF_002';   stimTypes{27} = 4;  arrayTypes{27} = 'Dual'; arraysToSave{27} = 'V1'; 
taskNames{28} ='DualTFSmall';           monkeyNames{28} = 'dona';   expDates{28} = '060623';  protocolNames{28} = 'GRF_002';   stimTypes{28} = 4;  arrayTypes{28} = 'Dual'; arraysToSave{28} = 'V1'; 
taskNames{29} = 'DualTFSmall';          monkeyNames{29} = 'dona';   expDates{29} = '100623';  protocolNames{29} = 'GRF_002';   stimTypes{29} = 4;  arrayTypes{29} = 'Dual'; arraysToSave{29} = 'V1'; 
taskNames{30} = 'DualTFSmall';          monkeyNames{30} = 'dona';   expDates{30} = '110623';  protocolNames{30} = 'GRF_002';   stimTypes{30} = 4;  arrayTypes{30} = 'Dual'; arraysToSave{30} = 'V1'; 

% Both Full screen and Small Stimulus  5 Con 8TF
taskNames{31} = 'ConTFSize';              monkeyNames{31} = 'dona';   expDates{31} = '060723';  protocolNames{31} = 'GRF_001';   stimTypes{31} = 3;  arrayTypes{31} = 'Dual'; arraysToSave{31} = 'V1'; 
% protocols were combined together offline - as monkey was stopping in the middle
% of the task - that's why a long name
taskNames{32} = 'ConTFSize';              monkeyNames{32} = 'dona';   expDates{32} = '120624';  protocolNames{32} = 'GRF_002_GRF_003_GRF_004_GRF_005_GRF_006';   stimTypes{32} = 3; arrayTypes{32} = 4;arraysToSave{32} = 'V1'; 

end