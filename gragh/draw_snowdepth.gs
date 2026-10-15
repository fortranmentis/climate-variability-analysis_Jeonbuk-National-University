'reinit'

'open snowdepth.ctl'

'set grads off'

'set strsiz 3 1'
'set font 10 file /usr/local/share/fonts/times.ttf'

'set gxout scatter'
'set x 1'
'set y 1'
'set z 1'
'set time dec1982 feb2020'

'set vrange -15 75'
'set ccolor 1'
'set cthick 10'
'set parea 1 10 1 8'
'd ind'


'set vrange -15 75'
'set cmark 13'
'set ccolor 1'
'set cthick 5'
'define mean = ave(ind,t=1,t=38)'
'define sdind = sqrt(ave(pow(ind,2),t=1,t=38))'
'define SD1 = mean + sdind'
'define SD2 = mean - sdind'

'set cmark 13'
'set ccolor 1'
'set cthick 5'
'd SD1'
'set cmark 13'
'set ccolor 1'
'set cthick 5'
'd SD2'


'draw title Maximum snowdepth STDV (DJF)'
'draw xlab Years'
'draw ylab Maximum snowdepth (cm)'

'printim ./DJF_snowdepth_SD.png x4000 y3600 white'
