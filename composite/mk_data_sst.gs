'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/sst.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan1982 may2019'
'define var=sst'

**** Calulate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(var,t+0,time=may2019,12)'
'modify clim seasonal'

**** Calulate Anoamly ****
'set time jan1982 may2019'
'define anom=var-clim'

'set gxout fwrite'
'set fwrite sst_DEC_1982-2018.gdat'

**** December data write ****
iyr=1981
while(iyr<2018)
iyr=iyr+1
'set time dec'iyr
'd anom'
endwhile

'disable fwrite'
