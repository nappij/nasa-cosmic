      FUNCTION DARSIN(X)
      IMPLICIT REAL *8(A-H,O-Z)
      IF(DABS(X).LT.1.D0) GO TO 1
      DARSIN=DSIGN(1.D0,X)*1.5707963267948966D0
      RETURN
    1 IF(DABS(X).GT.1.D-7) GO TO 2
      DARSIN=X
      RETURN
    2 DARSIN=DATAN(X/DSQRT(1.D0-X**2))
      RETURN
      END
