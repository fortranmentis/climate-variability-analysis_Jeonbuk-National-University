PROGRAM MVEOF 
  !=============================== E.O.F. ================================
  ! TITLE     : Multi-Variate Empirical Orthogonal Functions
  ! AUTHOR    : J.-Y. PARK (jyloves9@snu.ac.kr)
  ! DEVELOPED : 11. Feb. 2009
  ! MODIFIED  : 14. May. 2009
  ! INFORMS   :
  !               |       Temporal EOF         |      Spatial EOF
  !   --------------------------------------------------------------------
  !               |  (X'X=C --> ELE')          | (XX'=C --> ELE')
  !    Pattern    | Each column of XE/sqrt(L)  | Each column of E*sqrt(L)
  !    Timeseries | Each column of E*sqrt(L)   | Each column of E'X/sqrt(L)
  !    Percentage |                 Diagonal elements of L   
  !   --------------------------------------------------------------------
  ! * You can choose multi input-variables.
  ! * Householder method used.
  !=======================================================================

  IMPLICIT none
  !******************************** Change Here !!! ****************************************
  INTEGER, PARAMETER :: LON1=120, LON2=240, LAT1=20, LAT2=60.0 ! Area Selection for EOF
  INTEGER, PARAMETER :: lx=144, ly=73, nt=36       ! Tot. Data Length
  REAL   , PARAMETER :: GINT=2.5                     ! Grid Interval 
  REAL   , PARAMETER :: UNDEF=-9.99e+8               ! Missing Value
  INTEGER, PARAMETER :: NV=1                         ! # of variables
  INTEGER, PARAMETER :: TINT=1                       ! Remove mean  (0:No, 1:Tot. mean, 12:Climatology)
  INTEGER, PARAMETER :: DeTrd=1                      ! Detrend      (0:remain, 1:remove)
  INTEGER, PARAMETER :: MATx=0                       ! Matrix type  (0:cov, 1:cor)
  INTEGER, PARAMETER :: MAG=0                        ! PC normalize (0:no, 1:yes)
  INTEGER, PARAMETER :: LATw=0                       ! LAT weighting(0:no, 1:yes)
  INTEGER, PARAMETER :: SPTL=0                       ! Spatial COV  (0:Auto, 1:yes)
  CHARACTER(50), PARAMETER :: outputd='./'    ! Output directory
  CHARACTER(90), PARAMETER :: input1='./slp_DJF_1982-2018.gdat'
  !CHARACTER(90), PARAMETER :: input1='./sst_mon_JAN1982-DEC2018.gdat'
  CHARACTER(5), PARAMETER  :: flag='_slp'    ! File name flag for Different options of EOF runs
  !----- IF the original data do not cover the whole globe, you may handle followings ------
  INTEGER, PARAMETER :: sx=NINT((lon1-1.25)/gint)+1   !=== When original data start from lon.=0.5
  INTEGER, PARAMETER :: sy=NINT((lat1+90)/gint)+1  !=== When original data start from lat.=-89.5
  !*****************************************************************************************
  INTEGER, PARAMETER :: nx=NINT((lon2-lon1)/gint)+1
  INTEGER, PARAMETER :: ny=NINT((lat2-lat1)/gint)+1
  INTEGER, PARAMETER :: nm=10             
  INTEGER            :: i, j, k, iy, im, it, iv, ier, c

  REAL               :: Data(lx,ly,nt,nv)   ! Original Data
  REAL               :: Sdata(nx,ny,nt,nv)  ! Selected Area Data
  REAL               :: Anom(nx,ny,nt,nv)   ! Anomaly Data
  REAL               :: EV(nx,ny,nm,nv)     ! Eigen vectors(Pattern)
  REAL               :: PCT(nm,nt),errb(nm) ! PC TimeSeries & its errors
  REAL               :: latv(ny), cosw(ny)  ! lat info. and cosine weighting
  REAL               :: temp(lx,ly,nt), tmp(nx,ny,nt), tp(nx,ny,nt), pi
  INTEGER            :: tmask(nt)           ! MASK for Missing Value(time)
  INTEGER            :: Mask(nx,ny,nv)      ! MASK for Missing Value(space)
  REAL,  ALLOCATABLE :: X(:,:), XX(:,:)     ! (Space,Time) Matrix [or (Time, Space)]
  REAL,  ALLOCATABLE :: COV(:,:)            ! Covariace Mat.[(Time, Time) or (sp,sp)]
  REAL,  ALLOCATABLE :: R(:,:),STDV(:,:)    ! Standard deviation & its matrix multp.
  REAL,  ALLOCATABLE :: D(:), E(:)          ! Main/Sub Diagonal(of Tridiagonal Mat.)
  REAL,  ALLOCATABLE :: Clim(:,:,:)         ! Climatology(or total mean for TINT=1)
  REAL,  ALLOCATABLE :: Ddata(:,:,:,:)      ! Data with out missing time steps


  OPEN(1,file=TRIM(input1), form='unformatted', &
          access='direct', recl=lx*ly*4, status='old')

  DO iv=1, nv
  DO it=1, nt
    READ(iv,rec=it) data(:,:,it,iv)
  ENDDO
  ENDDO


