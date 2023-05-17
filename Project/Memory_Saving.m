%% This script allows you to open and explore the data in a *.nc file
clear all % clear all variables
close all % close all windows

% define the name of the file to be used, the path is included
FileName = '/Users/surajmann/Documents/General/Uni/Coventry University/Year 2/5011CEM - Big Data/5011CEM2021_manns18/Model/o3_surface_20180701000000.nc';

%PoolSize = 6; % Input amount of processors (workers) to run
%Hours = 1:25; % input period length of data to be tested
%DataSize = [250, 5000, 15000]; % input various data sizes you wish to test

%TestData();

% runs the parrallel processing with desire inputs and returns array of results
%results = ParallelProcessing(FileName, PoolSize, Hours, DataSize); 

% autoplots data from parallel processing for visualisation
%Graphs(results);

% runs memory tests from files
AllDataMem = LoadAllData(FileName);
HourDataMem = LoadHours(FileName);
HourMem = LoadAllHours(FileName);
Reportresults(AllDataMem, HourDataMem, HourMem);