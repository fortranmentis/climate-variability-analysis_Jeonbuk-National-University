'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/sst.mnmean.nc'

'set x 1'
'set y 1'
'set z 1'
'set time jan1982 dec2018'
'define ind=aave(sst,lon=190,lon=240,lat=-5,lat=5)'
**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(ind,t+0,time=dec2018,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan1982 dec2018'
'define anom=ind-clim'
'define sanom=ave(anom,t-1,t+1)'

**** Write Data ****
'set gxout fwrite'
'set fwrite Nino_index_NDJ_1982-2018.gdat'

iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time dec'iyr
'd sanom'
endwhile
'disable fwrite'
