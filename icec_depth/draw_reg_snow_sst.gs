'reinit'

'open reg_snowdepth_icec_-8.ctl'
'open reg_snowdepth_air-8.ctl'

'set grads off'
'set font 10 file /usr/local/share/fonts/times.ttf'

'set dfile 1'
'set lon 0 360'
'set lat 50 90' 
'set mproj nps'


**** draw icec shaded ****
'set gxout shaded'
'clevsjy2 0.03 0'

'd corr.1'
'xcbar 1 10 0.5 0.7 -ft 60'

'define icesig=const(maskout(corr.1,0.1-prob.1),1)'
*dots var    size xint yint pc nc
'dots icesig 0.03 2.0  2.0  1  '

'set lat 50 90' 
'basemap L 0 1 L'

**** draw airt contour ****
'set dfile 2'
'set lon 0 360'
'set lat 50 90'
'set z 1'
'set t 1'
'set gxout contour'
'set mproj nps'

'set cthick 2'
'set clab masked'
'set ccolor 1'
'set clopts 1 10 0.1'
'd corr.2'

'set cstyle 1'
'set cint 0.015'
'set cthick 8'
'set ccolor 3'
'set clopts 1 12 0.12'
'd maskout(corr.2,0.1-prob.2)'


'set string 1 bl 12 0'
'set strsiz 0.14 0.14'
'draw string 1.0 0.09 Sea ice concentration [%/cm]'

'set string 1 bc 10 0'
'set strsiz 0.12 0.12'
'draw string 1.8 8.07 contour green: Significant part'

'set string 1 bc 10 0'
'set strsiz 0.12 0.12'
'draw string 1.74 8.3 contour: Air temperature [K]'

'set string 1 bc 10 0'
'set strsiz 0.12 0.12'
'draw string 1.49 7.84 dots: Significant part'


'draw title Jeonju Snowdepth(reg) AMJ(-8)\Sea ice concentration & Air temperature (850hpa)'
'printim ./reg_jj_icec_air(-8).png x1000 y800 white'
