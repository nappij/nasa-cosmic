      SUBROUTINE RDCAT4(LUCATLG,
     *    NTARGS,KTARGID,TARGNAMES,KTARGTYP,MAXPARM,TARGPARM,
     *    LUPRINT)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS IS A SERVICE ROUTINE FOR THE TARGET CATALOGUE READER. IT PRINTS
C INFO BEING RETURNED BY THE READER. OUTPUT FORMAT IS CRUDE BUT USEFUL.
C
C***********************************************************************
C
C BY C PETRUZZO, GSFC/742, 12/84, 7/85.
C    MODIFIED.....
C
C***********************************************************************
C
      INCLUDE 'RDCAT.INC'
C
      REAL*8    TARGPARM(MAXPARM,1)
      INTEGER*4 KTARGID(1)
      INTEGER*4 KTARGTYP(1)
      CHARACTER*16 TARGNAMES(1)
      REAL*8 R8888/8888.D0/
      REAL*8 DEGRAD / 57.29577951308232D0 /
      CHARACTER*2 CH2TEMP,I4CHAR
      LOGICAL FIRSTCALL/.TRUE./
      REAL*8 DATA(MAXDATA)
      CHARACTER*10 OUTNAMES(MAXDATA)
C
      CHARACTER*10 OTHERS(MAXDATA)
      CHARACTER*10 PARMNAME(MAXDATA,MAXTYPE)/
     *   NOTREQ01*'NULL',
     *   'LAT =', 'LONG =', 'ALT =','SPH-FLAG =', NOTREQ02*'NULL',
     *   'RACN =', 'DECL =', ' (IGNORE)=', NOTREQ03*'NULL',
     *   'AZ =', 'EL =', NOTREQ04*'NULL',
     *   NOTREQ05*'NULL',
     *   'AZ =', 'ALT =', 'SPH-FLAG =', NOTREQ06*'NULL',
     *   NOTREQ07*'NULL',
     *   NOTREQ08*'NULL'/
C
C    NAMES FOR TARGET TYPE 7 PARAMETERS. THREE CASES ARE POSSIBLE:
C    1 - NO INFO;  2 - INITIAL CONDS SUPPLIED; 3 - EPHEM FILE USED
      CHARACTER*10 NAME7(MAXDATA,3)
      EQUIVALENCE (NAME7(1,1),NAME7A(1)), (NAME7(1,2),NAME7B(1)),
     *            (NAME7(1,3),NAME7C(1))
      PARAMETER KREM7A = MAXDATA - 1,
     *          KREM7B = MAXDATA - 10,
     *          KREM7C = MAXDATA - 2
      CHARACTER*10 NAME7A(MAXDATA)/
     *    'SOURCE =', KREM7A*'NULL'/
      CHARACTER*10 NAME7B(MAXDATA) /
     *    'SOURCE =',  'COORD =',   'EPOCH =',  'KEPL/CART=',
     *    'X/SMA =',   'Y/ECC =',   'Z/INCL=',
     *    'XD/NODE =', 'YD/ARGP =', 'ZD/MA =',
     *    KREM7B*'NULL'/
      CHARACTER*10 NAME7C(MAXDATA)/
     *    'SOURCE =', 'EPH FILE =', KREM7C*'NULL'/
C
C
      IBUG = 0
      LUBUG = 19
C
C
C FIRST-CALL INITIALIZATION
C
      IF(FIRSTCALL) THEN
        FIRSTCALL = .FALSE.
C      LOAD THE OTHERS ARRAY. (LOAD WITH OTHER-01, OTHER-02, ....)
        DO I=1,MAXDATA
          CH2TEMP = I4CHAR(I,2,KDUM)
          IF(CH2TEMP(1:1).EQ.' ') CH2TEMP(1:1) = '0'
          OTHERS(I) = 'OTHER-' // CH2TEMP // ' ='
          END DO
C      LOAD THE PARMNAMES ELEMENTS THAT HAVE BEEN INITIALIZED TO 'NULL'
        DO ITYPE=1,MAXTYPE
          INDEX = 0
          DO IDATA=1,MAXDATA
            IF(PARMNAME(IDATA,ITYPE).EQ.'NULL') THEN
              INDEX = INDEX + 1
              PARMNAME(IDATA,ITYPE) = OTHERS(INDEX)
              END IF
            END DO
          END DO
