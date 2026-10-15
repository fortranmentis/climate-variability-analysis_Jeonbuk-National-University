!#####################################################
PROGRAM compositemain
! dsrc(nx,ny,nt) : source data
! slctd(nt) : array for the selected times ( 1 or 0 )
! dm1(nx,ny) : composite mean
! probc(nx,ny) : probability for T-distribution
  INTEGER, PARAMETER :: nx=360, ny=180, nt=38
  REAL, PARAMETER :: dmiss=-9.99E+8
  CHARACTER(40), PARAMETER :: inputind='snow_JAN_1984-2021.gdat'
  CHARACTER(30), PARAMETER :: inputdata='sst_DJF_-12.gdat'
  CHARACTER(40), PARAMETER :: output='comp_snow_JAN_sst_DJF_-12'
  REAL, DIMENSION(nx,ny,nt) :: dsrc
  REAL, DIMENSION(nt) :: slctd
  REAL, DIMENSION(nx,ny) :: dm1, dm2, probc

!#####################################################
! Composite Conditions : slctd(nt) = 1 or 0
  REAL, DIMENSION(nt) :: dsrcts
  OPEN(12,FILE=TRIM(inputind),RECL=nt*4, &
  ACCESS='DIRECT',FORM='UNFORMATTED',STATUS='OLD')
  READ(12,REC=1) dsrcts
  tsm=0.
  DO it=1,nt
    tsm=tsm+dsrcts(it)/float(nt)
  ENDDO
  tsvar=0.
  DO it=1,nt
    tsvar=tsvar+(dsrcts(it)-tsm)**2/float(nt)
  ENDDO
  tssd=sqrt(tsvar)
  DO it=1,nt
  !--- select years greater than 1 standard deviation of index ---
  IF(dsrcts(it).GT.1.*tssd)THEN 
    slctd(it)=1.
  ELSE
    slctd(it)=0.
  ENDIF
  ENDDO
