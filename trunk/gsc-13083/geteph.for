      SUBROUTINE GETEPH(TIM50,POS,VEL,IRESET,LUEPHEM,LUERR,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  THIS ROUTINE CONTROLS CALLS TO THE EPHEMERIS FILE READER. USING THIS
C  ROUTINE SAVES THE PROGRAMMER FROM HAVING TO CODE THE POSBUF, VELBUF,
C  R8V, AND I4V ARRAYS IN EACH ROUTINE THAT NEEDS TO READ THE EPHEM
C  FILE.
C
C  THIS ROUTINE HAS FOUR FUNCTIONS, DEFINED BY ENTRY POINTS:
C
C        1) IT GIVES SPACECRAFT POSITION AND VELOCITY AT A SPECIFIED
C           TIME USING DATA FROM AN EPHEM FILE. (CALL GETEPH)
C
C        2) IT RETURNS EPHEM FILE HEADER INFORMATION. (CALL GETEPHD)
C
C        3) IT REDEFINES THE EPOCH AND PRESERVES THE EARTH-FIXED
C           TRAJECTORY. (CALL GETEPHZ)
C
C        4) IT 'DEACTIVATES' PREVIOUSLY ACCESSED EPHEM FILES. SEE
C           COMMENTS BELOW THE DEFINITION OF ACTIVE.
C           (CALL GETEPH OR GETEPHD OR GETEPHZ)
C
C
C  THIS ROUTINE ALLOWS THE PROGRAM TO MULTIPLE FILES WITHIN A SINGLE
C  RUN. THE FILES INVOLVED MAY BE READ IN ANY SEQUENCE NEEDED. FOR
C  EXAMPLE, FOR EPHEM FILE UNITS 91, 92, AND 93, THE CALLS MAY USE
C  THEM IN THE ORDER 91,92,91,93,91,91,91,93,92,93,92,92,91,....
C
C  THIS ROUTINE CAN HANDLE UP TO 3(EASILY INCREASED) ACTIVE FILES. A 
C  FILE IS CALLED 'ACTIVE' WITHIN THIS ROUTINE IF ITS ASSOCIATED ARRAYS
C  HAVE BEEN INITIALIZED. ARRAYS ARE INITIALIZED THE FIRST TIME THE FILE
C  IS NEEDED. THE FILE REMAINS ACTIVE UNTIL A CALL OCCURS TO DEACTIVATE
C  IT. WHEN A FILE IS DEACTIVATED, THIS ROUTINE FORGETS IT EVER USED
C  THE FILE AND A SUBSEQUENT CALL TO READ IT IS EXECUTED AS THOUGH IT
C  WERE THE FIRST CALL.
C
C  THIS ROUTINE CONTAINS CODE THAT ALLOWS YOU TO CHANGE THE EPOCH
C  ON THE FILE, PRESERVE THE EARTH-FIXED TRAJECTORY, AND RETURN
C  INERTIAL STATE VECTORS AS THOUGH THE EPHEM FILE WERE ORIGIALLY
C  GENERATED WITH THAT EPOCH. THIS OPTION IS NOT VALID FOR FORCE
C  MODELS INVOLVING THE SUN, MOON, AND SUN-DEPENDENT DRAG. IT IS VALID
C  FOR EARTH ZONAL AND TESSERAL FORCES.
C
C
C                    ********************
C********************* GETEPH ARGUMENTS ********************************
C                    ********************
C
C USAGE NOTE: IF AN EPOCH CHANGE IS DEFINED, THE FIRST GETEPH CALL MUST
C             BE PRECEEDED BY A GETEPHD CALL. THIS REQUIREMENT FORCES
C             THE PROGRAMMER TO CONSIDER THE FACT THAT THE HEADER
C             INFORMATION IS DEPENDENT UPON THE EPOCH IN USE AND THE
C             CALLING PROGRAM MAY NEED TO UPDATE ITS INFORMATION.
C
C  VARIABLE  DIM  TYPE  I/O   DESCRIPTION
C  --------  ---  ----  ---   -----------
C
C  TIM50     1    R*8    I    THE TIME IN SECONDS SINCE 1/1/50 0.0 HR UT
C                             THAT THE S/C POSITION AND VELOCITY ARE
C                             WANTED.
C
C  POS       3    R*8    O    THE S/C INERTIAL CARTESIAN POSITION
C                             COORDINATES AT TIM50. KM.
C
C                             THE POSITION DEPENDS UPON THE EPOCH IN
C                             USE. IT WILL DIFFER FROM THE FILE'S
C                             POSITION IF AN EPOCH CHANGE HAS BEEN
C                             DEFINED BY GETEPHZ, BUT THE EARTH-FIXED
C                             TRAJECTORY IS THE SAME.
C
C  VEL       3    R*8    O    THE S/C VELOCITY AT TIM50. KM/SEC.
C
C                             THE VELOCITY DEPENDS UPON THE EPOCH IN
C                             USE. IT WILL DIFFER FROM THE FILE'S
C                             VELOCITY IF AN EPOCH CHANGE HAS BEEN
C                             DEFINED BY GETEPHZ, BUT THE EARTH-FIXED
C                             TRAJECTORY IS THE SAME.
C
C  IRESET    1    I*4    I    A FLAG TO TELL THE ROUTINE TO READ THE 
C                             HEADER INFORMATION FROM THE EPHEM FILE.
C
C                             =0 DO NOT RE-READ THE HEADER. THE FILE HAS
C                                NOT BEEN CHANGED SINCE THE LAST CALL.
C                                HEADER INFO ALREADY IN INTERNAL ARRAYS
C                                WILL BE USED.
C                             =1 RE-READ THE HEADER AND REPLACE THE
C                                CURRENT CONTENTS OF INTERNAL ARRAYS.
C                                USED IF THE FILE HAS BEEN REGENERATED
C                                SINCE THE LAST CALL.
C
C                             HEADER INFO IS NEEDED BY THE INTERPOLATION
C                             SCHEME FOR PRODUCING THE OUTPUT POS/VEL.
C
C                             THE HEADER IS READ AUTOMATICALLY THE FIRST
C                             TIME THIS FILE IS READ.
C
C  LUEPHEM   1    I*4    I    THE FORTRAN UNIT NUMBER ASSOCIATED WITH
C                             THE EPHEM FILE BEING READ.
C
C                             IF POSITIVE: THIS IS THE NUMBER OF THE 
C                               FILE WE WANT TO READ NOW.
C
C                             IF NEGATIVE: WE ARE TELLING THIS ROUTINE
C                               TO SEARCH THE SET OF ACTIVE FILE NUMBERS
C                               FOR IABS(LUEPHEM) AND, IF FOUND, SET THE
C                               FILE TO INACTIVE STATUS. TO DEACTIVATE 
C                               ALL FILE NUMBERS, USE -999. LUEPHEM AND
C                               IERR ARE THE ONLY ARGUMENTS REFERENCED.
C
C  LUERR     1    I*4    I    THE FORTRAN UNIT NUMBER FOR PRINTING OF
C                             ERROR MESSAGES. LUERR=0 MEANS NO
C                             MESSAGES ARE POSSIBLE.
C
C  IERR      1    I*4    O    ERROR RETURN FLAG.
C                             = 0, NO ERROR FOUND. 
C                             = 1, ERROR FOUND.
C
C
C
C                    *********************
C********************* GETEPHD ARGUMENTS *******************************
C                    *********************
C
C  VARIABLE  DIM  TYPE  I/O   DESCRIPTION
C  --------  ---  ----  ---   -----------
C
C  IRESET     1   I*4    I    SAME DESCRIPTION AS ABOVE.
C
C  LUEPHEM    1   I*4    I    SAME DESCRIPTION AS ABOVE.
C
C  NHINFO     1   I*4    I    MUST EQUAL 52 FOR ERROR CHECKS.
C
C  HEADINFO  52   R*8    O    AN ARRAY CONTAINING INFO READ FROM THE
C                             EPHEMERIS FILE HEADER RECORDS.
C
C     HEADINFO ASSIGNMENTS ARE:
C
C       (1) TIME ASSOCIATED WITH THE INITIAL CONDITIONS. SECONDS SINCE 
C           1/1/50, 0.0 HR UT
C
C       (2-8) KEPLERIAN ELEMENTS FOR INITIAL CONDITIONS. ORDER IS A, E,
C             I, N, W, MA, TA.   IN KM AND RADIANS.
C
C       (9) EARLIEST TIME THAT POS/VEL INFO IS GIVEN ON THE FILE. 
C           IN SECONDS SINCE 1950.
C
C       (10) LATEST TIME THAT POS/VEL INFO IS GIVEN ON THE FILE.
C            IN SECONDS SINCE 1950.
C
C       (11) STEP SIZE BETWEEN CONSECUTIVE POSITION/VELOCITY ENTRIES.
C            IN SECONDS.
C
C       (12-31) AUXILIARY INFO.
C
C          12) YYMMDD.HHMMSS OBTAINED FROM COMPUTER CLOCK WHEN FILE
C              WAS MADE
C          13) COORDINATE SYSTEM ID. 1=M50, 2=MDT, 3=TOD
C          14) LOADED WITH INFO NOT USEFUL TO THE CALLER. IGNORE IT.
C          15) NUMBER OF GRAVITY PARAMETER POSITIONS PRESENT
C          16) NUMBER OF DRAG PARAMETER POSITIONS PRESENT
C          17) NUMBER OF AUXILIARY PARAMETER POSITIONS PRESENT
C          18-31) NOT USED
C
C       (32-38) GRAVITY MODEL INFO
C
C          32) SUN POINT MASS USED. (0.0=NO; OTHERWISE, YES)
C          33) MOON POINT MASS USED. (0.0=NO; OTHERWISE, YES)
C          34) NUMBER OF ZONAL HARMONICS USED
C          35) NUMBER OF TESSERAL HARMONICS USED
C          36) EARTH MU, KM**3/SEC**2
C          37) MOON MU, KM**3/SEC**2
C          38) SUN MU, KM**3/SEC**2
C
C       (39-52) DRAG MODEL INFO
C
C          39) DRAG FORCES USED. (0.0=DRAG WAS OFF; OTHERWISE, ON)
C              IF DRAG IS OFF, ELEMENTS 40-52 ARE NOT RELEVANT
C          40) S/C MASS, KG
C          41) DRAG COEFFICIENT
C          42) ATMOSPHERE MODEL NUMBER (1=HARPRI, 2=JAC-ROB, 3=ATM62)
C          43) RHO4 PARAMETER FOR HAR-PRI MODEL
C          44) NNCOS PARAMETER FOR HAR-PRI MODEL
C          45) DENSITY SOURCE FOR HAR-PRI.
C              (1=INTERNAL, 2=TOSS FILE, 3=USER)
C          46) HAR-PRI SOLAR FLUX IDENTIFIER
C              (1=65, 2=75, 3=100, 4=125, ..., 10=275)
C          47) FORTRAN UNIT NUMBER USED BY EPHEMGEN PGM FOR THE
C              DENSITY DATA 
C          48) ATT-DEP DRAG INDICATOR (0=NO, 1=ATT-DEP, 3=ATT-DEP/SVDS)
C          49) S/C AREA NORMAL TO X-AXIS, OR CONST AREA FOR
C              NO ATTITUDE DEPENDENT DRAG
C          50) S/C AREA NORMAL TO Y-AXIS
C          51) S/C AREA NORMAL TO Z-AXIS
C          52) FORTRAN UNIT NUMBER USED BY EPHEMGEN PGM FOR THE
C              S/C ATTITUDE DATA 
C
C  DELEP     1    R*8    O    THE NUMBER OF SECONDS BETWEEN THE ACTUAL
C                             EPOCH TIME USED WHEN THE EPHEM FILE WAS
C                             WRITTEN AND THE EPOCH TIME BEING USED IN
C                             THE GETEPH CALLS FOR POS/VEL INFORMATION.
C
C  LUERR     1    I*4    I    SAME DESCRIPTION AS ABOVE.
C
C  IERR      1    I*4    O    SAME DESCRIPTION AS ABOVE.
C
C
C
C                    *********************
C********************* GETEPHZ ARGUMENTS *******************************
C                    *********************
C
C USAGE NOTE: FOR THE EPHEM FILE INVOLVED ON THIS CALL, AFTER CALLING
C             GETEPHZ AND BEFORE CALLING GETEPH, YOU MUST CALL GETEPHD.
C             SEE A SIMILAR NOTE IN THE GETEPH DESCRIPTION ABOVE.
C
C  VARIABLE  DIM  TYPE  I/O   DESCRIPTION
C  --------  ---  ----  ---   -----------
C
C  EPOCHNEW   1    R*8   I    THE EPOCH TO WHICH THE STATE VECTORS
C                             RETURNED BY SUBSEQUENT GETEPH AND GETEPHD
C                             CALLS ARE TO BE REFERENCED. UNLESS
C                             REDEFINED BY A CALL TO GETEPHZ, STATES
C                             ARE REFERENCED TO THE EPOCH ON THE EPHEM
C                             FILE HEADER. IF EPOCH IS REDEFINED,
C                             STATE VECTORS WILL BE ROTATED TO PRESERVE
C                             THE EARTH-FIXED TRAJECTORY.
C
C  LUEPHEM    1    I*4   I    THE EPHEM FILE FOR WHICH THIS EPOCH
C                             DEFINITION WILL APPLY. IF NEGATIVE, THE
C                             FILE IS DEACTIVATED AND EPOCHNEW HAS NO
C                             EFFECT.
C
C  LUERR     1    I*4    I    SAME DESCRIPTION AS ABOVE.
C
C  IERR      1    I*4    O    SAME DESCRIPTION AS ABOVE.
C
C
C
C***********************************************************************
C
C  CODED BY C PETRUZZO 6/81.
C  MODIFIED....... CJP.  7/83. COMMENT MOD, NO CODE MOD.
C                  CJP.  3/85. MAJOR REWRITE TO ALLOW MULTIPLE FILES
C                              TO BE ACTIVE. CALLING SEQ REMAINS INTACT
C                              BUT LUEPHEM NEGATIVE NOW HAS A MEANING.
C                              ADDED ENTRY POINT GETEPHD AND ITS CODE.
C                  CJP.  5/85. MODS TO ALLOW FOR EPOCH CHANGE WHILE
C                              PRESERVING EARTH-FIXED TRAJECTORY.
C
C***********************************************************************
C
C
      INTEGER NUMERR/0/,MAXERR/15/
      REAL*8 TJD50/2433282.5D0/,SECDAY/86400.D0/
      REAL*8 POS(3),VEL(3),ROTMTX(3,3),POSHEAD(3),VELHEAD(3)
      REAL*8 DEGRAD / 57.29577951308232D0 /
      LOGICAL DEACTIVATE