C      SPECIAL CODE FOR TARGET TYPE 7.
        DO ICASE=1,3
          INDEX = 0
          DO IDATA=1,MAXDATA
            IF(NAME7(IDATA,ICASE).EQ.'NULL') THEN
              INDEX = INDEX + 1
              NAME7(IDATA,ICASE) = OTHERS(INDEX)
              END IF
            END DO
          END DO
C
        IF(IBUG.NE.0) THEN
          WRITE(LUBUG,9001)
 9001     FORMAT(/,' RDCAT4. FIRST-CALL DEBUG.')
          DO ITYPE=1,MAXTYPE
            WRITE(LUBUG,9002) ITYPE,(PARMNAME(I,ITYPE),I=1,MAXDATA)
 9002       FORMAT(/,'    PARMNAME,  TYPE=',I2/,99(T5,10A11/) )
            END DO
          DO ICASE=1,3
            WRITE(LUBUG,9003) ICASE,(NAME7(I,ICASE),I=1,MAXDATA)
 9003       FORMAT(/,'    PARMNAME,  TYPE=7, ICASE=',I2/,99(T5,10A11/) )
            END DO
          END IF
C
          END IF
C
C
C THIS-CALL INITIALIZATION
C
      IERR = 0
      IUNIT = LUPRINT
      IF(LUPRINT.EQ.0 .AND. IBUG.NE.0) IUNIT = LUBUG
C
      IF(NTARGS.LE.0 .OR. IUNIT.LE.0) GO TO 9999
C
C
C WRITE HEADER LINES
C
      WRITE(IUNIT,8533) LUCATLG
 8533 FORMAT(//,
     *  '   TARGET CATALOGUE INFORMATION ',
     *    '(INFO FROM RDCAT4; CATALOGUE UNIT= ',I2,')'/)
      WRITE(IUNIT,8534)
 8534 FORMAT(
     *    T5,'  ID  ',T12,'NAME',T32,'TYPE',T37,'TARGET PARAMETERS'/,
     *    T5,'  --  ',T12,'----',T32,'----',T37,'-----------------'/)
C
C
C LOOP THROUGH THE TARGETS AND OUTPUT INFO FOR THOSE WITH POSITIVE ID'S
C
      DO 1200 ITARG = 1,NTARGS
      ID =    KTARGID(ITARG)
      IF(ID.LE.0) GO TO 1200    ! IGNORE NEGATIVE ID'S
C
      KTYPE = KTARGTYP(ITARG)
C
      IF(KTYPE.LT.0) THEN
        KSHOW = 0              ! ERROR CONDITION. SHOW NO TARGPARM INFO
        ASSIGN 5000 TO KFMT1
      ELSE
        KSHOW = 0            ! WILL SHOW FIRST THRU LAST NON-R8888 VALUE
C      ASSIGN THE FORMATS TO BE USED
        IF(KTYPE.EQ.1) THEN
          ASSIGN 5010 TO KFMT1
          ASSIGN 5110 TO KFMT2
        ELSE IF(KTYPE.EQ.2) THEN
          ASSIGN 5020 TO KFMT1
          ASSIGN 5120 TO KFMT2
        ELSE IF(KTYPE.EQ.3) THEN
          ASSIGN 5030 TO KFMT1
          ASSIGN 5130 TO KFMT2
        ELSE IF(KTYPE.EQ.4) THEN
          ASSIGN 5040 TO KFMT1
          ASSIGN 5140 TO KFMT2
        ELSE IF(KTYPE.EQ.5) THEN
          ASSIGN 5050 TO KFMT1
          ASSIGN 5150 TO KFMT2
        ELSE IF(KTYPE.EQ.6) THEN
          ASSIGN 5060 TO KFMT1
          ASSIGN 5160 TO KFMT2
        ELSE IF(KTYPE.EQ.7) THEN
          CONTINUE   ! IS SET BELOW
        ELSE IF(KTYPE.EQ.8) THEN
          ASSIGN 5080 TO KFMT1
          ASSIGN 5180 TO KFMT2
          END IF
