      SUBROUTINE FINDTW
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      COMMON/DEBUG2/ IOUT,JOUT,KLUGE
C
      COMMON/ITWWRK/NKB,NTW,NTT,ILK,ILLK
C
      COMMON/SCDINT/D01S2,D01SC,D01C2,D11S2(3),D11SC(3),D11C2(3)
     1             ,D12S2(3),D12SC(3),D12C2(3),D21S2(3,3),D21SC(3,3)
     2             ,D21C2(3,3),D22S2(3,3),D22SC(3,3),D22C2(3,3)
     3             ,D23(3,3),D24(3,3),D31S2(3,3,3),D31SC(3,3,3)
     4             ,D31C2(3,3,3),D32(3,3,3)
C
      COMMON/SCIFIN/DK21C2(3,3),DK21S2(3,3),DK22S(3,3),DK22C(3,3)
     1             ,DK23(3,3),DK24(3,3),DK31S2(3,3,3),DK31C2(3,3,3)
     2             ,DK32S(3,3,3),DK32C(3,3,3),DK33(3,3,3),DK34(3,3,3)
C
      COMMON/TWWORK/FM(3,3),A(3),AD(3),B(3),BD(3),C(3),CD(3),ZL,RO
     1             ,TSQT(3),W2,W3,EIM,ED2,ED3,EDP,GJ
C
      COMMON/TWWRK1/XX(3,3),XXD(3,3),XXDD(3),XXA(3,3,3),XXB(3,3,3)
     1             ,XXC(3,3,3),XDXA(3,3),XDXB(3,3),XDXC(3,3),XDDXA(3)
     2             ,XDDXB(3),XDDXC(3),XAX(3,3),XBX(3,3),XCX(3,3)
     3             ,DLAA(3,3),DLAB(3,3),DLAC(3,3),DLBB(3,3),DLBC(3,3)
     4             ,DLCC(3,3),VIFA(3),VIFB(3),VIFC(3)
C
      COMMON/WRKTDP/ CDMP(3)
C
      DIMENSION SK(28),SK2(6),SK3(22)
C
      DIMENSION S(139),TS1(15),TS2(59),TS3(65)
C
      EQUIVALENCE (TS1(1),S(1)),(TS2(1),S(16)),(TS3(1),S(75))
C
      EQUIVALENCE (SK2(1),SK(1)),(SK3(1),SK(7))
C
      DATA DZERO/0.0D0/
C
C
C     ZERO OUT SUMMING ARRAY S(I)
C
      DO 2 I=1,139
      S(I)=DZERO
    2 CONTINUE
C
      DO 3 I=1,28
      SK(I)=DZERO
    3 CONTINUE
C
      ZL2=ZL*ZL
      ZL3=ZL*ZL2
      CON=RO*ZL
C
C     CONSTRUCT TERMS FOR AN AND BN EQUATIONS
C
      IF(NKB.EQ.0) GO TO 100
C
      DO 80 I=1,NKB
C
C     ZERO OUT INTERMEDIATE SUMMS
C
      DO 5 II=1,12
      TS3(II)=DZERO
    5 CONTINUE
C
      DO 6 II=1,9
      TS2(II)=DZERO
    6 CONTINUE
C
      DO 7 II=1,6
      SK2(II)=DZERO
      SK3(II)=DZERO
    7 CONTINUE
C
      W11S2=D11S2(I)/ZL
      W11SC=D11SC(I)/ZL
      W11C2=D11C2(I)/ZL
C
C
      DO 40 J=1,NKB
C
      AJ=A(J)
      ADJ=AD(J)
      BJ=B(J)
      BDJ=BD(J)
C
      W21S2=D21S2(I,J)/ZL2
      W21SC=D21SC(I,J)/ZL2
      W21C2=D21C2(I,J)/ZL2
C
      WK21S=DK21S2(I,J)
      WK21C=DK21C2(I,J)
C
      DO 18 II=19,21
      TS3(II)=DZERO
   18 CONTINUE
C
      SK3(1)=DZERO
      SK3(2)=DZERO
C
      DO 20 L=1,NTW
C
      CL=C(L)
      CDL=CD(L)
C
      W31S2=D31S2(L,I,J)/ZL2
      W31SC=D31SC(L,I,J)/ZL2
      W31C2=D31C2(L,I,J)/ZL2
C
      TS3(19)=TS3(19)+CDL*W31S2
      TS3(20)=TS3(20)+CDL*W31SC
      TS3(21)=TS3(21)+CDL*W31C2
