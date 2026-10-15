'reinit'

'open reg_gs_sst-12.ctl'
'open reg_gs_uwnd-12.ctl'
'open reg_gs_vwnd-12.ctl'

'set dfile 1'
'set parea 1 9 1 7'
'set x 1 360'
'set y 1 180'
'set z 1'

'define sigsst=const(maskout(prob.1,0.1-prob.1),1)'
'set gxout shaded'
'clevsjy 0.01 0.015'
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

'draw title Gunsan Snowdepth(reg) JAN(-12)\SST & Wind'
'printim ./reg_gs_SST_wind(-12).png x4000 y3600 white'
