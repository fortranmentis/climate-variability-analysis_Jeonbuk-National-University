'reinit'
'sdfopen ../Data/sst.mnmean.nc'

'set x 1'; 'set y 1'; 'set z 1'
'set time jan1982 dec2018'
'define ind=aave(sst,lon=190,lon=240,lat=-5,lat=5)'

'define mean=ave(ind,time=jan1982,time=dec2018)'
'define nino=ind-mean'

***** Write data in binary format (.gdat) *****
'set gxout fwrite'
'set fwrite Nino_monthly_JAN1982-DEC2018.gdat'
'd nino'
'disable fwrite'

***** Write data in netcdf format (.nc) *****
'set sdfwrite -4d nino.nc'
'sdfwrite nino'