PRINT *, "- Area selecting from original Data..."
  DO iv=1, nv
    temp=data(:,:,:,iv)
    CALL Dselection(DATA=temp,NX=nx,NY=ny,SX=sx,SY=sy,SDATA=tmp)
    sdata(:,:,:,iv)=tmp
  ENDDO


  IF (detrd == 1) then
PRINT *, "- Detrending.... "
  DO iv=1, nv
    tmp=sdata(:,:,:,iv)
    CALL Detrend(DATA=tmp,UNDEF=undef)
    sdata(:,:,:,iv)=tmp
  ENDDO
  ENDIF


PRINT *, "- Anomaly calculating..."
  DO iv=1, nv
    IF (TINT == 0) then
      anom(:,:,:,iv)=sdata(:,:,:,iv)
    ELSE
      IF(iv==1) ALLOCATE(clim(nx,ny,tint))
      tmp=sdata(:,:,:,iv)
      CALL Anomaly(DATA=tmp,UNDEF=undef,ANOM=tp,CLIM=clim,TINT=tint)
      anom(:,:,:,iv)=tp
    ENDIF
  ENDDO


  IF (latw == 1) then
PRINT *, "- Latitude/Cosine Weighting..."
  pi=4.*ATAN(1.)
  DO iy=1, ny
    latv(iy)=FLOAT(LAT1)+GINT*(iy-1)
    cosw(iy)=COS(latv(iy)*pi/180.)
    WHERE(anom(:,iy,:,:) .ne. undef)  anom(:,iy,:,:)=anom(:,iy,:,:)*cosw(iy)
  ENDDO
  ENDIF


PRINT *, "- Remove missing timesteps..."
  DO iv=1, nv
    tmp=anom(:,:,:,iv)
    CALL REMOVEMISS(DATA=tmp,UNDEF=undef,C=c,tMASK=tmask)
    IF(iv==1) ALLOCATE(ddata(nx,ny,c,nv))
    ddata(:,:,:,iv)=tmp(:,:,1:c)
    print*, '   # of available timesteps :', c, 'out of', SIZE(anom,3)
  ENDDO


PRINT *, "- Matrix Reshaping(3D --> 2D)..."
  mask=1
  DO iv=1, nv
    !NOT using the grids having UNDEFs more than 50% of time dimension.
    WHERE(COUNT(ddata(:,:,:,iv).eq.UNDEF,DIM=3).ge.c*0.50) mask(:,:,iv)=0 
  ENDDO
  print*, '   # of available gridpoint :', sum(mask), 'out of', nx*ny*nv
  ALLOCATE(X(sum(mask),c))
  k=0
  DO iv=1, nv
  DO j=1, ny
  DO i=1, nx
    IF (mask(i,j,iv).eq.1) then
      k=k+1
      X(k,:)=ddata(i,j,:,iv)
    ENDIF
  ENDDO
  ENDDO
  ENDDO
!--- To see which time point is available ---
!DO i=1, c
!k=COUNT(X(:,i) .ne. undef, DIM=1) 
!IF(k/float(sum(mask)) >= 0.5) print*, i,  k
!enddo


