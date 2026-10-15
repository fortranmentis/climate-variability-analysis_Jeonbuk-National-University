'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/sst.mnmean.nc'

'set x 1'
'set y 1'
'set z 1'
'set time jan1982 dec2018'
'define ind=aave(sst,lon=190,lon=240,lat=-5,lat=5)'
****Calculate climatology**** 
'set time jan1982 dec1982'
'define clim=ave(ind,t+0,time=dec2019,12)'
'modify clim seasonal'
****Calculate Anomaly****
'set time jan1982 dec2018'
'define anom=ind-clim'
'd anom'
