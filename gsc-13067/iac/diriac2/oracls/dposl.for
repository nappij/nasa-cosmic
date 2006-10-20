      SUBROUTINE DPOSL(A,LDA,N,B)
      INTEGER LDA,N
      DOUBLE PRECISION A(LDA,1),B(1)
C
C     DPOSL SOLVES THE DOUBLE PRECISION SYMMETRIC POSITIVE DEFINITE
C     SYSTEM A * X = B
C     USING THE FACTORS COMPUTED BY DPOCO OR DPOFA.
C
C     ON ENTRY
C
C        A       DOUBLE PRECISION(LDA, N)
C                THE OUTPUT FROM DPOCO OR DPOFA.
C
C        LDA     INTEGER
C                THE LEADING DIMENSION OF THE ARRAY  A .
C
C        N       INTEGER
C                THE ORDER OF THE MATRIX  A .
C
C        B       DOUBLE PRECISION(N)
C                THE RIGHT HAND SIDE VECTOR.
C
C     ON RETURN
C
C        B       THE SOLUTION VECTOR  X .
C
C     ERROR CONDITION
C
C        A DIVISION BY ZERO WILL OCCUR IF THE INPUT FACTOR CONTAINS
C        A ZERO ON THE DIAGONAL.  TECHNICALLY THIS INDICATES
C        SINGULARITY BUT IT IS USUALLY CAUSED BY IMPROPER SUBROUTINE
C        ARGUMENTS.  IT WILL NOT OCCUR IF THE SUBROUTINES ARE CALLED
C        CORRECTLY AND  INFO .EQ. 0 .
C
C     TO COMPUTE  INVERSE(A) * C  WHERE  C  IS A MATRIX
C     WITH  P  COLUMNS
C           CALL DPOCO(A,LDA,N,RCOND,Z,INFO)
C           IF (RCOND IS TOO SMALL .OR. INFO .NE. 0) GO TO ...
C           DO 10 J = 1, P
C              CALL DPOSL(A,LDA,N,C(1,J))
C        10 CONTINUE
C
C     LINPACK.  THIS VERSION DATED 08/14/78 .
C     CLEVE MOLER, UNIVERSITY OF NEW MEXICO, ARGONNE NATIONAL LAB.
C
C     SUBROUTINES AND FUNCTIONS
C
C     BLAS DAXPY,DDOT
C
C     INTERNAL VARIABLES
C
      DOUBLE PRECISION DDOT,T
      INTEGER K,KB
C
C     SOLVE TRANS(R)*Y = B
C
      DO 10 K = 1, N
         T = DDOT(K-1,A(1,K),1,B(1),1)
         B(K) = (B(K) - T)/A(K,K)
   10 CONTINUE
C
C     SOLVE R*X = Y
C
      DO 20 KB = 1, N
         K = N + 1 - KB
         B(K) = B(K)/A(K,K)
         T = -B(K)
         CALL DAXPY(K-1,T,A(1,K),1,B(1),1)
   20 CONTINUE
      RETURN
      END