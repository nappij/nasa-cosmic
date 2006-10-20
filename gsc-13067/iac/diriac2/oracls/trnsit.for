      SUBROUTINE TRNSIT(A,NA,B,NB,H,NH,G,NG,F,NF,V,NV,T,X,NX,DISC,STABL
     1E,IOP,DUMMY)
C 
C   PURPOSE:
C      Compute and print the transient response of the time-invariant
C      continuous or discrete system.
C 
C   Subroutines employed by TRNSIT: ADD, DGECO, DGESL, EQUATE, EXPINT,
C      EXPSER, LNCNT, MULT, PRNT, SCALE, SUBT, TRANP, UNITY
C   Subroutines employing TRNSIT: none
C 
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(1),B(1),H(1),G(1),F(1),V(1),X(1),DUMMY(1)
      DIMENSION NA(2),NB(2),NH(2),NG(2),NF(2),NV(2),NX(2),T(2),IOP(4)
      DIMENSION NDUM1(2),NDUM2(2)
      LOGICAL  DISC,STABLE
C 
      N = NA(1)*NA(2)
      N1 = N + 1
      N2 = N + N1
      N3 = N + N2
      N4 = N + N3
      N5 = N + N4
      N6 = N + N5
C 
      CALL LNCNT(4)
      IF(DISC) WRITE(6,100)
      IF( .NOT. DISC ) WRITE(6,120)
  100 FORMAT(BZ,//' COMPUTATION OF TRANSIENT RESPONSE FOR THE DIGITAL SY
     1STEM '/)
  120 FORMAT(//' COMPUTATION OF TRANSIENT RESPONSE FOR THE CONTINUOUS
     1 SYSTEM'/)
      CALL PRNT(A,NA,' A  ',1)
      CALL PRNT(B,NB,' B  ',1)
      IF( (IOP(1) .NE. 1) .AND. (IOP(1) .NE. 0) )  GO TO 180
      CALL LNCNT(3)
      IF( IOP(1) .EQ. 0 ) WRITE(6,140)
      IF( IOP(1) .EQ. 1 ) WRITE(6,160)
  140 FORMAT(//' H IS A NULL MATRIX ')
  160 FORMAT(//' H IS AN IDENTITY MATRIX ')
      GO TO 200
  180 CONTINUE
      CALL PRNT(H,NH,' H  ',1)
  200 CONTINUE
      IF( (IOP(2) .NE. 1) .AND. (IOP(2) .NE. 0) )  GO TO 260
      CALL LNCNT(3)
      IF( IOP(2) .EQ. 0 ) WRITE(6,220)
      IF( IOP(2) .EQ. 1 ) WRITE(6,240)
  220 FORMAT(//' G IS A NULL MATRIX')
  240 FORMAT(//' G IS AN IDENTITY MATRIX')
      GO TO 280
  260 CONTINUE
      CALL PRNT(G,NG,' G  ',1)
  280 CONTINUE
      CALL PRNT(F,NF,' F  ',1)
      IF( (IOP(3) .NE. 0) .AND. (IOP(3) .NE. 1) )  GO TO 295
      CALL LNCNT(3)
      IF(IOP(3).EQ.0) WRITE(6,285)
      IF(IOP(3).EQ.1) WRITE(6,290)
  285 FORMAT(//' V IS A NULL MATRIX')
  290 FORMAT(//' V IS AN IDENTITY MATRIX')
      GO TO 300
  295 CONTINUE
      CALL PRNT(V,NV,' V  ',1)
C 
  300 CONTINUE
      CALL EQUATE(A,NA,DUMMY(N6),NA)
      CALL MULT(B,NB,F,NF,DUMMY,NA)
      CALL SUBT(A,NA,DUMMY,NA,A,NA)
C 
      IF(DISC) GO TO 350
      NMAX = T(1)/T(2)
      IOPT = 1
      TT = T(2)
      IF( IOP(3) .NE. 0 )  GO TO 315
      CALL EXPSER(A,NA,DUMMY,NA,TT,IOPT,DUMMY(N1))
      GO TO 400
  315 CONTINUE
      CALL EXPINT(A,NA,DUMMY,NA,DUMMY(N1),NA,TT,IOPT,DUMMY(N2))
      CALL MULT(DUMMY(N1),NA,B,NB,DUMMY(N2),NB)
      IF( IOP(3) .NE. 1 ) GO TO 325
      CALL EQUATE(DUMMY(N2),NB,DUMMY(N1),NX)
      GO TO 400
  325 CONTINUE
      CALL MULT(DUMMY(N2),NB,V,NV,DUMMY(N1),NX)
      GO TO 400
  350 CONTINUE
      NMAX = IOP(4)
      CALL EQUATE(A,NA,DUMMY,NA)
      IF( IOP(3) .EQ. 0 ) GO TO 400
      CALL MULT(B,NB,V,NV,DUMMY(N1),NX)
C 
  400 CONTINUE
      CALL LNCNT(4)
      WRITE(6,420)
  420 FORMAT(//' STRUCTURE OF PRINTING TO FOLLOW'/)
      CALL LNCNT(6)
      WRITE(6,440)
  440 FORMAT('   TIME OR STAGE '/'  STATE - X TRANSPOSE - FROM DX = AX +
     1 BU'/'  OUTPUT - Y TRANSPOSE - FROM Y = HX + GU   IF DIFFERENT FRO
     2M X'/'  CONTROL - U TRANSPOSE - FROM U = -FX + V'//)
C 
      K = 0
      L = 0
      CALL SCALE(F,NF,F,NF,-1.0D0)
C 
  450 CONTINUE
      IF( K .GT. NMAX ) GO TO 800
      CALL MULT(F,NF,X,NX,DUMMY(N2),NV)
      IF( IOP(3) .NE. 0 ) CALL ADD(DUMMY(N2),NV,V,NV,DUMMY(N2),NV)
      CALL MULT(DUMMY,NA,X,NX,DUMMY(N3),NX)
      IF( IOP(3) .EQ. 0 ) GO TO 475
      CALL ADD(DUMMY(N1),NX,DUMMY(N3),NX,DUMMY(N3),NX)
  475 CONTINUE
      IF( IOP(2) .EQ. 0 ) GO TO 525
      IF( IOP(2) .EQ. 1 ) GO TO 500
      CALL MULT(G,NG,DUMMY(N2),NV,DUMMY(N4),NDUM1)
      GO TO 525
  500 CONTINUE
      CALL EQUATE(DUMMY(N2),NV,DUMMY(N4),NDUM1)
  525 CONTINUE
      IF( IOP(1) .EQ. 0 ) GO TO 575
      IF( IOP(1) .EQ. 1 ) GO TO 550
      CALL MULT(H,NH,X,NX,DUMMY(N5),NDUM1)
      GO TO 575
  550 CONTINUE
      CALL EQUATE(X,NX,DUMMY(N5),NDUM1)
  575 CONTINUE
      IF( IOP(2) .EQ. 0 ) GO TO 600
      IF( IOP(1) .EQ. 0 ) GO TO 700
      CALL ADD(DUMMY(N4),NDUM1,DUMMY(N5),NDUM1,DUMMY(N4),NDUM1)
      GO TO 700
  600 CONTINUE
      IF( IOP(1) .NE. 0 ) CALL EQUATE(DUMMY(N5),NDUM1,DUMMY(N4),NDUM1)
C 
  700 CONTINUE
      CALL LNCNT(5)
      IF( .NOT. DISC ) GO TO 720
      WRITE(6,710) K
  710 FORMAT(////,I5)
      GO TO 740
  720 CONTINUE
      TIME=K*T(2)
      WRITE(6,730) TIME
  730 FORMAT(////,D16.7)
  740 CONTINUE
      CALL TRANP(X,NX,DUMMY(N5),NDUM2)
      CALL PRNT(DUMMY(N5),NDUM2,L,3)
      IF( (IOP(2) .EQ. 0) .AND. ( (IOP(1) .EQ. 0) .OR. (IOP(1) .EQ. 1) )
     1) GO TO 750
      CALL TRANP(DUMMY(N4),NDUM1,DUMMY(N5),NDUM2)
      CALL PRNT(DUMMY(N5),NDUM2,L,3)
  750 CONTINUE
      CALL TRANP(DUMMY(N2),NV,DUMMY(N5),NDUM2)
      CALL PRNT(DUMMY(N5),NDUM2,L,3)
C 
      CALL EQUATE(DUMMY(N3),NX,X,NX)
      K = K + 1
      GO TO 450
C 
C 
  800 CONTINUE
      CALL SCALE(F,NF,F,NF,-1.0D0)
      IF( .NOT. STABLE  .OR.  IOP(3) .EQ. 0  )   GO TO 900
      IF( IOP(3) .EQ. 1 )  GO TO 820
      CALL MULT(B,NB,V,NV,DUMMY,NX)
      GO TO 840
  820 CONTINUE
      CALL EQUATE(B,NB,DUMMY,NX)
  840 CONTINUE
      IF( .NOT. DISC )  GO TO 860
      CALL UNITY(DUMMY(N1),NA)
      CALL SUBT(DUMMY(N1),NA,A,NA,A,NA)
  860 CONTINUE
C 
C   * * * CALL TO MATHLIB FUNCTIONS * * *
      CALL DGECO(A,NA(1),NA(1),DUMMY(N1),RCOND,DUMMY(N2))
      IF ((1.0 + RCOND) .NE. 1.0) GO TO 880
      CALL LNCNT(3)
      IF( .NOT. DISC )  WRITE(6,865) RCOND
      IF( DISC )  WRITE(6,870) RCOND
  865 FORMAT(//' IN TRNSIT, THE MATRIX A-BF SUBMITTED TO DGECO IS SINGU
     1LAR, RCOND = ',D16.8)
  870 FORMAT(//' IN TRNSIT, THE MATRIX  I - (A-BF) SUBMITTED TO DGECO I
     1S SINGULAR, RCOND = ',D16.8)
      GO TO 900
  880 CONTINUE
      NT = 1
      DO 885 M1 = 1,NX(2)
         CALL DGESL(A,NA(1),NA(1),DUMMY(N1),DUMMY(NT),0)
         NT = NT + NA(1)
  885 CONTINUE
      IF( .NOT. DISC )  CALL SCALE(DUMMY,NX,DUMMY,NX,-1.0D0)
      CALL LNCNT(5)
      WRITE(6,890)
  890 FORMAT(////' STEADY-STATE VALUE OF  X TRANSPOSE')
      CALL TRANP(DUMMY,NX,DUMMY(N5),NDUM2)
      CALL PRNT(DUMMY(N5),NDUM2,L,3)
C 
  900 CONTINUE
      CALL EQUATE(DUMMY(N6),NA,A,NA)
C 
      RETURN
      END