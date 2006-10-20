      SUBROUTINE XPLANE(GRAVMU,STATE1,IFLAG,PLANE2,ICROSS,KCROSS,DELTIM,
     1            IERPNT,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  GIVEN A S/C POSITION AND VELOCITY OR ITS KEPLERIAN ELEMENTS,
C  DETERMINE THE TIME UNTIL THE SPECIFIED CROSSING OF A SPECIFIED PLANE.
C  THE CROSSING MAY BE FROM ABOVE OR BELOW, WHICHEVER IS WANTED.
C  CALCULATIONS ARE TWO-BODY ONLY. MORE ACCURACY CAN BE OBTAINED BY
C  USING THIS ROUTINE IN AN ITERATIVE SCHEME.
C
C  CAN BE USED FOR DETERMINING WHEN:
C          S/C CROSSES THE ECLIPTIC
C          S/C IS OVER THE TERMINATOR
C          S/C WILL HAVE GIVEN RIGHT ASCENSION OR LOCAL TIME
C          S/C WILL CROSS ORBIT PLANE OF ANOTHER S/C
C          ETC,.......
C
C
C  VAR    DIM    TYPE   I/O  DESCRIPTION
C  ---    ---    ----   ---  -----------
C
C  GRAVMU  1     R*8     I   GRAVITATIONAL COEFFICIENT OF THE CENTRAL
C                            BODY. LENGTH UNIT IS AS FOR STATE1, TIME
C                            UNIT IS AS FOR DELTIM. USUALLY, UNITS ARE
C                            KILOMETERS AND SECONDS, BUT MAY BE
C                            OTHERWISE.
C
C  STATE1  6     R*8     I   S/C STATE, EITHER POSITION AND VELOCITY
C                            OR KEPLERIAN ELEMENTS. SEE IFLAG FOR MORE
C                            INFO. LENGTH AND TIME UNITS ARE AS FOR
C                            GRAVMU. ANGLE UNIT IS RADIANS.
C                            ORDER IS: X, Y, Z, XD, YD, ZD OR
C                            ELSE: SMA, ECC, INCL, NODE, ARGP, ANOM.
C
C  IFLAG   1     I*4     I   FLAG IDENTIFYING STATE1 AS :
C
C                            = NEGATIVE. STATE1 IS POSITION AND VELOCITY
C
C                            = 0 STATE1 IS KEPLERIAN ELEMENTS WITH
C                                STATE1(6) BEING MEAN ANOMALY.
C
C                            = POSITIVE. STATE1 IS KEPLERIAN ELEMENTS
C                              WITH STATE1(6) BEING TRUE ANOMALY.
C
C  PLANE2  2     R*8     I   PLANE FOR WHICH CROSSING TIME IS WANTED.
C                            SINCE A SENSE OF ABOVE/BELOW IS NEEDED,
C                            'ABOVE' IS DEFINED AS THE SIDE OF THE
C                            PLANE TOWARD WHICH THE ANGULAR MOMENTUM
C                            VECTOR WOULD POINT FOR AN ORBIT HAVING
C                            INCLINATION=PLANE2(1) AND NODE=PLANE2(2).
C                            HENCE:
C                            PLANE2(1) IS INCLINATION OF THE PLANE TO BE
C                            CROSSED, PLANE(2) IS THE NODE.
C                            UNITS ARE RADIANS.
C
C  ICROSS  1     R*8     I   FLAG TELLING THIS ROUTINE WHICH CROSSING
C                            IS WANTED. ASSIGNMENTS ARE:
C                             SUMMARY--
C                              = 0 NEAREST, EITHER NODE.
C                              =-1 PREVIOUS, EITHER NODE.
C                              =+1 NEXT, EITHER NODE.
C                              =-2 PREVIOUS, DESCENDING NODE.
C                              =+2 NEXT, DESCENDING NODE.
C                              =-3 PREVIOUS, ASCENDING NODE.
C                              =+3 NEXT, ASCENDING NODE.
C
C
C                            = 0 FIND TIME OF THE NEAREST(IN TIME)
C                                CROSSING. MAY BE ASCENDING OR DESCEND-
C                                ING, AND BEFORE OR AFTER THE TIME
C                                OF STATE1. IF STATE1 IS EXACTLY HALF
C                                WAY BETWEEN TWO CROSSINGS, THE TIME
C                                OF THE NEXT CROSSING IS PRODUCED.
C                                IF STATE1 IS AT A CROSSING, DELTIM=0.D0
C
C                            =-1 FIND THE TIME OF THE PREVIOUS CROSSING
C                                REGARDLESS OF WHETHER IT IS
C                                ASCENDING OR DESCENDING. IF STATE1 IS
C                                AT A CROSSING, DELTIM = -PERIOD/2.
C
C                            =+1 FIND THE TIME OF THE NEXT CROSSING
C                                REGARDLESS OF WHETHER IT IS
C                                ASCENDING OR DESCENDING. IF STATE1 IS
C                                AT A CROSSING, DELTIM = +PERIOD/2.
C
C                            =-2 FIND THE TIME OF THE PREVIOUS CROSSING
C                                OF THE DESCENDING NODE. IF STATE1 IS AT
C                                THE DESCENDING NODE, DELTIM = -PERIOD.
C
C                            =+2 FIND THE TIME OF THE NEXT CROSSING
C                                OF THE DESCENDING NODE. IF STATE1 IS AT
C                                THE DESCENDING NODE, DELTIM = +PERIOD.
C
C                            =-3 FIND THE TIME OF THE PREVIOUS CROSSING
C                                OF THE ASCENDING NODE. IS STATE1 IS AT
C                                THE ASCENDING NODE, DELTIM=-PERIOD.
C
C                            =+3 FIND THE TIME OF THE NEXT CROSSING
C                                OF THE ASCENDING NODE. IF STATE1 IS AT
C                                THE ASCENDING NODE, DELTIM = +PERIOD.
C
C  KCROSS  1     I*4     O   IDENTIFIES THE CROSSING FOUND.
C
C                            = 0 NO CROSSING. RESULTS FROM ERROR
C                                CONDITION AND OCCURS ONLY WHEN IERR=1.
C
C                            =+/-2 TIME OF NEXT/PREVIOUS CROSSING OF
C                                  DESCENDING NODE RETURNED IN DELTIM.
C
C                            =+/-3 TIME OF NEXT/PREVIOUS CROSSING OF
C                                  ASCENDING NODE RETURNED IN DELTIM.
C
C                            NOTE: FOR ICROSS=0, DELTIM=0.D0 MAY BE
C                                  OUTPUT. IN THAT CASE, ONE KNOWS THAT
C                                  STATE1 WAS AT A RELATIVE NODE, AND
C                                  KCROSS=2 OR KCROSS=3 IDENTIFIES
C                                  THE NODE. DELTIM=0.D0 MEANS THAT
C                                  THE PRESENT POSITION IS THE CLOSEST.
C
C  DELTIM  1     R*8     O   THE TIME UNTIL THE DESIRED CROSSING OF
C                            PLANE2. TIME UNIT IS AS FOR GRAVMU.
C                            DELTIM MAY BE POSITIVE OR NEGATIVE,
C                            DEPENDING ON THE VALUE OF ICROSS.
C                            DELTIM=CROSSING TIME - CURRENT TIME. IF
C                            THE CROSSING HAS OCCURRED, DELTIM IS
C                            NEGATIVE. IF IT IS IN THE FUTURE, DELTIM
C                            IS POSITIVE. DELTIM=0.D0 IS POSSIBLE ONLY
C                            WHEN ICROSS=0(SEE NOTE AT THE END OF THE
C                            ICROSS DESCRIPTION).
C
C  IERPNT  1     I*4     I   FORTRAN UNIT NUMBER FOR ERROR MESSAGE.
C                            ONLY ELLIPTICAL/CIRCULAR ORBITS ARE
C                            HANDLED. ERROR OTHERWISE.
C                            IF THE TWO PLANES ARE COINCIDENT, THEN
C                            S/C MOVES IN THE PLANE TO BE CROSSED. NO
C                            CROSSINGS OCCUR AND AN ERROR CONDITION
C                            EXISTS.
C
C  IERR    1     I*4     O   ERROR RETURN.
C                            =0 MEANS NO ERROR. =1 MEANS ERROR FOUND.
C
C**********************************************************************
C
C CODED BY C PETRUZZO. GSFC/470. 9/81.
C              MODIFIED.......  CJP. 3/83. BUG FIX.
C                               CJP. 11/83. COMMENT FIX, NO CODE MOD.
C                               CJP. 5/85. BUG FIX.
C
C***********************************************************************
C
C
      REAL*8 POS(3),VEL(3),PLANE2(2),GRAVMU,STATE1(6)
      REAL*8 NORML1(3),NORML2(3),RELNOD(3),TEMP(3),ELMNTS(6)
      REAL*8 MEAN,MEAN1,MEAN2,MEANX
      REAL*8 TWOPI/ 6.283185307179586D0 /
      REAL*8 HALFPI/ 1.570796326794897D0 /
      REAL*8 PI/ 3.141592653589793D0 /
      REAL*8 DEGRAD/ 57.29577951308232D0 /
      INTEGER INIT/1/,IVCROS(7)/0,-1,+1,-2,+2,-3,+3/
      EQUIVALENCE (SMA,ELMNTS(1)),(ECC,ELMNTS(2))
      REAL*8 DTREQV(7)
      EQUIVALENCE (DTREQV(1),DTRU0),(DTREQV(2),DTRUM1),
     1   (DTREQV(3),DTRUP1),(DTREQV(4),DTRUM2),(DTREQV(5),DTRUP2),
     2   (DTREQV(6),DTRUM3),(DTREQV(7),DTRUP3)
C
C
C  THE SPACECRAFT IS MOVING IN PLANE 1. FIND THE TIME WHEN IT CROSSES
C  PLANE 2.
C
C
C  INITIALIZATION:
C
      IBUG=0
C
      IF(IBUG.NE.0)
     *  WRITE(6,1001)
     *      GRAVMU,STATE1,IFLAG,ICROSS,(PLANE2(I)*DEGRAD,I=1,2)
 1001 FORMAT(/,' XPLANE. GRAVMU=',F10.2/,
     *         '         STATE1=',3G17.10/,
     *         '                ',3G17.10/,
     *         '         IFLAG=',I3,' ICROSS=',I3,' PLANE2(DEG)=',2F8.2)
C
C     ANGLE SEPARATION COS ABOVE WHICH PLANES WILL BE CALLED COPLANAR.
      IF(INIT.EQ.1) COPLNR=DCOS(0.0001D0/DEGRAD)
C
C     DEFINE ANGLE SEPARATION BELOW WHICH POSITION VECTORS ARE CALLED
C     COLLINEAR. USED TO CHECK STATE1 FOR PRESENCE AT PLANE INTER-
C     SECTION. EQUALS 1 METER IN 6678 KM.
      IF(INIT.EQ.1) EPSTRU=DASIN(0.001D0/6678.D0)
C
      INIT=0
C
C  FIRST LOAD POS, VEL, ELMNTS(WITH MEAN ANOMALY), AND TRU(CURRENT T.A.)
C
      IF(IFLAG.GE.0) GO TO 100
C     IFLAG IS NEGATIVE. STATE1 IS POS/VEL.
      DO 50 I=1,3
      POS(I)=STATE1(I)
   50 VEL(I)=STATE1(I+3)
      CALL TOKEPL(GRAVMU,POS,VEL,ELMNTS,DUM,TRU)
      MEAN=ELMNTS(6)
      IERR=1
      IF(ECC.LT.0.D0  .OR. ECC.GE.1.D0) GO TO 999
      GO TO 200
C
  100 CONTINUE
C     STATE1 IS KEPLERIAN ELEMENTS.
      DO 150 I=1,6
  150 ELMNTS(I)=STATE1(I)
      TRU=ELMNTS(6)
      MEAN=ELMNTS(6)
      IERR=1
      IF(IFLAG.EQ.0) TRU=ANOMLY(1,MEAN,ECC,IERPNT,IER)
      IF(IFLAG.GT.0) MEAN=ANOMLY(-1,TRU,ECC,IERPNT,IER)
      IF(IER.NE.0) GO TO 999
      CALL TOCART(GRAVMU,ELMNTS,IFLAG,POS,VEL,IERPNT,IER)
      IF(IER.NE.0) GO TO 999
C
  200 CONTINUE
      IF(IBUG.NE.0)
     *   WRITE(6,1002) POS,VEL,ELMNTS(1),ELMNTS(2),
     *     (ELMNTS(I)*DEGRAD,I=3,6),TRU*DEGRAD,MEAN*DEGRAD
 1002 FORMAT(' XPLANE. '/,
     *     '   POS=',3F10.1,'  VEL=',3F10.5/,
     *     '   ELEMS=',F10.1,F10.6,F10.2/,9X,3F10.2/,
     *     '   TRU=',F10.2,'  MEAN=',F10.2)
C
C  GET INDEX ASSOCIATING DTREQV ARRAY WITH ICROSS.
      DO 155 I=1,7
      IF(ICROSS.NE.IVCROS(I)) GO TO 155
      INDICR=I
      GO TO 156
  155 CONTINUE
C     ERROR CONDITION. INVALID ICROSS.
      IERR=3
      GO TO 999
  156 CONTINUE
C
C  NOW FIND THE NORMALS TO EACH PLANE.
      CALL UCROSS(POS,VEL,NORML1)
      TEMP(1)=DSIN(PLANE2(1))
      NORML2(1)= TEMP(1) * DSIN(PLANE2(2))
      NORML2(2)=-TEMP(1) * DCOS(PLANE2(2))
      NORML2(3)= DCOS(PLANE2(1))
C     TEST NORMALS FOR COLLINEAR SITUATION. MEANS PLANES ARE COINCIDENT.
      IERR=2
      IF(DABS(DOT(NORML1,NORML2)).GE.COPLNR) GO TO 999
C
C  FIND THE UNIT VECTOR, RELNOD, POINTING TO THE ASCENDING RELATIVE
C  NODE. RELNOD LIES ALONG THE INTERSECTION OF THE TWO PLANES.
      CALL UCROSS(NORML2,NORML1,RELNOD)
      IF(IBUG.NE.0) THEN
        CALL XYZSPH(-1,RA2,DEC2,DUM,NORML2,1.D0)
        CALL XYZSPH(-1,RA1,DEC1,DUM,NORML1,1.D0)
        CALL XYZSPH(-1,RAREL,DECREL,DUM,RELNOD,1.D0)
        WRITE(6,1003) RA1*DEGRAD,DEC1*DEGRAD,
     *                RA2*DEGRAD,DEC2*DEGRAD,
     *                RAREL*DEGRAD,DECREL*DEGRAD
 1003   FORMAT(/,' XPLANE. PLANE1 NORMAL RA,DEC=',2F10.3/,
     *           '         PLANE2 NORMAL RA,DEC=',2F10.3/,
     *           '         RELATIVE NODE RA,DEC=',2F10.3)
        END IF
C
C  FIND THE TRUE ANOMALY, DELTRU, TRAVELLED SINCE THE MOST RECENT
C  ASCENDING RELATIVE NODE CROSSING. DELTRU=0 MEANS AT ASC REL NODE.
      DUM=VNORM(POS,TEMP)
      TEMP1 = DOT(RELNOD,TEMP)
      IF(DABS(TEMP1).GT.1.D0) TEMP1 = DSIGN(1.D0,TEMP1)
      DELTRU = DACOS(TEMP1)
      IF(IBUG.NE.0) WRITE(6,1004) DELTRU*DEGRAD
 1004 FORMAT(' XPLANE. DELTRU(=RELNOD/CURENT ANGLE)=',F8.2)
C     DELTRU IS ANGULAR DIFFERENCE BETWEEN POSITION VECTOR AND VECTOR
C     TO ASCENDING REL NODE. DETERMINE WHICH OF THE TWO POSITIONS
C     SATISFYING THIS DELTRU ANGLE IS CORRECT AND MODIFY DELTRU SO THAT
C     IT IS THE TRUE ANOMALY TRAVELLED SINCE ASCENDING RELATIVE NODE.
      CALL CROSS(POS,RELNOD,TEMP)
      IF(DOT(TEMP,NORML1).GT.0.D0) DELTRU=TWOPI-DELTRU
      DELTRU=DMOD(DELTRU+TWOPI,TWOPI)
      IF(IBUG.NE.0) WRITE(6,1005) DELTRU*DEGRAD
 1005 FORMAT(' XPLANE. DELTRU(=TRAVELED SINCE ASC NODE) =',F8.2)
C
C  GET THE TRUE ANOMALY OF THE ASCENDING RELATIVE NODE.
      ASCTRU=DMOD(TRU-DELTRU+TWOPI,TWOPI)
      IF(DABS(ASCTRU-TWOPI).LT.EPSTRU) ASCTRU=0.D0
      IF(IBUG.NE.0) WRITE(6,1006) ASCTRU*DEGRAD
 1006 FORMAT(' XPLANE. ASCTRU(=S/C TRUE ANOM AT REL NODE) =',F8.2)
C
C  NOW FIND THE ANGLES FROM THE CURRENT S/C POSITION TO THE DIFFERENT
C  CROSSINGS POSSIBLE. NOTE THAT DTRUxx'S ARE EQUIVALENCED TO DTREQV.
      DTRUP2= DMOD(PI-DELTRU+TWOPI,TWOPI)
      DTRUM2=-DMOD(PI+DELTRU,TWOPI)
      DTRUP3= TWOPI-DELTRU
      DTRUM3=-DELTRU
C     CHECK FOR S/C AT A CROSSING. IF SO, BE SURE DTRUxx'S ARE OK .
      DTRU0=1.D0   ! ZERO/NON-ZERO CHECK DONE. NOT IN COMPUTATIONS.
      IF(DABS(DELTRU).GT.EPSTRU .AND. DABS(DELTRU-TWOPI).GT.EPSTRU)
     1       GO TO 165
      DTRU0=0.D0
      DTRUP2=PI
      DTRUM2=-PI
      DTRUP3=TWOPI
      DTRUM3=-TWOPI
      GO TO 154
  165 IF(DABS(DELTRU-PI).GT.EPSTRU) GO TO 154
      DTRU0=0.D0
      DTRUP2=TWOPI
      DTRUM2=-TWOPI
      DTRUP3=PI
      DTRUM3=-PI
  154 CONTINUE
      IF(IABS(ICROSS).GT.1) GO TO 175
      DTRUP1=DMIN1(DTRUP2,DTRUP3)
      DTRUM1=DMAX1(DTRUM2,DTRUM3)
  175 CONTINUE
      IF(IBUG.NE.0) WRITE(6,1007) DTRU0*DEGRAD,
     *   DTRUP2*DEGRAD,DTRUM2*DEGRAD,DTRUP3*DEGRAD,DTRUM3*DEGRAD
 1007 FORMAT(' XPLANE. DTRU0=',F8.2/,
     *       '         DTRUP2/DTRUM2=',2F8.2,'  DTRUP3,DTRUM3=',2F8.2)
C
C  NOW GET THE TIME, DT, IT TOOK TO TRAVEL TO THE DESIRED CROSSING.
C     USE OF TOSS ANOMLY ROUTINE IS NEEDED BECAUSE IT PRESERVES ANGLES
C     GREATER THAN TWOPI. FOR EXAMPLE, IF TRU+DELTRU AS GREATER THAN
C     TWOPI, SO WILL MEAN1 BE.
      PERIOD=TWOPI*DSQRT(SMA**3/GRAVMU)
      IF(IBUG.NE.0) WRITE(6,1008) PERIOD,PERIOD/60.D0
 1008 FORMAT(' XPLANE. PERIOD=',F8.1,'(SEC)  ',F8.2,'(MIN)')
C     FIRST, FIND MEANX, THE MEAN ANOMALY AT THE CROSSING.
      IF(ICROSS.NE.0) GO TO 255
C     LOOKING FOR THE NEAREST(IN TIME) CROSSING. NEED TO EXAMINE TWO
C     CROSSINGS.
      MEANX=MEAN
      XTRU=TRU
      IF(DTRU0.EQ.0.D0) GO TO 265
      MEAN1=ANOMLY(-1,TRU+DTRUP1,ECC,0,IDUM)
      MEAN2=ANOMLY(-1,TRU+DTRUM1,ECC,0,IDUM)
      IF(IBUG.NE.0) WRITE(6,1009) (MEAN1-MEAN)*DEGRAD,
     *                 (MEAN2-MEAN)*DEGRAD
 1009 FORMAT(' XPLANE(ICROSS=0). D-MEAN: NEXT=',F8.2,' PREV=',F8.2)
      MEANX=MEAN1
      XTRU=TRU+DTRUP1
      IF(DABS(MEAN1-MEAN).LT.DABS(MEAN2-MEAN)) GO TO 265
      MEANX=MEAN2
      XTRU=TRU+DTRUM1
      GO TO 265
  255 CONTINUE
C     NOT LOOKING FOR NEAREST.
      IF(IBUG.NE.0) WRITE(6,1010) INDICR,DTREQV(INDICR)*DEGRAD
 1010 FORMAT(' XPLANE. INDICR=',I2,' DTREQV(INDICR)=',F8.2)
      XTRU=TRU+DTREQV(INDICR)
      MEANX=ANOMLY(-1,XTRU,ECC,0,IDUM)
  265 CONTINUE
      DT=(MEANX-MEAN)/TWOPI * PERIOD
      IF(DT.LT.0.D0) DT=-DMOD(-DT,PERIOD)
      IF(DT.GT.0.D0) DT=DMOD(DT,PERIOD)
      IF(IBUG.NE.0) WRITE(6,1011) XTRU*DEGRAD,MEANX*DEGRAD,DT,DT/60.D0
 1011 FORMAT(' XPLANE. XTRU=',F8.2,' MEANX=',F8.2,'  DT=',F8.2,'(SEC) ',
     *              F8.2,'(MIN)')
C
C
C  SET KCROSS.
      KCROSS=3
      TEMPP=DMOD(DABS(XTRU-ASCTRU)+TWOPI,TWOPI)
      IF(DABS(TEMPP-PI).LT.HALFPI) KCROSS=2
      IF(DT.LT.0.D0) KCROSS=-KCROSS
      IF(IBUG.NE.0) WRITE(6,1012) (XTRU-ASCTRU)*DEGRAD,KCROSS
 1012 FORMAT(' XPLANE. XTRU-ASCTRU=',F8.2,'  KCROSS=',I2)
C
C
C  WE WANT TO RETURN DELTIM, THE TIME MEASURED FROM THE TIME OF STATE1
C  TO THE TIME OF THE DESIRED CROSSING. SET IT.
      DELTIM=DT
      IERR=0
      GO TO 900
C
C
  999 CONTINUE
C     ERROR SITUATION.
      IF(IERPNT.NE.0) WRITE(IERPNT,9010) IERR
 9010 FORMAT(/,' XPLANE. ERROR CONDITION. RETURN FLAG=',I2/,
     1  ' KEY: 1=INVALID ORBIT INPUT, 2=PLANES COINCIDENT,',
     2  ' 3=INVALID ICROSS INPUT.')
      IERR=1
      DELTIM=0.D0
      KCROSS=0
C
  900 CONTINUE
      IF(IBUG.NE.0) WRITE(6,1013) DELTIM,DELTIM/60.D0,KCROSS
 1013 FORMAT(' XPLANE RETURNING. DELTIM=',F8.2,'(SEC) ',F8.2,'(MIN)',
     *                '  KCROSS=',I3/)
      RETURN
      END