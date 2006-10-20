      PROGRAM DRV3X2
CD0  
CD0   IDENTIFICATION : 
CD0
CD0         PROGRAMMER -  J.D. FRICK, MDAC/HOUSTON 
CD0         VERSION    -  SEPTEMBER 1986 
CD1
CD1   PURPOSE :
CD1
CD1         THIS IS A SIMPLE DRIVER PROGRAM FOR VMACO. CONTAINED BELOW 
CD1         IS A CONSTRAINED OPTIMIZATION TEST CASE WITH 3 CONTROL 
CD1         VARIABLES AND 2 CONSTRAINTS. IT MAY BE NOTED THAT ONE OF THE
CD1         CONSTRAINTS IS AN EQUALITY AND ONE IS AN INEQUALITY TYPE. 
CD2
CD2   CALLING ARGUMENT INPUT : 
CD2
CD2      NAME    DEFINITION
CD2
CD2      NONE
CD3
CD3   CALLING ARGUMENT OUTPUT :
CD3
CD3      NAME    DEFINITION
CD3
CD3      ACC     CONTROLS THE FINAL ACCURACY FOR CONVERGENCE. CON-
CD3              VERGENCE OCCURS WHEN THE VALUE FOR THE CHANGE IN
CD3              THE OBJECTIVE FUNCTION PLUS SUITABLY WEIGHTED MULTI-
CD3              PLIERS OF THE CONSTRAINT FUNCTION DIFFERS FROM
CD3              FROM ITS PREVIOUS VALUE BY AT MOST ACC.
CD3      C       VECTOR OF CONSTRAINT VARIABLES.
CD3      CNORML  MATRIX OF CONSTRAINT NORMALS  
CD3      F       VALUE OF THE OBJECTIVE FUNCTION (OPTIMIZED VARIABLE)  
CD3      G       GRADIENT OF THE OBJECTIVE FUNCTION
CD3      IPRINT  FLAG TO INDICATE AMOUNT OF PRINTOUT
CD3              = 0 NO PRINTOUT
CD3              = 1 VALUES OF X, C, AND F ARE PRINTED 
CD3              = 2 DEBUG PRINTOUT
CD3      ISTAT   INDEX TO INDICATE THE STATUS OF THE OPTIMIZATION  
CD3              ALGORITHM.
CD3              =-1 INITIAL PASS THROUGH VMACO
CD3              = 0 CONTINUE ALGORITHM CALCULATIONS
CD3              = 1 CONVERGE WITHIN REQUIRED ACURRACY 
CD3              > 1 ERROR ENCOUNTERED 
CD3      M       TOTAL NUMBER OF CONSTRAINTS (I.E. CONSTRAINT EQUATIONS)
CD3      MAXFUN  MAXIMUM NUMBER OF TIMES VMACO CAN BE CALLED
CD3      MEQ     TOTAL NUMBER OF EQUALITY CONSTRAINTS  
CD3      N       NUMBER OF CONTROL VARIABLES
CD3      NSIZE   CORRESPONDS TO THE MAXIMUM DIMENSION OF THE INNERMOST 
CD3              ARRAY SIZE FROM THE CNORML MATRIX (I.E. MAX CONTROL
CD3              VARIABLE SIZE). THIS ALLOWS CORRECT COMMUNICATION 
CD3              BETWEEN THE CNORML AND CN MATRIX. 
CD3      X       VECTOR OF CONTROL VARIABLES
CD4
CD4   COMMON VARIABLE INPUT
CD4
CD4      NAME    DEFINITION
CD4
CD4      NONE
CD5
CD5   COMMON VARIABLE OUTPUT
CD5
CD5      NAME    DEFINITION
CD5
CD5      NONE
CD6
CD6   INTERNAL VARIABLES
CD6
CD6      NAME    DEFINITION
CD6
CD6      MSIZE   SIZE OF ARRAYS PERTAINING TO THE CONSTRAINTS
CD7
CD7   LIMITATIONS/ASSUMPTIONS  
CD7
CD7      NONE 
C  
C***********************************************************************
C    
      PARAMETER ( MSIZE  =    4 )
      PARAMETER ( NSIZE  =    4 )
C
      DIMENSION C      (NSIZE ) 
      DIMENSION CNORML (NSIZE ,MSIZE )
      DIMENSION G      (NSIZE )
      DIMENSION X      (NSIZE ) 
C
C************************************************************************
C  
      N = 3  
      M = 2  
      MEQ = 1
C
      MAXFUN = 20
      ACC = 1.E-7
      IPRINT = 1 
      ISTAT = -1 
C  
C.....AN INITIAL GUESS IS MADE
C
      X(1) = 1.
      X(2) = 2.
      X(3) = 3.
C  
   20 CONTINUE 
C
C.....THE OBJECTIVE FUNCTION IS CALCULATED
C
      F = X(1)**2 + X(2)**2 + X(3) 
C  
C.....THE GRADIENTS OF THE OBJECTIVE FUNCTION ARE CALCULATED
C
      G(1) = 2.*X(1)
      G(2) = 2.*X(2)
      G(3) = 1.0
C
C.....THE CONSTRAINTS AND THEIR FIRST PARTIALS ARE CALCULATED
C  
      C(1) = X(1)*X(2) - X(3)  
C  
      CNORML(1,1) = X(2)
      CNORML(2,1) = X(1)
      CNORML(3,1) = -1.
C  
      C(2) = X(3) - 1. 
C  
      CNORML(1,2) = 0. 
      CNORML(2,2) = 0. 
      CNORML(3,2) = 1. 
C  
      CALL VMACO (N,M,MEQ,X,F,G,C,CNORML,NSIZE,MAXFUN,ACC, 
     1            ISTAT,IPRINT)
C  
      IF (ISTAT .EQ. 0) THEN
        GO TO 20
      ENDIF
C  
      STOP 
      END