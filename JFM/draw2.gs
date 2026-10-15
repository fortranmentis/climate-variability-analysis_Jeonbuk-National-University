'reinit'
'open uwnd_snow_jfm.ctl'
'open vwnd_snow_jfm.ctl'

'set cthick 2.5'

'set gxout vector'
'set ccolor 9'
'd maskout(uwnd.1,0.1-prob);maskout(vwnd.2,0.1-prob)'

'basemap L 15 1 L'
'cbarm'

'draw title JFM'

'printim ./SNOW_JFM_corr_SST_FMA.png x4000 y3600 white'

