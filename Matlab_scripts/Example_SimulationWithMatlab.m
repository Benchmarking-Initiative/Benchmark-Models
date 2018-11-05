%% Reading benchmark files 
clear all, clc

forceRead = false; % loads workspace, if available [FASTER]
% forceRead = true;  % enforce reading the benchmark files [SLOWER]

% Specify a folder/benchmark-model:

basefolder = strrep(fileparts(which('Example_SimulationWithMatlab.m')),'Matlab_scripts','Benchmark-Models');

% NEW CHECKS
% modelfolder = 'Bachmann_MSB2011';  % ok
% modelfolder = 'Becker_Science2010';  % ok
% modelfolder = 'Boehm_JProteomeRes2014';  % ok
% modelfolder = 'Beer_MolBioSystems2014'; % ok
% modelfolder = 'Bruno_JExpBio2016'; % ok
% modelfolder = 'Brannmark_JBC2010';  % ok
% modelfolder = 'Chen_MSB2009';  % ok
% modelfolder = 'Crauste_CellSystems2017'; % ok
% modelfolder = 'Fiedler_BMC2016'; % ok
% modelfolder = 'Fujita_SciSignal2010'; % ok
% modelfolder = 'Hass_PONE2017'; % ok
% modelfolder = 'Isensee_JCB2018'; % ok
% modelfolder = 'Lucarelli_CellSystems_2018';  % ok
% modelfolder = 'Merkle_PCB2016'; % ok 
% modelfolder = 'Raia_CancerResearch2011'; % ok
% modelfolder = 'Schwen_PONE2014'; % ok
% modelfolder = 'Sobotta_Frontiers2017';  ok
% modelfolder = 'Swameye_PNAS2003'; % ij
% modelfolder = 'Schwen_PONE2014'; % ok
% modelfolder = 'Zheng_PNAS2012'; % ok
% modelfolder = 'Elowitz_Nature2000'; % ok
% modelfolder = 'Borghans_BiophysChem1997'; % ok
% modelfolder = 'Sneyd_PNAS2002'; % ok

list_examples = {'Becker_Science2010';
    'Bachmann_MSB2011';
    'Beer_MolBioSystems2014';
    'Boehm_JProteomeRes2014';
    'Bruno_JExpBio2016';
    'Lucarelli_CellSystems_2018'; ...
    'Merkle_PCB2016';
    'Raia_CancerResearch2011';
    'Hass_PONE2017';
    'Schwen_PONE2014';
    'Swameye_PNAS2003'; ...
    'Brannmark_JBC2010';
    'Crauste_CellSystems2017';
    'Weber_BMC2015';
    'Isensee_JCB2018';
    'Zheng_PNAS2012';
    'Fiedler_BMC2016';
    'Sobotta_Frontiers2017';
    'Fujita_SciSignal2010';
    'Chen_MSB2009';
    'Elowitz_Nature2000';
    'Borghans_BiophysChem1997';
    'Sneyd_PNAS2002'};


for iex = 21:length(list_examples)
    modelfolder = list_examples{iex};

    folder = [basefolder,filesep,modelfolder];
    [~,name]=fileparts(folder);

    fprintf('Reading benchmark model in folder %s ...\n',folder)
    if ~exist([name,'.mat'],'file') || forceRead
        [Is,ms,ds] = ReadBenchmarks(folder);
        save(name,'Is', 'ms','ds','folder');
    else
        load(name)
    end

    % Writing Matlab code for simulation
    fprintf('Writing ODE_file and ODE_call ...\n')
    if length(Is)>1
        error('This case is not yet implemented.');
    else
        I = Is(1);
    end

    if(strcmp(modelfolder,'Swameye_PNAS2003'))
       mex spline_pos5.c
    end
    
    for ii = 1:length(ms) % loop over all model/data pairs
        m = ms(ii);
        d = ds(ii);
        if(strcmp(modelfolder,'Chen_MSB2009'))
            tols = 1.e-4;
        elseif(strcmp(modelfolder,'Isensee_JCB2018'))
            tols = 1.e-6;
        elseif(strcmp(modelfolder,'Sobotta_Frontiers2017'))
            tols = 1.e-6;
        else
            tols = 1.e-8;
        end
        status = WriteMatlabODEs(I,m,d,tols); % the ODE files from the last call are overwritten

        if status == 0
            fprintf('Executing ODE_call for model, data %i \n',ii)
            ODE_call % variable d has to be known
            if maxdiff>0.01 && reldiff>0.01
                input('\n maxdiff>0.01 && reldiff>0.01: OK?');
            end
            drawnow
        else
            fprintf('ii=%i: status ~=0 (can occur for empty prediction settings) \n',ii);
        end

    end
end
%close all
