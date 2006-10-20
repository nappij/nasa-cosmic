C
C *** LAST REVISED ON 20-AUG-1987 11:42:35.56
C *** SOURCE FILE: [DL.GRAPHICS.LONGLIB]REFLIB.FOR
C
C ************************************************************************
C
C RAMTEK EMULATION FILE ROUTINES FOR THE LONGLIB GRAPHICS LIBRARY
C
C THIS CODE IS ESSENTIALLY FORTRAN 77 COMPATIBLE BUT USES A LARGE 
C "BYTE" ARRAY.  THERE ARE A FEW OTHER VAX FORTRAN CODING TRICKS.
C RELATIVELY SIMPLE MODIFICATIONS CAN BE USED TO CONVERT THE NON-FORTRAN
C 77 MACHINE DEPENDENT STUFF TO MORE GENERIC STUFF.  FOR EFFICIENCY
C REASONS, THIS CODE IS LEFT NON-STANDARD.
C
C ************************************************************************
C
	SUBROUTINE RAMOPEN(ICHAN,IDEV,IDDEV,IERR)
C
C	OPEN/INIT RAMTEK EMULATION FILE CHANNEL
C
C	INPUTS:
C
C	IDEV	(I)	DEVICE TYPE (1=1280x1024 OR 2=512x512)
C
C	OUTPUTS:
C
C	ICHAN	(I)	RETURNED CHANNEL NUMBER (ALWAYS=1)
C	IDDEV	(I)	RETURNED RAMTEK DEVICE NUMBER (ALWAYS=0)
C	IERR	(I)	RETURNED ERROR CODE (0=NO ERROR)
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	IOTYPE=IDEV			! STORE RAMTEK EMULATION FILE SIZE CODE
	IDDEV=0				! RETURN RAMTEK DEVICE NUMBER
	ICHAN=1				! "CHANNEL" NUMBER
C
C	SET ARRAY SIZE
C
	IXWIDE=1280			! ARRAY X DIMENSION SIZE
	IYWIDE=1024			! ARRAY Y DIMENSION SIZE
	IF (IDEV.EQ.2) THEN		! 512X512 ARRAY
		IXWIDE=512
		IYWIDE=512
	ENDIF
C
C	INITIALIZE LINE TYPES
C
	MT=-1				! LINE BIT PATTERN SOLID
	NT=1				! LINE WIDTH
	IST=1				! BIT PATTERN SCALE FACTOR
C
C	INITIALIZE IMAGE MODE
C
	LX=0				! IMAGE MODE START X
	LY=0				! IMAGE MODE START Y
	XL(1)=0				! LEFT DEFAULT WINDOW
	YL(1)=0				! UPPER DEFAULT WINDOW 
	XL(2)=IXWIDE-1			! RIGHT DEFAULT WINDOW
	YL(2)=IYWIDE-1			! LOWER DEFAULT WINDOW
	IS=0				! PIX SEQ: L-R, T-B
	RETURN
	END
C
C
	SUBROUTINE RAMCLOSE(ICHAN)
C
C	TERMINATE RAMTEK EMULATION FILE PLOTTING
C	MAY HAVE THE SIDE EFFECT CLOSING THEN REOPENING PRINTER HISTORY FILE
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL NUMBER (IGNORED)
C
	CHARACTER*(*) NAME
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	BYTE B(1280),IB
	INTEGER PEN
	CHARACTER*70 FNAME
	CHARACTER*1 DEV
	DATA IPASS/0/
C
C	PROMPT USER FOR OUTPUT FOR THIS CALL
C
	IF (IPASS.EQ.2) RETURN	! ALREADY COMPLETED A NON-INTERACTIVE PASS
	IPASS=1			! INTERACTIVE=1
C
100	CONTINUE
	CALL CTERM(1)
21	WRITE(*,1)
1	FORMAT('$Plot-Buffer Ouput Device? (T,F,O,P,X) ')
	READ(*,2) DEV
	IDEV=ICHAR(DEV)
	IF (IDEV.GE.96) IDEV=IDEV-32
	IF (IDEV.EQ.32.OR.IDEV.EQ.63) THEN
		WRITE(*,27)
