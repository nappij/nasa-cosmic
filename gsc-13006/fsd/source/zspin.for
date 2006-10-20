      SUBROUTINE ZSPIN(TSTOP,FREQ,DELTAT,LSAVE,TSTART,JUMP)
C
      IMPLICIT REAL*8 (A-H,O-Z)
C
C        'ZSPIN' DETERMINES THE INITIAL AND FINAL TIMES ASSOCIATED WITH
C        THE CONTROL AND REMOVAL OF CONTROL ABOUT THE Z-AXIS.
C
      COMMON/ZSPINR/ DTZMA,PZDT,CMZO,ISPIN3,JSPIN
C
      GO TO (10,20,30),JUMP
   10 JUMP=2
      TSAVET=TSTOP
      FSAVE=FREQ
      DSAVE=DELTAT
      TSTOP=TSTART + DTZMA
      IF(DTZMA.GE.FREQ) GO TO 15
      FREQ=DTZMA/4.D0
      DELTAT=FREQ/4.D1
      IF(FREQ.EQ.0) FREQ=FSAVE
      IF(FREQ.EQ.0) DELTAT=DSAVE
   15 TS=DMOD(TSTOP,8.64D4)
      HMS=HMSOUT(TS)
      WRITE(6,10000) HMS
      WRITE(6,10003) FREQ,DELTAT
C
C
      RETURN
C
C
   20 JUMP=3
      JSPIN=10
      LSAVE=1
      TSTOP=TSTOP + PZDT
      DELTAT=FREQ/4.D1
      IF(PZDT.GE.FSAVE) GO TO 25
      FREQ=PZDT/4.D0
      DELTAT=FREQ/4.D1
   25 TS=DMOD(TSTOP,8.64D4)
      HMS=HMSOUT(TS)
      WRITE(6,10001) HMS
      WRITE(6,10003) FREQ,DELTAT
C
C
      RETURN
C
C
   30 ISPIN3=0
      LSAVE=1
      JUMP=1
      TSTOP=TSAVET
      FREQ=FSAVE
      DELTAT=DSAVE
      TS=DMOD(TSTOP,8.64D4)
      HMS=HMSOUT(TS)
      WRITE(6,10002) HMS
      WRITE(6,10003) FREQ,DELTAT
C
C
      RETURN
C
10000 FORMAT('0',3X,'Z-SPIN AXIS MOMENT ACTIVATED'//' ',3X,
     .              'INTEGRATING TO THE LEADING EDGE OF PULSE AT ',
     .               F10.3)
C
10001 FORMAT('0',3X,'SPIN AXIS MOMENT'//'0',3X,'CONTINUING PROBLEM TO ',
     .              F10.3)
C
10002 FORMAT('0',3X,'SPIN AXIS PROBLEM OFF'//'0',3X,
     .             'CONTINUING PROBLEM TO ',F10.3)
C
10003 FORMAT('0',3X,'WITH A PRINT FREQUENCY OF ',G15.5/' ',3X,
     .              'AND A DELTA-TIME OF ',G15.5)
C
      END