C
        DO INDEX=1,MAXPARM
          TEST = TARGPARM(INDEX,ITARG)
          IF(TEST.NE.R8888) KSHOW = INDEX
          DATA(INDEX) = TARGPARM(INDEX,ITARG)/FACTOR(INDEX,KTYPE)
          OUTNAMES(INDEX) = PARMNAME(INDEX,KTYPE)
          END DO
        END IF
C
C    SPECIAL CODE FOR TYPE 7(ANOTHER SATELLITE) BECAUSE QUANTITIES
C    PRESENT MAY DIFFER FROM TARGET TO TARGET.  WE LOAD THE PARAMETER
C    NAMES ACCORDING TO THE QUANTITIES PRESENT AND CONVERT TO DEGREES
C    AS NEEDED.
      IF(KTYPE.EQ.7) THEN
        KASE = JIDNNT(DATA(1)) + 1
C      ERROR CHECK.
        IF(KASE.NE.1 .AND. KASE.NE.2 .AND. KASE.NE.3) THEN
C        KASE IS INVALID. ERROR SHOULD HAVE BEEN SENSED EARLIER.
          TYPE *,' RDCAT4. CODING ERROR. SEE RDCAT4 SOURCE. END. KASE=',
     *                KASE
          STOP   ' RDCAT4. CODING ERROR. SEE RDCAT4 SOURCE. END.'
          END IF
C      LOAD PARAMETER NAMES TO BE WRITTEN
        DO I=1,KSHOW
          OUTNAMES(I) = NAME7(I,KASE)
          END DO
C      DO CASE-DEPENDENT CONVERSIONS
        IF(KASE.EQ.1) THEN            ! NO INFO SUPPLIED
          ASSIGN 5071 TO KFMT1
          ASSIGN 5171 TO KFMT2
        ELSE IF(KASE.EQ.2) THEN       ! INITIAL CONDITIONS PRESENT
          ASSIGN 5072 TO KFMT1
          ASSIGN 5172 TO KFMT2
          DATA(3) = PAKTIM50(DATA(3)) ! PUT EPOCH IN YYMMDD.HMMSS FORMAT
          KTEMP = JIDNNT(DATA(4))     ! 1 = KEPLERIAN, 2 = CARTESIAN
          IF(KTEMP.EQ.1) THEN
            DATA( 7) = DATA( 7)*DEGRAD
            DATA( 8) = DATA( 8)*DEGRAD
            DATA( 9) = DATA( 9)*DEGRAD
            DATA(10) = DATA(10)*DEGRAD
            END IF
        ELSE IF(KASE.EQ.3) THEN       ! EPHEM FILE SPECIFIED
          ASSIGN 5073 TO KFMT1
          ASSIGN 5173 TO KFMT2
          END IF
        END IF
C
C
      WRITE(IUNIT,KFMT1) KTARGID(ITARG),TARGNAMES(ITARG),KTYPE,
     *      (OUTNAMES(I), DATA(I), I=1,MIN(4,KSHOW) )
      IF(KSHOW.GT.4) THEN
        WRITE(IUNIT,KFMT2) (OUTNAMES(I), DATA(I), I=5,KSHOW)
        END IF
C
 1200 CONTINUE
C
 9999 CONTINUE
      RETURN
C
 5000 FORMAT(T5,I4,T12,A,T30,I5)
C
 5010 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
 5110 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5020 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.6, 1X,A,F13.6, 1X,A,F13.3, 1X,A,F13.1)
 5120 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5030 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.6, 1X,A,F13.6, 1X,A,F13.1, 1X,A,G13.6)
 5130 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5040 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.6, 1X,A,F13.6, 1X,A,G13.6, 1X,A,G13.6)
 5140 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5050 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
 5150 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5060 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.6, 1X,A,G13.3, 1X,A,G13.1, 1X,A,G13.6)
 5160 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5071 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.1, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
 5171 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5072 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.1, 1X,A,F13.1, 1X,A,F13.6, 1X,A,F13.1)
 5172 FORMAT(T37, 1X,A,F13.6, 1X,A,F13.6, 1X,A,F13.6, 1X,A,F13.6)
C
 5073 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,F13.1, 1X,A,F13.1, 1X,A,G13.6, 1X,A,G13.6)
 5173 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
C
 5080 FORMAT(T5,I4,T12,A,T30,I5,
     *       T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
 5180 FORMAT(T37, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6, 1X,A,G13.6)
      END