C
      REAL*8 HEADINFO(1)
C
C MAXEPH IS THE MAX NUMBER OF FILES THAT CAN BE ACTIVE AT A TIME. TO
C INCREASE THE MAX, CHANGE THE MAXEPH VALUE. NO OTHER CHANGES NEEDED.
C
      PARAMETER MAXEPH=3
C
      REAL*8  POSBUF(3,100,MAXEPH), VELBUF(3,100,MAXEPH), EPOCH(MAXEPH)
      REAL*8  R8V(62,MAXEPH)
      INTEGER I4V( 6,MAXEPH)
      INTEGER LUINIT(MAXEPH)/MAXEPH*1/,    ! 1 SAYS HEADER NEEDS READING
     *        LUACTIVE(MAXEPH)/MAXEPH*-1/  ! ACTIVE FILE NUMBERS
      REAL*8  DELEPOCH(MAXEPH)/MAXEPH*0.D0/
      INTEGER KENTLAST(MAXEPH)/MAXEPH*0/
C
C
C
C
C >>>>>>> ENTER VIA GETEPH CALL.
C
      KENTRY = 1
      GO TO 2222
C
C
C >>>>>>> ENTER VIA GETEPHD CALL.
C
      ENTRY GETEPHD(IRESET,LUEPHEM,NHINFO,HEADINFO,DELEP,LUERR,IERR)
      KENTRY = 2
      GO TO 2222
