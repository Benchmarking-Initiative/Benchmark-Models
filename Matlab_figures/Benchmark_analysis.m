% This script generates the plots for the analyses of the paper "Benchmark
% Problems for Dynamic Modeling of Intracellular Processes". 

% Load results for the checks of convexity in linear and log scale.
load('Benchmark_paper_convex.mat','Convex_analysis');

% Load fitting results of all models
loadOptimizationAnalysis

% Load table with all the characteristics of the
% models including number of data points, observables, parameters, etc.
load('Benchmark_paper_modelcharacteristics.mat','modelcharacteristics');

%% Comparison of performance criterion linlog vs. log for different thresholds to consider a start as converged
chi2_threshold = 1e-1;
plot_Benchmark('convergence-linloglog',chi2_threshold)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
% if ~(exist('Manuscript_figures'))
% 	mkdir('Manuscript_figures')
% end
% print('-depsc',['Manuscript_figures/Fig2A'])

chi2_threshold = 10;
plot_Benchmark('convergence-linloglog',chi2_threshold)
title(['threshold = ' num2str(chi2_threshold)],'FontSize',7)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Supplement_figures/linlog_threshold10'])

chi2_threshold = 50;
plot_Benchmark('convergence-linloglog',chi2_threshold)
title(['threshold = ' num2str(chi2_threshold)],'FontSize',7)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
% if ~(exist('Supplement_figures'))
% 	mkdir('Supplement_figures')
% end
%print('-depsc',['Supplement_figures/linlog_threshold50'])

%% Comparison of convexity between different sampling and parameter transformation strategies
plot_Benchmark('convex')
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 5 6.5])
%print('-depsc',['Manuscript_figures/Fig2C'])

%% Interior-point vs. trust-region-reflective performance metrics for different thresholds
chi2_threshold = 1e-1;
plot_Benchmark('trust-ip',chi2_threshold)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Manuscript_figures/Fig3'])

chi2_threshold = 0.5;
plot_Benchmark('trust-ip',chi2_threshold)
title(['threshold = ' num2str(chi2_threshold)],'FontSize',7)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Supplement_figures/ip_trust_threshold0_5'])

chi2_threshold = 1;
plot_Benchmark('trust-ip',chi2_threshold)
title(['threshold = ' num2str(chi2_threshold)],'FontSize',7)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Supplement_figures/ip_trust_threshold1'])

chi2_threshold = 10;
plot_Benchmark('trust-ip',chi2_threshold)
title(['threshold = ' num2str(chi2_threshold)],'FontSize',7)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Supplement_figures/ip_trust_threshold10'])

chi2_threshold = 50;
plot_Benchmark('trust-ip',chi2_threshold)
title(['threshold = ' num2str(chi2_threshold)],'FontSize',7)
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Supplement_figures/ip_trust_threshold50'])

%% Iterations needed in optimization vs. parameter number
plot_Iterations(0,modelcharacteristics,6) 
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Manuscript_figures/Fig4A'])

%% Time needed for optimization vs. parameter number
plot_Iterations(1,modelcharacteristics,6) 
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 8 8])
%print('-depsc',['Manuscript_figures/Fig4B'])

%% Waterfall plots for the Supplementary Information
plot_WaterfallScatter

%% Convexity plots for the Supplementary Information
plot_Convexity_suppl
set(gcf, 'PaperUnits','centimeters', 'PaperPosition',[0 0 16 15])
%print('-depsc',['Supplement_figures/convexity'])
