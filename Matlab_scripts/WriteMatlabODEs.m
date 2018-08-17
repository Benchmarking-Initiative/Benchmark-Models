% WriteMatlabODEs(I,m,d)
% 
%   Given a general model info I, a model struct m and a data struct d,
%   this file writes plan Matlab code for ODE-integration and comparison of
%   simulations.
% 
% I.parameters.names can be larger than Matlab's max. variable length (63
% characters). I therefore put parameters into struct P;

function status = WriteMatlabODEs(I,m,d,tols)

if ~isfield(d.Simulation,'name')
    disp('d.Simulation.name does not exist. This occurs if the data set is empty which in turn occurs for prediction/validation settings.')
    disp('WriteMatlabODEs is not designed for this setting because simulation in the data file and simuation by ode15s is compared. => Aborted.')
    status = -1;
    return    
end

if isempty(fieldnames(m.ODEs)) % No ODE model
    fprintf('   General_Info file = %s\n',I.file);
    fprintf('   model-file        = %s\n',m.file);
    fprintf('   data-file         = %s\n',d.file);
    warning('Seems to be NO ODEs model. Return now without writing files.');
    return
end

fid = fopen('ODE_call.m','w');
fprintf(fid,'%s This script can be used to integrate ODEs (here using ode15s) for simulation the dynamics x(t) for this benchmark model.\n\n','%');
fprintf(fid,'%s The model corresponds to:\n','%');
fprintf(fid,'%s General_Info file = %s\n','%',I.file);
fprintf(fid,'%s model-file        = %s\n','%',m.file);
fprintf(fid,'%s data-file         = %s\n','%',d.file);

pstr = 'p=[';
pstrInv = cell(size(I.parameters.names));
for i=1:length(I.parameters.names)
    if str2num(I.parameters.logscale{i})
        fprintf(fid,'%s = 10^%s;\n',I.parameters.names{i},I.parameters.value{i});   
%         pval = 10.^str2num(I.parameters.value{i});
    else
        fprintf(fid,'%s = %s;\n',I.parameters.names{i},I.parameters.value{i});   
%         pval = str2num(I.parameters.value{i});
    end
%     fprintf(fid,'%s = %f;\n',I.parameters.names{i},pval);   
    pstr = sprintf('%s %s,',pstr,I.parameters.names{i});
    pstrInv{i} = sprintf('%s = p(%i);',I.parameters.names{i},i);
end
pstr = sprintf('%s];\n\n',pstr(1:end-1));
fprintf(fid,'%s',pstr);


for i=1:length(m.Initials.name)
    fprintf(fid,'%s = %s;\n',strrep(m.Initials.name{i},'init_','initial_'),num2str(m.Initials.value{i}));
end

% Since replacements are all done, the following should not be required:
% [~,dfile] = fileparts(d.file);
% imodel = regexp(dfile,'model(\d+)','Match');
% imodel = num2str(imodel{1}(6:end));
% 
% idata = regexp(dfile,['model',num2str(imodel),'_data(\d+)$'],'Match');
% idata = strmatch(['Data file ',num2str(idata{1}(5:end))],I.data_file,'exact');
% idata = idata(1);
% 
% for i=1:length(I.replacement.old)
%     if ischar(I.replacement.new{idata,i})
%         fprintf(fid,'%s = %s;\n',I.replacement.old{i},I.replacement.new{idata,i});
%     elseif isnumeric(I.replacement.new{idata,i}) && ~isnan(I.replacement.new{idata,i})
%         fprintf(fid,'%s = %f;\n',I.replacement.old{i},I.replacement.new{idata,i});
%     end
% end


xstr = '';
x0strInv = cell(size(m.Initials.name));
for i=1:length(m.Initials.name)
    xstr = sprintf('%s %s;',xstr,strrep(m.Initials.name{i},'init_','initial_'));
    x0strInv{i} = sprintf('%s = x(%i);',strrep(m.Initials.name{i},'init_',''),i);
end
x0str = sprintf('x0=[%s];\n\n',xstr(1:end-1));
fprintf(fid,'%s',x0str);

fprintf(fid,'tsim = unique([');
if(isnumeric(m.tstart))
    fprintf(fid,'%f',m.tstart);
else
    fprintf(fid,'%s',m.tstart);
end

for i=1:length(d.Simulation.time)
    fprintf(fid,',%f',d.Simulation.time(i));
end
for i=1:length(d.ExpData.time)
    fprintf(fid,',%f',d.ExpData.time(i));
