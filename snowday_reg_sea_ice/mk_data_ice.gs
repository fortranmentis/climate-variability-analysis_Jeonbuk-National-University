'reinit'
'sdfopen ../sea_ice/icec.mnmean.nc'

'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan1983 jan2020'

**** Calulate Climatology ****
'set time jan1983 dec1983'
'define clim=ave(icec,t+0,time=jan2020,12)'
'modify clim seasonal'

**** Calulate Anoamly ****
'set time jan1983 jan2020'
'define anom=icec-clim'

'set gxout fwrite'
'set fwrite icec_JAN-12.gdat'

**** December data write ****
iyr=1982
while(iyr<2020)
iyr=iyr+1
'set time jan'iyr
'd anom'
endwhile

'disable fwrite'