C
      WK33=DK33(L,I,J)-DK33(L,J,I)
      WK34=DK34(L,I,J)-DK34(L,J,I)
C
      SK3(1)=SK3(1)+CL*WK33
      SK3(2)=SK3(2)+CL*WK34
C
   20 CONTINUE
C
C     TWO DIMENSIONAL ARRAYS
C
C     XIU2P
C
      TS2(1)=TS2(1)+AJ*W21S2
      TS2(2)=TS2(2)+AJ*W21SC
      TS2(3)=TS2(3)+AJ*W21C2
C
C     XIU3P
C
      TS2(4)=TS2(4)+BJ*W21S2
      TS2(5)=TS2(5)+BJ*W21SC
      TS2(6)=TS2(6)+BJ*W21C2
C
C     THREE DIMENSIONAL ARRAYS
C
C     XIBETDU2P
C
      TS3(1)=TS3(1)+AJ*TS3(19)
      TS3(2)=TS3(2)+AJ*TS3(20)
      TS3(3)=TS3(3)+AJ*TS3(21)
C
C     XIBETDU3P
C
      TS3(4)=TS3(4)+BJ*TS3(19)
      TS3(5)=TS3(5)+BJ*TS3(20)
      TS3(6)=TS3(6)+BJ*TS3(21)
C
C     XIBETDU2PD
C
      TS3(7)=TS3(7)+ADJ*TS3(19)
      TS3(8)=TS3(8)+ADJ*TS3(20)
      TS3(9)=TS3(9)+ADJ*TS3(21)
C
C     XIBETDU3PD
C
      TS3(10)=TS3(10)+BDJ*TS3(19)
      TS3(11)=TS3(11)+BDJ*TS3(20)
      TS3(12)=TS3(12)+BDJ*TS3(21)
C
C     LOAD DELTA ARRAYS
C
      DLAA(I,J)=DLAA(I,J)+W2*W21C2+W3*W21S2
      DLAB(I,J)=DLAB(I,J)+W2*W21SC-W3*W21SC
      DLBB(I,J)=DLBB(I,J)+W2*W21S2+W3*W21C2
C
      SK2(1)=SK2(1)+AJ*WK21S
      SK2(2)=SK2(2)+BJ*WK21S
      SK2(3)=SK2(3)+AJ*WK21C
      SK2(4)=SK2(4)+BJ*WK21C
C
      SK3(3)=SK3(3)+AJ*SK3(1)
      SK3(4)=SK3(4)+BJ*SK3(1)
      SK3(5)=SK3(5)+AJ*SK3(2)
      SK3(6)=SK3(6)+BJ*SK3(2)
C
   40 CONTINUE
C
C     SECOND TWIST LOOP
C
      DO 45 II=7,9
      TS2(II)=DZERO
   45 CONTINUE
C
C
      DO 50 L=1,NTW
C
      CL=C(L)
      CDL=CD(L)
C
      W22S2=D22S2(L,I)/ZL
      W22SC=D22SC(L,I)/ZL
      W22C2=D22C2(L,I)/ZL
C
C     XIBETD
C
      TS2(7)=TS2(7)+CDL*W22S2
      TS2(8)=TS2(8)+CDL*W22SC
      TS2(9)=TS2(9)+CDL*W22C2
C
      SK2(5)=SK2(5)+CL*DK22S(L,I)
      SK2(6)=SK2(6)+CL*DK22C(L,I)
C
   50 CONTINUE
C
C
      XXA(I,1,1)=XXA(I,1,1)+W2*(TS2(5)+TS2(3))+W3*(TS2(1)-TS2(5))
      XXA(I,2,1)=XXA(I,2,1)-W2*W11C2-W3*W11S2
      XXA(I,2,2)=XXA(I,2,2)-W2*(0.5D0*TS2(5)+TS2(3))
     1                     +W3*(0.5D0*TS2(5)-TS2(1))
      XXA(I,2,3)=XXA(I,2,3)-0.5D0*(W2*TS2(6)+W3*TS2(4))
      XXA(I,3,1)=XXA(I,3,1)-W2*W11SC+W3*W11SC
      XXA(I,3,2)=XXA(I,3,2)-W2*(0.5D0*TS2(4)+TS2(2))
     1                     +W3*(TS2(2)-0.5D0*TS2(6))
      XXA(I,3,3)=XXA(I,3,3)-0.5D0*(W2-W3)*TS2(5)
