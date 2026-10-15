'reinit'
'open corr_snow_JFM_sst_JFM_-12.ctl'

'set gxout shaded'
'd maskout(corr,0.1-prob)'
'basemap L 15 1 L'
'cbarm'
'draw title JFM-12'

'printim ./SNOW_JFM_corr_SST_JFM_-12.png x4000 y3600 white'

