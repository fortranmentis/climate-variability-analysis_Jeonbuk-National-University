'reinit'
'sdfopen ../nonmun/air.mon.mean.nc'

'set x 1 144'
'set y 1 73'
'set z 9'
'set time dec1981 apr2021'

**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(air,t+0,time=apr2021,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time dec1981 apr2021'
'define anom=air-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite airt_DJF_1981-2021.gdat'

iyr=1980
while(iyr<2020)
iyr=iyr+1
'set time jan'iyr
'd sanom'
endwhile

'disable fwrite'