C
      XXB(I,1,1)=XXB(I,1,1)+W2*(TS2(4)+TS2(2))-W3*(TS2(2)+TS2(6))
      XXB(I,2,1)=XXB(I,2,1)-(W2-W3)*W11SC
      XXB(I,2,2)=XXB(I,2,2)-0.5D0*(W2-W3)*TS2(2)
      XXB(I,2,3)=XXB(I,2,3)-W2*(TS2(5)+0.5D0*TS2(3))
     1                     +W3*(TS2(5)-0.5D0*TS2(1))
      XXB(I,3,1)=XXB(I,3,1)-W2*W11S2-W3*W11C2
      XXB(I,3,2)=XXB(I,3,2)-0.5D0*(W2*TS2(1)+W3*TS2(3))
      XXB(I,3,3)=XXB(I,3,3)-W2*(TS2(4)+0.5D0*TS2(2))
     1                     -W3*(TS2(6)-0.5D0*TS2(2))
C
      XDXA(I,1)=XDXA(I,1)+W2*(TS3(5)+TS3(3))+W3*(TS3(1)-TS3(5))
      XDXA(I,2)=XDXA(I,2)-W2*TS2(9)-W3*TS2(7)
      XDXA(I,3)=XDXA(I,3)-TS2(8)*(W2+W3)
C
      XDXB(I,1)=XDXB(I,1)+W2*(TS3(2)+TS3(4))-W3*(TS3(2)-TS3(6))
      XDXB(I,2)=XDXB(I,2)-TS2(8)*(W2+W3)
      XDXB(I,3)=XDXB(I,3)-W2*TS2(7)-W3*TS2(9)
C
      XDDXA(I)=XDDXA(I)+2.0D0*(W2*(TS3(12)-TS3(8))+W3*(TS3(8)+TS3(10)))
      XDDXB(I)=XDDXB(I)+2.0D0*(W2*(TS3(11)-TS3(7))+W3*(TS3(9)+TS3(11)))
C
      XAX(I,1)=XXA(I,2,3)-XXA(I,3,2)
      XAX(I,2)=XXA(I,3,1)-XXA(I,1,3)
      XAX(I,3)=XXA(I,1,2)-XXA(I,2,1)
C
      XBX(I,1)=XXB(I,2,3)-XXB(I,3,2)
      XBX(I,2)=XXB(I,3,1)-XXB(I,1,3)
      XBX(I,3)=XXB(I,1,2)-XXB(I,2,1)
C
C     INSERT GENERALISED FORCE CALCULATION
C
      VIFA(I)=(EIM*(SK2(3)+0.5D0*SK2(2))+ED2*SK2(6)-ED3*SK2(5)
     1        -EDP*SK3(4)/ZL2-GJ*SK3(6))/ZL3
C
      VIFB(I)=(EIM*(-SK2(4)+0.5D0*SK2(1))+ED2*SK2(5)+ED3*SK2(6)
     1        +EDP*SK3(3)/ZL2+GJ*SK3(5))/ZL3
C
      VIFA(I)=VIFA(I)/CON
      VIFB(I)=VIFB(I)/CON
C
   80 CONTINUE
C
      IF(IOUT.EQ.1) GO TO 85
      WRITE(6,6000)
      WRITE(6,6001) S
      WRITE(6,6000)
      WRITE(6,6001) SK
 6000 FORMAT('0',10X,'DEBUGGING OUTPUT FROM FINDTW'/)
 6001 FORMAT(' ',1P10E13.6)
   85 CONTINUE
C
C
C     ZERO OUT SUMS FOR TWIST EQUATIONS
C
      DO 90 II=1,139
      S(II)=DZERO
   90 CONTINUE
C
      DO 95 II=1,28
      SK(II)=DZERO
   95 CONTINUE
C
C
  100 CONTINUE
C
C     CONSTRUCT TWIST EQUATION
C
      DO 180 I=1,NTW
C
      CDI=CD(I)
C
      W12S2=D12S2(I)
      W12SC=D12SC(I)
      W12C2=D12C2(I)
C
      IF(NKB.EQ.0) GO TO 150
C
      DO 105 II=1,12
      TS2(II)=DZERO
  105 CONTINUE
C
      DO 140 J=1,NKB
C
      AJ=A(J)
      ADJ=AD(J)
      BJ=B(J)
      BDJ=BD(J)
C
      W22S2=D22S2(I,J)/ZL
      W22SC=D22SC(I,J)/ZL
      W22C2=D22C2(I,J)/ZL
C
      WK22S=DK22S(I,J)
      WK22C=DK22C(I,J)
C
      DO 116 II=1,7
      SK3(II)=DZERO
  116 CONTINUE
C
      DO 117 II=13,22
      TS2(II)=DZERO
  117 CONTINUE
