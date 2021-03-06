      SUBROUTINE SETVAL(ITEST)
C
C        COMPUTES THE FM(3,3) ARRAY FROM THE ANGLES INPUT FOR
C        THE LIBRATION DAMPER (BETLD,GAMLD,PHILD) AND ALSO SETS UP
C        INDICES FOR POINTING LATER IN THE SIMULATOR.  CALCULATES
C        ANTENNA DEPLOYMENT AND THE 'A' ARRAY
C
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER*4 DDPLY
C
C
      COMMON/CONSTS/ PI,TWOPI,RADIAN
C
      COMMON/CSTVAL/ TSTART,ZL0(10),ZL1(10),ZL2(10),ZLA(10),TTST
C
      COMMON/DEPLOY/DDPLY,MDPLY
C
      COMMON/IPOOL1/ IGRAV,IDAMP,IK,K1,ITIM,IAB,IAPS,IBB,IBPS,NK(10),
     .               LK(10),LLK(10)
C
      COMMON/LIBDPR/ ZK1D,ZK2D,PHIS,PHILD,DPHILD,BETLD,GAMLD,
     .               ZMDO,ZMDBO,CNV,DECAY
C
      COMMON/RPOOL1/ RHOK(10),TIME,SA(3,3),FM1(3,3),ZLK(10),OMEG(3),
     .               ZLKP(10),ZLKDP(10),CMAT(3,3),GBAR(3,3),YBCM(3),
     .               ZBZK(3,10),FCM(3,3),DTO,PHID,PHI
C
      COMMON/RPOOL6/ FM(3,3),CIY(3,3),CIZ(3,3),SAT(3,3),SZ1,SZ2,SZ3
C
      COMMON/VARBLS/ DEPEND(150),DERIV(150)
C
C
      IF(ITEST.EQ.2) GO TO 30
C
C
      SBET=DSIN(BETLD*RADIAN)
      CBET=DCOS(BETLD*RADIAN)
      SGAM=DSIN(GAMLD*RADIAN)
      CGAM=DCOS(GAMLD*RADIAN)
C
C
      DO 10 I=1,3
      DO 10 J=1,3
   10 FM1(I,J)=0.D0
C
C
      FM1(1,2)=-CBET*SGAM
      FM1(2,2)= CGAM
      FM1(3,2)= SBET*SGAM
C
      IA=9
      IF(IDAMP.EQ.1) IA=11
      IAB=IA + 1
      ISM=0
      IT=1
      II=1
C
      DO 20 I=1,IK
      IF(NK(I).EQ.0) GO TO 20
      ISM=ISM + NK(I)
      IF(IT.EQ.2) GO TO 20
      IT=2
      II=I
   20 CONTINUE
C
      IBB=IAB + 2*ISM
      IAPS=IAB + NK(II)
      IBPS=IBB + NK(II)
      RETURN
C
C
   30 TTST=TIME - TSTART
      TIMSQR=TTST*TTST
      DO 40 I=1,IK
      IF(MDPLY.EQ.0) ZL1(I)=0.0D0
      ZL2(I)=ZLA(I)/2.D0
      ZLK(I)=ZL0(I) + ZL1(I)*TTST + ZL2(I)*TIMSQR
      ZLKP(I)=ZL1(I) + 2.D0*ZL2(I)*TTST
   40 ZLKDP(I)=2.D0*ZL2(I)
      L1=0
C
C     RIGID BODY MOTION PARAMETERS
C
      AONE=DSQRT(DEPEND(1)**2+DEPEND(2)**2+DEPEND(3)**2)
      ATWO=DSQRT(DEPEND(4)**2+DEPEND(5)**2+DEPEND(6)**2)
      DO 50 I=1,2
      DO 50 J=1,3
      L1=L1+1
      IF(I.EQ.1) SA(I,J)=DEPEND(L1)/AONE
      IF(I.EQ.2) SA(I,J)=DEPEND(L1)/ATWO
   50 CONTINUE
      SA(3,1)=SA(1,2)*SA(2,3)-SA(1,3)*SA(2,2)
      SA(3,2)=SA(1,3)*SA(2,1)-SA(1,1)*SA(2,3)
      SA(3,3)=SA(1,1)*SA(2,2)-SA(1,2)*SA(2,1)
      ATHREE=DSQRT(SA(3,1)**2+SA(3,2)**2+SA(3,3)**2)
      SA(3,1)=SA(3,1)/ATHREE
      SA(3,2)=SA(3,2)/ATHREE
      SA(3,3)=SA(3,3)/ATHREE
      SA(2,1)=SA(1,3)*SA(3,2)-SA(1,2)*SA(3,3)
      SA(2,2)=SA(1,1)*SA(3,3)-SA(1,3)*SA(3,1)
      SA(2,3)=SA(1,2)*SA(3,1)-SA(1,1)*SA(3,2)
      ATWO=DSQRT(SA(2,1)**2+SA(2,2)**2+SA(2,3)**2)
      SA(2,1)=SA(2,1)/ATWO
      SA(2,2)=SA(2,2)/ATWO
      SA(2,3)=SA(2,3)/ATWO
      DEPEND(1)=SA(1,1)
      DEPEND(2)=SA(1,2)
      DEPEND(3)=SA(1,3)
      DEPEND(4)=SA(2,1)
      DEPEND(5)=SA(2,2)
      DEPEND(6)=SA(2,3)
C
      DO 60 I=1,3
      DO 60 J=1,3
   60 SAT(I,J)=SA(J,I)
C
      DO 65 I=1,3
   65 OMEG(I)=DEPEND(I+6)
C
C     COMPUTE THE DERIVATIVES OF THE DIRECTION COSINES
      DERIV(1)=DEPEND(2)*OMEG(3)-DEPEND(3)*OMEG(2)
      DERIV(2)=DEPEND(3)*OMEG(1)-DEPEND(1)*OMEG(3)
      DERIV(3)=DEPEND(1)*OMEG(2)-DEPEND(2)*OMEG(1)
      DERIV(4)=DEPEND(5)*OMEG(3)-DEPEND(6)*OMEG(2)
      DERIV(5)=DEPEND(6)*OMEG(1)-DEPEND(4)*OMEG(3)
      DERIV(6)=DEPEND(4)*OMEG(2)-DEPEND(5)*OMEG(1)
C
      SPHI=DSIN(PHILD)
      CPHI=DCOS(PHILD)
C
      IF(IDAMP.EQ.0) GO TO 70
      PHI=DEPEND(10)
      PHID=DEPEND(11)
      SPHI=DSIN(PHI)
      CPHI=DCOS(PHI)
C
   70 FM1(1,1)= CBET*CGAM*CPHI - SBET*SPHI
      FM1(2,1)= SGAM*CPHI
      FM1(3,1)=-CBET*SPHI - SBET*CGAM*CPHI
C
      FM1(1,3)= SBET*CPHI + CBET*CGAM*SPHI
      FM1(2,3)= SGAM*SPHI
      FM1(3,3)= CBET*CPHI - SBET*CGAM*SPHI
C
C
C
      RETURN
      END
