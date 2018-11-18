function ds = SimulateExpData(ds,nSigma, randomseed)

% set random seed
if(exist('rng','file')~=0)
    if(exist('randomseed','var') && ~isempty(randomseed))
        rng(randomseed);
    else
        rng('shuffle');        
    end
end
if(~exist('ds','var') || isempty(ds))
    error('Please specify correct data struct')
end
if(~exist('nSigma','var') || isempty(nSigma))
    nSigma = 1;
end

if(nSigma == 0)
    warning('You are simulating data without noise, i.e. models with estimated errors will be corrupted!')
end
    
for is = 1:length(ds)
    for iSim = 1:size(ds(is).ExpData.value,2)
        sd_tmp = ds(is).ExpData.SDmodel{iSim};
        replaceData = isnan(ds(is).ExpData.SDmodel{iSim}) & ~isnan(ds(is).ExpData.SDexp{iSim});
        sd_tmp(replaceData) = ...
            ds(is).ExpData.SDexp{iSim}(replaceData);
        
        ds(is).ExpData.value{iSim} = ds(is).Simulation.value{iSim} + ...
            nSigma * randn(size(ds(is).ExpData.value{iSim})) .* sd_tmp;

    end
end