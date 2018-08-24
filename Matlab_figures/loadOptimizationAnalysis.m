% Load and merge results of optimization analysis

load('Benchmark_paper_optimization_1.mat','Optimization_analysis_part1');
load('Benchmark_paper_optimization_2.mat','Optimization_analysis_part2');

global Optimization_analysis

fn1=fieldnames(Optimization_analysis_part1);
fn2=fieldnames(Optimization_analysis_part2);

for i = 1:10
    Optimization_analysis.(fn1{i}) = Optimization_analysis_part1.(fn1{i});
    Optimization_analysis.(fn2{i}) = Optimization_analysis_part2.(fn2{i});
end
