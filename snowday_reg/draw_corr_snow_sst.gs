'reinit'
'open reg_snowday_JAN_sst_JAN-12.ctl'

'set gxout shaded'
'd maskout(corr,0.1-prob)'
'basemap L 15 1 L'
'cbarm'
'draw title JAN-12'

'printim ./snowdepth_JAN_reg_SST_JAN-12.png x4000 y3600 white'

