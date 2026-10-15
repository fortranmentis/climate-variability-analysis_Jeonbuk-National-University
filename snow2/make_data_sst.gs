'reinit'
'sdfopen ../nonmun/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time dec1982 feb2020'

**** Calculate Climatology ****
'set time dec1982 nov1983'
'define clim=ave(sst,t+0,time=feb2020,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time dec1982 feb2020'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst_JAN.gdat'

iyr=1981
while(iyr<2020)
iyr=iyr+1
'set time feb'iyr
'd sanom'
endwhile

'disable fwrite'

