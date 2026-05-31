
clear; clc; close all;
runMode = "twoStage";

% Colors
colPar  = [0.7 0.03 0.3];   % parallel
colOrth = [1 0.54 0.15];    % orthogonal

Fs = 2000;
T  = 0.8;
timeVals = 0:(1/Fs):(T-(1/Fs));

TF1 = 15;
% MF  = [1:2:13 17:2:29];
MF  = [1 3 7 9 11 13 17:2:29];
deltaOri = [0 90];

Amp = 1;
x1  = Amp * sin(2*pi*TF1*timeVals);

%% =========================
% Model parameters
%% =========================
Z1   = 1;
Z2   = 1;
k2   = 1;
n1   = 1;
n2   = 1;
Aout = 1;
drive1 = Amp;

%% =========================
% Filter configurations
%% =========================
cfgLabels = {
    sprintf('Stage 1: 7/23\nStage 2: 30/30')
    sprintf('Stage 1: 30/30\nStage 2: 7/23')
    sprintf('Stage 1: 7/23\nStage 2: 7/23')
    };

s1Cuts = [
    7 23
    30 30
    7 23
    ];

s2Cuts = [
    30 30
    7 23
    7 23
    ];

%% =========================
% Storage
%% =========================
UntunedPool1    = cell(3,1);
UntunedPool2    = cell(3,1);
UntunedR1       = cell(3,1);
UntunedResponse = cell(3,1);

TunedPool1    = cell(3,1);
TunedPool2    = cell(3,1);
TunedR1       = cell(3,1);
TunedResponse = cell(3,1);

%% =========================
% Run all conditions
%% =========================
for icfg = 1:3

    [B1,A1]   = butter(2, s1Cuts(icfg,1)/(Fs/2), 'low');
    [B2,A2]   = butter(2, s1Cuts(icfg,2)/(Fs/2), 'low');
    [B1b,A1b] = butter(2, s2Cuts(icfg,1)/(Fs/2), 'low');
    [B2b,A2b] = butter(2, s2Cuts(icfg,2)/(Fs/2), 'low');

    for itune = 1:2

        if itune == 1
            alpha_s1_parallel = [1 1];
            alpha_s1_orth     = [1 1];
        else
            alpha_s1_parallel = [1 0];
            alpha_s1_orth     = [0 1];
        end

        alpha_s2_parallel = [1 0];
        alpha_s2_orth     = [0 1];

        pool1Mat    = zeros(2, length(MF));
        pool2Mat    = zeros(2, length(MF));
        R1Mat       = zeros(2, length(MF));
        ResponseMat = zeros(2, length(MF));

        for iori = 1:length(deltaOri)

            if deltaOri(iori) == 0
                alpha_stage1 = alpha_s1_parallel;
                alpha_stage2 = alpha_s2_parallel;
            else
                alpha_stage1 = alpha_s1_orth;
                alpha_stage2 = alpha_s2_orth;
            end

            alpha1_s1 = alpha_stage1(1);
            alpha2_s1 = alpha_stage1(2);

            alpha1_s2 = alpha_stage2(1);
            alpha2_s2 = alpha_stage2(2);

            for iMF = 1:length(MF)

                x2 = Amp * sin(2*pi*MF(iMF)*timeVals);

                % ---------- Stage 1 ----------
                I1_pre = (x1 + x2).^2;
                I2_pre = (x1.^2 + x2.^2);

                I1 = I1_pre - mean(I1_pre);
                I2 = I2_pre - mean(I2_pre);

                LPF_I1 = filtfilt(B1,A1,I1);
                LPF_I2 = filtfilt(B2,A2,I2);

                I_stage1 = alpha1_s1.*LPF_I1 + alpha2_s1.*LPF_I2;
                pool1 = mean(I_stage1.^2);

                R1 = (drive1^n1) / (drive1^n1 + (Z1 + pool1)^n1);

                pool1Mat(iori,iMF) = pool1;
                R1Mat(iori,iMF)    = R1;

                % ---------- Stage 2 ----------
                if runMode == "twoStage"
                     x1_stage1 = R1.* x1;

                    I1_2_pre = (x1_stage1 + x2).^2;
                    I2_2_pre = (x1_stage1.^2 + x2.^2);

                    I1_2 = I1_2_pre - mean(I1_2_pre);
                    I2_2 = I2_2_pre - mean(I2_2_pre);

                    LPF_I1_2 = filtfilt(B1b,A1b,I1_2);
                    LPF_I2_2 = filtfilt(B2b,A2b,I2_2);

                    I_stage2 = alpha1_s2.*LPF_I1_2 + alpha2_s2.*LPF_I2_2;
                    pool2 = mean(I_stage2.^2);

                    R1_50 = Z2 + k2*pool2;
                    z = Aout * (R1^n2) / (R1^n2 + R1_50^n2);

                    pool2Mat(iori,iMF)    = pool2;
                    ResponseMat(iori,iMF) = z;
                else
                    pool2Mat(iori,iMF)    = 0;
                    ResponseMat(iori,iMF) = R1;
                end
            end
        end

        if itune == 1
            UntunedPool1{icfg}    = pool1Mat;
            UntunedPool2{icfg}    = pool2Mat;
            UntunedR1{icfg}       = R1Mat;
            UntunedResponse{icfg} = ResponseMat;
        else
            TunedPool1{icfg}    = pool1Mat;
            TunedPool2{icfg}    = pool2Mat;
            TunedR1{icfg}       = R1Mat;
            TunedResponse{icfg} = ResponseMat;
        end
    end
