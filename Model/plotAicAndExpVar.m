function plotAicAndExpVar (akaikeInfoCrit,expVarAll)

% merging data across monkeys
clearvars AIC expVarVals
for jdel = 1:size(akaikeInfoCrit,2)
    AIC{jdel} = vertcat(akaikeInfoCrit{:,jdel});
    expVarVals{jdel} = vertcat(expVarAll{:,jdel});
end

f = figure;
f.WindowState = 'maximized';

plotHandles_a= getPlotHandles(1,1,[0.045 0.11 0.32 0.6],0.011,0.005);
plotHandles_b= getPlotHandles(1,1,[0.40 0.11 0.1 0.6],0.011,0.005);
plotHandles_c= getPlotHandles(1,1,[0.045 0.765 0.32 0.18],0.011,0.005);

plotHandles_j= getPlotHandles(1,1,[0.54 0.11 0.32 0.6],0.011,0.005);
plotHandles_k= getPlotHandles(1,1,[0.895 0.11 0.1 0.6],0.011,0.005);
plotHandles_l= getPlotHandles(1,1,[0.54 0.765 0.32 0.18],0.011,0.005);

% original axes positions
basePos_a = get(plotHandles_a,'Position');
basePos_b = get(plotHandles_b,'Position');
basePos_c = get(plotHandles_c,'Position');

basePos_j = get(plotHandles_j,'Position');
basePos_k = get(plotHandles_k,'Position');
basePos_l = get(plotHandles_l,'Position');

