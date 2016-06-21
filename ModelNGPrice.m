% Model & simulate Natural Gas prices
clear
try
    data = fetchNGData
catch
    sata = load('Data\NGSpot.mat')
end
S = data.NaturalGas;

x = log(S);
dx = diff(x);
dt = 1/261; % Time in years (261 observations per year)
dxdt = dx/dt;
x(end) = []; % To ensure the number of elements in x and dxdt match

% Fit a linear trend to estimate mean reversion parameters
coeff = polyfit(x, dxdt, 1);
res = dxdt - polyval(coeff, x);

revRate   = -coeff(1)
meanLevel = coeff(2)/revRate
vol       = std(res) * sqrt(dt)


OUmodel = hwv(revRate, meanLevel, vol,  'StartState', x(end))
NTrials = 1000;
NSteps  = 2000;


Xsim = simulate(OUmodel, NSteps, 'NTrials', NTrials, 'DeltaTime', dt);


Xsim = squeeze(Xsim); % Remove redundant dimension
Ssim = exp(Xsim);

% Visualize first 80 prices of 100 paths
plot(data.Date(end-20:end), S(end-20:end), data.Date(end)+(0:79), Ssim(1:80,1:100));
datetick; xlabel('Date'); ylabel('NG Spot Price');

% Save Model
% The calibrated model is saved in a m.-file for later use.

save SavedModels\NGPriceModel OUmodel dt
path = 14;
plot(data.Date, data.NaturalGas, 'b', data.Date(end)+(0:NSteps), Ssim(:,path), 'r');
title(['Historical & Simulated Prices, Path ' int2str(path)]);
datetick('x','keeplimits');

% calibration report.

NTrials = 12;
NSteps  = 2000;
Xsim = simulate(OUmodel, NSteps, 'NTrials', NTrials, 'DeltaTime', dt);
Ssim = exp(Xsim);

for path = 1:NTrials
    plot(data.Date, data.NaturalGas, 'b', data.Date(end)+(0:NSteps), Ssim(:,path), 'r');
    title(['Historical & Simulated Prices, Path ' int2str(path)]);
    datetick
    snapnow;
end
