$ IF F$MODE() .EQS. "BATCH" THEN SET PROCESS/NAME= "A New INCA"
$ SET DEF [QPLOT.INCA.SOURCE]
$ @PAS EDIT       INCAWORK
$ @PAS MISC       INCAWORK
$ @PAS PLOT       INCAWORK
$ @PAS LOCUS      INCAWORK
$ @PAS FREQR      INCAWORK
$ @PAS DESCF      INCAWORK
$ @PAS TIMER      INCAWORK
$ @PAS MAIN       INCAWORK
$ !
$ @LINK
$ PURGE
