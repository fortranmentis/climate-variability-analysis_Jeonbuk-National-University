'reinit'
'open corr_JFM_snow_sst.ctl'

'set mpdset lowres'
'set gxout shaded'
'basemap L 15 1 L'
'd maskout(corr,0.1-prob)'
'cbarm'
'draw title JFM'

'printim ./SNOW_DJF_corr_SST_JFM.png'

