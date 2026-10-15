'reinit'
'sdfopen wspd.mon.mean.nc'

'set x 1 144'
'set y 1 73'
'set z 1'

'set time jan2001 dec2018'


'set time jan2001 dec2001'
'define clim=ave(wspd,t+0,time=dec2018,12)'
'modify clim seasonal'


'set time jan2001 dec2018'
'define anom=wspd-clim'


'set gxout fwrite'
'set fwrite wspd_OCT_2001-2018.gdat'


iyr=2000
while(iyr<2018)
iyr=iyr+1
'set time oct'iyr
'd anom'
endwhile

'disable fwrite'
