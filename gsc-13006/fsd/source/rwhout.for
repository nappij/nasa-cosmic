      SUBROUTINE RWHOUT
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON/CSTVAL/ TSTART,ZL0(10),ZL1(10),ZL2(10),ZLA(10),TTST
      COMMON/VARBLS/ DEPEND(150),DERIV(150)
      WRITE(50)TTST,(DEPEND(I),I=1,15),(DERIV(I),I=1,15)
      RETURN
      END
