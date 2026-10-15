'reinit'
'open snow_JAN_1984-2021.ctl'

'set grads off'
'set gxout scatter'
'set x 1'
'set y 1'
'set z 1'
'set time feb1984 feb2021'

'set vrange 0 17'
'set cmark 2'
'set ccolor 1'
'set cthick 10'
'set parea 1 10 1 8'

'd ind'

'draw title The number of snowy days (JAN)'
'draw xlab Years'
'draw ylab Snowy days'

'printim ./JAN_snowday.png x2000 y1600 white'
