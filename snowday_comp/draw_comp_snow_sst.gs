'reinit'
'open comp_snowday_JAN_sst_JAN-12.ctl'


'set gxout shaded'
'd maskout(comp,conf-0.20)'
'basemap L 15 1 L'
'cbarm'
'draw title JAN-12'

'printim ./snowday_JAN_comp_SST_JAN-12.png x4000 y3600 white'

