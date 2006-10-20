      SUBROUTINE PLOT(X,Y,BIGY,SMLY,NTIME,BX,SX,NOPT,IN,HEXTTL,AOPT,KTT)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                     C
C     SUBROUTINE 'PLOT' DOES THE PRINTER PLOTS                        C
C     LATEST MODIFICATIONS AS OF SEPT. 1977.                          C
C     THE ARRAY TITLE IS IN ONE TO ONE CORRESPONDENCE WITH            C
C     LOCATION IN THE PLOT BUFFER AND THE INPUT CONTROL KPLOTS.       C
C                                                                     C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
      IMPLICIT REAL*8 (A-H,O-Z)
C
      COMMON/RMAIN1/ HUMPTY(2),FREQ,DUMPTY(302)
C
      REAL*4 Y,BIGY,SMLY
C
      COMPLEX*16 AOPT
C
      COMPLEX*16 HEXTTL
C
      COMPLEX*16 OPT2,TITLE
C
      COMMON/PLTHED/OPT2(10),TITLE(450)
C
      INTEGER PERIOD,DASH,BLANK,STAR
C
C
      DIMENSION X(NTIME),Y(NTIME),JPRINT(101),LINES(101),T(12)
      DIMENSION PRIOD(12),T2(12)
C
C
      DATA PERIOD/'*'/
      DATA DASH  /'-'/
      DATA BLANK /' '/
C
      DATA PRIOD /'.','.','.','.','.','.','.','.','.','.','.','.'/
C
      LOGICAL SWITCH
C
C                       PRESET VALUES
C
      KOUNT=0
      ID=0
      SWITCH=.TRUE.
C
C***********************************************************************
C
C      *** INPUT ---
C                   X INDEPENDENT VARIABLE(TIME-ABSCISSA)
C                   Y DEPENDENT VARIABLE(ORDINATE)
C                   BIGY LARGEST DEPENDENT VARIABLE
C                   SMLY SMALLEST DEPENDENT VARIABLE
C                   NO INDEX FOR WRITING HEADING
C
C                   NTIME NUMBER OF VALUES TO BE PLOTTED
C
C
C***********************************************************************
C
C                       CHECK FOR ORDINATE SCALE
C  *** VALUES ALL NEGATIVE
C
      IF(BIGY.LE.0..AND.SMLY.LT.0.) ID=1
C
C   *** VALUES ALL POSITIVE
C
      IF(BIGY.GE.0..AND.SMLY.GE.0.) ID=51
C
C   *** VALUES RANGE FROM POSITIVE TO NEGATIVE
C
      IF(BIGY.GT.0..AND.SMLY.LT.0.) ID=26
C    CHECK FOR CONSTANT FUNCTION
      IF (BIGY.EQ.SMLY) ID=-1
C
      AOPT=TITLE(IN)
      IF(IN.LT.11.AND.NOPT.EQ.2) AOPT=OPT2(IN)
C
      IF(KTT.GT.2) RETURN
C
      IF (ID.GT.0) GO TO 10
      IF (ID.EQ.0) WRITE (6,10000) AOPT
      IF (ID.LT.0) WRITE (6,4445) AOPT    ,BIGY
      RETURN
C
C                       CALCULATE ABSCISSA SCALE
C
   10 N=NTIME
C
C
   15 CONTINUE
C
C                       CHECK ON NUMBER OF VALUES TO PLOT
C                             GREATER THAN 111 PLOT FIRST 111
C                             THEN PLOT NEXT GROUP ETC.
C
      IF(NTIME.LE.101) GO TO 20
      SWITCH=.FALSE.
      NT=NTIME-101
      N=101
   20 K11=11
      N1=0
      T2(1)=X(1)
      XSCALE=FREQ
C
C
   30 CALL YRMODA(T2(1),IMNTH,IDAY,IHR,IMIN,ISEC)
      CALL YRMODA(X(N+N1),IMO,ID,IH,IM,IS)
C
      DO 40 I=1,10
   40 T2(I+1)=T2(I) + 10.D0*XSCALE
C
      DO 45 I=1,11
      T22=T2(I)
   45 T(I)=HMSOUT(DMOD(T22  ,86400.D0))
C
C                       SETUP FOR PRINTING VARIABLES
C
      YMAX=BIGY-SMLY
C
C                       SETUP LINES FOR PRINTING
C
      DO 50 I=1,N
      K=I+N1
      XLINE=50.0*(BIGY-Y(K))/YMAX+1.0
   50 LINES(I)=XLINE
C
C                       WRITE HEADING
C
      WRITE (6,10001) HEXTTL,AOPT
      WRITE(6,10004) (PRIOD(I),I=1,11)
C
C                       FILL JPRINT TABLE WITH CHARATERS TO PRINT
C
      DO 90 I=1,51
C
      DO 55 J=1,101
   55 JPRINT(J)=BLANK
C
      DO 60 J=1,N
       IF(LINES(J).EQ.I) JPRINT(J)=PERIOD
   60 CONTINUE
C
      A=BIGY-DFLOAT   (I-1)*YMAX/50
      WRITE(6,10002) A,DASH,(JPRINT(K),K=1,101)
   90 CONTINUE
C
      WRITE(6,10004) (PRIOD(I),I=1,11)
      WRITE (6,10005)(T(I),I=1,11)
      WRITE (6,10008) IMNTH,IDAY,IHR,IMIN,ISEC,IMO,ID,IH,IM,IS
      IF(SWITCH) RETURN
      SWITCH=.FALSE.
      IF(NT.LT.101) SWITCH=.TRUE.
      N=NT+1
      N1=N1+100
      IF (SWITCH)  GO TO 100
      N=101
      NT=NT-100
  100 T2(1)=T2(K11)
      GO TO 30
C
 4445 FORMAT('1',10X,'NO PLOTS FOR ',2A8/' FUNCTION HAS CONSTANT VALUE O
     1F ',G10.4)
10000 FORMAT('1',10X,'NO PLOTS FOR ',2A8)
C
10001 FORMAT('1',61X,2A8/62X,2A8)
C
10002 FORMAT(' ',5X,G13.6,2X,A1,111A1)
C
10003 FORMAT(' ',20X,112A1)
C
10004 FORMAT(' ',21X,A1,10(9X,A1))
C
10005 FORMAT('0',5X,'TIME',6X,F9.2,10(1X,F9.2))
C
10008 FORMAT('0',40X,'FROM',I6,'/',I2,4X,I2,'.',I2,'.',I2,4X,'TO',I6,
     * '/',I2,4X,I2,'.',I2,'.',I2)
C
C
      END