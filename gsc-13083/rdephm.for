      SUBROUTINE RDEPHM(REQTIM,POSVCT,VELVCT,IERR,IERPNT,
     *             POSBUF,VELBUF,R8V,I4V)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C PROGRAM NAME
C     RDEPHM
C
C PURPOSE
C     RETRIEVE EPHEMERIS VECTORS
C
C********************************************************************
C
C  USAGE.....
C
C    1. THE USER DEFINES THE FOLLOWING IN THE CALLING PROGRAM...
C
C         REAL*8 POSVCT(3),VELVCT(3)
C         REAL*8 POSBUF(3,100),VELBUF(3,100),R8V(62)
C         INTEGER*4 I4V(6)
C
C    2. BEFORE THE FIRST CALL TO RDEPHM, THE USER SET VALUES
C       IN ELEMENTS 12 AND 13 OF R8V AND ELEMENTS 1, 2, AND 3 OF
C       I4V. I4V(3) SHOULD BE SET TO ZERO TO GUARANTEE THAT THE
C       ARRAYS ARE INITIALIZED ON THE FIRST CALL. THESE ARRAYS ARE
C       DESCRIBED BELOW WITH THE OTHER CALLING SEQUENCE ITEMS.
C
C    3. REQTIM IS INPUT, POSVCT AND VELVCT ARE OUTPUT. AFTER THE
C       RETURN, POSBUF, VELBUF, R8V, AND I4V ARE AVAILABLE IN THE
C       CALLER FOR USE THERE IF THEY ARE OF INTEREST THERE, BUT NO
C       MODIFICATION OF THEIR CONTENTS SHOULD BE DONE.
C
C***********************************************************************
C
C METHOD
C
C   1. FOR THE FIRST OR A REINITIALIZATION(I4V(3)=0) CALL, RDEPHM READS
C      THE FIRST RECORD AND EXTRACTS PERTINENT DATA FOR SUBSEQUENT
C      USE. IF NOT A FIRST OR REINITIZATION CALL, THIS STEP IS BYPASSED.
C
C   2. THE ROUTINE CHECKS WHETHER THE TIME FOR WHICH DATA IS WANTED IS
C      WITHIN THE TIME INTERVAL COVERED BY THE FILE. IF SO, IT
C      CONTINUES. IF NOT, IT WRITES AN ERROR MESSAGE AND RETURNS.
C
C   3. THE ROUTINE CHECKS WHETHER THE TIME FOR WHICH DATA IS WANTED IS
C      WITHIN THE TIME INTERVAL COVERED BY THE CURRENT BUFFER CONTENTS. 
C      IF SO, IT CONTINUES.  IF NOT, IT FINDS AND READS THE RECORD
C      CONTAINING THE DESIRED VECTOR AND LOADS THE POSITION AND
C      VELOCITY BUFFERS.
C
C   4. WE NOW KNOW THAT THE TIME FOR WHICH EPHEMERIS INFORMATION IS
C      WANTED IS WITHIN THE TIME SPAN COVERED BY THE BUFFERS. THE
C      ROUTINE INTERPOLATES TO GET THE DATA AT THE DESIRED TIME.
C      INTERPOLATION IS DONE BY CALLING SUBROUTINE INTRP0 TO PERFORM A
C      N-POINT HERMITE INTERPOLATION.
C
C   5. RDEPHM RETURNS THE DESIRED VECTOR SCALED TO USER SPECIFICATION.
C
C++++++++++++++++++++++++++ CALLING SEQUENCE +++++++++++++++++++++++++++
C
C     CALL RDEPHM(REQTIM,POSVCT,VELVCT,IERR,POSBUF,VELBUF,R8V,I4V)
C
C     VARIABLE (IN/OUT, TYPE, DIMENSION)
C
C     REQTIM (INPUT,R8,1)   - TIME IN SECONDS FROM EPOCH OF REQUESTED
C                             POSITION AND VELOCITY VECTOR. THE EPOCH
C                             TIME IS GIVEN IN R8V(14) DESCRIBED BELOW.
C                             IF REQTIM='ZZZZZZZZ', THEN THE HEADER
C                             RECORDS ARE READ, R8V AND I4V ARE FILLED,
C                             POSBUF AND VELBUF ARE LOADED, BUT POSVCT
C                             AND VELVCT ARE NOT FILLED. THIS IS A WAY
C                             TO GET FILE INFO WITHOUT NEEDING A VALID
C                             TIME IN REQTIM.
C
C     POSVCT (OUTPUT,R8,3)  - POSITION COMPONENTS OF REQUESTED
C                             VECTOR(KM)
C
C     VELVCT (OUTPUT,R8,3)  - VELOCITY COMPONENTS OF REQUESTED
C                             VECTOR(KM/SEC)
C
C     IERR   (OUTPUT,I4,1)  - ERROR CONDITION INDICATOR:
C                             =0, NO ERROR OCCURRED
C                             =1, I/O ERROR IN READING EPHEMERIS FILE
C                             =2, REQUESTED VECTOR NO ON EPHEMERIS FILE
C                             =3, END OF FILE REACHED ON EPHEMERIS FILE
C
C     IERPNT (INPUT,I4,1)   - FORTRAN UNIT NUMBER FOR ERROR MESSAGES.
C                             =0 MEANS GIVE NO ERROR MESSAGES.
C
C  THE FOLLOWING VARIABLES ARE USED UPON REENTRY:
C
C     POSBUF (INOUT,R8,3,100)- BUFFER CONTAINING POSITION DATA FROM
C                              TWO CONCURRENT EPHEMERIS RECORDS
C
C     VELBUF (INOUT,R8,3,100)- BUFFER CONTAINING VELOCITY DATA FROM
C                              TWO CONCURRENT EPHEMERIS RECORDS
C
C     R8V    (INOUT,R8,62)  - REAL*8 STORAGE ARRAY REFLECTING THE
C                             STATUS OF POSITION AND VELOCITY BUFFERS
C                             
C                             REQTIM IS REFERENCED TO EPOCH AND EPOCH
C                             IS REFERENCED TO 1/1/62 AT 0.0 HRS.
C                             R8V(1) AND R8V(2) GIVE ELAPSED TIME FROM
C                             1/1/62, 0.0 HRS, TO EPOCH.
C
C     (1)                     REFERENCE SECONDS FOR EPHEMERIS FILE
C                             THIS IS THE NUMBER OF SECONDS ELAPSED
C                             BETWEEN MIDNIGHT OF THE DAY ON WHICH
C                             EPOCH OCCURS AND EPOCH.
C     (2)                     REFERENCE DAYS FOR EPHEMERIS FILE
C                             THIS IS THE NUMBER OF DAYS ELAPSED 
C                             BETWEEN 1/1/62, 0.0 HRS, AND 0.0 HRS OF
C                             THE DAY ON WHICH EPOCH OCCURS.
C     (3)                     TIME BETWEEN DATA POINTS(SEC)
C     (4)                     TIME BETWEEN RECORDS(SEC)
C     (5)                     EFFECTIVE START TIME OF FILE(SEC)
C                             MEASURED FROM EPOCH.
C     (6)                     EFFECTIVE END TIME OF FILE(SEC)
C                             MEASURED FROM EPOCH.
C     (7)                     TIME ADJUSTMENT FOR FRONT END ON INTER-
C                             POLATION SCHEME(SEC)
C     (8)                     TIME ADJUSTEMENT FOR BACK END OF INTER-
C                             POLATION SCHEME
C     (9)                     EFFECTIVE START TIME OF THIS BUFFER(SEC)
C     (10)                    EFFECTIVE END TIME OF THIS BUFFER(SEC)
C     (11)                    REFERENCE TIME OF BUFFER(SEC)
C     (12)                  * SCALING FACTOR FOR POSITION COMPONENTS
C                             (=1.D0 MEANS KILOMETERS OUTPUT)
C     (13)                  * SCALING FACTOR FOR VELOCITY COMPONENTS
C                             (=1.D0 MEANS KM/SEC OUTPUT)
C     (14)                    FULL JULIAN DATE OF EPOCH.
C     (15-21)                 EPOCH CONDITIONS. KEPLERIAN. ORDER IS ---
C                             A, E, I, N, W, MA, TA. (KM, RADIANS).
C     (22-41)                 AUXILIARY PARAMETERS. SAME DESCRIPTION AS
C                             FOR THE AUXPARM ARRAY DESCRIBED BELOW.
C                             R8V(21+I) = AUXPARM(I).
C     (42-48)                 GRAVITY PARAMETERS. SAME DESCRIPTION AS
C                             FOR THE GRAVPARM ARRAY DESCRIBED BELOW.
C                             R8V(41+I) = GRAVPARM(I).
C     (49-62)                 DRAG PARAMETERS. SAME DESCRIPTION AS
C                             FOR THE DRAGPARM ARRAY DESCRIBED BELOW.
C                             R8V(48+I) = DRAGPARM(I).
C
C     I4V    (INOUT,I4,6)   - INTEGER*4 STORAGE ARRAY REFLECTING
C                             STATUS OF POSITION AND VELOCITY BUFFERS
C     (1)                   * EPHEMERIS FILE UNIT NUMBER USED THIS CALL
C     (2)                   * NUMBER OF POINTS USED BY INTERPOLATOR
C     (3)                   * RESTART FLAG:
C                             =0, RESTART REQUESTED
C                             =1, RESTART NOT REQUESTED (NORMALLY USED)
C     (4)                     EPHEMERIS FILE UNIT NUMBER USED PREV CALL 
C                             WHEN CURRENT R8V, I4V, POSBUF AND VELBUF
C                             WERE LOADED.
C     (5)                     NUMBER OF FRONT POINTS FROM PIVOT POINT
C     (6)                     NUMBER OF BACK POINTS FROM PIVOT POINT
C
C      *- THESE VALUES MUST BE INITIALLY DEFINED BY THE USER.
C
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C ORIGINATOR
C     J GARRAHAN,CSC
C
C MODIFICATIONS
C     2/81. C PETRUZZO.  ADDED COMMENTS AND R8V(14-21).
C           ADDED IERPNT AND ERROR MESSAGES.
C     5/81. C PETRUZZO.  BUG FIX ON VJD62 VALUE.
C                              DIMENSION CORRECTION ON R8V.
C                              MORE COMMENTS ADDED.
C    12/81. C PETRUZZO.  IMPROVED ERROR MESSAGE FOR INVALID REQTIM.
C     1/83. C PETRUZZO.  IMPROVED ERROR MESSAGE FOR END-FILE ERROR.
C     5/85. C PETRUZZO.  ADDED R8V(22-62), ASSOCIATED ARRAYS GRAVPARM,
C                        DRAGPARM, AND AUXPARM. CODE CLEANUP PERMITTED
C                        BY THE FACT THAT THE VAX BACKSPACE IS REALLY
C                        A REWIND AND READ FORWARD.
C    11/85. C PETRUZZO.  MORE CLEANUP. INSERTED REWIND/READ-FORWARD
C                        CODE THAT SHOULD HAVE BEEN DONE 5/85.
C     3/87. C PETRUZZO.  COMMENT CORRECTION.
C
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
      DIMENSION R(3),V(3),POSVCT(3),VELVCT(3)
      DIMENSION POSBUF(3,100),VELBUF(3,100)
      DIMENSION R8V(62),I4V(6)
      DATA DULKM/1.0D-4/, DULKMS/864.0D-4/
      REAL*8 VJD62/2437665.5D0/,HEADER/'ZZZZZZZZ'/,SECDAY/86400.D0/,
     *       VJD50/2433282.5D0/
      INTEGER MAXERR/50/,NUMERR/0/
      LOGICAL INITCALL,DONEWHILE
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
C     14) FORTRAN UNIT NUMBER USED BY EPHEMGEN PGM FOR ATTITUDE DATA 
C
      PARAMETER NAUXIL=20     ! NUMBER OF AUXILIARY PARAMETERS
      REAL*8 AUXPARM(NAUXIL)
