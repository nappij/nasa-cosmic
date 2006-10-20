      SUBROUTINE WRTPLT(TTT,AL,BE,GA,OM,PH,CC1,CC2,CC3,ITAR)
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      INTEGER*4 ACNTRL
C
      COMMON/ACCHUB/YHUB(3,6),HUBACC(3,6),ACCRED(6),DUMMY1(72)
C
      COMMON/ACFILT/ACPARM(20),IACFLT(20)
C
      COMMON/ACTOUT/AVOUT(3)
C
      COMMON/CANTNA/ A(10,3),ADOT(10,3),B(10,3),BDOT(10,3),DIN(10,3),
     .               DINDOT(10,3),DOUT(10,3),DOUTDT(10,3)
C
      COMMON/CONSTS/ PI,TWOPI,RADIAN
C
      COMMON /CSTAT/X(20),XDOT(20),CPARM(20)
C
      COMMON/CWHEEL/VWH(3),VDUMY(6)
C
      COMMON/DEBUG1/ IAFM(5)
C
      COMMON/DMMNT1/ ZKBM(6),EMAK(10),EMBK(10),ARTETA(3),CMTORK(3),
     .               ITORK,IBENDM,ITENSE,ITNS1
C
      COMMON/HAMOUT/HAMILT,IHAMLT
C
      COMMON/HOUTPT/IHCALC,IHREF,IHFLAG
C
      COMMON/HVCOUT/HBODY(3),HINERT(3),HMAG
C
      COMMON/IACC/IACOMP,IHUBAC,ITIPAC,IAFLAG
C
      COMMON /ICNTRL/KNTRL(10)
C
      COMMON/IMAIN1/ IDATE,LSAVE,INOPT,IPLOT,NUMEQS,IPLTPE,IORB,ITAPE
C
      COMMON/INEWR / NKT(10),ICP,ICPS
C
      COMMON/IPOOL1/ IGRAV,IDAMP,IK,K1,ITIM,IAB,IAPS,IBB,IBPS,NK(10),
     .               LK(10),LLK(10)
C
      COMMON/ISECBD/I2BDY
C
      COMMON/ITW   /ITWIST,ITWST1
C
      COMMON/MOMENT/ ACNTRL,IVISCS,IATTDE,IMGMTS,IWHEEL,NPULSE
C
      COMMON/NUMACC/NY
C
      COMMON/OUTFOR/ SUMMTS(3)
C
      COMMON/OUTTHR/ SMAGB(3),XMB(3),RWHEEL(3)
C
      COMMON/PLTCOM/IPLMOD,IKMOD
C
      COMMON/RPOOL9/ RT1(7),RT2(10,9),ALP(7,7),GAM(10,9,7),DEL(10,9,9)
C
      COMMON/SBDOUT/ANG2(3),ANG2D(3),DUMSB(21),OM2(3)
C
      COMMON/SUNVTR/ SSSLLL(3)
C
      COMMON/TENSON/TSS1(10)
C
      COMMON/TWIOUT/ CWO(10,3),CWDO(10,3)
C
      COMMON/VARBLS/DEPEND(150),DERIV(150)
C
      REAL*4 BUFF(450)
C
      DIMENSION OM(3),H(3),SUNV(3)
C
C     ZERO OUT PLOT BUFFER
C
      DO 10 I=1,450
      BUFF(I)=0.0E0
   10 CONTINUE
C
C     LOAD CALL LIST VARIABLES
C
      BUFF(1)=AL
      BUFF(2)=BE
      BUFF(3)=GA
      BUFF(4)=OM(1)
      BUFF(5)=OM(2)
      BUFF(6)=OM(3)
      BUFF(7)=PH
      BUFF(8)=CC1
      BUFF(9)=CC2
      BUFF(10)=CC3
