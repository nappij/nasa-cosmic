      SUBROUTINE ORBUPD(TOP,DELV,TV)
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      COMMON/CNBODY/DUM4(5),ZMU,DUM5(3)
C
      COMMON/INUMP/ ISPNP
      COMMON/ITCNTL/IPULSE,ISPLSE,KPULSE,ITSW,IOTSW
C
      COMMON/ORBNEW/ROD(3),VOD(3),TST
C
      COMMON/RPOOL1/DUM1(11),SA(3,3),DUM2(105)
C
C
      DIMENSION TV(3)
C
      DIMENSION VB(3),X(3),XD(3)
C
      DATA NUM/1/
      DATA RD2DG/57.295779513D0/
C
      DO 1 I=1,3
      VB(I)=DELV*TV(I)
    1 CONTINUE
      CALL XFIND(ROD,VOD,ZMU,TST,TOP,X,XD)
      DO 2 I=1,3
      ROD(I)=X(I)
      VOD(I)=XD(I)+SA(I,1)*VB(1)+SA(I,2)*VB(2)+SA(I,3)*VB(3)
    2 CONTINUE
      TST=TOP
C   RECONSTRUCT CLASSICAL ORBITAL ELEMENTS AFTER THRUSTING
C
C   MAGNITUDE OF R VECTOR
      R1=ROD(1)
      R2=ROD(2)
      R3=ROD(3)
      R=DSQRT(R1*R1+R2*R2+R3*R3)
C
C   MAGNITUDE OF V VECTOR
      V1=VOD(1)
      V2=VOD(2)
      V3=VOD(3)
      V=DSQRT(V1*V1+V2*V2+V3*V3)
C
C   NEW ANGULAR MOMENTUN VECTOR OF THE ORBIT
      H1=R2*V3-V2*R3
      H2=R3*V1-V3*R1
      H3=R1*V2-V1*R2
      H=DSQRT(H1*H1+H2*H2+H3*H3)
C
C   COMPUTE THE SEMI-MAJOR AXIS
      AS=ZMU*R/(2.0D0*ZMU-R*V**2)
C
C    COMPUTE THE ECCENTICITY
      E=1.0D0-H*H/(ZMU*AS)
      IF(E.LT.0.0D0) E=0.0D0
      E=DSQRT(E)
C
C   COMPUTE THE INCLINATION ANGLE
      IF(H3.EQ.0.0) EI=1.5707963267949D0
      H12=DSQRT(H1*H1+H2*H2)
      EI=DATAN2(H12,H3)
C
C   COMPUTE THE LONGITUDE OF ASCENDING NODE
      DEI=DABS(EI)
      BW=DATAN2(H1,-H2)
      IF(DEI.LT.1.0D-9) BW=0.0D0
C
C   COMPUTE THE TRUE ANOMALY
      FNUM=H*(R1*V1+R2*V2+R3*V3)
      FDNUM=H*H-ZMU*R
      F=DATAN2(FNUM,FDNUM)
C
C   COMPUTE THE ARGUMENT OF LATITUDE
      IF(DEI.LT.1.0D-9) GO TO 3
      DTHE=DSIN(EI)*(R1*DCOS(BW)+R2*DSIN(BW))
      THE=DATAN2(R3,DTHE)
      GO TO 4
 3    CONTINUE
      THE=DATAN2(R2,R1)
 4    CONTINUE
C
C   COMPUTE THE ARGUMENT OF PERIGEE
      W=THE-F
C
C    COMPUTE THE ECCENTRIC ANOMALY
      ENUM=DSQRT(1.0D0-E*E)*DSIN(F)
      EDNUM=E+DCOS(F)
      ECC=DATAN2(ENUM,EDNUM)
C
C   COMPUTE THE MEAN ANOMALY
      EM=ECC-E*DSIN(ECC)
C
C   CONVERT THE ANGULAR VALUES FROM RADIUS TO DEGREES BEFORE PRINT
      EI=EI*RD2DG
      BW=BW*RD2DG
      F=F*RD2DG
      W=W*RD2DG
      ECC=ECC*RD2DG
      EM=EM*RD2DG
C
C   CONVERT THE TIME IN SECONDS INTO HHMMSS
      CALL TCNVRT(YMD,TEMP,SEC,TLAST,TOP,2)
      HMS=HMSOUT(DMOD(SEC,86400.0D0))
      NPULSE=KPULSE+1
      WRITE(6,15) NPULSE
 15   FORMAT('    NO. OF PULSE =',I3)
      WRITE(6,20) HMS
 20   FORMAT('    TIME OF IMPULSIVE THRUSTING(HHMMSS)=',F20.6)
C    PRINT ONLY EVERY 10 PULSES FOR ORBIT INFORMATION
      NPS=NPULSE/ISPNP
      IF(NPULSE.EQ.IPULSE) GO TO 350
      IF(NPS.NE.NUM) GO TO 400
      NUM=NUM+1
 350  CONTINUE
C   PRINT MESSAGE FOR INTERRUPTION DUE TO THRUSTING
C
      WRITE(6,10)
 10   FORMAT('**** KEPLERIAN PARAMETERS AFTER THRUSTING')
      WRITE(6,25) DELV
 25   FORMAT('    CHANGE IN MAG. OF VELOCITY(KM/SEC)=',F20.10)
      WRITE(6,30) AS
 30   FORMAT('    SEMI-MAJOR AXIS(KM)=',F20.8)
      WRITE(6,40) E
 40   FORMAT('    ECCENTRICITY=',F20.10)
      WRITE(6,50) EI
 50   FORMAT('    INCLINATION ANGLE(DEG)=',F20.10)
      WRITE(6,60) BW
 60   FORMAT('    LONGITUDE OF ASCENDING NODE(DEG)=',F20.10)
      WRITE(6,70) W
 70   FORMAT('    ARGUMENT OF PERIGEE(DEG)=',F20.10)
      WRITE(6,80) F,ECC,EM
 80   FORMAT('    TRUE,ECCENTRIC,MEAN ANOMALIES(DEG)=',3(F20.10,2X))
      WRITE(6,100) R1,R2,R3
 100  FORMAT('    POSITION VECTOR=',3(F20.10,2X))
      WRITE(6,200) V1,V2,V3
 200  FORMAT('    VELOCITY VECTOR=',3(F20.10,2X))
      WRITE(6,300) H1,H2,H3,H
 300  FORMAT('    ANGULAR MOMENTUM VECTORS=',3F20.10,'MAG=',F20.10)
 400  CONTINUE
      TST=TOP
      RETURN
      END
