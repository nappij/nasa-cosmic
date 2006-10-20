      SUBROUTINE GPRINT
C
C    *****************************************************************
C     SUBROUTINE GPRINT(WITH ENTRY POINT SPRINT) IS THE EXECUTIVE
C     ROUTINE TO CONTROL THE NORMAL PRINT OUTPUT, IT CALLS SUBROUTINE
C     SET TO PERFORM THE PRINTED FSD PROGRAM OUTPUT.
C    *****************************************************************
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      INTEGER*4 ACNTRL
      REAL*8 MSUBM
C
C
      COMMON/CANTNA/ A(10,3),ADOT(10,3),B(10,3),BDOT(10,3),DIN(10,3),
     .               DINDOT(10,3),DOUT(10,3),DOUTDT(10,3)
C
      COMMON/CONSTS/ PI,TWOPI,RADIAN
C
      COMMON/CWHEEL/ VWH(3),VDUMY(6)
C
      COMMON/DEBUG1/ IAFM(5)
C
      COMMON/DMMNT1/ ZKBM(6),FMAK(10),FMBK(10),ARTETA(3),CMTORK(3),
     .               ITORK,IBENDM,ITENSE,ITNS1
C
      COMMON/DRPROT/ STAGP
C
      COMMON/ECNSTS/ THETA1,THETGO(12)
C
      COMMON/ELMNTS/ NELMTS,NDAMPR
C
      COMMON/HAMOUT/ HAMILT,IHAMLT
C
      COMMON/ICNTRL/ KNTRL(10)
C
      COMMON/IPOOL1/ IGRAV,IDAMP,IK,K1,ITIM,IAB,IAPS,IBB,IBPS,NK(10),
     .               LK(10),LLK(10)
C
      COMMON/ISHADE/ IPLANS,ISATSH,IWRTTF
C
      COMMON/MOMENT/ ACNTRL,IVISCS,IATTDE,IMGMTS,IWHEEL,NPULSE
C
      COMMON/NODER / NDER,NOPT
C
      COMMON/NUTANG/ ANGNUT
C
      COMMON/OUTONE/ OMEGL,VSUBL,MSUBM(3),CMX,SIMPX,SB(3)
C
      COMMON/OUTTWO/ SOLILL,EPSERR
C
      COMMON/OUTTHR/ SMAGB(3),XMB(3),RWHEEL(3)
C
      COMMON/OUTFOR/ OMEGDT(3)
C
      COMMON/PRCOM / STORE(10,30),ILINE,ICOL,ICNT,IHD
C
      COMMON/RMAIN1/ DELTAT,FACTOR,FREQ,TSTOP,DELMIT,
     .               UPBND(150),DNBND(150)
C
      COMMON/RMGNTC/ SMAGI(3),DPMAG(3),SFMAG,MAGFLD
C
      COMMON/RPOOL1/ RHOK(10),TIME,SA(3,3),FM1(3,3),ZLK(10),OMEG(3),
     .               ZLKP(10),ZLKDP(10),CMAT(3,3),GBAR(3,3),YBCM(3),
     .               ZBZK(3,10),FCM(3,3),DTO,PHID,PHI
C
      COMMON/RPOOL3/ZMS,DUMMM(6)
C
      COMMON/RPOOL9/ RT1(7),RT2(10,9),ALP(7,7),GAM(10,9,7),DEL(10,9,9)
C
      COMMON/SOLOUT/ FTAKIN(10,3),FTAKOT(10,3),FTBKIN(10,3),FTBKOT(10,3)
C
      COMMON/SUBPOS/ ALAT,ALONG,HGT
C
      COMMON/SUNANG/ DSL2
C
      COMMON/SUNVTR/ SSSLLL(3)
C
      COMMON/TENSON/ TSSO(10)
C
      COMMON/VARBLS/ DEPEND(150),DERIV(150)
C
      COMMON/VECTRS/ XSAT(3),XSATDT(3),AD(3)
C
      COMMON/XIN1  / PSI1,THET1,PHI1,ETTA,ZETTA,ITEST1
C
      COMMON/XIN2  / ALFAE,BETAE,GAMAE,OMBC(3),ITEST2
