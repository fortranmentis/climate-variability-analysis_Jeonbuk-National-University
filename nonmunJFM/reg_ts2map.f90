PROGRAM sstevolution
  INTEGER,PARAMETER  :: lx=360, ly=180, nm=1, lt=38
  INTEGER,PARAMETER  :: tint=1                      ! Remove mean  (0:No, 1:Tot. mean, 12:Climatology)
  REAL ,  PARAMETER  :: reg=0                       ! (0:corr. map,  1:reg. map,  2:reg. map(1STDV))
  INTEGER,PARAMETER  :: DeTrd=0                     ! Detrend      (0:remain, 1:remove)
  INTEGER,PARAMETER  :: lag1=0, lag2=0, lagint=0
  REAL ,  PARAMETER  :: UNDEF=-9.99e8
  CHARACTER(40), PARAMETER :: inputind='JFM.gdat'
  CHARACTER(30), PARAMETER :: inputdata='sst_JFM_-12.gdat'
  CHARACTER(40), PARAMETER :: output='corr_snow_JFM_sst_JFM_-12'
  REAL               :: ind(lt), temp1(lt)
  REAL               :: sst(lx,ly,lt), temp2(lt)
  REAL               :: corr(lx,ly), prob(lx,ly), co, pr, t
  REAL               :: anom(lx,ly,lt), clim(lx,ly,lt), temp(1,1,lt)
  CHARACTER          :: ch
  INTEGER            :: i, j, it, iv, md, df, nt

! File.1 : time series  
  OPEN(1,file=TRIM(inputind),form='unformatted',access='direct',recl=lt*4,status='old')
    READ(1,rec=1) ind(:)
  CLOSE(1)

! File.2 : Map
  OPEN(2,file=TRIM(inputdata),form='unformatted',access='direct',recl=lx*ly*4, status='old')
  DO it=1, lt
    READ(2,REC=it) sst(:,:,it)
  ENDDO
  CLOSE(2)


!----   Remove cycle
  CALL Anomaly(DATA=sst,UNDEF=undef,ANOM=anom,CLIM=clim,TINT=tint)
  sst=anom


  temp1=ind(:)
!----   Remove trend
    IF(Detrd ==1 ) then
     temp(1,1,:)=temp1
     CALL Detrend(temp,undef)
     temp1=temp(1,1,:)

     CALL Detrend(sst,undef)
    ENDIF

    ik=0
    DO il= 1, 1
     ik=ik+1
     DO j=1, ly
     DO i=1, lx
      temp2=sst(i,j,:)
       Call Linear_Correlation(DATA1=temp1(1:lt),DATA2=temp2(1:lt),UNDEF=undef,REG=reg,CORR=co,PROB=pr,DF=df)
