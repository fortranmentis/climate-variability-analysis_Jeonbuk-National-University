'reinit'
'sdfopen /home/sang9604/climate_analysis/FInal/sst.mnmean.nc'

'set x 1'
'set y 1'
'set z 1'
'set time jan1990 dec2018'
'define ind=aave(sst,lon=28,lon=40,lat=41,lat=46)'
****Calculate climatology**** 
'set time jan1990 dec1990'
'define clim=ave(ind,t+0,time=dec2019,12)'
'modify clim seasonal'
****Calculate Anomaly****
'set time jan1990 dec2018'
'define anom=ind-clim'
'define sanom=ave(anom,t-1,t+1)'
******
'set gxout fwrite'
'set fwrite sst_ind.gdat'

iyr=1989
while(iyr<2018)
iyr=iyr+1
'set time jul'iyr
'd sanom'

endwhile
'disable fwrite'
