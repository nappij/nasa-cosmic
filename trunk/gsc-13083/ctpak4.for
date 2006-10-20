      SUBROUTINE CTPAK4(NVEC,VECIN,VECOUT,ROTMX,SHIFT,FACTOR,
     *                  KSPEC1,KSPEC2,LUERR,IERR)
      IMPLICIT REAL*8(A-H,O-Z)
C
C PURPOSE: THIS ROUTINE IS PART OF THE COORDINATE TRANSFORMATION
C          PACKAGE. IT PERFORMS THE ROTATIONS AND TRANSLATIONS USING
C          QUANTITIES PREVIOUSLY COMPUTED.
C
C***********************************************************************
C
C BY K PACKARD 4/83
C    MODIFICATIONS - MAJOR MODS BY C PETRUZZO, 10/83
C
C***********************************************************************
C
      REAL*8 ROTMX(3,3,2),SHIFT(3,2),FACTOR(2)
      LOGICAL NEEDROT1,NEEDROT2,NEEDSHIFT1,NEEDSHIFT2,NEEDFAC1,NEEDFAC2
      REAL*8 VECIN(3,1),VECOUT(3,1)   ! ACTUALLY, DIM = (3,NVEC)
      INTEGER KSPEC1(3),KSPEC2(3)
C 
      DIMENSION VTEMP(3),VTEMPX(3)
C
C
C THIS ROUTINE TRANSFORMS VECIN TO VECOUT IN TWO STEPS:
C
C         (1) TRANSFORM VECIN FROM INPUT SYSTEM TO
C             MEAN OF 1950.0, GEOCENTRIC.
C
C             VTEMP = ROTMX(,,1)*VECIN + SHIFT(,1)
C
C             WHERE ROTMX1 CHANGES THE ORIENTATION AND SHIFT(,1) 
C             CHANGES THE ORIGIN. SHIFT(,1) IS THE LOCATION OF THE INPUT
C             ORIGIN IN GEOCENTRIC MEAN OF 1950.0 COORDINATES.
C
C         (2) TRANSFORM VTEMP FROM MEAN OF 1950.0, GEOCENTRIC, TO
C             THE OUTPUT SYSTEM.
C
C             VECOUT = ROTMX(,,2)(TRANSPOSE) * (VTEMP-SHIFT(,2))
C
C             WHERE SHIFT(,2) CHANGES THE ORIGIN TO THE OUTPUT LOCATION
C             AND ROTMX2 CHANGES THE ORIENTATION. SHIFT(,2) IS THE 
C             LOCATION OF THE OUTPUT ORIGIN IN GEOCENTRIC MEAN OF 1950.0
C             COORDINATES.
C
C
      IBUG=0
      LUBUG=19
C
      IF(IBUG.NE.0) WRITE(LUBUG,9011) FACTOR,KSPEC1,KSPEC2,
     *      NVEC,(I,(VECIN(J,I),J=1,3),I=1,NVEC)
 9011 FORMAT(/,' CTPAK4 DEBUG. FACTOR=',2G14.6/,
     *         '    KSPEC1=',3I4,'    KSPEC2=',3I4,'   NVEC=',I5/,
     *         '    VECIN=',<NVEC>(T10,I3,3X,3G16.8/))
C
      IF(NVEC.LE.0) GO TO 9999
C
      NEEDROT1  =  KSPEC1(1).NE.1  ! VECIN ORIENTATION IS NOT 1950.0
      NEEDSHIFT1 = KSPEC1(2).NE.1  ! VECIN ORIGIN IS NOT EARTH CENTER
      NEEDFAC1  =  KSPEC1(3).NE.1  ! VECIN LENGTH UNIT IS KM
C
      NEEDROT2 =   KSPEC2(1).NE.1  ! VECOUT ORIENTATION IS NOT 1950.0
      NEEDSHIFT2 = KSPEC2(2).NE.1  ! VECOUT ORIGIN IS NOT EARTH CENTER
      NEEDFAC2 =   KSPEC2(3).NE.1  ! VECOUT LENGTH UNIT IS KM
C
C
      DO 10 IVEC = 1,NVEC
C
C SCALE INPUT LENGTH UNIT TO KILOMETERS
C
      IF(NEEDFAC1) THEN
        VTEMP(1) = VECIN(1,IVEC) * FACTOR(1)
        VTEMP(2) = VECIN(2,IVEC) * FACTOR(1)
        VTEMP(3) = VECIN(3,IVEC) * FACTOR(1)
      ELSE
        VTEMP(1) = VECIN(1,IVEC)
        VTEMP(2) = VECIN(2,IVEC)
        VTEMP(3) = VECIN(3,IVEC)
        END IF
C
C CONVERT FROM THE INPUT SYSTEM TO GEOCENTRIC, MEAN OF 1950.0
C
C    ROTATE TO MEAN OF 1950.0 ORIENTATION
      IF(NEEDROT1) THEN      ! IF NOT, SYS1 IS 1950.0, ROTMX1=IDENTITY
        CALL VECROT(ROTMX(1,1,1),VTEMP,VTEMP)
        END IF
C
C    SHIFT ORIGIN TO GEOCENTER
      IF(NEEDSHIFT1) THEN    ! IF NOT, ORIGIN1 IS EARTH CENTER, SHIFT1=0
        VTEMP(1) = VTEMP(1) + SHIFT(1,1)
        VTEMP(2) = VTEMP(2) + SHIFT(2,1)
        VTEMP(3) = VTEMP(3) + SHIFT(3,1)
        END IF
C
C
C CONVERT FROM GEOCENTRIC, MEAN OF 1950.0 THE OUTPUT SYSTEM.
C
C    SHIFT ORIGIN TO OUTPUT ORIGIN
      IF(NEEDSHIFT2) THEN    ! IF NOT, ORIGIN2 IS EARTH CENTER, SHIFT2=0
        VTEMP(1) = VTEMP(1) - SHIFT(1,2)
        VTEMP(2) = VTEMP(2) - SHIFT(2,2)
        VTEMP(3) = VTEMP(3) - SHIFT(3,2)
        END IF
C
C    ROTATE TO OUTPUT SYSTEM ORIENTATION
      IF(NEEDROT2) THEN      ! IF NOT, SYS2 IS 1950.0, ROTMX2=IDENTITY
        CALL MTXMUL2(ROTMX(1,1,2),VTEMP,VTEMPX,3,3,1)
        VTEMP(1) = VTEMPX(1)
        VTEMP(2) = VTEMPX(2)
        VTEMP(3) = VTEMPX(3)
        END IF
C
C
C SCALE FROM KM TO OUTPUT LENGTH UNIT
C
      IF(NEEDFAC2) THEN
        VECOUT(1,IVEC) = VTEMP(1) * FACTOR(2)
        VECOUT(2,IVEC) = VTEMP(2) * FACTOR(2)
        VECOUT(3,IVEC) = VTEMP(3) * FACTOR(2)
      ELSE
        VECOUT(1,IVEC) = VTEMP(1)
        VECOUT(2,IVEC) = VTEMP(2)
        VECOUT(3,IVEC) = VTEMP(3)
        END IF
C
   10 CONTINUE
C
 9999 CONTINUE
      RETURN
      END
