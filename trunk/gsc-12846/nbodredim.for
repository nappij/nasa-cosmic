      PROGRAM NREDIM
C
C     PROGRAM NBODREDIM
C
C
C     PROGRAM TO REDIMENSION NBOD2 - UP TO 23 BODIES
C
C     NBODREDIM IS FORTRAN 77
C
      CHARACTER ICARD(72)*1,IBLK*1
      CHARACTER*13 FILNAM
      CHARACTER*1 YESNO
      DATA NIT,NOT/2,1/
      DATA IBLK/' '/
  900 CONTINUE
      PRINT*
      PRINT*
      PRINT*,'ENTER NAME OF FILE TO BE REDIMENSIONED'
      PRINT*,'(E.G. RENBOD.FOR)'
      READ 1002,FILNAM
      OPEN(UNIT=NIT,FILE=FILNAM,STATUS='OLD',ERR=901)
      GO TO 902
  901 PRINT*
      PRINT*,'ERROR OPENING FILE TO BE REDIMENSIONED'
      PRINT*
      PRINT*,'DO YOU WANT TO TRY AGAIN? [Y/N]'
      READ 1003,YESNO
      IF(YESNO.EQ.'Y')THEN
      YESNO='N'
      GO TO 900
      ELSE
      STOP
      END IF
  902 CONTINUE
      PRINT*
      PRINT*
      PRINT*,'ENTER NAME YOU WANT REDIMENSIONED FILE TO BE CALLED'
      READ 1002,FILNAM
      OPEN(UNIT=NOT,FILE=FILNAM,STATUS='NEW',ERR=904)
      GO TO 905
  904 PRINT*
      PRINT*,'ERROR OPENING REDIMENSIONED FILE'
      PRINT*
      PRINT*,'DO YOU WANT TO TRY AGAIN? [Y/N]'
      READ 1003,YESNO
      IF(YESNO.EQ.'Y')THEN
      YESNO='N'
      GO TO 902
      ELSE
      STOP
      END IF
  905 CONTINUE
      PRINT*
      PRINT*,'**FRIENDLY ADVICE** IF THERE ARE COMMENT LINES IN'
      PRINT*,'USER-WRITTEN ROUTINES WHICH EXTEND BEYOND COLUMN 72'
      PRINT*,'(SPECIFICALLY IN COLUMNS 73-75), THE REDIMENSION PROGRAM'
      PRINT*,'WILL BOMB OUT - YOU MUST FIX THESE YOURSELF'
      PRINT*
C
C     SET DIMENSION SIZES
C
C
C     NBOD WAS N (=10)
C     NMODS WAS 2N
C     NBOD4 WAS 4N
C     NIDOF WAS 33
C     NEW WAS 160
C     N24 WAS 18
C
  906 CONTINUE
      PRINT*
      PRINT*
      PRINT*,'ENTER # OF BODIES (MUST BE .LE. 23)'
      READ *,NBOD
      IF(NBOD.LE.0.OR.NBOD.GT.23)THEN
      PRINT*
      PRINT*,'# OF BODIES MUST BE .GT. 0 AND .LE. 23'
      NBOD=0
      GO TO 906
      END IF
  907 CONTINUE
      PRINT*
      PRINT*
      PRINT*
      PRINT*,'ENTER # OF 1ST ORDER DIFFERENTIAL EQUATIONS THAT THE'
      PRINT*,'      USER WILL ENTER IN SUBROUTINE TORQUE'
      READ *,NTQ
      IF(NTQ.LT.0)THEN
      PRINT*
      PRINT*,'# OF DIFFERENTIAL EQUATIONS MUST BE .GE. 0'
      NTQ=0
      GO TO 907
      END IF
      NMODS=NBOD*2
      NBOD4=NMODS*2
      NIDOF=4*NBOD+NMODS+3
      NEW=2*NIDOF+6*NBOD+NTQ
      N24=24
