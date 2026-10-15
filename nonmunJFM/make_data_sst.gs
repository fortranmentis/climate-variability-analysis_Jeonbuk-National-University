'reinit'
'sdfopen ../nonmun/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan1983 mar2020'

**** Calculate Climatology ****
'set time jan1983 dec1983'
'define clim=ave(sst,t+0,time=mar2020,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan1983 mar2020'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst_JFM_-12.gdat'

iyr=1982
while(iyr<2020)
iyr=iyr+1
'set time feb'iyr
'd sanom'
endwhile

'disable fwrite'