C
C     AUXPARM CONTENTS:
C      1) YYMMDD.HHMMSS OBTAINED FROM COMPUTER CLOCK WHEN FILE WAS MADE
C      2) COORDINATE SYSTEM ID. 1=M50, 2=MDT, 3=TOD
C      3) THE VALUE THAT THE EPHEM FILE WRITER EXPECTED THE READER TO
C         USE FOR THE NTITLE VALUE SET BELOW.
C      4) THE VALUE THAT THE EPHEM FILE WRITER EXPECTED THE READER TO
C         USE FOR THE NGRAV VALUE SET ABOVE.
C      5) THE VALUE THAT THE EPHEM FILE WRITER EXPECTED THE READER TO
C         USE FOR THE NDRAG VALUE SET ABOVE.
C      6) THE VALUE THAT THE EPHEM FILE WRITER EXPECTED THE READER TO
C         USE FOR THE NAUXIL VALUE SET ABOVE.
C      7-20) NOT USED
C
C NTITLE IS THE LENGTH OF USEFUL PART OF THE HEADER ARRAY WRITTEN BY
C EPHFILE.
C
      PARAMETER NTITLE= 56 + NGRAV + NDRAG + NAUXIL
C
C THE HEADER RECORD IS LONGER THAN NTITLE R*8 WORDS, BUT WE NEED
C ONLY NTITLE OF THEM
C
      DIMENSION BUF(NTITLE)