C
C     LOAD REGULAR ELEMENT DISPLACEMENTS AND VELOCITIES
C
      IND=11
      NEL=IK-K1
      IF(NEL.EQ.0) GO TO 25
      DO 20 I=1,NEL
      L=I+K1
      MB=NK(L)
      IF(MB.EQ.0) GO TO 15
      DO 12 J=1,MB
      BUFF(IND  )=BUFF(IND  )+A(I,J)
      BUFF(IND+1)=BUFF(IND+1)+ADOT(I,J)
      BUFF(IND+2)=BUFF(IND+2)+B(I,J)
      BUFF(IND+3)=BUFF(IND+3)+BDOT(I,J)
   12 CONTINUE
   15 CONTINUE
      MT=NKT(L)
      IF(MT.EQ.0) GO TO 18
      DO 16 J=1,MT
      BUFF(IND+4)=BUFF(IND+4)+CWO(L,J)
      BUFF(IND+5)=BUFF(IND+5)+CWDO(L,J)
   16 CONTINUE
   18 CONTINUE
      IND=IND+6
   20 CONTINUE
   25 CONTINUE
C
C     LOAD DAMPER ELEMENT DISPLACEMENTS AND VELOCITIES
C
      IND=71
      IF(K1.EQ.0) GO TO 40
      DO 35 I=1,K1
      MB=NK(I)
      IF(MB.EQ.0) GO TO 30
      DO 27 J=1,MB
      BUFF(IND  )=BUFF(IND  )+DOUT(I,J)
      BUFF(IND+1)=BUFF(IND+1)+DOUTDT(I,J)
      BUFF(IND+2)=BUFF(IND+2)+DIN(I,J)
      BUFF(IND+3)=BUFF(IND+3)+DINDOT(I,J)
   27 CONTINUE
   30 CONTINUE
      MT=NKT(I)
      IF(MT.EQ.0) GO TO 33
      DO 32 J=1,MT
      BUFF(IND+4)=BUFF(IND+4)+CWO(I,J)
      BUFF(IND+5)=BUFF(IND+5)+CWDO(I,J)
   32 CONTINUE
   33 CONTINUE
      IND=IND+6
   35 CONTINUE
   40 CONTINUE
      IND=131
C
C     MODAL DISPLACEMENTS FOR SPECIFIC ELEMENT
C
      IF(IPLMOD.EQ.0) GO TO 60
      IF(IKMOD.LE.K1) IND=140
      DO 55 I=1,IK
      IF(IKMOD.NE.I) GO TO 55
      MB=NK(I)
      IF(MB.EQ.0) GO TO 50
      IF((I-K1).GT.0) GO TO 45
      DO 42 J=1,MB
      BUFF(IND  )=DOUT(I,J)
      BUFF(IND+1)=DIN(I,J)
      IND=IND+2
   42 CONTINUE
      GO TO 50
   45 CONTINUE
      L=I-K1
      DO 47 J=1,MB
      BUFF(IND  )=A(L,J)
      BUFF(IND+1)=B(L,J)
      IND=IND+2
   47 CONTINUE
   50 CONTINUE
      IND=137
      IF(IKMOD.LE.K1) IND=146
      MT=NKT(I)
      IF(MT.EQ.0) GO TO 60
      DO 52 J=1,MT
      BUFF(IND)=CWO(I,J)
      IND=IND+1
   52 CONTINUE
      GO TO 60
   55 CONTINUE
   60 CONTINUE
C
C     FILL THE BUFFER SPACE FOR ACCLEROMETER READING PLOT
C
      IF(IACOMP.EQ.0.AND.IHUBAC.EQ.0) GO TO 500
      INDEX=148
      DO 510 I=1,NY
      BUFF(INDEX+I)=ACCRED(I)
 510  CONTINUE
 500  CONTINUE
C
C     FILL UP THE BUFFER ARRAY FOR PRINCIPAL MOMENT OF INERTIA,
C     ANGULAR MOMENTUM VECTOR IN INERTIAL SPACE
C
      INDEX=154
      DO 610 I=1,3
 610  BUFF(INDEX+I)=ALP(I+3,I+3)
      INDEX=INDEX+3
      IF(IHCALC.EQ.0) GO TO 600
      DO 650 I=1,3
 650  H(I)=HINERT(I)/HMAG
      HALPA=DATAN2(H(2),H(1))/RADIAN
      HDELT=DARSIN(H(3))/RADIAN
      BUFF(INDEX+1)=HALPA
      BUFF(INDEX+2)=HDELT
      BUFF(INDEX+3)=HMAG
 600  CONTINUE
