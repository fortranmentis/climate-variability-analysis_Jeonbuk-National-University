'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan1982 dec2018'

**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(sst,t+0,time=dec2018,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan1982 dec2018'
'define anom=sst-clim'

**** Write Data ****
'set gxout fwrite'
'set fwrite sst_mon_amon_JAN1982-DEC2018.gdat'
'd anom'
'disable fwrite'
