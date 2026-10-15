program aaa
 INTEGER, PARAMETER :: nt=39
 REAL :: wind(nt)

 !---- Data read
 open(10, file='wind.txt',form='formatted', status='old')
 read(10,*) wind(:)

 !---- Data write
 open(20, file='wind.gdat',form='unformatted',access='direct',recl=1*4, status='unknown')
 DO i=1, nt
  write(20,rec=i) wind(i)
 ENDDO

end program aaa
