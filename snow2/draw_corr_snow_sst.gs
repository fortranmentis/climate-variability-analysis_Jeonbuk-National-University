'reinit'
'open corr_snow_JFM_sst_DJF_-12.ctl'

'set gxout shaded'
'd maskout(corr,0.1-prob)'
'basemap L 15 1 L'
'cbarm'
'draw title DJF(-12)'

'printim ./SNOW_JFM_corr_SST_DJF_-12.png x4000 y3600 white'