27		FORMAT(/' Available Ramtek Emulation Output Devices:'//
     $			5x,' T : Screen Graphics Terminal'/
     $			5x,' F : Ramtek Emulation File'/
     $			5x,' O : Ramtek Emulation File Overlay'/
     $			5x,' M : Longlib MetaFile Output'/
     $			5x,' X : Exit'//)
		GOTO 100
	ENDIF
2	FORMAT(A1)
	IF (IDEV.EQ.84) THEN	! TERMINAL SCREEN
		IARG=1
		CALL WHEREVT(XS,YS,XS,YS,RX,RY,ILU,IY,IX,IX,IY)
		IF (ILU.LT.0) THEN
			WRITE (*,11)
11			FORMAT('$Enter NUMBER of Terminal Code: ')
			READ (*,*,ERR=100) IOPT
		ENDIF
		IOPT=0
	ENDIF
	IF (IDEV.EQ.70.OR.IDEV.EQ.82) THEN	! RAMTEK FILE
		IARG=2
		IOPT=1
35		WRITE (*,15)
15		FORMAT('$Enter Ramtek Emulation File Name: ')
		READ(*,20) FNAME
20		FORMAT(A70)
	ENDIF
	IF (IDEV.EQ.79) THEN	! RAMTEK FILE (OVERLAY)
		IARG=2
		IOPT=2
		WRITE(*,15)
		READ(*,20) FNAME
	ENDIF
	IF (IDEV.EQ.77.OR.IDEV.EQ.80) THEN	! PRINTER PACKAGE
		IARG=3
	ENDIF
	IF (IDEV.EQ.88) RETURN	! EXIT
	GOTO 200
C
C	ENTRY FOR NON-INTERACTIVE RAMTEK EMULATION FILE STUFF
C
	ENTRY REFDIS(IARGI,IOPTI,NAME,RSX,RSY)
C
C	IARGI	(I)	OUTPUT DEVICE CODE
C			 -1 = GRAPHICS TERMINAL
C				(IOPT=TERMINAL TYPE SEE WHEREVT)
C				RSX, RSY USED FOR TERMINAL RESOLUTION
C			 1 = GRAPHICS TERMINAL
C				(IOPT=TERMINAL TYPE SEE FRAME)
C				INTERNAL RESOLUTION USED
C			 2 = RAMTEK EMULATION FILE
C				(IOPT=1 IS ABSOLUTE WRITE)
C				(IOPT=2 IS OVERLAY)
C				(IOPT=3 IS ERASE)
C			 -3 = PRINTER HISTORY FILE
C				RSX, RSY USED FOR METAFILE RESOLUTION
C			 3 = PRINTER HISTORY FILE
C				INTERNAL RESOLUTION USED
C	IOPTI	(I)	OPTION CODE (SEE ABOVE)
C	NAME	(C)	FILE NAME FOR RAMTEK EMULATION FILE
C	RSX,RSY (I)	DEVICE RESOLUTION (INCH/PIXEL)
C
	IARG=IARGI
	IOPT=IOPTI
	FNAME=NAME
	IPASS=2					! NON-INTERACTIVE=2
200	CONTINUE
C
C	OUTPUT RAMTEK EMULATION ARRAY TO SELECTED DEVICE
C
	IF (IARG.EQ.2) THEN			! OUTPUT TO FILE
		IXW=1280
		IF (IXWIDE.EQ.512) IXW=512
		OPEN(UNIT=2,FILE=FNAME,ACCESS='DIRECT',STATUS='UNKNOWN',
     $		 RECL=IXW,FORM='FORMATTED',ERR=99)
		DO 250 IY=1,IYWIDE
			IYX=(IY-1)*IXWIDE
			IF (IOPT.GT.1) THEN
			    IF (IXWIDE.EQ.512) THEN
			READ(2'IY,260,ERR=97) (B(II),II=1,IXWIDE)
			    ELSE
			READ(2'IY,261,ERR=97) B
			    ENDIF
			ENDIF 
			DO 245 IX=1,IXWIDE
				IB=A(IX+IYX)
				IF (IOPT.EQ.1.OR.(IB.NE.0.AND.
     $				 IOPT.EQ.2).OR.(IB.EQ.0.AND.
     $				 IOPT.EQ.3)) B(IX+1)=IB
245			CONTINUE
C
C	DIRECT-ACCESS WRITE AND RUN-TIME DEFINED FORMAT STATEMENT
C
			IF (IXWIDE.EQ.512) THEN
			  WRITE(2'IY,260,ERR=97) (B(II),II=1,IXWIDE)
260			  FORMAT(512A1)
			ELSE
			  WRITE(2'IY,261,ERR=97) B
261			  FORMAT(1280A1)
			ENDIF
C
250		CONTINUE
	ENDIF
C
	IAA=IABS(IARG)
	IF (IAA.EQ.3.OR.IAA.EQ.1) THEN
		IF (IAA.EQ.3) THEN		! META FILE
			CALL WHEREPR(XS,YS,XS,YS,XS,YS,RX,RY,ILU,IY,IX,IX)
			IF (ILU.LT.0) THEN
C
C	IF METAFILE CLOSED, OPEN IT
C
			 ILU=3
			 CALL PPLOTS(ILU,0.,0.,1.)
			 CALL WHEREPR(XS,YS,XS,YS,XS,YS,RX,RY,ILU,IY,IX,IX)
			ELSE
C
C	ELSE ISSUE A NEWPAGE COMMAND
C
			 CALL NEWPAGE
			ENDIF
C
C	RESCALE RESOLUTION OF OUTPUT
C
			RX=RX*5.0/3.0
			RY=RY*5.0/3.0
			IF (IARG.LT.0) THEN
				RX=RSX
				RY=RSY
			ENDIF
		ENDIF
		IF (IAA.EQ.1) THEN
			CALL WHEREVT(XS,YS,XS,YS,RX,RY,ILU,IY,IX,IX,IY)
			IF (ILU.LT.0) THEN
C
C	IF TERMINAL OUTPUT CLOSED, OPEN IT
C
			 CALL VPLOTS(IOPT,0.,0.,1.)
			 CALL WHEREVT(XS,YS,XS,YS,RX,RY,ILU,IY,IX,IX,IY)
			ENDIF
C
C	RESCALE RESOLUTION OF OUTPUT
C
			RX=RX*4
			RY=RY*4
			IF (IARG.LT.0) THEN
				RX=RSX
				RY=RSY
			ENDIF
		ENDIF
C
C	OUTPUT TO METAFILE AND/OR TERMINAL
C
		LPEN=-3
		DO 300 IY=1,IYWIDE
			IYX=(IYWIDE-IY)*IXWIDE
			PEN=-1
			DO 305 IX=0,IXWIDE
				II=A(IX+IYX).AND.255
				IF (IX.EQ.IXWIDE) II=-2
				IF (II.NE.PEN) THEN
					IF (PEN.NE.-1.AND.PEN.NE.0) THEN
				   XS=(IX0+0.5)*RX
				   XS1=(IX-0.5)*RX
				   YS=(IY+0.5)*RX
				   IF (IARG.EQ.1) THEN
					IF (LPEN.NE.PEN)
     $					  CALL PLOTVT(FLOAT(PEN),0.,0)
					CALL PLOTVT(XS,YS,3)
					CALL PLOTVT(XS1,YS,2)
				   ENDIF
				   IF (IARG.EQ.3) THEN
					IF (LPEN.NE.PEN)
     $					  CALL PPLOT(FLOAT(PEN),0.,0)
					CALL PPLOT(XS,YS,3)
					CALL PPLOT(XS1,YS,2)
				   ENDIF
				   LPEN=PEN
					ENDIF
					PEN=II
					IX0=IX
				ENDIF
305			CONTINUE
300		CONTINUE
		IF (IARG.EQ.3) CALL PPLOT(0.,0.,-3)	! UP PEN FOR METAFILE
		IF (IARG.EQ.1) CALL PLOTVT(0.,0.,-3)	! UP PEN FOR TERMINAL
	ENDIF
C
	IF (IPASS.EQ.1) GOTO 100	! MORE INTERACTIVE STUFF
	RETURN
99	WRITE(*,98)
98	FORMAT(' *** ERROR OPENING RAMTEK EMULATION FILE ***')
	GOTO 35
97	WRITE(*,96)
96	FORMAT(' *** ERROR READING/WRITING RAMTEK EMULATION FILE ***')
	GOTO 35
	END
C
	SUBROUTINE RMPLOT(ICHAN,N,IP,ICOL,IERR)
C
C	PLOT A LINE OF CONNECTED VECTORS
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	N	(I)	NUMBER OF VECTOR PAIRS
C	IP	(I)	ARRAY OF X,Y LOCATIONS OF POINTS
C	ICOL	(I)	PLOTTING COLOR (0-255)
C	IERR	(I)	RETURNED IO ERROR FLAG
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	INTEGER IP(1)
C
C	ARRAYS FOR LINE WIDTH SIMULATION
C
	INTEGER MWP(7),MWX(44),MWY(44)
	DATA MWP/1,5,12,21,26,37,44/
	DATA MWX/0,-1,1,1,-1,-1,0,2,1,0,0,-1,0,-1,-1,-1,0,0,1,1,1,1,
     $   1,0,0,-1,-1,-1,-1,-1,-1,0,0,1,1,1,1,1,1,1,0,0,-1,-1/
	DATA MWY/0,0,1,-1,-1,0,2,0,0,-1,-1,0,-1,0,0,1,1,1,1,0,0,0,-1,
     $   -1,-1,-1,-1,0,0,1,1,1,1,1,1,0,0,0,-1,-1,-1,-1,-1,-1/
C
	IBNT=0
	IF (N.LE.0) RETURN
C
C	CONVERT A STRING OF VECTORS INTO INDIVIDUAL VECTORS
C
	IF (N.EQ.1) THEN
		IX1=IP(1)
		IY1=IP(2)
		LW=MWP(NT)
		DO 10 IW=1,LW
			IX1=IX1+MWX(IW)
			IY1=IY1+MWY(IW)
			IX2=IX1
			IY2=IY1
			CALL RAMOUT(9999,IX1,IY1,IX2,IY2,ICOL)
10		CONTINUE
		GOTO 200
	ENDIF
	DO 100 I=3,N*2,2
		IX1=IP(I-2)
		IY1=IP(I-1)
		IX2=IP(I)
		IY2=IP(I+1)
		LW=MWP(NT)
		DO 50 IW=1,LW
			IX1=IX1+MWX(IW)
			IY1=IY1+MWY(IW)
			IX2=IX2+MWX(IW)
			IY2=IY2+MWY(IW)
			CALL RAMOUT(9999,IX1,IY1,IX2,IY2,ICOL)
50		CONTINUE
100	CONTINUE
200	RETURN
	END
C
C
	SUBROUTINE RAMOUT(ICHAN,IX1,IY1,IX2,IY2,IC)
C
C	CONVERT A VECTOR PLOT INTO RASTER SCAN BYTE MAP
C
C 	NOTE: THIS RAMOUT IS NOT COMPATIBLE WITH THE
C	REAL RAMTEK VERSION
C
C	ICHAN	(I)	SHOULD BE 9999
C	IX1,IY1	(I)	START POINT OF LINE SEGMENT
C	IX2,IY2	(I)	START POINT OF LINE SEGMENT
C	IC	(I)	COLOR (0-255)
C
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	INTEGER DX,DY,X,Y,X1,Y1,X2,Y2,DIF,D,B(16)
	LOGICAL INV
C
C	CHECK TO SEE IF SOME ROUTINE OTHER THAN RMPLOT IS CALLING RAMOUT
C
	IF (ICHAN.LT.9999) THEN
		IX2=-1
		RETURN
	ENDIF
C
C	BIT MAP FOR LINE TYPE
C
	DO 75 I=1,16
		B(I)=IBITS(MT,I-1,1)
75	CONTINUE
	DX=IABS(IX1-IX2)
	DY=IABS(IY1-IY2)
	X1=IX1
	X2=IX2
	Y1=IY1
	Y2=IY2
	IF (X1.LT.0) X1=0
	IF (X2.LT.0) X2=0
	IF (Y1.LT.0) Y1=0
	IF (Y2.LT.0) Y2=0
	IF (X1.GE.IXWIDE) X1=IXWIDE-1
	IF (X2.GE.IXWIDE) X2=IXWIDE-1
	IF (Y1.GE.IYWIDE) Y1=IYWIDE-1
	IF (Y2.GE.IYWIDE) Y2=IYWIDE-1
	INV=.FALSE.
	IF (DX.LT.DY) THEN
		X1=IY1
		Y1=IX1
		X2=IY2
		Y2=IX2
		X=DY
		DY=DX
		DX=X
		INV=.TRUE.
	ENDIF
	IF (X2.LT.X1) THEN
		X=X1
		X1=X2
		X2=X
		Y=Y1
		Y1=Y2
		Y2=Y
	ENDIF
	DIF=1
	IF (Y2.LT.Y1) DIF=-1
	D=2*DY-DX
	I1=2*DY
	I2=2*(DY-DX)
	Y=Y1
	IYY=0
C
C	BYTE COLOR VALUE
C
	ICC=IC
	IF (ICC.GT.127) ICC=IC-256
C
	ISST=16*IST
	DO 10 X=X1,X2
		IBNT=IBNT+1
		IBT=MOD(IBNT/IST,16)+1
		IBNT=MOD(IBNT,ISST)
		IF (INV) THEN
			IF (B(IBT).NE.0) A((X+IYY)*IXWIDE+Y)=ICC
		ELSE
			IF (B(IBT).NE.0) A(X+(Y+IYY)*IXWIDE)=ICC
		ENDIF
		IF (D.LT.0) THEN
			D=D+I1
		ELSE
			D=D+I2
			Y=Y+DIF
		ENDIF
10	CONTINUE
	RETURN
	END
C
	SUBROUTINE RMTEXTURE(ICHAN,ITEXT,IWIDE,ISIZE,IERR)
C
C	CHANGE PLOT LINE TEXTURE AND SCALING
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	ITEXT	(I)	LINE TYPE (0-15)
C	IWIDE	(I)	LINE WIDTH (FOR RMPLOT)
C	ISIZE	(I)	PIXEL SCALING
C	IERR	(I)	STATUS ERROR
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
C	LINE TYPE BIT MAPS (16 BITS)
C
	INTEGER ILT(16)
	DATA ILT/-1,21845,13311,16191,8191,13119,16359,255,23485,
     $	 13107,7295,15567,22015,3855,24383,23485/
C
	IT=ITEXT+1
	IF (IT.LT.1) IT=1
	IF (IT.GT.16) IT=MOD(IT,16)+1
	MT=ILT(IT)
	NT=IWIDE
	IF (NT.LT.1) NT=1
	IF (NT.GT.7) NT=7
	IST=ISIZE
	IF (IST.LT.1) IST=1
	IF (IST.GT.16) IST=16
	RETURN
	END
C
	SUBROUTINE RMCLEAR(ICHAN,IERR)
C
C	CLEAR RAMTEK SCREEN
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	IERR	(I)	STATUS ERROR
C
C
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	DO 100 I=0,1310719
100		A(I)=0
	RETURN
	END
C
C
	SUBROUTINE RAMOUTIN(ICHAN,CMD,NC,BUF,NB,IRD)
C
C	READ/WRITE DATA FROM RAMTEK IN IMAGE MODE
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL NUMBER (=9999)
C	CMD	(B)	ARRAY OF BYTE DATA TO WRITE
C	NC	(I)	NUMBER OF BYTES
C	BUF	(I*2)	ARRAY OF INTEGER*2 DATA TO WRITE
C	NB	(I)	NUMBER OF WORDS
C	IRD	(I)	READ/WRITE CODE
C			 0=READ BYTES
C			 1=READ I*2 WORDS
C			 2=WRITE BYTES
C			 3=WRITE I*2 WORDS
C
C	OUTPUTS: (DEPENDS ON IRD)
C
C	BUF	(I*2)	RETURNED DATA INTEGER*2 WORDS
C	NB	(I)	NUMBER OF WORDS TO READ
C	CMD	(B)	RETURNED DATA BYTES
C	NC	(I)	NUMBER OF BYTES TO READ
C
	BYTE CMD(1)
	INTEGER*2 BUF(1)
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	INTEGER*2 IJ
	BYTE IIB
	EQUIVALENCE (IJ,IIB)
C
	IF (ICHAN.NE.9999) RETURN
	IF (IRD.EQ.0.AND.NC.LE.0) RETURN
	IF (IRD.EQ.1.AND.NB.LE.0) RETURN
	IF (IRD.EQ.2.AND.NC.LE.0) RETURN
	IF (IRD.EQ.3.AND.NB.LE.0) RETURN
C
	IX=1
	IY=0
	JX=0
	JY=1
	GOTO (10,11,12,13,14,15,16,17) IS+1
10	GOTO 20					! "NORMAL" L-R,T-B
11	IX=-1					! R-L, T-B
	GOTO 20
12	JY=-1					! L-R, B-T
	GOTO 20
13	IX=-1					! R-L, B-T
	IY=-1
	GOTO 20
14	IX=0					! T-B, L-R
	IY=1
	JX=1
	JY=0
	GOTO 20
15	IX=0					! B-T, L-R
	IY=-1
	JX=1
	JY=0
	GOTO 20
16	IX=0					! T-B, R-L
	IY=1
	JX=-1
	JY=0
	GOTO 20
17	IX=0					! B-T, R-L
	IY=-1
	JX=-1
	JY=0
	GOTO 20
C
20	CONTINUE
	NBB=NC
	IF (IRD.EQ.1.OR.IRD.EQ.3) NBB=NB
	DO 100 IB=1,NBB
		INDEX=LY
		INDEX=LX+INDEX*IXWIDE
		GOTO (50,51,52,53) IRD+1
		GOTO 60
50		CMD(IB)=A(INDEX)
		GOTO 60
51		BUF(IB)=A(INDEX).AND.255	! BIT-WISE AND OF BYTE VARIABLES
		GOTO 60
52		A(INDEX)=CMD(IB)
		GOTO 60
53		IJ=BUF(IB)			! PUT I*2 VALUE INTO BYTE
		A(INDEX)=IIB
		GOTO 60
60		LX=LX+IX
		LY=LY+IY
65		IF (LX.LT.XL(1)) THEN
			LX=XL(2)
			LY=LY+JY
		ENDIF
		IF (LX.GT.XL(2)) THEN
			LX=XL(1)
			LY=LY+JY
		ENDIF
		IF (LY.LT.YL(1)) THEN
			LY=YL(2)
			LX=LX+JX
			GOTO 65
		ENDIF
		IF (LY.GT.YL(2)) THEN
			LY=YL(1)
			LX=LX+JX
			GOTO 65
		ENDIF
100	CONTINUE
C
	RETURN
	END
C
	SUBROUTINE RMREADCURSOR(ICHAN,IDEV,IX,IY,ITRK,IVIS,IENT,IERR)
	IERR=-1
	RETURN
	END
C
	SUBROUTINE RMREADCOL(ICHAN,IS,N,IERR)
	RETURN
	END
C
	SUBROUTINE RMWRITECOL()
	RETURN
	END
C
	SUBROUTINE RMREADBYTE(ICHAN,IS,N,IERR)
C
C	READ DATA BYTE FROM RAMTEK IMAGE MODE
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL (IGNORED)
C	N	(I)	NUMBER OF BYTES TO READ OF IMAGE
C
C	OUTPUTS:
C
C	IS	(B)	ARRAY OF IMAGE DATA
C	IERR	(I)	STATUS ERROR
C
	BYTE IS(1)
	CALL RAMOUTIN(9999,IS,N,IERR,0,0)
	RETURN
	END
C
	SUBROUTINE RMREADWORD(ICHAN,IS,N,IERR)
C
C	READ INTEGER*2 WORD FROM RAMTEK IMAGE MODE
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL (IGNORED)
C	N	(I)	NUMBER OF WORDS TO READ
C
C	OUTPUTS:
C
C	IS	(I*2)	ARRAY OF IMAGE DATA
C	IERR	(I)	STATUS ERROR
C
	INTEGER*2 IS(1)
	CALL RAMOUTIN(9999,IERR,0,IS,N,1)
	RETURN
	END
C
	SUBROUTINE RMWRITEBYTE(ICHAN,IS,N,IERR)
C
C	WRITE BYTE DATA TO RAMTEK IN IMAGE MODE
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	IS	(B)	ARRAY OF IMAGE DATA
C	N	(I)	NUMBER OF BYTES TO WRITE
C
C	OUTPUTS:
C
C	IERR	(I)	STATUS ERROR
C
	BYTE IS(1)
	CALL RAMOUTIN(9999,IS,N,IE,0,2)
	RETURN
	END
C
	SUBROUTINE RMWRITEWORD(ICHAN,IS,N,IERR)
C
C	WRITE INTEGER*2 WORDS TO RAMTEK IN IMAGE MODE
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	IS	(I*2)	ARRAY OF IMAGE DATA
C	N	(I)	NUMBER OF WORDS TO READ
C
C	OUTPUTS:
C
C	IERR	(I)	STATUS ERROR
C
	INTEGER*2 IS(1)
	CALL RAMOUTIN(9999,IERR,0,IS,N,3)
	RETURN
	END
C
	SUBROUTINE RMSTART(ICHAN,IX,IY,IERR)
C
C	SET START OF IMAGE WRITE (COP) LOCATION TO (IX,IY)
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	IX,IY	(I)	PIXEL LOCATION
C
C	OUTPUTS:
C
C	IERR	(I)	STATUS ERROR (IGNORED)
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	LX=IX
	IF (LX.LT.XL(1)) LX=XL(1)
	IF (LX.GT.XL(2)) LX=XL(2)
	LY=IY
	IF (LY.LT.YL(1)) LY=YL(1)
	IF (LY.GT.YL(2)) LY=YL(2)
C
	RETURN
	END
C
	SUBROUTINE RMWIND(ICHAN,IX,IY,IXM,IYM,IERR)
C
C	SET IMAGE MODE WINDOW ON RAMTEK
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	IX,IY	(I)	UPPER-LEFT (MINIMUM) CORNER
C	IXM,IYM	(I)	LOWER-RIGHT (MAXIMUM) CORNER
C
C	OUTPUTS:
C
C	IERR	(I)	STATUS ERROR (IGNORED)
C
C	NOTE: MINIMUM WINDOW SIZE ALLOWED IS 2X2 PIXELS
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	XL(1)=IX
	IF (XL(1).LT.0) XL(1)=0
	IF (XL(1).GT.IXWIDE) XL(1)=IXWIDE
	YL(1)=IY
	IF (YL(1).LT.0) YL(1)=0
	IF (YL(1).GT.IYWIDE) YL(1)=IYWIDE
	XL(2)=IXM
	IF (XL(2).LT.0) XL(2)=0
	IF (XL(2).GT.IXWIDE) XL(2)=IXWIDE
	YL(2)=IYM
	IF (YL(2).LT.0) YL(2)=0
	IF (YL(2).GT.IYWIDE) YL(2)=IYWIDE
	IF (XL(2).LE.XL(1)) XL(2)=XL(1)+1
	IF (YL(2).LE.YL(1)) YL(2)=YL(1)+1
	LX=XL(1)
	LY=YL(1)
C
	RETURN
	END
C
	SUBROUTINE RMDIR(ICHAN,ISEQ,IERR)
C
C	SET SCAN SEQUENCE FOR IMAGE WRITING ON RAMTEK
C
C	INPUTS:
C
C	ICHAN	(I)	CHANNEL
C	ISEQ	(I)	SCAN CODE
C		    PIX-TO-PIX  LINE-TO-LINE
C	ISEQ	0	L-R	   T-B
C		1	R-L	   T-B
C		2	L-R	   B-T
C		3	R-L	   B-T
C		4	T-B	   L-R
C		5	B-T	   L-R
C		6	T-B	   R-L
C		7	B-T	   R-L
C
C	OUTPUTS:
C
C	IERR	(I)	STATUS ERROR
C
	BYTE A(0:1310720)		! RAMTEK EMULATION BYTE ARRAY
	COMMON /RAMTEKIO/IOTYPE,MT,NT,IST,IXWIDE,IYWIDE,
     $		LX,LY,XL(2),YL(2),IS,IBNT,A
C
	IF (ISEQ.GE.0.AND.ISEQ.LT.8) THEN
		IS=ISEQ
	ELSE
		IERR=-1
	ENDIF
C
	RETURN
	END
C
	SUBROUTINE RMZOOM()
	RETURN
	END
C
	SUBROUTINE RMPAN()
	RETURN
	END
C
	SUBROUTINE RMSETCUR()
	RETURN
	END
C
	SUBROUTINE RMTEXT()
	RETURN
	END
C
	SUBROUTINE RMFNTSIZE()
	RETURN
	END
C
	SUBROUTINE RMRESET()
	RETURN
	END
C
C
	SUBROUTINE RTERM(IX)
C
C	REPLACEMENT FOR RTERM ROUTINE FOR THE REF PACKAGE
C	WRITTEN: DGL 8/18/87
C
C IX	CONTROL FLAG
C	= 0 CLEAR RAMTEK SCREEN
C	= 2 ASK IF RAMTEK SCREEN CLEAR
C	=-2 CLEAR RAMTEK SCREEN
C	=-4 CLEAR RAMTEK SCREEN
C	= 3 CLOSE RAMTEK CHANNEL
C	=-3 REOPEN CLOSED RAMTEK CHANNEL
C
	COMMON/RMTEK/ICHAN,IMR(128),RRE(2),ROX,ROY,RSF,NIMR,RANG,MM,IPW,
     $		IPSC,ICOL,RVP(4),IRID,RLIM(2),IRXLIM,IRYLIM,IDDEV
C
	CHARACTER*1 ANS
C
	IF (ICHAN.EQ.-99.AND.IX.EQ.2) GOTO 80
	IF (ICHAN.EQ.-99.AND.IX.EQ.-3) GOTO 80
	IF (ICHAN.LE.0) RETURN
	IF (IABS(IX).GT.4) RETURN
	GOTO (10,15,10,15,10,15,20,30,15),IX+5
10	CONTINUE			! CLEAR RAMTEK SCREEN
	CALL RAMCLOSE(ICHAN)
15	RETURN
20	WRITE(*,5)			! ASK IF SCREEN CLEAR
5	FORMAT('$Call REF Output Routine? (y/n) [y] ')
	READ(*,6) ANS
6	FORMAT(A1)
	IANS=ICHAR(ANS)
	IF (IANS.GE.96) IANS=IANS-32
	IF (IANS.EQ.89.OR.IANS.EQ.32) THEN
		GOTO 10
	ELSE
		IF (IANS.EQ.81) GOTO 30 ! TEMP. CLOSE CHANNEL
		IF (IANS.EQ.83) THEN
			ICHAN=-99  		! SKIP PLOT MODE
		ENDIF
	ENDIF
	RETURN
30	CONTINUE				! TEMP. CLOSE CHANNEL
	ICHAN=-99
	RETURN
80	CONTINUE
	RETURN
	END