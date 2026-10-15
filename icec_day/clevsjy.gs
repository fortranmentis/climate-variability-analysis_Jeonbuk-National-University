*********************************************************************
*       Programmed by   Park, Jong-yeon (jylovesu@kordi.re.kr)
*       Last Modified   31. Aug. 2010
*       Usage
*          ga-> clevs cint sign'
*          cint : contour interval 
*          sign : 'p' for positive only, 'n' for negative only (Optional)
*
**********************************************************************

function clevs(arg)
'rgbset_mod'

*'set rgb 120 95 000 000' 
*'set rgb 121 135 000 000' 
*'set rgb 122 200 000 000' 
*'set rgb 123 255 000 000' 
*'set rgb 124 255 051 000' 
*'set rgb 125 255 102 000' 
*'set rgb 126 255 153 000' 
*'set rgb 127 255 204 000' 
*'set rgb 128 255 255 000' 
*'set rgb 129 204 255 000' 
*'set rgb 130 153 255 000' 
*'set rgb 131 051 255 000' 
**'set rgb 131 000 255 000' 
*'set rgb 132 000 227 028' 
*'set rgb 133 000 170 085' 
*'set rgb 134 000 113 142' 
*'set rgb 135 000 057 198' 
*'set rgb 136 000 000 255' 
*'set rgb 137 000 000 200'
*'set rgb 138 000 000 135'
*'set rgb 139 000 000 95'

** Rainbow ***
*'set rgb 120 95 000 000' 
*'set rgb 121 135 000 000' 
*'set rgb 122 200 000 000' 
*'set rgb 123 255 000 000' 
*'set rgb 124 255 051 000' 
*'set rgb 125 255 102 000' 
*'set rgb 126 255 153 000' 
*'set rgb 127 255 204 000' 
*'set rgb 128 255 255 000' 
*'set rgb 129 204 255 000' 
*'set rgb 130 153 255 000' 
*'set rgb 131 051 255 000' 
**'set rgb 131 000 255 000' 
*'set rgb 132 000 227 028' 
*'set rgb 133 000 170 085' 
*'set rgb 134 000 113 142' 
*'set rgb 135 000 057 198' 
*'set rgb 136 000 000 255' 
*'set rgb 137 000 000 200'
*'set rgb 138 000 000 135'
*'set rgb 139 000 000 95'
*** blue-yellow-red**
*'set rgb 120 0  0 95'
'set rgb 121 8 29 88'
'set rgb 122 37 52 148'
'set rgb 123 34 94 168'
'set rgb 124 29 145 192'
'set rgb 125 65 182 196'
'set rgb 126 127 205 187'
'set rgb 127 199 233 180'
'set rgb 128 237 248 177'
'set rgb 129 255 255 191'
'set rgb 130 255 237 160'
'set rgb 131 254 217 118'
'set rgb 132 254 178 76'
'set rgb 133 253 141 60'
'set rgb 134 252 78 42'
'set rgb 135 227 26 28'
'set rgb 136 189 0 38'
'set rgb 137 128 0 38'
*'set rgb 138 95 0 0'
** blue-red**
*'set rgb 121 8 48 107'
*'set rgb 122 8 81 156'
*'set rgb 123 33 113 181'
*'set rgb 124 66 146 198'
*'set rgb 125 107 174 214'
*'set rgb 126 158 202 225'
*'set rgb 127 198 219 239'
*'set rgb 128 222 235 247'
*'set rgb 129 255 255 255'
*'set rgb 130 254 224 210'
*'set rgb 131 252 187 161'
*'set rgb 132 252 146 114'
*'set rgb 133 251 106 74'
*'set rgb 134 239 59 44'
*'set rgb 135 203 24 29'
*'set rgb 136 165 15 21'
*'set rgb 137 103 0 13'

*'colortable load rgb'
*'colortable 20 red yellow blue -n 20'

cint=subwrd(arg,1)
offset=subwrd(arg,2)
sign=subwrd(arg,3)
if offset=''; offset=0; endif

clevs1=''; clevs2=''
nc=16; ic=-1
while(ic<nc); ic=ic+2
ac=-cint*(nc-ic+1)/2 +offset
clevs1=clevs1%' '%ac
if(ic<=14)
ac=cint*(ic+1)/2 + offset
clevs2=clevs2%' '%ac
endif
endwhile
clevs='clevs 'clevs1'   'clevs2
say clevs1
say clevs2
say clevs
IF (sign='')
'set 'clevs
*'set ccols 39  38    37   36    35   34  33   32   31  30  29    28  27  26  25  24  23  22  22'
*'set ccols  138  137  136    135   134  133   132   131  130  129    128  127  126  125  124  123   122 121 120'
'set ccols   121  122  123    124   125  126   127   128  129   130    131  132  133  134  135  136 137'
*'set ccols  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18'
ENDIF
IF (sign='p')
'set clevs 'clevs2
*'set ccols  0   21   22  23  24  25  26  27  28  29'
'set ccols  0  130  131  132  133  134  135  136 137'
ENDIF
IF (sign='n')
'set clevs 'clevs1
'set ccols 49  48    47   46    45   44  43   42   41   0'
ENDIF


return
*********************



function usage()

say '**********************************************************************'
say '* '
say '*  Objective       clevs'
say '*  Programmed by   Park, Jong-yeon (jylovesu@kordi.re.kr)'
say '*  Last Modified   27. July. 2010'
say '*  Usage'
say '*     ga-> clevs cint sign'
say '*          cint : contour interval (Optional)'
say '*          sign : 'p' for positive only, 'n' for negative only
say '
say '**********************************************************************'

return

                        