annotation(gcf,'textarrow',...
    [0.025 0.1] ,[0.939 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',26, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.505 0.1] ,[0.937 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',26, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

for iplot = 1:2
    clearvars histData scatterData
    if iplot == 1
        histData = expVarVals;
        scatterData = expVarAll;
    else
        histData = AIC;
        scatterData = akaikeInfoCrit;
    end
   
    if iplot == 1
        plotHandle1 = plotHandles_a;
        plotHandle2 = plotHandles_b;
        plotHandle3 = plotHandles_c;

        mainBasePos = basePos_a;
        rightBasePos = basePos_b;
        topBasePos = basePos_c;

        BinNum = 21;
        BinAx = 0:0.05:1;
        labelString = 'Explained Variance';

        % expanded main scatter limits
        limits = [0 1.35];

        x_ax_val = 1;
        y_ax_val1 = 0.16;
        y_ax_val2 = 0.08;
        tailSide = 'both';

        % diagonal histogram parameters
        diffBinEdges         = -0.30:0.03:0.30;
        diffTickValues       = -0.30:0.10:0.30;
        diffTickLabels       = {'-3','-2','-1','0','1','2','3'};
        diagGapFromData      = 0.10;
        diagHalfSpan         = 0.10;   % compact baseline
        diagBarScale         = 0.003; % smaller height
        diagBarWidthFrac     = 1.9;   % thicker width
        diagFaceAlpha        = 0.20;
        diagBarDirectionSign = 1;

        rightWidthScale      = 1.00;
        rightMinHeightFrac   = 0.42;
        topMinWidthFrac      = 0.42;

    else
        plotHandle1 = plotHandles_j;
        plotHandle2 = plotHandles_k;
        plotHandle3 = plotHandles_l;

        mainBasePos = basePos_j;
        rightBasePos = basePos_k;
        topBasePos = basePos_l;

        BinNum = 21;
        BinAx = -1000:100:1000;
        labelString = 'Akaike Information Criteria';

        % expanded main scatter limits
        limits = [-1100 1100];

        x_ax_val = 550;
        y_ax_val1 = -850; 
        y_ax_val2 = -975;
        tailSide = 'both';

        % diagonal histogram parameters
        diffBinEdges         = -400:40:400;
        diffTickValues       = -300:100:300;
        diffTickLabels       = {'-300','-200','-100','0','100','200','300'};
        diagGapFromData      = 180;
        diagHalfSpan         = 170;    % compact baseline
        diagBarScale         = 5.5;    % smaller height
        diagBarWidthFrac     = 1.95;   % thicker width
        diagFaceAlpha        = 0.20;
        diagBarDirectionSign = 1;

        
        rightWidthScale      = 1.00;
        rightMinHeightFrac   = 0.42;
        topMinWidthFrac      = 0.42;
    end
    
    subplot(plotHandle1)
    colorArray = [0.7 0.03 0.3;1 0.54 0.15]; 
    Markers = {'o','square','^','d','pentagram'};
    plot(-200:1:-195,-200:1:-195,'-','color',colorArray(1,:),'lineWidth',2.5);
    hold on;
    plot(-200:1:-195,-200:1:-195,'-','color',colorArray(2,:),'lineWidth',2.5);
    hold on;
    scatter(-10000,-10000,1,'filled','Marker',Markers{1},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    scatter(-10000,-10000,1,'filled','Marker',Markers{2},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    scatter(-10000,-10000,1,'filled','Marker',Markers{3},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    scatter(-10000,-10000,1,'filled','Marker',Markers{4},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    scatter(-10000,-10000,1,'filled','Marker',Markers{5},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;

    for idel = 1:size(scatterData,2)
        for imonkey = 1:size(scatterData,1)  
            clearvars mod1_x mod2_y
            mod1_x = scatterData{imonkey,idel}(:,1);
            mod2_y = scatterData{imonkey,idel}(:,2);
            scatter(mod1_x,mod2_y,85,'filled',Markers{imonkey},...
                'MarkerEdgeColor',colorArray(idel,:),...
                'MarkerFaceColor',colorArray(idel,:),...
                'MarkerFaceAlpha',0.2);
            hold on;
        end
    end

    X_Label = (labelString + " - Original Tuned Normalization Model");
    Y_Label = (labelString + " - Slow-varying Tuned Normalization Model");
    ylabel(Y_Label);xlabel(X_Label);
    xlim(limits);ylim(limits);
    hUnity= plot(limits,limits,'k:','lineWidth',1.2);
    box off;

    % ----- occupied range for marginal histograms -----
    allValsForMarginals = [histData{1}(:,1); histData{1}(:,2); histData{2}(:,1); histData{2}(:,2)];
    allValsForMarginals = allValsForMarginals(isfinite(allValsForMarginals));
    occupiedRange = getOccupiedHistogramRange(allValsForMarginals, BinAx, limits);

    % ----- diagonal histogram anchor relative to last data point -----
    allX = [histData{1}(:,1); histData{2}(:,1)];
    allY = [histData{1}(:,2); histData{2}(:,2)];
    validMask = isfinite(allX) & isfinite(allY);
    allX = allX(validMask);
    allY = allY(validMask);

    if ~isempty(allX)
        sAnchor = max((allX + allY) ./ 2) + diagGapFromData;
    else
        sAnchor = mean(occupiedRange);
    end
    sAnchor = min(max(sAnchor, limits(1)), limits(2));

    % ----- get real max count across both conditions for mini y-axis -----
    counts1 = histcounts(histData{1}(:,2) - histData{1}(:,1), diffBinEdges);
    counts2 = histcounts(histData{2}(:,2) - histData{2}(:,1), diffBinEdges);
    maxDiagCount = max([counts1(:); counts2(:); 1]);

    diagCountTicks = getNiceCountTicks(maxDiagCount);

    % ----- draw diagonal histogram -----
    drawDiagonalDifferenceHistogram(gca,...
        histData{1}(:,1),histData{1}(:,2),...
        diffBinEdges,colorArray(1,:),...
        diagBarScale,diagBarWidthFrac,sAnchor,...
        diagHalfSpan,diagFaceAlpha,diagBarDirectionSign,...
        true,diffTickValues,diffTickLabels,diagCountTicks,maxDiagCount);

    drawDiagonalDifferenceHistogram(gca,...
        histData{2}(:,1),histData{2}(:,2),...
        diffBinEdges,colorArray(2,:),...
        diagBarScale,diagBarWidthFrac,sAnchor,...
        diagHalfSpan,diagFaceAlpha,diagBarDirectionSign,...
        false,diffTickValues,diffTickLabels,diagCountTicks,maxDiagCount);

    legend('Delta 0','Delta 90','M1-LFP','M2-LFP','M3-ECoG','M1 and M2-MUA','M2 and M4-EEG',...
        'location','northwest','Fontname','courier','Fontsize',15,'FontWeight','bold');
    legend('boxoff')
    ax = gca;
    ax.FontSize = 13;
    ax.XLabel.FontSize = 16;
    ax.YLabel.FontSize = 16;

    %%% significance
    [del_0_p,~] = signrank(histData{1}(:,1),histData{1}(:,2),'tail',tailSide);
    [del_90_p,~] = signrank(histData{2}(:,1),histData{2}(:,2),'tail',tailSide);

    string_0 = ['p = ' num2str(del_0_p)];
    text(x_ax_val,y_ax_val1,string_0,'color',colorArray(1,:),...
        'FontWeight','bold','fontname','courier','Fontsize',15);
    
    string_90 = ['p = ' num2str(del_90_p)];
    text(x_ax_val,y_ax_val2,string_90,'color',colorArray(2,:),...
        'FontWeight','bold','fontname','courier','Fontsize',15);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clearvars mod1_0 mod2_0 mod1_90 mod2_90
    mod1_0  = histData{1,1}(:,1);
    mod2_0  = histData{1,1}(:,2);
    mod1_90 = histData{1,2}(:,1);
    mod2_90 = histData{1,2}(:,2);

    % ----- resize/reposition marginals -----
    resizeMarginalAxes(plotHandle1,plotHandle2,plotHandle3,...
        mainBasePos,rightBasePos,topBasePos,occupiedRange,limits,...
        rightWidthScale,rightMinHeightFrac,topMinWidthFrac);
    
    % ----- right marginal -----
    subplot(plotHandle2)
    histogram(mod2_0,BinNum,'BinEdges',BinAx,'Orientation','horizontal',...
        'FaceColor',colorArray(1,:),'FaceAlpha',0.2,...
        'EdgeColor',colorArray(1,:),'LineWidth',1.5);
    hold on;
    histogram(mod2_90,BinNum,'BinEdges',BinAx,'Orientation','horizontal',...
        'FaceColor',colorArray(2,:),'FaceAlpha',0.2,...
        'EdgeColor',colorArray(2,:),'LineWidth',1.5);

    ylim(occupiedRange);
    
    if iplot == 1
        xlim([0 40]);
        yticks(0:0.1:1.6)
        yticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','','','','','',''});
    else
        xlim([0 18]);
        yticks(-1000:200:1000)
        yticklabels({'-1000','-800','-600','-400','-200','0','200','400','600','800','1000'});
    end
    
    box off; set(gca, 'color', 'none');
    set(gca,'Xtick',[]);
    ax = gca;
    ax.XRuler.Visible = 'off';
    ax.FontSize = 13;

    % ----- top marginal -----
    subplot(plotHandle3)
    histogram(mod1_0,BinNum,'BinEdges',BinAx,'Orientation','vertical',...
        'FaceColor',colorArray(1,:),'FaceAlpha',0.2,...
        'EdgeColor',colorArray(1,:),'LineWidth',1.5);
    hold on;
    histogram(mod1_90,BinNum,'BinEdges',BinAx,'Orientation','vertical',...
        'FaceColor',colorArray(2,:),'FaceAlpha',0.2,...
        'EdgeColor',colorArray(2,:),'LineWidth',1.5);
    
    xlim(occupiedRange);
    
    if iplot == 1
        ylim([0 25]);
        xticks(0:0.1:1.6);
        xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','','','','','',''});
        yticks(0:10:20);
    else
        ylim([0 15]);
        xticks(-1000:200:1000);
        xticklabels({'-1000','-800','-600','-400','-200','0','200','400','600','800','1000'});
    end
    
    box off; set(gca, 'color', 'none');
    set(gca,'Ytick',[]);
    ax = gca;
    ax.YRuler.Visible = 'off';
    ax.FontSize = 13;
end

end


function drawDiagonalDifferenceHistogram(axHandle,xVals,yVals,binEdges,faceColor,...
    barScale,barWidthFrac,sAnchor,halfSpan,faceAlpha,barDirectionSign,...
    drawAxisFlag,diffTickValues,diffTickLabels,countTickValues,maxDiagCount)

if nargin < 10 || isempty(faceAlpha)
    faceAlpha = 0.2;
end
if nargin < 11 || isempty(barDirectionSign)
    barDirectionSign = 1;
end
if nargin < 12 || isempty(drawAxisFlag)
    drawAxisFlag = false;
end

hold(axHandle,'on');

diffVals = xVals-yVals;
diffVals = diffVals(isfinite(diffVals));

if isempty(diffVals)
    return;
end

counts = histcounts(diffVals,binEdges);

u = [1 1] ./ sqrt(2);   % along unity line
v = [1 -1] ./ sqrt(2);  % orthogonal to unity line

anchorPoint = [sAnchor sAnchor];

nBins = numel(binEdges) - 1;
tEdges = linspace(-halfSpan, halfSpan, nBins + 1);
tCenters = (tEdges(1:end-1) + tEdges(2:end)) / 2;
tWidths = diff(tEdges);

for ibin = 1:nBins
    if counts(ibin) <= 0
        continue;
    end

    baseCenter = anchorPoint + tCenters(ibin) * v;
    halfWidth = 0.5 * barWidthFrac * tWidths(ibin);
    barHeight = counts(ibin) * barScale;

    p1 = baseCenter - halfWidth * v;
    p2 = baseCenter + halfWidth * v;
    p3 = p2 + barDirectionSign * barHeight * u;
    p4 = p1 + barDirectionSign * barHeight * u;

    patch('Parent',axHandle,...
        'XData',[p1(1) p2(1) p3(1) p4(1)],...
        'YData',[p1(2) p2(2) p3(2) p4(2)],...
        'FaceColor',faceColor,...
        'EdgeColor',faceColor,...
        'FaceAlpha',faceAlpha,...
        'LineWidth',1.5,...
        'Clipping','on');
end

if drawAxisFlag
    % ----- x-axis baseline -----
    axisStart = anchorPoint - halfSpan * v;
    axisEnd   = anchorPoint + halfSpan * v;

    plot(axHandle,[axisStart(1) axisEnd(1)],[axisStart(2) axisEnd(2)],...
        'k-','LineWidth',1.2);

    % ----- x ticks and labels -----
    if ~isempty(diffTickValues)
        diffMin = binEdges(1);
        diffMax = binEdges(end);

        tickLen = 0.06 * halfSpan;
        labelOffset = 0.30 * halfSpan;

        for it = 1:numel(diffTickValues)
            dVal = diffTickValues(it);

            if dVal < diffMin || dVal > diffMax
                continue;
            end

            % exact mapping from data difference value to position on baseline
            frac = (dVal - diffMin) / (diffMax - diffMin);
            frac = max(0,min(1,frac));
            tickCenter = axisStart + frac * (axisEnd - axisStart);

            tickStart = tickCenter;
            tickEnd   = tickCenter - barDirectionSign * tickLen * u;

            plot(axHandle,[tickStart(1) tickEnd(1)],...
                [tickStart(2) tickEnd(2)],'k-','LineWidth',1);

            labelPos = tickCenter - barDirectionSign * labelOffset * u;
            text(labelPos(1),labelPos(2),diffTickLabels{it},...
                'Parent',axHandle,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'FontName','courier',...
                'FontSize',11,...
                'Color','k',...
                'Clipping','off');
        end
    end

    % x-axis label
    xLabelPos = anchorPoint - barDirectionSign * (0.58 * halfSpan) * u;
    text(xLabelPos(1),xLabelPos(2),'x-y',...
        'Parent',axHandle,...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'Rotation',-45,...
        'FontName','courier',...
        'FontWeight','bold',...
        'FontSize',12,...
        'Color','k',...
        'Clipping','off');

    % ----- y-axis for counts -----
    yAxisBase = axisStart;
    yAxisEnd = yAxisBase + barDirectionSign * (maxDiagCount * barScale) * u;

    plot(axHandle,[yAxisBase(1) yAxisEnd(1)],[yAxisBase(2) yAxisEnd(2)],...
        'k-','LineWidth',1.2);

    tickLen2 = 0.08 * halfSpan;
    labelOffset2 = 0.40 * halfSpan;

    for it = 1:numel(countTickValues)
        cTick = countTickValues(it);
        tickCenter = yAxisBase + barDirectionSign * (cTick * barScale) * u;

        tickP1 = tickCenter - 0.5 * tickLen2 * v;
        tickP2 = tickCenter + 0.5 * tickLen2 * v;

        plot(axHandle,[tickP1(1) tickP2(1)],...
            [tickP1(2) tickP2(2)],'k-','LineWidth',1);

        labelPos = tickCenter - labelOffset2 * v;
        text(labelPos(1),labelPos(2),sprintf('%d',cTick),...
            'Parent',axHandle,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','middle',...
            'FontName','courier',...
            'FontSize',11,...
            'Color','k',...
            'Clipping','off');
    end

    % ----- y-axis label -----
    yLabelPos = yAxisBase + barDirectionSign * (0.53 * maxDiagCount * barScale) * u ...
        - 0.70 * halfSpan * v;

    text(yLabelPos(1),yLabelPos(2),'Count',...
        'Parent',axHandle,...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'Rotation',45,...
        'FontName','courier',...
        'FontWeight','bold',...
        'FontSize',11,...
        'Color','k',...
        'Clipping','off');
end

end
function occupiedRange = getOccupiedHistogramRange(allVals,BinEdges,mainLimits)

allVals = allVals(isfinite(allVals));

if isempty(allVals)
    occupiedRange = mainLimits;
    return;
end

counts = histcounts(allVals,BinEdges);
occupiedBins = find(counts > 0);

if isempty(occupiedBins)
    occupiedRange = mainLimits;
    return;
end

firstBin = occupiedBins(1);
lastBin  = occupiedBins(end);

if numel(BinEdges) > 1
    halfBin = median(diff(BinEdges)) / 2;
else
    halfBin = 0;
end

occupiedMin = BinEdges(firstBin) - halfBin;
occupiedMax = BinEdges(lastBin + 1) + halfBin;

occupiedMin = max(mainLimits(1), occupiedMin);
occupiedMax = min(mainLimits(2), occupiedMax);

if occupiedMax <= occupiedMin
    occupiedRange = mainLimits;
else
    occupiedRange = [occupiedMin occupiedMax];
end

end


function tickVals = getNiceCountTicks(maxCount)

maxCount = max(1, ceil(maxCount));

if maxCount <= 5
    step = 1;
elseif maxCount <= 10
    step = 2;
elseif maxCount <= 20
    step = 5;
elseif maxCount <= 50
    step = 10;
else
    step = ceil(maxCount / 5);
end

tickVals = 0:step:maxCount;
if tickVals(end) ~= maxCount
    tickVals = [tickVals maxCount];
end

tickVals = unique(round(tickVals));

end


function resizeMarginalAxes(mainAx,rightAx,topAx,...
    mainBasePos,rightBasePos,topBasePos,occupiedRange,mainLimits,...
    rightWidthScale,rightMinHeightFrac,topMinWidthFrac)

if nargin < 9 || isempty(rightWidthScale)
    rightWidthScale = 1;
end
if nargin < 10 || isempty(rightMinHeightFrac)
    rightMinHeightFrac = 0.35;
end
if nargin < 11 || isempty(topMinWidthFrac)
    topMinWidthFrac = 0.35;
end

mainSpan = mainLimits(2) - mainLimits(1);

if mainSpan <= 0
    return;
end

fracStart = (occupiedRange(1) - mainLimits(1)) / mainSpan;
fracEnd   = (occupiedRange(2) - mainLimits(1)) / mainSpan;

fracStart = max(0,min(1,fracStart));
fracEnd   = max(0,min(1,fracEnd));

if fracEnd <= fracStart
    fracEnd = min(1, fracStart + 0.01);
end

occFrac = fracEnd - fracStart;
occFracTop = max(occFrac, topMinWidthFrac);
occFracRight = max(occFrac, rightMinHeightFrac);

occCenter = 0.5 * (fracStart + fracEnd);

% top marginal
newTopPos = topBasePos;
newTopPos(3) = occFracTop * mainBasePos(3);
newTopPos(1) = mainBasePos(1) + occCenter * mainBasePos(3) - 0.5 * newTopPos(3);

% clamp top axis inside main axis horizontal span
topLeftBound  = mainBasePos(1);
topRightBound = mainBasePos(1) + mainBasePos(3);
newTopPos(1) = max(topLeftBound, min(newTopPos(1), topRightBound - newTopPos(3)));

% right marginal
newRightPos = rightBasePos;
newRightPos(4) = occFracRight * mainBasePos(4);
newRightPos(2) = mainBasePos(2) + occCenter * mainBasePos(4) - 0.5 * newRightPos(4);

% clamp right axis inside main axis vertical span
rightBottomBound = mainBasePos(2);
rightTopBound    = mainBasePos(2) + mainBasePos(4);
newRightPos(2) = max(rightBottomBound, min(newRightPos(2), rightTopBound - newRightPos(4)));

% keep right marginal fully inside the figure, fixed small gap from main axis
gapToMain = rightBasePos(1) - (mainBasePos(1) + mainBasePos(3));
if gapToMain < 0
    gapToMain = 0.01;
end

newRightPos(3) = rightBasePos(3) * rightWidthScale;
newRightPos(1) = mainBasePos(1) + mainBasePos(3) + gapToMain;

figureRightMargin = 0.985;
if newRightPos(1) + newRightPos(3) > figureRightMargin
    newRightPos(3) = max(0.04, figureRightMargin - newRightPos(1));
end

set(topAx,'Position',newTopPos);
set(rightAx,'Position',newRightPos);
set(mainAx,'Position',mainBasePos);

end