C
C     MODIFICATION FOR GPRINT
C     ADD NEW COMMONS
C
      COMMON/HOUTPT/ IHCALC,IHREF,IHFLAG
C
      COMMON/HVCOUT/ HBODY(3),HINERT(3),HMAG
C
C
C   MOD OF ACCELERATION COMPUTATION IN GPRINT
C
C   ADD COMMON FOR ACCELERATION COMPUTATION
C
      COMMON/IACC  / IACOMP,IHUBAC,ITIPAC
C
      COMMON/ACCHUB/ YHUB(3,6),HUBACC(3,6),ACCRED(6),ALFAEA(6),
     .               BETAEA(6),GAMAEA(6),DKAT(3,3,6)
C
      COMMON/ACCORB/ ACCOB(3),TRTACC(3)
C
      COMMON/SEPACC/ CENACC(3,10),CORACC(3,10),DLIACC(3,10),TIPACC(3,10)
C
      COMMON/NUMACC/ NUMHUB
C
      COMMON/GRNTST/ ALFAEG,DELTAG,PHASEG,ALTUDE,OMGY(3),
     *               GACC(3),GLOCAT(3),IGRUND,IALTUD
C
      COMMON/GRNOUT/ ALFAG,DELTG,PHASG,OMGN(3)
C
      COMMON/ITW   / ITWIST,ITWST1
C
      COMMON/INEWR / NKT(10),IABCDE(2)
C
      COMMON/TWIOUT/ CW(10,3),CWD(10,3)
C
C
      DIMENSION SUMD(10),SUMDT(10),SUMDIN(10),SUMDNT(10),SUMA(10),
     .          SUMB(10),SUMAD(10),SUMBD(10)
C
      DIMENSION YCEMS(3)
      DIMENSION FMT(25)
      DIMENSION GAMES(4,2,2),INAM(4,2,2)
C
      DATA ISIZE /0/
      DATA FMD/'F12.0   '/,FMD1/'F12.3   '/
      DATA I2/',A2,'/
      DATA I3 /',A3,'/
      DATA I4 /',A4,'/
      DATA I5 /',A5,'/
      DATA I6 /',A6,'/
      DATA I8/',A8,'/
      DATA PAR1 /'(       '/, PAR2/')       '/
      DATA SKIP /' 1H0,   '/, CC /'1H ,    '/
      DATA FM3/'D12.5   '/,FM5/',1X,    '/,FM2/'2X,A8,2X'/
      DATA STARS /'********'/
      DATA GAMES /'DOUT    ','DOUTDT  ','DIN     ','DINDOT  ',
     .            'A       ','ADOT    ','B       ','BDOT    ',
     .            'UD3     ','UD3DT   ','UD2     ','UD2DT   ',
     .            'U3      ','U3DOT   ','U2      ','U2DOT   '/
      DATA INAM  /',A4,',',A6,',',A3,',',A6,',
     .            ',A1,',',A4,',',A1,',',A4,',
     .            ',A3,',',A5,',',A3,',',A5,',
     .            ',A2,',',A5,',',A2,',',A5,'/
C
      ISP=0
      GO TO 500
      ENTRY SPRINT
      ISP=1
  500 FMT(1)=PAR1
      BLANK=10D-38
      ILINE=1
      ICOL=0
C
C        TEST FOR HEADING,NO HEADING CONDITIONS
C
      IF(ICNT.GT.60) GO TO 650
      IF(ISIZE.GT.(60-ICNT)) GO TO 650
C
C        IHD = 1 MEANS HEADING
C        IHD = 0 MEANS NO HEADING
      IHD=0
      GO TO 690
  650 IHD=1
      ICNT=0
C
C        OUTPUT DATA VIA SUBROUTINE SET
  690 CALL TCNVRT (YMD,TEMP,SEC,TLAST,TIME,2)
      CALL SET ('DATE    ',0,0,YMD,I4)
      HMS=HMSOUT(DMOD(SEC,86400.D0))
      CALL SET ('TIME    ',0,0,HMS,I4)
      IF(IGRUND.EQ.1)  GO TO 400
      DO 720 I=1,3
  720 CALL SET ('XSAT    ',I,0,XSAT(I),I4)
      DO 750 I=1,3
  750 CALL SET ('XSATDT  ',I,0,XSATDT(I),I6)
      RMAG=DSQRT(XSAT(1)**2+XSAT(2)**2+XSAT(3)**2)
      CALL SET ('RMAG    ',0,0,RMAG,I4)
      CALL SET('STAG PR ',0,0,STAGP,I8)
