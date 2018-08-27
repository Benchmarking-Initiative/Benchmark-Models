function [] = plot_WaterfallScatter
% This function plots the waterfall plots and optimization time for all
% benchmark models.

global Optimization_analysis
ar_tmp = Optimization_analysis;
modelNrs = fieldnames(ar_tmp);
modelNrs = sort(modelNrs);
legend_string = {};
colors = lines(3);

for im = 1:length(modelNrs)
    figure('PaperUnits','centimeters','PaperSize',[21 29.7])
    subplot(2,1,1)
    modelNr = modelNrs{im};
    model_name = strsplit(modelNrs{im},'_');
    
    if strcmp(model_name{2},'Reelin')
        model_name{2} = 'Hass';
    end
    if strcmp(model_name{2},'TGFb')
        model_name{2} = 'Lucarelli';
    end
    
    min_model = min([ar_tmp.(modelNr).fmin_ip_log.chi2s,...
        ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s,ar_tmp.(modelNr).FindInputs_logFit.chi2s]);
    s1=scatter(1:1000,sort(ar_tmp.(modelNr).FindInputs_logFit.chi2s)-min_model+1,...
        'd','MarkerEdgeColor',colors(3,:));
    hold on
    s2=scatter(1:1000,sort(ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s)-min_model+1,...
        'o','MarkerEdgeColor',colors(2,:));
    s3=scatter(1:1000,sort(ar_tmp.(modelNr).fmin_ip_log.chi2s)-min_model+1,...
        'x','MarkerEdgeColor',colors(1,:));

    s2.MarkerFaceAlpha = .5;
    s2.MarkerEdgeAlpha = .5;
    s3.MarkerFaceAlpha = .5;
    s3.MarkerEdgeAlpha = .5;
    set(gca,'yscale','log')
    if(im==7)
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))
    end
    legend_string{3} = ['{fmincon interior-point}'];
    legend_string{2} = ['{fmincon trust-region}'];
    legend_string{1} = ['{lsqnonlin}'];
    
    set(gcf,'Color','w')
    xlabel('fit number')
    ylabel('final likelihood value + const.')
    title([model_name{2}])
    box off
    
    set(gca,'FontSize',14)
    axis manual
    if ismember(model_name{2},{'Beer','Crauste'})
        legend(legend_string,'Location','southeast')
    else
        legend(legend_string,'Location','northwest')
    end
    x_limits = get(gca,'XLim');
    y_limits = get(gca,'YLim');
    
    text(x_limits(1)-(x_limits(2)-x_limits(1))*0.15,...
        (y_limits(2)+(y_limits(2)-y_limits(1))*0.2),'A','FontSize',16)
    
    subplot(2,1,2)
    s1=scatter((ar_tmp.(modelNr).FindInputs_logFit.timing),...
        (ar_tmp.(modelNr).FindInputs_logFit.chi2s-min_model+1),'d','MarkerEdgeColor',colors(3,:)); hold on;
    s2=scatter((ar_tmp.(modelNr).fmin_ip_log.timing),...
        (ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s-min_model+1),'o','MarkerEdgeColor',colors(2,:)); hold on;
    s3=scatter((ar_tmp.(modelNr).fmin_ip_log.timing),...
        (ar_tmp.(modelNr).fmin_ip_log.chi2s-min_model+1),'x','MarkerEdgeColor',colors(1,:));

    s2.MarkerFaceAlpha = .5;
    s2.MarkerEdgeAlpha = .5;
    s3.MarkerFaceAlpha = .5;
    s3.MarkerEdgeAlpha = .5;
    set(gca,'xscale','log','yscale','log')
    if(im==7)
        set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))
    end
    set(gcf,'Color','w')
    xlabel('optimization time [s]')
    ylabel('final likelihood value + const.')
    axis manual
    x_limits = get(gca,'XLim');
    y_limits = get(gca,'YLim');
    set(gca,'FontSize',14)
    box off
    text(10.^(log10(x_limits(1)) - (log10(x_limits(2)) - log10(x_limits(1)))*0.15),...
        y_limits(2)+(y_limits(2)-y_limits(1))*0.2,'B','FontSize',16)
    
    print(gcf,['Supplement_figures/' model_name{2}],'-dpdf','-fillpage')
end
close all
