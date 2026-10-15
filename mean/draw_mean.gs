'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/uwnd.mon.mean.nc'

'set lev 1000 200'
'set t 1 12'
'define clim=ave(uwnd,t+0,time=dec2019.12)'
'modify clim seasonal'
'set t 1 last'
'define sclim=ave(clim,t-1,t+1)'
'set x 1'
'define zsclim=ave(sclim,lon=0,lon=360)'
'set gxout shaded'

'set parea 1 5 5 8'
'set t 1'
'd zsclim'
'draw title Winter (DJF)'

'set parea 6 10 5 8'
'set t 4'
'd zsclim'
'draw title Spring (MAM)'

'set parea 1 5 1 4'
'set t 7'
'd zsclim'
'draw title Summer (JJA)'

'set parea 6 10 1 4'
'set t 10'
'd zsclim'
'draw title Fall (SON)'

'cbarm'