C
      DO 118 II=1,14
      TS3(II)=DZERO
  118 CONTINUE
C
      DO 120 L=1,NKB
C
      AL=A(L)
      ADL=AD(L)
      BL=B(L)
      BDL=BD(L)
C
      W31S2=D31S2(I,J,L)/ZL2
      W31SC=D31SC(I,J,L)/ZL2
      W31C2=D31C2(I,J,L)/ZL2
C
      W32=D32(I,J,L)/ZL2
C
      WK31S=DK31S2(I,J,L)
      WK31C=DK31C2(I,J,L)
      WK33=DK33(I,J,L)
      WK34=DK34(I,J,L)
C
      TS3(1)=TS3(1)+AL*W31S2
      TS3(2)=TS3(2)+AL*W31SC
      TS3(3)=TS3(3)+AL*W31C2
C
      TS3(4)=TS3(4)+BL*W31S2
      TS3(5)=TS3(5)+BL*W31SC
      TS3(6)=TS3(6)+BL*W31C2
C
      TS3(7)=TS3(7)+ADL*W31S2
      TS3(8)=TS3(8)+ADL*W31SC
      TS3(9)=TS3(9)+ADL*W31C2
C
      TS3(10)=TS3(10)+BDL*W31S2
      TS3(11)=TS3(11)+BDL*W31SC
      TS3(12)=TS3(12)+BDL*W31C2
C
      TS3(13)=TS3(13)+AL*W32
      TS3(14)=TS3(14)+BL*W32
C
      SK3(1)=SK3(1)+AL*WK31S
      SK3(2)=SK3(2)+BL*WK31S
      SK3(3)=SK3(3)+BL*WK31C
      SK3(4)=SK3(4)+AL*WK33
      SK3(5)=SK3(5)+BL*WK33
      SK3(6)=SK3(6)+AL*WK34
      SK3(7)=SK3(7)+BL*WK34
C
      IF(I.GT.1) GO TO 120
C
      W21S2=D21S2(J,L)
      W21SC=D21SC(J,L)
      W21C2=D21C2(J,L)
C
      TS2(13)=TS2(13)+AL*W21S2
      TS2(14)=TS2(14)+AL*W21SC
      TS2(15)=TS2(15)+AL*W21C2
C
      TS2(16)=TS2(16)+BL*W21S2
      TS2(17)=TS2(17)+BL*W21SC
      TS2(18)=TS2(18)+BL*W21C2
C
      TS2(19)=TS2(19)+ADL*W21S2
      TS2(20)=TS2(20)+ADL*W21SC
      TS2(21)=TS2(21)+ADL*W21C2
C
      TS2(22)=TS2(22)+BDL*W21SC
C
C
C
  120 CONTINUE
C
C     BETU2P
C
      TS2(1)=TS2(1)+AJ*W22S2
      TS2(2)=TS2(2)+AJ*W22SC
      TS2(3)=TS2(3)+AJ*W22C2
C
C     BETU3P
C
      TS2(4)=TS2(4)+BJ*W22S2
      TS2(5)=TS2(5)+BJ*W22SC
      TS2(6)=TS2(6)+BJ*W22C2
C
C     BETU2PD
C
      TS2(7)=TS2(7)+ADJ*W22S2
      TS2(8)=TS2(8)+ADJ*W22SC
      TS2(9)=TS2(9)+ADJ*W22C2
C
C     BETU3PD
C
      TS2(10)=TS2(10)+BDJ*W22S2
      TS2(11)=TS2(11)+BDL*W22SC
      TS2(12)=TS2(12)+BDJ*W22C2
C
C     BETU2PU2P
      TS3(15)=TS3(15)+AJ*TS3(1)
      TS3(16)=TS3(16)+AJ*TS3(2)
      TS3(17)=TS3(17)+AJ*TS3(3)
C
C     BETU2PU3P
C
      TS3(18)=TS3(18)+AJ*TS3(4)
      TS3(19)=TS3(19)+AJ*TS3(5)
      TS3(20)=TS3(20)+AJ*TS3(6)
C
C     BETU3PU3P
C
      TS3(21)=TS3(21)+BJ*TS3(4)
      TS3(22)=TS3(22)+BJ*TS3(5)
      TS3(23)=TS3(23)+BJ*TS3(6)
C
C     BETU2PU2PD
C
      TS3(24)=TS3(24)+AJ*TS3(7)
      TS3(25)=TS3(25)+AJ*TS3(8)
      TS3(26)=TS3(26)+AJ*TS3(9)