C
C
C
      IBUG = 0
      LUBUG = 19
C
      IF(IBUG.NE.0) WRITE(LUBUG,4341) I4V(1),I4V(3),I4V(4),REQTIM,
     *      REQTIM
 4341 FORMAT(/,' ****** RDEPHM DEBUG. STARTING.',
     *              ' I4V(1),I4V(3),I4V(4)=',3I5/,
     *         '    REQTIM(SEC)=',G13.5,'  REQTIM(ALPHA)=',A8)
C
C ********************
C *  INITIALIZATION  *
C ********************
C
C SET UP FOR ERROR MESSAGES.
      IERR=0
      IEROUT=IERPNT
      IF(NUMERR.GE.MAXERR) IEROUT=0
C
C SEE WHETHER WE NEED TO INITIALIZE R8V, I4V, AND BUFFERS.
      NFILE=I4V(1)
      INITCALL = I4V(3).EQ.0    .OR.
     *           I4V(4).NE.NFILE    .OR.    REQTIM.EQ.HEADER
C
C
C ****************************
C *  INITIALIZE R8V AND I4V  *
C ****************************
C
      IF( .NOT.INITCALL) GO TO 25
C
      I4V(3) = 1  ! TURNS OFF THIS INITIALIZATION FLAG FOR NEXT CALL.
