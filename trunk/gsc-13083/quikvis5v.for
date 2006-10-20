      SUBROUTINE QUIKVIS5V(ANGSIN,REFANG,ANGSOUT)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE IS PART OF THE QUIKVIS PROGRAM.  IT IS USED BY QUIKVIS5'S
C LOWER LEVEL ROUTINES TO MAKE THE ANGSIN PAIRS OF MEAN ANOMALIES
C RELATIVE TO MEAN ANOMALY = REFANG.  FOR EXAMPLE(IN DEGREES), IF
C ANGSIN(1,1) = 100 DEG, ANGSIN(2,1) = 200 DEG, AND REFANG = 140 DEG,
C THEN THIS ROUTINE RETURNS THE ANGLE PAIR -40,60 IN ANGSOUT.
C
C
C VARIABLE DIM TYPE I/O DESCRIPTION
C -------- --- ---- --- -----------
C
C ANGSIN        R*8  I  MEAN ANOMALY RANGES WHERE INDIVIDUAL REQMTS ARE
C      2,MAXREQMT       SATISFIED.  IN RADIANS.
C
C                       ANGSIN(1,I) IS THE MEAN ANOMALY WHERE THE I'TH
C                       REQUIREMENT BEGINS TO BE SATISFIED, ANGSIN(2,I)
C                       IS WHERE IT CEASES.
C
C                       WHAT THE SPECIFIC REQUIREMENTS ARE IS
C                       UNIMPORTANT TO THIS ROUTINE.
C
C REFANG    1   R*8  I  THE REFERENCE MEAN ANOMALY. IN PRACTICE, THIS
C                       IS THE MEAN ANOMALY WHERE THE REFERENCE ORBITAL
C                       EVENT OCCURS.  IN RADIANS.
C
C ANGSOUT       R*8  I  THE RELATIVE MEAN ANOMALIES.  IN RADIANS.
C      2,MAXREQMT
C
C***********************************************************************
C
C BY C PETRUZZO/GFSC/742.   9/86.
C       MODIFIED....
C
C***********************************************************************
C
      INCLUDE 'QUIKVIS.INC'
C
      LOGICAL ALWAYS,NEVER
      REAL*8 TOLER/1.D-8/
      REAL*8 ANGSIN(2,MAXREQMT),ANGSOUT(2,MAXREQMT)
C
      DO IREQ=1,MAXREQMT
C
        ANG1 = ANGSIN(1,IREQ) - REFANG
        ANG2 = ANGSIN(2,IREQ) - REFANG
C
        IF(ANG2.LT.ANG1) ANG1 = ANG1 - TWOPI
C
        ALWAYS = DABS( (ANG2-ANG1)-TWOPI ) .LT. TOLER
        NEVER =  DABS(     ANG2-ANG1     ) .LT. TOLER
C
        IF(ALWAYS) THEN
          ANG1 = 0.D0
          ANG2 = TWOPI
        ELSE IF(NEVER) THEN
          ANG1 = 0.D0
          ANG2 = 0.D0
        ELSE
          ANG1 = EQVANG(ANG1)
          ANG2 = EQVANG(ANG2)
          IF(ANG2.LT.ANG1) ANG1 = ANG1 - TWOPI
          END IF
C
        ANGSOUT(1,IREQ) = ANG1
        ANGSOUT(2,IREQ) = ANG2
C
        END DO
C
      RETURN
C
C***********************************************************************
C
C
C**** INITIALIZATION CALL. PUT GLOBAL PARAMETER VALUES INTO THIS
C     ROUTINE'S LOCAL VARIABLES.
C
      ENTRY QVINIT5V
C
      CALL QUIKVIS999(-1,R8DATA,I4DATA,L4DATA)
      RETURN
C
C***********************************************************************
C
      END