      SUBROUTINE ECHO1
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 ISUBD,JARRAY,NSUBX
      INTEGER*4 ACNTRL
C
C
C     MODIFICATIONS TO ECHO1 FOR PUNCHED CARD OUTPUT
C     AUGUST,1977
C
C
      COMMON/ANTENA/ A(10,3),ADOT(10,3),B(10,3),BDOT(10,3),DIN(10,3),
     .               DINDOT(10,3),DOUT(10,3),DOUTDT(10,3),ZBZ(3,10),
     .               NELMTS,NDAMPR,MODES(10)
C
      COMMON/CANTNA/ AA(10,3),AADOT(10,3),BB(10,3),BBDOT(10,3),
     .               DDIN(10,3),DDINDT(10,3),DDOUT(10,3),DDTOUT(10,3)
C
      COMMON/CONSTS/ PI,TWOPI,RADIAN
C
      COMMON/CSTVAL/ TSTART,ZL0(10),ZL1(10),ZL2(10),ZLA(10)
C
      COMMON/HEAD22/ HEAD1(5),HEAD2(5),ILINE
C
      COMMON/IMAIN1/ IDATE,LSAVE,INOPT,IPLOT,NUMEQS,IPLTPE,IORB,ITAPE
C
      COMMON/INEWR / NKT(10),IDUMM(2)
C
      COMMON/IPOOL1/ IGRAV,IDAMP,IK,K1,ITIM,IAB,IAPS,IBB,IBPS,NK(10),
     .               LK(10),LLK(10)
C
      COMMON/ITW   / ITWIST,ITWST1
C
      COMMON/LIBDPR/ ZK1D,ZK2D,PHIS,PHILD,DPHILD,BETLD,GAMLD,
     .               ZMDO,ZMDBO,CNV,DECAY
C
      COMMON/MOMENT/ ACNTRL,IVISCS,IATTDE,IMGMTS,IWHEEL,NPULSE
C
      COMMON/RPOOL1/ RHOK(10),TIME,SA(3,3),FM1(3,3),ZLK(10),OMEG(3),
     .               ZLKP(10),ZLKDP(10),CMAT(3,3),GBAR(3,3),YBCM(3),
     .               ZBZK(3,10),FCM(3,3),DTO,PHID,PHI
C
      COMMON/RVISCS/ NSUBX(3),YARRAY(3),RADTBE,VISCTY,RADRNG,DENSTY,
     .               JARRAY(3),SSUBY,OMEGL,ISUBD
C
      COMMON/TWIOUT/ CW(10,3),CWD(10,3)
C
      COMMON/VECTRS/ XSAT(3),XSATDT(3),AD(3)
C
      COMMON/XIN1  / PSI1,THET1,PHI1,ETTA,ZETTA,ITEST1
C
      COMMON/XIN2  / ALFAE,BETAE,GAMAE,OMBC(3),ITEST2
C
C
C
      IK=NDAMPR+NELMTS
      CALL TCNVRT(DATE,DM1,TOD,TL,TIME,2)
      DATE=DATE+0.1D0
      ID=DATE
      NDF=0
      KP=0
      WRITE(7,699) NDF,KP
  699 FORMAT(1X,'IORB',I2,' IKPLR',I2)
      WRITE(7,700) ID,TOD
  700 FORMAT(1X,'IDATE',I7,' TIME ',F12.4)
C
C     USE POSITION AND VELOCITY FOR CARD RESTART
C
      WRITE(7,701) (XSAT(I),I=1,3)
      WRITE(7,702) (XSATDT(I),I=1,3)
  701 FORMAT(1X,'XSAT ',1P3E15.7)
  702 FORMAT(1X,'XSATDT ',1P3E15.7)
C
C     ELEMENT LENGTHS AND VELOCITIES
C
      IF(IK.EQ.0) GO TO 25
      DO 12 I=1,10
      IF(I.LE.K1) ZL0(NELMTS+I)=ZLK(I)
      IF(I.LE.K1) ZL1(NELMTS+I)=ZLKP(I)
      IF(I.GT.K1) ZL0(I-K1)=ZLK(I)
      IF(I.GT.K1) ZL1(I-K1)=ZLKP(I)
   12 CONTINUE
      WRITE(7,703) (ZL0(I),I=1,IK)
  703 FORMAT(1X,'ZL0 ',1P5E13.5/5X,5E13.5)
      WRITE(7,704) (ZL1(I),I=1,IK)
  704 FORMAT(1X,'ZL1 ',1P5E13.5/5X,5E13.5)
