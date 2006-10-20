C
      SUBROUTINE OUTPSP
C       GENERAL TYPE OUTPUT FOR NO PARTICULAR SATELLITE
C
C
      IMPLICIT REAL*8(A-H,O-Z)
      LOGICAL  FG1, FG2, FG3, FG4, FG5, INERF, RBLO, LEQU, LINIT(1)
C
C
      INTEGER
     * AWORK , CT1   , CT2   , CT3   , CT4   , CT5   , FCON  , PCON  ,
     * SCNDUM, SCN   , SCRDUM, SCR   , SFKDUM, SFK   , SFR   , SG    ,

     * SI    , SIG   , SIXDUM, SIX   , SKDUM , SK    , SL    , SLK   ,
     * SMA   , SMCDUM, SMC   , SMV   , SOK   , SPIDUM, SPI   , SQF   ,
     * SQL   , SR    , SSCN  , SSIX  , SVA   , SVB   , SVD   , SVI   ,
     * SVM   , SVP   , SVQ   , SXM   , SXT   , TORQ  , SMAL  , SEU   ,
     * SC    , SCG   , NFLXB , SFLX  , SFXM  , NMODS , SFCC  , SCC   ,
     * IINIT(1)      , IZINIT(1)     , SD
C
C
C
      REAL*8
     * ANGD  (33)   , CNF  (3,10)  , ETIC  (3,10)  , ETMC  (3,10)   ,     2
     * FLQ   (3,20) , FLE  (3,3,20), FLH   (3,3,20),                      3
     * THADD ( 63)  , YMCD (3,2,11), RINIT (1)     , RZINIT(1)            4
C
C
C
C
C
      COMMON /LOGIC/ FG1, FG2, FG3, FG4, FG5, INERF, RBLO(10)             5
C
C
      COMMON /INTG/    AWORK(200)   ,                                     6
     * CT1           , CT2           , CT3           , CT4           ,
     * CT5           , FCON  (33)    , JCON  (10)    , LCON  (22)    ,    7
     * MO    (10)    , NB1           , NBOD          , NCTC          ,    8
     * NFER          , NFKC          , NFRC          , NLOR          ,
     * NMV           , NMO           , NMOA          , NSVP          ,
     * NSVQ          , PCON  (11)    , SD            , SFR   (33)    ,    9
     * SG            , SI    ( 55)   , SIG           , SL            ,   10
     * SLK   (33)    , SMA   (10)    , SOK   (11)    , SQF   (11)    ,   11
     * SQL   (11)    , SMV           , SR            , SSCN          ,   12
     * SSIX          , SVA           , SVB           , SVD           ,
     * SVI           , SVM           , SVP   (22)    , SVQ   (33)    ,   13
     * SXM   (3,10)  , SXT           , TORQ  ( 97)   , SMAL          ,   14
     * SEU           , NTQ           , SC    (33)    , SCG           ,   15
     * NFLXB         , SFLX          , SFXM  (10)    , NMODS         ,   16
     * SFCC          , SCC   (10)                                        17
C
C
      COMMON /INTGZ/
     * SCNDUM        , SCN   ( 9)    , SCRDUM        , SCR   ( 9)    ,   18
     * SFKDUM        , SFK   ( 9)    , SIXDUM        , SIX   ( 9)    ,   19
     * SKDUM         , SK    ( 9)    , SPIDUM        , SPI   ( 9)    ,   20
     * SMCDUM        , SMC   ( 9)                                        21
C
C
      COMMON /REAL/
     * CA    (3,10)  , CAC   (3,10)  , CLM   (10)    , COMC  (3,11)  ,   22
     * DOMC  (3,11)  , ETC   (3,11)  , ETM   ( 63)   , FOMC  (3,11)  ,   23
     * GAM   (3, 66) , H             , HM    (3,10)  , HMC   (3,10)  ,   24
     * HMOM  (10)    , PHI   (3,11)  , PLM   (10)    , QF    (3,33)  ,   25
     * QFC   (3,33)  , QL    (3,22)  , QLC   (3,22)  , ROMC  (3,11)  ,   26
     * T             ,                 THA   ( 63)   , THAD  ( 63)   ,   27
     * THADW (10)    , THAW  (10)    , XDIC  (3,3, 66),XI    (3,3,10),   28
     * XIC   (3,3,10), XMAS  (10)    , XMN   ( 63, 63),XMT   (3,3,10),   29
     * TUG   (33)    , FLA   (3,20)  , FLB   (3,20)  , FLC   (3,20)  ,   30
     * FLD   (3,3,20), FLJ   (3,3,20), CAO   (3,10)  , XIO   (3,3,10),   31
     * FLIRC (3,10)  , FLCRC (3,10)  , FLAC  (3,20)  , FLQC  (3,20)  ,   32
     * FLOM  (20)    , ZETA  (20)    , FCF   (3,3,40), FCK   (3,40)  ,   33
     * TIMEND
