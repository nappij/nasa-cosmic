      SUBROUTINE XXDCAL(XXD,ZLK,K,M)
C
C     'XXDCAL' CALCULATES THE MOMENT OF THE RELATIVE LINEAR MOMENTUM
C     OF AN ELEMENT IN THE ELEMENT FRAME.
C
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER*4 P,Q,R
C
      COMMON/COMALP/ SZ02(10),SZ03(10),SZ04(10),SZ12(3,10),SZ13(3,10),
     .               SZ14(3,10),SZ15(3,10),SZ16(3,10),SZ21(9,10),
     .               SZ22(9,10),SZ23(9,10),SZ25(9,10),
     .               SZ26(9,10),SZ27(9,10),SZ28(9,10),SZ31(27,10),
     .               SZ32(27,10),SZ33(27,10),SZ34(27,10),SZ35(27,10),
     .               SZ41(81,10),SZ42(81,10),SZ43(81,10)
C
      COMMON/DEBUG3/ISWTCH
C
      COMMON/IPOOL1/ IGRAV,IDAMP,IK,K1,ITIM,IAB,IAPS,IBB,IBPS,NK(10),
     .               LK(10),LLK(10)
C
      DIMENSION XXD(3,3),ZLK(10)
C
      IF(ISWTCH.EQ.0) WRITE(6,20002) K,M
C
      SUM17=0.0D0
      SUM18=0.0D0
      SUM19=0.0D0
      SUM20=0.0D0
      SUM21=0.0D0
      SUM22=0.0D0
      SUM23=0.0D0
      SUM24=0.0D0
      SUM25=0.0D0
      SUM26=0.0D0
      SUM27=0.0D0
      SUM28=0.0D0
      SUM29=0.0D0
      SUM30=0.0D0
C
      DO 40 N=1,M
      SUM7=0.0D0
      SUM8=0.0D0
      SUM9=0.0D0
      SUM10=0.0D0
      SUM11=0.0D0
      SUM12=0.0D0
      SUM13=0.0D0
      SUM14=0.0D0
      SUM15=0.0D0
      SUM16=0.0D0
C
      DO 30 P=1,M
      SUM3=0.0D0
      SUM4=0.0D0
      SUM5=0.0D0
      SUM6=0.0D0
C
      DO 20 Q=1,M
      SUM1=0.0D0
      SUM2=0.0D0
C
      DO 10 R=1,M
      A1=FUNA(K,K1,R)
      B1=FUNB(K,K1,R)
      IR=27*(N-1)+9*(P-1)+3*(Q-1)+R
      SUM1=SUM1+B1*SZ41(IR,K)
   10 SUM2=SUM2+A1*SZ41(IR,K)
C
      A1=FUNA(K,K1,Q)
      B1=FUNB(K,K1,Q)
      IQ=9*(N-1)+3*(P-1)+Q
C
      SUM3=SUM3 + B1*SUM1
      SUM4=SUM4 + A1*SUM2
      SUM5=SUM5+B1*SZ31(IQ,K)
   20 SUM6=SUM6+A1*SZ31(IQ,K)
C
      A1=FUNA(K,K1,P)
      B1=FUNB(K,K1,P)
      AD1=ADFUN(K,K1,P)
      BD1=BDFUN(K,K1,P)
      IP=3*(N-1)+P
C
      SUM7=SUM7+B1*SZ27(IP,K)
      SUM8=SUM8+A1*SZ27(IP,K)
      SUM9 =SUM9  + A1*(SUM3 + SUM4)
      SUM10=SUM10 + B1*(SUM3 + SUM4)
      SUM11=SUM11 + B1*SUM5
      SUM12=SUM12 + A1*SUM6
      SUM13=SUM13 + BD1*SUM5
      SUM14=SUM14 + AD1*SUM6
      SUM15=SUM15+AD1*SZ21(IP,K)
   30 SUM16=SUM16+BD1*SZ21(IP,K)
C
      A1  = FUNA(K,K1,N)
      B1  = FUNB(K,K1,N)
      AD1= ADFUN(K,K1,N)
      BD1= BDFUN(K,K1,N)
C
      SUM17=SUM17 + BD1*SUM7
      SUM18=SUM18 + AD1*SUM8
      SUM19=SUM19 + AD1*SUM9
      SUM20=SUM20 + BD1*SUM10
      SUM21=SUM21 + AD1*(SUM11 + SUM12)
      SUM22=SUM22+AD1*SZ14(N,K)
      SUM23=SUM23 + A1*(SUM13 + SUM14)
      SUM24=SUM24 + A1*SUM15
      SUM25=SUM25 + A1*SUM16
      SUM26=SUM26 + B1*(SUM13 + SUM14)
      SUM27=SUM27 + B1*SUM15
      SUM28=SUM28 + B1*SUM16
      SUM29=SUM29 + BD1*(SUM11 + SUM12)
   40 SUM30=SUM30+BD1*SZ14(N,K)
C
      XXD(1,1)=-(SUM18+SUM17) + ((SUM19+SUM20)/(2.D0*ZLK(K)*ZLK(K)))
      XXD(1,2)=ZLK(K)*SUM22 - SUM21/(2.D0*ZLK(K))
      XXD(1,3)=ZLK(K)*SUM30 - SUM29/(2.D0*ZLK(K))
      XXD(2,1)=-SUM23/ZLK(K)
      XXD(2,2)=SUM24
      XXD(2,3)=SUM25
      XXD(3,1)=-SUM26/ZLK(K)
      XXD(3,2)=SUM27
      XXD(3,3)=SUM28
C
      IF(ISWTCH.EQ.0) WRITE(6,10000) ((XXD(I,J),J=1,3),I=1,3)
C
      RETURN
C
10000 FORMAT('0XXD(K,J,I)',//3G15.5)
20002 FORMAT('0',5X,'XXDCAL ',2I4)
C
      END
