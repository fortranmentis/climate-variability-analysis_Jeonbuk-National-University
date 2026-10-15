'reinit'
'sdfopen ../2001sst/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan2000 jan2014'

**** Calculate Climatology ****
'set time jan2000 dec2000'
'define clim=ave(sst,t+0,time=dec2015,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan2000 jan2014'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst-12.gdat'

iyr=1999
while(iyr<2014)
iyr=iyr+1
'set time jan'iyr
'd sanom'
endwhile

'disable fwrite'

