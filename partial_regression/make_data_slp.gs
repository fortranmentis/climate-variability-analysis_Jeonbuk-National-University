'reinit'
'sdfopen /home/sang9604/climate_analysis/partial_regression/mslp.mon.mean.nc'

'set x 1 144'
'set y 1 73'
'set z 1'
'set time jan1982 feb2019'

**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(mslp,t+0,time=dec2019,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan1982 feb2019'
'define anom=mslp-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite slp_NDJ_1982-2018.gdat'

iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time dec'iyr
'd sanom'
endwhile

'disable fwrite'
