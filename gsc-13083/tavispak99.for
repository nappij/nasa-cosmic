      SUBROUTINE TAVISPAK99(A,B,C,SOLN,KVISFLAG,LUERR,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE SOLVES FOR THE ZEROS OF THE FUNCTION
C        FCN = A*COS(EA) + B*SIN(EA) - C
C
C VARIABLE DIM TYPE I/O DESCRIPTION
C -------- --- ---- --- -----------
C
C A         1   R*8  I  THE 'A' COEFFICIENT IN THE EXPRESSION
C
C B         1   R*8  I  THE 'B' COEFFICIENT IN THE EXPRESSION
C
C C         1   R*8  I  THE 'C' COEFFICIENT IN THE EXPRESSION
C
C SOLN      2   R*8  O  TWO ECCENTRIC ANOMALY VALUES AT WHICH THE
C                       CURVE IS ZERO. THE CURVE IS INCREASING AT
C                       SOLN(1) AND DECREASING AT SOLN(2).
C
C                       IF THE CURVE HAS NO ZEROS, THE ECCENTRIC ANOMALY
C                       YIELDING THE VALUE NEAREST ZERO IS RETURNED IN
C                       SOLN(1) AND SOLN(2).
C
C KVISFLAG  1   I*4  O  FLAG INDICATING THE ZERO'S STATUS OF THE CURVE.
C                       = -1, CURVE IS ALWAYS NEGATIVE.
C                       =  0, CURVE HAS POSITIVE AND NEGATIVE SEGMENTS.
C                       =  1, CURVE IS ALWAYS POSITIVE.
C
C IERR      1   I*4  O  = 0, NO ERRORS.
C                       = OTHERWISE, NUMERICAL ERROR. NO SOLN RETURNED.
C
C***********************************************************************
C
C CODED BY C PETRUZZO GSFC/742 10/85.
C    MODIFIED....
C
C***********************************************************************
C
      REAL*8 SOLN(2)
      REAL*8 A13/-1.D0/, A23/-1.D0/, A33/-1.D0/
      REAL*8 HALFPI / 1.570796326794897D0 /
      REAL*8 PI     / 3.141592653589793D0 /
      REAL*8 TWOPI  / 6.283185307179586D0 /
      REAL*8 DEGRAD / 57.29577951308232D0 /
      REAL*8 TOLER/1.D-5/
C
      DET(A11,A21,A31,A12,A22,A32) =
     *   A11*A22*A33 + A12*A23*A31 + A13*A21*A32
     *  -A31*A22*A13 - A21*A12*A33 - A11*A32*A23
C
      IBUG = 0
      LUBUG = 19
C
      IF(IBUG.NE.0) WRITE(LUBUG,8501) A,B,C
 8501 FORMAT(' TAVISPAK99 DEBUG. INPUT. A,B,C=',3G15.7)
C
C THE FUNCTION DEFINES WHEN A TARGET SATISFIES THE AVAILABILITY
C REQUIREMENT.  WHEN THE FUNCTION IS POSITIVE, IT IS AVAILABLE.  WHEN
C NEGATIVE, IT IS NOT AVAILABLE.  THREE SITUATIONS ARE POSSIBLE:
C
C    1. THE FUNCTION IS ALWAYS POSITIVE. HENCE, TARGET IS ALWAYS
C       AVAILABLE.
C    2. THE FUNCTION IS SOMETIMES POSITIVE AND SOMETIMES NEGATIVE.
C       TRANSITION BETWEEN AVAILABILITY AND NON-AVAILABILITY OCCURS
C       WHEN THE FUNCTION CHANGES SIGN. IE, AT THE FCN'S ZEROS.
C    3. THE FUNCTION IS ALWAYS POSITIVE. HENCE, TARGET IS NEVER
C       AVAILABLE.
C
C
C INITIALIZE
C
      IERR = 0
C
C DETERMINE THE MAX AND MIN VALUES OF THE FCN TO SEE IF ZEROS EXIST.
C TO DO THIS, WE DIFFERENTIATE  FCN = A*COS(EA) + B*SIN(EA) - C,  SET
C THE DERIVATIVE TO ZERO, THEN FIND EA'S WHERE MAX AND MIN VALUES OCCUR.
C IE, FIND EA'S WHERE  -A * SIN(EA) + B * COS(EA) = 0.   SOLUTIONS ARE
C EA=DATAN(B/A) AND EA=PI+DATAN(B/A).
C
C    FIND THE EA'S(EA1 AND EA2) WHERE THE MIN AND MAX VALUES OF OCCUR.
      IF(DABS(A).GT.TOLER) THEN
        EA1 = DATAN( B/A )
      ELSE   ! B * COS(EA) = 0, SO WANT EA'S FOR COS(EA)=0.D0
        EA1 = HALFPI
        END IF
      SINEA1 = DSIN(EA1)
      COSEA1 = DCOS(EA1)
      VAL1 = A*COSEA1 + B*SINEA1 - C
      EA2 = EA1 + PI
      SINEA2 = -SINEA1
      COSEA2 = -COSEA1
      VAL2 = A*COSEA2 + B*SINEA2 - C
      IF(VAL1.LE.VAL2) THEN
        EAMIN = EA1
        EAMAX = EA2
      ELSE
        EAMIN = EA2
        EAMAX = EA1
        END IF
      VMIN = DMIN1(VAL1,VAL2)
      VMAX = DMAX1(VAL1,VAL2)
C
C    DETERMINE WHETHER THE CURVE IS ALWAYS NEGATIVE, ALWAYS POSITIVE, OR
C    A MIX.
      IF(VMIN.LT.-TOLER .AND. VMAX.GT.+TOLER) THEN
        KVISFLAG = 0   ! A MIX OF POSITIVE AND NEGATIVE
      ELSE
C      RETURN THE EA WHERE THE FUNCTION IS NEAREST TO THE FCN=0 AXIS.
        CONTINUE
        IF(VMIN.GE.-TOLER) THEN
          KVISFLAG = 1     ! ALWAYS POSITIVE
          SOLN(1) = EAMIN
          SOLN(2) = EAMIN
        ELSE
          KVISFLAG = -1    ! ALWAYS NEGATIVE
          SOLN(1) = EAMAX
          SOLN(2) = EAMAX
          END IF
        END IF
      IF(IBUG.NE.0) WRITE(LUBUG,5644) KVISFLAG,
     *     EA1*DEGRAD,VAL1,EA2*DEGRAD,VAL2
 5644 FORMAT(' TAVISPAK99 DEBUG 5644.  MIN/MAX INFO. KVISFLAG=',I3/,
     *       '   EA1,VAL1=',2G13.5,'   EA2,VAL2=',2G13.5)
C
C
      IF(KVISFLAG.EQ.0) THEN
C      CURVE CROSSES FCN=0 AXIS.  SOLVE FOR THE ECCENTRIC ANOMALIES
C      MAKING THE FUNCTION ZERO.
        ASINARG = C / DSQRT(A*A+B*B)
        IF(DABS(ASINARG).GT.1.D0) THEN
          IF(IBUG.NE.0) WRITE(LUBUG,8609) ASINARG*DEGRAD
 8609     FORMAT(' TAVISPAK99. BAD ASINARG. VALUE=',G23.16)
          IERR = 3
          GO TO 9999
          END IF
        IF(DABS(B).GT.TOLER) THEN
          TERM1 = DASIN( ASINARG )
          TERM2 = DATAN(-A/DABS(B))
          TEMP = DSIGN(1.D0,B)
          SOLN1 =      TEMP*(TERM1+TERM2)
          SOLN2 = PI - TEMP*(TERM1-TERM2)
          IF(IBUG.NE.0) WRITE(LUBUG,8787) TERM1*DEGRAD,TERM2*DEGRAD
 8787     FORMAT(' TAVISPAK99 DEBUG. B N/E 0. TERM1,TERM2(DEG)=',2G16.8)
        ELSE
          TEMP = C/A
          IF(DABS(TEMP).GT.1.D0) TEMP = DSIGN(1.D0,TEMP)
          SOLN1 = DACOS(C/A)
          SOLN2 = -SOLN1
          END IF
C      SET SOLN(1) TO THE ZERO FOR WHICH THE FUNCTION IS INCREASING AND
C      SOLN(2) TO THE ZERO FOR WHICH IT IS DECREASING.
        SLOPE1 = -A*DSIN(SOLN1) + B*DCOS(SOLN1)
        IF(IBUG.NE.0) THEN
          SLOPE2 = -A*DSIN(SOLN2) + B*DCOS(SOLN2)
          WRITE(LUBUG,8617) SOLN1*DEGRAD,SLOPE1,SOLN2*DEGRAD,SLOPE2
 8617     FORMAT(' TAVISPAK99. SOLN1,SLOPE1=',2G16.8/,
     *           '             SOLN2,SLOPE2=',2G16.8)
          END IF
        IF(SLOPE1.GT.0.D0) THEN
          SOLN(1) = SOLN1
          SOLN(2) = SOLN2
        ELSE
          SOLN(1) = SOLN2
          SOLN(2) = SOLN1
          END IF
        END IF
C
      IF(IBUG.NE.0) WRITE(LUBUG,8606) KVISFLAG,
     *      SOLN(1)*DEGRAD,SOLN(2)*DEGRAD
 8606 FORMAT(' TAVISPAK99 RETURNING.  KVISFLAG=',I3,
     *             '  SOLN=',2G25.16/)
C
 9999 CONTINUE
      RETURN
      END