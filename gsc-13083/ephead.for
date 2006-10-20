      SUBROUTINE EPHEAD(LUEPHM,LUPRINT,KGETPARM,HEADPARM,LUERR,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  THIS ROUTINE RETURNS, OPTIONALLY, CERTAIN HEADER RECORD INFORMATION
C  FROM THE SPACECRAFT EPHEMERIS FILE HEADER. IT ALSO WRITES,
C  OPTIONALLY, CERTAIN HEADER INFORMATION ON A SPECIFIED OUTPUT UNIT.
C
C
C  <<<< WARNING >>>>  (IF THE EPHEM FILE IS NOT REWRITTEN DURING THE
C                      RUN, THIS WARNING CAN BE IGNORED)
C
C   THIS ROUTINE GETS HEADER INFO BY CALLING GETEPHD, AN ENTRY IN
C   GETEPH. IF THE EPHEM FILE HAS BEEN REWRITTEN SINCE THE MOST RECENT
C   CALL TO GETEPH, THEN GETEPH'S INTERNAL ARRAYS CONTAIN INCORRECT
C   INFORMATION AND THE HEADER INFORMATION GIVEN HERE WILL BE INCORRECT.
C   THE SOLUTION IS TO RESET THE FILE(SEE GETEPH ABOUT THIS) WHEN THE
C   FILE IS REGENERATED. 
C
C
C VARIABLE DIM TYPE I/O DESCRIPTION
C -------- --- ---- --- -----------
C
C LUEPHM    1   I*4  I  THE FORTRAN UNIT NUMBER OF THE SPACECRAFT
C                       EPHEMERIS FILE.
C
C LUPRINT   1   I*4  I  THE FORTRAN UNIT NUMBER TO WHICH HEADER
C                       INFORMATION IS TO BE WRITTEN.
C
C                       = 0 OR NEG MEANS NO PRINT WANTED.
C
C KGETPARM  1   I*4  I  A FLAG INDICATING WHETHER THE ARRAY HEADPARM IS
C                       TO BE LOADED.
C
C                       = 0 MEANS DO NOT LOAD IT.
C                       = OTHERWISE, LOAD IT.
C
C HEADPARM SEE  R*8  O   AN ARRAY CONTAINING INFO READ FROM THE
C         DESCR          EPHEMERIS FILE HEADER RECORDS. IF KGETPARM =0,
C                        NO ELEMENTS ARE LOADED AND THE DIMENSION IS 1.
C                        IF KGETPARM IS NOT ZERO, THE ELEMENTS ARE
C                        LOADED AND THE DIMENSION IS 12.
C
C                        MAY MORE HEADER ITEMS ARE AVAILABLE THROUGH
C                        GETEPHD(ENTRY IN GETEPH).  THEY ARE NOT
C                        RETURNED BY THIS ROUTINE BECAUSE OF THE NUMBER
C                        OF CALLING ROUTINES THAT WOULD HAVE HAD TO
C                        BE CHANGED.
C
C                        ASSIGNMENTS ARE:
C
C                         (1) TIME ASSOCIATED WITH INITIAL CONDITIONS.
C                             SECONDS SINCE 1/1/50, 0.0 HR UT
C
C                         (2-8) KEPLERIAN ELEMENTS FOR INITIAL
C                             CONDITIONS. ORDER IS A, E, I, N, W, MA,
C                             TA. IN KM AND RADIANS.
C
C                         (9) EARLIEST TIME THAT POS/VEL INFO IS GIVEN
C                             ON THE FILE. IN SECONDS SINCE 1950.
C
C                        (10) LATEST TIME THAT POS/VEL INFO IS GIVEN ON
C                             THE FILE. IN SECONDS SINCE 1950.
C
C                        (11) STEP SIZE BETWEEN CONSECUTIVE POS/VEL
C                             ENTRIES. IN SECONDS.
C
C                        (12) COORDINATE SYSTEM TO WHICH POS/VEL VECTORS
C                             ARE REFERENCED.
C                             1.0 = MEAN OF 1950.0
C                             2.0 = MEAN OF DATE
C                             3.0 = TRUE OF DATE
C
C LUERR     1   I*4  I  FORTRAN UNIT NUMBER FOR ERROR MESSAGES.
C
C                       =0 OR NEG MEANS NO MESSAGE POSSIBLE.
C
C IERR      1   I*4  O  ERROR INDICATOR.
C                       =0 MEANS NO ERROR.
C                       =1 MEANS ERROR.
C
C
C**********************************************************************
C
C  CODED BY C. PETRUZZO. 9/82.
C
C  MODIFIED..... 7/83. COMMENT MOD, NO CODE MOD.
C                3/85. COMMENT MOD AND REMOVED EPHEM FILE READ STATEMENT
C                      AND CHANGED CODE TO GET HEADER INFO VIA CALL
C                      TO GETEPHD(ENTRY IN GETEPH).
C                5/85. ADDITIONAL PARAMETERS WERE ADDED TO THE EPHEM
C                      FILE HEADER IN 5/85. MODS MADE HERE TO USE THEM.
C                3/86. ADDED 12'TH ELEMENT TO HEADPARM. MOD TO 
C                      FORMAT 1021.
C                3/87. COMMENT MODS, NO CODE MOD.
C
C**********************************************************************
C
      REAL*8 HEADPARM(1)
      REAL*8 DEGRAD/ 57.29577951308232D0 /
      CHARACTER*20 CHEPOCH,CHGENER
      LOGICAL OKHEAD
      CHARACTER*3 OFFON(2)/'OFF',' ON'/
      CHARACTER*40 COORDNAME
C
C
C
C NGRAV, NDRAG, NAUXIL ARE THE NUMBER OF PARAMETERS IN THE GRAVITY,
C DRAG, AND AUXILIARY DATA ARRAYS STORED IN THE EPHEM FILE HEADER
C WRITTEN BY SUBROUTINE EPHFILE.
C
      PARAMETER NGRAV=7       ! NUMBER OF GRAVITY PARAMETERS
      REAL*8 GRAVPARM(NGRAV)
C
C     GRAVPARM CONTENTS:
C      1) SUN POINT MASS USED. (0.0=NO; OTHERWISE, YES)
C      2) MOON POINT MASS USED. (0.0=NO; OTHERWISE, YES)
C      3) NUMBER OF ZONAL HARMONICS USED
C      4) NUMBER OF TESSERAL HARMONICS USED
C      5) EARTH MU, KM**3/SEC**2
C      6) MOON MU, KM**3/SEC**2
C      7) SUN MU, KM**3/SEC**2
C
C
      PARAMETER NDRAG=14      ! NUMBER OF DRAG PARAMETERS
      REAL*8 DRAGPARM(NDRAG)
