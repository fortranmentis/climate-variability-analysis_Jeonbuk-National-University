'reinit'
'open reg_snowday_JAN_icec_MAR-10.ctl'

'set lat 50 90'
'set mproj nps'
'set gxout shaded'
'set grads off'
'set timelab off'
'clevsjy 0.3 1'
'd maskout(corr,0.1-prob)'
'basemap L 15 1 L'

'cbarm'
'draw title Regression\Snowday & Icec MAR-10'

'printim ./snowday_JAN_reg_icec_MAR-10.png x4000 y3090 white'