C
      CALL XYZPLH(XSAT)
      ALAT=ALAT/RADIAN
      ALONG=ALONG/RADIAN
      CALL SET ('LAT     ',0,0,ALAT,I3)
      CALL SET ('LONG    ',0,0,ALONG,I4)
      CALL SET ('ALT     ',0,0,HGT,I4)
 400  CONTINUE
      CALL SET ('DELTAT  ',0,0,DELTAT,I6)
      IF(IGRUND.EQ.1.AND.IGASBR.EQ.0)  GO TO 798
      DO 823 I=1,3
      DO 823 J=1,3
  823 CALL SET('SA      ',I,J,SA(I,J),I2)
 798  CONTINUE
      IF(IGRUND.EQ.1)  GO TO 410
      IF(ISP.EQ.1) GO TO 920
      CALL SET ('ALFAE   ',0,0,ALFAE,I5)
      IF(ITEST2.EQ.0) GO TO 890
      CALL SET ('BETAE   ',0,0,BETAE,I5)
      CALL SET ('GAMAE   ',0,0,GAMAE,I5)
      GO TO 990
  890 CALL SET ('BETAE   ',0,0,BLANK,I5)
      CALL SET ('GAMAE   ',0,0,BLANK,I5)
      GO TO 990
  920 CALL SET ('THET1   ',0,0,THET1,I5)
      IF(ITEST1.EQ.0) GO TO 970
      CALL SET ('PSI1    ',0,0,PSI1,I4)
      CALL SET ('PHI1    ',0,0,PHI1,I4)
      GO TO 1020
  970 CALL SET ('PSI1    ',0,0,BLANK,I4)
      CALL SET ('PHI1    ',0,0,BLANK,I4)
      GO TO 1020
  990 CALL SET ('W1BC    ',0,0,OMBC(1),I4)
      CALL SET ('W2BC    ',0,0,OMBC(2),I4)
      CALL SET ('W3BC    ',0,0,OMBC(3),I4)
      AL=ALFAE*RADIAN
      BE=BETAE*RADIAN
      GA=GAMAE*RADIAN
      RRAT=OMBC(1)*DCOS(GA)-OMBC(2)*DSIN(GA)
      PRAT=(OMBC(1)*DSIN(GA)+OMBC(2)*DCOS(GA))/DCOS(AL)
      YRAT=OMBC(3)+DTAN(AL)*(OMBC(1)*DSIN(GA)+OMBC(2)*DCOS(GA))
      CALL SET('RRAT    ',0,0,RRAT,I4)
      CALL SET('PRAT    ',0,0,PRAT,I4)
      CALL SET('YRAT    ',0,0,YRAT,I4)
 1020 DEGREE=180/PI
      W1B=DEPEND(7)*DEGREE
      W2B=DEPEND(8)*DEGREE
      W3B=DEPEND(9)*DEGREE
      CALL SET ('W1B     ',0,0,W1B,I3)
      CALL SET ('W2B     ',0,0,W2B,I3)
      CALL SET ('W3B     ',0,0,W3B,I3)
      GO TO 430
 410  CONTINUE
      CALL SET('ALFAG   ',0,0,ALFAG,I5)
      CALL SET('DELTG   ',0,0,DELTG,I5)
      CALL SET('W1GY    ',0,0,OMGN(1),I4)
      CALL SET('W2GY    ',0,0,OMGN(2),I4)
      CALL SET('W3GY    ',0,0,OMGN(3),I4)
 430  CONTINUE
      DO 1085 I=1,3
 1085 CALL SET('MOMENT  ',I,0,OMEGDT(I),I6)
      JELMNT=0
      JDAMPR=0
