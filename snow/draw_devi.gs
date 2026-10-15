'reinit'
'open detrended_snow_DEC_1983-2020.ctl'

'set grads off'
'set gxout scatter'
'set x 1'
'set y 1'
'set z 1'
'set time DEC1983 DEC2020'

'set vrange -10 10'
'set cmark 13'
'set ccolor 1'
'set cthick 5'
'set parea 1 10 1 8'

'define sdind = sqrt(ave(pow(ind,2),t=1,t=38))'
'd sdind'

'set vrange -10 10'
'set cmark 2'
'set ccolor 1'
'set cthick 10'
'set parea 1 10 1 8'

'd ind'

'draw title The number of snowy days SD (DEC)'
'draw xlab Years'
'draw ylab Snowy days'

'printim ./DEC_snowday_deviation.png x2000 y1600 white'
