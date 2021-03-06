      SUBROUTINE POLE(A,NA,B,NB,EVAL,NUMR,F,NF,IOP,DUMMY)
C 
C   PURPOSE:
C      Calculate an (1 x n) matrix F which causes the eigenvalues
C      of the matrix A-BF to assume n specified values.
C 
C   Subroutines employed by POLE: DGECO, DGESL, EIGEN, EQUATE, JUXTC,
C      LNCNT, MULT, NULL, PRNT, SCALE, SUBT, TRANP, TRCE
C   Subroutines employing POLE: None
C 
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(1),B(1),EVAL(1),F(1),DUMMY(1)
      DIMENSION NA(2),NB(2),NF(2),NDUM1(2),NDUM2(2)
C 
C 
      IF( IOP .EQ. 0 ) GO TO 100
      CALL LNCNT(6)
      WRITE(6,25)
   25 FORMAT('  GIVEN THE COMPLETELY CONTROLLABLE PAIR (A,B), THE MATRIX
     1 F IS COMPUTED'/' SUCH THAT A-BF HAS PRESCRIBED EIGENVALUES'///)
      CALL PRNT(A,NA,' A  ',1)
      CALL PRNT(B,NB,' B  ',1)
      CALL LNCNT(6)
      WRITE(6,50) NUMR
   50 FORMAT(///' THE PRESCRIBED EIGENVALUES ARE STORED IN EVAL'/' PAST
     1ENTRY ',I4,' NUMBERS CORRESPOND TO REAL AND IMAGINARY PARTS'/)
      CALL PRNT(EVAL,NB,'EVAL',1)
  100 CONTINUE
C 
      N = NA(1)
      M = N**2
      N1 = M + 1
      N2 = N1 + M
      N3 = N2 + M
      N4 = N3 + M
      J = 1
      CALL EQUATE(B,NB,DUMMY,NDUM2)
      CALL EQUATE(B,NB,DUMMY(N1),NB)
  200 CONTINUE
      CALL MULT(A,NA,DUMMY(N1),NB,DUMMY(N2),NB)
      IF( J .EQ. N ) GO TO 300
      CALL JUXTC(DUMMY,NDUM2,DUMMY(N2),NB,DUMMY(N3),NDUM1)
      CALL EQUATE(DUMMY(N2),NB,DUMMY(N1),NB)
      CALL EQUATE(DUMMY(N3),NDUM1,DUMMY,NDUM2)
      J = J + 1
      GO TO 200
  300 CONTINUE
C 
      CALL SCALE(DUMMY(N2),NB,F,NF,-1.0D0)
      CALL EQUATE(DUMMY,NA,DUMMY(N4),NA)
      NRHS = 1
C 
C   * * * CALL TO MATHLIB FUNCTIONS * * *
      CALL DGECO(DUMMY,N,N,DUMMY(N1),RCOND,DUMMY(N2))
      IF ((1.0 + RCOND) .NE. 1.0) GO TO 400
      CALL LNCNT(1)
      WRITE(6,350) RCOND
  350 FORMAT(' IN POLE, THE CONTROLLABILITY MATRIX, C, HAS BEEN DECLARED
     1 SINGULAR BY DGECO, RCOND = ',D16.8)
      RETURN
  400 CONTINUE
      NT = 1
      DO 420 M1 = 1,NRHS
         CALL DGESL(DUMMY,N,N,DUMMY(N1),F(NT),0)
         NT = NT + N
  420 CONTINUE
C 
      IF( IOP .EQ. 0 ) GO TO 500
      CALL LNCNT(10)
      WRITE(6,425)
  425 FORMAT(//' DENOTE CHARACTERISTIC POLYNOMIAL OF A BY D(S)')
      WRITE(6,450)
  450 FORMAT(14X,'N  N-1',6X,'N-2')
      WRITE(6,475)
  475 FORMAT(8X,'D(S)=S +S   D(1)+S   D(2)+...+SD(N-1)+D(N)'//)
      WRITE(6,485)
  485 FORMAT(//'  AL = COL.(D(N),D(N-1),...,D(1))')
      CALL PRNT(F,NF,' AL ',1)
C 
  500 CONTINUE
      NDUM1(1) = 2
      NDUM1(2) = 2
      CALL NULL(DUMMY,NDUM1)
      IF( NUMR .EQ. 0 )   GO TO 535
C 
      DO 525 I =1,N
      DO 525 J =1,NUMR
      DUMMY(I) = DUMMY(I) + EVAL(J)**I
  525 CONTINUE
  535 CONTINUE
      N11 = N1
      N21 = N11 + 1
      N12 = N21 + 1
      N22 = N12 + 1
      IF( NUMR .EQ. N ) GO TO 600
      L = NUMR + 1
      DO 550 I= L,N,2
      DUMMY(N11) =  EVAL(I)
      DUMMY(N12) =  EVAL(I+1)
      DUMMY(N21) = -EVAL(I+1)
      DUMMY(N22) =  EVAL(I)
      CALL EQUATE(DUMMY(N1),NDUM1,DUMMY(N2),NDUM1)
      DO 550 K =1,N
      CALL TRCE(DUMMY(N2),NDUM1,TR)
      DUMMY(K) = DUMMY(K) + TR
      IF( K .EQ. N ) GO TO 550
      CALL MULT(DUMMY(N1),NDUM1,DUMMY(N2),NDUM1,DUMMY(N3),NDUM1)
      CALL EQUATE(DUMMY(N3),NDUM1,DUMMY(N2),NDUM1)
  550 CONTINUE
  600 CONTINUE
      NDUM1(1) = N
      NDUM1(2) = 1
      DUMMY(N1) = - DUMMY(1)
      DO 650 K = 2,N
      NK = N1+K-1
      DUMMY(NK) = DUMMY(K)
      KM1 = K-1
      DO 625 J = 1,KM1
      NJ = N1+J-1
      NKJ = NK-NJ
      DUMMY(NK) = DUMMY(NK)+ DUMMY(NJ)*DUMMY(NKJ)
  625 CONTINUE
      DUMMY(NK) = - DUMMY(NK)/K
  650 CONTINUE
      DO 675 J = 1,N
      I = N+1-J
      DUMMY(J) = DUMMY(N1-1+I)
  675 CONTINUE
C 
      IF( IOP .EQ. 0 ) GO TO 800
      CALL LNCNT(7)
      WRITE(6,700) N
  700 FORMAT(//'  FOR THE ',I4,' EIGENVALUES STORED IN EVAL THE CHARACTE
     1RISTIC POLYNOMIAL IS'/14X,'N  N-1      N-2'/8X,'D(S)=S +S   D(1)+S
     2   D(2)+...+SD(N-1)+D(N)'//)
      WRITE(6,750)
  750 FORMAT(//'  ALTL = COL.(D(N),D(N-1),...,D(1))')
      CALL PRNT(DUMMY,NB,'ALTL',1)
C 
  800 CONTINUE
      CALL NULL(DUMMY(N1),NA)
      DO 850 I =1,N
      N1I = I*N-I+N1
      DUMMY(N1I) = 1.0
  850 CONTINUE
      NM1 = N-1
      DO 875 J = 1,NM1
      K = J+1
      DO 875 I = K,N
      NJ = N1 + (J-1)*N + I-K
      DUMMY(NJ) = F(I)
  875 CONTINUE
      CALL MULT(DUMMY(N4),NA,DUMMY(N1),NA,DUMMY(N2),NA)
      CALL SUBT(DUMMY,NB,F,NF,F,NF)
      CALL TRANP(DUMMY(N2),NA,DUMMY,NA)
C 
C   * * * CALL TO MATHLIB FUNCTIONS * * *
      CALL DGECO(DUMMY,N,N,DUMMY(N1),RCOND,DUMMY(N2))
      IF ((1.0 + RCOND) .NE. 1.0) GO TO 900
      CALL LNCNT(1)
      WRITE(6,885) RCOND
  885 FORMAT('  IN POLE, THE MATRIX V HAS BEEN DECLARED SINGULAR BY DGEC
     1O, RCOND = ',D16.8)
      RETURN
C 
  900 CONTINUE
      NT = 1
      DO 925 M1 = 1,NRHS
         CALL DGESL(DUMMY,N,N,DUMMY(N1),F(NT),0)
         NT = NT + N
  925 CONTINUE
      NF(1) = 1
      NF(2) = N
      CALL MULT(B,NB,F,NF,DUMMY,NDUM1)
      CALL SUBT(A,NA,DUMMY,NDUM1,DUMMY,NDUM1)
      CALL EQUATE(DUMMY,NDUM1,DUMMY(N1),NDUM1)
      ISV = N
      ILV = 0
      N21 = N2
      N22 = N2+N
      N23 = N22+N
      CALL EIGEN(N,N,DUMMY(N1),DUMMY(N21),DUMMY(N22),ISV,ILV,DUMMY(N3),D
     1UMMY(N4),IERR)
      IF( IERR .EQ. 0 ) GO TO 1000
      CALL LNCNT(1)
      WRITE(6,950)
  950 FORMAT('  IN POLE, AFTER CALL TO EIGEN WITH  A-BF, IERR= ',I4)
C 
 1000 CONTINUE
      CALL EQUATE(DUMMY(N3),NA,DUMMY(N23),NA)
      IF( IOP .EQ. 0 ) RETURN
      CALL PRNT(F,NF,' F  ',1)
      CALL PRNT(DUMMY,NA,'A-BF',1)
      CALL LNCNT(3)
      WRITE(6,1100)
 1100 FORMAT(//'  EIGENVALUES(VAL MATRIX) AND EIGENVECTORS(VECT MATRIX)
     1OF A-BF')
      NDUM1(1) = N
      NDUM1(2) = 2
      CALL PRNT(DUMMY(N2),NDUM1,' VAL',1)
      CALL PRNT(DUMMY(N23),NA,'VECT',1)
C 
      RETURN
      END
