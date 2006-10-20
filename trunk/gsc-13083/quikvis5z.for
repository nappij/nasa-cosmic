      SUBROUTINE QUIKVIS5Z(RAAN,SUNPOS,RATARG,DELTIM)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE IS PART OF THE QUIKVIS PROGRAM. IT COMPUTES THE TIME
C SINCE PERIGEE THAT THE S/C TAKES TO REACH THE POINT IN ITS ORBIT WHEN
C AN EVENT OCCURS AS SPECIFIED BY THE 'KRELTIME' PARAMETER RETRIEVED
C FROM QUIKVIS999.
C
C VARIABLE DIM TYPE I/O DESCRIPTION
C -------- --- ---- --- -----------
C
C RAAN      1   R*8  I  ORBIT'S RIGHT ASCENSION OF ASCENDING NODE.
C                       IN RADIANS. OTHER ORBITAL ELEMENTS ARS SET VIA
C                       THE RETRIEVAL CALL TO QUIKVIS999.
C
C SUNPOS    3   R*8  I  SUN POSITION AT THE TIME TO WHICH ELEMS IS
C                       REFERENCED.  IN KM.
C
C                       USED FOR KRELTIME=  1, 2. NOT USED OTHERWISE.
C
C RATARG    1   R*8  I  TARGET MERIDIAN. USED FOR KRELTIME= 6. NOT USED
C                       OTHERWISE.
C
C DELTIM    1   R*8  O  POSITIVE DIFFERENCE BETWEEN THE TIME TO WHICH
C                       ELEMS IS REFERENCED AND THE TIME THAT THE EVENT
C                       SPECIFIED BY 'KRELTIME' OCCURS.
C
C***********************************************************************
C
C BY C PETRUZZO/GFSC/742.   2/86.
C       MODIFIED....
C
C***********************************************************************
C
      INCLUDE 'QUIKVIS.INC'
C
      REAL*8 PLANE2(2),SUNPOS(3),ELEMS(6)
C
      IERR = 0
      IF(ERTHMU.EQ.0.D0) ERTHMU = CONST(56)
C
C
C ****************
C *  INITIALIZE  *
C ****************
C
      ELEMS(1) = SMA
      ELEMS(2) = ECC
      ELEMS(3) = ORBINCL
      ELEMS(4) = RAAN    ! FROM ARGUMENT LIST
      ELEMS(5) = ARGP
      ELEMS(6) = 0.D0
C
C    REMINDER: KRELTIME SPECIFIES THE EVENT INVOLVED.
C      =1, S/C ENTERS ORBIT NIGHT
C      =2, S/C ENTERS ORBIT DAY
C      =3, S/C CROSSES THE SUN MERIDIAN
C      =4, S/C CROSSES THE ASCENDING NODE
C      =5, S/C CROSSES THE DESCENDING NODE
C      =6, S/C CROSSES THE TARGET MERIDIAN
C      =7, S/C CROSSES INERTIAL ZERO RIGHT ASCENSION
C
C
C **********************************
C * PASS THROUGH SUNRISE OR SUNSET *
C **********************************
C
      IF(KRELTIME.EQ.1 .OR.   ! SUNSET
     *   KRELTIME.EQ.2)       ! SUNRISE
     *           THEN
        KUMB = 1   ! SHADTA COMPUTES UMBRA ENTRY AND EXIT TRUE ANOMALIES
        CALL SHADTA(ELEMS,SUNPOS,KUMB,-1,UMBIN,UMBOUT,DUM,DUM,
     *          LUERR,IERR)
        IF(IERR.NE.0) THEN
C        FORCE A LOOK AT WHY ERROR OCCURRED. SHOULD NEVER HAPPEN.
          STOP 'QUIKVIS5X. ERROR STOP 2. SEE CODE.'
          END IF
        IF(KUMB.EQ.2) THEN   ! ORBIT NIGHT PASSAGE OCCURS.
          IF(KRELTIME.EQ.1) THEN
            XTA = EQVANG(UMBIN)
          ELSE
            XTA = EQVANG(UMBOUT)
            END IF
        ELSE                 ! NO ORBIT NIGHT PASSAGE. REFER TO ASC NODE
          XTA = -ARGP
          END IF
        IF(ECC.GT.ECCMIN) THEN
          XMA = ANOMLY(-1,XTA,ECC,LUERR,IERR)
        ELSE
          XMA = XTA
          END IF
        DELTIM = XMA/TWOPI * PERIOD
        GO TO 9999
        END IF
C
C
C **********************************************************************
C * CROSS SUN OR TARGET MERIDIAN, OR PASS ASCENDING OR DESCENDING NODE *
C **********************************************************************
C
      IF( KRELTIME.EQ.3 .OR.   ! SUN MERIDIAN
     *    KRELTIME.EQ.4 .OR.   ! ASCENDING NODE
     *    KRELTIME.EQ.5 .OR.   ! DESCENDING NODE
     *    KRELTIME.EQ.6 .OR.   ! TARGET MERIDIAN
     *    KRELTIME.EQ.7)       ! ZERO RIGHT ASCENSION
     *            THEN
C
C      CALL XPLANE TO SEE WHEN THE S/C CROSSES THE MERIDIAN OR
C      EQUATORIAL PLANE.
C
        IF( KRELTIME.EQ.3 .OR. KRELTIME.EQ.6 .OR. KRELTIME.EQ.7 ) THEN
          PLANE2(1) = HALFPI
          IF(KRELTIME.EQ.3) THEN
            CALL XYZSPH(-1,RASUN,DECSUN,DUM,SUNPOS,1.D0)
            PLANE2(2) = RASUN
          ELSE IF(KRELTIME.EQ.6) THEN
            PLANE2(2) = RATARG
          ELSE
            PLANE2(2) = 0.D0
            END IF
          ICROSS = 2
          IF(ELEMS(2).GT.HALFPI) ICROSS = 3
          END IF
C
        IF( KRELTIME.EQ.4 .OR. KRELTIME.EQ.5 ) THEN
          PLANE2(1) = 0.D0
          PLANE2(2) = 0.D0
          IF(KRELTIME.EQ.4) THEN
            ICROSS = 3
          ELSE
            ICROSS = 2
            END IF
          END IF
C
        CALL XPLANE(ERTHMU,ELEMS,0,PLANE2,ICROSS,KCROSS,DT,
     *          LUERR,IERR)
C      ERROR SHOULD NEVER OCCUR.  STOP TO FORCE A LOOK AT WHY.
        IF(IERR.NE.0) STOP 'QUIKVIS5Z. ERROR. STOP 1. SEE CODE.'
C
        IF(IBUG.NE.0) WRITE(LUBUG,1002)
     *     PLANE2(1)*DEGRAD,PLANE2(2)*DEGRAD,ICROSS,
     *     DT/60.D0,KCROSS
 1002   FORMAT(' QUIKVIS5Z DEBUG 1002. PLANE2=',2F8.2,'  ICROSS=',I2/,
     *         '   DT(MIN)=',G13.5,'  KCROSS=',I2)
C
        DELTIM = DT
        GO TO 9999
        END IF
C
C
 9999 CONTINUE
      RETURN
C
C***********************************************************************
C
C
C**** INITIALIZATION CALL. PUT GLOBAL PARAMETER VALUES INTO THIS
C     ROUTINE'S LOCAL VARIABLES.
C
      ENTRY QVINIT5Z
C
      CALL QUIKVIS999(-1,R8DATA,I4DATA,L4DATA)
      RETURN
C
C***********************************************************************
C
      END