C
      DO 4510 K=1,IK
      IY=K-K1
      JWZ=IY
      IF (IY.LE.0) JWZ=K
      IF (IBENDM.EQ.0) GO TO 700
      CALL SET('BNMTA   ',JWZ,0, FMAK(K), I5)
      CALL SET('BNMTB   ',JWZ,0, FMBK(K), I5)
  700 IF (ITENSE.EQ.0) GO TO 4510
      CALL SET('TENSN   ',JWZ,0, TSSO(K),I5)
 4510 CONTINUE
      DO 1170 K=1,IK
      M=NK(K)
      IF(M.EQ.0) GO TO 1170
      IF((K-K1).GT.0) GO TO 1140
      IF(JDAMPR.EQ.1) GO TO 1140
C
      DO 1130 I=1,NDAMPR
C
      SUMD(I)=0.D0
      SUMDT(I)=0.D0
      SUMDIN(I)=0.D0
      SUMDNT(I)=0.D0
      IF(NK(I).EQ.0) GO TO 1130
C
      DO 1120 J=1,M
C
      SUMD(I)=SUMD(I) + DOUT(I,J)
      SUMDT(I)=SUMDT(I) + DOUTDT(I,J)
      SUMDIN(I)=SUMDIN(I) + DIN(I,J)
      SUMDNT(I)=SUMDNT(I) + DINDOT(I,J)
C
      CALL SET(GAMES(1,1,1),I,J,DOUT(I,J),INAM(1,1,1))
      CALL SET(GAMES(2,1,1),I,J,DOUTDT(I,J),INAM(2,1,1))
      CALL SET(GAMES(3,1,1),I,J,DIN(I,J),INAM(3,1,1))
      CALL SET(GAMES(4,1,1),I,J,DINDOT(I,J),INAM(4,1,1))
C
      IF (IWRTTF.EQ.0) GO TO 1120
      CALL SET('FTAKIN  ',I,J,FTAKIN(I,J), I6)
      CALL SET('FTAKOT  ',I,J,FTAKOT(I,J), I6)
      CALL SET('FTBKIN  ',I,J,FTBKIN(I,J), I6)
      CALL SET('FTBKOT  ',I,J,FTBKOT(I,J), I6)
 1120 CONTINUE
C
 1130 CONTINUE
      JDAMPR=1
      GO TO 1170
 1140 IF(JELMNT.EQ.1) GO TO 1170
      DO 1160 I=1,NELMTS
      SUMA(I)=0.D0
      SUMB(I)=0.D0
      SUMAD(I)=0.D0
      SUMBD(I)=0.D0
      KK=I+K1
      IF(NK(KK).EQ.0) GO TO 1160
      M=NK(KK)
C
      DO 1150 J=1,M
C
      SUMA(I)=SUMA(I) + B(I,J)
      SUMB(I)=SUMB(I) + A(I,J)
      SUMAD(I)=SUMAD(I) + BDOT(I,J)
      SUMBD(I)=SUMBD(I) + ADOT(I,J)
C
      CALL SET(GAMES(1,2,1),I,J,A(I,J),INAM(1,2,1))
      CALL SET(GAMES(2,2,1),I,J,ADOT(I,J),INAM(2,2,1))
      CALL SET(GAMES(3,2,1),I,J,B(I,J),INAM(3,2,1))
      CALL SET(GAMES(4,2,1),I,J,BDOT(I,J),INAM(4,2,1))
C
      IF (IWRTTF.EQ.0) GO TO 1150
      CALL SET('FTAKIN  ',I,J,FTAKIN(I,J), I6)
      CALL SET('FTAKOT  ',I,J,FTAKOT(I,J), I6)
      CALL SET('FTBKIN  ',I,J,FTBKIN(I,J), I6)
      CALL SET('FTBKOT  ',I,J,FTBKOT(I,J), I6)
 1150 CONTINUE
 1160 CONTINUE
      JELMNT=1
 1170 CONTINUE
C
      DO 1210 K=1,IK
      IF(NK(K).EQ.0) GO TO 1210
      IF((K-K1).GT.0) GO TO 1190
      IF(JDAMPR.EQ.2) GO TO 1190
