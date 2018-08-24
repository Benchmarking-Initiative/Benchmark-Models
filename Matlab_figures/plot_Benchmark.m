function plot_Benchmark(which_compare,chi2_threshold)
global ar_tmp

global Convex_analysis
global Optimization_analysis

names = {'Bachmann','Becker','Beer','Boehm','Brannmark','Bruno','Chen',...
    'Crauste','Fiedler','Fujita','Hass','Isensee','Lucarelli','Merkle',...
    'Raia','Schwen','Sobotta','Swameye','Weber','Zheng'};

if(~exist('chi2_threshold','var') || isempty(chi2_threshold))
    chi2_threshold = 1e-1;
end

if(strcmp(which_compare,'trust-ip'))
    ar_tmp = Optimization_analysis;
elseif(strcmp(which_compare,'convex'))
    ar_tmp = Convex_analysis;
elseif(strcmp(which_compare,'convergence-linlog') || ...
        strcmp(which_compare,'convergence-linloglog'))
    ar_tmp = Optimization_analysis;
end

if(~exist('modelNrs','var') || isempty(modelNrs))
    modelNrs = fieldnames(ar_tmp);
    modelNrs = sort(modelNrs);
end

loadModelColors
if strcmp(which_compare,'convex')
	figure('Name','convexity lin log')
else
    figure('Name',[which_compare ' threshold ' num2str(chi2_threshold)])