end

%% =========================
% Common y-limits across both panels
%% =========================
allCol1 = [];
allCol2 = [];
allCol3 = [];
allCol4 = [];

for icfg = 1:3
    allCol1 = [allCol1, UntunedPool1{icfg}(1,:), UntunedPool1{icfg}(2,:), TunedPool1{icfg}(1,:), TunedPool1{icfg}(2,:)];
    allCol2 = [allCol2, UntunedPool2{icfg}(1,:), UntunedPool2{icfg}(2,:), TunedPool2{icfg}(1,:), TunedPool2{icfg}(2,:)];
    allCol3 = [allCol3, UntunedR1{icfg}(1,:),    UntunedR1{icfg}(2,:),    TunedR1{icfg}(1,:),    TunedR1{icfg}(2,:)];
    allCol4 = [allCol4, UntunedResponse{icfg}(1,:), UntunedResponse{icfg}(2,:), TunedResponse{icfg}(1,:), TunedResponse{icfg}(2,:)];
end

min1 = min(allCol1); max1 = max(allCol1); pad1 = 0.08*(max1-min1 + eps); yl1 = [min1-pad1 max1+pad1];
min2 = min(allCol2); max2 = max(allCol2); pad2 = 0.08*(max2-min2 + eps); yl2 = [min2-pad2 max2+pad2];
min3 = min(allCol3); max3 = max(allCol3); pad3 = 0.08*(max3-min3 + eps); yl3 = [min3-pad3 max3+pad3];
min4 = min(allCol4); max4 = max(allCol4); pad4 = 0.08*(max4-min4 + eps); yl4 = [min4-pad4 max4+pad4];

%% =========================
% Figure
%% =========================
figure('Color','w','Position',[100 40 1100 1600]);

% Top panel: untuned
gridTop = [0.14 0.54 0.78 0.40];
[plotHandlesTop,~] = getPlotHandles(3,4,gridTop,0.05,0.05,0);

% Bottom panel: tuned
gridBottom = [0.14 0.06 0.78 0.40];
[plotHandlesBottom,~] = getPlotHandles(3,4,gridBottom,0.05,0.05,0);

