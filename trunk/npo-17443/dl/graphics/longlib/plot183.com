$ ! raster scan conversion for printronix printer
$ ! *** LAST REVISED ON 10-SEP-1987 11:13:36.00
$ ! *** SOURCE FILE: [DL.GRAPHICS.LONGLIB]PLOT183.COM
$ NAME = "''P1'"
$ IF "''P1'" .EQS. "" THEN NAME = "FOR003.DAT"
$ FORNAM = "''F$SEARCH(NAME)'"
$ IF FORNAM .EQS. "" THEN GOTO ERROR
$ WRITE SYS$OUTPUT "USING FILE ''FORNAM'"
$ RAST := $LONGLOC:PRNTRX
$ RAST 'FORNAM				!RUN PRINTRONIXS RSC
$ PRINT OUT.LIS				!PRINT
$ EXIT
$ ERROR:
$   WRITE SYS$OUTPUT "ERROR LOCATING ''NAME' PLOT FILE"
$ EXIT
