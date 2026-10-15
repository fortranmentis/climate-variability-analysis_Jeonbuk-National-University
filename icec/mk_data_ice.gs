'reinit'
'sdfopen ../icec/icec.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time dec1981 feb2020'

**** Calulate Climatology ****
'set time dec1981 nov1982'
'define clim=ave(icec,t+0,time=jan2020,12)'
'modify clim seasonal'

**** Calulate Anoamly ****
'set time jan1982 jan2020'
'define anom=icec-clim'
'define sanom=ave(anom,t-1,t+1)'

'set gxout fwrite'
'set fwrite icec_DJF-12.gdat'

**** December data write ****
iyr=1981
while(iyr<2019)
iyr=iyr+1
'set time jan'iyr
'd sanom'
endwhile

'disable fwrite'