C
C     
C
      IAWORK=200
      ITORQ=97
      IAWOR1=IAWORK-NBOD-6
      ITORQ1=ITORQ-(2*NBOD-1)
      IDEM2=NBOD**2+NBOD+1-(NBOD*(NBOD-1))/2
      IDEM3=(NBOD-1)**2+NBOD-((NBOD-1)*(NBOD-2))/2
C
C     IDEM4 = SIZE OF /LOGIC/    LOGICAL WORDS
C     IDEM5 = SIZE OF /INTG/     INTEGER WORDS
C     IDEM6 = SIZE OF /INTGZ/    INTEGER WORDS
C     IDEM7 = SIZE OF /REAL/     REAL WORDS
C     IDEM8 = SIZE OF /REALZ/    REAL WORDS
C     IDEM9 = SIZE OF /SATELL/   REAL WORDS
C
      IDEM4=6+NBOD
      IDEM5=IAWORK+NBOD*5+3*(NBOD+1)*5+2*(NBOD+1)*2+(NBOD+1)*4+IDEM3+
     *      ITORQ+3*NBOD+39
      IDEM6=(NBOD-1)*7+7
      IDEM7=3*NBOD*7+NBOD*6+3*(NBOD+1)*6+NIDOF*3+3*(NBOD+1)+3*IDEM2+
     *      9*(NBOD+1)*2+6*(NBOD+1)*2+9*IDEM2+9*NBOD*4+NIDOF*NIDOF+
     *      3*NBOD*10+9*NBOD*4+NBOD*4+12*NBOD+36*NBOD+3
      IDEM8=9+3*NBOD*2+(NBOD-1)+9*NBOD
      IDEM9=1000
      IDEM10=NEW