C
C
C >>>>>>> ENTER VIA GETEPHZ CALL.
C
      ENTRY GETEPHZ(EPOCHNEW,LUEPHEM,LUERR,IERR)
      KENTRY = 3
C
C
C
 2222 CONTINUE
C
      IBUG = 0
      LUBUG = 19
C
      IF(IBUG.NE.0) THEN
        IF(KENTRY.EQ.1) TEMP = PAKTIM50(TIM50)
        IF(KENTRY.EQ.2) TEMP = 999999.999999
        IF(KENTRY.EQ.3) TEMP = PAKTIM50(EPOCHNEW)
        WRITE(LUBUG,5001) TEMP,IRESET,LUEPHEM,LUACTIVE
 5001   FORMAT(/,' GETEPH. START DEBUG.',
     *       ' TIME=',G20.12,'  IRESET,LUEPHEM=',2I4/,
     *         '      LUACTIVE=',<MAXEPH>I3)
        END IF
C
      IERR = 0
C
C
C IF THIS IS A CALL TO DEACTIVATE A FILE, DO SO AND RETURN.
C
      IF(LUEPHEM.LT.0) THEN
        IEPH = 0
        LU = -LUEPHEM
        DO WHILE (IEPH.LT.MAXEPH)
          IEPH = IEPH + 1
          DEACTIVATE =  LU.EQ.999 .OR. LU.EQ.LUACTIVE(IEPH)
          IF(DEACTIVATE) THEN
            LUACTIVE(IEPH) = -1
            LUINIT(IEPH) = 1
            DELEPOCH(IEPH) = 0.D0
            END IF
          END DO
        GO TO 9999
        END IF
