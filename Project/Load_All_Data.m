function [AllDataMem] = Load_All_Data(FileName) 
%% Load all the model data together

Contents = ncinfo(FileName); % Store the file content information in a variable.
for idx = 1: 8
    AllData(idx,:,:,:) = ncread(FileName, Contents.Variables(idx).Name); 
    %fprintf('Loading %s\n', Contents.Variables(idx).Name); % display loading information
end

AllDataMem = whos('AllData').bytes/1000000; 
%fprintf('Memory used for all data: %.3f MB\n', AllDataMem)
end