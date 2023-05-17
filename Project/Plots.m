function Plots(Sresults, Presults, Processors, DataSize)
%% Plotting graphs in Matlab

%% Create xVals array which is every processor used for the data analysis

NumProcessors = Processors-1; % Set number of processors from parallel processing
legendString = cellstr(num2str(DataSize', '%-d Data')); % create legend string array for DataSize elements

xVals = [];
y1Vals = [];
y2Vals = [];
y3Vals = [];
for num = 1:Processors % create xVals array with each processor used as elements
    xVals(num) = num;
end

%% Separate and combine results arrays into indivual data methods
y1Vals = [Sresults(1,2);  Presults(1:NumProcessors,3)];
y2Vals = [Sresults(2,2); Presults((NumProcessors+1):(NumProcessors*2),3)];
y3Vals = [Sresults(3,2); Presults(((NumProcessors*2)+1):(NumProcessors*3),3)];

%% Reshape matrix into row vector
y1Vals = reshape(y1Vals,1,[]);
y2Vals = reshape(y2Vals,1,[]);
y3Vals = reshape(y3Vals,1,[]);

%% DataSize element 1 - processing times line graph plot
figure(1)
yyaxis left
plot(xVals, y1Vals, '-bd')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')

legend(legendString(1))

%% DataSize 2 - processing times line graph plot
figure(2)
yyaxis right
plot(xVals, y2Vals, '-rx')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')

legend(legendString(2))

%% DataSize 3 - processing times line graph plot
figure(3)
yyaxis left
plot(xVals, y3Vals, '-gv')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')
legend(legendString(3))

%% Time to process one segment of data
format shortG
y1MeanVals = y1Vals / DataSize(1);
y2MeanVals = y2Vals / DataSize(2);
y3MeanVals = y3Vals / DataSize(3);

%% Plot all 3 Data Methods on same Plot - line graph
figure(4)
plot(xVals, y1MeanVals, '-bd')
hold on
plot(xVals, y2MeanVals, '-rx')
hold on
plot(xVals, y3MeanVals, '-gv')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Mean Processing time vs number of processors')
legend(legendString)

%% Plot Bar Graph
figure(5)
y = [y1MeanVals; y2MeanVals; y3MeanVals];
bar(xVals, y)
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Mean Processing time vs number of processors')
legend(legendString)

%% use linear regression on results to work out equation and prediction

% extract useful data for equation (sequential does not benefit prediction)
DataProcessors = xVals(2:Processors);
Y1 = y1MeanVals(2:Processors);
Y2 = y2MeanVals(2:Processors);
Y3 = y3MeanVals(2:Processors);
Y = (Y1 + Y2 + Y3) / 3; % Take mean of all method processing times


fitlm(DataProcessors, Y) % fit linear regression with Number of Processors as predictor and time as response
coefficient = polyfit(DataProcessors, Y, 1); % work out coefficients
x = ceil((0.00103+coefficient(2) / - coefficient(1))); % Predict number of processors using equation
fprintf('\nEQUATION = %i + %i*Processors\n', coefficient(2), coefficient(1)); % Print equation
fprintf('\nPredicted Number of Processors Needed: %i\n', x); % print prediction

end % end function




