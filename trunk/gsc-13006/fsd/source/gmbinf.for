      SUBROUTINE GMBINF(AZIF,ELIF)
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      COMMON/GMINTF/GMK1(2),GMK2(2),GMDMP(2),GMSTP(2)
C
      COMMON/GMBOUT/AZ,AZD,EL,ELD
C
C
      WSA=0.0D0
      DENA=DABS(AZ)
      IF(DENA.GT.GMSTP(1)) WSA=DENA-GMSTP(1)
      WSE=0.0D0
      DENE=DABS(EL)
      IF(DENE.GT.GMSTP(2)) WSE=DENE-GMSTP(2)
      IF(DENA.NE.0.0D0) WSA=WSA*AZ/DENA
      IF(DENE.NE.0.0D0) WSE=WSE*EL/DENE
      AZIF=GMK1(1)*AZ+GMK2(1)*WSA+GMDMP(1)*AZD
      ELIF=GMK1(2)*EL+GMK2(2)*WSE+GMDMP(2)*ELD
C
C
      RETURN
C
C
      END
