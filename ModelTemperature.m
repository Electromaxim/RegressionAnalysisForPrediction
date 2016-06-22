% Compute mean (yearly average) and remove it from the series
m = mean(drybulb)
drybulb0 = drybulb - m;

% Fit double-sine model
model = fit(dates, drybulb0, 'sin2')

%% Visualize Model Accuracy
pred = model(dates) + m;
res = drybulb - pred;
fitPlot(dates, [drybulb pred], res);
disp(['Mean Absolute Error: ' num2str(mean(abs(res))) ' degrees F']);

% Analyze Serial Correlation in Residuals
figure;
subplot(2,1,1);
autocorr(res,50);
title('Serial Correlation of Stochastic series');
subplot(2,1,2);
parcorr(res(1:1000),50);

% Modeling the Stochastic Component with a seasonal AR model
lags = [1 2 3 4 23 24 25 47 48 49];
Xres = lagmatrix(res, lags);
[beta, betaci, res2] = regress(res, Xres);
disp('Lags Coefficients and Confidence Intervals');
disp([lags' beta betaci])

% Analyze Residuals of Regression for Serial Correlation
figure;
subplot(2,1,1);
plot(dates, res2); datetick
title('Regression Residuals & Their Serial Correlation');
subplot(2,1,2);
autocorr(res2(lags(end)+1:end),50);

%% Fit a Distribution to Residuals
PD = fitdist(res2, 'tlocationscale');

%% Summary of model
% The temperature model can now be defined by,
% 
% * The mean temperature "m"
% * The sinusoidal model "model"
% * Regression parameters "beta"
% * Autocorrelation lags "lags"
% * The residual probability distribution "PD"
% * Optional presample data (the last observations of temperature for regression)
tempModel = struct('m', m, 'sinmodel', model, 'reglags', lags, 'regbeta', beta, 'dist', PD, 'presample', res(end-lags(end)+1:end));
save SavedModels\TemperatureModel.mat -struct tempModel
clearvars -except tempModel dates drybulb

% Simulate our model
newDates = dates(end-365*24+1:end);
simTemp = simulateTemperature(tempModel, newDates, 1);

% Plot simulation results
ax1 = subplot(2,1,1);
plot(newDates, drybulb(end-365*24+1:end))
title('Actual Temperatures');
ax2 = subplot(2,1,2);
plot(newDates, simTemp);
title('Simulated Temperatures');
linkaxes([ax1 ax2], 'x');
dynamicDateTicks([ax1 ax2], 'linked');