C
C     DRAGPARM CONTENTS:    (IF DRAG IS OFF, ELEMENTS 2-14 NOT RELEVANT)
C      1) DRAG FORCES USED. (0.0=NO; OTHERWISE, YES)
C      2) S/C MASS, KG
C      3) DRAG COEFFICIENT
C      4) ATMOSPHERE MODEL NUMBER (1=HARPRI, 2=JAC-ROB, 3=ATM62)
C      5) RHO4 PARAMETER FOR HAR-PRI MODEL
C      6) NNCOS PARAMETER FOR HAR-PRI MODEL
C      7) DENSITY SOURCE FOR HAR-PRI. (1=INTERNAL, 2=TOSS FILE, 3=USER)
C      8) HAR-PRI SOLAR FLUX IDENTIFIER (1=65, 2=75, 3=100, ..., 10=275)
C      9) FORTRAN UNIT NUMBER USED BY EPHEMGEN PGM FOR THE DENSITY DATA 
C     10) ATT-DEP DRAG INDICATOR (0=NO, 1=ATT-DEP, 3=ATT-DEP/SVDS)
C     11) S/C AREA NORMAL TO X-AXIS, OR CONST AREA FOR NO ATT-DEP DRAG
C     12) S/C AREA NORMAL TO Y-AXIS
C     13) S/C AREA NORMAL TO Z-AXIS
C     14) FORTRAN UNIT NUMBER USED BY EPHEMGEN PGM FOR THE ATTITUDE DATA
C
      PARAMETER NAUXIL=20     ! NUMBER OF AUXILIARY PARAMETERS
      REAL*8 AUXPARM(NAUXIL)
