      SUBROUTINE RICNWT(A,NA,B,NB,H,NH,Q,NQ,R,NR,F,NF,P,NP,IOP,IDENT,DI
     1SC,FNULL,DUMMY)
C 
C   PURPOSE:
C      Solve either the continuous or discrete steady-state Riccati
C      equation by the Newton algorithms described by Kleinman and
C      Hewer.
C 
C   REFERENCES:
C      Kleinman, David L.: On an Iterative Technique for Riccati Equa-
C        tion Computations. IEEE Trans. Autom. Control, vol. AC-13, no.
C        1, Feb. 1968, pp. 114-115.
C      Hewer, Gary A.: An Iterative Technique for the Computation of
C        the Steady State Gains for the Discrete Optimal Regulator.
C        IEEE Trans. Autom. Control, vol. AC-16, no. 4, Aug. 1971,
C        pp. 382-383.
C      Kantorovich, L.V.; and Akilov, G.P. (D. E. Brown, trans.): Func-
C        tional Analysis in Normed Spaces. A.P. Robertson, ed., Mac-
C        Millan Co., 1964.
C      Sandell, Nils R., Jr.: On Newton's Method for Riccati Equation
C        Solution. IEEE Trans. Autom. Control, vol. AC-19, no. 3, June
C        1974, pp. 254-255.
C      Kwakernaak, Huibert; and Sivan, Raphael: Linear Optimal Control
C        Systems. John Wiley & Sons, Inc., c. 1972.
C 
C   Subroutines employed by RICNWT: ADD, BARSTW, BILIN, DPOCO, DPOSL,
C      EQUATE, GELIM, LNCNT, MAXEL, MULT, PRNT, SCALE, SUBT, SUM,
C      SYMPDS, TRANP, UNITY
C   Subroutines employing RICNWT: ASYREG
C 
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(1),B(1),Q(1),R(1),F(1),P(1),DUMMY(1)
      DIMENSION NA(2),NB(2),NQ(2),NR(2),NF(2),NP(2),IOP(3)
      DIMENSION H(1),NH(2),IOPT(2)
      LOGICAL  IDENT,DISC,FNULL,SYM
      COMMON/TOL/EPSAM,EPSBM,IACM
      COMMON/CONV/SUMCV,MAXSUM,RICTCV,SERCV
C 
      I=1
      IOPT(1)=0
      SYM = .TRUE.
C 
      N = NA(1)**2
      N1 = N +1
      IF( .NOT. DISC) N1 = NA(1)*NR(1) + 1
      N2= N1+N
      N3= N2+N
      N4 = N3+N
