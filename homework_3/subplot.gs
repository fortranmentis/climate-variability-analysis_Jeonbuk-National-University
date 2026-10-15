function subplot(args)
version='02OCT2008'
**************************************************************
dn.1 =' '
dn.2 ='  Script to subplot m by n matrix'
dn.3 =' '
dn.4 ='  sulim@snu.ac.kr, 'version', release'
dn.5 ='  Atmosphere-Ocean Dynamics Lab. / Seoul Nat'l Univ.
dn.6 =' '
dn.7 ='  Usage :'
dn.8 ='   ga> subplot mnxy title index gap strsiz xtitle ytitle'
dn.9 ='   ga> subplot mn title index gap strsiz xtitle ytitle'
dn.10=' '
dn.11='   plot a frame at (x,y) of m by n matrix'
dn.12='   index  = order of the frame'
dn.13='   gap    = gap between frames'
dn.14='   strsiz = size of the title string'
dn.15='   xtitle = title of the x-axis'
dn.16='   ytitle = title of the y-axis'
dn.17=' '
dn.18='  Examples :'
dn.19='   "ga> subplot 24 alpha 7"'
dn.20='        7th frame of 2 by 4 matrix, title is alpha'
dn.21='   "ga> subplot 24v alpha 7"'
dn.22='        vertical order'
dn.23='   "ga> subplot 24 alpha 7 0.5 0.18"'
dn.24='        gap is 0.5 and string size is 0.18'
dn.25='   "ga> subplot 3622 bravo"'
dn.26='        plot at (2,2) of 3 by 6 matrix, title is beta'
dn.27='   "ga> subplot 3622 "charlie delta" 0 0.5 0.12"'
dn.28='        auto indexing, gap=0.5, and string size=0.12' 
dn.29='   "ga> subplot 3622 echo 5"'
dn.30='        overrides the auto-indexing'
dn.31='   "ga> subplot 8 foxtrot 7'
dn.32='        pre-defined subplot parameters w/ size 8'
dn.33=' '
**************************************************************
*
* version information
* 23SEP2008, prototype
* 02OCT2008, text problem fixed, prepanels added
*
* advanced options
alphabet_label='no'
title_alignment='l'
title_color='1'
posi_page1= 0.0
posi_page2= 0.0
size_page1=11.0
size_page2= 8.5
title_space=0.0
default_gap=0.5
default_size_str=0.15
draw_frame='no'
total_frame='no'
result_out='no'
*
* NOTE : title='notitle' -> no title
* NOTE : m and n must be less than 10.
* NOTE : size_page1 exchanges w/ size_page2 in portrait mode.
* NOTE : title_space instead of xtitle -> title_space=ytitle
* NOTE : title_color instead of xtitle -> title_color=ytitle
*
* title_space|            size_page1
*            +---------------------------------+
*            |                                 |
*            |                                 |
*            |                                 | size_page2
*            |                                 |
*            |                                 |
* posi_page2 +---------------------------------+
*        posi_page1
*
**************************************************************
*
* arguments
mat=subwrd(args,1)
m=substr(mat,1,1); n=substr(mat,2,1)
m1=substr(mat,3,1); n1=substr(mat,4,1)
* text argument
txt1=subwrd(args,2); strpos=2; str1=''
if substr(txt1,1,1)='"';
  while(1)
    if substr(txt1,strlen(txt1),1)='"';
      txt1=stripstr(txt1); str1=str1%' '%txt1; break
    else
      txt1=stripstr(txt1)
      if strpos=2; str1=txt1
      else; str1=str1' 'txt1; endif
      strpos=strpos+1 
      txt1=subwrd(args,strpos)
    endif
    if txt1=''; say ' Error, invalid text.'; return; endif
  endwhile
else
  str1=txt1
endif
idx1=subwrd(args,strpos+1)
gap=subwrd(args,strpos+2); size_str=subwrd(args,strpos+3)
xtitle=subwrd(args,strpos+4); ytitle=subwrd(args,strpos+5)
if xtitle='title_space'
  title_space=ytitle; xtitle=''; ytitle=''
endif
if xtitle='title_color'
  title_color=ytitle; xtitle=''; ytitle=''
endif
if mat=''; i=0; while(i<33); i=i+1
say dn.i; endwhile; return; endif
if gap=''
* default gap and size_str 
  if m=1 & n>0 & n<4; sp=1; endif
  if n=1 & m>0 & m<4; sp=1; endif
  if sp=1; gap=1.0; size_str=0.20
  else; gap=default_gap; size_str=default_size_str; endif