C
C     AUXPARM CONTENTS:
C      1) YYMMDD.HHMMSS OBTAINED FROM COMPUTER CLOCK WHEN FILE WAS MADE
C      2) COORDINATE SYSTEM ID. 1=M50, 2=MDT, 3=TOD
C      3) SAME DESCRIPTION AS FOR NTITLE PARAMETER DESCRIBED BELOW.
C      4) SAME DESCRIPTION AS FOR NGRAV PARAMETER DESCRIBED ABOVE
C      5) SAME DESCRIPTION AS FOR NDRAG PARAMETER DESCRIBED ABOVE
C      6) SAME DESCRIPTION AS FOR NAUXIL PARAMETER DESCRIBED ABOVE
C      7-20) NOT USED
C
C NTITLE IS THE LENGTH OF USEFUL PART OF THE HEADER ARRAY WRITTEN BY
C EPHFILE. USED HERE JUST AS AN ADDITIONAL CHECK FOR CONSISTENCY AMONG
C ROUTINES INVOLVED WITH THE FILE HEADER.
C
      PARAMETER NTITLE=97
C
C NINFO IS THE NUMBER OF HEADER ELEMENTS TO BE RETURNED BY GETEPHD CALL.
C
      PARAMETER NINFO = 11 + NGRAV + NDRAG + NAUXIL
      REAL*8 HEADINFO(NINFO)
C
C
C
C
C *** INITIALIZE ***
C
      IERR = 0
C
C
C *** LOAD THE HEADER INFO INTO THE LOCAL ARRAY, HEADINFO ***
C
      CALL GETEPHD(0,LUEPHM,NINFO,HEADINFO,DELEP,LUERR,IER1)
      IF(IER1.NE.0) THEN
        IERR = 1
        IF(LUERR.GT.0) WRITE(LUERR,6543) LUEPHM
 6543   FORMAT(/,
     *    ' EPHEAD. ERROR RETURN FROM GETEPHD(GETEPH). UNIT=',I3)
        GO TO 9999
        END IF
C
C
C *** LOAD CERTAIN HEADER INFO INTO THE LOCAL ARRAY, AUXPARM ***
C
      INDEX1 = 12
      CALL MTXEQL(HEADINFO(INDEX1),AUXPARM,NAUXIL,1)
C 
C
C *** PROGRAMMING ERROR CHECKS ***
C
C CHECKS ARE DONE HERE TO HELP ENSURE THAT FUTURE HEADER MODS ARE
C ACCOMPANIED BY CONSISTENT MODS TO EPHEMGEN, EPHFILE, RDEPHM, GETEPH,
C AND GETEPHD.
C
C   IF THERE IS AN ERROR, TRACE IT USING THE FOLLOWING INFO:
C
C    1. EPHEMGEN MAIN LOADS ARRAY VALUES
C    2. EPHFILE(EPHEMGEN PROGRAM) WRITES THE HEADER INFO, INCLUDING
C       THE NUMBER OF PARAMETERS BEING CHECKED HERE
C    3. RDEPHM, CALLED BY GETEPH, READS THE HEADER, LOADS R8V, AND
C       PASSES R8V BACK TO GETEPH.
C    4. GETEPH LOADS HEADINFO FROM R8V ARRAY
C    5. THIS ROUTINE CHECKS THE NUMBER OF PARAMETERS.
C
      KTITLE = JIDNNT(HEADINFO(14))
      KGRAV =  JIDNNT(HEADINFO(15))
      KDRAG =  JIDNNT(HEADINFO(16))
      KAUXIL = JIDNNT(HEADINFO(17))