C
      DO 1180 I=1,NDAMPR
      IF(NK(I).EQ.0) GO TO 1180
      CALL SET(GAMES(1,1,2),I,0,SUMD(I),INAM(1,1,2))
      CALL SET(GAMES(2,1,2),I,0,SUMDT(I),INAM(2,1,2))
      CALL SET(GAMES(3,1,2),I,0,SUMDIN(I),INAM(3,1,2))
      CALL SET(GAMES(4,1,2),I,0,SUMDNT(I),INAM(4,1,2))
 1180 CONTINUE
      JDAMPR=2
C
      GO TO 1210
 1190 IF(JELMNT.EQ.2) GO TO 1210
      DO 1200 I=1,NELMTS
      II=I+K1
      IF(NK(II).EQ.0) GO TO 1200
      CALL SET(GAMES(1,2,2),I,0,SUMA(I),INAM(1,2,2))
      CALL SET(GAMES(2,2,2),I,0,SUMAD(I),INAM(2,2,2))
      CALL SET(GAMES(3,2,2),I,0,SUMB(I),INAM(3,2,2))
      CALL SET(GAMES(4,2,2),I,0,SUMBD(I),INAM(4,2,2))
 1200 CONTINUE
      JELMNT=2
 1210 CONTINUE
C
C
      IF(ITWIST.EQ.0) GO TO 1212
      DO 1211 I=1,IK
      NTW=NKT(I)
      IF(NTW.EQ.0) GO TO 1211
      DO 1213 J=1,NTW
      CALL SET('CW      ',I,J,CW(I,J),I2)
      CALL SET('CWD     ',I,J,CWD(I,J),I3)
 1213 CONTINUE
 1211 CONTINUE
 1212 CONTINUE
C
C
      DO 1580 I=1,IK
      IF(ZLK(I).EQ.0) GO TO 1580
      IF(I.GT.K1) GO TO 1570
      CALL SET ('ZLD     ',I,0,ZLK(I),I3)
      GO TO 1580
 1570 CALL SET ('ZLK     ',I-K1,0,ZLK(I),I3)
 1580 CONTINUE
C
      CALL GPSOUT
C
      CALL SECOUT
C
      IF(IDAMP.EQ.0) GO TO 1620
      PHILD=DEPEND(10)/RADIAN
      DPHILD=DEPEND(11)/RADIAN
      CALL SET ('PHILD   ',0,0,PHILD,I5)
      CALL SET ('DPHILD  ',0,0,DPHILD,I6)
 1620 IF(ISP.EQ.0) GO TO 1710
      IF(IVISCS.EQ.0) GO TO 1680
      CALL SET ('OMEGL   ',0,0,OMEGL,I5)
      CALL SET ('VSUBL   ',0,0,VSUBL,I5)
      DO 1670 I=1,3
 1670 CALL SET ('MSUBM   ',I,0,MSUBM(I),I5)
 1680 IF(IATTDE.EQ.0) GO TO 1710
      CALL SET ('CMX     ',0,0,CMX,I3)
      CALL SET ('SIMPX   ',0,0,SIMPX,I5)
 1710 IF(IMGMTS.EQ.0) GO TO 1780
      DO 1730 I=1,3
 1730 CALL SET ('XMB     ',I,0,XMB(I),I3)
      DO 1750 I=1,3
 1750 CALL SET ('SMAGI   ',I,0,SMAGI(I),I5)
      DO 1770 I=1,3
 1770 CALL SET ('SMAGB   ',I,0,SMAGB(I),I5)
 1780 CONTINUE
      IF(IGRUND.EQ.1)  GO TO 420
      CALL SET ('SOLILL  ',0,0,SOLILL,I6)
      CALL SET ('SUNANG  ',0,0,DSL2,I6)
      IF(IAFM(1).EQ.0) GO TO 420
      DO 3000 I=1,3
      CALL SET('SUNVEC  ',I,0,SSSLLL(I),I6)
 3000 CONTINUE
 420  CONTINUE
      IF(IWHEEL.EQ.0) GO TO 1815
      DO 1810 I=1,3
      CALL SET('WHL SPD ',I,0,VWH(I),I8)
 1810 CALL SET ('RWHEEL  ',I,0,RWHEEL(I),I6)
C
      IF(KNTRL(1).NE.0) CALL DEBOUT