C
C
C SEE IF THE FILE IS ALREADY ACTIVE. IF SO, SET LUINDEX.
C
      LUINDEX = 0
      IEPH = 0
      DO WHILE (LUINDEX.EQ.0 .AND. IEPH.LT.MAXEPH)
        IEPH = IEPH + 1
        IF(LUACTIVE(IEPH).EQ.LUEPHEM) LUINDEX = IEPH
        END DO
C
C
C IF NOT ALREADY ACTIVE(IE, LUINDEX IS STILL ZERO), MAKE IT ACTIVE.
C
      IF(LUINDEX.EQ.0) THEN
        IEPH = 0
        DO WHILE(LUINDEX.EQ.0 .AND. IEPH.LT.MAXEPH)
          IEPH = IEPH + 1
          IF(LUACTIVE(IEPH).LE.0) THEN
            LUINDEX = IEPH
            LUINIT(IEPH) = 1
            LUACTIVE(LUINDEX) = LUEPHEM
            END IF
          END DO
        END IF
C
C IF STILL NOT ACTIVE, THEN MAX FILES WERE ACTIVE AND THERE WAS NO
C ROOM FOR A NEW ONE. THE USER CAN DEACTIVATE SOME FILES TO MAKE ROOM
C FOR THIS ONE, OR ELSE RECOMPLILE THIS ROUTINE WITH A LARGER MAXEPH 
C VALUE. IN ANY CASE, THIS IS AN ERROR CONDITION. CODING COULD HAVE HAD
C THE CURRENT FILE REPLACE ONE ALREADY ACTIVE, BUT CJP PREFERS TO HAVE
C AN ERROR CONDITION SO THIS ROUTINE WILL BE USED PROPERLY.
C
      IF(LUINDEX.EQ.0) THEN
        IERR = 1
        IF(LUERR.GT.0) WRITE(LUERR,4001) LUEPHEM,LUACTIVE
 4001   FORMAT(/,
     *    ' GETEPH ERROR. HAVE NOT READ READ EPHEM FILE ',I2,
     *       '. MAX FILES ARE ACTIVE.'/,
     *    '        ACTIVE FILES ARE ',<MAXEPH>I3/)
        GO TO 9999
        END IF
