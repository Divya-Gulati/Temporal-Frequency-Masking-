function [startPoint,lowerbound,upperbound] = getStartValsDualTFModel(numTFs,modelNum,Delta,MonkeyID)

if modelNum==1 % Free parameters sigma, exponent, supression values; Untuned normalization model- Salelkar and Ray 2020
    
    sigmaStart = 0.25;
    LampStart = 2.5;
    lowerbound_supression= zeros(1,numTFs);
    upperbound_supression= 35*ones(1,numTFs);
    SuppressionVals = ones(1,numTFs);
    
    startPoint = [sigmaStart LampStart SuppressionVals];
    lowerbound = [0.1 1 lowerbound_supression];
    upperbound = [4 15 upperbound_supression];
    
elseif modelNum==2
    
    if strcmpi(MonkeyID,'M3')
        
        lowerbound = [0 1 1 0 0 0.1];
        upperbound = [4 15 40 Inf Inf 1];
        
        if Delta == 0
            LampStart = 4;
            sigmaStart = 0.3;
            cutOffStart = 7;
            alpha1Start = 6;
            alpha2Start = 0.00000000000000001;
            scalingFactor = 0.65;
        elseif Delta == 90
            LampStart = 5;
            sigmaStart = 0.55;
            cutOffStart = 7;
            alpha1Start = 0.1;
            alpha2Start = 2;
            scalingFactor = 0.9;
        else
            LampStart = 5;
            sigmaStart = 0.7;
            cutOffStart = 8;
            alpha1Start = 0.1;
            alpha2Start = 4;
            scalingFactor = 0.9;
        end
        
    elseif strcmpi(MonkeyID,'M1')
        lowerbound = [0.1 1 1 0 0 0.1];
        upperbound = [4 15 40 Inf Inf 1];
        
        if Delta == 0
            LampStart = 3;
            sigmaStart = 0.35;
            cutOffStart = 7.5;
            alpha1Start = 12;
            alpha2Start = 0.00000000000000001;
            scalingFactor =0.65;
        elseif Delta == 90
            LampStart = 3;
            sigmaStart = 0.35;
            cutOffStart = 24;
            alpha1Start =0.00000000000000001;
            alpha2Start = 10;
            scalingFactor = 0.7;
        end
        
    elseif strcmpi(MonkeyID,'M2')
        lowerbound = [0.1 1 1 0 0 0.1];
        upperbound = [4 15 40 Inf Inf 1];
        
        if Delta == 0
            LampStart = 4;
            sigmaStart = 0.25;
            cutOffStart = 7.5;
            alpha1Start = 6;
            alpha2Start = 0.00000000000000001;
            scalingFactor =0.65;
        elseif Delta == 90
            LampStart = 4;
            sigmaStart = 0.35;
            cutOffStart = 25;
            alpha1Start = 0.00000000000000001;
            alpha2Start = 20;
            scalingFactor = 0.7;
        else
            LampStart = 2.5;
            sigmaStart = 0.3;
            cutOffStart = 25;
            alpha1Start = 0.000000000000000001;
            alpha2Start = 6;
            scalingFactor = 0.75;
        end
    end
    
    startPoint = [sigmaStart LampStart cutOffStart alpha1Start alpha2Start scalingFactor];
    
end

end