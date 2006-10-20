      DOUBLE PRECISION FUNCTION ANOMLY(IND,ANGLE,ECC,IERPNT,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  THIS ROUTINE COMPUTES MEAN ANOMALY GIVEN TRUE ANOMALY AND VIS-VERSA.
C
C  VAR    DIM TYPE  I/O  DESCRIPTION
C  ---    --- ----  ---  -----------
C
C  IND     1  I*4    I   INDICATOR ON ANGLE TYPE.
C                        =ZERO OR POSITIVE. MEAN ANOMALY INPUT, TRUE
C                         ANOMALY OUTPUT.
C                        =NEGATIVE. TRUE ANOMALY INPUT, MEAN OUTPUT.
C
C  ANGLE   1  R*8    I   ANGLE TO BE CONVERTED. MEAN OR TRUE ANOMALY,
C                        DEPENDING ON VALUE OF IND INPUT. RADIANS.
C
C  ECC     1  R*8    I   ECCENTRICITY. MUST BE LESS THAN 1.D0
C
C  IERPNT  1  I*4    I   FORTRAN UNIT FOR ERROR MESSAGE. USED WHEN AN
C                        INVALID ECC HAS BEEN INPUT OR WHEN ITERATION
C                        LOOP IN TRUE ANOMALY SOLUTION FAILS TO
C                        CONVERGE.
C                        =0 MEANS NO ERROR MESSAGE IS TO BE GIVEN.
C
C  IERR    1  I*4    O   ERROR RETURN FLAG.
C                        =0, NO ERROR.  =1, ERROR.
C
C***********************************************************************
C
C  TAKEN FROM 580'S MAESTRO PROGRAM. MODS BY C PETRUZZO 9/81.
C
C***********************************************************************
C
      REAL*8 PI/  3.141592653589793D0    /
      REAL*8 TWOPI/  6.283185307179586D0    /
      REAL*8 MEAN
C
C
C  EQUATIONS ARE FROM THE ORBITAL FLIGHT HANDBOOK(MARTIN CO., 1963.)
C  VOL I, PAGE III-21, EQN 2-7 AND
C  PAGE III-23, EQNS 2-57 AND 2-59.
C
      IERR=0
      IF(ECC.LT.0.D0.OR.ECC.GE.1.D0) IERR=1
      IF(IERR.EQ.0) GO TO 1515
      ANOMLY=0.D0
      IF(IERPNT.NE.0) WRITE(IERPNT,1500) IND,ANGLE,ECC,ANOMLY
 1500 FORMAT('0ANOMLY. BIG ERROR. ECCENTRICITY NOT FOR AN ELLIPSE.'/,
     1  '  IND,ANGLE,ECC=',I3,2G20.10,' ANOMLY OUT=',F8.2)
      GO TO 9000
C
 1515 CONTINUE
      TEMP=DABS(ANGLE)
      ANG1=DMOD(TEMP,TWOPI)
      DIF2PI=TEMP-ANG1
C
      IF(IND.LT.0) GO TO 1000
C
C
C  GET TRUE ANONALY FROM MEAN ANOMALY BY WAY OF ECCENTRIC ANOMALY.
      MEAN=ANG1
C  FIND ECANOM THE SATISFIES    MEAN=ECANOM-ECC*DSIN(ECANOM)
      ECANOM=MEAN
      DO 8 I=1,50
      ERROR=MEAN-ECANOM+ECC*DSIN(ECANOM)
      IF(DABS(ERROR).LE.1.D-12) GO TO 50
      TEMP=ECC*DCOS(ECANOM)
      HELPER=.01D0 * TEMP**3
      IF(TEMP.GT.0.99D0 .OR. I.GT.10) HELPER=0.D0
      DERIV=1.D0-TEMP+HELPER
      DEL=ERROR/DERIV
      IF(DEL.GT.2.D0) DEL=2.D0
      ECANOM=ECANOM+DEL
    8 CONTINUE
      IERR=1
      IF(IERPNT.NE.0) WRITE(IERPNT,1100) MEAN,ECANOM
 1100 FORMAT('0ANOMLY. ERROR. ECANOM LOOP NOT CONVERGED. MEAN,ECANOM=',
     1   2G20.10)
   50 CONTINUE
      Y=DSQRT(1.D0-ECC*ECC) * DSIN(ECANOM)
      X=DCOS(ECANOM) - ECC
      TRUANM=DMOD(DATAN2(Y,X)+TWOPI,TWOPI)
      ANG2=TRUANM
      GO TO 2000
C
C
 1000 CONTINUE
C  GET MEAN ANOMALY FROM TRUE ANOMALY BY WAY OF ECCENTRIC ANOMALY.
      TRUANM=ANG1
      COSTRU=DCOS(TRUANM)
      ECANOM=DARCOS( (ECC+COSTRU)/(1.D0+ECC*COSTRU) )
C  ECANOM IS BETWEEN 0.D0 AND PI. TRUE ANOMALY IS BETWEEN 0.D0 AND TWOPI
C  PUT ECANOM ON THE PROPER SIDE OF PI.
      IF(TRUANM.GT.PI) ECANOM=TWOPI-ECANOM
      MEAN = ECANOM - ECC*DSIN(ECANOM)
      ANG2=MEAN
C
C
 2000 CONTINUE
      ANG2=ANG2+DIF2PI
      IF(ANGLE.LT.0.D0) ANG2=-ANG2
      ANOMLY=ANG2
 9000 RETURN
      END