C
      IF(IBUG.NE.0) WRITE(LUBUG,5002) LUINDEX
 5002 FORMAT(/,' GETEPH DEBUG 5002. LUINDEX=',I3)
C
C
C IF THIS FILE IS NEWLY ACTIVE WITH THIS CALL, READ THE HEADER RECORD
C AND LOAD R8V, I4V, POSBUF, VELBUF, AND EPOCH. THESE ARRAYS ARE CARRIED
C AS THEY ARE FOUND ON THE EPHEM FILE, NOT MODIFIED TO ACCOMMODATE ANY
C EPOCH CHANGE THAT MAY BE INVOLVED.
C
      NEWACTIVE = (IRESET.NE.0 .OR. LUINIT(LUINDEX).EQ.1)  .AND.
     *             KENTRY.NE.3
      IF(NEWACTIVE) THEN
        LUINIT(LUINDEX) = 0
        R8V(12,LUINDEX) = 1.D0
        R8V(13,LUINDEX) = 1.D0
        I4V( 1,LUINDEX) = LUEPHEM
        I4V( 2,LUINDEX) = 4
        I4V( 3,LUINDEX) = 1
        IF(IBUG.NE.0) WRITE(LUBUG,5009) LUEPHEM
 5009   FORMAT(/,' GETEPH DEBUG 5009. INITIALIZE BUFFERS FOR UNIT',I3)
        CALL RDEPHM('ZZZZZZZZ',POS,VEL,IER,LUERR,
     *        POSBUF(1,1,LUINDEX),VELBUF(1,1,LUINDEX),
     *        R8V(1,LUINDEX),I4V(1,LUINDEX))
        EPOCH(LUINDEX) = (R8V(14,LUINDEX) - TJD50) * SECDAY
