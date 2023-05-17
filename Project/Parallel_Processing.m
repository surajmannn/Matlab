function [Parallel_Results] = Parallel_Processing(FileName, Processors, Hours, DataSize)
%% This script Parallel Processes the input data file via the input parameters

% Load Data
Contents = ncinfo(FileName);

Lat = ncread(FileName, 'lat');
Lon = ncread(FileName, 'lon');
NumHours = Hours; % Amount of hours of data to test from input argument
Parallel_Results = []; % Results array

%% Processing parameters
% ##  provided by customer  ##
RadLat = 30.2016;
RadLon = 24.8032;
RadO3 = 4.2653986e-08;

StartLat = 1;
NumLat = 400;
StartLon = 1;
NumLon = 700;



%% Create the parallel pool and attache files for use
poolobj = gcp;
% attaching a file allows it to be available at each processor without
% passing the file each time. This speeds up the process. For more
% information, ask your tutor.
addAttachedFiles(poolobj,{'/Users/surajmann/Documents/General/Uni/Coventry University/Year 2/5011CEM - Big Data/5011CEM2021_manns18/Common Files/EnsembleValue'});

%% AUTOMATED PARALLEL PROCESSING
for idx1 = 1:length(DataSize) % loops through each data method
    DataParameter = DataSize(idx1); % current data method
    for idx2 = 2:Processors % loops through number of processors
        WorkerParameter = idx2; % current processor
        %% Pre-allocate output array memory
        % the '-4' value is due to the analysis method resulting in fewer output
        % values than the input array.
        NumLocations = (NumLon - 4) * (NumLat - 4);
        EnsembleVectorPar = zeros(NumLocations, NumHours); % pre-allocate memory

        %% Cycle through the hours and load all the models for each hour and record memory use
        % We use an index named 'NumHour' in our loop
        % The section 'parallel processing' will process the data location one
        % after the other, reporting on the time involved.
        tic
        if isempty(gcp('nocreate')) % check if pool exists
            parpool('local', WorkerParameter);
        end
        for idxTime = 1:NumHours % loop through each hour of data
            %% 5: Load the data for each hour
            % Each hour we read the data from the required models, defined by the
            % index variable. Each model data are placed on a 'layer' of the 3D
            % array resulting in a 7 x 700 x 400 array.
            % We do this by indexing through the model names, then defining the
            % start position as the beginnning of the Lat, beginning of the Lon and
            % beginning of the new hour. We then define the number of elements
            % along each data dimension, so the total number of Lat, the total
            % number of Lon, but only 1 hour.
            % You can use these values to select a smaller sub-set of the data if
            % required to speed up testing o fthe functionality.

            DataLayer = 1;
            for idx = [1, 2, 4, 5, 6, 7, 8]
                HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
                    [StartLon, StartLat, idxTime], [NumLon, NumLat, 1]);
                DataLayer = DataLayer + 1;
            end

            %% 6: Pre-process the data for parallel processing
            % This takes the 3D array of data [model, lat, lon] and generates the
            % data required to be processed at each location.
            % ## This process is defined by the customer ##
            % If you want to know the details, please ask, but this is not required
            % for the module or assessment.
            [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);

            %% 9: The actual parallel processing!
            % Ensemble value is a function defined by the customer to calculate the
            % ensemble value at each location. Understanding this function is not
            % required for the module or the assessment, but it is the reason for
            % this being a 'big data' project due to the processing time (not the
            % pure volume of raw data alone).
            T4 = toc;
            parfor idx = 1:DataParameter % Cycles through data method
                [EnsembleVectorPar(idx, idxTime)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
            end
            T3(idxTime) = toc - T4; % record the parallel processing time for this hour of data
            fprintf('Parallel processing time for hour %i : %.1f s\n', idxTime, T3(idxTime))
            
        end % end time loop
        %% Print Results for each iteration of the loop and store in results array
        fprintf('Total processing time for %i data, for %i workers = %.2f s\n', DataParameter, WorkerParameter, sum(T3));
        format shortG
        Parallel_Results = [Parallel_Results; DataParameter, WorkerParameter, sum(T3)]; % Append results to results array
        delete(gcp); % delete pool 
    end % end workers loop
end % end data size loop

%% 10: Reshape ensemble values to Lat, lon, hour format
EnsembleVectorPar = reshape(EnsembleVectorPar, 696, 396, []);
T2 = toc;
end % end function