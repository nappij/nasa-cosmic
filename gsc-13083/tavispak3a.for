      SUBROUTINE TAVISPAK3A(KREQMT,ELEMS,UTARG,ANGREQ,
     *       KVISFLAG,EABEGIN,EACEASE,ORBDATA,LUERR,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE IS PART OF TOSS'S TAVISPAK SET OF SUBROUTINES.  IT
C EXECUTES THE ALGORITHMS FOR THE HORIZON AND VELOCITY VECTOR AVOIDANCE
C REQUIREMENTS.
C
C***********************************************************************
C
C CODED BY C PETRUZZO, GSFC/742, 1/86.
C    MODIFIED....  CJP. 10/86. FORMAT STATEMENT CHANGES FOR DEBUG PRINT.
C                              ADDED IBUG AND LUBUG VARIABLES.
C
C***********************************************************************
C
C
      REAL*8 UTARG(3),ORBDATA(20),FCN(3),EA(3),SOLN(2),SOLNOLD(2),
     *         UNODE(3),ORBNORM(3),PROJ(3)
      REAL*8 ELEMS(5)
      LOGICAL CONVERGED,FINI
      REAL*8 PI     / 3.141592653589793D0 /
      REAL*8 TWOPI  / 6.283185307179586D0 /
      REAL*8 DEGRAD / 57.29577951308232D0 /
C
      IERR = 0
      IBUG = 0
      LUBUG = 19
C
C ZERO ECCENTRICITY HAS A SIMPLER, MORE EFFICIENT SOLUTION THAN THE
C NON-ZERO CASE.
C
C
C >>>>> PUT ZERO ECCENTRICITY CODE HERE <<<<<
C
C
C NON-ZERO ECCENTRICITY. INITIALIZE FOR THE ITERATION LOOP. (ALSO
C OK FOR ZERO ECCENTRICITY, BUT NOT AS EFFICIENT).
C
      MAXLOOPS =   10           ! MAX LOOPS BEFORE ERROR IS ASSUMED
      NLOOP =      0            ! COUNTS CURRENT LOOP
      DIFF =       1.D10
      EPS =        0.01/DEGRAD ! CONVERGENCE TEST
      CONVERGED = .FALSE.
      FINI = .FALSE.
C    SET INITIAL ECC ANOM VALUES TO ARBITRARILY SELECTED VALUES.
      EA(1) =   0.D0
      EA(2) = 120.D0/DEGRAD
      EA(3) = 240.D0/DEGRAD
C
C ITERATE.  WE USE THREE (EA(I),FCN(I)) PAIRS TO DEFINE A CURVE THAT
C APPROXIMATES THE RAM OR SHADOW FUNCTION.  WE SOLVE FOR THE ZEROS OF
C THAT CURVE TO GET APPROXIMATIONS FOR THE TWO ZEROS OF THE RAM OR
C SHADOW FUNCTIONS.  WE USE THOSE TWO SOLUTIONS AND THEIR MIDPOINT TO
C COMPUTE THREE NEW RAM OR SHADOW FUNCTION VALUES, THEN APPROXIMATE
C THE RAM OR SHADOW FUNCTION AGAIN.  SUCESSIVE APPROXIMATIONS FIT THE
C ACTUAL CURVE BETTER NEAR THE ZEROS, SO THE APPROXIMATE ZEROS CONVERGE
C TO THE ACTUAL ZEROS.
C
      DO WHILE (.NOT.FINI)
        NLOOP = NLOOP + 1
        IF(IBUG.NE.0) WRITE(LUBUG,8602) NLOOP
 8602   FORMAT(/,' TAVISPAK3A. START ITERATION LOOP ',I3)
        IF(NLOOP.EQ.MAXLOOPS) FINI = .TRUE.
C
C      TO MODEL THE SHADOW AND RAM FUNCTIONS, THE ALGORITHM USES
C              FCN = (A*DCOS(EA)) + (B*DSIN(EA)) - C
C      AS AN APPROXIMATION.  THE TRANSITION BETWEEN AVAILABLE AND NOT
C      AVAILABLE OCCURS WHEN THE FCN CHANGES SIGN. POSITIVE FCN MEANS
C      AVAILABLE, NEGATIVE NOT AVAILABLE. FOR KVISFLAG=0, EABEGIN IS THE
C      ZERO FOR THE NEGATIVE-TO-POSITIVE TRANSITION, EACEASE IS THE ZERO
C      FOR POSITIVE-TO-NEGATIVE.
C
C      FIRST, COMPUTE THREE SHADOW OR RAM FUNCTION VALUES.
        IF(KREQMT.EQ.1) THEN
          CALL TAVISPAK3A1(NLOOP,ANGREQ,UTARG,EA,FCN,ORBDATA,LUERR,IERR)
          IF(IERR.NE.0) THEN
            GO TO 9999
            END IF
        ELSE IF(KREQMT.EQ.2) THEN
          CALL TAVISPAK3A2(NLOOP,ANGREQ,UTARG,EA,FCN,ORBDATA,LUERR,IERR)
          IF(IERR.NE.0) THEN
            GO TO 9999
            END IF
          END IF
C
C      SECOND, FIT THE APPROXIMATION CURVE TO THE 3 (EA,FCN) PAIRS AND
C      SOLVE FOR THE ZEROS OF THE APPROXIMATION CURVE.
        CALL TAVISPAK3X(EA,FCN,A,B,C,LUERR,IERR)          ! FIT
        IF(IERR.NE.0) GO TO 9999
        CALL TAVISPAK99(A,B,C,SOLN,KVISFLAG,LUERR,IERR)   ! SOLVE
        IF(IERR.NE.0) GO TO 9999
C
        IF(IBUG.NE.0) WRITE(LUBUG,8603) KVISFLAG,(EA(I)*DEGRAD,I=1,3),
     *       FCN,SOLN(1)*DEGRAD,SOLN(2)*DEGRAD
 8603   FORMAT(' TAVISPAK3A DEBUG 8603.  KVISFLAG=',I3/,
     *         '         EA=',3G16.8/,
     *         '        FCN=',3G16.8/,
     *         '       SOLN=',2G16.8)
C
C      KVISFLAG = -1 MEANS TARGET IS NEVER AVAILABLE ACCORDING TO THE
C      APPROXIMATING FUNCTION; ; =0, HAS PERIODS OF AVAILABILITY AND
C      NO AVAILABILITY; =+1, IS ALWAYS AVAILABLE.
C
C        - IF NON-ZERO AND THIS IS THE FIRST ITERATION, THEN WE USE THE
C          SOLN RETURNED TO EXAMINE THE ACTUAL SHADOW OR RAM FUNCTION
C          FOR ECC ANOMALIES WHERE THE APPROXIMATING FUNCTION IS CLOSEST
C          TO ZERO.
C        - IF NON-ZERO AND THIS IS NOT THE FIRST ITERATION, WE ACCEPT
C          THE RESULT AND EXIT.
C
        IF(KVISFLAG.NE.0) THEN
          IF(NLOOP.EQ.1) THEN
            EAMINMAX = SOLN(1)
            SOLN(1) = EAMINMAX - 5.D0/DEGRAD
            SOLN(2) = EAMINMAX + 5.D0/DEGRAD
            KVISFLAG = 0   ! LETS THE ITERATION CONTINUE
          ELSE
            GO TO 9999
            END IF
          END IF
C
C      SET THE DIFFERENCE BETWEEN THIS SOLUTION AND THE PREVIOUS ONE
C      FOR DOING THE CONVERGENCE TEST.
        IF(NLOOP.GT.1) THEN
          DIFF1 = EQVANG(SOLN(1)-SOLNOLD(1))
          IF(DIFF1.GT.PI) DIFF1 = TWOPI - DIFF1
          DIFF2 = EQVANG(SOLN(2)-SOLNOLD(2))
          IF(DIFF2.GT.PI) DIFF2 = TWOPI - DIFF2
          DIFF = DMAX1(DIFF1,DIFF2)
          CONVERGED = DIFF.LT.EPS
          IF(IBUG.NE.0) WRITE(LUBUG,8604) CONVERGED,
     *         DIFF1*DEGRAD,DIFF2*DEGRAD,SOLN(1)*DEGRAD,SOLN(2)*DEGRAD
 8604     FORMAT(/,' TAVISPAK3A DEBUG 8604. ',
     *               'CONVERGED=',L2,'   DIFF1,DIFF2=',2G16.8/,
     *           '    SOLN(IN ECC ANOM)=',2G16.8)
          END IF
C
C      SET UP FOR THE NEXT ITERATION
        IF(.NOT.CONVERGED) THEN
          SOLNOLD(1) = SOLN(1)
          SOLNOLD(2) = SOLN(2)
          EA(1) = SOLN(1)
          EA(3) = SOLN(2)
          EA(2) = (EA(1)+EA(3))/2.D0
        ELSE
          FINI = .TRUE.
          END IF
C
        END DO    ! ENDS THE 'DO WHILE (.NOT.FINI)' LOOP
C
      IF(.NOT.CONVERGED) THEN
        IERR = 4
        GO TO 9999
        END IF
C
      EABEGIN = SOLN(1)
      EACEASE = SOLN(2)
C
 9999 CONTINUE
      RETURN
      END