C
 1815 IF(ISP.EQ.0.AND.IGRUND.EQ.0) GO TO 1820
      IF(IHREF.EQ.1) GO TO 1818
      CALL SET('EPSERR  ',0,0,EPSERR,I6)
      GO TO 1819
 1818 CONTINUE
      EPSERH=EPSERR
      CALL SET('EPSERH  ',0,0,EPSERH,I6)
 1819 CONTINUE
 1820 IF (NOPT.EQ.0) GO TO 1821
      ANDER=NDER
      CALL SET ('NO DEREQ',0,0,ANDER,I8)
      NDER=0
 1821 IF(IHAMLT.NE.0) CALL SET('HAMILTON',0,0,HAMILT,I8)
      IF(IACOMP.EQ.0) GO TO 2000
      DO 2100 I=1,3
      CALL SET('ACCOB   ',I,0,ACCOB(I),I5)
 2100 CONTINUE
      IF(IHUBAC.EQ.0) GO TO 2200
      DO 2300 I=1,NUMHUB
      CALL SET('ACCRED  ',I,0,ACCRED(I),I6)
      DO 2300 J=1,3
      CALL SET('HUBACC  ',J,I,HUBACC(J,I),I6)
 2300 CONTINUE
 2200 CONTINUE
      IF(ITIPAC.EQ.0) GO TO 2000
      DO 2400 I=1,NELMTS
      DO 2400 J=1,3
      CALL SET('TIPACC  ',J,I,TIPACC(J,I),I6)
 2400 CONTINUE
 2000 CONTINUE
      IF(IHCALC.EQ.0) GO TO 1685
      DO 1692 I=1,3
      CALL SET('HBODY   ',I,0,HBODY(I),I5)
 1692 CONTINUE
      CALL SET('NUT ANG ',0,0,ANGNUT,I8)
      DO 1693 I=1,3
      CALL SET('HVECTR  ',I,0,HINERT(I),I6)
 1693 CONTINUE
      CALL SET('HMAG    ',0,0,HMAG,I5)
 1685 CONTINUE
      CALL SET('ZMS     ',0,0,ZMS,I4)
      DO 1694 I=1,3
      YCEMS(I)=YBCM(I)/ZMS
      CALL SET('YCEMS   ',I,0,YCEMS(I),I5)
 1694 CONTINUE
      BIXX=ALP(4,4)
      BIYY=ALP(5,5)
      BIZZ=ALP(6,6)
      BIXY=-ALP(4,5)
      BIXZ=-ALP(4,6)
      BIYZ=-ALP(5,6)
      CALL SET('BIXX    ',0,0,BIXX,I4)
      CALL SET('BIYY    ',0,0,BIYY,I4)
      CALL SET('BIZZ    ',0,0,BIZZ,I4)
      CALL SET('BIXY    ',0,0,BIXY,I4)
      CALL SET('BIXZ    ',0,0,BIXZ,I4)
      CALL SET('BIYZ    ',0,0,BIYZ,I4)
 1686 IF((IHD.EQ.1).AND.(ICOL.LT.10)) CALL SETEND
C
      ISIZE=ILINE+1
      ICNT=ICNT+ISIZE
      DO 1910 J=1,ILINE
      FMT(2) = CC
      IF(J.EQ.1) FMT(2)=SKIP
      L=10
      IF(ILINE.EQ.J) L=ICOL
      DO 1900 I=1,L
      K=(I-1)*2+3
      IF(STORE(I,J).EQ.BLANK ) GO TO 1930
      FMT(K)=FM3
      IF(J.EQ.1.AND.I.EQ.1) FMT(K)=FMD
      IF (J.EQ.1.AND.I.EQ.2) FMT(K)=FMD1
      IF (J.EQ.ILINE.AND.I.EQ.L.AND.NOPT.NE.0) FMT(K)=FMD1
 1890 FMT(K+1)=FM5
      N=K
      GO TO 1900
 1930 STORE(I,J)=STARS
      FMT(K)=FM2
      GO TO 1890
 1900 CONTINUE
      FMT(N+1)=PAR2
      WRITE(6,FMT)(STORE(II,J),II=1,L)
 1910   CONTINUE
      RETURN
      END
