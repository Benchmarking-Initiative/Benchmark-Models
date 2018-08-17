function [Is,ms,ds] = ReadBenchmarks(folder)
if ~exist(folder,'dir')
    error('Folder %s does not exist.',folder);
end

Is = ReadInfoFiles(folder);
ms = ReadModelFiles(folder);
ds = ReadDataFiles(folder);

