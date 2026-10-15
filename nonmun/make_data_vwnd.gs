'reinit'
'sdfopen ../nonmun/vwnd.mon.mean.nc'

'set x 1 144'
'set y 1 73'
'set z 3'
'set time dec1981 mar2021'

**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(vwnd,t+0,time=mar2021,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time dec1981 mar2021'
'define anom=vwnd-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite vwnd_SON_1981-2021.gdat'

iyr=1980
while(iyr<2020)
iyr=iyr+1
'set time oct'iyr
'd sanom'
endwhile

'disable fwrite'

