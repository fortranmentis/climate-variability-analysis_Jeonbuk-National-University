program aaa
 INTEGER, PARAMETER :: nt=40
 REAL :: jfm(nt)

 !---- Data read
 open(10, file='JFM.txt',form='formatted', status='old')
 read(10,*) jfm(:)

 !---- Data write
 open(20, file='JFM.gdat',form='unformatted',access='direct',recl=1*4, status='unknown')
 DO i=1, nt
  write(20,rec=i) jfm(i)
 ENDDO

end program aaa
