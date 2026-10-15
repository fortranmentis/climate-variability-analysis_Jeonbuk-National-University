program aaa
 INTEGER, PARAMETER :: nt=19
 REAL :: snow(nt)

 !---- Data read
 open(10, file='snow.txt',form='formatted', status='old')
 read(10,*) snow(:)

 !---- Data write
 open(20, file='snow.gdat',form='unformatted',access='direct',recl=1*4, status='unknown')
 DO i=1, nt
  write(20,rec=i) snow(i)
 ENDDO

end program aaa
