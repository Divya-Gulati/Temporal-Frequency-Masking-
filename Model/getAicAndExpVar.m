function [akaikeInfoCrit,expVarAll] = getAicAndExpVar(folderSourceString,FileNames)


for iFileName = 1:length(FileNames)
    
    clearvars errorResidual estData Parameters expVar
    load(fullfile(folderSourceString,FileNames{iFileName}),'errorResidual','estData','Parameters','expVar');
     
     if iFileName == 1
         akaikeInfoCrit = cell(size(errorResidual,1),size(errorResidual,2));
         expVarAll = cell(size(errorResidual,1),size(errorResidual,2));
     end
 
    for iMonkey =  1:size(errorResidual,1)
        for idel = 1:size(errorResidual,2)
            for ielec = 1:size(errorResidual{iMonkey, idel},1)
                SSEd = errorResidual{iMonkey, idel} (ielec,1); % Sum of squared estimates
                elecData = estData{iMonkey, idel} (ielec,:,:,:);
                N = length(elecData(:)); % Number of observations
                K = size(Parameters{iMonkey, idel}  ,2)+1; % Number of parameters % including SSEd also as a free parameter
                akaikeInfoCrit{iMonkey,idel}(ielec,iFileName) = N*log(SSEd/N)+2*K+((2*K*(K+1))./(N-K-1));
                expVarAll{iMonkey,idel}(ielec,iFileName) = expVar{iMonkey, idel}(ielec,1);
            end
        end
    end
end

end