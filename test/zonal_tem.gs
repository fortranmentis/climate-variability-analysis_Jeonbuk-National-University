'reinit'
'sdfopen /home/sang9604/climate_analysis/test/air.mon.mean.nc'

'set lev 1000 100'
'set t 1 12'
'define clim=ave(air,t+0,time=dec2019,12)'
'modify clim seasonal'
'set t 1 last'
'define sclim=ave(clim,t-1,t+1)'
'set x 1'
'define zsclim=ave(sclim,lon=0,lon=360)'
'set gxout shaded'



'set parea 1 5 3 6'
'set t 1'
'd zsclim'
'draw title Winter (DJF)'


'set parea 6 10 3 6'
'set t 7'
'd zsclim'
'draw title Summer (JJA)'

'cbarm 0.95'