PRINT *, "- Covariace/Correlation matrix calculating..."
  IF (sum(mask) .ge. SIZE(X,2) ) then !== temporal covariance
    IF (SPTL .eq. 1) GOTO 101
    ALLOCATE(cov(SIZE(X,2),SIZE(X,2)))
    DO i=1,c
    DO j=1,c
      IF ( matx == 0 ) THEN
      cov(i,j)=cov_ts(X(:,i),X(:,j),sum(mask),undef)
      ELSE
      PRINT*, "Warning : Correlation Matx. is not effective for temporal cov."
      cov(i,j)=cor_ts(X(:,i),X(:,j),sum(mask),undef)
      ENDIF
    ENDDO
    ENDDO
  ELSE                                !== spatial covariance
    101 ALLOCATE(cov(sum(mask),sum(mask)))
    DO i=1,sum(mask)
    DO j=1,sum(mask)
      IF ( matx == 0 ) THEN
      cov(i,j)=cov_ts(X(i,:),X(j,:),c,undef)
      ELSE
      cov(i,j)=cor_ts(X(i,:),X(j,:),c,undef)
      ENDIF
    ENDDO
    ENDDO
  ENDIF
!-------This Covariance calculating is not considering UNDEF-------
!  IF (sum(mask) .ge. SIZE(X,2)) then !== temporal covariance
!    ALLOCATE(cov(SIZE(X,2),SIZE(X,2)))
!    cov=MATMUL(TRANSPOSE(X),X)/(size(X,1)-1)    ! Covariace=X'X/(N-1)
!    IF (matx == 1) then           ! correlation matx.
!      STOP "Error : Correlation Matx. is not valid for temporal cov."
!    ENDIF
!  ELSE                        !== spatial covariance
!    ALLOCATE(cov(sum(mask),sum(mask)))
!    cov=MATMUL(X,TRANSPOSE(X))/(size(X,2)-1)    ! Covariace=X'X/(N-1)
!    IF (matx == 1) then           ! correlation matx.
!      ALLOCATE(r(sum(mask),1),stdv(sum(mask),sum(mask)))
!      r(:,1)=SQRT(SUM(X**2,DIM=2)/(size(X,2)-1))
!      stdv=MATMUL(r,TRANSPOSE(r))
!      cov=cov/stdv
!    ENDIF
!  ENDIF
!-----------------------------------------------------------------


