'reinit'
'open wind.ctl'

'set grads off'
'set gxout scatter'
'set x 1'
'set y 1'
'set z 1'
'set t 1 last'

'set cmark 2'
'set ccolor 1'
'set cthick 10'

'd ind'

'draw title Wind Speed of Typhoon 1981~2019'
'draw xlab Years'
'draw ylab Wind Speed(knot)'

'printim ./wind.png x2000 y1600 white'