C
      OKHEAD = KTITLE.EQ.NTITLE   .AND.   KGRAV.EQ.NGRAV   .AND.
     *         KDRAG.EQ.NDRAG   .AND.   KAUXIL.EQ.NAUXIL
      IF(.NOT.OKHEAD) THEN
        IERR = 1
        IF(LUERR.NE.0) WRITE(LUERR,5601) KTITLE,KGRAV,KDRAG,KAUXIL
 5601   FORMAT(/,
     *   ' EPHEAD ERROR. HEADER CONTENTS NOT AS EXPECTED. SEE SOURCE.'/,
     *   '     KTITLE,KGRAV,KDRAG,KAUXIL=',4I4)
        END IF
C
C
C *** LOAD HEADER INFO INTO LOCAL ARRAYS GRAVPARM AND DRAGPARM ***
C
      IF(OKHEAD) THEN
        INDEX1 = 12 + NAUXIL
        CALL MTXEQL(HEADINFO(INDEX1),GRAVPARM,NGRAV,1)
        INDEX1 = INDEX1 + NGRAV
        CALL MTXEQL(HEADINFO(INDEX1),DRAGPARM,NDRAG,1)
      ELSE
        CALL MTXSETR8(GRAVPARM,777.D0,NGRAV,1)
        CALL MTXSETR8(DRAGPARM,777.D0,NDRAG,1)
        END IF
C
C
C *** LOAD GRAVITATION PARAMETERS INTO VARIABLES WITH USEFUL NAMES ***
C
      KSUN = 1
      IF(GRAVPARM(1).EQ.0.D0) KSUN = 0
      KMOON = 1
      IF(GRAVPARM(2).EQ.0.D0) KMOON = 0
      NZONAL =    JIDNNT(GRAVPARM(3))
      NTESSERAL = JIDNNT(GRAVPARM(4))
      UEARTH =    GRAVPARM(5)
      UMOON =     GRAVPARM(6)
      USUN =      GRAVPARM(7)
C
C
C *** LOAD DRAG PARAMETERS INTO VARIABLES WITH USEFUL NAMES ***
C
      KDRAG = 1
      IF(DRAGPARM(1).EQ.0.D0) KDRAG = 0
      IF(KDRAG.EQ.0) CALL MTXSETR8(DRAGPARM,0.D0,NDRAG,1)
      SCMASS = DRAGPARM( 2)
      CD =     DRAGPARM( 3)
      MODID =  DRAGPARM( 4)
      IF(MODID.NE.1) THEN
        DRAGPARM(5) = 0.D0
        DRAGPARM(6) = 0.D0
        DRAGPARM(7) = 0.D0
        DRAGPARM(8) = 0.D0
        END IF
      KDENID = DRAGPARM(8)
      KATTDEP = JIDNNT(DRAGPARM(10))
      XAREA = DRAGPARM(11)
      YAREA = DRAGPARM(12)
      ZAREA = DRAGPARM(13)
C
C
C *** LOAD AUXILIARY PARAMETERS INTO VARIABLES WITH USEFUL NAMES ***
C
      KCOORD = JIDNNT(AUXPARM(2))
C
C
C *** OPTION: LOAD OUTPUT ARRAY, HEADPARM ***
C
      IF(KGETPARM.NE.0) THEN
        CALL MTXEQL(HEADINFO,HEADPARM,11,1)
        HEADPARM(12) = AUXPARM(2)
        END IF
C
C
C *** OPTION: GIVE PRINT ***
C
      IF(LUPRINT.GT.0) THEN
C
        CALL PAKT50CH( SINCE50(AUXPARM(1)),CHGENER )
        CHGENER(12:12)=':'
        WRITE(LUPRINT,1001) LUEPHM,CHGENER(1:14)
C
        IF(DELEP.EQ.0.D0) WRITE(LUPRINT,1022)
        IF(DELEP.NE.0.D0) WRITE(LUPRINT,1021)
