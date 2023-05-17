%% This is the main script for the project
close all % close all windows

%% User defined inputs for the program
% define the name of the file to be used, the path is included
FileName = '/Users/surajmann/Documents/General/Uni/Coventry University/Year 2/5011CEM - Big Data/5011CEM2021_manns18/Model/o3_surface_20180701000000.nc';

% Test bad file
%FileName = '/Users/surajmann/Documents/General/Uni/Coventry University/Year 2/5011CEM - Big Data/5011CEM2021_manns18/Model/NaN.nc';

Processors = 6; % Input number of processors (workers) to test data on
Hours = 25; % input number of hours for period of data to be tested (25 = 1day)
DataSize = [250, 5000, 15000]; % input 3 various data segment sizes you wish to test (max = 277804)

%% MEMORY
% runs memory tests from files
Report_Results(FileName);

%% Test Data for Text and Nan errors, log results to Analysis.txt file
error = TestAndLog(FileName);
if error == 1 %% check for error
    fprintf('\nErrors in Data, check Log File and terminal for more info\n!'); % stop program
else % no error, run processing
    %% PROCESSING THE DATA

    fprintf('\nSEQUENTIAL PROCESSING:\n');
    % Runs sequential processing and returns array of results
    Sresults = Sequential_Processing(FileName, DataSize, Hours);

    fprintf('\nPARALLEL PROCESSING:\n');
    % run the parrallel processing with desire inputs and returns array of results
    Presults = Parallel_Processing(FileName, Processors, Hours, DataSize);

    %% PLOTS & PREDICTIONS
    % autoplots data from processing functions and provides prediction
    Plots(Sresults, Presults, Processors, DataSize);
end
