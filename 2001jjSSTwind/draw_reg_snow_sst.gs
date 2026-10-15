'reinit'

'open reg_jj_sst-0.ctl'
'open reg_jj_uwnd-0.ctl'
'open reg_jj_vwnd-0.ctl'

'set dfile 1'
'set parea 1 9 1 7'
'set x 1 360'
'set y 1 180'
'set z 1'

'define sigsst=const(maskout(prob.1,0.1-prob.1),1)'
'set gxout shaded'
'clevsjy 0.015 0.02'
'd corr.1'

*dots var    size xint yint pc nc
'dots sigsst 0.02 2    2    1'
'basemap L 0 1 L'
'cbarm'

'set dfile 2;dfile 3'
'set parea 1 9 1 7'
'set x 1 144'
'set y 1 72.3'
'set z 1'

'set gxout vector'

'set ccolor 14'
'set cthick 6'
'd maskout(prob.2,0.1-prob.2);maskout(prob.3,0.1-prob.3)'
'run cbarm 1 1'

'draw title Jeonju Snowdepth(reg) JAN(-0)\SST & Wind'
'printim ./reg_jj_SST_wind(-0).png x4000 y3600 white'
