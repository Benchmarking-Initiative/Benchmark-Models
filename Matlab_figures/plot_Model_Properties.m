clear all;
close all;
clc;

parts = strsplit(pwd, filesep);
parent_path = strjoin(parts(1:end-1), filesep);

% Options
dy_ticks = 0.2;

% Load color and data
loadModelColors

name = {'observables',...
        'conditions',...
        'data points',...
        'parameters'};

numbers(:,1) = xlsread([parent_path '/Benchmark-Models/benchmark_model_characteristics.xlsx'],'model_overview','D3:D22');
numbers(:,2) = xlsread([parent_path '/Benchmark-Models/benchmark_model_characteristics.xlsx'],'model_overview','E3:E22');
numbers(:,3) = xlsread([parent_path '/Benchmark-Models/benchmark_model_characteristics.xlsx'],'model_overview','F3:F22');
numbers(:,4) = xlsread([parent_path '/Benchmark-Models/benchmark_model_characteristics.xlsx'],'model_overview','J3:J22');

[~,model_names] = xlsread([parent_path '/Benchmark-Models/benchmark_model_characteristics.xlsx'],'model_overview','A3:A22');

bounds = [1e0,1e0,1e1,9e0;...
    43         110       27132         270];

ticks = repmat(10.^[0:5]',1,4);
ticks_fine = [1:10]' * 10.^[0:5];
ticks_fine = repmat(ticks_fine(:),1,4);
ticks_name = {'10^0','10^1','10^2','10^3','10^4','10^5'};

scaled_ticks      = log10(ticks     );
scaled_ticks_fine = log10(ticks_fine);
scaled_numbers    = log10(numbers   );
scaled_ticks      = bsxfun(@minus  ,scaled_ticks     ,log10(bounds(1,:)));
scaled_ticks_fine = bsxfun(@minus  ,scaled_ticks_fine,log10(bounds(1,:)));
scaled_numbers    = bsxfun(@minus  ,scaled_numbers   ,log10(bounds(1,:)));
scaled_ticks      = bsxfun(@rdivide,scaled_ticks     ,log10(bounds(2,:))-log10(bounds(1,:)));
scaled_ticks_fine = bsxfun(@rdivide,scaled_ticks_fine,log10(bounds(2,:))-log10(bounds(1,:)));
scaled_numbers    = bsxfun(@rdivide,scaled_numbers   ,log10(bounds(2,:))-log10(bounds(1,:)));
scaled_ticks      = 0.95*scaled_ticks     +0.025;
scaled_ticks_fine = 0.95*scaled_ticks_fine+0.025;
scaled_numbers    = 0.95*scaled_numbers   +0.025;

% Create figure
figure; hold on;

for i = 1:size(numbers,2)
    % Bar
    [N,EDGES] = histcounts(scaled_numbers(:,i),5);
    for k = 1:length(N)
        fill(EDGES([k,k+1,k+1,k]),-i+0.7*N(k)/max(N)*[0,0,1,1],'k','FaceColor',0.8*[1,1,1],'EdgeColor',[1,1,1],'LineWidth',3);
    end
    % Plot axis
    quiver(0,-i,1.05,0,0,'color','k','MaxHeadSize',0.1);
    % Plot ticks
    for k = 1:size(ticks_fine,1)
        if (0.025 <= scaled_ticks_fine(k,i)) && (scaled_ticks_fine(k,i) <= 0.975)
            plot(scaled_ticks_fine(k,i)*[1,1],-i+0.2*dy_ticks*[-1,1],'k-');
        end
    end
    for k = 1:size(ticks,1)
        if (0.025 <= scaled_ticks(k,i)) && (scaled_ticks(k,i) <= 0.975)
            plot(scaled_ticks(k,i)*[1,1],-i+0.4*dy_ticks*[-1,1],'k-');
            text(scaled_ticks(k,i),-i-dy_ticks,ticks_name{k},'HorizontalAlignment','center');
        end
    end
    % Plot markers
    for j = 1:size(numbers,1)
        plot(scaled_numbers(j,i),-i,'o','MarkerSize',3,'MarkerFaceColor',colors(j,:),'MarkerEdgeColor',colors(j,:));
    end
    % Label
    text(1.1,-i,name{i})
end

for j = 1:size(numbers,1)
    lh(j) = plot(scaled_numbers(j,:),-[1:size(numbers,2)],'-','Color',colors(j,:));
end

legend(lh,model_names,'box','off');

xlim([-0.1,2]);
box off
axis off
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 9 12])

[rho,pval]=corr(log(numbers(:,3)),numbers(:,4))
