'reinit'

'open corr_snow_JFM_sst_JFM.ctl'
'open air_correlation_to_Jeonju_JFM_JFM.ctl'
'open hgt85_1984-2021_JFM_correlation_to_JFM.ctl'
'open uwnd_snow_jfm.ctl'
'open vwnd_snow_jfm.ctl'


'set dfile 1'
'set x 1 360'
'set y 1 180'
'set z 1'
'set gxout shaded'
'd maskout(corr,0.1-prob)'
'basemap L 15 1 L'

'set dfile 2'
'set x 1 144'
'set y 1 73'
'set z 1'
'set gxout contour'
'set rgb 21 247 252 253'
'd reg.2'

'set dfile 3'
'set x 1 144'
'set y 1 73'
'set z 1'
'set rgb 66 102 255 102'
'dots corr.3 0.2 2 2 66 2'

'set dfile 4;dfile 5'
'set x 1 144'
'set y 1 73'
'set z 1'
'set gxout shaded'
'set ccolor 14'
'd maskout(corr.4,0.1-prob);maskout(corr.5,0.1-prob)'
'cbarm 1 0'


'draw title JFM'

'printim ./SNOW_JFM_corr_SST_FMA.png x4000 y3600 white'

