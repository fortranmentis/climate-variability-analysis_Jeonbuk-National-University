'reinit'
'open Jeonju_1980-2019.ctl'

'set x 1'
'set y 1'
'set z 1'
'set time jan1982 dec2018'
'define ind=precip'
**** Calculate Climatology ****
'set time jan1982 dec1982'
'define clim=ave(ind,t+0,time=dec2019,12)'
'modify clim seasonal'

**** Calculate Anomaly ****
'set time jan1982 dec2018'
'define anom=ind-clim'

**** Write Data ****
'set gxout fwrite'
'set fwrite Jeonju_precip_monthly_JAN1982-DEC2018.gdat'
'd anom'
'disable fwrite'