C
C      ERROR CHECK. ERROR MESSAGE WOULD HAVE BEEN WRITTEN FROM RDEPHM.
        IF(IER.NE.0) THEN
          IERR = 1
          GO TO 9999
          END IF
C
C      DEBUG.
        IF(IBUG.NE.0) WRITE(LUBUG,1001) LUINDEX,LUEPHEM,
     *     (R8V(I,LUINDEX),I=1,62), (I4V(I,LUINDEX),I=1,6),
     *     (I,(POSBUF(J,I,LUINDEX),J=1,3),I=1,20)
 1001   FORMAT(' GETEPH DEBUG.   LUINDEX=',I2,'  LUEPHEM=',I3/,
     *         '  R8V = ',15(T12,4G15.7/),T12,2G15.7/,
     *         '  I4V = ',6I5/,
     *         '  POSBUF(1-3,1-20,LUINDEX) = '/,20(T5,I2,2X,3G15.7/))
        END IF
C
C
C *****************************
C * GET THE OUTPUT QUANTITIES *
C *****************************
C
C *** IF ENTERED VIA GETEPH, GET THE S/C POSITION AT TIME TIM50 ***
C
      IF(KENTRY.EQ.1) THEN
C
C     ERROR CHECK. SEE USAGE COMMENTS AT THE TOP OF THIS LISTING FOR
C     INFORMATION ON WHY GETEPHZ CALL FOLLOWED BY GETEPH CALL IS NOT
C     PERMITTED.
C
       IF(KENTLAST(LUINDEX).EQ.3) THEN
         STOP ' GETEPH. PROGRAMMER ERROR, NOT USER ERROR. STOPPED.'
         END IF