C
C     BETU2PU3PD
C
      TS3(27)=TS3(27)+AJ*TS3(10)
      TS3(28)=TS3(28)+AJ*TS3(11)
      TS3(29)=TS3(29)+AJ*TS3(12)
C
C     BETU3PU2PD
C
      TS3(30)=TS3(30)+BJ*TS3(7)
      TS3(31)=TS3(31)+BJ*TS3(8)
      TS3(32)=TS3(32)+BJ*TS3(9)
C
C     BETU3PU3PD
C
      TS3(33)=TS3(33)+BJ*TS3(10)
      TS3(34)=TS3(34)+BJ*TS3(11)
      TS3(35)=TS3(35)+BJ*TS3(12)
C
C     BETU2PDU2PD
C
      TS3(36)=TS3(36)+ADJ*TS3(7)
      TS3(37)=TS3(37)+ADJ*TS3(8)
      TS3(38)=TS3(38)+ADJ*TS3(9)
C
C     BETU2PDU3PD
C
      TS3(39)=TS3(39)+ADJ*TS3(10)
      TS3(40)=TS3(40)+ADJ*TS3(11)
      TS3(41)=TS3(41)+ADJ*TS3(12)
C
C     BETU3PDU3PD
C
      TS3(42)=TS3(42)+BDJ*TS3(10)
      TS3(43)=TS3(43)+BDJ*TS3(11)
      TS3(44)=TS3(44)+BDJ*TS3(12)
C
C     LOAD DELTA COUPLING MATRICES
C
      DLAC(J,I)=DLAC(J,I)+0.5D0*TS3(14)*(W2+W3)
      DLBC(J,I)=DLBC(J,I)+0.5D0*TS3(13)*(W2+W3)
C
C     INTERNAL GENERALISED FORCE FOR TWIST EQUATION
C
      SK2(1)=SK2(1)+AJ*WK22S
      SK2(2)=SK2(2)+BJ*WK22S
      SK2(3)=SK2(3)+AJ*WK22C
      SK2(4)=SK2(4)+BJ*WK22C
C
      SK3(9)=SK3(9)+AJ*SK3(1)
      SK3(10)=SK3(10)+BJ*SK3(2)
      SK3(11)=SK3(11)+AJ*SK3(3)
C
      SK3(12)=SK3(12)+BJ*SK3(4)
      SK3(13)=SK3(13)+AJ*SK3(5)
C
      SK3(14)=SK3(14)+BJ*SK3(6)
      SK3(15)=SK3(15)+AJ*SK3(7)
C
      SK3(20)=DZERO
      SK3(21)=DZERO
C
      DO 130 L=1,NTW
      CL=C(L)
C
      SK3(20)=SK3(20)+CL*DK32S(I,L,J)
      SK3(21)=SK3(21)+CL*DK32C(I,L,J)
C
  130 CONTINUE
C
      SK3(16)=SK3(16)+AJ*SK3(20)
      SK3(17)=SK3(17)+BJ*SK3(20)
      SK3(18)=SK3(18)+AJ*SK3(21)
      SK3(19)=SK3(19)+BJ*SK3(21)
C
C     CONSTRUCT BENDING TERMS FOR SYSTEM EQUATIONS - ONE TIME ONLY
C
      IF(I.GT.1) GO TO 140
C
C     U2P
      W11S2=D11S2(J)
      W11SC=D11SC(J)
      W11C2=D11C2(J)
C
      TS1(1)=TS1(1)+AJ*W11S2
      TS1(2)=TS1(2)+AJ*W11SC
      TS1(3)=TS1(3)+AJ*W11C2
C
C     U3P
C
      TS1(4)=TS1(4)+BJ*W11S2
      TS1(5)=TS1(5)+BJ*W11SC
      TS1(6)=TS1(6)+BJ*W11C2
C
C     U2PD
C
      TS1(7)=TS1(7)+ADJ*W11S2
      TS1(8)=TS1(8)+ADJ*W11SC
      TS1(9)=TS1(9)+ADJ*W11C2
C
C     U3PD
C
      TS1(10)=TS1(10)+BDJ*W11S2
      TS1(11)=TS1(11)+BDJ*W11SC
      TS1(12)=TS1(12)+BDJ*W11C2
C
C     TWO DIMENSIONAL SUMS
C
C     U2PU2P
C
      TS2(23)=TS2(23)+AJ*TS2(13)
      TS2(24)=TS2(24)+AJ*TS2(14)
      TS2(25)=TS2(25)+AJ*TS2(15)
