
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
