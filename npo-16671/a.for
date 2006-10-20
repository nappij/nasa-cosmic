      SUBROUTINE READS (PRINT, MNAM, J, C, S, NHDIM)
      DOUBLE PRECISION J(NHDIM), C(NHDIM, NHDIM), S(NHDIM, NHDIM)
      COMMON /PRAM/ NMAS, NHARM, NDISK
      LOGICAL PRINT,MNAM
      DOUBLE PRECISION COM(1)
      DOUBLE PRECISION RC,U
      COMMON RC,U,COM
      DOUBLE PRECISION RI,CO,LAI,LOI, LARAD, LORAD, RCOS
      COMMON/AMAS1/AUNMAS(1)
      COMMON/ARAD1/AUNRAD(1)
      COMMON/ALAT1/AUNLAT(1)
      COMMON/ALON1/AUNLON(1)
      COMMON /PARA/ NOPAR, NOPTCY, TOL, NTP(1)
      COMMON /PARB/ NTD(1)
      COMMON /PARC/ PARDEL(1)
      COMMON/OPT/ NOPAR2
      COMMON /LABEL/ CTYP(3,10),FTYP(3,5)
      DATA CO /.1745329251994430D-1/
C      NAMELIST/HARMS/J,C,S
      IA = 4*NMAS
      ID = IA + 2*NHARM**2 + NHARM
      NOPAR1=NOPAR-NOPAR2
      IF (PRINT) WRITE (6, 10)
   10 FORMAT (25H1ORBSIM MASCON INPUT DATA)
C
C     IF NMAS IS POSITIVE, READ DATA FOR POINT MASSES
C
      IF (NMAS .LT. 1) GO TO 80
      IF (PRINT) WRITE (6, 20)
   20 FORMAT (// 22H0POINT MASS INPUT DATA// 6H POINT, 5X,
     1 25HPOINT MASS  DISTANCE FROM, 7X, 8HLATITUDE, 6X, 9HLONGITUDE,
     2 45H   X-COORDINATE   Y-COORDINATE   Z-COORDINATE/ 25X,
     3 13HPLANET CENTER/)
      DO 70 I = 1, NMAS
      IF (MNAM) GO TO 40
      READ (5, 30) A, B, F, D
   30 FORMAT (3X, 5E12.7)
      COM(I) = DBLE(A) / U
      RI = DBLE(B)
      LAI = DBLE(F)
      LOI = DBLE(D)
      GO TO 50
   40 COM(I) = AUNMAS(I)
      RI = DBLE(AUNRAD(I))
      LAI = DBLE(AUNLAT(I))
      LOI = DBLE(AUNLON(I))
   50 I1 = I + NMAS
      I2 = I1 + NMAS
      I3 = I2 + NMAS
      LARAD = LAI*CO
      LORAD = LOI*CO
      RCOS = RI*DCOS(LARAD)
      COM(I1) = RCOS*DCOS(LORAD)
      COM(I2) = RCOS*DSIN(LORAD)
      COM(I3) = RI*DSIN(LARAD)
      IF (PRINT) WRITE (6, 60) I, COM(I), RI, LAI, LOI, COM(I1),
     1 COM(I2), COM(I3)
   60 FORMAT (I6, 7D15.8)
   70 CONTINUE
C
C     IF NHARM IS POSITIVE, READ DATA FOR SPHERICAL HARMONICS
C
   80 IF (NHARM .LT. 1) GO TO 130
      IF (PRINT) WRITE (6, 90)
   90 FORMAT (// 31H0SPHERICAL HARMONICS INPUT DATA// 5X, 1HI, 5X, 1HK,
     1 19X, 4HJ(I), 17X, 6HC(I,K), 17X, 6HS(I,K)/)
C      READ (5, HARMS)
      IS = NHARM**2 + IA
      IC = IA
      DO 120 I = 1, NHARM
      IB = IA + I
      IS = IS + NHARM
      COM(IB) = J(I)
      IC = IC + NHARM
      DO 110 K = 1, NHARM
      KC = K + IC
      KS = K + IS
      COM(KS) = S(I,K)
      COM(KC) = C(I,K)
      IF (PRINT) WRITE (6, 100) I, K, COM(I), COM(KC), COM(KS)
  100 FORMAT (2I6, 3D23.16)
  110 CONTINUE
  120 CONTINUE
C
C     IF NDISK IS POSITIVE, READ DATA FOR DISKS
C
  130 IF (NDISK .LT. 1) GO TO 160
      IF (PRINT) WRITE (6, 140)
  140 FORMAT (// 16H0DISK INPUT DATA// 6H  DISK, 6X, 9HDISK MASS,
     1 15H    DISK RADIUS, 7X, 8HLATITUDE, 6X, 20HLONGITUDE  DISTANCE ,
     2 4HFROM/ 70X, 11HMOON CENTER/)
      RCSNGL = SNGL(RC)
      DO 150 IE = 1, NDISK
      I = IE + ID
      I1 = I + NDISK
      I2 = I1 + NDISK
      I3 = I2 + NDISK
      I4 = I3 + NDISK
      READ (5, 30) A, B, F, D, E
      IF (E .GT. RCSNGL) E = RCSNGL
      IF (E .LE. 0.0) E = RCSNGL
      COM(I) = DBLE(A)
      COM(I1) = DBLE(B)
      COM(I2) = DBLE(F)
      COM(I3) = DBLE(D)
      COM(I4) = DBLE(E)
      IF (PRINT) WRITE (6, 60) IE, COM(I), COM(I1), COM(I2), COM(I3),
     1 COM(I4)
  150 CONTINUE
C
C     IF NOPAR IS POSITIVE, READ OPTIMIZATION DATA
C
  160 IF (NOPAR1 .LT. 1) GO TO 230
      IF (PRINT) WRITE (6, 170)
  170 FORMAT (//,22X,' OPTIMIZATION DATA',//,' NUMBER',7X,'TYPE',
     1 10X,'DISK',6X,'INCREMENT',/)
      DO 200 I = 1, NOPAR1
      READ (5, 180) NTP(I), NTD(I), PARDEL(I)
  180 FORMAT (5X, 2I5, E15.7)
      IRNW=NTP(I)
      IF (PRINT) WRITE (6, 190) I,(FTYP(IQ,IRNW),IQ=1,3), NTD(I),
     1 PARDEL(I)
  190 FORMAT (1X,I4,2X,3A6,I6,4X,E15.8)
  200 CONTINUE
      READ (5, 210) NOPTCY, TOL
  210 FORMAT (I5, E15.8)
      IF (NOPTCY .LT. 1) NOPTCY = 5
      IF ((TOL .LE. 0.0) .OR. (TOL .GT. PARDEL(1))) TOL = 0.1*PARDEL(1)
      IF (PRINT) WRITE (6, 220) NOPTCY, TOL
  220 FORMAT (33H0NUMBER OF OPTIMIZATION CYCLES = , I5/
     1 40H CONVERGENCE CRITERION ON INCREMENT 1 = , E15.8)
  230 IF (PRINT) WRITE (6, 240)
  240 FORMAT (1H1)
      RETURN
      END