C
C      GET THE STATE VECTOR. TIM50 ACCOUNTS FOR ANY EPOCH CHANGE, AND
C      SINCE THE R8V, I4V, POSBUF, VELBUF, AND EPOCH ARRAYS ARE RELATED
C      TO THE ACTUAL EPOCH ON THE FILE, WE DO OUR COMPUTATIONS RELATIVE
C      TO THE ORIGINAL EPOCH, THEN ACCOUNT FOR THE EPOCH CHANGE.
        DT = DELEPOCH(LUINDEX)
        TFILE = (TIM50 - DT)  - EPOCH(LUINDEX)
        CALL RDEPHM(TFILE,POS,VEL,
     *         IER,LUERR,POSBUF(1,1,LUINDEX),VELBUF(1,1,LUINDEX),
     *         R8V(1,LUINDEX),I4V(1,LUINDEX))
C
C      ERROR CHECK. ERROR MESSAGE WOULD HAVE BEEN WRITTEN FROM RDEPHM.
        IF(IER.NE.0) THEN
          IERR = 1
          GO TO 9999
          END IF
C
C      IF AN EPOCH CHANGE IS INVOLVED, ROTATE THE STATE VECTOR.
        IF(DT.NE.0.D0) THEN
          KCOORD = JIDNNT(R8V(23,LUINDEX))
          CALL ROTSLIP1(KCOORD,TIM50-DT,DT,ROTMTX,LUERR,IER1)
          CALL VECROT(ROTMTX,POS,POS,3,1)
          CALL VECROT(ROTMTX,VEL,VEL,3,1)
          END IF
C
        KENTLAST(LUINDEX) = KENTRY
        END IF
C
C
C ********** IF ENTERED VIA GETEPHD, LOAD HEADER INFO ARRAY ************
C
      IF(KENTRY.EQ.2) THEN
C
C      EPOCH AND R8V ARE AS THEY ARE ON THE EPHEM FILE. LOAD HEADINFO
C      WITH THOSE VALUES. IF AN EPOCH CHANGE IS INVOLVED, MODIFY
C      HEADINFO AFTERWARD.
C
        HEADINFO(1) = EPOCH(LUINDEX)
        DO 200 I=1,7
  200   HEADINFO(1+I)=R8V(14+I,LUINDEX)  !SEE RDEPHM FOR R8V DESCRIPTION
        HEADINFO( 9) = EPOCH(LUINDEX) + (R8V(5,LUINDEX)-R8V(7,LUINDEX))
        HEADINFO(10) = EPOCH(LUINDEX) + (R8V(6,LUINDEX)+R8V(8,LUINDEX))
        HEADINFO(11) = R8V(3,LUINDEX)
C
C      CHANGE HEADINFO CONTENTS IF EPOCH CHANGE IS INVOLVED
        DELEP = DELEPOCH(LUINDEX)
        IF(DELEP.NE.0.D0) THEN
C        EPOCH.
          HEADINFO(1) = HEADINFO(1) + DELEP
C        KEPLERIAN ELEMENTS
          KCOORD = JIDNNT(R8V(23,LUINDEX))
          CALL ROTSLIP1(KCOORD,EPOCH(LUINDEX),DELEP,ROTMTX,LUERR,IER1)
          UEARTH = R8V(46,LUINDEX)
          CALL TOCART(UEARTH,HEADINFO(2),0,POSHEAD,VELHEAD,LUERR,IER1)
          CALL VECROT(ROTMTX,POSHEAD,POSHEAD,3,1)
          CALL VECROT(ROTMTX,VELHEAD,VELHEAD,3,1)
          CALL TOKEPL(UEARTH,POSHEAD,VELHEAD,HEADINFO(2),DUM,DUM)
          HEADINFO(8) = ANOMLY(1,HEADINFO(8),HEADINFO(3),LUERR,IER1)
C        EARLIEST/LATEST TIMES
          HEADINFO( 9) = HEADINFO( 9) + DELEP
          HEADINFO(10) = HEADINFO(10) + DELEP
          END IF
C
        NINFO1 = 11
        NGRAV =   7
        NDRAG =  14
        NAUXIL = 20
