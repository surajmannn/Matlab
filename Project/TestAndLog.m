function [error] = TestAndLog(FileName)
%% Script to examine NetCDF data formats and check for NaN

%% Test File with Errors
NaNErrors = 0;
error = 0;
%% Set file to test
Contents = ncinfo(FileName); % Store the file content information in a variable.

%% Test for Text
% Define plain text variable types
DataTypes = {'NC_Byte', 'NC_Char', 'NC_Short', 'NC_Int', 'NC_Float', 'NC_Double'};

FileID = netcdf.open(FileName,'NC_NOWRITE'); % open file read only and create handle
for idx = 0:size(Contents.Variables,2)-1 % loop through each variable
    % read data type for each variable and store
    [~, datatype(idx+1), ~, ~] = netcdf.inqVar(FileID,idx);
end
% display data types
DataInFile = DataTypes(datatype)'

% find character data types
FindText = strcmp('NC_Char', DataInFile);

% print results
fprintf('\nTesting file: %s\n', FileName)
if any(FindText)
    fprintf('\nError, text variables present:\n')
    error = 1;
else
    fprintf('\nAll data is numeric, continue analysis.\n')
end

%% Test for Nan and create log
% Create and open log file
LogFileName = 'AnalysisLog.txt';

% create new log file, 'w' replaces the file if present. To continually
% append, use 'a'
LogID = fopen('AnalysisLog.txt', 'w'); % option to clear code
LogID = fopen('AnalysisLog.txt', 'a+'); % append instead of write a+
fprintf(LogID, '%s: Starting analysis of %s\n', datestr(now, 0), FileName);

StartLat = 1;
StartLon = 1;

fprintf('\nTesting files: %s\n', FileName)
for idxHour = 1:25
    
    for idxModel = 1:8
        Data(idxModel,:,:) = ncread(FileName, Contents.Variables(idxModel).Name,...
            [StartLat, StartLon, idxHour], [inf, inf, 1]); % 'inf' reads all the data
    end
    
    % check for NaNs
    if any(isnan(Data), 'All')
        NaNErrors = 1;
        %% display warning
        fprintf('\nNaNs present\n')
        ErrorModel = find(isnan(Data), 1, 'first');
        %% find first error:
        fprintf('Analysis for hour %i is invalid, NaN errors recorded in model %s\n',...
            idxHour, Contents.Variables(ErrorModel).Name)
        
        % Write to log file
        fprintf(LogID, '%s: %s processing data hour %i\n', datestr(now, 0), 'NaN Error', idxHour);
    else
        % write to log file
        fprintf(LogID, '%s: %s processing data hour %i\n', datestr(now, 0), 'Success', idxHour);
    end
    
end
 fclose(LogID);

if ~NaNErrors
    fprintf('\nNo errors!\n')
else
    error = 1;
end

end % end function