function plot_Iterations(do_timing,modelcharacteristics,which_field, mark_nonid)
% INPUT:
% do_timing... true: plot time required for optimization,
%              false: plot iteration number for optimization,
% modelcharacteristics... table
% which_field... 3: number of observables,
%                4: nmber of data points,
%                5: number of conditions,
%                6: number of parameters (see modelcharacteristics table)
% mark_nonid... true: non-identifiable models are marked differently
%               false: all models have the same marker

if(~exist('do_timing','var') || isempty(do_timing))
    do_timing = false;
end
if(~exist('which_field','var') || isempty(which_field))
    which_field = 6;
end
if(~exist('mark_nonid','var') || isempty(mark_nonid))
    mark_nonid = false;
end

global Optimization_analysis
ar_tmp = Optimization_analysis;

modelNrs = sort(fieldnames(ar_tmp));
iters = NaN(length(modelNrs)*2,1000);
if(do_timing)
   figure('Name','Timing') 
else
   figure('Name','Iterations') 
end

for im = 1:length(modelNrs)
    modelNr = modelNrs{im};
    if(do_timing)
        iters(im,1:length(ar_tmp.(modelNr).FindInputs_logFit.timing)) ...
            = ar_tmp.(modelNr).FindInputs_logFit.timing;
    else
        iters(im,1:length(ar_tmp.(modelNr).FindInputs_logFit.iter)) ...
            = ar_tmp.(modelNr).FindInputs_logFit.iter;
    end
end

iter_mean = nanmean(iters,2);
iter_std = nanstd(iters,1,2)./sqrt(sum(~isnan(iters),2));

disp([num2str(nanmean(iter_mean)) '+-' num2str(nanmean(iter_std))])

names = {'Bachmann','Becker','Beer','Boehm','Brannmark','Bruno','Chen',...
    'Crauste','Fiedler','Fujita','Hass','Isensee','Lucarelli','Merkle',...
    'Raia','Schwen','Sobotta','Swameye','Weber','Zheng'};

loadModelColors

for im = 1:length(modelNrs)
    model_split = strsplit(modelNrs{im},'_');
    if(strcmp(model_split{2},'Reelin'))
        model_name = 'Hass';
    elseif(strcmp(model_split{2},'TGFb'))
        model_name = 'Lucarelli';
    else
        model_name = model_split{2};
    end
    char_id = find(~cellfun(@isempty,strfind(modelcharacteristics{:,1},model_name)));
    x_tmp = table2array(modelcharacteristics(char_id,which_field)); %4 is data points, 6 is parameters, 3 is observables
    
    is_nonid = table2array(modelcharacteristics(char_id,end));
    out.x_tmp(im) = x_tmp;
    out.iter_mean(im) = iter_mean(im);
    out.non_id(im) = is_nonid;
    [~,color_ind]=ismember(model_name,names);
    
    if mark_nonid && is_nonid
        loglog(x_tmp,iter_mean(im),'d','MarkerSize',4,'LineWidth',2,...
            'Color',colors(icolor_ind,:))
    else
        loglog(x_tmp,iter_mean(im),'.','MarkerSize',13,'LineWidth',2,...
            'Color',colors(color_ind,:))
    end
    hold on
    if do_timing
        if strcmp(model_name,'Brannmark')
            text(x_tmp+0.1*x_tmp,iter_mean(im)+1.1,model_name,'FontSize',6);
        else
            text(x_tmp+0.1*x_tmp,iter_mean(im),model_name,'FontSize',6);
        end
    else
        if strcmp(model_name,'Fiedler')
            text(x_tmp+0.08*x_tmp,iter_mean(im)+40,model_name,'FontSize',6);
        elseif strcmp(model_name,'Brannmark')
            text(x_tmp+0.08*x_tmp,iter_mean(im)-15,model_name,'FontSize',6);
        elseif strcmp(model_name,'Swameye')
            text(x_tmp+0.08*x_tmp,iter_mean(im)+15,model_name,'FontSize',6)
        elseif strcmp(model_name,'Merkle')
            text(x_tmp+0.08*x_tmp,iter_mean(im)+40,model_name,'FontSize',6)
        else
            text(x_tmp+0.08*x_tmp,iter_mean(im),model_name,'FontSize',6);
        end
    end
end
set(gcf,'Color','w')
xlabel('number of parameters','FontSize',7)
if(do_timing)
    ylabel('average computation time per local optimization [s]','FontSize',7)
    xlim([5e0,6e2])
    ylim([3e-1,1e3])
else
    ylabel('average number of iterations per local optimization','FontSize',7)
    xlim([5e0,6e2])
    ylim([7e0,3.5e3])
    set(gca,'xscale','log','yscale','log')
end

axis square
set(gca,'FontSize',7)

% get correlations
x_tmp = out.x_tmp(~isnan(out.x_tmp))';
iter_mean = out.iter_mean(~isnan(out.iter_mean))';
if ~do_timing
    [rho,pval]=corr(x_tmp,iter_mean)
else
    [rho,pval]=corr(x_tmp,iter_mean)
    grid = linspace(min(log10(x_tmp)),max(log10(x_tmp)));
    % regression
    b = [ones(length(x_tmp),1),log10(x_tmp)]\log10(iter_mean);
    disp([num2str(b(2)) 'x-'  num2str(-b(1))]);
    plot(10.^grid,10.^(grid*b(2)+b(1)),'-','Color',[0.7,0.7,0.7])
    ha = get(gca, 'Children'); % line in the background
    set(gca, 'Children', [ha(end:-1:1)]);
end