C
C CLEAR PARTS OF R8V AND I4V.
C
      CALL MTXSETR8(R8V,0.D0,11,1)
      CALL MTXSETR8(R8V(14),0.D0,49,1)    ! 14 -> 62
      I4V(5)=0
      I4V(6)=0
C
C READ FILE DIRECTORY
C
      I4V(4)=NFILE
      REWIND NFILE
      READ(NFILE,ERR=15) BUF
C
C EXTRACT, CONVERT, AND INITIALIZE DESIRED DATA
C
C    SET R8V TIME INFO.
      EPYMD = BUF(44)*10000.0D0 + BUF(45)*100.0D0 + BUF(46)
      EPSEC = BUF(47)*3600.0D0 +  BUF(48)*60.0D0 +  BUF(49)/1000.0D0
      EPSEC50 = SINCE50(EPYMD) + EPSEC
      YMD1 = BUF(4)
      SEC1 = BUF(6)
      YMD2 = BUF(7)
      SEC2 = BUF(9)
      R8V(1) = EPSEC
      R8V(2) = ( SINCE50(EPYMD) - SINCE50(620101.D0) )/86400.D0
      R8V(3) = BUF(10)
      R8V(4) = R8V(3) * 50.D0
      R8V(5) = SINCE50(YMD1) + SEC1 - EPSEC50  ! ADJUSTED BELOW
      R8V(6) = SINCE50(YMD2) + SEC2 - EPSEC50  ! ADJUSTED BELOW
      IF(IBUG.NE.0) WRITE(LUBUG,4349) YMD1,SEC1,YMD2,SEC2,
     *    R8V(5),R8V(6),EPYMD,EPSEC,PAKTIM50(EPSEC50)
 4349 FORMAT(/,' RDEPHM DEBUG 4349.'/,
     *         '  YMD1,SEC1=',2G20.13/,
     *         '  YMD2,SEC2=',2G20.13/,
     *         '  R8V(5),R8V(6)(PRE-ADJUSTMENT)=',2G15.7/,
     *         '  EPYMD,EPSEC,PAKTIM50(EPSEC50)=',2G14.6,G21.13)
C
C    SET INTERPOLATION PARAMETERS. ADJUST EFFECTIVE START/STOP TIME TO
C    ACCOMMODATE INTERPOLATION.
      I4V(5) = I4V(2) / 2
      I4V(6) = I4V(2) - I4V(5)
      R8V(7) = I4V(5) * R8V(3)
      R8V(8) = I4V(6) * R8V(3)
      R8V(5) = R8V(5) + R8V(7)
      R8V(6) = R8V(6) - R8V(8)
C
C    SET R8V(9) AND R8V(10) SO THAT THE BEFORE/WITHIN/AFTER TEST BELOW
C    CAUSES KLOC=-1 TO BE SET.
      R8V( 9) = 1.D30
      R8V(10) = 1.D30
C
C    LOAD EPOCH TIME AND ELEMENTS INTO R8V.
      R8V(14) = VJD62 + R8V(2) + R8V(1)/SECDAY
      R8V(15) = BUF(50)
      R8V(16) = BUF(51)
      R8V(17) = BUF(52)
      R8V(18) = BUF(54)
      R8V(19) = BUF(53)
      R8V(20) = BUF(55)
      R8V(21) = BUF(56)
C
C    LOAD AUXPARM, GRAVPARM, DRAGPARM. CODED THIS WAY TO MORE CLEARLY
C    ILLUSTRATE HOW THIS HEADER INFO GETS FROM THE BUF ARRAY INTO R8V.
      INDX1 = NTITLE - NGRAV - NDRAG - NAUXIL + 1
      CALL MTXEQL(BUF(INDX1),AUXPARM,NAUXIL,1)
      INDX1 = INDX1 + NAUXIL
      CALL MTXEQL(BUF(INDX1),GRAVPARM,NGRAV,1)
      INDX1 = INDX1 + NGRAV
      CALL MTXEQL(BUF(INDX1),DRAGPARM,NDRAG,1)
C
C    LOAD  R8V FROM AUXPARM, GRAVPARM, DRAGPARM.
      INDX2 = 22
      CALL MTXEQL(AUXPARM,R8V(INDX2),NAUXIL,1)
      INDX2 = INDX2 + NAUXIL
      CALL MTXEQL(GRAVPARM,R8V(INDX2),NGRAV,1)
      INDX2 = INDX2 + NGRAV
      CALL MTXEQL(DRAGPARM,R8V(INDX2),NDRAG,1)