C
C     U2PU3P
C
      TS2(26)=TS2(26)+BJ*TS2(13)
      TS2(27)=TS2(27)+BJ*TS2(14)
      TS2(28)=TS2(28)+BJ*TS2(15)
C
C     U3PU3P
C
      TS2(29)=TS2(29)+BJ*TS2(16)
      TS2(30)=TS2(30)+BJ*TS2(17)
      TS2(31)=TS2(31)+BJ*TS2(18)
C
C     U2PU2PD
C
      TS2(32)=TS2(32)+ADJ*TS2(13)
      TS2(33)=TS2(33)+ADJ*TS2(14)
      TS2(34)=TS2(34)+ADJ*TS2(15)
C
C     U3PU3PD
C
      TS2(35)=TS2(35)+BDJ*TS2(16)
      TS2(36)=TS2(36)+BDJ*TS2(17)
      TS2(37)=TS2(37)+BDJ*TS2(18)
C
C     U3PU2PD
C
      TS2(38)=TS2(38)+ADJ*TS2(16)
      TS2(39)=TS2(39)+ADJ*TS2(17)
      TS2(40)=TS2(40)+ADJ*TS2(18)
C
C     U2PU3PD
C
      TS2(41)=TS2(41)+BDJ*TS2(13)
      TS2(42)=TS2(42)+BDJ*TS2(14)
      TS2(43)=TS2(43)+BDJ*TS2(15)
C
C     U2PDU2PDSC
      TS2(44)=TS2(44)+ADJ*TS2(20)
C     U3PDU3PDSC
      TS2(45)=TS2(45)+BDJ*TS2(22)
C     U2PDU3PDS2
      TS2(46)=TS2(46)+BDJ*TS2(19)
C     U2PDU3PDC2
      TS2(47)=TS2(47)+BDJ*TS2(21)
C
C
C
  140 CONTINUE
C
C
  150 CONTINUE
C
C     CALCULATE TWIST EQUATION BASIC ARRAYS
C
      XXC(I,1,1)=XXC(I,1,1)+(W2-W3)*(TS3(17)-TS3(15)+TS3(22)-TS3(16))
      XXC(I,1,2)=XXC(I,1,2)+W2*(TS2(4)+TS2(2))+W3*(TS2(6)-TS2(2))
      XXC(I,1,3)=XXC(I,1,3)-W2*(TS2(5)+TS2(3))+W3*(TS2(5)-TS2(1))
      XXC(I,2,1)=XXC(I,2,1)+W2*(TS2(2)-TS2(6))-W3*(TS2(2)+TS2(4))
      XXC(I,2,2)=XXC(I,2,2)-(W2-W3)*(W12SC-TS3(16)+0.5D0*(TS3(20)
     1                                 -TS3(18)))
      XXC(I,2,3)=XXC(I,2,3)+W2*(W12C2-0.5D0*(TS3(17)+TS3(23)))
     1                     +W3*(W12S2-0.5D0*(TS3(15)+TS3(21)))
      XXC(I,3,1)=XXC(I,3,1)+W2*(-TS2(5)+TS2(1))+W3*(TS2(5)+TS2(3))
      XXC(I,3,2)=XXC(I,3,2)-W2*(W12S2-0.5D0*(TS3(15)+TS3(21)))
     1                     -W3*(W12C2-0.5D0*(TS3(17)+TS3(23)))
      XXC(I,3,3)=XXC(I,3,3)+(W2-W3)*(W12SC-TS3(22)
     1                             -0.5D0*(TS3(20)-TS3(18)))
C
      XDXC(I,1)=XDXC(I,1)-W2*(TS3(26)+TS3(33)+TS3(28)+TS3(31))
     1                   +W3*(TS3(28)+TS3(31)-TS3(24)-TS3(35))
      XDXC(I,2)=XDXC(I,2)+W2*(TS2(11)+TS2(9))+W3*(TS2(11)-TS2(7))
      XDXC(I,3)=XDXC(I,3)+W2*(TS2(10)+TS2(8))+W3*(TS2(12)-TS2(8))
C
      XDDXC(I)=XDDXC(I)+W2*(TS3(37)-TS3(43)-TS3(41)+TS3(39))
     1                 +W3*(TS3(43)-TS3(37)+TS3(41)-TS3(39))
C
      XCX(I,1)=XXC(I,2,3)-XXC(I,3,2)
      XCX(I,2)=XXC(I,3,1)-XXC(I,1,3)
      XCX(I,3)=XXC(I,1,2)-XXC(I,2,1)
C
C
      DO 160 J=1,NTW
      DLCC(I,J)=DLCC(I,J)+(W2+W3)*D23(I,J)
