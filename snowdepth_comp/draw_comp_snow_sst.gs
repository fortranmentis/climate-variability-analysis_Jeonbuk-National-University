'reinit'
'open comp_snowdepth_JAN_sst_JAN-12.ctl'


'set gxout shaded'
'd maskout(comp,conf-0.50)'
'basemap L 15 1 L'
'cbarm'
'draw title JAN-12'

'printim ./snowdepth_JAN_comp_SST_JAN-12.png x4000 y3600 white'

