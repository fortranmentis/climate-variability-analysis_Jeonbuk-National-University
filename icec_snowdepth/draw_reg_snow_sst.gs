'reinit'

'open reg_snowdepth_icec_-12.ctl'
'open reg_snowdepth_hgt-12.ctl'

'set grads off'

'set mproj nps'
'set lat 50 90' 
'set dfile 1;dfile 2'
'set font 10 file /usr/local/share/fonts/times.ttf'

**** draw air temp shaded ****
'set gxout shaded'
'clevsjy2 0.03'

'd corr.1'
'xcbar 1 10 0.24 0.44 -ft 60'

'define icesig=const(maskout(corr.1,0.1-prob.1),1)'
*dots var    size xint yint pc nc
'dots icesig 0.03 2.0  2.0  1  '

'set lat 50 90' 
'basemap L 0 1 L'

**** draw hgt contour ****
'set gxout contour'
'set mproj nps'
'set lat 49 90' 

'set cint 0.2'
'set cthick 2'
'set clab masked'
'set ccolor 1'
'set clopts 1 10 0.1'
'd corr.2'

'set cstyle 1'
'set cint 0.2'
'set cthick 12'
'set ccolor 3'
'set clopts 1 12 0.12'
'd maskout(corr.2,0.1-prob.2)' 

'set font 10 file /usr/local/share/fonts/times.ttf'

'set string 1 bl 12 0'
'set strsiz 0.14 0.14'
'draw string 1.0 0.5 Sea ice concentration'

'set string 1 bc 10 0'
'set strsiz 0.12 0.12'
'draw string 1.6 8.07 contour: Geopotential height'

'set string 1 bc 10 0'
'set strsiz 0.12 0.12'
'draw string 1.35 8.3 dots: Significant part'

'set string 1 bc 10 0'
'set strsiz 0.12 0.12'
'draw string 1.67 7.84 contour green: Significant part'


'draw title Jeonju Snowdepth(reg) DJF(-12)\Sea ice concentration & Geopotential height'
'printim ./reg_jj_icec_geo(-12).png x1000 y800 white'
