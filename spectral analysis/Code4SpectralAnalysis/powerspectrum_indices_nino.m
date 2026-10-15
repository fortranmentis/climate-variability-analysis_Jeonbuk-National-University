%WAVETEST Example Matlab script for WAVELET, using NINO3 SST dataset
%
% See "http://paos.colorado.edu/research/wavelets/"
% Written January 1998 by C. Torrence
%
% Modified Oct 1999, changed Global Wavelet Spectrum (GWS) to be sideways,
%   changed all "log" to "log2", changed logarithmic axis on GWS to
%   a normal axis.
clear all;
close all;
fname = {'Nino_index'};
    
lt=444; lm=1;
fid = fopen('./Nino_index_monthly_JAN1982-DEC2018.gdat','r');
pct = fread(fid,[lm,lt],'float32');
varbl = pct(1,:);

% ---- Some other factors to be modified -------%
lag1 = 0.955;  % lag-1 autocorrelation for red noise background
siglev = 0.95; % significance level (e.g., 95%, 99%)

%--------------------------- Computation --------------------------------
% normalize by standard deviation (not necessary, but makes it easier
% to compare with plot on Interactive Wavelet page, at
% "http://paos.colorado.edu/research/wavelets/plot/"
variance = std(varbl)^2;
varbl = (varbl - mean(varbl))/sqrt(variance) ;

n = length(varbl);
dt = 1 ;
time = [1:length(varbl)]*dt + 0 ;  % construct time array
xlim = [1,n]; % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.01;    % lower ==> better resolution
s0 = 2*dt;    % this says start at a scale of 2 months
j1 = round((log2(n*dt/s0))/dj);
mother = 'Morlet';

% Wavelet transform:
[wave,period,scale,coi] = wavelet(varbl,dt,pad,dj,s0,j1,'morlet');
power = (abs(wave)).^2 ;        % compute wavelet power spectrum

% Global wavelet spectrum & significance levels:
global_ws = variance*(sum(power')/n);   % time-average over all times
dof = n - scale;  % the -scale corrects for padding at edges
[global_signif,fft_global] = wave_signif(variance,dt,scale,1,lag1,siglev,dof,'morlet');

%---------------------------- Plotting ---------------------------------
% levels = [0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
 Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));

%--- Plot global wavelet spectrum
P1_max = max(global_ws)
P1=plot(log2(period),global_ws/P1_max, 'k','linewidth',2)
set(gca,'XLim',log2([min(period),max(period)]), ...
       'YLim',[0,1.1], ...
       'XDir','reverse', ...
       'XTick',log2(Yticks(:)), ...
       'XTickLabel',Yticks)

hold on
plot(log2(period),fft_global/P1_max,'color','r','linestyle','--','linewidth',1)
plot(log2(period),global_signif/P1_max,'color','r','linestyle','-.','linewidth',1)
hold on

% Create ylabel
ylabel('Power (Normalized)','FontSize',13,'FontName','Times');

% Create title
title('Power spectral density (ENSO index)','FontWeight','demi','FontSize',15,'FontName','Times');

% Create xlabel
xlabel('Period (Month)','FontSize',13,'FontName','Times');

% end of code
 print('-f1',fname{1},'-dpng')