endif
if size_str=''; size_str=0.20; endif
'q xinfo'
w=subwrd(result,16); h=subwrd(result,20)
if w>h
  size_page2=size_page2-title_space
  xlo=posi_page1+gap; xhi=posi_page1+size_page1
  ylo=posi_page2; yhi=posi_page2+size_page2-gap
  recx=posi_page1' 'posi_page2
  recy=posi_page1+size_page1' 'posi_page2+size_page2
else
  size_page1=size_page1-title_space
  xlo=posi_page1+gap; xhi=posi_page1+size_page2
  ylo=posi_page2; yhi=posi_page2+size_page1-gap
  recx=posi_page2' 'posi_page1
  recy=posi_page2+size_page2' 'posi_page1+size_page1
endif
if total_frame='yes'; 'draw rec 'recx' 'recy; endif
xsize=xhi-xlo; ysize=yhi-ylo
twodig=substr(mat,1,2)*1
if twodig<11
  if twodig<idx1 | twodig=5 | twodig=7
  say ' Error, invalid argument.'; return; endif
  if idx1=''; fn=prepanels(twodig,1)
  else; fn=prepanels(twodig,idx1); endif
  x1=subwrd(fn,1)*1; x2=subwrd(fn,2)*1
  y1=subwrd(fn,3)*1; y2=subwrd(fn,4)*1
else
if n1='' & m1!='' & m1!='0' & m1!='v'
  say ' Error, invalid argument.'; return
endif
if m1='' | m1='0'
  if idx1=''
    idx1='0'; m1=1; n1=1
  else
    fn=idx2mn(m,n,idx1,1)
    m1=subwrd(fn,1); n1=subwrd(fn,2)
  endif
  if str1=''; m1=1; n1=1; endif
endif
if m1='v'
  fn=idx2mn(m,n,idx1,2)
  m1=subwrd(fn,1); n1=subwrd(fn,2)
  idx1='v'
endif
if idx1='' | idx1='0'; idx1=m*(n1-1)+m1; endif
if idx1='v'; idx1=n*(m1-1)+n1; endif
if m<m1; say ' Error, invalid argument.'; return; endif
if n<n1; say ' Error, invalid argument.'; return; endif
x1=xlo+xsize/m*(m1-1)
x2=xlo+xsize/m*m1-gap
y1=yhi-(ysize/n*n1)+gap
y2=yhi-(ysize/n*(n1-1))
endif
if x1>x2; say ' Error, invalid argument.'; return; endif
if y1>y2; say ' Error, invalid argument.'; return; endif
'set string 'title_color' 'title_alignment; 'set strsiz 'size_str
if title_alignment='c'; x1lab=(x1+x2)/2; endif
if title_alignment='l'; x1lab=x1; endif
if title_alignment='r'; x1lab=x2; endif
'set font 1'
if str1='notitle'; else
'set string 1 l 4'
  if alphabet_label='yes'
  'draw string 'x1lab' 'y2+size_str' ('chr(idx1+96)') 'str1
  else
    if str1=''; else
******* CHange HERE!@!!!!!!!!!!!!!!!!!!!      
*    'draw string 'x1lab+0.0' 'y2+size_str-0.0' 'str1
    'draw string 'x1lab+0.3' 'y2+size_str-0.0' 'str1
    endif
  endif
endif
if xtitle!=''
'set string 1 c 4 0'; 'set strsiz 'size_str*0.8
xc=(x1+x2)/2
'draw string 'xc' 'y1-gap*0.4' 'xtitle
endif
if ytitle!=''
'set string 1 c 4 90'; 'set strsiz 'size_str*0.8
yc=(y1+y2)/2
'draw string 'x1-gap*0.5' 'yc' 'ytitle
endif
'set string 1 l 4 0'; 'set strsiz 'size_str
if result_out='yes'
  result=x1' 'x2' 'y1' 'y2' 'gap' 'size_str' '
endif
if draw_frame='yes'
'draw rec 'x1' 'y1' 'x2' 'y2
endif
'set vpage off'
'set parea 'x1' 'x2' 'y1' 'y2
'set mproj scaled'
'set grads off'
return result

function chr(n)
a0='                               ';
a1=' !"#$%&`()*+`-./0123456789:;<=>?'
a2='@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'
a3='.abcdefghijklmnopqrstuvwxyz{|}~ '
a=a0%a1%a2%a3
return substr(a,n,1)

function idx2mn(m,n,idx1,t)
if t=1
idx=0; in=0; while(in<n); in=in+1
im=0; while(im<m); im=im+1; idx=idx+1
if idx=idx1
  m1=im; n1=in
endif
endwhile; endwhile
else
idx=0; im=0; while(im<m); im=im+1
in=0; while(in<n); in=in+1; idx=idx+1
if idx=idx1
  m1=im; n1=in
endif
endwhile; endwhile
endif
return m1' 'n1