% Panel labels
annotation('textbox',[0.045 0.96 0.25 0.03],'String','Untuned stage 1', ...
    'LineStyle','none','FontWeight','bold','FontSize',14,'FontName','Courier');
annotation('textbox',[0.045 0.47 0.25 0.03],'String','Tuned stage 1', ...
    'LineStyle','none','FontWeight','bold','FontSize',14,'FontName','Courier');

%% =========================
% Plot top panel (untuned)
%% =========================
for icfg = 1:3

    P1   = UntunedPool1{icfg};
    P2   = UntunedPool2{icfg};
    R1m  = UntunedR1{icfg};
    Resp = UntunedResponse{icfg};

    % Column 1: Pool1
    axes(plotHandlesTop(icfg,1));
    plot(MF, P1(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, P1(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl1); grid off; box off;
    ylabel('Pool1');
    if icfg == 1, title('Suppression - Pool1','FontName','Courier','FontSize',12); end

    % Column 2: Pool2
    axes(plotHandlesTop(icfg,2));
    plot(MF, P2(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, P2(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl2); grid off; box off;
    ylabel('Pool2');
    if icfg == 1, title('Supression - Pool2','FontName','Courier','FontSize',12); end

    % Column 3: R1
    axes(plotHandlesTop(icfg,3));
    plot(MF, R1m(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, R1m(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl3); grid off; box off;
    ylabel('R1');
    if icfg == 1, title('Stage-1 output R1','FontName','Courier','FontSize',12); end

    % Column 4: Final response
    axes(plotHandlesTop(icfg,4));
    plot(MF, Resp(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, Resp(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl4); grid off; box off;
    ylabel('Final response');
    if icfg == 1
        title('Final response','FontName','Courier','FontSize',12);
        legend('Parallel','Orthogonal','Location','best');
    end
end

%% =========================
% Plot bottom panel (tuned)
%% =========================
for icfg = 1:3

    P1   = TunedPool1{icfg};
    P2   = TunedPool2{icfg};
    R1m  = TunedR1{icfg};
    Resp = TunedResponse{icfg};

    % Column 1: Pool1
    axes(plotHandlesBottom(icfg,1));
    plot(MF, P1(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, P1(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl1); grid off; box off;
    ylabel('Pool1');
    if icfg == 3
        xlabel('Temporal Frequency of Mask (Hz)');
    end

    % Column 2: Pool2
    axes(plotHandlesBottom(icfg,2));
    plot(MF, P2(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, P2(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl2); grid off; box off;
    ylabel('Pool2');
    if icfg == 3
        xlabel('Temporal Frequency of Mask (Hz)');
    end

    % Column 3: R1
    axes(plotHandlesBottom(icfg,3));
    plot(MF, R1m(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, R1m(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl3); grid off; box off;
    ylabel('R1');
    if icfg == 3
        xlabel('Temporal Frequency of Mask (Hz)');
    end

    % Column 4: Final response
    axes(plotHandlesBottom(icfg,4));
    plot(MF, Resp(1,:), 'o-','LineWidth',1.8,'Color',colPar); hold on;
    plot(MF, Resp(2,:), 's--','LineWidth',1.8,'Color',colOrth);
    ylim(yl4); grid off; box off;
    ylabel('Final response');
    if icfg == 3
        xlabel('Temporal Frequency of Mask (Hz)');
    end
end

%% =========================
%  labels
%% =========================


for icfg = 1:3
    axes(plotHandlesTop(icfg,1));
    text (-0.42, 0.5,cfgLabels{icfg},'Units','normalized',...
        'Rotation',90,'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',11);

    axes(plotHandlesBottom(icfg,1));
    text (-0.42, 0.5,cfgLabels{icfg},'Units','normalized',...
        'Rotation',90,'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',11);

end

annotation(gcf,'textarrow',...
    [0.025 0.1] ,[0.963 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');
annotation(gcf,'textarrow',...
    [0.03 0.1] ,[0.486 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'Fontname','courier');