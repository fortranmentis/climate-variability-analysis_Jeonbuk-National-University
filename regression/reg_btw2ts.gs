'reinit'

'open Nino_index_NDJ_1982-2018.ctl'
'open precip_Jeonju_DEC_1982-2018.ctl'

'set x 1'
'set y 1'
'set z 1'
'set t 1 last'

'define mx=ave(nino.1,t=1,t=37)'
'define my=ave(ind.2,t=1,t=37)'

'd SUM((nino.1-mx)*(ind.2-my),t=1,t=37) / SUM(pow((nino.1-mx),2),t=1,t=37)'
say result

