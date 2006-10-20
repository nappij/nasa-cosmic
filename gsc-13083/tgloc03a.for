      SUBROUTINE TGLOC03A(NPARMS,PARMS,TARGNAME,LUERR,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE IS PART OF THE TOSS TARGET LOCATION PACKAGE, TGLOC.
C THIS IS A SERVICE ROUTINE FOR TGLOC03.  IT VERIFIES THAT THE RIGHT
C ASCENSION AND DECLINATION VALUES ARE WITHIN VALID LIMITS.
C
C VAR     DIM    TYPE I/O DESCRIPTION
C ---     ---    ---- --- -----------
C
C NPARMS   1      I*4  I  THE NUMBER OF PARAMETERS SUPPLIED IN THE PARMS
C                         ARRAY.  MUST BE 2 OR GREATER.
C
C PARMS  NPARMS   R*8  I  PARAMETERS ASSOCIATED WITH THIS TARGET.  SAME
C                         DESCRIPTION AS IS GIVEN IN TGLOC FOR TARGET
C                         TYPE 3.
C
C TARGNAME 1     CH*16 I  THE NAME OF THE TARGET FOR WHICH THE PARMS
C                         ARRAY IS BEING CHECKED.  USED FOR ERROR
C                         MESSAGES.
C
C LUERR    1      I*4  I  FORTRAN UNIT NUMBER FOR ERROR MESSAGES.
C                          = 0/NEGATIVE, NO MESSAGES POSSIBLE.
C
C IERR     1      I*4   O ERROR RETURN FLAG.
C                          = 0, NO ERROR.
C                          = OTHERWISE, ERROR.
C
C***********************************************************************
C
C BY C PETRUZZO, GSFC/742, 8/85.
C        MODIFIED....
C
C***********************************************************************
C
      REAL*8 PARMS(1)
      PARAMETER NUMNEED = 2
      LOGICAL OKALL,OK(NUMNEED)
      CHARACTER*16 TARGNAME
      INTEGER INIT/0/
C
      REAL*8 HALFPI / 1.570796326794897D0 /
      REAL*8 PI     / 3.141592653589793D0 /
      REAL*8 TWOPI  / 6.283185307179586D0 /
      REAL*8 DEGRAD / 57.29577951308232D0 /
C
C
C ERROR CHECK.  IF NPARMS IS SMALLER THAN REQUIRED, THEN THE ERROR
C SHOULD HAVE BEEN FOUND IN TGLOC00A.  THIS ROUTINE SHOULD NOT HAVE
C BEEN CALLED.
C
      IF(NPARMS.LT.NUMNEED) THEN
        TYPE *,' TGLOC03A. CODING ERROR. STOPPED. SEE SOURCE.'
        STOP   ' TGLOC03A. CODING ERROR. STOPPED. SEE SOURCE.'
        END IF
C
C INITIALIZE.
C
      IERR = 0
      IF(INIT.EQ.0) THEN
        INIT = 1
        RLIMIT1 =  TWOPI * (1.D0+1.D-8)
        RLIMIT2 = HALFPI * (1.D0+1.D-8)
        END IF
C
C CHECK RIGHT ASCENSION.
C
      OK(1) = DABS(PARMS(1)) .LT. RLIMIT1
C
C CHECK DECLINATION.
C
      OK(2) = DABS(PARMS(2)) .LT. RLIMIT2
C
C CHECK FOR ALL OK.
C
      OKALL = .TRUE.
      DO I=1,NUMNEED
        OKALL = OKALL .AND. OK(I)
        END DO
C
      IF(.NOT.OKALL) THEN
        IERR = 1
        IF(LUERR.GT.0) WRITE(LUERR,1001) TARGNAME,
     *     PARMS(1)*DEGRAD,
     *     PARMS(2)*DEGRAD
 1001   FORMAT(/,
     *     ' TGLOC03A. PARAMETER ERROR FOR TARGET TYPE 3, TARGET=',A/,
     *     '      RACN,DECL(DEG)=',2G13.5)
        END IF
C
      RETURN
      END