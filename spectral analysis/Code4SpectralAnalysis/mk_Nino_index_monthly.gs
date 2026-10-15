'reinit'
'sdfopen ../Data/sst.mnmean.nc'

'set x 1'; 'set y 1'; 'set z 1'
'set time jan1982 dec2018'
'define ind=aave(sst,lon=190,lon=240,lat=-5,lat=5)'

'set gxout fwrite'
'set fwrite Nino_monthly_JAN1982-DEC2018.gdat'
'd ind'
'disable fwrite'