C
C     ELEMENT INITIAL CONDITIONS
C
      IF(NELMTS.EQ.0) GO TO 19
      DO 15 I=1,NELMTS
      NDF=MODES(I)
      IF(NDF.EQ.0) GO TO 15
      WRITE(7,705) I,(   AA(I,J),J=1,NDF)
      WRITE(7,706) I,(AADOT(I,J),J=1,NDF)
      WRITE(7,707) I,(   BB(I,J),J=1,NDF)
      WRITE(7,708) I,(BBDOT(I,J),J=1,NDF)
   15 CONTINUE
  705 FORMAT(1X,'   A(',I2,',1)2',1P3E13.5)
  706 FORMAT(1X,'ADOT(',I2,',1)2',1P3E13.5)
  707 FORMAT(1X,'   B(',I2,',1)2',1P3E13.5)
  708 FORMAT(1X,'BDOT(',I2,',1)2',1P3E13.5)
   19 CONTINUE
      IF(NDAMPR.EQ.0) GO TO 25
      DO 20 I=1,NDAMPR
      ID=NELMTS+I
      NDF=MODES(I)
      IF(NDF.EQ.0) GO TO 20
      WRITE(7,709) I,(  DDIN(I,J),J=1,NDF)
      WRITE(7,710) I,(DDINDT(I,J),J=1,NDF)
      WRITE(7,711) I,( DDOUT(I,J),J=1,NDF)
      WRITE(7,712) I,(DDTOUT(I,J),J=1,NDF)
   20 CONTINUE
  709 FORMAT(1X,'   DIN(',I2,',1)2',1P3E13.5)
  710 FORMAT(1X,'DINDOT(',I2,',1)2',1P3E13.5)
  711 FORMAT(1X,'  DOUT(',I2,',1)2',1P3E13.5)
  712 FORMAT(1X,'DOUTDT(',I2,',1)2',1P3E13.5)
   25 CONTINUE
C
      IF(ITWIST.EQ.0) GO TO 28
      DO 26 I=1,IK
      NTW=NKT(I)
      IF(NTW.EQ.0) GO TO 26
      WRITE(7,720) I,( CW(I,J),J=1,NTW)
      WRITE(7,721) I,(CWD(I,J),J=1,NTW)
  720 FORMAT(1X,' CW(',I2,',1)2',1P3E13.5)
  721 FORMAT(1X,'CDW(',I2,',1)2',1P3E13.5)
   26 CONTINUE
   28 CONTINUE
C
      IF(IDAMP.EQ.0) GO TO 30
      WRITE(7,713) PHILD,DPHILD
  713 FORMAT(1X,'PHILD ',1PE13.5,'  DPHILD',E13.5)
   30 CONTINUE
      IF(INOPT.EQ.2) GO TO 35
      DO 32 I=1,3
      OMEG(I)=OMEG(I)/RADIAN
   32 CONTINUE
      WRITE(7,714) PSI1,THET1,PHI1
  714 FORMAT(1X,'PSI1',1PE13.5,' THET1',E13.5,' PHI1',E13.5)
      WRITE(7,715) (OMEG(I),I=1,3)
  715 FORMAT(1X,'OMEG',1P3E13.5)
      GO TO 40
   35 CONTINUE
      WRITE(7,716) ALFAE,BETAE,GAMAE
  716 FORMAT(1X,'ALFAE',1PE13.5,' BETAE',E13.5,' GAMAE',E13.5)
      WRITE(7,717) (OMBC(I),I=1,3)
  717 FORMAT(1X,'OMBC',1P3E13.5)
   40 CONTINUE
      IF(IVISCS.EQ.0) GO TO 50
      WRITE(7,718) (YARRAY(I),I=1,3),OMEGL
  718 FORMAT(1X,'YARRAY',1P3E13.5,' OMEGL',E13.5)
   50 CONTINUE
C
      RETURN
C
      END
