'reinit'

'sdfopen sst.mnmean.nc'
'sdfopen precip.mon.mean.nc'
'sdfopen uwnd.mon.mean.nc'
'sdfopen vwnd.mon.mean.nc'

'set time jul2017'

'set dfile 1'
'set gxout shaded'
'set lon 0 360'
'set lat -90 90'
'set z 1'
'd sst.1'

'set dfile 2'
'set gxout contour'
'set z 1'
'd precip.2'

'set dfile 3'
'set z 1'
'set gxout vector'
'd skip(uwnd.3,3,3);vwnd.4' 