C
C
      IF(IBUG.NE.0) THEN
        INDX1END = INDX1 + NDRAG - 1
        WRITE(LUBUG,8601) 'BUF',INDX1END,
     *     (I,(BUF(J),J=I,I+2),I=1,INDX1END,3)
        INDX2END = INDX2 + NDRAG - 1
        WRITE(LUBUG,8601) 'R8V',INDX2END,
     *     (I,(R8V(J),J=I,I+2),I=1,INDX2END,3)
 8601   FORMAT(/,
     *    ' RDEPHM DEBUG. HEADER INFO:  NUM OF ELEMS FOR ',A' =',I3,
     *        '  CONTENTS='/,(T5,I3,') ',3G21.13))
        END IF
C
C ERROR CHECK. 
C
      KTITLE=  JIDNNT(AUXPARM(3))
      KGRAV =  JIDNNT(AUXPARM(4))
      KDRAG =  JIDNNT(AUXPARM(5))
      KAUXIL = JIDNNT(AUXPARM(6))
      IF(KGRAV.NE.NGRAV .OR. KDRAG.NE.NDRAG .OR. KAUXIL.NE.NAUXIL  .OR.
     *      KTITLE.NE.NTITLE) THEN
C      INCONSISTENCY BETWEEN HEADER WRITER(EPHFILE) AND WHAT THIS READER
C      EXPECTS.
        STOP ' RDEPHM. ERROR END 1. SEE CODE.'
        END IF
C
C
C IF REQTIM='ZZZZZZZZ', THEN THIS CALL WAS FOR LOADING ARRAYS, NOT FOR
C PRODUCING POS/VEL VALUES. EXIT.
C
      IF(REQTIM.EQ.HEADER) GO TO 9999
C
   25 CONTINUE
C
C
C *****************************************************************
C *  LOAD POSITION AND VELOCITY BUFFERS NEEDED FOR INTERPOLATION  *
C *****************************************************************
C
C VERIFY THAT REQUESTED DATA TIME IS IN THE FILE'S EFFECTIVE TIME SPAN
C
      IF((REQTIM .LT. R8V(5)) .OR. (REQTIM .GT. R8V(6))) GO TO 95
C
C INITIALIZE VARIABLES
C
      T1FILE = R8V(5) - R8V(7)   ! TIME FOR FIRST BUFFER, FIRST ELEMENT
      T2FILE = R8V(6) + R8V(8)   ! TIME FOR LAST BUFFER, LAST VALID DATA
      EPSEC50 = (R8V(14) - VJD50) * 86400.D0
      TIM01 = R8V(11)            ! TIME FOR CURRENT BUFFER, 1'ST ELEM
      TIM51 = TIM01 + R8V(4)     ! TIME FOR CURRENT BUFFER, 51'ST ELEM
      IF(IBUG.NE.0) WRITE(LUBUG,4348) T1FILE,T2FILE,EPSEC50/86400.D0,
     *       R8V(11)
 4348 FORMAT(/,' RDEPM DEBUG. T1FILE,T2FILE=',2G16.8/,
     *         '    EPSEC50(DAYS)=',G15.8,'  R8V(11)=',G15.8)
C
C    SET NUMREAD COUNTER FOR POSSIBLE USE IN ERROR MESSAGE. NUMREAD IS
C    THE NUMBER OF THE MOST RECENTLY READ RECORD.
      IF(R8V(10).LT.1.D29) THEN  ! NOT FIRST EXECUTION AFTER INIT'LZN
C      KTEMP = BUFFER END TIME'S STEP NUMBER FROM ACTUAL FILE START TIME
        KTEMP = ( (R8V(10)+R8V(8)) - (R8V(5)-R8V(7)) ) / R8V(3) + 1.1D0
        NUMREAD = ( KTEMP + 49) / 50 + 2   ! ADD 2 FOR 2 HEADERS
        IF(IBUG.NE.0) WRITE(LUBUG,4359) R8V(10),R8V(8),R8V(5),R8V(7),
     *       R8V(3),KTEMP,NUMREAD
 4359   FORMAT(/,' RDEPHM DEBUG 4359. HAVE COMPUTED NUMREAD.'/,
     *           '    R8V(10),R8V(8)=',2G15.7/,
     *           '    R8V( 5),R8V(7)=',2G15.7/,
     *           '    R8V( 3)=',G15.7,'  KTEMP,NUMREAD=',2I5)
      ELSE
        NUMREAD = 1  ! HAVE READ ONE HEADER RECORD DURING INITIALIZATION
        END IF
C
C    SET KLOC FLAG INDICATING WHETHER REQTIM IS BEFORE, WITHIN, OR AFTER
C    THE EFFECTIVE TIME SPAN OF THE CURRENT BUFFER
      IF(REQTIM.LT.R8V(9)) KLOC = -1                         ! BEFORE
      IF(R8V(9).LE.REQTIM .AND. REQTIM.LE.R8V(10))  KLOC = 0 ! WITHIN 
      IF(R8V(10).LT.REQTIM) KLOC = 1                         ! AFTER
