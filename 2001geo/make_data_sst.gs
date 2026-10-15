'reinit'
'sdfopen ../2001geo/hgt.mon.mean.nc'

'set x 1 144'
'set y 1 73'
'set z 3'
'set time jan2000 jan2014'

**** Calculate Climatology ****
'set time jan2000 dec2000'
'define clim=ave(hgt,t+0,time=dec2015,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan2000 jan2014'
'define anom=hgt-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite geo(-12).gdat'

iyr=1999
while(iyr<2014)
iyr=iyr+1
'set time JAN'iyr
'd sanom'
endwhile

'disable fwrite'

