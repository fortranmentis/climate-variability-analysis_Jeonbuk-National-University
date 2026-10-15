lt=444; lm=1;
fid = fopen('./Nino_monthly_JAN1982-DEC2018.gdat','r');
ts = fread(fid,[lm,lt],'float32');
ind = ts(1,:);

time = [0:length(ind)-1]*(1/12) + 1982.0 ;  % construct time array
dT = 1;    % month    

[xs,c,h,Cx,f] = lanczosfilter(ind,dT,1/12,[ ],'high');

subplot(211), plot(time,ind,time,xs), legend('original','filtered'), axis tight
subplot(212), plot(f,h,f,abs(Cx)/max(abs(Cx)))

