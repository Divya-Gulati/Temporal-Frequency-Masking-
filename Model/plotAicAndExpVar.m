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

plotHandles_j= getPlotHandles(1,1,[0.545 0.11 0.32 0.6],0.011,0.005);
plotHandles_k= getPlotHandles(1,1,[0.89 0.11 0.1 0.6],0.011,0.005);
plotHandles_l= getPlotHandles(1,1,[0.545 0.765 0.32 0.18],0.011,0.005);

annotation(gcf,'textarrow',...
    [0.025 0.1] ,[0.90 0.5],...
    'String','A', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

annotation(gcf,'textarrow',...
    [0.505 0.1] ,[0.92 0.5],...
    'String','B', 'HeadStyle', 'none', 'LineStyle', 'none',...
    'FontSize',18, 'color','k','FontWeight','bold', 'TextRotation',0,'FontName','courier');

for iplot = 1:2
    clearvars histData scatterData
    if iplot == 1
        histData = expVarVals;
        scatterData =expVarAll;
    else
        histData = AIC;
        scatterData = akaikeInfoCrit;
    end
   
    if iplot == 1
        plotHandle1 = plotHandles_a;
        plotHandle2 = plotHandles_b;
        plotHandle3 = plotHandles_c;
        BinNum = 21;
        BinAx = 0:0.05:1;
        labelString = 'Explained Variance';
        limits = [0 1];
        x_ax_val = 0.7;
        y_ax_val1 = 0.1;
        y_ax_val2 = 0.05;
        tailSide = 'both';
    else
        plotHandle1 = plotHandles_j;
        plotHandle2 = plotHandles_k;
        plotHandle3 = plotHandles_l;
        BinNum = 15;
        BinAx = -1000:100:400;
        labelString = 'Akaike Information Criteria';
        limits = [-1000 400];
        x_ax_val = 0;
        y_ax_val1 = -860; 
        y_ax_val2 = -930;
        tailSide = 'both';
    end
    
    subplot(plotHandle1)
    colorArray = [0.7 0.03 0.3;1 0.54 0.15]; 
    Markers = {'o','square','^'};
    plot(-200:1:-195,-200:1:-195,'-','color',colorArray(1,:),'lineWidth',2.5);
    hold on;
    plot(-200:1:-195,-200:1:-195,'-','color',colorArray(2,:),'lineWidth',2.5);
    hold on;
    scatter(-10000,-10000,1000,'filled','Marker',Markers{1},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    scatter(-10000,-10000,1000,'filled','Marker',Markers{2},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    scatter(-10000,-10000,1000,'filled','Marker',Markers{3},'MarkerFaceAlpha',0.6,'MarkerFaceColor','k');hold on;
    for idel = 1:size(scatterData,2)
        for imonkey = 1:size(scatterData,1)  
            clearvars mod1_x mod2_y
            mod1_x = scatterData{imonkey,idel}(:,1);
            mod2_y = scatterData{imonkey,idel}(:,2);
            scatter(mod1_x,mod2_y,70,'filled',Markers{imonkey},'MarkerEdgeColor',colorArray(idel,:),'MarkerFaceColor',colorArray(idel,:),'MarkerFaceAlpha',0.2);
            hold on;
        end
    end
    X_Label = (labelString + " - Original Tuned Normalization Model") ;
    Y_Label = (labelString + " - Optimal Tuned Normalization Model") ;
    ylabel(Y_Label);xlabel(X_Label);
    xlim(limits);ylim(limits);
    plot(limits,limits,'k:','lineWidth',1.2);
    legend('Delta 0','Delta 90','M1','M2','M3','location','northwest','Fontname','courier','Fontsize',13,'FontWeight','bold');
    
    
    %%% checking significance --

    [del_0_p,~] = signrank(histData{1}(:,1),histData{1}(:,2),'tail',tailSide);
    [del_90_p,~] = signrank(histData{2}(:,1),histData{2}(:,2),'tail',tailSide);

    string_0 = ['p = ' num2str(del_0_p)];%, '%0.8f'
    text(x_ax_val,y_ax_val1,string_0,'color',colorArray(1,:),'FontWeight','bold','fontname','courier','Fontsize',12);
    
    string_90 = ['p = ' num2str(del_90_p)];%,'%0.8f'
    text(x_ax_val,y_ax_val2,string_90,'color',colorArray(2,:),'FontWeight','bold','fontname','courier','Fontsize',12);

    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clearvars mod1_0 mod2_0 mod1_90 mod2_90
    mod1_0= histData{1, 1} (:,1);
    mod2_0= histData{1, 1} (:,2);
    mod1_90= histData{1, 2} (:,1);
    mod2_90= histData{1, 2} (:,2);
    
    subplot(plotHandle2)
    histogram(mod2_0,BinNum,'BinEdges',BinAx,'Orientation','horizontal','FaceColor',colorArray(1,:),'FaceAlpha',0.2,'EdgeColor',colorArray(1,:),'LineWidth',1.5);
    hold on;
    histogram(mod2_90,BinNum,'BinEdges',BinAx,'Orientation','horizontal','FaceColor',colorArray(2,:),'FaceAlpha',0.2,'EdgeColor',colorArray(2,:),'LineWidth',1.5);
    
    if iplot == 1
        ylim([0 1]);yticks(0:0.1:1)
        xlim([0 40]);yticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
    else
        ylim([-1000 400]);yticks(-1000:200:400)
        xlim([0 20]);
        yticklabels({'-1000','-800','-600','-400','-200','0','200','400'});
    end
    
    box off; set(gca, 'color', 'none');
    set(gca,'Xtick',[]);
    ax = gca;
    ax.XRuler.Visible = 'off';
    
   %%%                                %%%%%%%%
    subplot(plotHandle3)
    histogram(mod1_0,BinNum,'BinEdges',BinAx,'Orientation','vertical','FaceColor',colorArray(1,:),'FaceAlpha',0.2,'EdgeColor',colorArray(1,:),'LineWidth',1.5);
    hold on;
    histogram(mod1_90,BinNum,'BinEdges',BinAx,'Orientation','vertical','FaceColor',colorArray(2,:),'FaceAlpha',0.2,'EdgeColor',colorArray(2,:),'LineWidth',1.5);
    
    if iplot == 1
        xlim([0 1]);ylim([0 30]);
        xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
        xticks(0:0.1:1);yticks(0:10:20);
    else
        xlim([-1000 400]);ylim([0 20]);
        xticks(-1000:200:400);
        xticklabels({'-1000','-800','-600','-400','-200','0','200','400'});
    end
    
    box off; set(gca, 'color', 'none');
    set(gca,'Ytick',[]);
    ax = gca;
    ax.YRuler.Visible = 'off';
    
end

end