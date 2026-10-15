**********************************************************************
* 
*	Objective	Dot picture	
*	Version 	0912 
*	Programmed by	Kim, WonMoo (kwmski7@snu.ac.kr)
*	Last Modified	04. Dec. 2009
*	Usage
*	   ga-> dots var scl xint yint poscol negcol 
*		var  : variable
*	     optional arguments :
*		scl : scaling parameter - size for the maximum value 
*               int : interval between dots
*		col : colors for positive and negative values
*
**********************************************************************


function dots(args)
 'set datawarn off'
 'set warn off'

* read arguments
 var=subwrd(args,1) ; if ( var='' ) ; tmp=usage() ; return ; endif
 scl=subwrd(args,2) ; if ( scl='' ) ; scl=0.1 ; endif
 xint=subwrd(args,3) ; if ( xint='' ) ; xint=1 ; endif
 yint=subwrd(args,4) ; if ( yint='' ) ; yint=1 ; endif
 poscol=subwrd(args,4) 
 negcol=subwrd(args,5) 


* read settings
  'q dim'
  d=0 ; t=2
  while ( t<=6 )
   tmp=sublin(result,t) ; chk=subwrd(tmp,8) ; if ( chk!='=' ) ; d=d+1 ; dim1.d=subwrd(tmp,6) ; dim2.d=subwrd(tmp,8) ; t.d=t ; endif 
   t=t+1
  endwhile
  if ( d!=2 ) ; say '*** Error Dimension must be 2...' ; endif
  tmp=sublin(result,t.1) ; dimx=subwrd(tmp,1) ; namex=subwrd(tmp,4) ; x1=subwrd(tmp,11) ; x2=subwrd(tmp,13) ; x1=-1*math_int(-1*x1) ; x2=math_int(x2) 
  tmp=sublin(result,t.2) ; dimy=subwrd(tmp,1) ; namey=subwrd(tmp,4) ; y1=subwrd(tmp,11) ; y2=subwrd(tmp,13) ; y1=-1*math_int(-1*y1) ; y2=math_int(y2)

  'q gxout'
  tmp=sublin(result,4) ;  gxout=subwrd(tmp,6)

* read statistics
 'set gxout stat'
 'd 'var 
 tmp=sublin(result,6) ; undef=subwrd(tmp,4)
 tmp=sublin(result,8) ; min=subwrd(tmp,4) ; max=subwrd(tmp,5)

* draw
 'set gxout 'gxout
 x=x1 ; nx=0
 while ( x<=x2 )
  nx=nx+1
  y=y1 ; ny=0
  while ( y<=y2 )
   ny=ny+1
   'set 'dimx' 'x ; 'set 'dimy' 'y ; 'd 'var
   val=subwrd(result,4) 
    siz.x.y=val2siz(val,min,max,scl,undef) 
    val.x.y=val
   y=y+xint
  endwhile
  x=x+yint
 endwhile

 'set 'namex' 'dim1.1' 'dim2.1 ; 'set 'namey' 'dim1.2' 'dim2.2 
 'draw map'
 'set gxout contour'
 'd const('var','undef',-a)'
 x=x1
 while ( x<=x2 )
  y=y1
  while ( y<=y2 )
   siz=siz.x.y
   if ( siz!=undef )
    'q gr2xy 'x' 'y
    wx=subwrd(result,3) ; wy=subwrd(result,6)
    if ( val.x.y>=0 )
     if ( poscol!='' ) ; 'set line 'poscol ; endif
     'draw mark 3 'wx' 'wy' 'siz
    else
     if ( negcol!='' ) ; 'set line 'negcol ; 'draw mark 3 'wx' 'wy' 'siz
     else ; 'draw mark 2 'wx' 'wy' 'siz ; endif
    endif
   endif
   y=y+xint
  endwhile
  x=x+yint
 endwhile

 'set datawarn on'
 'set warn on'
return

function val2siz(val,min,max,scl,undef)
 if ( val!=undef )
  siz=val/6max*val
 else
  siz=undef
 endif
return siz

function usage()

say '**********************************************************************'
say '* '
say '*	Objective	Dot-Diagram '
say '*	Version 	v0912 '
say '*	Programmed by	Kim, WonMoo (kwmski7@snu.ac.kr)'
say '*	Last Modified	07. Aug. 2009'
say '*	Usage'
say '*	   ga-> dots var scl xint yint poscol negcol'
say '*		var  : variable'
say '*	     optional arguments :'
say '*		scl : scaling parameter - size for the maximum value '
say '*		int : interval between dots '
say '*		col : colors for positive and negative values'
say '*       to control the default color, use "set line" '
say '*'
say '**********************************************************************'

return



