% ms = ReadModelFiles(folder)
% 
%   Reading the General_info.xlsx folder

function ms = ReadModelFiles(folder)
disp('Reading model files ...');

folder2 = [folder,filesep,'Model'];

d = dir(folder2);
files = {d.name};
files = files(3:end); % exclude '.' '..'
iraus = strmatch('~',files);
files(iraus) = [];
drin = find(~cellfun(@isempty,regexp(files,'\.xlsx$')));
files = files(drin);

for f=1:length(files)
    file = [folder2,filesep,files{f}];
    if f==1
        ms = Read_core(file);
    else
        ms(f) = Read_core(file);
    end    
    fprintf('%i out of %i model files done.\n',f,length(files));
end


function m = Read_core(file)
[status,sheets] = xlsfinfo(file);
NOSTATE = '___dummy___';

m = struct;
m.ODEs = struct;
m.Observables = struct;
m.Initials = struct;
m.file = file;

%Write ODEs, replace dummy state
if ~isempty(intersect(sheets,'ODEs'))
    raw = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','ODEs'));
    m.ODEs.lhs = strrep(raw(:,1),NOSTATE,'dummy');
%     ode_tmp = cell(size(raw,1),1);
%     for iode = 1:size(raw,1)
%        ode_tmp{iode} = replaceFunctions( raw(iode,2), m.specialFunc, 0 ); 
%     end
%     m.ODEs.rhs = strrep(ode_tmp,NOSTATE,'dummy');
    m.ODEs.rhs = strrep(raw(:,2),NOSTATE,'dummy');
end

raw = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','Observables'));
ichar = find(cellfun(@ischar,raw(:,1)));
indDef = strmatch('With definitions',raw(ichar,1));
indDef = ichar(indDef);

ind = find(~cellfun(@isempty,raw(:,1)) & cellfun(@ischar,raw(:,1)));
if ~isempty(indDef)
    ind = ind(ind<indDef);
end
ind = ind(ind>2);
for i=1:length(ind)
    if isempty(raw{ind(i),1})
        break
    end
    m.Observables.name{i} = strrep(raw{ind(i),1},' ','_');
    m.Observables.scale{i} = raw{ind(i),2};
    m.Observables.obsfun{i} = raw{ind(i),3};
    m.Observables.errormodel{i} = raw{ind(i),4};
    m.Observables.normalized{i} = raw{ind(i),5};
end


ind = find(~cellfun(@isempty,raw(:,1)) & cellfun(@ischar,raw(:,1)));
if ~isempty(indDef)
    ind = ind(ind>indDef);
    m.Observables.definition_lhs = cell(size(ind));
    m.Observables.definition_rhs = cell(size(ind));
    for i=1:length(ind)
        m.Observables.definition_lhs{i} = raw{ind(i),1};
        m.Observables.definition_rhs{i} = raw{ind(i),2};
    end
else
    m.Observables.definition_lhs = cell(0);
    m.Observables.definition_rhs = cell(0);
end

raw = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','Initials'));
ind = find(~cellfun(@isempty,raw(:,1)));
m.tstart = raw{3,2};
ind = ind(ind>3);
m.Initials.name = cell(size(ind));
m.Initials.value = cell(size(ind));
for i=1:length(ind)
    m.Initials.name{i} = strrep(raw{ind(i),1},NOSTATE,'dummy');
%     if(strcmp(raw{ind(i),2}(1),'('))
%         m.Initials.value{i} = regexprep(regexprep(raw{ind(i),2},'^(',''),')$','');
%     else
        m.Initials.value{i} = raw{ind(i),2};
%     end
end