C
C
      COMMON /REALZ/
     * CBDUM (1,3)    , CB    (3,10)  , CBCDUM(1,3)  , CBC    (3,10) ,   34
     * XMCDUM(1,1, 9) , XMC   (3,3,10), CBN(3)                           35
C
C
      EQUIVALENCE (ETM(1),THADD(1))         ,(XMN(1,1),ANGD(1))    ,
     *            (XMN(1,3),YMCD(1,1,1))    ,(XMN(1,6),CNF(1,1))    ,
     *            (XMN(1,8),ETIC(1,1))      ,(XMN(1,10),ETMC(1,1))  ,
     *            (FLB(1,1),FLQ(1,1))       ,(FLE(1,1,1),FLD(1,1,1)),
     *            (FLH(1,1,1),FLJ(1,1,1))   ,
     *            (FG1,LINIT(1))            ,(CA(1,1),RINIT(1))     ,
     *            (CBDUM(1,1),RZINIT(1))    ,(AWORK(1),IINIT(1))    ,
     *            (SCNDUM,IZINIT(1))
C
C
C
      DIMENSION PHII(3,3)
      DIMENSION TOMC(3,11)                                               61
      DIMENSION SYSCM(3)
      DIMENSION SYSIN(3,3)
      DIMENSION HB(3,10),TK(10)                                          62
      DIMENSION POS(3,10),VEL(3,10)                                      63
      DIMENSION TEM1(3),TEM2(3),TEM3(3),DERV(3,11)                       64
      DIMENSION TEM4(3)
      DIMENSION HBODY(3),        HINERT(3)
      DIMENSION EPD(3,10),DHM(3,10)                                      65
      DIMENSION EP(3),EI(3,3),EID(3,3),FQD(3),FQDC(3),TEM5(3,3)
      INTEGER SET(24),SFXMK                                              66
      REAL*8 LM(3,10),LMT(3)                                             67
      INTEGER T1K
C
C THE FOLOWING ADDED BY STEER 1/15/81
      COMMON /DYTRQOU/ CAD    ,CADD  ,FBJ    ,XID    ,XMASDT2
     1                ,SLGMDT ,SLGOMG,SLGV   ,XISLGD
      COMMON /INTOUTS/ ACCDIR ,ACCLOC ,DTPLOT ,DTPRINT,HHALF ,TPRINT
      COMMON /TORQOUT/ RCM12B ,RCM12BD,TOTM12 ,XI12  ,XI12D
     1                ,SLGFORB,SLGMOMB
      COMMON /VAROUTS/ ITOTV  ,ITOTVEN,MASSDT ,MASSEDT,TMENG
     1                ,SLGMASS,LNOVERF
C
      DIMENSION ACCDIR(3,4)  ,ACCLOC(3,4)  ,CAD(3)       ,CADD(3)
     1         ,DUME(3)      ,POSR(3,9)    ,VELR(3,9)    ,ACCR(3,9)
     2         ,HBODY12(3)   ,HINERTO(3)   ,VELO(3)      ,VELADD(3)
     3         ,OMB(3,10)    ,RBDD(3)      ,OMBD(3)      ,RCMACC(3)
     4         ,WXWXR(3)     ,RBDDA(3)     ,ACREAD(4)    ,TMENG(2)
     5         ,MASSEDT(2)   ,FBJ(3,2)     ,ITOTVEN(2)  ,HINERTJ(3)
     6         ,HISUM(3)     ,VELCMC(3)    ,XI12(3,3)    ,RCM12B(3)
     7         ,RCM12BD(3)   ,RCMDD(3)     ,XI12D(3,3)
     8         ,SLGOMG(3)    ,SLGV(3)      ,XISLGD(3,3)
     9         ,SLGFORB(3)   ,SLGMOMB(3)   ,RBDDH(3,9)
     1         ,HBDYTOT(3)   ,XIBTOT(3,3)  ,LMOMT(3)
C
      LOGICAL LNOVERF(2), LPLOT, LPRINT
C
      REAL*8 ITOTV  ,ITOTVEN,LAMDA  ,LMOMT ,MASSDT ,MASSEDT
C
C
      LPLOT=.FALSE.
      LPRINT=.FALSE.
      TPHHALF=T+HHALF
      IF(LNOVERF(1).OR.LNOVERF(2))LPRINT=.TRUE.
      IF(LNOVERF(1).OR.LNOVERF(2))LPLOT=.TRUE.
      LNOVERF(1)=.FALSE.
      LNOVERF(2)=.FALSE.
      IF(TPHHALF.LT.TPRINT)GO TO 4000
         TPRINT=TPRINT+DTPRINT
         LPRINT=.TRUE.
 4000 IF(TPHHALF.LT.TPLOT)GO TO 4010
         TPLOT=TPLOT+DTPLOT
         LPLOT=.TRUE.
 4010 IF(.NOT.LPLOT.AND..NOT.LPRINT)RETURN
