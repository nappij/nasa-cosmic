C
C            **** START RDCAT.INC ****
C
C THIS IS THE INCLUDE FILE FOR THE TARGET CATALOGUE READER. IT DEFINES
C PARAMETERS THAT ARE USED WITHIN THE READER AND WHICH WE MAY WANT TO
C CHANGE LATER.
C
C IF THIS INCLUDE FILE IS CHANGED, RECOMPILE ALL ROUTINES WHOSE NAMES
C BEGIN WITH 'RDCAT'.
C
C TOSS CONTAINS A TEXT FILE, TARGCATLG.TXT, DEFINING THE CATALOGUE'S
C FORMAT.
C
C***********************************************************************
C
C BY C PETRUZZO, GSFC/742, 12/84, 7/85.
C    MODIFIED.....
C
C***********************************************************************
C
C
C MAXIMUM NUMBER OF TARGET TYPES RECOGNIZED(=1,2,...,8)
      PARAMETER MAXTYPE = 8
C
C TOTAL NUMBER OF DATA ELEMENTS(PER TARGET) RDCAT WAS DESIGNED TO
C HANDLE. THE PROGRAM CALLING RDCAT MAY ALLOW FOR FEWER.
      PARAMETER MAXDATA = 20
C
C CONVERSION FACTORS FROM FILE UNITS TO TARGPARM UNITS. FACTOR ARRAY IS
C INITIALIZED THIS WAY SO NEW TARGET TYPES OR DIFFERENT MAXDATA VALUES
C CAN BE USED WITHOUT CODE CHANGES IN MANY PLACES.
C    
C    NUMBER OF REQUIRED DATA ELEMS FOR EACH TARGET TYPE.
      PARAMETER NUMREQ01 = 0,
     *          NUMREQ02 = 4,
     *          NUMREQ03 = 3,
     *          NUMREQ04 = 2,
     *          NUMREQ05 = 0,
     *          NUMREQ06 = 3,
     *          NUMREQ07 = 0, ! SPECIAL CASE, SEE RDCAT3B2
     *          NUMREQ08 = 0
C    MAXIMUM NUMBER OF OTHER(IE, NOT REQ'D) DATA ELEMS FOR EACH TYPE
      PARAMETER NOTREQ01 = MAXDATA-NUMREQ01,
     *          NOTREQ02 = MAXDATA-NUMREQ02,  
     *          NOTREQ03 = MAXDATA-NUMREQ03,
     *          NOTREQ04 = MAXDATA-NUMREQ04,
     *          NOTREQ05 = MAXDATA-NUMREQ05,
     *          NOTREQ06 = MAXDATA-NUMREQ06,
     *          NOTREQ07 = MAXDATA-NUMREQ07,
     *          NOTREQ08 = MAXDATA-NUMREQ08
      PARAMETER RADDEG = 1.D0/57.29577951308232D0
      REAL*8 FACTOR(MAXDATA,MAXTYPE) / 
     *                       NOTREQ01*1.D0,  ! 1
     *     2*RADDEG,2*1.D0,  NOTREQ02*1.D0,  ! 2
     *     2*RADDEG,1.D0,    NOTREQ03*1.D0,  ! 3 SPECIAL CODE RDCAT3B
     *     2*RADDEG,         NOTREQ04*1.D0,  ! 4
     *                       NOTREQ05*1.D0,  ! 5
     *     RADDEG, 2*1.D0,   NOTREQ06*1.D0,  ! 6
     *                       NOTREQ07*1.D0,  ! 7 SPECIAL CODE RDCAT3B
     *                       NOTREQ08*1.D0 / ! 8
C
C ARRAY = NUMBER OF REQUIRED DATA ELEMENTS FOR EACH TARGET TYPE.
      INTEGER*4 NUMPARM(MAXTYPE)/
     *   NUMREQ01,NUMREQ02,NUMREQ03,NUMREQ04,
     *   NUMREQ05,NUMREQ06,NUMREQ07,NUMREQ08 /
C
C TARGET TYPES NEEDING SPECIAL HANDLING
      PARAMETER NSPECIAL=2
      INTEGER KSPECIAL(NSPECIAL)/3,7/
C
C VALUE RECOGNIZED BY RDCAT, ETC AS A NON-OVERRIDDEN DEFAULT. BEFORE
C READING A RECORD FROM THE CATALOGUE, RDCAT3 SETS THE TARGDATA ARRAY
C TO THIS VALUE. OTHER ROUTINES SEE IF THE VALUE WAS CHANGED BY THE READ
C STATEMENT.
      REAL*8 DEFALT/1.D20/
C
C ERROR FLAG ASSIGNMENTS(INTERNAL TO READER, NOT OUTPUT TO CALLER):
      INTEGER
     *  KERRFLG1/8850/,  ! REQUIRED DATA MISSING FROM CATALOGUE RECORD
     *  KERRFLG2/9950/   ! CALLING PGM USES MAXPARM TOO SMALL
C
C 
C
C            **** END RDCAT.INC ****
C