PRINT *, "- EOF analysis is in progress..."
  ier=0
  IF (sum(mask) .ge. SIZE(X,2)) then
    IF (SPTL .eq. 1) GOTO 102
    ALLOCATE(d(SIZE(X,2)),e(SIZE(X,2)))
    CALL TRED2(SIZE(X,2),SIZE(X,2),cov,d,e,cov)   !--- Householder Method for Eigen Value Prob.
    CALL TQL2(SIZE(X,2),SIZE(X,2),d,e,cov,ier)    !--- (Output: d(percentage variance), cov(EOFs)
  ELSE
    102 ALLOCATE(d(sum(mask)),e(sum(mask)))
    CALL TRED2(sum(mask),sum(mask),cov,d,e,cov)
    CALL TQL2(sum(mask),sum(mask),d,e,cov,ier)
  ENDIF


PRINT *, "- Extracting Pattern and Time series from EOF result..."
PRINT *, "   : Pattern(2D --> 3D).."
  WHERE(X .eq. undef) X=0
  IF (sum(mask) .ge. SIZE(X,2)) then
    IF (SPTL .eq. 1) GOTO 103
    ALLOCATE(XX(sum(mask),SIZE(X,2)))
    XX=MATMUL(X,cov)
    k=0
    DO iv=1, nv
    DO j=1, ny
    DO i=1, nx
      IF (mask(i,j,iv).eq.1) then
        k=k+1
        IF (MAG .eq. 1) then ; ev(i,j,:,iv)=XX(k,:nm)               !-- Patterns
        ELSE ; ev(i,j,:,iv)=XX(k,:nm)/SQRT(d(:nm))                  !-- Patterns
        ENDIF
      ELSE ; ev(i,j,:,iv)=undef
      ENDIF
    ENDDO
    ENDDO
    ENDDO
  ELSE
    103 k=0
    DO iv=1, nv
    DO j=1, ny
    DO i=1, nx
      IF (mask(i,j,iv).eq.1) then
        k=k+1
        IF (MAG .eq. 1) then ; ev(i,j,:,iv)=cov(k,:nm)*SQRT(d(:nm)) !-- Patterns
        ELSE ; ev(i,j,:,iv)=cov(k,:nm)                              !-- Patterns
        ENDIF
      ELSE ; ev(i,j,:,iv)=undef
      ENDIF
    ENDDO
    ENDDO
    ENDDO
  ENDIF


PRINT *, "   : Time Series.."
  IF (sum(mask) .ge. SIZE(X,2)) then
    IF (SPTL .eq. 1) GOTO 104
    DO i=1,nm
      IF (MAG .eq. 1) then ; pct(i,1:SIZE(x,2))=cov(:,i)             !-- Time Series
      ELSE ; pct(i,1:SIZE(X,2))=cov(:,i)*SQRT(d(i))                  !-- Time Series
      ENDIF
    ENDDO
  ELSE
    104 ALLOCATE(XX(SUM(mask),SIZE(X,2)))
    XX=MATMUL(TRANSPOSE(cov),X)
    DO i=1,nm
      IF (MAG .eq. 1) then ; pct(i,1:SIZE(x,2))=XX(i,:)/SQRT(d(i))   !-- Time Series
      ELSE ; pct(i,1:SIZE(X,2))=XX(i,:)                              !-- Time Series
      ENDIF
    ENDDO
  ENDIF
! For data not qualified by missing criteria, say, 80% --
!WHERE (pct .eq. 0.) pct=undef


PRINT *, "- Final Data writing..."
  OPEN(11,file=TRIM(outputd)//'ev'//TRIM(flag)//'.gdat',form='unformatted',access='direct',recl=nx*ny*4,status='unknown')
  DO iv=1, nv
    DO im=1, nm
      WRITE(11,rec=nm*(iv-1)+im) ev(:,:,im,iv)
    ENDDO
  ENDDO
  CLOSE(11)

  OPEN(12,file=TRIM(outputd)//'pct'//TRIM(flag)//'.gdat',form='unformatted',access='direct',recl=nm*4,status='unknown')
  k=0
  DO it=1, nt
    IF (tmask(it) .eq. 1) then
      k=k+1
      WRITE(12,rec=it) pct(:,k)
    ELSE
      errb(:)=undef
      WRITE(12,rec=it) errb(:)
    ENDIF
  ENDDO
  CLOSE(12)

  OPEN(13,file=TRIM(outputd)//'pv'//TRIM(flag)//'.gdat',form='unformatted',access='direct',recl=nm*4,status='unknown')
    DO im=1, nm
      errb(im)=d(im)*sqrt(2./(size(D)-1)) ! According to North et al. 1982
      WRITE(*,'(A5,I2,F9.3,A1)') "Mode", im, d(im)/sum(d)*100, "%"
    ENDDO
    WRITE(13,rec=1)  d(1:nm)/sum(d)*100  ! Percentage variance
    WRITE(13,rec=2)  errb                ! Typical errors
  CLOSE(13)


!----- Make .ctl file 
  OPEN(10,file=TRIM(outputd)//'ev'//TRIM(flag)//'.ctl',form='formatted',status='unknown')
  WRITE(10,'(A19)') 'DSET ^ev'//TRIM(flag)//'.gdat'
  WRITE(10,'(A23)') 'TITLE EOF_eigen vectors'
  WRITE(10,'(A6,E15.5)') 'UNDEF ', undef
  WRITE(10,'(A5,I3,A8,I3,F4.1)') 'XDEF ', NINT((LON2-LON1)/GINT)+1, ' LINEAR ', LON1, GINT
  WRITE(10,'(A5,I3,A8,I3,F4.1)') 'YDEF ', NINT((LAT2-LAT1)/GINT)+1, ' LINEAR ', LAT1, GINT
  WRITE(10,'(A5,I3,A15)') 'ZDEF ', nm, ' LINEAR   1. 1.'
  WRITE(10,'(A7,A8,A9,A4)') 'TDEF  1', ' LINEAR ', '01JAN0001', ' 1yr'
  WRITE(10,'(A5,I2)') 'VARS ', nv
  DO iv=1, nv
  WRITE(10,'(A2,I3,A17)') 'ev', nm, ' -999 eof modes'
  ENDDO
  WRITE(10,'(A7)') 'ENDVARS'

  OPEN(20,file=TRIM(outputd)//'pct'//TRIM(flag)//'.ctl',form='formatted',status='unknown')
  WRITE(20,'(A19)') 'DSET ^pct'//TRIM(flag)//'.gdat'
  WRITE(20,'(A30)') 'TITLE EOF_principle components'
  WRITE(20,'(A6,E15.5)') 'UNDEF ', undef
  WRITE(20,'(A19)') 'XDEF   1 linear 1 1'
  WRITE(20,'(A19)') 'YDEF   1 linear 1 1'
  WRITE(20,'(A5,I3,A11)') 'ZDEF ', nm, ' linear 1 1'
  WRITE(20,'(A5,I3,A8,A9,A4)') 'TDEF ', nt, ' LINEAR ', '01JAN1982', ' 1mo'
  WRITE(20,'(A6)') 'VARS 1'
  WRITE(20,'(A5,I3,A17)') 'pct  ', nm, ' -999 pc series'
  WRITE(20,'(A7)') 'ENDVARS'

  OPEN(30,file=TRIM(outputd)//'pv'//TRIM(flag)//'.ctl',form='formatted',status='unknown')
  WRITE(30,'(A19)') 'DSET ^pv'//TRIM(flag)//'.gdat'
  WRITE(30,'(A29)') 'TITLE EOF_Percentage Variance'
  WRITE(30,'(A6,E15.5)') 'UNDEF ', undef
  WRITE(30,'(A19)') 'XDEF   1 linear 1 1'
  WRITE(30,'(A19)') 'YDEF   1 linear 1 1'
  WRITE(30,'(A5,I3,A11)') 'ZDEF ', nm, ' linear 1 1'
  WRITE(30,'(A5,I2,A8,A9,A4)') 'TDEF ', 1, ' LINEAR ', '01JAN0001', ' 1yr'
  WRITE(30,'(A6)') 'VARS 2'
  WRITE(30,'(A5,I3,A15)') 'pv   ', nm, ' -999 pv seires'
  WRITE(30,'(A5,I3,A15)') 'err  ', nm, ' -999 pv errors'
  WRITE(30,'(A7)') 'ENDVARS'

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

  !FORALL (i=1:SIZE(DATA,3)) CLIM(:,:,i)=CLIM(:,:,MOD(TINT,i))
  !ANOM=DATA-CLIM

END SUBROUTINE Anomaly


!================== Missing data =======================
! TITLE   : Remove missing data (time)
! AUTHOR  : J.-Y. PARK (jyloves9@snu.ac.kr)
! MODIFIED: 16. Feb. 2010
! INFORMS :
!
!=======================================================
SUBROUTINE removemiss(DATA,UNDEF,C,tMASK)
  IMPLICIT none
  REAL,    INTENT(inout)           :: DATA(:,:,:) 
  REAL,    INTENT(in   )           :: UNDEF
  INTEGER, INTENT(  out)           :: C, tmask(SIZE(DATA,3))
  INTEGER                          :: msk(SIZE(DATA,1),SIZE(DATA,2),SIZE(DATA,3)), it

  msk=0
  tmask=0
  c=0
  DO it=1, SIZE(DATA,3)
    WHERE(DATA(:,:,it).ne.UNDEF) msk(:,:,it)=1
    IF(SUM(msk(:,:,it)).ne.0) then 
      c=c+1
      tmask(it)=1
      data(:,:,c)=DATA(:,:,it)
    ENDIF
  ENDDO
ENDSUBROUTINE


!================== Data selection =====================
! TITLE   : Data Selection
! AUTHOR  : J.-Y. PARK (jyloves9@snu.ac.kr)
! MODIFIED: 6. Feb. 2009
! INFORMS :
!
!=======================================================
SUBROUTINE Dselection(DATA,nx,ny,sx,sy,SDATA)
  IMPLICIT none
  REAL,    INTENT(in   )           :: DATA(:,:,:) 
  INTEGER, INTENT(in   )           :: nx, ny, sx, sy
  REAL,    INTENT(  out)           :: sDATA(nx,ny,size(DATA,3)) 
  INTEGER                          :: i, j, k
 
  DO j=sy, sy+ny-1
  DO i=sx, sx+nx-1
    sDATA(i-sx+1,j-sy+1,:)=DATA(i,j,:)
  ENDDO
  ENDDO

END SUBROUTINE Dselection


!======================= Detrend =======================
! TITLE   : Data Detrending
! AUTHOR  : W.-M. KIM 
! MODIFIED: 3. MAR. 2010 (by J.-Y. PARK)
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


SUBROUTINE TQL2(NM,N,D,E,Z,IER)
  !. . . . . . . . . . . . . . . . . . . . . . . . . .  
  !   QL METHOD TO DETERMINE THE EIGENVALUES AND EIGENVECTORS OF:
  !     1)  A SYMMETRIC TRIDIAGONAL MATRIX.
  !     2)  A FULL SYMMETRIC MATRIX AFTER A PREVIOUS CALL TO TRED2.
  !
  !   CALLING MODE:
  !             CALL TQL2(NM,N,D,E,Z,IER)
  !   INPUTSS:
  !   NM  (I4)  1ST DIMENSION OF MATRICES A AND Z IN CALLING PROGRAM
  !   N   (I4)  SIZE OF Z
  !   D  (R*8)  MAIN DIAGONAL (N) OF THE TRIDIAGONAL MATRIX
  !   E  (R*8)  SUB-DIAGONAL (N) OF THE TRIDIAGONAL MATRIX
  !   Z  (R*8)  TABLE (NM,N) STORING THE UNITY MATRIX IF THE TRIDIAGONAL
  !             MATRIX IS DEFINED BY D AND E, CASE #1.
  !             FOR CASE #2, IT CONTAINS THE ELEMENTS OF THE TRANSFORMATION
  !             MATRIX AFTER A CALL TO TRED2.
  !   OUTPUTS:
  !   D  (R*8)  EIGENVALUES
  !   Z  (R*8)  EIGENVECTORS
  !   IER (I4)  ERROR CODE = 0,  CONVERGENCE OK.
  !                        = L,  NO CONVERGENCE FOR THE Lth EIGENVALUE
  !   REFERENCE:
  !   J.H.WILKINSON,-C.REINSCH,R.S.MARTIN
  !   HANDBOOK FOR AUTOMATIC COMPUTATION, VOL.2, LINEAR ALGEBRA
  !   SPRINGER-VERLAG 1971.
  !. . . . . . . . . . . . . . . . . . . . . . . . . .  
      INTEGER I,J,K,L,M,N,NM,JM,IER
      REAL  D(N),E(N),Z(NM,N),B,C,F,G,H,P,R,S,EPS,EPS1
      DATA EPS /0.D0/,JM /30/
      IER = 0
      IF (N.EQ.1) GO TO 38

    !--- MACHINE EPSILON
      IF (EPS.NE.0.D0) GO TO 12
      EPS = 1.D0
   10 EPS = EPS/2.D0
      EPS1 = 1.D0+EPS
      IF (EPS1.GT.1.D0) GO TO 10

   12 DO 14 I = 2,N
   14 E(I-1) = E(I)
      E(N) = 0.D0
      F = 0.D0
      B = 0.D0

      DO 28 L = 1,N
      J = 0
      H = EPS*(ABS(D(L))+ABS(E(L)))
      IF (B.LT.H) B = H

    !--- SEEK SMALLEST ELEMENT OF SUBDIAGONAL
      DO 16 M = L,N
      IF (ABS(E(M)).LE.B) GO TO 18
   16 CONTINUE
   18 IF (M.EQ.L) GO TO 26

    !--- START ITERATION
   20 IF (J.EQ.JM) GO TO 36
      J = J+1

    !--- SHIFT
      G = D(L)
      P = (D(L+1)-G)/(2.D0*E(L))
      R = SQRT(P*P+1.D0)
      D(L) = E(L)/(P+SIGN(R,P))
      H = G-D(L)
      DO 22 I = L+1,N
   22 D(I) = D(I)-H
      F = F+H

    !--- QL TRANSFORMATION
      P = D(M)
      C = 1.D0
      S = 0.D0
      DO 24 I = M-1,L,-1
      G = C*E(I)
      H = C*P
      IF (ABS(P).GE.ABS(E(I))) THEN
      C = E(I)/P
      R = SQRT(C*C+1.D0)
      E(I+1) = S*P*R
      S = C/R
      C = 1.D0/R
      ELSE
      C = P/E(I)
      R = SQRT(C*C+1.D0)
      E(I+1) = S*E(I)*R
      S = 1.D0/R
      C = C*S
      ENDIF
      P = C*D(I)-S*G
      D(I+1) = H+S*(C*G+S*D(I))

    !--- ELEMENTS OF EIGENVECTORS
      DO 24 K = 1,N
      H = Z(K,I+1)
      Z(K,I+1) = S*Z(K,I)+C*H
      Z(K,I) = Z(K,I)*C-S*H
   24 CONTINUE
      E(L) = S*P
      D(L) = C*P
      IF (ABS(E(L)).GT.B) GO TO 20

    !--- CONVERGENCE
   26 D(L) = D(L)+F
   28 CONTINUE

    !--- SORT EIGENVALUES AND EIGENVECTORS IN ASVENDING ORDER
      DO 34 L = 2,N
      I = L-1
      K = I
      P = D(I)
      DO 30 J = L,N
      IF (D(J).LE.P) GO TO 30
      K = J
      P = D(J)
   30 CONTINUE
      IF (K.EQ.I) GO TO 34
      D(K) = D(I)
      D(I) = P
      DO 32 J = 1,N
      P = Z(J,I)
      Z(J,I) = Z(J,K)
   32 Z(J,K) = P
   34 CONTINUE
      GO TO 38

    !--- NO CONVERGENCE
   36 IER = L
   38 RETURN
END SUBROUTINE TQL2

SUBROUTINE TRED2(NM,N,A,D,E,Z)
  !. . . . . . . . . . . . . . . . . . . . . . . . . . 
  !     TRIDIAGONALIZATION OF A SYMMETRIC MATRIX BY ORTHOGONAL TRANSFORMATIONS
  !     (ALGORITHM OF HOUSEHOLDER)
  !     CALLING MODE:
  !               CALL TRED2(NM,N,A,D,E,Z)
  !     INPUTS:
  !     NM  (I4)  1ST DIMENSION OF MATRICES A AND Z IN CALLING PROGRAM
  !     N   (I4)  SIZE OF A
  !     A  (R*8)  TABLE(NM,N) STORING THE COEFFICIENTS OF SYMMETRIC A MATRIX
  !               (LOWER HALF), A IS NOT DESTROYED DURING THE PROCESS
  !               IF Z MATRIX HAS NOT THE SAME ADDRESS.
  !     OUTPUTS:
  !     D  (R*8)  MAIN DIAGONAL (N) OF REDUCED TRIDIAGONAL MATRIX
  !     E  (R*8)  SUB-DIAGONAL (N) OF REDUCED TRIDIAGONAL MATRIX
  !     Z  (R*8)  TABLE (NM,N) STORING THE ELEMENTS OF THE ORTHOGONAL
  !               TRANSFORMATION MATRIX.
  !     REFERENCE:
  !     J.H.WILKINSON,-C.REINSCH,R.S.MARTIN
  !     HANDBOOK FOR AUTOMATIC COMPUTATION, VOL.2, LINEAR ALGEBRA
  !     SPRINGER-VERLAG 1971.
  !. . . . . . . . . . . . . . . . . . . . . . . . . . 
      INTEGER I,J,K,L,N,NM
      REAL  A(NM,N),D(N),E(N),Z(NM,N),F,G,H,HH,SCALE

    !--- LOWER HALF OF A PUT INTO Z
      DO 10 I = 1,N
      DO 10 J = 1,I
   10 Z(I,J) = A(I,J)
      IF (N.EQ.1) GO TO 32

    !--- N-2 STAGE OF TRANSFORMATION
      DO 30 I = N,2,-1
      L = I-1
      H = 0.

    !--- CONDITIONNING BY NORM OF A
      SCALE = 0.
      IF (L.LT.2) GO TO 14
      DO 12 K = 1,L
   12 SCALE = SCALE+ABS(Z(I,K))
      IF (SCALE.NE.0.) GO TO 16

   14 E(I) = Z(I,L)
      GO TO 28

   16 DO 18 K = 1,L
      Z(I,K) = Z(I,K)/SCALE
      H = H+Z(I,K)*Z(I,K)
   18 CONTINUE

      F = Z(I,L)
      G = -SIGN(SQRT(H),F)
      E(I) = SCALE*G
      H = H-F*G
      Z(I,L) = F-G
      F = 0.
      DO 24 J = 1,L
      Z(J,I) = Z(I,J)/H
      G = 0.

    !--- ELEMENT OF A*U
      DO 20 K = 1,J
   20 G = G+Z(J,K)*Z(I,K)
      IF (L.GE.J+1) THEN
      DO 22 K = J+1,L
   22 G = G+Z(K,J)*Z(I,K)

    !--- ELEMENT OF P = A*U/H
      END IF
      E(J) = G/H
      F = F+E(J)*Z(I,J)
   24 CONTINUE

    !--- ELEMENT OF K
      HH = F/(H+H)

    !--- REDUCED FORM OF A
      DO 26 J = 1,L
      F = Z(I,J)
      G = E(J)-HH*F
      E(J) = G
      DO 26 K = 1,J
      Z(J,K) = Z(J,K)-F*E(K)-G*Z(I,K)
   26 CONTINUE

   28 D(I) = H
   30 CONTINUE

    !--- END OF TRANSFORMATION
   32 D(1) = 0.
      E(1) = 0.

    !--- ACCUMULATE TRANSFORMATION MATRICES IN Z
      DO 40 I = 1,N
      L = I-1
      IF (D(I).NE.0.) THEN
      DO 36 J = 1,L
      G = 0.
      DO 34 K = 1,L
   34 G = G+Z(I,K)*Z(K,J)
      DO 36 K = 1,L
      Z(K,J) = Z(K,J)-G*Z(K,I)
   36 CONTINUE
      END IF
      D(I) = Z(I,I)
      Z(I,I) = 1.
      IF (L.LT.1) GO TO 40
      DO 38 J = 1,L
      Z(I,J) = 0.
      Z(J,I) = 0.
   38 CONTINUE
   40 CONTINUE

      RETURN
END SUBROUTINE TRED2


FUNCTION cov_ts(ts1,ts2,nt,dmiss)
! INFORMS : sulim@snu.ac.kr July 7, 2007
! PURPOSE : covariance with missing process
! ACCEPTS : ts1(nt), ts2(nt), dmiss
! RETURNS : cov_ts
  Integer             :: nt, nv
  REAL                :: cov_ts, dmiss, var1, var2, covt
  REAL, DIMENSION(nt) :: ts1, ts2

  nv=0
  DO it=1,nt
    IF ( ts1(it) .NE. dmiss .AND. ts2(it) .NE. dmiss) THEN
      nv=nv+1
    ENDIF
  ENDDO
  IF ( nv == 0 ) THEN
    PRINT*,'  - Error, no valid value...'; !STOP
  ENDIF
  covt=0.
  DO it=1,nt
    IF ( ts1(it) .NE. dmiss .AND. ts2(it) .NE. dmiss) THEN
      covt=covt+ts1(it)*ts2(it)/FLOAT(nv)
    ENDIF
  ENDDO

  IF ( FLOAT(nv)/FLOAT(nt) >= 0.5 ) THEN
    !-- missing criteria = 50%
    cov_ts=covt
  ELSE
    PRINt*, "dmiss Found: not enough grids for COVmatx!"; STOP
    cov_ts=dmiss
  ENDIF

END FUNCTION cov_ts

FUNCTION cor_ts(ts1,ts2,nt,dmiss)
! INFORMS : sulim@snu.ac.kr July 8, 2007
! PURPOSE : correlation with missing process
! ACCEPTS : ts1(nt), ts2(nt), dmiss
! RETURNS : cor_ts
  Integer             :: nt, nv
  REAL                :: cor_ts, dmiss, var1, var2, ts1m, ts2m, covt
  REAL, DIMENSION(nt) :: ts1, ts2 

  ts1m=0.; ts2m=0.; nv=0
  DO it=1,nt
    IF ( ts1(it) .NE. dmiss .AND. ts2(it) .NE. dmiss) THEN
      nv=nv+1
      ts1m=ts1m+ts1(it)
      ts2m=ts2m+ts1(it)
    ENDIF
  ENDDO
  IF ( nv == 0 ) THEN
    PRINT*,'  - Error, all missing data...'; STOP
  ENDIF
  ts1m=ts1m/FLOAT(nv)
  ts2m=ts2m/FLOAT(nv)
  covt=0.; var1=0.; var2=0.
  DO it=1,nt
    IF ( ts1(it) .NE. dmiss .AND. ts2(it) .NE. dmiss) THEN
      var1=var1+ts1(it)**2/FLOAT(nv)
      var2=var2+ts2(it)**2/FLOAT(nv)
      covt=covt+ts1(it)*ts2(it)/FLOAT(nv)
    ENDIF
  ENDDO

  IF ( FLOAT(nv)/FLOAT(nt) >= 0.5 ) THEN
    !-- missing criteria = 50%
    IF ( var1*var2 == 0 ) THEN
      PRINT*,'  - Error, all constant...'; STOP
    ELSE
      cor_ts=covt/SQRT(var1*var2)
    ENDIF
  ELSE
    PRINt*, "dmiss Found: not enough grids for CORmatx!"; STOP
    cor_ts=dmiss
  ENDIF

END FUNCTION cor_ts


END PROGRAM MVEOF