C
C
C      INITIAL CONDITIONS, TIME SPAN COVERED
        T1SEC50 = HEADINFO( 9)
        T2SEC50 = HEADINFO(10)
        SPAN=T2SEC50-T1SEC50
  225   CONTINUE
        CALL ELAPSD(SPAN,KDAYS,KHRS,KMINS,SEC)
        KSEC=JIDNNT(SEC)
        IF(KSEC.EQ.60) THEN
          SPAN=SPAN+0.5
          GO TO 225 
          END IF
        CALL PAKT50CH( HEADINFO(1),CHEPOCH )
        WRITE(LUPRINT,1002) COORDNAME(1,KCOORD,KDUM,KDUM),CHEPOCH,
     *     HEADINFO(2),HEADINFO(3),(HEADINFO(I)*DEGRAD,I=4,8),
     *     PAKTIM50(T1SEC50),PAKTIM50(T2SEC50),KDAYS,KHRS,KMINS,
     *     JIDNNT(SEC),HEADINFO(11)
C
C      GRAVITATIONAL FORCES
        WRITE(LUPRINT,1003) UEARTH,OFFON(KSUN+1),OFFON(KMOON+1),
     *             NZONAL,NTESSERAL
C
C      DRAG FORCE
        WRITE(LUPRINT,1004) OFFON(KDRAG+1)
C
        WRITE(LUPRINT,1099)
        END IF
C
      GO TO 9999
C
 9999 CONTINUE
C
      RETURN
C
 1001 FORMAT(/,
     *  ' EPHEMERIS FILE HEADER INFORMATION(UNIT=',I2,').'//,
     *    T5,'FILE WAS MADE (Y/M/D H:M) = ',A/)
 1021 FORMAT(
     * '    THE HEADER INFO HAS BEEN MODIFIED TO REFLECT AN EPOCH ',
     *           'DIFFERENT FROM'/,
     * '    THE EPHEM FILE''S. THE EARTH-FIXED TRAJECTORY IS ',
     *           'PRESERVED.'/)
 1022 FORMAT(
     * '    THIS IS THE ACTUAL HEADER INFO AS TAKEN FROM THE'/,
     * '    EPHEM FILE. NO EPOCH CHANGE HAS OCCURRED.'/)
 1002 FORMAT(
     *    T5,'INITIAL CONDITIONS :'//,
     *    T8,A//,
     *    T8,'EPOCH(Y/M/D H/M/S) =  ',A/,
     *    T8,'SEMI-MAJOR AXIS(KM) = ',F9.3/,
     *    T8,'ECCENTRICITY =        ',F9.6/,
     *    T8,'INCLINATION(DEG) =    ',F9.3/,
     *    T8,'NODE(DEG)=            ',F9.3/,
     *    T8,'ARG OF PERIGEE(DEG) = ',F9.3/,
     *    T8,'MEAN ANOMALY(DEG) =   ',F9.3/,
     *    T8,'TRUE ANOMALY(DEG) =   ',F9.3///,
     *    T5,'TIME INFORMATION:'/,
     *    T8,'EARLIEST TIME(YYMMDD.HHMMSS) =    ',F13.6/,
     *    T8,'LATEST TIME(YYMMDD.HHMMSS) =      ',F13.6/,
     *    T8,'  TIME SPAN =',I4,' DAYS, ',I2,' HRS, ',I2,' MIN, ',
     *      I2,' SEC.'/,
     *    T8,'TIME STEP BETWEEN POS/VEL ENTRIES(SEC) = ',F6.0//)
 1003 FORMAT(
     *    T5,'FORCES USED :'//,
     *    T8,'EARTH GRAVITATION CONST: ',F10.2/,
     *    T8,'SUN GRAVITY:                 ',A/,
     *    T8,'MOON GRAVITY:                ',A/,
     *    T8,'NUMBER OF EARTH ZONALS:      ',I3/,
     *    T8,'NUMBER OF EARTH TESSERALS:   ',I3)
 1004 FORMAT(
     *    T8,'ATMOSPHERIC DRAG:            ',A/)
 1099 FORMAT(//,' END OF EPHEMERIS FILE HEADER INFORMATION.'/)
C
      END