C END ADDITION BY STEER
C
C

    1 CONTINUE
C      LPRINT=.FALSE.
C
C
C     COMPUTE SYSTEM COMPOSITE CENTER OF MASS
      TOTM = 0.D0
      DO 11  I=1,3
   11 TEM1(I) = 0.D0
      DO 15  K=1,NBOD
      KO = KT0(NB1,0,K)
      CALL SCLV(XMAS(K),GAM(1,KO),TEM2)
      CALL VECADD(TEM1,TEM2,TEM1)
   15 TOTM = TOTM + XMAS(K)
      DO 16  I=1,3
   16 SYSCM(I) = TEM1(I)/TOTM
      IF(.NOT.LPRINT)GO TO 3001
      PRINT 203, T
      PRINT 200, (SYSCM(I),I=1,3)
      PRINT 222, TOTM
C
C
C     COMPUTE VECTOR FROM INERTIAL ORIGIN TO COMPOSITE SYSTEM
C       CENTER OF MASSRELATIVE TO COMPUTING FRAME
 3001 CALL VECADD(CBC(1,1),SYSCM,CBC(1,0))
C
C
C     COMPUTE SYSTEM INERTIA TENSOR ABOUT COMPOSITE CENTER OF MASS
      CALL SUEOP(SYSCM,SYSCM,TOTM,SYSIN)
      DO 4  I=1,3
      DO 4  J=1,3
    4 SYSIN(I,J) = XDIC(I,J,1) - SYSIN(I,J)
      IF(.NOT.LPRINT)GO TO 3003
      PRINT 211, (SYSIN(1,J),J=1,3)
      PRINT 212, (SYSIN(2,J),J=1,3)
      PRINT 211, (SYSIN(3,J),J=1,3)
      PRINT 213
 3003 CONTINUE
C
C
C     FLEXIBILITY RELATED PARAMETERS
      MN = 0
      DO 30 K=1,NBOD
      DO 32 I=1,3
      EPD(I,K) = 0.
   32 DHM(I,K) = 0.
      IF(SFXM(K).EQ.0) GO TO 30
      SFXMK = SFXM(K)
      DO 31 I=1,SFXMK
      MN = MN+1
      NFMN = NFER + MN
      CALL SCLV(THAD(NFMN),FLAC(1,MN),TEM1)
      CALL VECADD(EPD(1,K),TEM1,EPD(1,K))
      CALL SCLV(THAD(NFMN),FLQC(1,MN),TEM1)
      CALL VECADD(DHM(1,K),TEM1,DHM(1,K))
   31 CONTINUE
   30 CONTINUE
C
C
C
C     COMPUTE INERTIAL ANGULAR MOMENTUM AND KINETIC ENERGY OF EACH
C       BODY AND OF THE COMPOSITE SYSTEM
      TKIN = 0.D0
      DO 7  I=1,3
      HISUM(I)=0.
      LMOMT(I)=0.
      LMT(I) = 0.D0
    7 HBODY(I) = 0.D0
      DO 17 KKK=1,NBOD
      CALL SCLV(0.,VELR(1,1),VELR(1,1))
      K=NBOD-(KKK-1)
      KK = K
      JK = JCON(K)
      IF(KK.NE.1) GO TO 28
      DO 29  I=1,3
   29 TEM1(I) = ROMC(I,NB1)
      GO TO 26
   28 CONTINUE
C     COMPUTE LINEAR VELOCITY OF CENTER OF MASS OF BODY K PUT IN TEM1
      IF(RBLO(K)) GO TO 19
      CALL VECROS (FOMC(1,JK),CAC(1,K),TEM1)
      CALL VECADD(ROMC(1,K),TEM1,TEM1)
      GO TO 24
   19 CALL VECROS (FOMC(1,K),CAC(1,K),TEM1)
   24 CALL VECADD(TEM1,VELR(1,1),VELR(1,1))
      CALL VECADD(ROMC(1,NB1),TEM1,TEM1)
C     CHECK FOR END OF CHAIN
   25 IF(JK.EQ.0) GO TO 26
      CALL VECROS (FOMC(1,JK),CBC(1,KK),TEM2)
      CALL VECADD(VELR(1,1),TEM2,VELR(1,1))
      CALL VECADD(TEM1,TEM2,TEM1)
      KK = JK
      JK = JCON(KK)
      GO TO 25
   26 CONTINUE
C
C     INTERTIAL POSITION OF CENTER OF MASS IN TEM2
      KL = KT0(NB1,0,K)
      CALL VECADD(CBC(1,1),GAM(1,KL),TEM2)
      DO 3  I=1,3
      POS(I,K) = TEM2(I)
    3 VEL(I,K) = TEM1(I)
C
C
C     ADD RELATIVE VELOCITY OF CM, NON-ZERO IF BODY FLEXIBLE
      CALL VECADD(VEL(1,K),EPD(1,K),VEL(1,K))
      DO 13 I=1,3
   13 TEM1(I) = VEL(I,K)