C
      IF(IBUG.NE.0) WRITE(LUBUG,4342) KLOC,REQTIM,R8V(9),R8V(10),
     *       (REQTIM-R8V(9)),(REQTIM-R8V(10))
 4342 FORMAT(/,' RDEPHM DEBUG 4342.  KLOC=',I3/,
     *         '    REQTIM,R8V(9),R8V(10)=',3G14.6/,
     *         '    (REQTIM-R8V(9)),(REQTIM-R8V(10))=',2G14.6)
C
C    IF REQTIM BEFORE THE CURRENT BUFFER, REWIND THE FILE AND SKIP THE
C    TWO HEADER RECORDS. THE DO-WHILE LOOP WILL CAUSE RECORDS TO BE READ
C    UNTIL THE PROPER DATA IS IN THE BUFFERS. VAX BACKSPACE IS A REWIND
C    AND READ FORWARD, SO FANCY BACKSPACE LOGIC IS A WASTE OF TIME.
      IF(KLOC.EQ.-1) THEN
        REWIND NFILE
        NUMREAD = 0
        READ(NFILE,ERR=15) ! SKIP HEADER RECORD 1
        NUMREAD = 1
        READ(NFILE,ERR=15) ! SKIP HEADER RECORD 2
        NUMREAD = 2
C      LOAD POSBUF AND VELBUF WITH RECOGNIZABLE CONTENTS
        CALL MTXSETR8(POSBUF,HEADER,100,3)
        CALL MTXSETR8(VELBUF,HEADER,100,3)
        TIM01 = HEADER
        TIM51 = HEADER
        END IF
C
C    SET INDEX1, THE INDEX TELLING THE READ STATEMENT WHERE TO START
C    LOADING POSBUF AND VELBUF. IF KLOC=0, READ WILL NOT OCCUR.
      IF(KLOC.EQ.-1) INDEX1 =  1
      IF(KLOC.EQ.+1) INDEX1 = 51
C
C
C READ FORWARD UNTIL REQTIM FALLS WITHIN THE TIME SPAN OF THE BUFFERS.
C IF IT IS ALREADY WITHIN THE SPAN, THE DO-WHILE LOOP DOES NOT EXECUTE.
C
      DONEWHILE = KLOC.EQ.0
      DO WHILE ( .NOT.DONEWHILE )
C
        IF(INDEX1.EQ.51) THEN
C        THE IDEA HERE IS TO HAVE THE 100 ELEMENTS OF THE POSBUF AND
C        VELBUF ARRAYS CONTAIN THE CONTENTS OF TWO SUCCESSIVE EPHEM FILE
C        RECORDS. WE WILL READ DATA INTO THE SECOND 50, SO SHIFT THE
C        CONTENTS OF THE SECOND 50 TO THE FRONT OF THE BUFERS. IF THE
C        SECOND HALF HAS NOT BEEN LOADED YET, DO NOT SHIFT.
          IF(POSBUF(1,51).NE.HEADER) THEN
            CALL MTXEQL(POSBUF(1,51),POSBUF(1,1),3,50)
            CALL MTXEQL(VELBUF(1,51),VELBUF(1,1),3,50)
            TIM01 = TIM51  ! FIRST ELEMENT'S TIME TAG. FOR ERROR CHECK.
            END IF
          END IF
C
C      READ THE NEXT RECORD
        READ(NFILE,ERR=15,END=35) YMD,TD,TS,DUM,
     *    ( POSBUF(1,I),POSBUF(2,I),POSBUF(3,I),
     *      VELBUF(1,I),VELBUF(2,I),VELBUF(3,I), I=INDEX1,INDEX1+49)
        NUMREAD = NUMREAD+1
        IF(IBUG.NE.0) WRITE(LUBUG,4345) NUMREAD,YMD,TS,INDEX1
 4345   FORMAT(/,' RDEPHM DEBUG 4345. NUMREAD=',I4/,
     *           '    YMD=',G18.10,'  TS=',G14.6,'  INDEX1=',I2)
C
C      SET EARLIEST AND LATEST TIMES FOR THIS BUFFER.
        TIMREF = (SINCE50(YMD) + TS) - EPSEC50  ! 1'ST OR 51'ST TIME
        R8V( 9) = DMAX1(T1FILE,TIMREF-R8V(4))
        R8V(10) = DMIN1(T2FILE,TIMREF+R8V(4)-R8V(3))
        R8V(11) = R8V(9)
        IF(INDEX1.EQ.01) TIM01 = TIMREF  ! TIME TAG FOR ERROR CHECK
        IF(INDEX1.EQ.51) TIM51 = TIMREF  ! TIME TAG FOR ERROR CHECK