!#####################################################

  OPEN(11,FILE=TRIM(inputdata),RECL=nx*ny*nt*4, &
  ACCESS='DIRECT',FORM='UNFORMATTED',STATUS='OLD')
  READ(11,REC=1) dsrc

  CALL composite(dsrc,slctd,dm1,dm2,probc,nx,ny,nt,dmiss)

  OPEN(21,FILE=''//TRIM(output)//'.gdat',RECL=nx*ny*4, &
  ACCESS='DIRECT',FORM='UNFORMATTED',STATUS='UNKNOWN')
  WRITE(21,REC=1) dm1
  WRITE(21,REC=2) probc

  OPEN(31,file=''//TRIM(output)//'.ctl',form='formatted',status='unknown')
  WRITE(31,'(A43)') 'DSET ^'//TRIM(output)//'.gdat'
  WRITE(31,'(A6,E15.5)') 'UNDEF ', dmiss
  IF(nx==144) then
  WRITE(31,'(A5,I3,A8,F5.2,F4.1)') 'XDEF ', nx, ' LINEAR ', 1.25, 2.5
  WRITE(31,'(A5,I3,A8,F7.2,F4.1)') 'YDEF ', ny,  ' LINEAR ', -88.75, 2.5
  ELSE
  WRITE(31,'(A5,I3,A8,F4.1,F4.1)') 'XDEF ', nx, ' LINEAR ', 0.5, 1.0
  WRITE(31,'(A5,I3,A8,F6.1,F4.1)') 'YDEF ', ny,  ' LINEAR ', -89.5, 1.0
  ENDIF
  WRITE(31,'(A5,I3,A15)') 'ZDEF ', 1, ' LINEAR   0. 1.'
  WRITE(31,'(A8,A8,A9,A4)') 'TDEF   1', ' LINEAR ', '01JAN0000', ' 1mo'
  WRITE(31,'(A5,I2)') 'VARS ', 2
  WRITE(31,'(A4,I2,I2,A10)') 'comp', 1, 1, 'composite'
  WRITE(31,'(A4,I2,I2,A12)') 'conf', 1, 1, 'confidence'
  WRITE(31,'(A7)') 'ENDVARS'
  CLOSE(31)

END PROGRAM compositemain
!#####################################################


SUBROUTINE composite(dsrc,slctd,dm1,dm2,probc, &
                     nx,ny,nt,dmiss)
! INFORMS : sulim@snu.ac.kr 10 Dec. 2003, Ver. 0.1
! PURPOSE : composite analysis
! ACCEPTS : dsrc(nx,ny,nt),slctd(nt),chkmss(nx,ny),
!           nx,ny,nt,dmiss
! RETURNS : dm1(nx,ny),dm2(nx,ny),probc(nx,ny)
  INTEGER, PARAMETER :: np=1  ! for 1-preiod mean
!  INTEGER, PARAMETER :: np=12 ! for 12-period mean
  REAL, DIMENSION(nt) :: dsrcts, slctd
  REAL, DIMENSION(nx,ny,nt) :: dsrc
  REAL, DIMENSION(nx,ny) :: dm1, dm2, chkmss, probc
  REAL, ALLOCATABLE :: dsrcm(:,:,:)
  ALLOCATE(dsrcm(nx,ny,np))
  CALL checkmiss(dsrc,nx,ny,nt,dmiss,chkmss,jn)
  nr=nt/np; dsrcm(:,:,:)=0.
  DO i=1,nx
  DO j=1,ny
    IF (chkmss(i,j).EQ.0) THEN
    DO kr=1,nr
    DO kp=1,np
    it=np*(kr-1)+kp
    dsrcm(i,j,kp)=dsrcm(i,j,kp)+dsrc(i,j,it)/nr
    ENDDO
    ENDDO
    ENDIF
  ENDDO
  ENDDO
  n1=0; n2=nt
  DO it=1,nt
    IF(slctd(it).EQ.1)n1=n1+1
  ENDDO
  dm1(:,:)=0.; dm2(:,:)=0.
  DO j=1,ny
  DO i=1,nx
  var1=0.; var2=0.
  IF(chkmss(i,j).EQ.0)THEN
    DO kr=1,nr
    DO kp=1,np
    it=np*(kr-1)+kp
      IF(slctd(it).EQ.1.)THEN 
      dm1(i,j)=dm1(i,j)+(dsrc(i,j,it)-dsrcm(i,j,kp))/n1
      ENDIF
      dm2(i,j)=dm2(i,j)+(dsrc(i,j,it)-dsrcm(i,j,kp))/n2
    ENDDO
    ENDDO
    DO kr=1,nr
    DO kp=1,np
    it=np*(kr-1)+kp
      IF(slctd(it).EQ.1.)THEN
      var1=var1+(dsrc(i,j,it)-dsrcm(i,j,kp)-dm1(i,j))**2/n1
      ENDIF
      var2=var2+(dsrc(i,j,it)-dsrcm(i,j,kp)-dm2(i,j))**2/n2
    ENDDO
    ENDDO
    IF(n1.NE.0)THEN
      df=((var1/n1+var2/n2)**2) &
        /((var1/n1)**2/(n1-1)+(var2/n2)**2/(n2-1))
      t=(dm1(i,j)-dm2(i,j))/sqrt(var1/n1+var2/n2)
      prob=betai(0.5*df,0.5,df/(df+t**2))
      probc(i,j)=1-prob
    ELSE
      probc(i,j)=0.
    ENDIF
  ELSE
    dm1(i,j)=dmiss
    dm2(i,j)=dmiss
    probc(i,j)=dmiss
  ENDIF
  ENDDO
  ENDDO
END SUBROUTINE composite

FUNCTION betai(a,b,x)
  REAL betai,a,b,x
  REAL bt,betacf,gammln
!  IF(x.lt.0..or.x.gt.1.) Print*,'bad argument x in betai'
  IF(x.eq.0..or.x.eq.1.) THEN
    bt=0.
  ELSE
    bt=exp(gammln(a+b)-gammln(a)-gammln(b) &
      +a*log(x)+b*log(1.-x))
  ENDIF
  IF(x.lt.(a+1.)/(a+b+2.)) THEN
    betai=bt*betacf(a,b,x)/a
    RETURN
  ELSE
    betai=1.-bt*betacf(b,a,1.-x)/b
    RETURN
  ENDIF
END FUNCTION betai

FUNCTION betacf(a,b,x)
  INTEGER MAXIT
  REAL betacf,a,b,x,EPS,FPMIN
  PARAMETER (MAXIT=100,EPS=3.e-7,FPMIN=1.e-30)
  INTEGER m,m2
  REAL aa,c,d,del,h,qab,qam,qap
  qab=a+b
  qap=a+1.
  qam=a-1.
  c=1.
  d=1.-qab*x/qap
  IF(abs(d).lt.FPMIN) d=FPMIN
  d=1./d
  h=d
  DO m=1,MAXIT
    m2=2*m
    aa=m*(b-m)*x/((qam+m2)*(a+m2))
    d=1.+aa*d
    if(abs(d).lt.FPMIN) d=FPMIN
    c=1.+aa/c
    if(abs(c).lt.FPMIN) c=FPMIN
    d=1./d
    h=h*d*c
    aa=-(a+m)*(qab+m)*x/((a+m2)*(qap+m2))
    d=1.+aa*d
    if(abs(d).lt.FPMIN) d=FPMIN
    c=1.+aa/c
    if(abs(c).lt.FPMIN) c=FPMIN
    d=1./d
    del=d*c
    h=h*del
    if(abs(del-1.).lt.EPS) then
      betacf=h
      RETURN
    endif
  ENDDO
!  PAUSE 'a or b too big. or MAXIT too small in betacf'
  betacf=h
END FUNCTION betacf

FUNCTION gammln(xx)
  REAL gammln,xx
  INTEGER j
  DOUBLE PRECISION ser,stp,tmp,x,y,cof(6)
  SAVE cof,stp
  DATA cof,stp/76.18009172947146d0,-86.50532032941677d0, &
  24.01409824083091d0,-1.231739572450155d0,.1208650973866179d-2, &
  -.5395239384953d-5,2.50662282746310005d0/
  x=xx
  y=x
  tmp=x+5.5d0
  tmp=(x+0.5d0)*log(tmp)-tmp
  ser=1.000000000190015d0
  DO j=1,6
    y=y+1.d0
    ser=ser+cof(j)/y
  ENDDO
  gammln=tmp+log(stp*ser/x)
END FUNCTION gammln

SUBROUTINE checkmiss(dsrc,nx,ny,nt,dmiss,chkmss,jn)
! Purpose : To count non-missing grids
! Accepts : dsrc(nx,ny,nt), dmiss
! Returns : chkmss(nx,ny), jn(# of valid grids)
  REAL, DIMENSION(nx,ny,nt) :: dsrc
  REAL, DIMENSION(nx,ny) :: chkmss
  chkmss(:,:)=0.
  DO i=1,nx
  DO j=1,ny
    nzero=0
    DO k=1,nt
      IF (dsrc(i,j,k).EQ.dmiss) THEN
        chkmss(i,j)=chkmss(i,j)+1.
      ENDIF
      IF (dsrc(i,j,k).EQ.0.) then
        nzero=nzero+1
      ENDIF
    ENDDO
    IF (nzero.eq.nt) chkmss(i,j)=nt
!                    all-zero grid remove out
  ENDDO
  ENDDO
  jn=0
  DO i=1,nx
  DO j=1,ny
    IF (chkmss(i,j).EQ.0.) THEN
      jn=jn+1
    ENDIF
  ENDDO
  ENDDO
END SUBROUTINE checkmiss
