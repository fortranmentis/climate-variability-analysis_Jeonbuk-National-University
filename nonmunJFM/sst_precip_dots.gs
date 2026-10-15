'reinit'
'sdfopen ../0.Data/sst.mnmean.nc'
'sdfopen ../0.Data/precip.mon.mean.nc'

'set dfile 1'
'set x 1 360'
'set y 1 180'
'set z 1'
'set time jan2000'
'set gxout shaded'
'clevsjy 1'

'set parea 1 9 1 7'

'd sst.1'

'set dfile 2'
'set x 1 144'
'set y 1 72'
'set z 1'
'set time jan2000'
'set rgb 66 102 255 102'
'set parea 1 9 1 7'

'dots precip.2 0.5 3 3 66 2'

'cbarm 1 0'

'printim ./test_NY.png x4000 y3600 white'

