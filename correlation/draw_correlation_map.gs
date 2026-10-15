'reinit'
'set grads off'
'open sst_NDJ_regressed_onto_Jeonju_precip.ctl'

'set gxout shaded'
'clevsjy2 0.1'
'set mproj mollweide'
'set grid off'
'd maskout(corr,0.05-prob)'
'basemap L 15 1 L'
'cbarm'

'printim ./sst_NDJ_correlation_Jeonju_precip.png white'