C
C     START COMPUTATION OF ANGULAR MOMENTUM, LINEAR MOMENTUM AND KINETIC
      CALL DYDOTV(XIC(1,1,K),FOMC(1,K),HB(1,K))
      CALL VECADD(HISUM,HB(1,K),HISUM)
      CALL VECDOT(FOMC(1,K),HB(1,K),TK(K))
      CALL VECDOT(TEM1,TEM1,TEM)
      TK(K) = .5D0*(TK(K) + XMAS(K)*TEM)
      CALL VECROS (TEM2,TEM1,TEM3)
      CALL SCLV(XMAS(K),TEM3,TEM3)
      CALL VECADD(HB(1,K),TEM3,HB(1,K))
      IF(.NOT.RBLO(K)) GO TO 5068
      IF(NMO.EQ.0) GO TO 5068
      DO 27  M=1,NMO
      IF(MO(M).NE.K) GO TO 27
      CALL SCLV(HMOM(M),HMC(1,M),TEM3)
      CALL VECADD(HISUM,TEM3,HISUM)
      CALL VECADD(HB(1,K),TEM3,HB(1,K))
      TK(K) = TK(K) + .5D0*HMOM(M)**2/PLM(M)
   27 CONTINUE
 5068 CONTINUE
C
C
C     ADD FLEXIBILITY ADDITIONS TO MOMENTUM AND ENERGY
      CALL VECADD(HB(1,K),DHM(1,K),HB(1,K))
      CALL VECDOT(FOMC(1,K),DHM(1,K),TEM)
      TK(K) = TK(K) + TEM
C
C
C     ADD UP FOR SYSTEM ANGULAR MOMENTUM AND KINETIC ENERGY
      TKIN = TKIN + TK(K)
      CALL VECADD(HB(1,K),HBODY,HBODY)
      CALL SCLV(XMAS(K),VEL(1,K),LM(1,K))
      CALL VECADD(LMT,LM(1,K),LMT)
      CALL VECROS(GAM(1,KL),VELR(1,1),DUME)
      CALL SCLV(XMAS(K),DUME,DUME)
      CALL VECADD(HISUM,DUME,HISUM)
      CALL SCLV(XMAS(K),VELR(1,1),DUME)
      CALL VECADD(LMOMT,DUME,LMOMT)
   17 CONTINUE
      CALL VECROS(SYSCM,LMOMT,DUME)
      CALL VECSUB(HISUM,DUME,HBDYTOT)
      CALL TRNSPS  (XMC(1,1,0))
      CALL VECTRN (HBDYTOT,XMC(1,1,0),HINERTJ)
      CALL VECTRN (LMT,XMC(1,1,0),LMOMT)
      CALL VECTRN (HBODY,XMC(1,1,0),HINERT)
      CALL TRNSPS  (XMC(1,1,0))
      IF(.NOT.INERF) GO TO 2
      CALL TRNSPS  (XMC(1,1,1))
      CALL VECTRN (HINERTJ,XMC(1,1,1),HBDYTOT)
      CALL VECTRN (HINERT,XMC(1,1,1),HBODY)
      CALL TRNSPS  (XMC(1,1,1))
    2 CONTINUE
      HMG = SQRT(HINERT(1)**2 + HINERT(2)**2 + HINERT(3)**2)
      A = SQRT(LMT(1)**2 + LMT(2)**2 + LMT(3)**2)
      IF(.NOT.LPRINT)GO TO 3005
      PRINT 209, HMG
      PRINT 201, (HBODY(I),I=1,3)
      PRINT 202, (HINERT(I),I=1,3)
      PRINT 217, A
      PRINT 219, (LMT(I),I=1,3)
      PRINT 215, TKIN
 3005 CONTINUE
C
C
C     COMPUTE INERTIAL ACCELERATIONS
      DO 8  I=1,3
      TOMC(I,NB1)=DOMC(I,NB1)
    8 TOMC(I,1) = DOMC(I,1)
      IF(NBOD.EQ.1) GO TO 5001
      DO 14  K=2,NBOD
      CALL VECROS (FOMC(1,K),ROMC(1,K),TEM1)
   14 CALL VECSUB(DOMC(1,K),TEM1,TOMC(1,K))
 5001 CONTINUE
C     CALL VECROS (FOMC(1,1),ROMC(1,NB1),TEM1)
C     CALL VECSUB(DOMC(1,NB1),TEM1,TOMC(1,NB1))
      M = 1
      DO 20  K=1,NB1
      IF(K.EQ.1) GO TO 21
      M = M+3-PCON(K-1)
   21 DO 22  I=1,3
   22 TEM1(I) = 0
      MMTERM=M+2-PCON(K)
      IF(M.GT.MMTERM) GO TO 20
      DO 23 MM=M,MMTERM
      CALL SCLV(THADD(MM),QFC(1,MM),TEM2)
   23 CALL VECADD(TEM1,TEM2,TEM1)
   20 CALL VECADD(TEM1,TOMC(1,K),DERV(1,K))
