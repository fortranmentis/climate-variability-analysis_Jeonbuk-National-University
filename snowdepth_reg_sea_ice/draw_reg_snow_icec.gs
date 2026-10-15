'reinit'
'open reg_snowdepth_JAN_icec_JAN-0.ctl'

'set lat 50 90'
'set mproj nps'
'set gxout shaded'
'set grads off'
'set timelab off'
'clevsjy 0.1 0.5'
'd maskout(corr,0.1-prob)'
'basemap L 15 1 L'

'cbarm'
'draw title Regression\Snowdepth & Icec JAN-0'

'printim ./snowdepth_JAN_reg_icec-JAN-0.png x4000 y3090 white'

