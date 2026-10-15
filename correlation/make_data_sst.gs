'reinit'
'sdfopen ../Data/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan1982 feb2019'

**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(sst,t+0,time=dec2019,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan1982 feb2019'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst_NDJ_1982-2018.gdat'

iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time dec'iyr
'd sanom'
endwhile

'disable fwrite'