end
for im = 1:length(modelNrs)
    modelNr = modelNrs{im};
    model_split = strsplit(modelNr,'_');
    if(strcmp(model_split{2},'Reelin'))
        model_name = 'Hass';
    elseif(strcmp(model_split{2},'TGFb'))
        model_name = 'Lucarelli';
    else
        model_name = model_split{2};
    end
    model_names{im}=model_name;
    if(strcmp(which_compare,'trust-ip'))
        if im ==1
            loglog(linspace(1e-9,1e6),linspace(1e-9,1e6),'-','Color',[0.5,0.5,0.5]); hold on;
        end
        
        if strcmp(model_name,'Chen')
            all_chi2s = [ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s ...
                ar_tmp.(modelNr).fmin_ip_log.chi2s ...
                ar_tmp.(modelNr).FindInputs_logFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linlogFit.chi2s];
        else
            all_chi2s = [ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s ...
                ar_tmp.(modelNr).fmin_trust_FindInputs_lin.chi2s ...
                ar_tmp.(modelNr).fmin_ip_log.chi2s ...
                ar_tmp.(modelNr).FindInputs_logFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linlogFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linFit.chi2s];
        end
        
        % find best value found across optimizers
        global_opt = min(all_chi2s);
        
        % how often has this optimum been found (w.r.t. threshold)
        found_opt = sum(all_chi2s-global_opt < chi2_threshold);
        
        if found_opt > 1 % only include if optimum found more than once
            % number of starts with difference to best found value below
            % chi2_threshold using trust-region-reflective
            y_trust = nansum((ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s - global_opt) ...
                < chi2_threshold)/nansum(ar_tmp.(modelNr).fmin_trust_FindInputs_log.timing)*60;
            
            % number of starts with difference to best found value below
            % chi2_threshold using inter-point
            y_ip = nansum((ar_tmp.(modelNr).fmin_ip_log.chi2s - global_opt) ...
                < chi2_threshold)/nansum(ar_tmp.(modelNr).fmin_ip_log.timing)*60;
            
            % for plotting reasons (in log space)
            if y_trust == 0
                y_trust = y_trust + 1e-7;
            end
            if y_ip == 0
                y_ip = y_ip + 1e-7;
            end
            
            % assign ouptut
            out.y_trust(im) = y_trust;
            out.y_ip(im) = y_ip ;
            
            % logarithmic scatter plot
            [~,color_ind]=ismember(model_name,names);
            loglog(y_ip,y_trust,'.','MarkerSize',13,'Color',colors(color_ind,:));
            
            % fine tuning of label location
            if strcmp(model_name,'Hass')
                text(y_ip+0.4*y_ip,y_trust-4e-8,model_name,'FontSize',6);
            elseif strcmp(model_name,'Boehm')
                text(y_ip+0.4*y_ip,(y_trust)*(1.02)+8e-2,model_name,'FontSize',6)
            elseif strcmp(model_name,'Brannmark')
                text(y_ip+0.4*y_ip,(y_trust)*(1.02)+2e-7,model_name,'FontSize',6)
            elseif strcmp(model_name,'Isensee')
                text(y_ip+0.4*y_ip,y_trust+5e-8,model_name,'FontSize',6)
            elseif strcmp(model_name,'Weber')
                text(y_ip+0.4*y_ip,(y_trust)*(1.02)+0.5e-7,model_name,'FontSize',6)
            elseif strcmp(model_name,'Merkle')
                text(y_ip+0.4*y_ip,(y_trust)*(1.02),model_name,'FontSize',6)
            elseif strcmp(model_name,'Zheng')
                text(y_ip+0.4*y_ip,(y_trust)*(1.02)-3e-4,model_name,'FontSize',6)
            else
                text(y_ip+0.4*y_ip,(y_trust)*(1.02),model_name,'FontSize',6);
            end
            hold on
            xlim([1e-7,1e4])
            ylim([1e-7,1e4])
            axis square
            set(gca,'FontSize',7,...
                'xtick',[1e-7,1e-6,1e-4,1e-2,1e0,1e2],...
                'ytick',[1e-7,1e-6,1e-4,1e-2,1e0,1e2],...
                'xticklabel',{'0','10^{-6}','10^{-4}','10^{-2}','10^{0}','10^{2}'},...
                'yticklabel',{'0','10^{-6}','10^{-4}','10^{-2}','10^{0}','10^{2}'});
        end
    elseif(strcmp(which_compare,'convex'))
        perc_log = nansum(ar_tmp.(modelNr).log.isConvex)/...
            sum(~isnan(ar_tmp.(modelNr).log.isConvex));
        perc_nonlogConv = nansum(ar_tmp.(modelNr).nonlogConv.isConvex)/...
            sum(~isnan(ar_tmp.(modelNr).nonlogConv.isConvex));
        perc_nonlog = nansum(ar_tmp.(modelNr).nonlog.isConvex)/...
            sum(~isnan(ar_tmp.(modelNr).nonlog.isConvex));
        perc_logConv = nansum(ar_tmp.(modelNr).logConv.isConvex)/...
            sum(~isnan(ar_tmp.(modelNr).logConv.isConvex));
        
        % assign output
        out.perc_logT(im) = perc_log;
        out.perc_nonlogConvT(im) = perc_nonlogConv;
        out.perc_logConvT(im) = perc_logConv;
        out.perc_nonlogT(im) = perc_nonlog;
        
    elseif(strcmp(which_compare,'convergence-linlog'))
        if im ==1
            plot(linspace(1e-9,1e6),linspace(1e-9,1e6),'-','Color',[0.5,0.5,0.5]); hold on;
        end
        
        if strcmp(model_name,'Chen')
            all_chi2s = [ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s ...
                ar_tmp.(modelNr).fmin_ip_log.chi2s ...
                ar_tmp.(modelNr).FindInputs_logFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linlogFit.chi2s];
        else
            all_chi2s = [ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s ...
                ar_tmp.(modelNr).fmin_trust_FindInputs_lin.chi2s ...
                ar_tmp.(modelNr).fmin_ip_log.chi2s ...
                ar_tmp.(modelNr).FindInputs_logFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linlogFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linFit.chi2s];
        end
        
        % find best value found across optimizers
        global_opt = min(all_chi2s);
        
        % how often has this optimum been found (w.r.t. threshold)
        found_opt = sum(all_chi2s-global_opt < chi2_threshold);
        if found_opt > 1 % only include if optimum found more than once
            out.diff(im) = min(ar_tmp.(modelNr).FindInputs_logFit.chi2s)-...
                min(ar_tmp.(modelNr).FindInputs_linFit.chi2s);
            
            out.model_name{im} = model_name;
            
            y_log = nansum((ar_tmp.(modelNr).FindInputs_logFit.chi2s - global_opt) ...
                < chi2_threshold)./nanmsum(ar_tmp.(modelNr).FindInputs_logFit.timing)*60;
            
            y_lin = nansum((ar_tmp.(modelNr).FindInputs_linFit.chi2s - global_opt) ...
                < chi2_threshold)./nansum(ar_tmp.(modelNr).FindInputs_linFit.timing)*60;
            
            out.y_log(im)=y_log;
            out.y_lin(im)=y_lin;
            
            [~,color_ind]=ismember(model_name,names);
            loglog(y_lin,y_log,'.','MarkerSize',13,'Color',colors(color_ind,:)); hold on;
            
            text(y_lin+0.02,y_log*(1.02),model_name,'FontSize',6)
        end
    elseif(strcmp(which_compare,'convergence-linloglog'))
        if im ==1
            plot(linspace(1e-9,1e6),linspace(1e-9,1e6),'-','Color',[0.5,0.5,0.5]); hold on;
        end
        
        if strcmp(model_name,'Chen')
            all_chi2s = [ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s ...
                ar_tmp.(modelNr).fmin_ip_log.chi2s ...
                ar_tmp.(modelNr).FindInputs_logFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linlogFit.chi2s];
        else
            all_chi2s = [ar_tmp.(modelNr).fmin_trust_FindInputs_log.chi2s ...
                ar_tmp.(modelNr).fmin_trust_FindInputs_lin.chi2s ...
                ar_tmp.(modelNr).fmin_ip_log.chi2s ...
                ar_tmp.(modelNr).FindInputs_logFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linlogFit.chi2s ...
                ar_tmp.(modelNr).FindInputs_linFit.chi2s];
        end
        
        % find best value found across optimizers
        global_opt = min(all_chi2s);
        
        % how often has this optimum been found (w.r.t. threshold)
        found_opt = sum(all_chi2s-global_opt < chi2_threshold);
        if found_opt > 1 % only include if optimum found more than once
            
            out.diff(im) = min(ar_tmp.(modelNr).FindInputs_logFit.chi2s)-...
                min(ar_tmp.(modelNr).FindInputs_linlogFit.chi2s);
            
            out.model_name{im} = model_name;
            
            y_log = nansum((ar_tmp.(modelNr).FindInputs_logFit.chi2s - global_opt) ...
                < chi2_threshold)./nansum(ar_tmp.(modelNr).FindInputs_logFit.timing)*60;
            
            y_lin = nansum((ar_tmp.(modelNr).FindInputs_linlogFit.chi2s - global_opt) ...
                < chi2_threshold)./nansum(ar_tmp.(modelNr).FindInputs_linlogFit.timing)*60;
            
            if y_log == 0
                y_log = 1e-5;
            end
            if y_lin == 0
                y_lin = 1e-5;
            end
            
            out.y_log(im)=y_log;
            out.y_lin(im)=y_lin;
            [~,color_ind]=ismember(model_name,names);
            loglog(y_lin,y_log,'.','MarkerSize',13,'Color',colors(color_ind,:)); hold on;
            
            if strcmp(model_name,'Lucarelli')
                text(1.5*y_lin,y_log+0.001,model_name,'FontSize',6)
            elseif strcmp(model_name,'Merkle')
                text(1.5*y_lin,y_log-0.001,model_name,'FontSize',6)
            elseif strcmp(model_name,'Hass')
                text(1.5*y_lin,y_log+0.01,model_name,'FontSize',6)
            elseif strcmp(model_name,'Beer')
                text(1.5*y_lin,y_log+0.00002,model_name,'FontSize',6)
            elseif strcmp(model_name,'Sobotta')
                text(1.5*y_lin,y_log+4e-6,model_name,'FontSize',6)
            elseif strcmp(model_name,'Bachmann')
                text(1.5*y_lin,y_log-0.03,model_name,'FontSize',6)
            elseif strcmp(model_name,'Weber')
                text(1.5*y_lin,y_log-4e-6,model_name,'FontSize',6)
            elseif strcmp(model_name,'Fielder')
                text(1.5*y_lin,y_log+0.02,model_name,'FontSize',6)
            elseif strcmp(model_name,'Schwen')
                text(1.5*y_lin,y_log+0.5,model_name,'FontSize',6)
            elseif strcmp(model_name,'Boehm') && chi2_threshold == 50
                %text(1*y_lin,y_log+0.5,model_name,'FontSize',6)
            else
                text(1.5*y_lin,y_log,model_name,'FontSize',6)
            end
            set(gca,'FontSize',7,...
                'xtick',[1e-5,1e-4,1e-2,1e0,1e2],...
                'ytick',[1e-5,1e-4,1e-2,1e0,1e2],...
                'xticklabel',{'0','10^{-4}','10^{-2}','10^{0}','10^{2}'},...
                'yticklabel',{'0','10^{-4}','10^{-2}','10^{0}','10^{2}'});
        end
    end
