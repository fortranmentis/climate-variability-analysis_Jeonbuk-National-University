'reinit'
'open comp_snow_JAN_sst_ASO.ctl'


'set gxout shaded'
'd maskout(comp,conf-0.10)'
'basemap L 15 1 L'
'cbarm'
'draw title ASO(conf-30)'

'printim ./SNOW_JAN_comp_SST_ASO(-30).png x4000 y3600 white'

