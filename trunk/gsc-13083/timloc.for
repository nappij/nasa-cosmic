      REAL*8 FUNCTION TIMLOC(TSEC50,SCPOS,KCOORD,KREFSUN)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  THIS ROUTINE COMPUTES THE LOCAL TIME AT THE MERIDIAN ABOVE WHICH
C  THE S/C IS LOCATED. THE LOCAL TIME IS REFERENCED TO THE FICTITIOUS 
C  MEAN SUN OR TO THE TRUE SUN, DEPENDING UPON THE VALUE OF KREFSUN.
C
C  VARIABLE  DIM TYPE I/O  DESCRIPTION
C  --------  --- ---- ---  -----------
C
C  TSEC50     1  R*8   I   TIME ASSOCIATED WITH THE S/C POSITION. IN
C                          SECONDS SINCE 1/1/50, 00:00:00 UT.
C
C  SCPOS      3  R*8   I   THE SPACECRAFT GEOCENTRIC POSITION VECTOR. 
C                          MAY BE IN ANY LENGTH UNITS.
C
C  KCOORD     1  I*4   I   FLAG IDENTIFYING THE COORDINATE SYSTEM IN
C                          WHICH SCPOS IS GIVEN.
C
C                          = 1, MEAN OF 1950.0
C                          = 2, MEAN OF DATE, DATE=TSEC50
C                          = 3, TRUE OF DATE, DATE=TSEC50
C                          = OTHERWISE, USED AS THOUGH =3 WERE ENTERED.
C
C  KREFSUN    1  I*4   I   FLAG INDICATING WHETHER THE MEAN SUN OR TRUE
C                          SUN IS TO BE USED.
C
C                          = 0, USE FICTITIOUS MEAN SUN. THE LOCAL TIME
C                               IS COMPUTED USING THE TIME AT GREENWICH
C                               PLUS A TIME DIFFERENCE BASED ON THE
C                               S/C LONGITUDE RELATIVE TO GREENWICH,
C                               EACH 15.0 DEGREES OF LONGITUDE BEING
C                               EQUIVALENT TO ONE HOUR IN TIME.
C
C                          = OTHERWISE, USE TRUE SUN. THE LOCAL TIME IS
C                               COMPUTED USING 12:00 NOON AS THE TIME
C                               AT THE SUN MERIDIAN AND ADDING A TIME
C                               DIFFERENCE BASED ON THE S/C AND SUN
C                               RIGHT ASCENSION DIFFERENCE, EACH 15.0
C                               DEGREES OF LONGITUDE BEING EQUIVALENT
C                               TO ONE HOUR IN TIME.
C
C  TIMLOC     1  R*8   O   LOCAL TIME IN SECONDS. THE RANGE IS
C                          0.D0 TO 86400.D0
C
C                          EXAMPLE, 18:00:00 IN LOCAL TIME IS
C                                     TIMLOC=64800.0 SECONDS.
C
C***********************************************************************
C
C  BY C PETRUZZO, GSFC/470.3, 5/83.
C            MODIFIED... CJP 6/85. MAJOR REWRITE TO DELETE CLUMSY CODE,
C                                  USE SUBSEQUENTLY CODED ROUTINES, AND
C                                  MAKE IT MORE READABLE.
C
C***********************************************************************
C
C
      REAL*8 SCPOS(3),SUNPOS(3),SCTOD(3)
      REAL*8 SECDAY/86400.D0/,SECHAFDAY/43200.D0/
      REAL*8 TSUNLAST/-1.D10/,TGHALAST/-1.D10/
      REAL*8 TWOPI  / 6.283185307179586D0 /
      REAL*8 DEGRAD / 57.29577951308232D0 /
C
      IBUG = 0
      LUBUG = 19
C
      IF(IBUG.NE.0) WRITE(LUBUG,1001)
     *     PAKTIM50(TSEC50),SCPOS,KCOORD,KREFSUN
 1001 FORMAT(/,' TIMLOC DEBUG. ENTRY INFO:  TIME=',G23.16/,
     *         ' SCPOS=',3G15.8,'  KCOORD,KREFSUN=',2I3)
C
C INITIALIZE
C
      IF(KCOORD.GE.1 .AND.KCOORD.LE.3) THEN
        ICOORD = KCOORD
      ELSE
        ICOORD = 3
        END IF
C
C    CONVERT INPUT POSITION COORDINATES TO TRUE OF DATE.
      IF(ICOORD.EQ.1) THEN        ! M50 TO TOD
        CALL VECM50TOD(TSEC50,1,SCPOS,SCTOD)
      ELSE IF(ICOORD.EQ.2) THEN   ! MDT TO TOD
        CALL VECMDTTOD(TSEC50,1,SCPOS,SCTOD)
      ELSE                        ! ALREADY TOD
        SCTOD(1) = SCPOS(1)
        SCTOD(2) = SCPOS(2)
        SCTOD(3) = SCPOS(3)
        END IF
C
C    GET S/C RIGHT ASCENSION
      CALL XYZSPH(-1,SCRA,DUM,DUM,SCTOD,1.D0)
      IF(IBUG.NE.0) WRITE(LUBUG,1002) SCRA*DEGRAD,SCTOD
 1002 FORMAT(' TIMLOC DEBUG. SCRA(TOD)=',F8.3/,'   SCTOD=',3G16.8)
C
C
C COMPUTE THE LOCAL TIME
C
      IF(KREFSUN.EQ.0) THEN
C
C      FOR MEAN SOLAR TIME.
C       METHOD: GET THE RIGHT ASCENSION OF THE GREENWICH MERIDIAN,
C       CONVERT THE DIFFERENCE IN RIGHT ASCENSIONS TO A TIME DIFFERENCE,
C       ADD THE TIME DIFFERENCE TO THE TIME AT GREENWICH TO GET THE
C       LOCAL TIME AT THE S/C.
C
        IF(TSEC50.NE.TGHALAST) GHA = GHANGL(TSEC50,1)
        TGHALAST = TSEC50
        TDIFF = EQVANG(SCRA-GHA)/TWOPI * SECDAY
        TIMLOC = DMOD( TSEC50 + TDIFF, SECDAY )
        IF(IBUG.NE.0) WRITE(LUBUG,1003) GHA*DEGRAD,TDIFF,TIMLOC
 1003   FORMAT(' TIMLOC DEBUG. GHA=',F8.3,'  TDIFF,TIMLOC=',2G16.8)
C
      ELSE
C      FOR TRUE SOLAR TIME
C       METHOD: GET THE SUN'S RIGHT ASCENSION, CONVERT THE DIFFERENCE
C       IN RIGHT ASCENSIONS TO A TIME DIFFERENCE, ADD THE TIME
C       DIFFERENCE TO THE TIME AT SUN MERIDIAN(=12:00 NOON) TO GET
C       THE LOCAL TIME AT THE S/C.
C
        IF(TSEC50.NE.TSUNLAST) CALL SOLTOD(TSEC50,SUNPOS,0)
        TSUNLAST = TSEC50
        CALL XYZSPH(-1,SUNRA,DUM,DUM,SUNPOS,1.D0)
        TDIFF = EQVANG(SCRA-SUNRA)/TWOPI * SECDAY
        TIMLOC = DMOD( SECHAFDAY + TDIFF, SECDAY )
        IF(IBUG.NE.0) WRITE(LUBUG,1004) SUNRA*DEGRAD,TDIFF,TIMLOC
 1004   FORMAT(' TIMLOC DEBUG. SUNRA=',F8.3,'  TDIFF,TIMLOC=',2G16.8)
C
        END IF
C
      RETURN
      END