C
C      SET BUFFER EFF START/STOP TIMES TO ACCOMMODATE INTERPOLATION.
        R8V( 9) = R8V( 9) + R8V(7)
        R8V(10) = R8V(10) - R8V(8)
C
        IF(IBUG.NE.0) WRITE(LUBUG,4346) 
     *    TIMREF,R8V(9),R8V(10),R8V(11),TIM01,TIM51,
     *    (POSBUF(I,  1),I=1,3),(VELBUF(I,  1),I=1,3),
     *    (POSBUF(I, 50),I=1,3),(VELBUF(I, 50),I=1,3),
     *    (POSBUF(I, 51),I=1,3),(VELBUF(I, 51),I=1,3),
     *    (POSBUF(I,100),I=1,3),(VELBUF(I,100),I=1,3)
 4346   FORMAT(/,' RDEPHM DEBUG 4346. TIMREF=',G14.6/,
     *           '   R8V(9-11)=',3G15.7/,
     *           '   TIM01=',G15.7,'  TIM51=',G15.7/,
     *           '   POSBUF(-,  1)=',3G14.6/,
     *           '   VELBUF(-,  1)=',3G14.6/,
     *           '   POSBUF(-, 50)=',3G14.6/,
     *           '   VELBUF(-, 50)=',3G14.6/,
     *           '   POSBUF(-, 51)=',3G14.6/,
     *           '   VELBUF(-, 51)=',3G14.6/,
     *           '   POSBUF(-,100)=',3G14.6/,
     *           '   VELBUF(-,100)=',3G14.6)
C
C      DO ERROR CHECK TO VERIFY THAT THE TIME TAGS FOR THE 1'ST AND
C      51'ST ELEMENTS ARE 50 TIME STEPS APART. AN ERROR CAN OCCUR IF
C      THE APPLICATION PROGRAM ISSUES A READ STATEMENT TO THE EPHEM
C      FILE OUTSIDE OF THIS ROUTINE. THIS ROUTINE WILL STOP THE
C      PROGRAM SINCE DIRECT READING OF THE FILE SHOULD OCCUR ONLY IN
C      THIS ROUTINE.
        IF(INDEX1.EQ.51) THEN
          TEMP = DABS( (TIM51-TIM01) - R8V(4) )
          IF( TEMP .GT. R8V(3)*1.D-3 )
     *       STOP ' RDEPHM. ERROR END 2. SEE SOURCE CODE.'
          END IF
C      
C      SET UP FOR POSSIBLE LOOP THROUGH THIS DO-WHILE CODE AGAIN
        INDEX1 = 51
        DONEWHILE = R8V(9).LE.REQTIM .AND. REQTIM.LE.R8V(10)
        END DO
C
C
C *************************
C *  INTERPOLATE ON DATA  *
C *************************
C
C COMPUTE PIVOT POINT WITHIN BLOCK
C
C    SET N SUCH THAT REQTIM FALLS BETWEEN N'TH AND N+1'TH BUFFER TIMES
      N = (REQTIM-R8V(11))/R8V(3) + 1
C    SET AN, THE TIME FOR THE N'TH BUFFER ELEMENT
      AN = R8V(11) + DFLOAT(N-1)*R8V(3)
C    SET AT, THE TIME DIFFERENCE FROM N'TH BUFFER ELEMENT AND REQTIM
      AT = REQTIM-AN
C
      L1 = 3
      K1 = N+I4V(6)
      N1 = I4V(2)
      T1 = AT-I4V(6)*R8V(3)
C
      IF(IBUG.NE.0) WRITE(LUBUG,4347) AN,AT,N, L1,K1,N1,T1,
     *      (J,(POSBUF(I,J)/DULKM,I=1,3),J=N,N+3),
     *      (J,(VELBUF(I,J)/DULKMS,I=1,3),J=N,N+3)
 4347 FORMAT(/,' RDEPHM DEBUG 4347.  AN,AT,N= ',2G13.5,I4/,
     *         '     L1,K1,N1,T1=',3I5,G13.5/,
     *         4('     POSBUF(-,',I3,')/DULKM= ',3G14.6/),
     *         4('     VELBUF(-,',I3,')/DULKMS=',3G14.6/) )
C
      CALL INTRP0(POSBUF,VELBUF,K1,L1,R8V(3),N1,T1,R,V,DULKM,DULKMS)
C
C
C **********************************
C *  CONVERT DATA TO OUTPUT UNITS  *
C **********************************
C
C
      DO I=1,3
        POSVCT(I) = R(I)*R8V(12)
        VELVCT(I) = V(I)*R8V(13)
        END DO
      IF(IBUG.NE.0) WRITE(LUBUG,4357) POSVCT,VELVCT
 4357 FORMAT(/,' RDEPHM DEBUG 4357.'/,
     *         '    POSVCT=',3G15.7/,
     *         '    VELVCT=',3G15.7)
      GO TO 9999
