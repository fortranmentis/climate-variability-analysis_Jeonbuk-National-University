'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/precip.mon.mean.nc'

'set x 1 144'
'set y 1 72'
'set z 1'

'set time jan1982 dec2018'
'define pre=precip'

'set time jan1982 dec1982'
'define clim=ave(pre,t+0,time=dec2018,12)'
'modify clim seasonal'


'set time jan1982 dec2018'
'define anom=pre-clim'
'define sanom=ave(anom,t-1,t+1)'


'set gxout fwrite'
'set fwrite precip_test.gdat'
iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time dec'iyr
'd sanom'

endwhile
'disable fwrite'