C
C     FILL UP THE ARRAY FOR TENSION PLOT
C
      IF(ITENSE.EQ.0.AND.IBENDM.EQ.0) GO TO 740
      IF(ITENSE.EQ.0) GO TO 720
      INDEX=160
      DO 710 K=1,IK
 710  BUFF(INDEX+K)=TSS1(K)
 720  CONTINUE
      INDEX=170
      IF(IBENDM.EQ.0) GO TO 740
      DO 741 K=1,IK
      BUFF(INDEX+1)=EMAK(K)
      BUFF(INDEX+2)=EMBK(K)
      INDEX=INDEX+2
 741  CONTINUE
 740  CONTINUE
      IF(IAFM(1).EQ.0) GO TO 760
      INDEX=190
      DO 750 I=1,3
 750  SUNV(I)=-SSSLLL(I)
      SALPA=DATAN2(SUNV(2),SUNV(1))/RADIAN
      SDELT=DARSIN(SUNV(3))/RADIAN
      BUFF(INDEX+1)=SALPA
      BUFF(INDEX+2)=SDELT
  760  CONTINUE
      IF(IMGMTS.EQ.0) GO TO 770
      INDEX=192
      DO 780 I=1,3
 780  BUFF(INDEX+I)=SMAGB(I)
 770  CONTINUE
C
C     FILL UP THE ARRAY FOR HAMILTINIAN VALUES
C
      IF(IHAMLT.EQ.0) GO TO 800
      INDEX=195
      BUFF(INDEX+1)=HAMILT
 800  CONTINUE
C
C     ADD THE ARRAY FOR BENDING MOMENT MAGNITUDE
C
      IF(IBENDM.EQ.0) GO TO 950
      INDEX=196
      DO 870 K=1,IK
  870 BUFF(INDEX+K)=DSQRT(EMAK(K)*EMAK(K)+EMBK(K)*EMBK(K))
  950 CONTINUE
C
      IF(IWHEEL.EQ.0) GO TO 960
      INDEX=206
      DO 955 I=1,3
      BUFF(INDEX+I)=VWH(I)
  955 CONTINUE
  960 CONTINUE
C
      INDEX=209
      DO 962 I=1,3
      BUFF(INDEX+I)=SUMMTS(I)
  962 CONTINUE
C
      IF(IHCALC.EQ.0) GO TO 965
      INDEX=212
      DO 964 I=1,3
      BUFF(INDEX+I)=HBODY(I)
  964 CONTINUE
C
  965 CONTINUE
C
C      TEST FOR CONTROL SYSTEM SIMULATION
      IF(KNTRL(1) .EQ. 0) GO TO 970
      INDEX=215
      DO 968 I=1,20
968   BUFF(I+INDEX)=X(I)
C
  970 CONTINUE
C
C     SECONDARY BODY OUTPUT
C
      IF(I2BDY.EQ.0) GO TO 972
      INDEX=235
      DO 971 I=1,3
      I3=I+3
      I6=I+6
      BUFF(INDEX+I)=ANG2(I)/RADIAN
      BUFF(INDEX+I3)=ANG2D(I)/RADIAN
      BUFF(INDEX+I6)=OM2(I)/RADIAN
  971 CONTINUE
  972 CONTINUE
C
      IF(IACFLT(1).EQ.0) GO TO 974
C
      INDEX=244
      DO 973 I=1,3
      BUFF(INDEX+I)=AVOUT(I)
  973 CONTINUE
  974 CONTINUE
C
      INDEX=248
C
      CALL GPPLOT(BUFF,INDEX)
C
C     WRITE PLOT BUFFER
C
      WRITE(IPLTPE) ITAR,TTT,BUFF
C
C
      RETURN
      END