C
C
C **************************
C *  ERROR INTERPRETATION  *
C **************************
C
C
C    I/O ERROR  READING EPHEM FILE
   15 CONTINUE
      IERR = 1
      IF(IEROUT.NE.0) WRITE(IEROUT,5001) NFILE,NUMREAD+1
 5001 FORMAT(//,1X,60('*')//,
     *       ' RDEPHM. EPHEM FILE READ ERROR. FORTRAN UNIT=',I3/,
     *       ' ERROR OCCURRED WHEN TRYING TO READ RECORD NUMBER ',I3/,
     *       ' (RECORDS 1 AND 2 ARE HEADERS, 3-END ARE POS/VEL DATA)'//,
     *       1X,60('*')/)
      GO TO 5005
C
C    REQUESTED DATA NOT AVAILABLE
   95 CONTINUE
      IERR = 2
      IF(IEROUT.NE.0) WRITE(IEROUT,5002) NFILE,
     *    PAKTIM(R8V(14)+REQTIM/SECDAY),PAKTIM(R8V(14)+R8V(5)/SECDAY),
     *    PAKTIM(R8V(14)+R8V(6)/SECDAY),PAKTIM(R8V(14))
 5002 FORMAT(//,1X,60('*')//,
     *    ' ERROR IN USING EPHEM FILE.(FORTRAN UNIT=',I3,').'/,
     *    ' TIME WANTED IS NOT AVAILABLE.    TIME WANTED=',F13.6/,
     *    ' EARLIEST/LATEST USABLE TIMES =',2F15.6/,
     *    ' EPOCH=',F13.6//,
     *          1X,60('*')/)
      GO TO 5005
C
C    END OF EPHEM FILE REACHED
   35 CONTINUE
      IERR = 3
      IF(IEROUT.NE.0) THEN
        WRITE(IEROUT,5013)
        IF(REQTIM.NE.'ZZZZZZZZ') THEN
          EPSEC50 = ( R8V(14)-VJD50 ) * 86400.D0
          TSTART = PAKTIM50( EPSEC50 + R8V(5) - R8V(7) )
          TSTOP =  PAKTIM50( EPSEC50 + R8V(6) + R8V(8) )
          WRITE(IEROUT,5003) NFILE,NUMREAD+1,
     *             PAKTIM(R8V(14)+REQTIM/SECDAY),TSTART,TSTOP
        ELSE 
          TEMP1 = R8V(5)-R8V(7)
          TEMP2 = R8V(6)+R8V(8)
          NUMREC = ( JIDINT( (TEMP2-TEMP1)/R8V(3)+1.5D0 ) + 49) / 50
          WRITE(IEROUT,5023) NFILE,NUMREAD+1,NUMREC,NUMREAD+1,NUMREAD+3
          END IF
        WRITE(IEROUT,5013)
        END IF
 5013 FORMAT(/,1X,75('*')/)
 5003 FORMAT(' RDEPHM. EPHEM FILE ERROR. FORTRAN UNIT=',I4/,
     *      ' END OF FILE FOUND WHILE LOOKING FOR A TIME THAT WAS'/,
     *      ' SUPPOSED TO BE ON THE FILE. HEADER RECORD SAID THAT THE'/,
     *      ' TIME WAS PRESENT. PROBABLE ERROR IN FILE GENERATION.'//,
     *      ' END FILE OCCURRED WHILE TRYING TO READ RECORD NUMBER',I3/,
     *      ' TIME WANTED = ',F13.6/,
     *      ' START/END TIMES WERE SUPPOSED TO BE ',2F15.6)
 5023 FORMAT(' RDEPHM. EPHEM FILE ERROR. FORTRAN UNIT=',I4/,
     *      ' END FILE TRYING TO READ POS/VEL RECORD ',I1,
     *      '. FILE SHOULD HAVE ',I3,' RECORDS.'/,
     *      ' POS/VEL RECORD ',I1,' IS FILE RECORD ',I1,'.')
      GO TO 5005
C
C
C    INCREMENT THE ERROR MESSAGE COUNTER.
 5005 CONTINUE
      IF(IERPNT.NE.0) NUMERR = NUMERR+1
      IF(NUMERR.EQ.MAXERR .AND. IERPNT.NE.0) WRITE(IERPNT,5006) 
 5006 FORMAT(//,' //////////////////  EPHEM FILE READER MESSAGE.'/, 
     *   '    MAXIMUM NUMBER OF ERROR MESSAGES HAVE BEEN PRINTED.'/,
     *   '    FUTURE ERRORS WILL GENERATE NO MESSAGES.'/)
C
C
 9999 CONTINUE
      IF(IBUG.NE.0) WRITE(LUBUG,4356)
 4356 FORMAT(/,' ******* RDEPHM DEBUG. RETURNING.')
      RETURN
      END