end
fprintf(fid,',%f]);\n',max(d.Simulation.time));
fprintf(fid,'if length(tsim)==1, tsim = [tsim,1.1]; end\n');

fprintf(fid,'\n[t,x] = ode15s(@ODE_file,tsim,x0,odeset(''AbsTol'',%e,''RelTol'',%e,''MaxStep'',range(tsim)/1000),p);\n\n',tols,tols);
fprintf(fid,'close all\n');
fprintf(fid,'plot(t,x)\n');

fprintf(fid,'\n\n%s Calcuation of Observables:\n','%');
for i=1:length(m.Initials.name)
    fprintf(fid,'%s = x(:,%i);\n',strrep(m.Initials.name{i},'init_',''),i);
end

fprintf(fid,'\n\n%s a) Definitions:\n','%');
for i=1:length(m.Observables.definition_rhs)
    fprintf(fid,'%s = %s;\n',m.Observables.definition_lhs{i},Formula2Matlab(m.Observables.definition_rhs{i}));
end

fprintf(fid,'\n\n%s b) Observables:\n','%');
for i=1:length(m.Observables.name)
    if(~strcmp(m.Observables.obsfun{i}(1:11),'spline_pos5'))
        fprintf(fid,'%s = feval(inline(''%s'',',m.Observables.name{i},Formula2Matlab(m.Observables.obsfun{i}));
        if(~(strcmp(d.ExpData.timePar,'t') || strcmp(d.ExpData.timePar,'time')))
            fprintf(fid,'    ''%s'',...\n',d.ExpData.timePar);
        end
        tmp = sprintf('   ''%s'',...\n',I.parameters.names{:});
        fprintf(fid,'%s',tmp);


    % Since replacements are all done, the following should not be required:
    %     tmp = sprintf('''%s'',',I.replacement.old{:});
    %     fprintf(fid,'%s',tmp);

        for ix=1:length(m.Observables.definition_lhs)
            fprintf(fid,'    ''%s'',...\n',m.Observables.definition_lhs{ix});
        end
        for ix=1:length(m.Initials.name)
            fprintf(fid,'     ''%s''',strrep(m.Initials.name{ix},'init_',''));
            if ix<length(m.Initials.name)
                fprintf(fid,',');
            end
        end
        fprintf(fid,'),...\n');

        if(~(strcmp(d.ExpData.timePar,'t') || strcmp(d.ExpData.timePar,'time')))
            fprintf(fid,'    t,...\n');
        end

        tmp = sprintf('   %s,...\n',I.parameters.names{:});
        fprintf(fid,'%s',tmp);    
    % Since replacements are all done, the following should not be required:
    %     tmp = sprintf('%s,',I.replacement.old{:});
    %     fprintf(fid,'%s',tmp);

        for ix=1:length(m.Observables.definition_lhs)
            fprintf(fid,'    %s,...\n',m.Observables.definition_lhs{ix});
        end
        for ix=1:length(m.Initials.name)
            fprintf(fid,'%s',strrep(m.Initials.name{ix},'init_',''));
            if ix<length(m.Initials.name)
                fprintf(fid,',');
            else
                fprintf(fid,');\n');
            end
        end
    else
        fprintf(fid,'tmp_spline = NaN(size(t)); \n');
        fprintf(fid,'for it= 1:length(t) \n');
        fprintf(fid,'    tmp_spline(it) = %s; \n',strrep(m.Observables.obsfun{i},'t','t(it)'));
        fprintf(fid,'end \n');
        fprintf(fid,'%s = tmp_spline; \n',m.Observables.name{i});
    end   
end

for i=1:length(m.Observables.name)
   fprintf(fid,'if(length(%s)==1 && length(%s)<length(t))\n',m.Observables.name{i},m.Observables.name{i});
   fprintf(fid,'    %s = ones(size(t))*%s; \n',m.Observables.name{i},m.Observables.name{i});
   fprintf(fid,'end\n');
end


fprintf(fid,'\n\n%s Comparison of simulated observables in the benchmark collection with simulated observables here:\n','%');
fprintf(fid,'if isfield(d.Simulation,''value'')\n');
fprintf(fid,'    [~,ia,ib]=intersect(d.Simulation.time,t);\n');
fprintf(fid,'    figure,hold on;\n');
for o=1:length(d.Simulation.name)
    fprintf(fid,'    for i=1:length(ia)\n');
    fprintf(fid,'        plot(d.Simulation.value{%i}(ia(i)),%s(ib(i)),''b.'');\n',o,d.Simulation.name{o});
    fprintf(fid,'    end\n');
