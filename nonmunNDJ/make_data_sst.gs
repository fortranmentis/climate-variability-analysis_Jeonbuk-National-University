'reinit'
'sdfopen ../nonmun/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time dec1981 mar2021'

**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(sst,t+0,time=mar2021,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time dec1981 mar2021'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst_SON_1981-2021.gdat'

iyr=1980
while(iyr<2020)
iyr=iyr+1
'set time oct'iyr
'd sanom'
endwhile

'disable fwrite'

