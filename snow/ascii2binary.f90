program aaa
 INTEGER, PARAMETER :: nt=38
 REAL :: snow(nt)

 !---- Data read
 open(10, file='snowday1983-2020_JAN.txt',form='formatted', status='old')
 read(10,*) snow(:)

 !---- Data write
 open(20, file='snowday_JAN.gdat',form='unformatted',access='direct',recl=1*4, status='unknown')
 DO i=1, nt
  write(20,rec=i) snow(i)
 ENDDO

end program aaa
