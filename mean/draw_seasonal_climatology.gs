'reinit'
'sdfopen /home/sang9604/climate_analysis/Data/sst.mnmean.nc'

'set t 1 12'
'define clim=ave(sst,t+0,time=dec2019.12)'
'modify clim seasonal'
'set t 1 last'
'define sclim=ave(clim,t-1,t+1)'
'set gxout shaded'

'set parea 1 5 5 8'
'set t 1'
'd sclim'
'draw title Winter (DJF)'

'set parea 6 10 5 8'
'set t 4'
'd sclim'
'draw title Spring (MAM)'

'set parea 1 5 1 4'
'set t 7'
'd sclim'
'draw title Summer (JJA)'

'set parea 6 10 1 4'
'set t 10'
'd sclim'
'draw title Fall (SON)'

'cbarm'
