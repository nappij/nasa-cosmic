      SUBROUTINE MAGNTS(XMB,SA)
        IMPLICIT REAL*8 (A-H,O-Z)
C
C                       SUBROUTINE TO CALCULATE THE MAGNETIC
C                       MOMENTS ON THE SATELLITE IN THE BODY
C                       FRAME
C
      COMMON/MOMENT/IDUM(3),IMGMTS,JDUM(2)
C
      COMMON/OUTTHR/ SMAGB(3),XMB1(3),RWHEEL(3)
C
      COMMON/RMGNTC/ SMAGI(3),DPMAG(3),SFMAG,MAXGRV
C
      DIMENSION SA(3,3),XMB(3)
C
C
C
C
C
C
C
C                       ZERO MAGNETIC MOMENTS
C
C
      DO 20 I=1,3
   20 XMB(I)=0.D0
C
C
C                       HAG CALCULATES FLUX DENSITY IN
C                       ASCENDING NODE COORDINATES
C
   30 CALL HAG
C
C                       CALCULATE SMAGB
C
      DO 40 I=1,3
      SMAGB(I)=0.D0
      DO 40 J=1,3
   40 SMAGB(I)=SMAGB(I) + SA(J,I)*SMAGI(J)
C
C                       CALCULATE MOMENTS
      IF(IMGMTS.GT.1) CALL COILDP(XMB)
C
      XMB(1)=SFMAG*(SMAGB(3)*DPMAG(2) - SMAGB(2)*DPMAG(3)  + XMB(1))
      XMB(2)=SFMAG*(SMAGB(1)*DPMAG(3) - SMAGB(3)*DPMAG(1)  + XMB(2))
      XMB(3)=SFMAG*(SMAGB(2)*DPMAG(1) - SMAGB(1)*DPMAG(2)  + XMB(3))
C
      DO 50 I=1,3
   50 XMB1(I)=XMB(I)
      RETURN
C
C
      END