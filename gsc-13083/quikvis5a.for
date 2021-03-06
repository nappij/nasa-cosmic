      SUBROUTINE QUIKVIS5A(IDTARG,TARGNAMES,KTARGTYP,TARGPARM,IERR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE IS PART OF THE QUIKVIS PROGRAM.  IT IS THE DRIVER FOR
C COMPUTING THE TARGET AVAILABILITY FOR INDIVIDUALLY SPECIFIED TARGETS
C AND WRITING THE RESULTS.
C
C
C VARIABLE      DIM       TYPE I/O DESCRIPTION
C --------      ---       ---- --- -----------
C
C IDTARG      MAXTARGS     I*4  I  DESCRIBED IN QUIKVIS(=MAIN) PROLOGUE.
C
C TARGNAMES   MAXTARGS    CH*16 I  DESCRIBED IN QUIKVIS(=MAIN) PROLOGUE.
C
C KTARGTYP    MAXTARGS     I*4  I  DESCRIBED IN QUIKVIS(=MAIN) PROLOGUE.
C
C TARGPARM NPARMS,MAXTARGS R*8  I  DESCRIBED IN QUIKVIS(=MAIN) PROLOGUE.
C
C IERR           1         I*4  O  ERROR RETURN FLAG
C                                  =0, NO ERROR
C                                  =OTHERWISE, ERROR.
C
C***********************************************************************
C
C BY C PETRUZZO/GFSC/742.   2/86.
C       MODIFIED.... 9/96. CJP. ADDED EVENTMA ARRAY;  ADDED REQMTMA
C                               ARRAY AND DELETED TAREQMT ARRAY TO WORK
C                               IN MEAN ANOMALY INSTEAD OF TRUE;  ADDED
C                               HEADER WRITE FOR DETAIL DATA FILE; ADDED
C                               QUIKVIS5Z CALL(WAS MOVED FROM ..5A2C2);
C                               CHANGED INFO WRITTEN ON LUSCR1;  CHANGED
C                               SOME DEBUG CODE;  COMMENT CHANGES FOR
C                               CLARITY; MOVED LUSCR1 WRITE STATEMENT TO
C                               QUIKVIS5U
C
C***********************************************************************
C
      INCLUDE 'QUIKVIS.INC'
C
      CHARACTER*16 TARGNAMES(MAXTARGS)
      INTEGER*4 IDTARG(MAXTARGS)
      REAL*8 TARGPARM(NPARMS,MAXTARGS)
      INTEGER*4 KTARGTYP(MAXTARGS)
      REAL*8 VISTIMES(MAXNODES),EVENTMA(MAXNODES)
C
      REAL*8 SUNPOS(3),ELEMS(6),XUNIT(3),UTARG(3)
      REAL*8 ENDREC/'ENDREC  '/ ! FOR ERROR CHECK IN QUIKVIS5A2A.
      CHARACTER*18 DATETIME
      CHARACTER*5 CHARID,I4CHAR
      CHARACTER*25 CHNIGHT
      CHARACTER*20 CH20
      CHARACTER*21 CHYMD
      REAL*8 REQMTMA(2,MAXREQMT,MAXNODES)
C
C    NEEDALL IS A FLAG TELLING QUIKVIS5X WHETHER THE PROGRAM NEEDS MEAN
C    ANOMALY IN/OUT VALUES FOR ALL OBSVN REQMTS OR IF ONLY THE TOTAL
C    AVAILABILITY TIME IS OF INTEREST.
      LOGICAL NEEDALL
C
      IBUG = 0
      LUBUG = 19
C
C
C
C ****************
C *  INITIALIZE  *
C ****************
C
      IERR = 0
      ELEMS(1) = SMA
      ELEMS(2) = ECC
      ELEMS(3) = ORBINCL
      ELEMS(5) = ARGP
      ELEMS(6) = 0.D0
      NEEDALL = DODETAIL  ! SEE NEEDALL COMMENT ABOVE
      CALL MTXSETR8(REQMTMA,888.D0/DEGRAD,2*MAXREQMT,MAXNODES)
      CALL MTXSETR8(EVENTMA,777.D0/DEGRAD,MAXNODES,1)
C
C
C ************************************************
C *  PUT HEADER RECORDS ON THE XYPLOT DATA FILE  *
C ************************************************
C
      IF(DOXYPLOT) THEN
        CALL QUIKVIS5A1(IDTARG,TARGNAMES)
        END IF
C
C
C *************************************************
C *  PUT HEADER ON THE DETAILED OUTPUT DATA FILE  *
C *************************************************
C
      IF(LEVDETFILE.NE.0) THEN
       CALL QUIKVIS5A3
       END IF
C
C
C ************************************
C *  PROCESS THE TARGETS ONE-BY-ONE  *
C ************************************
C
C
      DO 1000 ITARG = 1,NUMTARGS
C
      IF(INTERACTIVE) THEN
        WRITE(LUPROMPT,9001) ITARG,NUMTARGS,DATETIME(0)
 9001   FORMAT(' START PROCESSING TARG NUMBER ',I3,' OF ',I3,' AT ',A)
        END IF
C
C
C*** STEP ALONG THE TIME RANGE AND STORE INFO ON A SCRATCH FILE AT
C    EACH TIME PROCESSED.  AFTER ALL TIMES HAVE BEEN PROCESSED, OUTPUT
C    THE DATA FOR THIS TARGET IN FINAL FORM.
C
      DO 2000 ITIME=1,NUMTIMES
      T50 = TSTART + (ITIME-1) * DELTIME
C
C
C    SET THE TARGET LOCATION PARAMETERS.  THIS IS DONE INSIDE THE ITIME
C    LOOP IN CASE THE TARGET IS MOVING(IE, LOCATION DEPENDS ON TIME).
C
      IF(KTARGTYP(ITARG).EQ.3) THEN         ! FIXED CELESTIAL
        RATARG =   TARGPARM(1,ITARG)
        DECTARG =  TARGPARM(2,ITARG)
        UTARG(1) = TARGPARM(3,ITARG)
        UTARG(2) = TARGPARM(4,ITARG)
        UTARG(3) = TARGPARM(5,ITARG)
      ELSE IF(KTARGTYP(ITARG).EQ.1) THEN    ! MOVING CELESTIAL
        CALL TGLOC(1,1,TARGNAMES(ITARG),1,DUM,1,1,UTARG,
     *       1,T50, 0,DUM, 0,DUM, 0,DUM, 0,DUM, LUERR,IERR)
        IF(IERR.NE.0) GO TO 9999
        CALL UNIVEC(UTARG)
        CALL XYZSPH(-1,RATARG,DECTARG,DUM,UTARG,1.D0)
      ELSE                                  ! BAD TARGET TYPE
C      ERROR SHOULD HAVE BEEN FOUND BY QUIKVIS1.
        STOP ' QUIKVIS5A. CODING ERROR. STOP 1.'
        END IF
C
C    GET THE SUN LOCATION.  IT IS NOT ALWAYS NEEDED, BUT CALLING IT
C    IS EASY AND ASSURES THE INFO IS PRESENT IF NEEDED.
C
      CALL SOLM50(T50,SUNPOS,0)
C
C    SET THE RAAN RANGE.  IT IS DONE INSIDE THE ITIME LOOP IN CASE THE
C    RAAN'S ARE DEFINED IN TERMS OF MEAN SOLAR TIME.  IF RAANS WERE
C    DEFINED DIRECTLY, THE FIRSTNODE, NUMNODES, AND DELNODE PARAMETERS
C    COULD HAVE BEEN SET BEFORE THE TIME LOOP BEGAN, BUT CODE IS CLEANER
C    THIS WAY.
C
      CALL QUIKVIS5Y(T50,FIRSTNODE,NUMNODES,DELNODE)
C
C    COMPUTE THE MEAN SOLAR TIME AT THE FIRST ASCENDING NODE LOCATION;
C    USED FOR OUTPUT(VIA LUSCR1 FILE), NOT FOR AVAILABILITY COMPUTATIONS
C
      CALL XYZSPH(1,FIRSTNODE,0.D0,1.D0,XUNIT,1.D0)
      FIRSTMST = TIMLOC(T50,XUNIT,1,0)
      IF(DABS(FIRSTMST-86400.D0).LT.1.D0) FIRSTMST = 0.D0
      DELMST = DELNODE/TWOPI * 86400.D0
C
      IF(IBUG.NE.0) THEN
        CALL XYZSPH(-1,RASUN,DECSUN,DUM,SUNPOS,1.D0)
        WRITE(LUBUG,8501)
     *    IDTARG(ITARG),RATARG*DEGRAD,DECTARG*DEGRAD,
     *    PAKTIM50(T50),RASUN*DEGRAD,DECSUN*DEGRAD,
     *    NODEOPT,FIRSTNODE*DEGRAD,FIRSTMST/3600.D0,DELNODE*DEGRAD
 8501   FORMAT(/,
     *  ' QUIKVIS5A DEBUG 8501.'/,
     *  '    IDTARG=',I5,'  TARG RA,DEC=',2F8.2/,
     *  '    TIME=',F13.6,' SUN RA,DEC=',2F8.2/,
     *  '    NODEOPT=',I2,' FIRSTNODE = ',F8.2,' FIRSTMST(HRS)=',F7.4,
     *        ' DELNODE=',F8.2)
        END IF
C
C
      CALL MTXSETR8(VISTIMES,-999.D0,MAXNODES,1)  ! FOR EASIER DEBUG
C
C*** FOR THE CURRENT TARGET AND TIME, STEP ALONG THE RAAN RANGE AND
C    COMPUTE THE DURATION THAT THE TARGET SATISFIES THE REQUIREMENTS
C
      DO INODE=1,NUMNODES
        ELEMS(4) = FIRSTNODE + (INODE-1) * DELNODE    ! = RAAN
C
C      FOR EACH REQUIREMENT, COMPUTE THE PER-ORBIT AVAILIBILITY DURATION
C      AND THE MEAN ANOMALIES WHEN THE REQUIREMENTS ARE FIRST AND LAST
C      SATISFIED.
C
        CALL QUIKVIS5X(ELEMS,UTARG,SUNPOS,
     *       VISTIMES(INODE),NEEDALL,REQMTMA(1,1,INODE),IERR)
        IF(IERR.NE.0) GO TO 9999
C
C
C      FIND THE MEAN ANOMALY WHERE S/C CROSSES THE PLACE IN ITS ORBIT
C      WHERE THE EVENT SPECIFIED BY THE 'KRELTIME' GLOBAL PARAMETER
C      OCCURS.  EXAMPLE: IF KRELTIME=2, FIND THE MEAN ANOMALY WHERE
C      SUNRISE OCCURS.  QUIKVIS5Z COMPUTES THE TIME SINCE PERIGEE WHERE
C      THE EVENT OCCURS.  AT THIS WRITING, THIS IS NEEDED ONLY WHEN THE
C      DETAIL OUTPUT OPTION IS ON, SO BYPASS IT WHEN DODETAIL IS FALSE.
C
        IF(DODETAIL) THEN
          CALL QUIKVIS5Z(ELEMS(4),SUNPOS,RATARG,DELTIM)
          EVENTMA(INODE) = DELTIM/PERIOD*TWOPI
          END IF
C
        END DO    ! END 'INODE=' LOOP
C
C
C    PUT INFO ON LUSCR1. READ BY QUIKVIS5A2'S LOWER LEVEL ROUTINES(VIA
C    QV5READ, AN ENTRY POINT IN QUIKVIS5U).
C
      CALL QV5WRITE(ITIME,T50,ITARG,IDTARG(ITARG),TARGNAMES(ITARG),
     *      FIRSTNODE,DELNODE,FIRSTMST,DELMST,NUMNODES,
     *      EVENTMA, VISTIMES, REQMTMA)
C
 2000 CONTINUE ! END ITIME LOOP
C
C*** OUTPUT INFO FOR THIS TARG.
C
C
C     >>>>  END COMPUTATIONS FOR THIS TARGET; OUTPUT ITS INFO  <<<<
C
      CALL QUIKVIS5A2(ITARG,IDTARG,TARGNAMES,KTARGTYP,TARGPARM,IERR)
C
 1000 CONTINUE ! END ITARG LOOP
C
 9999 CONTINUE
      RETURN
C
C***********************************************************************
C
C
C**** INITIALIZATION CALL. PUT GLOBAL PARAMETER VALUES INTO THIS
C     ROUTINE'S LOCAL VARIABLES.
C
      ENTRY QVINIT5A
C
      CALL QUIKVIS999(-1,R8DATA,I4DATA,L4DATA)
      RETURN
C
C***********************************************************************
C
      END
