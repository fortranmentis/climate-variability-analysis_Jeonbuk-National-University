PROGRAM correlogram
  INTEGER, PARAMETER  :: lt=444, nm=1, lag1=-24, lag2=24
!  INTEGER, PARAMETER  :: lt=444, nm=1, lag1=-48, lag2=48
  CHARACTER(90), PARAMETER :: input1='./Nino_index_monthly_JAN1982-DEC2018.gdat'
  CHARACTER(90), PARAMETER :: input2='./Nino_index_monthly_JAN1982-DEC2018.gdat'
!  CHARACTER(90), PARAMETER :: input1='./Jeonju_precip_monthly_JAN1982-DEC2018.gdat'
!  CHARACTER(90), PARAMETER :: input2='./Jeonju_precip_monthly_JAN1982-DEC2018.gdat'
  INTEGER, PARAMETER :: Detrd=0
  REAL, PARAMETER    :: undef=-9.99e8
  REAL, DIMENSION(lt) :: ts1, ts2
  REAL ::  pct(nm,lt), temp(1,1,lt), co, prob, c
  INTEGER :: tmp, df

!****** Data read *******
!--- FOR 1st and 2nd PC-time series
!  OPEN(1,file=''//TRIM(input1)//'',form='unformatted',access='direct',recl=nm*lt*4,status='old')
!  READ(1,rec=1) pct(:,:)
!  ts1=pct(1,:)
!  ts2=pct(2,:)

!--- FOR 2 time series
  OPEN(1,file=''//TRIM(input1)//'',form='unformatted',access='direct',recl=lt*4,status='old')
  READ(1,rec=1) ts1
  CLOSE(1)

  OPEN(2,file=''//TRIM(input2)//'',form='unformatted',access='direct',recl=lt*4,status='old')
  READ(2,rec=1) ts2
  CLOSE(2)


!****** Detrend *******
  IF (Detrd == 1) then
     temp(1,1,:)=ts1(:);  CALL Detrend(temp,undef);  ts1(:)=temp(1,1,:)
     temp(1,1,:)=ts2(:);  CALL Detrend(temp,undef);  ts2(:)=temp(1,1,:)
  ENDIF

!****** Corr. Calculation & Data write *******
  OPEN(11,file='correlogram.gdat',form='unformatted',access='direct',recl=4*2,status='unknown')
!  OPEN(12,file='correlogram.dat',form='formatted',status='unknown')
  write(*,*) '        mode#    ', 'Corr' 
  i=0
  DO il=lag1, lag2      
  i=i+1
    tmp=IABS(il)
    If (il < 0) then
      CALL Linear_Correlation(DATA1=ts1(1+tmp:lt),DATA2=ts2(1:lt-tmp),UNDEF=undef,REG=0.,CORR=co,PROB=prob,DF=df)
    ELSE
      CALL Linear_Correlation(DATA1=ts1(1:lt-tmp),DATA2=ts2(1+tmp:lt),UNDEF=undef,REG=0.,CORR=co,PROB=prob,DF=df)
    ENDIF
    WRITE(11,rec=i) co, prob
    if (df == 27) c=SQRT(2.05**2/(df+2.05**2))
    if (df <= 26 .and. df >=24) c=SQRT(2.06**2/(df+2.06**2))
    if (df <= 23 .and. df >=22) c=SQRT(2.07**2/(df+2.06**2))
!    WRITE(12,*) il,  co, prob, c
    WRITE(*,*) il,  co, prob, c
  ENDDO

!****************  Make .ctl file ************************
  OPEN(21,file='correlogram.ctl',form='formatted',status='unknown')
  WRITE(21,'(A22)') 'DSET ^correlogram.gdat'
  WRITE(21,'(A26)') 'TITLE Lead/Lag correlation'
  WRITE(21,'(A6,E15.5)') 'UNDEF ', -999.
  WRITE(21,'(A19)') 'XDEF   1 linear 1 1'
  WRITE(21,'(A19)') 'YDEF   1 linear 1 1'
  WRITE(21,'(A19)') 'ZDEF   1 linear 1 1'
  WRITE(21,'(A5,I3,A8,A9,A4)') 'TDEF ', lag2-lag1+1, ' LINEAR ', '01JUL0000', ' 1yr'
  WRITE(21,'(A6)') 'VARS 2'
  WRITE(21,'(A5,I3,A17)') 'co   ', 1, ' -999 correlation'
  WRITE(21,'(A5,I3,A17)') 'prob ', 1, ' -999 probability'
  WRITE(21,'(A7)') 'ENDVARS'

!***************************************************************************
!******************************** SUBROUTINE *******************************

CONTAINS
!======================= Detrend =======================
! TITLE   : Data Detrending
! AUTHOR  : W.-M. KIM
! MODIFIED: J.-Y. PARK
! INFORMS :
!  - Revomes long-term linear trend by least-squares method.
!=======================================================
SUBROUTINE Detrend(DATA,UNDEF)
  IMPLICIT none
  REAL, INTENT(inout)           :: DATA(:,:,:)
  REAL, INTENT(in   ), OPTIONAL :: UNDEF
  REAL, DIMENSION(SIZE(DATA,3)) :: X, temp, det
  REAL    :: ave, xx
  INTEGER :: i, j, it, nx, ny, nt

  nx=SIZE(DATA,1)
  ny=SIZE(DATA,2)
  nt=SIZE(DATA,3)

  DO i=1, nx
  DO j=1, ny
    temp(:)=DATA(i,j,:)
    FORALL ( it=1:nt ) X(it)=FLOAT(it)-0.5*(nt+1)

    IF ( PRESENT(UNDEF) ) THEN
      IF ( COUNT(temp.ne.UNDEF).ne.0 ) THEN
        ave=SUM(X*temp,MASK=temp.ne.UNDEF)/COUNT(temp.ne.UNDEF)
        xx =SUM(X**2,MASK=temp.ne.UNDEF)/COUNT(temp.ne.UNDEF)
        FORALL ( it=1:nt , temp(it).ne.UNDEF ) det(it)=(ave/xx)*X(it)
        WHERE ( temp.ne.UNDEF )
          det=temp-det
        ELSEWHERE
          det=UNDEF
        ENDWHERE
      ELSE
        det=UNDEF
      END IF
    ELSE
      ave=SUM(X*temp)/nt
      xx=SUM(X**2)/nt
      FORALL ( it=1:nt ) det(it)=(ave/xx)*X(it)
      det=temp-det
    ENDIF
    DATA(i,j,:)=det(:)
  ENDDO
  ENDDO
END SUBROUTINE Detrend


!================= Linear_Correlation ==================
! TITLE   : Linear Correlation
! AUTHOR  : J.-Y. PARK (jyloves9@snu.ac.kr)
! MODIFIED: 6. Feb. 2009
! INFORMS : 
!   - Calculate the correlation coeff. of two time series.
!   - If 'REG' is present, Regresstion will be calculated.
!=======================================================
SUBROUTINE Linear_Correlation(DATA1,DATA2,UNDEF,REG,CORR,PROB,DF)
  IMPLICIT none
  REAL                             :: DATA1(:), DATA2(:)
  REAL,    INTENT(in   ), OPTIONAL :: UNDEF, REG
  REAL,    INTENT(  out)           :: CORR, PROB
  INTEGER, INTENT(  out), OPTIONAL :: df
  REAL, ALLOCATABLE                :: tDATA1(:), tDATA2(:), ax(:), ay(:)
  REAL, PARAMETER                  :: TINY=1.0E-20   ! regularize the unusual case of complete correlation.
  REAL                             :: mx, my, Sxx, Syy, Sxy, z, t, tmp1(100000), tmp2(100000)
  INTEGER                          :: n, c, c2, it

    c=SIZE(data1) ; c2=SIZE(data2)
    IF(c .ne. c2) then
      print*, "# of Corr. data NOT match!!"
    ENDIF

    IF(PRESENT(UNDEF)) then
      n=0
      DO it=1, c
        IF((data1(it) .ne. UNDEF) .and. (data2(it) .ne. UNDEF)) then
          n=n+1
          tmp1(n)=data1(it)
          tmp2(n)=data2(it)
        ENDIF
      ENDDO
    ELSE
      n=c
    ENDIF

    IF(n < 6)  then
!      print*, "n is less than 12"
      CORR=undef
      PROB=undef
      df=undef
      t=undef
      RETURN
    ENDIF

    ALLOCATE(tdata1(n),tdata2(n),ax(n),ay(n))
    tdata1=tmp1(1:n)
    tdata2=tmp2(1:n)

    mx=SUM(tdata1)/n
    my=SUM(tdata2)/n
    ax=tdata1-mx
    ay=tdata2-my
    Sxx=DOT_PRODUCT(ax,ax)
    Syy=DOT_PRODUCT(ay,ay)
    Sxy=DOT_PRODUCT(ax,ay)

    CORR=Sxy/(SQRT(Sxx*Syy)+TINY)
    z=0.5*LOG(((1.+CORR)+TINY)/((1.-CORR)+TINY))        ! Fisher's z transformation.
    IF(PRESENT(DF)) then
      CALL DOF(DATA1=tdata1,DATA2=tdata2,DF=df)
    ELSE
      df=n-2
    ENDIF

    t=CORR*SQRT(df/(((1.-CORR)+TINY)*((1.+CORR)+TINY))) ! NR2 EQ.14.5.5, Student's t-distbtn in the null case.
    PROB=betai(0.5*df,0.5,df/(df+t**2))                 ! Student's t probability.
    !PROB=erfcc(abs(z*sqrt(n-1.))/1.4142136)             ! (Either way derives the same PROB result)
    !c=SQRT(2.04**2/(df+1.96**2))  !! 95% 
    DEALLOCATE(tdata1,tdata2,ax,ay)

    If(PRESENT(REG)) then
      IF(REG==1.) then
       CORR=Sxy/(SQRT(Sxx*n))     ! Regression - dy/dx (dx:1STDV)
      ELSEIF(REG==2.) then
       CORR=Sxy/Sxx               ! Regression - dy/dx 
      ENDIF
    ENDIF

END SUBROUTINE linear_Correlation


!============ Degree of freedom Calculation ============
! TITLE   : D. O. F 
! AUTHOR  : J.-Y. PARK (jyloves9@snu.ac.kr)
! MODIFIED: 16. Feb. 2010
! INFORMS : 
!   - Calculate the Degree of Freedom by using autoCORRs.
!=======================================================
SUBROUTINE DOF(DATA1,DATA2,DF)
  IMPLICIT none
  REAL,    INTENT(in   )          :: DATA1(:),DATA2(:)
  INTEGER, INTENT(  out)          :: DF
  INTEGER                         :: LAG, NLAG, I, NT
  REAL                            :: AUTOCORR1(size(DATA1)), AUTOCORR2(size(DATA2)), M1, M2, V1, V2, C, D

  NT=size(DATA1,1)

  ! mean
  M1=SUM(DATA1) / FLOAT(NT)
  M2=SUM(DATA2) / FLOAT(NT)

  ! variance
  V1 = 0.
  V2 = 0.
  DO I = 1 , NT
    V1 = V1 + (DATA1(I)-M1)**2/FLOAT(NT)
    V2 = V2 + (DATA2(I)-M2)**2/FLOAT(NT)
  ENDDO

  ! autocorrelation
  DO LAG = 1 , NT-1
    AUTOCORR1(LAG) = 0.
    AUTOCORR2(LAG) = 0.
    NLAG = NT-LAG
    DO I = 1 , NLAG
      AUTOCORR1(LAG) = AUTOCORR1(LAG) + (DATA1(I)-M1)*(DATA1(I+LAG)-M1)/FLOAT(NT)
      AUTOCORR2(LAG) = AUTOCORR2(LAG) + (DATA2(I)-M2)*(DATA2(I+LAG)-M2)/FLOAT(NT)
    ENDDO
    IF (V1.NE.0) THEN
      AUTOCORR1(LAG) = AUTOCORR1(LAG) / V1
    ENDIF
    IF (V2.NE.0) THEN
      AUTOCORR2(LAG) = AUTOCORR2(LAG) / V2
    ENDIF
  ENDDO

  C = 0.
  DO I = 1 , NT * 5/6
    !C = C + AUTOCORR1(I)*AUTOCORR2(I)
    C = C + (1-(I/float(NT)))*(AUTOCORR1(I)*AUTOCORR2(I))
  ENDDO

  D = 0.
  D = 1. + 2.*C
  DF = NT / D
ENDSUBROUTINE



!================= betai ==================
FUNCTION betai(a,b,x)
! Returns the incomplete beta fuction Ix(a,b).
  IMPLICIT none
  REAL, INTENT(in) :: a,b,x
  REAL :: betai
  REAL :: bt
  IF ( x.LT.0. .OR. x.GT.1. ) STOP '  ERROR in betai : bad argument x...'
  IF ( x.EQ.0. .OR. x.EQ.1. ) THEN
   bt=0.
  ELSE
   bt=exp(gammln(a+b)-gammln(a)-gammln(b)+a*log(x)+b*log(1.-x))
  END IF
  IF ( x.LT.(a+1.)/(a+b+2.) ) THEN
   betai=bt*betacf(a,b,x)/a
   RETURN
  ELSE
   betai=1.-bt*betacf(b,a,1.-x)/b
   RETURN
  END IF
END FUNCTION betai

!================== betacf ==================
FUNCTION betacf(a,b,x)
! Used by betai :: Evaluates continued fraction for incomplete betat fuction by modified Lentz's method.
  IMPLICIT none
  REAL    :: betacf,a,b,x
  INTEGER :: m,m2
  REAL    :: aa,c,d,del,h,qab,qam,qap
  REAL,     PARAMETER :: EPS=3.e-7,FPMIN=1.e-30
  INTEGER , PARAMETER  :: MAXIT=100

  qab=a+b ; qap=a+1. ; qam=a-1. ; c=1. ; d=1.-qab*x/qap
  IF ( ABS(d).LT.FPMIN) d=FPMIN
  d=1./d ; h=d
  DO m=1,MAXIT
   m2=2*m ; aa=m*(b-m)*x/((qam+m2)*(a+m2))
   d=1.+aa*d
   IF ( ABS(d).LT.FPMIN ) d=FPMIN
   c=1.+aa/c
   IF ( ABS(c).LT.FPMIN ) c=FPMIN
   d=1./d ; h=h*d*c ; aa=-(a+m)*(qab+m)*x/((a+m2)*(qap+m2))
   d=1.+aa*d
   IF ( ABS(d).LT.FPMIN ) d=FPMIN
   c=1.+aa/c
   IF ( ABS(c).LT.FPMIN ) c=FPMIN
   d=1./d ; del=d*c ; h=h*del
   IF ( ABS(del-1.).LT.EPS ) GOTO 999
  END DO
  STOP '  Error in betacf : a or b too big, or MAXIT too small...'
999 betacf=h
  RETURN
END FUNCTION betacf

!================= gammln ===================
FUNCTION gammln(xx)
! Returns the value ln(GAMMA(xx)) for xx>0.
  REAL    :: gammln,xx
  INTEGER :: j
  DOUBLE PRECISION :: ser,stp,tmp,x,y,cof(6)
  SAVE cof,stp
  DATA cof,stp /76.18009172947146d0,-86.50532032941677d0,24.01409824083091d0,-1.231739572450155d0, &
  .1208650973866179d-2,-.5395239384953d-5,2.506628746310005d0/
  x=xx ; y=x ; tmp=x+5.5d0 ; tmp=(x+0.5d0)*LOG(tmp)-tmp ; ser=1.000000000190015d0
  DO j=1,6
   y=y+1.d0 ; ser=ser+cof(j)/y
  END DO
  gammln=tmp+LOG(stp*ser/x)
  RETURN
END FUNCTION gammln

END PROGRAM correlogram
