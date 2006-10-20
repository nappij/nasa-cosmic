      SUBROUTINE POWERS(Q,M,NSPEC,IWIN)
C     M+1=NUMBER OF DESIRED LAG VALUES
C     NSPEC=2*NS, NUMBER OF DATA POINTS AFTER WINDOWING.
      COMPLEX Q(1)
C     WINDOW AUTOCORRELATION FUNCTION
C     IWIN=1,  HANN
C     IWIN=2,  HAMMING
C     IWIN=3,  TRIANGULAR
      IWIN=1
      FM=FLOAT(M)
      PI=3.1416
      IF(IWIN-2) 1,2,3
    1 IF(IWIN-1)10,11,11
   11 DO 910 J=2,M
      R=FLOAT(J-1)
      WT=0.5*(1.+COS(PI*R/FM))
      Q(J)=Q(J)*WT
      Q(NSPEC+2-J)=Q(J)
  910 CONTINUE
      GO TO 4
    2 DO 920 J=2,M
      R=FLOAT(J-1)
      WT=0.54+0.46*COS(PI*R/FM)
      Q(J)=Q(J)*WT
      Q(NSPEC+2-J)=Q(J)
  920 CONTINUE
      GO TO 4
    3 DO 930 J=2,M
      WT=FLOAT(M+1-J)/FM
      Q(J)=Q(J)*WT
      Q(NSPEC+2-J)=Q(J)
  930 CONTINUE
    4 JL=M+1
      JH=NSPEC+2-JL
      DO 911 J=JL,JH
      Q(J)=(0.,0.)
  911 CONTINUE
C
C     TAKE DIRECT FFT TO OBTAIN SPECTRUM.
      NN=NSPEC
      CALL FOUR(Q,NN,-1)
   10 RETURN
      END