function strlen(arg)
  i=1
  while(substr(arg,i,1) != '')
    i=i+1
  endwhile
return (i-1)

function stripstr (arg)
i=1
len=0
s=subwrd(arg,i)
if (s='') 
 return 0
else
 a=substr(s,1,1)
 if (a='"')
  s=substr(s,2,strlen(s))
 endif
 e=substr(s,strlen(s),1)
 if (e='"')
  s=substr(s,1,strlen(s)-1)
 endif
endif
return s

function prepanels(arg,index)
if arg=1
  x1.1=1.0; x2.1=7.5; y1.1=6.0; y2.1=9.0
endif
if arg=2
  x1.1=1.0; x2.1=7.5; y1.1=6.0; y2.1=9.0
  x1.2=1.0; x2.2=7.5; y1.2=2.0; y2.2=5.0
endif
if arg=3
  x1.1=1.0; x2.1=7.5; y1.1=7.5; y2.1=10.0
  x1.2=1.0; x2.2=7.5; y1.2=4.0; y2.2=6.5
  x1.3=1.0; x2.3=7.5; y1.3=0.5; y2.3=3.0
endif
if arg=4
  x1.1=0.5; x2.1=4.0; y1.1=6.5; y2.1=9.0
  x1.2=0.5; x2.2=4.0; y1.2=3.0; y2.2=5.5
  x1.3=4.5; x2.3=8.0; y1.3=6.5; y2.3=9.0
  x1.4=4.5; x2.4=8.0; y1.4=3.0; y2.4=5.5
endif
if arg=6
  x1.1=0.5; x2.1=4.0; y1.1=7.5; y2.1=10.0
  x1.2=0.5; x2.2=4.0; y1.2=4.0; y2.2=6.5
  x1.3=0.5; x2.3=4.0; y1.3=0.5; y2.3=3.0
  x1.4=4.5; x2.4=8.0; y1.4=7.5; y2.4=10.0
  x1.5=4.5; x2.5=8.0; y1.5=4.0; y2.5=6.5
  x1.6=4.5; x2.6=8.0; y1.6=0.5; y2.6=3.0
endif
if arg=8
  x1.1=0.5; x2.1=4.0; y1.1=8.0; y2.1=10.0
  x1.2=0.5; x2.2=4.0; y1.2=5.5; y2.2=7.5
  x1.3=0.5; x2.3=4.0; y1.3=3.0; y2.3=5.0
  x1.4=0.5; x2.4=4.0; y1.4=0.5; y2.4=2.5
  x1.5=4.5; x2.5=8.0; y1.5=8.0; y2.5=10.0
  x1.6=4.5; x2.6=8.0; y1.6=5.5; y2.6=7.5
  x1.7=4.5; x2.7=8.0; y1.7=3.0; y2.7=5.0
  x1.8=4.5; x2.8=8.0; y1.8=0.5; y2.8=2.5
endif
if arg=9
  x1.1=0.5; x2.1=3.5; y1.1=6.0; y2.1=8.0
  x1.2=4.0; x2.2=7.0; y1.2=6.0; y2.2=8.0
  x1.3=7.5; x2.3=10.5; y1.3=6.0; y2.3=8.0
  x1.4=0.5; x2.4=3.5; y1.4=3.5; y2.4=5.5
  x1.5=4.0; x2.5=7.0; y1.5=3.5; y2.5=5.5
  x1.6=7.5; x2.6=10.5; y1.6=3.5; y2.6=5.5
  x1.7=0.5; x2.7=3.5; y1.7=1.0; y2.7=3.0
  x1.8=4.0; x2.8=7.0; y1.8=1.0; y2.8=3.0
  x1.9=7.5; x2.9=10.5; y1.9=1.0; y2.9=3.0
endif
if arg=10
  x1.1=0.5; x2.1=4.0; y1.1=8.5; y2.1=10.0
  x1.2=0.5; x2.2=4.0; y1.2=6.5; y2.2=8.0
  x1.3=0.5; x2.3=4.0; y1.3=4.5; y2.3=6.0
  x1.4=0.5; x2.4=4.0; y1.4=2.5; y2.4=4.0
  x1.5=0.5; x2.5=4.0; y1.5=0.5; y2.5=2.0
  x1.6=4.5; x2.6=8.0; y1.6=8.5; y2.6=10.0
  x1.7=4.5; x2.7=8.0; y1.7=6.5; y2.7=8.0
  x1.8=4.5; x2.8=8.0; y1.8=4.5; y2.8=6.0
  x1.9=4.5; x2.9=8.0; y1.9=2.5; y2.9=4.0
  x1.10=4.5; x2.10=8.0; y1.10=0.5; y2.10=2.0
endif
result=x1.index' 'x2.index' 'y1.index' 'y2.index
return result