C
C      ERROR CHECK. DONE TO PROMOTE CONSISTENCY BETWEEN EPHEAD AND
C      GETEPH IN FUTURE MODS.  IE, IF CALLER CALLS WITH THE WRONG
C      VALUE, CALLER MODS ARE NEEDED BECAUSE THE QUANTITIES THE CALLER
C      EXPECTS IN HEADINFO ARE DIFFERENT THAN WHAT THIS ROUTINE WANTS
C      TO RETURN.
        IF( (NINFO1+NGRAV+NDRAG+NAUXIL).NE.NHINFO)
     *     STOP ' GETEPH. ENTRY GETEPHD. CODING ERROR. STOP 1.'
C
C      LOAD THE REST OF THE HEADINFO ARRAY
        INDX1 = 22
        INDX2 = NINFO1 + 1
        CALL MTXEQL(R8V(INDX1,LUINDEX),HEADINFO(INDX2),NAUXIL,1)
        INDX1 = INDX1 + NAUXIL
        INDX2 = INDX2 + NAUXIL
        CALL MTXEQL(R8V(INDX1,LUINDEX),HEADINFO(INDX2),NGRAV,1)
        INDX1 = INDX1 + NGRAV
        INDX2 = INDX2 + NGRAV
        CALL MTXEQL(R8V(INDX1,LUINDEX),HEADINFO(INDX2),NDRAG,1)
C
C      IF ONE OF THESE ERRORS OCCURS, THEN THE HEADINFO DESCRIPTION
C      IN THE PROLOGUE IS WRONG.  FORCE A LOOK AND A FIX.  THIS
C      DESCRIPTION DOES NOT AGREE WITH WHAT WAS WRITTEN ON THE
C      HEADER FILE BY EPHFILE.
        IF(JIDNNT(HEADINFO(15)).NE.NGRAV)
     *        STOP 'GETEPH. ENTRY GETEPHD. CODING ERROR. STOP 2.'
        IF(JIDNNT(HEADINFO(16)).NE.NDRAG)
     *        STOP 'GETEPH. ENTRY GETEPHD. CODING ERROR. STOP 3.'
        IF(JIDNNT(HEADINFO(17)).NE.NAUXIL)
     *        STOP 'GETEPH. ENTRY GETEPHD. CODING ERROR. STOP 4.'
C
        KENTLAST(LUINDEX) = KENTRY
        END IF
C
C
C ********** IF ENTERED VIA GETEPHZ, STORE THE EPOCH CHANGE ************
C
      IF(KENTRY.EQ.3) THEN
        DELEPOCH(LUINDEX) = EPOCHNEW - EPOCH(LUINDEX)
        KENTLAST(LUINDEX) = KENTRY
        END IF
C
C
C
 9999 CONTINUE
C
      IF(IBUG.NE.0) THEN
        IF(KENTRY.EQ.1) THEN
          WRITE(LUBUG,5003) PAKTIM50(TIM50),POS,VEL,IERR,LUACTIVE
 5003     FORMAT(/,' GETEPH RETURNING. TIME=',G20.12/,
     *         '   POS=',3G16.7/,'   VEL=',3G16.7/,
     *         '   IERR=',I3,'  LUACTIVE=',<MAXEPH>I4)
          END IF
        IF(KENTRY.EQ.2) THEN
          WRITE(LUBUG,5004)
     *       1,PAKTIM50(HEADINFO(1)),HEADINFO(2),HEADINFO(3),
     *       4,HEADINFO(4)*DEGRAD,HEADINFO(5)*DEGRAD,HEADINFO(6)*DEGRAD,
     *       7,HEADINFO(7)*DEGRAD,HEADINFO(8)*DEGRAD,
     *            PAKTIM50(HEADINFO(9)),
     *      10,PAKTIM50(HEADINFO(10)),HEADINFO(11),HEADINFO(12),
     *       (I,(HEADINFO(J),J=I,I+2),I=13,NHINFO,3)
 5004     FORMAT(/,' GETEPH(GETEPHD) RETURNING HEADER INFO:'/,
     *      999(T5,I3,') ',3G20.12/) )
          WRITE(LUBUG,5005) IERR,LUACTIVE
 5005     FORMAT('   IERR=',I3,'  LUACTIVE=',<MAXEPH>I4)
          END IF
        END IF
C
      RETURN
      END