!      IF(il<0) then
!       Call Linear_Correlation(DATA1=temp1(1-il:lt),DATA2=temp2(1:lt+il),UNDEF=undef,REG=reg,CORR=co,PROB=pr,DF=df)
!      ELSE
!       Call Linear_Correlation(DATA1=temp1(1:lt-il),DATA2=temp2(1+il:lt),UNDEF=undef,REG=reg,CORR=co,PROB=pr,DF=df)
!      ENDIF
      corr(i,j)=co
      prob(i,j)=pr
     ENDDO
     ENDDO
 
    write(ch,'(I1)') md

    OPEN(3,file=''//TRIM(output)//'.gdat', form='unformatted', &
          access='direct', recl=lx*ly*4, status='unknown')
    WRITE(3,rec=2*(ik-1)+1) corr
    WRITE(3,rec=2*(ik-1)+2) prob
    ENDDO
    CLOSE(3)

  !---- Make .ctl file ----
    OPEN(10,file=''//TRIM(output)//'.ctl',form='formatted',status='unknown')
    WRITE(10,'(A49)') 'DSET ^'//TRIM(output)//'.gdat'
    WRITE(10,'(A30)') 'TITLE '//TRIM(output)//' regress'
    WRITE(10,'(A6,E15.5)') 'UNDEF ', undef
    IF(lx==144) then
    WRITE(10,'(A5,I3,A8,F5.2,F4.1)') 'XDEF ', lx, ' LINEAR ', 1.25, 2.5
    WRITE(10,'(A5,I3,A8,F7.2,F4.1)') 'YDEF ', ly,  ' LINEAR ', -88.75, 2.5
    ELSE
    WRITE(10,'(A5,I3,A8,F4.1,F4.1)') 'XDEF ', lx, ' LINEAR ', 0.5, 1.0
    WRITE(10,'(A5,I3,A8,F6.1,F4.1)') 'YDEF ', ly,  ' LINEAR ', -89.5, 1.0
    ENDIF
    WRITE(10,'(A5,I3,A15)') 'ZDEF ', 1, ' LINEAR   1. 1.'
    WRITE(10,'(A5,I3,3A9)') 'TDEF ', 1, ' LINEAR ', '01JAN0001', ' 1yr'
    WRITE(10,'(A5,I2)') 'VARS ', 2
    WRITE(10,'(A5,I1,I3,A20)') 'corr ', 1, 1, ' -999  correlation'
    WRITE(10,'(A5,I1,I3,A20)') 'prob ', 1, 1, ' -999  probability'
    WRITE(10,'(A7)') 'ENDVARS'
    CLOSE(10)


CONTAINS
!====================== Anomaly ===========================
! TITLE   : Anomaly
! AUTHOR  : J.-Y. PARK (jyloves9@snu.ac.kr)
! MODIFIED: 6. Feb. 2009
! INFORMS :
!   - CLIM is climatology for TINT=12 and mean for TINT=1.
!     Therefore, ANOM has different values according to TINT
!
!==========================================================
SUBROUTINE Anomaly(DATA,UNDEF,ANOM,CLIM,TINT)
  IMPLICIT none
  REAL,    INTENT(  out)           :: ANOM(:,:,:)
  REAL,    INTENT(  out)           :: CLIM(:,:,:)
  REAL,    INTENT(in   )           :: DATA(:,:,:)
  REAL,    INTENT(in   ), OPTIONAL :: UNDEF
  INTEGER, OPTIONAL                :: TINT
  INTEGER :: i, j, it

  IF (PRESENT(TINT)) then
  ELSE ; TINT=1
  ENDIF

  IF (PRESENT(UNDEF)) then
    !--- Climatology (CLIM is just a MEAN for TINT=1) 
    DO it=1, TINT
      where(COUNT(DATA(:,:,it::TINT) .ne. UNDEF, DIM=3) .ne. 0)
        CLIM(:,:,it)=SUM(DATA(:,:,it::TINT), MASK=DATA(:,:,it::TINT).ne.UNDEF, DIM=3) / &
                     COUNT(DATA(:,:,it::TINT) .ne. UNDEF, DIM=3)
      elsewhere
        CLIM(:,:,it)=undef
      endwhere
    ENDDO

    !--- Anomaly 
    DO i=1, SIZE(DATA,3)
      j=mod(i,TINT) ; if (j .eq. 0) j=TINT
      where(DATA(:,:,i) .ne. UNDEF)
        anom(:,:,i)=DATA(:,:,i)-CLIM(:,:,j)
      elsewhere
        anom(:,:,i)=UNDEF
      endwhere
    ENDDO

  ELSE
    DO it=1, TINT
      CLIM(:,:,it)=SUM(DATA(:,:,it::TINT), DIM=3) / SIZE(DATA(:,:,it::TINT), DIM=3)
    ENDDO

    DO i=1, SIZE(DATA,3)
      j=mod(i,TINT) ; if (j .eq. 0) j=TINT
        anom(:,:,i)=DATA(:,:,i)-CLIM(:,:,j)
    ENDDO
  ENDIF

END SUBROUTINE Anomaly


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
  REAL                             :: mx, my, Sxx, Syy, Sxy, z, t, tmp1(1000000), tmp2(1000000)
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
      IF(REG==2.) then
       CORR=Sxy/(SQRT(Sxx*n))     ! Regression - dy/dx (dx:1STDV)
      ELSEIF(REG==1.) then
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
    C = C + AUTOCORR1(I)*AUTOCORR2(I)
  ENDDO

  D = 0.
  D = 1. + 2.*C
  DF = NT / D
ENDSUBROUTINE



!================= Linear_Correlation ==================
! TITLE   : Linear Correlation
! AUTHOR  : J.-Y. PARK (jyloves9@snu.ac.kr)
! MODIFIED: 6. Feb. 2009
! INFORMS : 
!   - Calculate the correlation coeff. of two time series.
!   - If 'REG' is present, Regresstion will be calculated.
!=======================================================
SUBROUTINE Linear_CorrelationOLD(DATA1,DATA2,UNDEF,REG,CORR,PROB,T)

  IMPLICIT none
  REAL, INTENT(  out)           :: CORR, PROB, t
  REAL, INTENT(in   )           :: DATA1(:), DATA2(:)
  REAL, INTENT(in   ), OPTIONAL :: UNDEF, REG
  REAL, PARAMETER  :: TINY=1.0E-20   ! regularize the unusual case of complete correlation.
  REAL, DIMENSION(SIZE(data1)) :: ax, ay
  REAL    :: mx, my, Sxx, Syy, Sxy, df, z
  INTEGER :: n

  IF(PRESENT(UNDEF) .and. ANY(data1.eq.undef .or. data2.eq.undef)) then
    CORR=undef
    PROB=undef
    z=undef
  ELSE
    n=SIZE(data1)
    mx=SUM(data1)/n
    my=SUM(data2)/n
    ax=data1-mx
    ay=data2-my
    Sxx=DOT_PRODUCT(ax,ax)
    Syy=DOT_PRODUCT(ay,ay)
    Sxy=DOT_PRODUCT(ax,ay)

    CORR=Sxy/(SQRT(Sxx*Syy)+TINY)
    z=0.5*LOG(((1.+CORR)+TINY)/((1.-CORR)+TINY))        ! Fisher's z transformation.
    df=n-2
    t=CORR*SQRT(df/(((1.-CORR)+TINY)*((1.+CORR)+TINY))) ! NR2 EQ.14.5.5, Student's t-distbtn in the null case.
    PROB=betai(0.5*df,0.5,df/(df+t**2))                 ! Student's t probability.
    !PROB=erfcc(abs(z*sqrt(n-1.))/1.4142136)             ! (Either way derives the same PROB result)
    !c=SQRT(2.04**2/(df+1.96**2))  !! 95% 

    If(PRESENT(REG)) then
      !CORR=Sxy/(SQRT(Sxx*n))     ! Regression_1
      CORR=Sxy/Sxx               ! Regression_2
    ENDIF
  ENDIF

END SUBROUTINE linear_CorrelationOLD

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
  DATA cof,stp /76.18009172947146d0,-86.50532032941677d0,24.01409824083091d0,&
               -1.231739572450155d0,.1208650973866179d-2,-.5395239384953d-5,2.506628746310005d0/
  x=xx ; y=x ; tmp=x+5.5d0 ; tmp=(x+0.5d0)*LOG(tmp)-tmp ; ser=1.000000000190015d0
  DO j=1,6
   y=y+1.d0 ; ser=ser+cof(j)/y
  END DO
  gammln=tmp+LOG(stp*ser/x)
  RETURN
END FUNCTION gammln

END PROGRAM sstevolution
