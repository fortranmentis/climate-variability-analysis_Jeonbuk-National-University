'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/precip.mon.mean.nc'

'set x 1'
'set y 1'
'set z 1'
'set time jan1982 dec2018'
'define ind=aave(precip,lon=115,lon=150,lat=30,lat=50)'


****Calculate climatology**** 
'set time jan1982 dec1982'
'define clim=ave(ind,t+0,time=dec2019,12)'
'modify clim seasonal'
****Calculate Anomaly****
'set time jan1982 dec2018'
'define anom=ind-clim'
'define sanom=ave(anom,t-1,t+1)'
******
'set gxout fwrite'
'set fwrite precip_ind.gdat'

iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time jul'iyr
'd sanom'

endwhile
'disable fwrite'