C 
      IF( IOP(1) .EQ. 0 )  GO TO 210
      CALL LNCNT(4)
      IF(.NOT. DISC)WRITE(6,100)
      IF( DISC )WRITE(6,150)
  100 FORMAT(BZ,//' PROGRAM TO SOLVE CONTINUOUS STEADY-STATE RICCATI EQU
     1ATION BY THE NEWTON ALGORITHM'/)
  150 FORMAT(//' PROGRAM TO SOLVE DISCRETE STEADY-STATE RICCATI EQUATION
     1 BY THE NEWTON ALGORITHM'/)
      CALL PRNT(A,NA,' A  ',1)
      CALL PRNT(B,NB,' B  ',1)
      CALL PRNT(Q,NQ,' Q  ',1)
      IF( .NOT. IDENT )GO TO 185
      CALL LNCNT(3)
      WRITE(6,180)
  180 FORMAT(/' H IS AN IDENTITY MATRIX'/)
      GO TO 200
  185 CONTINUE
      CALL PRNT(H,NH,' H  ',1)
      CALL MULT(Q,NQ,H,NH,DUMMY,NH)
      CALL TRANP(H,NH,DUMMY(N2),NP)
      CALL MULT(DUMMY(N2),NP,DUMMY,NH,Q,NQ)
      CALL LNCNT(3)
      WRITE(6,195)
  195 FORMAT(/' MATRIX (H TRANSPOSE)QH '/)
      CALL PRNT(Q,NQ,'HTQH',1)
  200 CONTINUE
      CALL PRNT(R,NR,' R  ',1)
      IF( FNULL )  GO TO 210
      CALL LNCNT(3)
      WRITE(6,205)
  205 FORMAT(/' INITIAL F MATRIX'/)
      CALL PRNT(F,NF,' F  ',1)
C 
  210 CONTINUE
      IF((IOP(1) .NE. 0)  .OR. IDENT)  GO TO 220
      CALL MULT(Q,NQ,H,NH,DUMMY,NH)
      CALL TRANP(H,NH,DUMMY(N2),NP)
      CALL MULT(DUMMY(N2),NP,DUMMY,NH,Q,NQ)
  220 CONTINUE
C 
      IF (DISC) GO TO 900
C 
      CALL TRANP(B,NB,P,NP)
      CALL EQUATE(R,NR,DUMMY,NR)
      CALL SYMPDS(NR(1),NR(1),DUMMY,NR(2),P,IOPT,IOPT,DET,ISCALE,DUMMY(N
     11),IERR)
      IF(IERR .NE. 0) GO TO 240
C      GENERATE R-INVERSE
      CALL UNITY(P,NR)
      CALL GELIM(NR(1),NR(1),DUMMY,NR(2),P,DUMMY(N2),0,DUMMY(N1),IERR)
      IF(IERR.EQ.0) GO TO 250
  240 CALL LNCNT(3)
      WRITE(6,225)
  225 FORMAT(/' IN RICNWT, A MATRIX WHICH IS  NOT SYMMETRIC POSITIVE DE
     1FINITE HAS BEEN SUBMITTED TO  SYMPDS'/)
      RETURN
C 
  250 CONTINUE
C     CALCULATE (R-INVERSE)*(B-TRANSPOSE) AND STORE IN DUMMY(N1)
      CALL TRANP(B,NB,DUMMY(N2),NF)
      CALL EQUATE(P,NR,DUMMY,NR)
      CALL MULT(DUMMY,NR,DUMMY(N2),NF,DUMMY(N1),NF)
      CALL PRNT(DUMMY,NR,'RINV',1)
C 
      IF(FNULL) GO TO 300
C 
C     GENERATE THE RECURSIVE EQUATION FOR THE INITIAL RUN
      CALL MULT(B,NB,F,NF,DUMMY(N2),NA)
      CALL SUBT(A,NA,DUMMY(N2),NA,DUMMY(N2),NA)
      CALL TRANP(DUMMY(N2),NA,DUMMY(N3),NA)
      CALL EQUATE(DUMMY(N3),NA,DUMMY(N2),NA)
      CALL MULT(R,NR,F,NF,DUMMY(N3),NF)
      CALL TRANP(F,NF,P,NP)
      CALL MULT(P,NP,DUMMY(N3),NF,DUMMY(N4),NA)
      CALL TRANP(DUMMY(N4),NA,DUMMY(N3),NA)
      CALL ADD(DUMMY(N4),NA,DUMMY(N3),NA,DUMMY(N3),NA)
      CALL SCALE(DUMMY(N3),NA,DUMMY(N3),NA,0.5D0)
      CALL ADD(DUMMY(N3),NA,Q,NQ,P,NP)
      CALL SCALE(P,NP,P,NP,-1.0D0)
      GO TO 350
C 
  300 CONTINUE
      CALL TRANP(A,NA,DUMMY(N2),NA)
      CALL SCALE(Q,NQ,P,NP,-1.0D0)
C 
  350 CONTINUE
      IF(IOP(3) .NE. 0) GO TO 400
      EPSA= EPSAM
      CALL BARSTW(DUMMY(N2),NA,B,NB,P,NP,IOPT,SYM,EPSA,EPSA,DUMMY(N3))
      GO TO 450
C 
  400 CONTINUE
      IOPT(2)=1
      CALL BILIN(DUMMY(N2),NA,B,NB,P,NP,IOPT,SCLE,SYM,DUMMY(N3))
C 
  450 CONTINUE
      CALL EQUATE(P,NP,DUMMY(N2),NP)
      IF(IOP(2).EQ. 0) GO TO 550
      CALL LNCNT(3)
      WRITE(6,500) I
  500 FORMAT(/' ITERATION  ',I5/)
      CALL PRNT(P,NP,' P  ',1)
C 
  550 CONTINUE
C     GENERATE THE RECURSIVE EQUATION ON THE LOOP
      CALL MULT(DUMMY(N1),NF,P,NP,DUMMY(N3),NF)
      CALL EQUATE(DUMMY(N3),NF,F,NF)
      CALL MULT(R,NR,F,NF,DUMMY(N3),NF)
      CALL TRANP(F,NF,P,NP)
      CALL MULT(P,NP,DUMMY(N3),NF,DUMMY(N4),NA)
      CALL TRANP(DUMMY(N4),NA,DUMMY(N3),NA)
      CALL ADD(DUMMY(N4),NA,DUMMY(N3),NA,DUMMY(N3),NA)
      CALL SCALE(DUMMY(N3),NA,DUMMY(N3),NA,0.5D0)
      CALL ADD(DUMMY(N3),NA,Q,NQ,P,NP)
      CALL SCALE(P,NP,P,NP,-1.0D0)
      CALL MULT(B,NB,F,NF,DUMMY(N3),NA)
      CALL SUBT(A,NA,DUMMY(N3),NA,DUMMY(N4),NA)
      CALL TRANP(DUMMY(N4),NA,DUMMY(N3),NA)
C 
      IF(IOP(3) .NE. 0 ) GO TO 650
      CALL BARSTW(DUMMY(N3),NA,B,NB,P,NP,IOPT,SYM,EPSA,EPSA,DUMMY(N4))
      GO TO 675
C 
  650 CONTINUE
      CALL BILIN(DUMMY(N3),NA,B,NB,P,NP,IOPT,SCLE,SYM,DUMMY(N4))
C 
  675 CONTINUE
      I=I+1
      CALL MAXEL(DUMMY(N2),NA,ANORM1)
      CALL SUBT(P,NP,DUMMY(N2),NA,DUMMY(N3),NA)
      CALL MAXEL(DUMMY(N3),NA,ANORM2)
      IF(ANORM1 .GT. 1.0) GO TO 700
      IF( ANORM2/ANORM1 .LT. RICTCV ) GO TO 800
      GO TO 750
C 
  700 CONTINUE
      IF( ANORM2 .LT. RICTCV ) GO TO 800
C 
  750 CONTINUE
      IF( I .LE. 101) GO TO 450
      CALL LNCNT(3)
      WRITE(6,775)
  775 FORMAT(/' THE SUBROUTINE RICNWT HAS EXCEEDED 100 ITERATIONS WITHO
     1UT CONVERGENCE'/)
      IOP(1) = 1
C 
  800 CONTINUE
      CALL MULT(DUMMY(N1),NF,P,NP,F,NF)
      GO TO 1300
C 
  900 CONTINUE
      IF( .NOT. FNULL ) GO TO 950
C 
      CALL EQUATE(Q,NQ,P,NP)
      CALL EQUATE(A,NA,DUMMY(N1),NA)
      CALL TRANP(A,NA,DUMMY(N2),NA)
      GO TO 1000
  925 CONTINUE
C 
      I=I+1
      CALL EQUATE(P,NP,DUMMY,NP)
  950 CONTINUE
C 
      CALL MULT(R,NR,F,NF,DUMMY(N1),NF)
      CALL TRANP(F,NF,P,NP)
      CALL MULT(P,NP,DUMMY(N1),NF,DUMMY(N2),NA)
      CALL TRANP(DUMMY(N2),NA,DUMMY(N1),NA)
      CALL ADD(DUMMY(N1),NA,DUMMY(N2),NA,DUMMY(N1),NA)
      CALL SCALE(DUMMY(N1),NA,DUMMY(N1),NA,0.5D0)
      CALL ADD(Q,NQ,DUMMY(N1),NA,P,NP)
      CALL MULT(B,NB,F,NF,DUMMY(N1),NA)
      CALL SUBT(A,NA,DUMMY(N1),NA,DUMMY(N1),NA)
      CALL TRANP(DUMMY(N1),NA,DUMMY(N2),NA)
C 
 1000 CONTINUE
      CALL SUM(DUMMY(N2),NA,P,NP,DUMMY(N1),NA,IOPT,SYM,DUMMY(N3))
      IF(IOP(2) .EQ. 0) GO TO 1100
      CALL LNCNT(3)
      WRITE(6,500) I
      CALL PRNT(P,NP,' P  ',1)
C 
 1100 CONTINUE
      CALL MULT(P,NP,A,NA,DUMMY(N1),NA)
      CALL MULT(P,NP,B,NB,DUMMY(N2),NB)
      CALL TRANP(B,NB,DUMMY(N3),NF)
      CALL MULT(DUMMY(N3),NF,DUMMY(N1),NA,F,NF)
      CALL MULT(DUMMY(N3),NF,DUMMY(N2),NB,DUMMY(N1),NR)
      CALL TRANP(DUMMY(N1),NR,DUMMY(N2),NR)
      CALL ADD(DUMMY(N1),NR,DUMMY(N2),NR,DUMMY(N1),NR)
      CALL SCALE(DUMMY(N1),NR,DUMMY(N1),NR,0.5D0)
      CALL ADD(R,NR,DUMMY(N1),NR,DUMMY(N1),NR)
C 
C   * * * CALL TO MATHLIB FUNCTIONS * * *
      CALL DPOCO(DUMMY(N1),NR(1),NR(1),RCOND,DUMMY(N2),IERR)
      IF(IERR .EQ. 0) GO TO 1150
      CALL LNCNT(3)
      WRITE(6,1125)
 1125 FORMAT(/' IN RICNWT, A MATRIX WHICH IS NOT POSITIVE DEFINITE HAS B
     1EEN SUBMITTED TO DPOCO'/)
      RETURN
C 
 1150 CONTINUE
      NT = 1
      DO 1175 M1 = 1,NA(1)
         CALL DPOSL(DUMMY(N1),NR(1),NR(1),F(NT))
         NT = NT + NR(1)
 1175 CONTINUE
      IF( I .EQ. 1) GO TO 925
      CALL MAXEL(DUMMY,NA,ANORM1)
      CALL SUBT(P,NP,DUMMY,NA,DUMMY(N1),NA)
      CALL MAXEL(DUMMY(N1),NA,ANORM2)
      IF( ANORM1 .GT. 1) GO TO 1200
      IF( ANORM2/ANORM1 .LT. RICTCV ) GO TO 1300
      GO TO 1250
 1200 CONTINUE
      IF( ANORM2 .LT. RICTCV ) GO TO 1300
C 
 1250 CONTINUE
      IF( I .LE. 101) GO TO  925
      CALL LNCNT(3)
      WRITE(6,775)
      IOP(1) = 1
C 
 1300 CONTINUE
      IF(IOP(1) .EQ. 0 ) RETURN
      CALL LNCNT(4)
      WRITE(6,1350) I
 1350 FORMAT(//' FINAL VALUES OF P AND F AFTER',I5,' ITERATIONS TO CONVE
     1RGE'/)
      CALL PRNT(P,NP,' P  ',1)
      CALL PRNT(F,NF,' F  ',1)
C 
      RETURN
      END