end
fprintf(fid,'    plot(xlim,xlim,''k-'')\n');
fprintf(fid,'    xlabel(''Simulation data in Benchmark-files'')\n');
fprintf(fid,'    ylabel(''simulation with Matlab''''s ODE solver'')\n');



fprintf(fid,'\n\n    %s maximal difference between simulation in the benchmark collection and simulation here\n','%');
fprintf(fid,'    [~,ia,ib]=intersect(d.Simulation.time,t);\n');
fprintf(fid,'    maxdiff = 0;\n');
fprintf(fid,'    reldiff = 0;\n');
    
for o=1:length(d.Simulation.name)
    fprintf(fid,'    for i=1:length(ia)\n');
    fprintf(fid,'        maxdiff = max(maxdiff,abs(d.Simulation.value{%i}(ia(i))-%s(ib(i))));\n',o,d.Simulation.name{o});
    fprintf(fid,'        reldiff = max(reldiff,abs(d.Simulation.value{%i}(ia(i))-%s(ib(i)))./max(1e-10,d.Simulation.value{%i}(ia(i))));\n',o,d.Simulation.name{o},o);
    fprintf(fid,'    end\n');
end
fprintf(fid,'    fprintf(''maxdiff=%sf,'',maxdiff)','%');
fprintf(fid,'\n');
fprintf(fid,'    fprintf(''reldiff=%sf,'',reldiff)','%');
fprintf(fid,'\n disp('' '')\n');
fprintf(fid,'else\n');
fprintf(fid,'    disp(''d.Simulation.value does not exist: Seems to be an empty prediction condition.'')\n');
fprintf(fid,'end\n');

fclose(fid);



%% Now we are writing the ODE rhs file containing \dot x = f(x,u,p):

fid = fopen('ODE_file.m','w');
fprintf(fid,'%s This function can be used in combination with a matlab integrator like ode15s for simulation the dynamics x(t) for this benchmark model.\n\n','%');
fprintf(fid,'%s The model corresponds to:\n','%');
fprintf(fid,'%s General_Info file=%s\n','%',I.file);
fprintf(fid,'%s model-file=%s\n','%',m.file);
fprintf(fid,'%s data-file=%s\n','%',d.file);
fprintf(fid,'\n');
fprintf(fid,'%s\n','function dxdt = ODE_file(t,x,p)');
fprintf(fid,'\n');
fprintf(fid,'timepoint = t;\n'); % required if step inputs are used

for i=1:length(pstrInv)
    fprintf(fid,'%s\n',pstrInv{i});
end
fprintf(fid,'\n');

for i=1:length(x0strInv)
    fprintf(fid,'%s\n',x0strInv{i});
end
fprintf(fid,'\n');

for i=1:length(m.ODEs.lhs)
    lhs = strrep(m.ODEs.lhs{i},'/dt','_dt');
    fprintf(fid,'%s = %s;\n',lhs,m.ODEs.rhs{i});
end


fprintf(fid,'dxdt = [...\n');
for i=1:(length(m.Initials.name)-1)
    fprintf(fid,'   %s_dt;...\n',strrep(m.Initials.name{i},'init_','d'));
end
fprintf(fid,'   %s_dt];\n',strrep(m.Initials.name{end},'init_','d'));


% % Defining step functions, step1 == heaviside 
% fprintf(fid,'\n\nfunction out = step1(t, level1, switch_time, level2)\n');
% fprintf(fid,'if t<switch_time\n');
% fprintf(fid,'   out = level1;\n');
% fprintf(fid,'else\n');
% fprintf(fid,'   out = level2;\n');
% fprintf(fid,'end\n');
% 
% 
% % Defining step functions, step2 == pulse
% fprintf(fid,'\n\nfunction out = step2(t, level1, switch_time1, level2, switch_time2, level3)\n');
% fprintf(fid,'if t<switch_time1\n');
% fprintf(fid,'   out = level1;\n');
% fprintf(fid,'elseif t<switch_time2\n');
% fprintf(fid,'   out = level2;\n');
% fprintf(fid,'else\n');
% fprintf(fid,'   out = level3;\n');
% fprintf(fid,'end\n');



fclose(fid);

status = 0;


function formel = Formula2Matlab(formel)
formel = strrep(formel,'*','.*');
formel = strrep(formel,'/','./');
formel = strrep(formel,'^','.^');
