% s=num2strCell(n)
% Konvertiert einen Array von Zahlen in eine Zelle von strings
%  oder eine Zelle von Zahlen in eine Zelle von strings.

function s=num2strCell(n)
s = cell(size(n));
if(iscell(n))
    for i=1:length(n)
        s{i}=num2str(n{i});
    end
else
    for i=1:length(n)
        s{i}=num2str(n(i));
    end
end
% s = cellfun('num2str',n);
