'reinit'

'open reg_jj_air-0.ctl'
'open reg_jj_geo-0.ctl'

'set dfile 1;dfile 2'
'set parea 1 9 1 7'
'set x 1 144'
'set y 1 73'

'basemap L 0 1 L'

**** draw air temp shaded ****
'set gxout shaded'
'clevsjy 0.12 0.55'
'd prob.1'
'cbarm'

'define airsig=const(maskout(prob.1,0.1-prob.1),1)'
'set parea 1 9 1 7'
*dots var    size xint yint pc nc
'dots airsig 0.04 2    2    1'

**** draw hgt contour ****
'set gxout contour'
'set cthick 2'
'set clab masked'

'set ccolor 1'
'd prob.2'
'set cthick 12'
'set ccolor 14'
'd maskout(prob.2,0.1-prob.2)'

'draw title Jeonju Snowdepth(reg) JAN(-0)\Air Temperature & Geopotential height'
'printim ./reg_jj_air_geo(-0).png x2000 y1600 white'
