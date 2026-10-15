'reinit'
'open sst_NDJ_corr_wind.ctl'

'set mproj mollweide'
'set poli off'
'set gxout shaded'
'set grads off'
'set timelab off'
'clevsjy 0.075 0.1'
'd maskout(reg,0.1-prob)'
'basemap L 15 1 L'
'cbarm'
'draw title Correlation\Wind Speed-SST(NDJ)'

'printim ./SNOW_JAN_comp_SST_ASO.png white'

