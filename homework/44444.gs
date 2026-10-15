'reinit'
'open nino_precip.ctl'

'set lon 100 170'
'set lat 20 50' 

'set gxout contour'
'd comp'

'set gxout shaded'
'd maskout(comp,conf-0.90)'
'cbarm'
