function MySetPath(action)
PathStr=genpath(pwd);
if strcmp(action,'add')
    addpath(PathStr);
elseif strcmp(action,'remove')
    rmpath(PathStr);
end