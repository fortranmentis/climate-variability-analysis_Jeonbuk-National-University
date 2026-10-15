'reinit'

'open reg_snowdepth_icec_-12.ctl'

'set grads off'

'set dfile 1;dfile 2'
'set font 10 file /usr/local/share/fonts/times.ttf'

**** draw air temp shaded ****
'set gxout shaded'
'clevsjy2 0.1 0.7'
'rgbset_mod'
'set rgb 121 8 48 107'
'set rgb 122 8 81 156'
'set rgb 123 33 113 181'
'set rgb 124 66 146 198'
'set rgb 125 107 174 214'
'set rgb 126 158 202 225'
'set rgb 127 198 219 239'
'set rgb 128 222 235 247'
'set rgb 129 255 255 255'
'set rgb 130 254 224 210'
'set rgb 131 252 187 161'
'set rgb 132 252 146 114'
'set rgb 133 251 106 74'
'set rgb 134 239 59 44'
'set rgb 135 203 24 29'
'set rgb 136 165 15 21'
'set rgb 137 103 0 13'

'd prob.1'
'xcbar 1 10 0.24 0.44 -ft 60'

'define icesig=const(maskout(prob.1,0.1-prob.1),1)'
*dots var    size xint yint pc nc
'dots icesig 0.06 2.0  2.0  1  '
 
'basemap L 0 1 L'

'printim ./reg_jj_icec_test(-12).png x1000 y800 white'
