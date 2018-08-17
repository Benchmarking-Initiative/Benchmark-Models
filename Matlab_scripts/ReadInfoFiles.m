% I = ReadInfoFiles(folder)
%
%   Reading the General_info.xlsx file in the specified folder

function Is = ReadInfoFiles(folder)

if ~exist(folder,'dir')
    error('Folder %s does not exist.',folder);
else
    disp('Reading Info files ...');
end

d = dir(folder);
files = {d.name};
files = files(3:end); % exclude '.' '..'
iraus = strmatch('~',files);
files(iraus) = [];
drin = find(~cellfun(@isempty,regexp(files,'\.xlsx$')));
files = files(drin);
drin = find(~cellfun(@isempty,regexp(files,'^General_info')));
files = files(drin);

if isempty(files)
    error('No matching General_Info file found.')
end

for f=1:length(files)
    file = [folder,filesep,files{f}];
    if f==1
        Is = Read_core(file);
    else
        Is(f) = Read_core(file);
    end
end

function I = Read_core(file)
[status,sheets] = xlsfinfo(file);

I = struct;
I.parameters = struct;
I.data = struct;
I.replacement = struct;
I.file = file;

raw = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','General Info'));
I.info = raw;


raw = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','Parameters'));
icell = find(cellfun(@ischar,raw(:,3)));
[~,~,iheader] = intersect('lower boundary',raw(icell,3));
iheader = icell(iheader);
I.parameters.names = raw((iheader+1):end,1);
I.parameters.value = num2strCell(raw((iheader+1):end,2));
I.parameters.lb = num2strCell(raw((iheader+1):end,3));
I.parameters.ub = num2strCell(raw((iheader+1):end,4));
I.parameters.logscale = num2strCell(raw((iheader+1):end,5));

for i=1:length(I.parameters.logscale)
    if str2num(I.parameters.logscale{i})==1
        I.parameters.names{i} = I.parameters.names{i}(7:(end-1));  % log10(pname) -> pname
    end
end

raw = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','Experimental conditions'));
icell = find(cellfun(@ischar,raw(:,2)));
idata = strmatch('Data file',raw(icell,2));
idata = icell(idata);
if isempty(idata)
    error('Data files not found')
end
I.modelIndex = NaN(length(idata),1);
try    
    
    colnames = raw(idata(1)-1,:);
    iischar = find(cellfun(@ischar,colnames));
    raus = {'exp condition'    'nTimePoints'    'nDataPoints', 'chi2 value'};
    [~,ia]=intersect(colnames(iischar),raus);
    raus = colnames(1:max(iischar(ia))); % don't use annotations columns which are on the left
    I.replacement.old = setdiff(colnames(iischar),raus(cellfun(@ischar,raus)));
    [~,ia,ib] = intersect(I.replacement.old,colnames(iischar)); ib = iischar(ib);
    I.replacement.old = I.replacement.old(ia);
    I.replacement.new = raw(idata,ib);
    
    for i=1:length(idata)
        I.modelIndex(i) = sum(cellfun(@ischar,raw(1:idata(i),1)))-1;
        I.data_file(i) = raw(idata(i),2);

        [~,~,icol] =intersect('exp condition',colnames(iischar)); icol = iischar(icol); % colnames{2} causes an error
        if isnumeric(raw{idata(i),icol})
            I.data.number(i) = raw{idata(i),icol};
        else
            I.data.number(i) = str2num(raw{idata(i),icol});
        end
        [~,~,icol] =intersect('nTimePoints',colnames(iischar)); icol = iischar(icol); % colnames{2} causes an error
        if isnumeric(raw{idata(i),icol})
            I.data.ntimes(i) = raw{idata(i),icol};
        else
            I.data.ntimes(i) = str2num(raw{idata(i),icol});
        end
        [~,~,icol] =intersect('nDataPoints',colnames(iischar)); icol = iischar(icol); % colnames{2} causes an error
        if isnumeric(raw{idata(i),icol})
            I.data.ndata(i) = raw{idata(i),icol};
        else
            I.data.ndata(i) = str2num(raw{idata(i),icol});
        end
    end
catch ERR
    rethrow(ERR)
end




