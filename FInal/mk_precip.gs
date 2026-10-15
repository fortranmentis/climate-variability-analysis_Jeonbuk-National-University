'reinit'
'sdfopen /home/sang9604/climate_analysis/FInal/precip.mon.mean.nc'

'set x 1 144'
'set y 1 72'
'set z 1'
'set time jan1990 dec2018'
'define pre=precip'
****Calculate climatology**** 
'set time jan1990 dec1990'
'define clim=ave(pre,t+0,time=dec2019,12)'
'modify clim seasonal'
****Calculate Anomaly****
'set time jan1990 dec2018'
'define anom=pre-clim'
'define sanom=ave(anom,t-1,t+1)'
******
'set gxout fwrite'
'set fwrite pre_NDJ_1990-2018.gdat'

iyr=1989
while(iyr<2018)
iyr=iyr+1
'set time dec'iyr
'd sanom'

endwhile
'disable fwrite'