end

if(strcmp(which_compare,'trust-ip'))
    xlim([1e-7,2e2])
    ylim([1e-7,2e2])
elseif(strcmp(which_compare,'convergence-linlog') || ...
        strcmp(which_compare,'convergence-linloglog'))
    set(gca,'YScale','log','FontSize',7);
    set(gca,'XScale','log','FontSize',7);
    axis square
    ylim([1e-5,1e2])
    xlim([1e-5,1e2])
elseif(strcmp(which_compare,'convex'))
    h=boxplot([out.perc_logT' ...
        out.perc_nonlogConvT' ...
        out.perc_logConvT' ...
        out.perc_nonlogT' ...
        ],'Labels',...
        {'Log','Linear-LogPars','Log-LinearPars','Linear'},...
        'Width',0.8,'Symbol','k.');
    set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 6);
    set(findobj(gcf,'LineStyle','--'),'LineStyle','-')
    boxes = findobj(gca,'Tag','Box');
    median = findobj(gca,'Tag','Median');
    
    patch(get(boxes(4),'XData'),get(boxes(4),'YData'),colors_convexity(1,:),'FaceAlpha',1); hold on;
    patch(get(boxes(3),'XData'),get(boxes(3),'YData'),colors_convexity(2,:),'FaceAlpha',1); hold on;
    patch(get(boxes(2),'XData'),get(boxes(2),'YData'),colors_convexity(3,:),'FaceAlpha',1); hold on;
    patch(get(boxes(1),'XData'),get(boxes(1),'YData'),colors_convexity(4,:),'FaceAlpha',1); hold on;
    plot(get(median(1),'XData'),get(median(1),'YData'),'k-','Linewidth',0.5); hold on;
    plot(get(median(2),'XData'),get(median(2),'YData'),'k-','Linewidth',0.5);
    plot(get(median(3),'XData'),get(median(3),'YData'),'k-','Linewidth',0.5);
    plot(get(median(4),'XData'),get(median(4),'YData'),'k-','Linewidth',0.5);
    box off
    set(gca,'YLim',[0 1.39],'FontSize',7,'ytick',[0:0.2:1])
    ylabel('convexity','FontSize',7)
    
    %Statistical tests
    thresh1 = 0.05;
    fields = fieldnames(out);
    for ig = 1:length(fields)
        out.(fields{ig})(isnan(out.(fields{ig}))) = 0;
    end
    count = 1;
    in2 = 4:-1:1;
    for in = 1:(length(fields)-1)
        for isec = length(fields):-1:in+1
            test_tmp = signrank(out.(fields{in}),out.(fields{isec}));
            fprintf('Tested %s vs. %s , resulted in p= %f \n',fields{in},fields{isec},test_tmp)
            if(test_tmp<thresh1)
                line([in isec],[1.01+(in2(count)-1)*0.07 1.01+(in2(count)-1)*0.07],'Color',[0.7,0.7,0.7],'LineWidth',0.8);
                line([in in],[1.0 1.01+(in2(count)-1)*0.07],'Color',[0.7,0.7,0.7],'LineWidth',0.8);
                line([isec isec],[1.0 1.01+(in2(count)-1)*0.07],'Color',[0.7,0.7,0.7],'LineWidth',0.8);
                count = count+1;
            end
        end
    end
end
set(gcf,'Color','w')






