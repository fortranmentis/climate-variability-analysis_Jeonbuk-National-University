'reinit'
'sdfopen /home/sang9604/climate_analysis/gisang/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time dec1981 dec2019'

**** Calculate Climatology ****
'set time dec1981 nov1982'
'define clim=ave(sst,t+0,time=dec2019,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time dec1981 dec2019'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst_NDJ_1981-2019.gdat'

iyr=1980
while(iyr<2019)
iyr=iyr+1
'set time dec'iyr
'd sanom'
endwhile

'disable fwrite'

