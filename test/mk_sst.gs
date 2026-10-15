'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'

'set time jan1982 apr2019'

'set time jan1982 dec1982'
'define clim=ave(sst,t+0,time=dec2019,12)'
'modify clim seasonal'


'set time jan1982 apr2019'
'define anom=sst-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite sst_ano.gdat'

iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time feb'iyr
'd anom'

endwhile
'disable fwrite'
