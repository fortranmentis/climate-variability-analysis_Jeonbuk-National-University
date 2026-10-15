'reinit'
'sdfopen /home/sang9604/climate_analysis/FInal/olr.mon.mean.nc'

'set x 1 144'
'set y 1 73'
'set z 1'
'set time jan1990 dec2018'
****Calculate climatology**** 
'set time jan1990 dec1990'
'define clim=ave(olr,t+0,time=dec2019,12)'
'modify clim seasonal'
****Calculate Anomaly****
'set time jan1990 dec2018'
'define anom=olr-clim'
'define sanom=ave(anom,t-1,t+1)'
******
'set gxout fwrite'
'set fwrite olr_JJA_1990-2018.gdat'

iyr=1989
while(iyr<2018)
iyr=iyr+1
'set time jul'iyr
'd sanom'

endwhile
'disable fwrite'