C
C
C
 1000 FORMAT(72A1,I3)
 1001 FORMAT(72A)
 1002 FORMAT(A13)
 1003 FORMAT(A1)
    1 FORMAT(5X,'* IINIT(1)      , IZINIT(1)     , SD    , SCXC('
     *,I2,')',17X,I3)
    2 FORMAT(5X,'* ANGD  (',I2,')   , CNF  (3,',I2,')  , ETIC  (3,',
     *I2,')  , ETMC  (3,',I2,')   ,   ',I3)
    3 FORMAT(5X,'* FLQ   (3,',I2,') , FLE  (3,3,',I2,'), FLH   (3,3,',
     *I2,'),  ',18X,I3)
    4 FORMAT(5X,'* THADD (',I3,')  , YMCD (3,2,',I2,'), RINIT (1)',
     *5X,', RZINIT(1)',10X,I3)
    5 FORMAT(6X,'COMMON /LOGIC/ FG1, FG2, FG3, FG4, FG5, INERF, RBLO(',
     *I2,')',11X,I3)
    6 FORMAT(6X,'COMMON /INTG/    AWORK(',I3,')   ,',35X,I3)
    7 FORMAT(5X,'* CT5           , FCON  (',I2,')    , JCON  (',I2,
     *')    , LCON  (',I2,')    ,  ',I3)
    8 FORMAT(5X,'* MO    (',I2,')    , NB1           , NBOD          , 
     *NCTC          ,  ',I3)
    9 FORMAT(5X,'* NSVQ          , PCON  (',I2,')    , SD            , S
     *FR   (',I2,')    ,  ',I3)
   10 FORMAT(5X,'* SG            , SI    (',I3,')   , SIG           , S
     *L            ,  ',I3)
   11 FORMAT(5X,'* SLK   (',I2,')    , SMA   (',I2,')    , SOK   (',
     *I2,')    , SQF   (',I2,')    ,  ',I3)
   12 FORMAT(5X,'* SQL   (',I2,')    , SMV           , SR            , 
     *SSCN          ,  ',I3)
   13 FORMAT(5X,'* SVI           , SVM           , SVP   (',I2,
     *')    , SVQ   (',I2,')    ,  ',I3)
   14 FORMAT(5X,'* SXM   (3,',I2,')  , SXT           , TORQ  (',I3,
     *')   , SMAL          ,  ',I3)
   15 FORMAT(5X,'* SEU           , NTQ           , SC    (',I2,
     *')    , SCG           ,  ',I3)
   16 FORMAT(5X,'* NFLXB         , SFLX          , SFXM  (',I2,
     *')    , NMODS         ,  ',I3)
   17 FORMAT(5X,'* SFCC          , SCC   (',I2,')',39X,I3)
   18 FORMAT(5X,'* SCNDUM        , SCN   (',I2,')    , SCRDUM        , 
     *SCR   (',I2,')    ,  ',I3)
   19 FORMAT(5X,'* SFKDUM        , SFK   (',I2,')    , SIXDUM        , 
     *SIX   (',I2,')    ,  ',I3)
   20 FORMAT(5X,'* SKDUM         , SK    (',I2,')    , SPIDUM        , 
     *SPI   (',I2,')    ,  ',I3)
   21 FORMAT(5X,'* SMCDUM        , SMC   (',I2,')',39X,I3)
   22 FORMAT(5X,'* CA    (3,',I2,')  , CAC   (3,',I2,')  , CLM   (',
     *I2,')    , COMC  (3,',I2,')  ,  ',I3)
   23 FORMAT(5X,'* DOMC  (3,',I2,')  , ETC   (3,',I2,')  , ETM   (',
     *I3,')   , FOMC  (3,',I2,')  ,  ',I3)
   24 FORMAT(5X,'* GAM   (3,',I3,') , H             , HM    (3,',
     *I2,')  , HMC   (3,',I2,')  ,  ',I3)
   25 FORMAT(5X,'* HMOM  (',I2,')    , PHI   (3,',I2,')  , PLM   (',
     *I2,')    , QF    (3,',I2,')  ,',2X,I3)
   26 FORMAT(5X,'* QFC   (3,',I2,')  , QL    (3,',I2,')  , QLC   (3,'
     *,I2,')  , ROMC  (3,',I2,')  ,  ',I3)
   27 FORMAT(5X,'* T             ,                 THA   (',I3,
     *')   , THAD  (',I3,')   ,  ',I3)
   28 FORMAT(5X,'* THADW (',I2,')    , THAW  (',I2,')    , XDIC  (3,3,'
     *,I3,'),XI    (3,3,',I2,'),  ',I3)
   29 FORMAT(5X,'* XIC   (3,3,',I2,'), XMAS  (',I2,')    , XMN   (',
     *I3,',',I3,'),XMT   (3,3,',I2,'),  ',I3)
   30 FORMAT(5X,'* TUG   (',I2,')    , FLA   (3,',I2,')  , FLB   (3,'
     *,I2,')  , FLC   (3,',I2,')  ,  ',I3)
   31 FORMAT(5X,'* FLD   (3,3,',I2,'), FLJ   (3,3,',I2,'), CAO   (3,'
     *,I2,')  , XIO   (3,3,',I2,'),  ',I3)
   32 FORMAT(5X,'* FLIRC (3,',I2,')  , FLCRC (3,',I2,')  , FLAC  (3,'
     *,I2,')  , FLQC  (3,',I2,')  ,  ',I3)
   33 FORMAT(5X,'* FLOM  (',I2,')    , ZETA  (',I2,')    , FCF   (3,3,'
     *,I2,'), FCK   (3,',I2,')  ,  ',I3)
   34 FORMAT(5X,'* CBDUM (1,3)    , CB    (3,',I2,')  , CBCDUM(1,3)  , 
     *CBC    (3,',I2,') ,  ',I3)
   35 FORMAT(5X,'* XMCDUM(1,1,',I2,') , XMC   (3,3,',I2,'), CBN(3)'
     *,26X,I3)
   36 FORMAT(6X,'COMMON /SATELL/ DUMMY(',I4,')',39X,I3)
   37 FORMAT(6X,'DIMENSION Y(',I3,'),YD(',I3,'),TEM(2,'I3,')',31X,I3)
   38 FORMAT(6X,'LOGICAL LG(',I3,')',51X,I3)
   39 FORMAT(6X,'INTEGER S1(',I2,'),S2(',I2,'),S3(',I2,'),SML,S4(',
     *I3,')',26X,I3)
   40 FORMAT(6X,'DIMENSION XMCDUM(1,1,',I2,'),XMC(3,3,1)',31X,I3)
   41 FORMAT(6X,'INTEGER SET(',I2,'),S(',I2,'),SS(',I2,')',38X,I3)
   42 FORMAT(6X,'INTEGER ST1(',I2,'),ST2(',I2,'),ST3(',I2,'),ST4(',I2,
     *'),SFXMN',21X,I3)
   43 FORMAT(6X,'INTEGER ST1(',I2,')',51X,I3)
   44 FORMAT(6X,'INTEGER ST1(',I2,'),SET(',I2,')',43X,I3)
   45 FORMAT(6X,'INTEGER ST1(',I2,'),SET(',I2,'),SFXMN',37X,I3)
   46 FORMAT(6X,'DIMENSION TEM1(',I3,'),TEM2(',I3,')',37X,I3)
   47 FORMAT(6X,'REAL*8 EFOMC(',I3,'),ECOMC(',I3,'),EROMC(',I3,
     *'),EDOMC(',I3,')',16X,I3)
   48 FORMAT(6X,'INTEGER SET(',I2,')',51X,I3)
   49 FORMAT(6X,'INTEGER ST1(',I2,'),ST2(',I2,'),ST3(',I2,
     *'),ST4(',I2,')',27X,I3)
   50 FORMAT(6X,'INTEGER ST1(',I2,'),ST2(',I2,'),ST3(',I2,
     *'),ST4(',I2,'),SET(',I2,'),SFXMN',13X,I3)
   51 FORMAT(5X,'* DUMMY(1000)',54X,I3)
   52 FORMAT(6X,'DIMENSION TEM1(3),TEM(3,',I2,'),XQD(3,',I2,
     *')',29X,I3)
   53 FORMAT(6X,'DIMENSION EQFC(',I3,'), EXDIC(',I4,')',34X,I3)
   54 FORMAT(6X,'REAL*8    FCUP(3,3,',I2,'),FCUP1(3,3),KCUP(3,',I2,
     *'),KCUP1(3)',13X,I3)
   55 FORMAT(6X,'INTEGER ST1(',I2,'),ST2(',I2,'),ST3(',I2,')'35X,I3)
   56 FORMAT(6X,'INTEGER ST4(',I2,')',51X,I3)
   57 FORMAT(6X,'INTEGER SET(',I2,')',51X,I3)
   58 FORMAT(6X,'INTEGER S1(',I3,'),S2(',I3,')',43X,I3)
   59 FORMAT(6X,'COMMON /INTG/ AWORK(',I3,'),ST1,N,M,MM,NST1,J,I,',
     *21X,I3)
   60 FORMAT(6X,'INTEGER ST1(',I2,')',51X,I3)
   61 FORMAT(6X,'DIMENSION TOMC(3,',I2,')',46X,I3)
   62 FORMAT(6X,'DIMENSION HB(3,',I2,'),TK(',I2,')',41X,I3)
   63 FORMAT(6X,'DIMENSION POS(3,',I2,'),VEL(3,',I2,')',37X,I3)
   64 FORMAT(6X,'DIMENSION TEM1(3),TEM2(3),TEM3(3),DERV(3,',I2,
     *')',22X,I3)
   65 FORMAT(6X,'DIMENSION EPD(3,',I2,'),DHM(3,',I2,')',37X,I3)
   66 FORMAT(6X,'INTEGER SET(',I2,'),SFXMK',45X,I3)
   67 FORMAT(6X,'REAL*8 LM(3,',I2,'),LMT(3)',44X,I3)
   68 FORMAT(6X,'DIMENSION DD(',I3,',',I3,'),CC(',I3,')',37X,I3)
   69 FORMAT(6X,'DIMENSION XMN(',I3,',1),THADD(1)',37X,I3)
   70 FORMAT(6X,'INTEGER S1(',I2,'),S2(',I2,'),S2NNM1',39X,I3)
   71 FORMAT(6X,'IDEM4 = ',I2,56X,I3)
   72 FORMAT(6X,'IDEM5 = ',I4,54X,I3)
   73 FORMAT(6X,'IDEM6 = ',I3,55X,I3)
   74 FORMAT(6X,'IDEM7 = ',I5,53X,I3)
   75 FORMAT(6X,'IDEM8 = ',I3,55X,I3)
   76 FORMAT(6X,'IDEM9 = ',I4,54X,I3)
   77 FORMAT(6X,'IDEM10 = ',I3,54X,I3)
   78 FORMAT(5X,'*',12X,'(SCNDUM,IZINIT(1))',8X,',(TORQ(',I2,'),SCXC(1))
     *',9X,I3)
   79 FORMAT(6X,'DATA NIDOF/',I3,'/',51X,I3)
   80 FORMAT('C',15X,'N = ',I2,50X,I3)
   81 FORMAT('C',13X,'NTQ = ',I4,48X,I3)
   82 FORMAT('C     IDEM4 = SIZE OF /LOGIC/       ',I2,' LOGICAL WORDS',
     *20X,I3)
   83 FORMAT('C     IDEM5 = SIZE OF /INTG/      ',I4,' INTEGER WORDS',
     *20X,I3)
   84 FORMAT('C     IDEM6 = SIZE OF /INTGZ/      ',I3,' INTEGER WORDS',
     *20X,I3)
   85 FORMAT('C     IDEM7 = SIZE OF /REAL/     ',I5,' REAL WORDS',
     *23X,I3)
   86 FORMAT('C     IDEM8 = SIZE OF /REALZ/      ',I3,' REAL WORDS',
     *23X,I3)
   87 FORMAT('C     IDEM9 = SIZE OF /SATELL/   ',I5,' REAL WORDS',
     *23X,I3)
   88 FORMAT('C  AWORK      I  ',I3,7X,'/INTG/     LOCAL WORK AREA TO SA
     *VE STORAGE   ',I3)
   89 FORMAT('C  TORQ',7X,'R  ',I3,7X,'/INTG/     UNUSED STORAGE AREA FO
     *R USER',6X,I3)
  500 CONTINUE
      READ(NIT,1000,END=700)ICARD,N
      IF(N.EQ.0)GO TO 525
      GO TO 600
  525 DO 505 L=1,72
      LE=73-L
      IF(ICARD(LE).EQ.IBLK)GO TO 505
      GO TO 510
  505 CONTINUE
      GO TO 500
  510 CONTINUE
      WRITE(NOT,1001)(ICARD(L),L=1,LE)
      GO TO 500
  600 CONTINUE
      IF(N.LT.11)GO TO 601
      IF(N.LT.21)GO TO 602
      IF(N.LT.31)GO TO 603
      IF(N.LT.41)GO TO 604
      IF(N.LT.51)GO TO 605
      IF(N.LT.61)GO TO 606
      IF(N.LT.71)GO TO 607
      IF(N.LT.81)GO TO 608
      IF(N.LT.91)GO TO 609
  601 IF(N.EQ.1)WRITE(NOT,1)2*NBOD,N
      IF(N.EQ.2)WRITE(NOT,2)3*(NBOD+1),NBOD,NBOD,NBOD,N
      IF(N.EQ.3)WRITE(NOT,3)NMODS,NMODS,NMODS,N
      IF(N.EQ.4)WRITE(NOT,4)NIDOF,NBOD+1,N
      IF(N.EQ.5)WRITE(NOT,5)NBOD,N
      IF(N.EQ.6)WRITE(NOT,6)IAWORK,N
      IF(N.EQ.7)WRITE(NOT,7)3*(NBOD+1),NBOD,NMODS+2,N
      IF(N.EQ.8)WRITE(NOT,8)NBOD,N
      IF(N.EQ.9)WRITE(NOT,9)NBOD+1,3*(NBOD+1),N
      IF(N.EQ.10)WRITE(NOT,10)IDEM3,N
      GO TO 500
  602 CONTINUE
      IF(N.EQ.11)WRITE(NOT,11)3*(NBOD+1),NBOD,NBOD+1,NBOD+1,N
      IF(N.EQ.12)WRITE(NOT,12)NBOD+1,N
      IF(N.EQ.13)WRITE(NOT,13)2*(NBOD+1),3*(NBOD+1),N
      IF(N.EQ.14)WRITE(NOT,14)NBOD,ITORQ,N
      IF(N.EQ.15)WRITE(NOT,15)3*(NBOD+1),N
      IF(N.EQ.16)WRITE(NOT,16)NBOD,N
      IF(N.EQ.17)WRITE(NOT,17)NBOD,N
      IF(N.EQ.18)WRITE(NOT,18)NBOD-1,NBOD-1,N
      IF(N.EQ.19)WRITE(NOT,19)NBOD-1,NBOD-1,N
      IF(N.EQ.20)WRITE(NOT,20)NBOD-1,NBOD-1,N
      GO TO 500
  603 CONTINUE
      IF(N.EQ.21)WRITE(NOT,21)NBOD-1,N
      IF(N.EQ.22)WRITE(NOT,22)NBOD,NBOD,NBOD,NBOD+1,N
      IF(N.EQ.23)WRITE(NOT,23)NBOD+1,NBOD+1,NIDOF,NBOD+1,N
      IF(N.EQ.24)WRITE(NOT,24)IDEM2,NBOD,NBOD,N
      IF(N.EQ.25)WRITE(NOT,25)NBOD,NBOD+1,NBOD,3*(NBOD+1),N
      IF(N.EQ.26)WRITE(NOT,26)3*(NBOD+1),2*(NBOD+1),2*(NBOD+1),NBOD+1,N
      IF(N.EQ.27)WRITE(NOT,27)NIDOF,NIDOF,N
      IF(N.EQ.28)WRITE(NOT,28)NBOD,NBOD,IDEM2,NBOD,N
      IF(N.EQ.29)WRITE(NOT,29)NBOD,NBOD,NIDOF,NIDOF,NBOD,N
      IF(N.EQ.30)WRITE(NOT,30)3*(NBOD+1),NMODS,NMODS,NMODS,N
      GO TO 500
  604 CONTINUE
      IF(N.EQ.31)WRITE(NOT,31)NMODS,NMODS,NBOD,NBOD,N
      IF(N.EQ.32)WRITE(NOT,32)NBOD,NBOD,NMODS,NMODS,N
      IF(N.EQ.33)WRITE(NOT,33)NMODS,NMODS,NBOD4,NBOD4,N
      IF(N.EQ.34)WRITE(NOT,34)NBOD,NBOD,N
      IF(N.EQ.35)WRITE(NOT,35)NBOD-1,NBOD,N
      IF(N.EQ.36)WRITE(NOT,36)IDEM9,N
      IF(N.EQ.37)WRITE(NOT,37)NEW,NEW,NEW,N
      IF(N.EQ.38)WRITE(NOT,38)NIDOF,N
      IF(N.EQ.39)WRITE(NOT,39)NBOD,NBOD,NBOD,NIDOF,N
      IF(N.EQ.40)WRITE(NOT,40)NBOD-1,N
      GO TO 500
  605 CONTINUE
      IF(N.EQ.41)WRITE(NOT,41)N24,N24,N24,N
      IF(N.EQ.42)WRITE(NOT,42)NBOD,NBOD,NBOD,NBOD,N
      IF(N.EQ.43)WRITE(NOT,43)NBOD+1,N
      IF(N.EQ.44)WRITE(NOT,44)NBOD,N24,N
      IF(N.EQ.45)WRITE(NOT,45)NBOD,N24,N
      IF(N.EQ.46)WRITE(NOT,46)3*(NBOD+1),3*(NBOD+1),N
      IF(N.EQ.47)WRITE(NOT,47)3*(NBOD+1),3*(NBOD+1),3*(NBOD+1),
     *3*(NBOD+1),N
      IF(N.EQ.48)WRITE(NOT,48)N24,N
      IF(N.EQ.49)WRITE(NOT,49)NBOD,NBOD,NBOD,NBOD,N
      IF(N.EQ.50)WRITE(NOT,50)NBOD,NBOD,NBOD,NBOD,N24,N
      GO TO 500
  606 CONTINUE
      IF(N.EQ.51)WRITE(NOT,51)N
      IF(N.EQ.52)WRITE(NOT,52)NBOD+1,NBOD+1,N
      IF(N.EQ.53)WRITE(NOT,53)3*3*(NBOD+1),3*3*IDEM2,N
      IF(N.EQ.54)WRITE(NOT,54)NMODS,NMODS,N
      IF(N.EQ.55)WRITE(NOT,55)NBOD,NBOD,NBOD+1,N
      IF(N.EQ.56)WRITE(NOT,56)NBOD,N
      IF(N.EQ.57)WRITE(NOT,57)N24,N
      IF(N.EQ.58)WRITE(NOT,58)NIDOF,NIDOF,N
      IF(N.EQ.59)WRITE(NOT,59)IAWOR1,N
      IF(N.EQ.60)WRITE(NOT,60)NBOD,N
      GO TO 500
  607 CONTINUE
      IF(N.EQ.61)WRITE(NOT,61)NBOD+1,N
      IF(N.EQ.62)WRITE(NOT,62)NBOD,NBOD,N
      IF(N.EQ.63)WRITE(NOT,63)NBOD,NBOD,N
      IF(N.EQ.64)WRITE(NOT,64)NBOD+1,N
      IF(N.EQ.65)WRITE(NOT,65)NBOD,NBOD,N
      IF(N.EQ.66)WRITE(NOT,66)N24,N
      IF(N.EQ.67)WRITE(NOT,67)NBOD,N
      IF(N.EQ.68)WRITE(NOT,68)NIDOF,NIDOF,NIDOF,N
      IF(N.EQ.69)WRITE(NOT,69)NIDOF,N
      IF(N.EQ.70)WRITE(NOT,70)NBOD,NBOD,N
      GO TO 500
  608 CONTINUE
      IF(N.EQ.71)WRITE(NOT,71)IDEM4,N
      IF(N.EQ.72)WRITE(NOT,72)IDEM5,N
      IF(N.EQ.73)WRITE(NOT,73)IDEM6,N
      IF(N.EQ.74)WRITE(NOT,74)IDEM7,N
      IF(N.EQ.75)WRITE(NOT,75)IDEM8,N
      IF(N.EQ.76)WRITE(NOT,76)IDEM9,N
      IF(N.EQ.77)WRITE(NOT,77)IDEM10,N
      IF(N.EQ.78)WRITE(NOT,78)ITORQ1,N
      IF(N.EQ.79)WRITE(NOT,79)NIDOF,N
      IF(N.EQ.80)WRITE(NOT,80)NBOD,N
      GO TO 500
  609 CONTINUE
      IF(N.EQ.81)WRITE(NOT,81)NTQ,N
      IF(N.EQ.82)WRITE(NOT,82)IDEM4,N
      IF(N.EQ.83)WRITE(NOT,83)IDEM5,N
      IF(N.EQ.84)WRITE(NOT,84)IDEM6,N
      IF(N.EQ.85)WRITE(NOT,85)IDEM7,N
      IF(N.EQ.86)WRITE(NOT,86)IDEM8,N
      IF(N.EQ.87)WRITE(NOT,87)IDEM9,N
      IF(N.EQ.88)WRITE(NOT,88)IAWORK,N
      IF(N.EQ.89)WRITE(NOT,89)ITORQ,N
      GO TO 500
  700 CONTINUE
      CLOSE(UNIT=1)
      CLOSE(UNIT=2)
      END
