'reinit'
'set grads off'
'open snowday_FEB_1983-2020.ctl'

'set x 1'
'set y 1'
'set z 1'
'set time feb1984 feb2021'

'set ccolor 1'
'set cthick 12'
'set cmark 0'
'set vrange -5 14'

'd ind'

***** finding trend by using ltrend *****

** drawing options **
'set ccolor 3'      
'set cthick 12'     
'set cmark 0'       
*********************

'set time feb1984 feb2021'
'ltrend ind trd'      
'd trd'                   
*****************************************

***** define detrended temperature *****
                          
** drawing options **     
'set ccolor 5'      
'set cthick 12'     
'set cmark 0'       
*********************
                    
'set time feb1984 feb2021'
'define dsnow=ind-trd'
'd dsnow'                 
****************************************

***** writing title *****
'draw title Original-black | trend-green | detrended-sky blue'

***** output image *****
'printim ./snowday_FEB_1984-2021.png x2000 y1600 white'

***** detrended data write *****
'set gxout fwrite'
'set fwrite ./detrended_snowday_FEB_1983-2020.gdat'
'set time feb1984 feb2021'
'd dsnow'
'disable fwrite'
