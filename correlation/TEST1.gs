'reinit'
'open AOD_MODIS_1deg_MAR2000-FEB2019.ctl'

'set x 1'
'set y 1'
'set t 1 last'
'define jb=aave(aod,lon=126,lon=128,lat=34,lat=36)'
****Calculate climatology**** 
'set time jan2001 dec2001'
'define clim=ave(jb,t+0,time=dec2019,12)'
'modify clim seasonal'
****Calculate Anomaly****
'set time jan2001 feb2019'
'define anom=jb-clim'

******
'set gxout fwrite'
'set fwrite aod_JB_oct_2001-2018.gdat'

iyr=2000
while(iyr<2018)
iyr=iyr+1
'set time oct'iyr
'd anom'
endwhile

'disable fwrite'