C
      CJ=C(J)
C
      SK2(5)=SK2(5)+CJ*DK23(I,J)
      SK2(6)=SK2(6)+CJ*DK24(I,J)
C
  160 CONTINUE
C
      VIFC(I)=(EIM*(SK3(10)-SK3(9)+SK3(11))
     1        +ED2*(SK2(2)+SK2(3)-SK3(16)+SK3(19))
     2        -ED3*(SK2(1)-SK2(4)+SK3(17)+SK3(18))
     3        +EDP*(SK2(5)+(SK3(12)-SK3(13))/ZL2)
     4        +GJ*(SK2(6)*ZL2+SK3(14)-SK3(15)))/ZL3
C
C
      VIFC(I)=VIFC(I)+CDMP(I)*CDI
      VIFC(I)=VIFC(I)/CON
C
C     CONSTRUCT TERMS FOR SYSTEM EQUATIONS
C
C     PHID
C
      TS1(13)=TS1(13)+CDI*W12S2
      TS1(14)=TS1(14)+CDI*W12SC
      TS1(15)=TS1(15)+CDI*W12C2
C
C     TWO DIMENSIONAL TERMS
C
C     PHIDU2P
C
      TS2(48)=TS2(48)+CDI*TS2(1)
      TS2(49)=TS2(49)+CDI*TS2(2)
      TS2(50)=TS2(50)+CDI*TS2(3)
C
C     PHIDU3P
C
      TS2(51)=TS2(51)+CDI*TS2(4)
      TS2(52)=TS2(52)+CDI*TS2(5)
      TS2(53)=TS2(53)+CDI*TS2(6)
C
C     PHIDU2PD
C
      TS2(54)=TS2(54)+CDI*TS2(7)
      TS2(55)=TS2(55)+CDI*TS2(8)
      TS2(56)=TS2(56)+CDI*TS2(9)
C
C     PHIDU3PD
C
      TS2(57)=TS2(57)+CDI*TS2(10)
      TS2(58)=TS2(58)+CDI*TS2(11)
      TS2(59)=TS2(59)+CDI*TS2(12)
C
C     THREE DIMENSIONAL TERMS
C
C     PHIDU2PU2P
C
      TS3(45)=TS3(45)+CDI*TS3(15)
      TS3(46)=TS3(46)+CDI*TS3(16)
      TS3(47)=TS3(47)+CDI*TS3(17)
C
C     PHIDU2PU3P
C
      TS3(48)=TS3(48)+CDI*TS3(18)
      TS3(49)=TS3(49)+CDI*TS3(19)
      TS3(50)=TS3(50)+CDI*TS3(20)
C
C     PHIDU3PU3P
C
      TS3(51)=TS3(51)+CDI*TS3(21)
      TS3(52)=TS3(52)+CDI*TS3(22)
      TS3(53)=TS3(53)+CDI*TS3(23)
C
C     PHIDU2PU2PD
C
      TS3(54)=TS3(54)+CDI*TS3(24)
      TS3(55)=TS3(55)+CDI*TS3(25)
      TS3(56)=TS3(56)+CDI*TS3(26)
C
C     PHIDU2PU3PD
C
      TS3(57)=TS3(57)+CDI*TS3(27)
      TS3(58)=TS3(58)+CDI*TS3(28)
      TS3(59)=TS3(59)+TS3(29)
C
C     PHIDU3PU2PD
C
      TS3(60)=TS3(60)+CDI*TS3(30)
      TS3(61)=TS3(61)+CDI*TS3(31)
      TS3(62)=TS3(62)+CDI*TS3(32)
C
C     PHIDU3PU3PD
C
      TS3(63)=TS3(63)+CDI*TS3(33)
      TS3(64)=TS3(64)+CDI*TS3(34)
      TS3(65)=TS3(65)+CDI*TS3(35)
C
C
C
  180 CONTINUE