C
C
      IF(.NOT.LPRINT)GO TO 3007
      DO 5 K=1,NBOD
      PRINT 204, K,(ROMC(I,K),I=1,3),(FOMC(I,K),I=1,3)
      PRINT 207, (DERV(I,K),I=1,3)
      PRINT 223, (ETC(I,K),I=1,3),(PHI(I,K),I=1,3)
      PRINT 205, (CAC(I,K),I=1,3),(CBC(I,K),I=1,3)
      PRINT 216, (POS(I,K),I=1,3),(VEL(I,K),I=1,3)
      PRINT 206, ((XMC(I,J,K),J=1,3),(XIC(I,J,K),J=1,3),I=1,3)
      PRINT 214, (HB(J,K),J=1,3),TK(K)
      PRINT 218, (LM(J,K),J=1,3)
    5 CONTINUE
      PRINT 208, (FOMC(I,NB1),I=1,3),(DERV(I,NB1),I=1,3)
      PRINT 223, (ETC(I,NB1),I=1,3),(PHI(I,NB1),I=1,3)
      PRINT 224, (CBC(I,0),I=1,3)
      PRINT 221, ((XMC(I,J,0),J=1,3),I=1,3)
      PRINT 213
 3007 CONTINUE
      IF(NMODS.EQ.0) GO TO 40
      CALL UNPAC(SET,NSET,SFLX)
      MN = 0
      DO 33 KK=1,NSET
      K = SET(NSET+1-KK)
      DO 34 I=1,3
      EP(I) = 0
      FQD(I) = 0
      FQDC(I) = 0
      DO 34 J=1,3
      EI(I,J) = 0
      EID(I,J) = 0
   34 CONTINUE
      SFXMK = SFXM(K)
      DO 35 M=1,SFXMK
      MN = MN+1
      NFMN = NFER+MN
      CALL SCLV(THA(NFMN),FLA(1,MN),TEM1)
      CALL VECADD(EP,TEM1,EP)
      CALL SCLV(THAD(NFMN),FLQ(1,MN),TEM1)
      CALL VECADD(FQD,TEM1,FQD)
      CALL SCLD(THA(NFMN),FLE(1,1,MN),TEM5)
      CALL DYADD(EI,TEM5,EI)
      CALL SCLD(THAD(NFMN),FLE(1,1,MN),TEM5)
      CALL DYADD(EID,TEM5,EID)
   35 CONTINUE
      IF(.NOT.LPRINT)GO TO 33
      PRINT 226, (EP(I),I=1,3),(EPD(I,K),I=1,3)
      PRINT 228, K,(FQD(I),I=1,3)
      PRINT 229, ((EI(I,J),J=1,3),(EID(I,J),J=1,3),I=1,3)
      PRINT 230, (FLIRC(I,K),I=1,3),(FLCRC(I,K),I=1,3)
      PRINT 231,(DHM(I,K),I=1,3)
   33 CONTINUE
      IF(LPRINT)PRINT 213
   40 CONTINUE
      IF(.NOT.LPRINT)GO TO 1090
      DO 9 I=1,NFER
    9 PRINT 220, (I,THA(I),I,THAD(I),I,THADD(I),I,(QFC(J,I),J=1,3))
      N1 = NFER+1
      N2 = NFER+MN
      IF(MN.EQ.0) GO TO 1090
      DO 12 I=N1,N2
   12 PRINT 225,  I,THA(I),I,THAD(I),I,THADD(I)
  200 FORMAT ('  CENTER OF MASS =',3D17.8,/)
  201 FORMAT (/,3X,'HBODY    = ',3D17.8)
  202 FORMAT (3X,'HINERT   = ',3D17.8)
  203 FORMAT ('1 TIME = ',D15.5,/)
  204 FORMAT(/,3X,'BODY ',I2,4X,'ROMC =',3D17.8,3X,'FOMC =',3D17.8)
  205 FORMAT (14X,'CAC = ',3D17.8,3X,'CBC = ',3D17.8)
  206 FORMAT (14X,'XMC = ',3D17.8,3X,'XIC = ',3D17.8)
  207 FORMAT (14X,'ACC = ',3D17.8)
  208 FORMAT (/,3X,'ORIGIN',4X,'FOMC = ',3D17.8,3X,'ACC = ',3D17.8)
  209 FORMAT ('  ANGULAR MOMENTUM = ',D20.8)
  210 FORMAT (3X,'HMOM(',I2,') = ',D17.8,10X,'CLM(',I2,') = ',D17.8)
  211 FORMAT (25X,3D17.8)
  212 FORMAT ('  SYSTEM INERTIA TENSOR =',3D17.8)
  213 FORMAT ('  ')
  214 FORMAT(14X,' HB = ',3D17.8,3X,' TK = ',D17.8)
  215 FORMAT (/,'  KINETIC ENERGY = ',D20.8)
  216 FORMAT (14X,'POS = ',3D17.8,3X,'VEL = ',3D17.8)
  217 FORMAT (/,'  LINEAR MOMENTUM = ',D20.8)
  218 FORMAT (14X,' LM = ',3D17.8)
  219 FORMAT (/,3X,'LBODY    = ',3D17.8)
  220 FORMAT (3X,'THA(',I2,') =',D13.6,3X,'THAD(',I2,') =',D13.6,3X,'THA
     *DD(',I2,') =',D13.6,3X,'QFC(',I2,') =',3D13.6)
  221 FORMAT (14X,'XMC = ',3D17.8)
  222 FORMAT ('   TOTAL SYSTEM MASS =',D17.8,/)
  223 FORMAT (14X,'ETC = ',3D17.8,3X,'PHI = ',3D17.8)
  224 FORMAT (14X,'CBC = ',3D17.8)
  225 FORMAT (3X,'THA(',I2,') =',D13.6,3X,'THAD(',I2,') =',D13.6,3X,'THA
     *DD(',I2,') =',D13.6)
  226 FORMAT (/,3X,'FLEXIBLE',3X,' EP = ',3D17.8,3X,'EPP = ',3D17.8)
  228 FORMAT (3X,' BODY',I2,4X,' QD = ',3D17.8)
  229 FORMAT (14X,' EI = ',3D17.8,3X,'EID = ',3D17.8)
  230 FORMAT (14X,'FIR = ',3D17.8,3X,'FCR = ',3D17.8)
  231 FORMAT (14X,'DHM = ',3D17.8)
C
C THE FOLLOWING ADDED BY J STEER TO COMPUTE EXTRANEOUS PARAMETERS.
C 1/15/81
 1090 CALL MATMUL(SYSIN,XMC(1,1,1),TEM5,3)
      CALL TRNSPS(XMC(1,1,1))
      CALL MATMUL(XMC(1,1,1),TEM5,XIBTOT,3)
      DO 1100 K=2,NBOD
         J=K-1
         CALL VECSUB(POS(1,K),POS(1,1),DUME)
         CALL VECTRN(DUME,XMC(1,1,1),POSR(1,J))
         CALL VECSUB(VEL(1,K),VEL(1,1),DUME)
         CALL VECTRN(DUME,XMC(1,1,1),VELR(1,J))
         CALL VECTRN(DERV(1,K),XMC(1,1,1),ACCR(1,J))
 1100 CONTINUE
      G=32.17405
      DEG=57.295780
      CALL VECTRN(FOMC(1,1),XMC(1,1,1),OMB(1,1))
      DO 1101 J=2,NBOD
         CALL VECTRN(ROMC(1,J),XMC(1,1,1),OMB(1,J))
 1101 CONTINUE
      CALL VECTRN(OMB(1,1),XI12,HBODY12)
      HB12MG=SQRT(HBODY12(2)*HBODY12(2)+HBODY12(3)*HBODY12(3)
     1           +HBODY12(1)*HBODY12(1))
      HTOTMG=HBDYTOT(2)*HBDYTOT(2)+HBDYTOT(3)*HBDYTOT(3)
      CONE A=ATAN2(SQRT(HTOTMG),HBDYTOT(1))*DEG
      CALL VECDOT(HINERTJ,HINERTJ,HTOTMG)
      HTOTMG=SQRT(HTOTMG)
      PITH=ATAN2(HINERTJ(2),HINERTJ(1))*DEG
      YAWH=ATAN2(HINERTJ(3),HINERTJ(1))*DEG
C
      IF(T.GT.1.E-8)GO TO 1110
         DO 1105 I=1,3
            HINERTO(I)=HINERTJ(I)/HTOTMG
            VELO(I)=LMOMT(I)/TOTM
 1105    CONTINUE
         PITHO=PITH
         YAWHO=YAWH
C
 1110 VMG ADD=0.
      DO 1115 I=1,3
         VEL ADD(I)=LMOMT(I)/TOTM-VELO(I)
         VMG ADD=VMG ADD+VEL ADD(I)*VEL ADD(I)
 1115 CONTINUE
      IF(VMGADD.LT.1.E-10)VMGADD=1.E-10
      VMGADD=SQRT(VMGADD)
      CALL VECDOT(HINERTJ,HINERTO,HDTHO)
      IF(HTOTMG.GT.1.E-10)HDTHO=HDTHO/HTOTMG
      IF(ABS(HDTHO).GT.1.)HDTHO=DSIGN(1.D0,HDTHO)
      POINTH=ACOS(HDTHO)*DEG
      IF(ABS(VELADD(1)).LT.1.E-10)VELADD(1)=1.E-10
      PITV=ATAN2(VELADD(2),VELADD(1))*DEG-PITHO
      YAWV=ATAN2(VELADD(3),VELADD(1))*DEG-YAWHO
      CALL VECDOT(VELADD,HINERTO,VDTHO)
      VDTHO=VDTHO/VMGADD
      IF(ABS(VDTHO).GT.1.)VDTHO=DSIGN(1.D0,VDTHO)
      POINTV=0.
      IF(VMGADD.GT.1.E-9)POINTV=ACOS(VDTHO)*DEG
      POI=XIBTOT(1,2)*XIBTOT(1,2)+XIBTOT(1,3)*XIBTOT(1,3)
      IF(POI.GT.1.E-10)POI=SQRT(POI)
      TRANI=(XIBTOT(2,2)+XIBTOT(3,3))/2.
      DIFMOI=TRANI-XIBTOT(1,1)
      IF(ABS(DIFMOI).LT.1.E-10)DIFMOI=DSIGN(1.D-10,DIFMOI)
      PA MIS=0.5*ATAN2(2.*POI,DIFMOI)*DEG
C
      LAMDA=(XIBTOT(1,1)/TRANI-1.)*OMB(1,1)*DEG
C COMPUTE ACCELEROMETER ACCELERATIONS
      CALL VECTRN(DERV(1,NB1),XMC(1,1,1),RBDD)
      CALL VECTRN(DERV(1,1),XMC(1,1,1),OMBD)
      CALL TRNSPS(XMC(1,1,1))
      DO 1130 K=1,4
         CALL VECROS(OMB(1,1),ACCLOC(1,K),DUME)
         CALL VECROS(OMB(1,1),DUME,WXWXR)
         CALL VECROS(OMBD,ACCLOC(1,K),DUME)
         CALL VECADD(DUME,WXWXR,RBDDA)
         CALL VECADD(RBDD,RBDDA,RBDDA)
         CALL VECDOT(RBDDA,ACCDIR(1,K),ACREAD(K))
         ACREAD(K)=ACREAD(K)/G
 1130 CONTINUE
C COMPUTE ACCELERATION OF BODIES 1 AND 2 COMBINED CM
      CALL VECROS(OMB(1,1),RCM12B,DUME)
      CALL VECROS(OMB(1,1),DUME,WXWXR)
      CALL VECROS(OMBD,RCM12B,DUME)
      CALL VECADD(DUME,WXWXR,RCMDD)
      CALL VECROS(OMB,RCM12BD,DUME)
      CALL SCLV(2.,DUME,DUME)
      CALL VECADD(DUME,RCMDD,RCMDD)
      CALL VECADD(RBDD,RCMDD,RCMDD)
C COMPUTE ACCELERATION OF HINGE POINTS IN BODY 1 COORDINATES
      DO 1135 K=2,NBOD
         CALL VECROS(OMB(1,1),CB(1,K),DUME)
         CALL VECROS(OMB(1,1),DUME,WXWXR)
         CALL VECROS(OMBD,CB(1,K),DUME)
         CALL VECADD(DUME,WXWXR,DUME)
         CALL VECADD(DUME,RBDD,RBDDH(1,K-1))
 1135 CONTINUE
C
C
C WRITE OUT DATA ONTO TAPE 20 FOR PRINT IF LPRINT TRUE
      WRITE(20,2000)T,TOTM*G
      WRITE(22)T,TOTM*G
 2000 FORMAT(1H0/1H0,4X,'TIME=',F8.3,' SEC    WEIGHT=',F9.3,' LBS'/)
      WRITE(20,2010)1,(POS(I,1),I=1,3),(VEL(I,1),I=1,3),
     1                (RBDD(I),I=1,3)
      WRITE(22)(POS(I,1),I=1,3),(VEL(I,1),I=1,3),(RBDD(I),I=1,3)
 2010 FORMAT(1H ,I2,1X,3(1PE11.4,2X),1X,3(E11.4,2X),1X,3(E11.4,2X))
      WRITE(20,2010)2,(RCM12B(I),I=1,3),(RCM12BD(I),I=1,3),
     1                (OMBD(I),I=1,3)
      WRITE(22)(RCM12B(I),I=1,3),(RCM12BD(I),I=1,3),(OMBD(I),I=1,3)
      KC=2
      IF(NBOD.LT.3)GO TO 1142
      DO 1140 K=3,NBOD
         J=K-1
         WRITE(20,2010)K,(POSR(I,J),I=1,3),(VELR(I,J),I=1,3),
     1                   (ACCR(I,J),I=1,3)
      WRITE(22)(POSR(I,J),I=1,3),(VELR(I,J),I=1,3),(ACCR(I,J),I=1,3)
         KC=K
 1140 CONTINUE
 1142 WRITE(20,2010)KC+1,(OMB(I,1),I=1,3),(FBJ(I,1),I=1,3)
     1                  ,TMENG(1),ITOTVEN(1),MASSEDT(1)*G
      WRITE(20,2010)KC+2,(OMB(I,2),I=1,3),(FBJ(I,2),I=1,3)
     1                  ,TMENG(2),ITOTVEN(2),MASSEDT(2)*G
      WRITE(20,2010)KC+3,(OMB(I,3),I=1,3),(XI12(1,I),I=1,3),PITV,
     1                   YAWV,POINTV
      WRITE(20,2010)KC+4,(OMB(I,4),I=1,3),(XI12(2,I),I=1,3),PITH,
     1                   YAWH,POINTH
      WRITE(20,2010)KC+5,(OMB(I,5),I=1,3),(XI12(3,I),I=1,3),CONEA,
     1                   PAMIS,LAMDA
      WRITE(20,2010)KC+6,(OMB(I,6),I=1,3),(HBODY12(I),I=1,3),
     1                   HB12MG,ACREAD(1),ACREAD(2)
      WRITE(20,2010)KC+7,(OMB(I,7),I=1,3),(HBDYTOT(I),I=1,3),
     1                   HTOTMG,ACREAD(3),ACREAD(4)
      WRITE(20,2010)KC+8,ITOTV,MASSDT*G,BLANK,(VELADD(I),I=1,3),VMG ADD
      WRITE(20,2010)KC+9,(RCMDD(I),I=1,3),TOTM12*G,SLGMASS*G,SLGMDT*G
      WRITE(20,2010)KC+10,(SLGFORB(I),I=1,3),(SLGMOMB(I),I=1,3)
     1                   ,(HINERTJ(I),I=1,3)
      WRITE(22)(OMB(I,1),I=1,3),(FBJ(I,1),I=1,3)
     1                  ,TMENG(1),ITOTVEN(1),MASSEDT(1)*G
      WRITE(22)(OMB(I,2),I=1,3),(FBJ(I,2),I=1,3)
     1                  ,TMENG(2),ITOTVEN(2),MASSEDT(2)*G
      WRITE(22)(OMB(I,3),I=1,3),(XI12(1,I),I=1,3),PITV,
     1                   YAWV,POINTV
      WRITE(22)(OMB(I,4),I=1,3),(XI12(2,I),I=1,3),PITH,
     1                   YAWH,POINTH
      WRITE(22)(OMB(I,5),I=1,3),(XI12(3,I),I=1,3),CONEA,
     1                   PAMIS,LAMDA
      WRITE(22)(OMB(I,6),I=1,3),(HBODY12(I),I=1,3),
     1                   HB12MG,ACREAD(1),ACREAD(2)
      WRITE(22)(OMB(I,7),I=1,3),(HBDYTOT(I),I=1,3),
     1                   HTOTMG,ACREAD(3),ACREAD(4)
      WRITE(22)ITOTV,MASSDT*G,BLANK,(VELADD(I),I=1,3),VMG ADD
      WRITE(22)(RCMDD(I),I=1,3),TOTM12*G,SLGMASS*G,SLGMDT*G
      WRITE(22),(SLGFORB(I),I=1,3),(SLGMOMB(I),I=1,3)
      WRITE(22)(THA(I),I=1,10),(THAD(I),I=1,10),(THADD(I),I=1,10)
      WRITE(22)(SYSCM(I),I=1,3),TOTM
      WRITE(22)((SYSIN(I,J),J=1,3),I=1,3)
      WRITE(22)(((XIC(I,J,K),K=1,6),J=1,3),I=1,3)
      WRITE(22)(XMAS(I),I=1,6)
      WRITE(22)((PHI(I,J),J=1,6),I=1,3)
      WRITE(22)(CAD(I),I=1,3)
      WRITE(22)(CADD(I),I=1,3)
      WRITE(22)(SLGOMG(I),I=1,3)
      WRITE(22)(SLGV(I),I=1,3)
      WRITE(22)((XISLGD(I,J),J=1,3),I=1,3)
      WRITE(22)((XI12D(I,J),J=1,3),I=1,3)
      NLINES=(NBOD-1)/4+1
      DO 1145 K=1,NLINES
         L1=3*K-2
         L2=L1+2
         J=KC+10+K
         WRITE(20,2010)J,((RBDDH(I,L),I=1,3),L=L1,L2)
 1145 CONTINUE
C
      LPLOT=.FALSE.
 1150 IF(LPLOT) WRITE(21)T,TMENG(1),TMENG(2)
     1 ,MASSDT*G,(OMB(I,1)*DEG,I=1,3),(RBDD(I),I=1,3),(ACREAD(I),I=1,4)
     2 ,POINTV,POINTH,CONEA,LAMDA
     3 ,(RCMDD(I),I=1,3),TOTM*G,SLGMASS*G,(THA(I)*DEG,I=4,15)
     4 ,(THAD(I)*DEG,I=4,15),(THADD(I)*DEG,I=4,15)
      RETURN
      END
