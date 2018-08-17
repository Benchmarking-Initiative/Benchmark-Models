% ds = ReadDataFiles(folder)
% 
%   Reading xlsx files in the Data folder
%   DAta files are search in the subfolder "Data" in folder.

function ds = ReadDataFiles(folder)
disp('Reading data files ...');

folder2 = [folder,filesep,'Data'];

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
        ds = Read_core(file);
    else
        ds(f) = Read_core(file);
    end    
    fprintf('%i out of %i data files done.\n',f,length(files));
end


function d = Read_core(file)
[status,sheets] = xlsfinfo(file);


d = struct;
d.ExpData = struct;
d.Simulation = struct;
d.file = file;

num = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','Exp Data'));
txt = num(1,:);
num = num(2:end,:);
%num(2:end,end:(size(num,2))) = NaN;
ind = 1:size(num(:,1));
% ind = ind(ind>2);
d.ExpData.time = str2double(num(ind,1));
d.ExpData.timePar = txt{1,1};
ii = 0;
for i=2:3:size(num,2)
    ii = ii+1;
    d.ExpData.value{ii} = str2double(num(ind,i));
    d.ExpData.SDexp{ii} = str2double(num(ind,i));
    d.ExpData.SDmodel{ii} = str2double(num(ind,i));
    d.ExpData.name{ii} = strrep(txt{1,i},' ','_');
end

num = table2cell(readtable(file,'ReadVariableNames',false,'Sheet','Simulation'));
txt = num(1,:);
num = num(2:end,:);
ind = 1:size(num(:,1));
% ind = ind(ind>2);
d.Simulation.time = str2double(num(ind,1));
for i=2:size(num,2)
    d.Simulation.value{i-1} = str2double(num(ind,i));
    d.Simulation.name{i-1} = strrep(txt{1,i},' ','_');
end

    

