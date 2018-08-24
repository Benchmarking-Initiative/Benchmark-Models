function plot_Convexity_suppl()
global Convex_analysis

modelNrs = fieldnames(Convex_analysis); 
modelNrs = sort(modelNrs);

%Set colors
loadModelColors

fig = figure('name','Convexity');
hold on
ax2 = axes('Position',[0 0 1 1]);

for im = 1:length(modelNrs)
    modelNr = modelNrs{im};
    model_name = strsplit(modelNrs{im},'_');
    
    if strcmp(model_name{2},'Reelin')
        model_name{2} = 'Hass';
    end
    if strcmp(model_name{2},'TGFb')
        model_name{2} = 'Lucarelli';
    end
    nr_cols = 3;
    nr_rows = ceil(length(modelNrs)/nr_cols);

    perc_log = nansum(Convex_analysis.(modelNr).log.isConvex)/sum(~isnan(Convex_analysis.(modelNr).log.isConvex));
    perc_nonlogConv = nansum(Convex_analysis.(modelNr).nonlogConv.isConvex)/sum(~isnan(Convex_analysis.(modelNr).nonlogConv.isConvex));
    perc_nonlog = nansum(Convex_analysis.(modelNr).nonlog.isConvex)/sum(~isnan(Convex_analysis.(modelNr).nonlog.isConvex));
    perc_logConv = nansum(Convex_analysis.(modelNr).logConv.isConvex)/sum(~isnan(Convex_analysis.(modelNr).logConv.isConvex));

    error_log = perc_log * (1-perc_log) / sqrt(sum(~isnan(Convex_analysis.(modelNr).log.isConvex)));
    error_nonlogConv = perc_nonlogConv * (1-perc_nonlogConv) / sqrt(sum(~isnan(Convex_analysis.(modelNr).nonlogConv.isConvex)));
    error_nonlog = perc_nonlog * (1-perc_nonlog) / sqrt(sum(~isnan(Convex_analysis.(modelNr).nonlog.isConvex)));
    error_logConv = perc_logConv * (1-perc_logConv) / sqrt(sum(~isnan(Convex_analysis.(modelNr).logConv.isConvex)));

    out.perc_logT(im) = perc_log;
    out.perc_nonlogConvT(im) = perc_nonlogConv;

    out.perc_logConvT(im) = perc_logConv;
    out.perc_nonlogT(im) = perc_nonlog;

    subplot(nr_rows,nr_cols,im)
    
    bars = [perc_log ...
        perc_nonlogConv ...
        perc_logConv ...
        perc_nonlog];
    
    for i = 1:4
        b = bar(i,bars(i));
        b.FaceColor = colors_convexity(i,:);
        hold on
    end
    
    errorbar([perc_log ...
        perc_nonlogConv ...
        perc_logConv ...
        perc_nonlog],...
        [error_log ...
        error_nonlogConv ...
        error_logConv ...
        error_nonlog], 'k.')
    
    %set(gca,'XTick',[1 2 3 4],'XTickLabel',{'Log','Linear-LogPars', 'Log-LinearPars','Linear'});
    
    set(gca,'XTick',[1 2 3 4],'XTickLabel',{''},'FontSize',7);

        
    title(model_name{2},'FontSize',7)   
    box off
end
ax1 = axes('Position',[0 0 1 1],'Visible','off');
blah = text(0.08,0.48,'convex sets [%]','FontSize',7);
set(blah,'Rotation',90);
%text(0.66,0.18,'Log   -  Both parameters and connection in log-space','FontSize',14,'FontWeight','bold')
%text(0.66,0.14,'Linear-LogPars   -  Parameter from log, connection in linear-space','FontSize',14,'FontWeight','bold')
%text(0.66,0.10,'Log-LinearPars   -  Parameter drawn in linear, connection in log-space','FontSize',14,'FontWeight','bold')
%text(0.66,0.06,'Linear   -   Both parameters and connection in linear space','FontSize',14,'FontWeight','bold')

set(gcf,'Color','w')   
%print(gcf,ConvexCheck,'-dpdf','-fillpage')