C
C     AUGMENT SYSTEM MATRICES
C
      XX(1,1)=XX(1,1)+W2*(TS2(29)+TS2(25)+2.0D0*TS2(27))
     1               +W3*(TS2(23)+TS2(31)-2.0D0*TS2(27))
      XX(1,2)=XX(1,2)-W2*(TS1(3)+TS1(5))-W3*(TS1(1)-TS1(5))
      XX(1,3)=XX(1,3)-W2*(TS1(2)+TS1(4))+W3*(TS1(2)-TS1(6))
      XX(2,1)=XX(1,2)
      XX(2,2)=XX(2,2)+W2*(D01C2-TS2(31)-TS2(27))
     1               +W3*(D01S2-TS2(23)+TS2(27))
      XX(2,3)=XX(2,3)+W2*(D01SC-0.5D0*(TS2(24)+TS2(30)+TS2(26)+TS2(28)))
     1               -W3*(D01SC-0.5D0*(TS2(24)+TS2(30)-TS2(26)-TS2(28)))
      XX(3,1)=XX(1,3)
      XX(3,2)=XX(2,3)
      XX(3,3)=XX(3,3)+W2*(D01S2-TS2(29)-TS2(27))
     1               +W3*(D01C2-TS2(31)+TS2(27))
C
C
C
      XXD(1,1)=XXD(1,1)+W2*(TS2(35)+TS2(34)+TS2(42)+TS2(39)
     1                     +TS3(50)-TS3(48)+TS3(52)-TS3(46))
     2                 +W3*(TS2(32)+TS2(37)-TS2(42)-TS2(39)
     3                     -TS3(53)+TS3(46)-TS3(52)+TS3(46))
      XXD(1,2)=XXD(1,2)+W2*(TS2(51)+TS2(49))+W3*(TS2(53)-TS2(49))
      XXD(1,3)=XXD(1,3)-W2*(TS2(52)+TS2(50))-W3*(TS2(48)-TS2(52))
      XXD(2,1)=XXD(2,1)-W2*(TS1(9)+TS1(11)-TS2(49)+TS2(53))
     1                 -W3*(TS1(7)-TS1(11)+TS2(51)+TS2(49))
      XXD(2,2)=XXD(2,2)-W2*(TS2(34)+0.5D0*(TS2(42)+TS2(39))
     1                     +TS1(14)-TS3(46)-0.5D0*(TS3(50)-TS3(48)))
     2                 -W3*(TS2(32)-0.5D0*(TS2(42)+TS2(39))
     3                     -TS1(14)+TS3(46)+0.5D0*(TS3(50)-TS3(48)))
      XXD(2,3)=XXD(2,3)-W2*(TS2(36)+0.5D0*(TS2(43)+TS2(40))
     1                     -TS1(15)+0.5D0*(TS3(47)+TS3(53)))
     2                 +W3*(TS2(36)-0.5D0*(TS2(41)+TS2(38))
     3                     +TS1(13)-0.5D0*(TS3(45)+TS3(51)))
      XXD(3,1)=XXD(3,1)-W2*(TS1(10)+TS1(8)-TS2(48)+TS2(52))
     1                 +W3*(TS1(8)-TS1(10)+TS2(50)+TS2(52))
      XXD(3,2)=XXD(3,2)-W2*(TS2(33)+0.5D0*(TS2(41)+TS2(38))
     1                     +TS1(13)-0.5D0*(TS3(45)+TS3(51)))
     2                 +W3*(TS2(33)-0.5D0*(TS2(43)+TS2(40))
     3                     -TS1(15)+0.5D0*(TS3(47)+TS3(53)))
      XXD(3,3)=XXD(3,3)-W2*(TS2(35)+0.5D0*(TS2(42)+TS2(39))
     1                     -TS1(14)+TS3(52)+0.5D0*(TS3(50)-TS3(48)))
     2                 -W3*(TS2(37)-0.5D0*(TS2(42)+TS2(39))
     3                     +TS1(14)-TS3(52)-0.5D0*(TS3(50)-TS3(48)))
C
C
C
      XXDD(1)=XXDD(1)-W2*(TS2(45)-TS2(44)+TS2(47)-TS2(46)
     1                   +2.0D0*(TS3(54)+TS3(65)-TS3(58)-TS3(61)))
     2               +W3*(TS2(47)-TS2(46)+TS2(45)-TS2(44)
     3                   -2.0D0*(TS3(63)+TS3(56)+TS3(58)+TS3(61)))
      XXDD(2)=XXDD(2)+2.0D0*(W2*(TS2(54)-TS2(58))+W3*(TS2(56)+TS2(58)))
      XXDD(3)=XXDD(3)+2.0D0*(W2*(TS2(59)-TS2(55))+W3*(TS2(55)+TS2(57)))
C
C
      IF(IOUT.EQ.1) GO TO 190
      WRITE(6,6000)
      WRITE(6,6001) S
      WRITE(6,6000)
      WRITE(6,6001) SK
      WRITE(6,6000)
      WRITE(6,6001) XX
      WRITE(6,6001) XXD
      WRITE(6,6001) XXDD
  190 CONTINUE
C
C
C
      RETURN
C
C
      END