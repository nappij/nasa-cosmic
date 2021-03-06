$! ////// THIS IS THE FIRST LINE OF BIGTEST.COM
$!
$ SET VERIFY
$!
$!
$!
$!
$!               FILE NAME = BIGTEST.COM
$!
$! THIS PROCEDURE COMPILES THE QUIKVIS PROGRAM'S SOURCE FILES, LINKS
$! THE PROGRAM, AND EXECUTES TWO SAMPLE RUNS USING THE NEWLY CREATED
$! IMAGE.  THE OUTPUT OF THE RUNS IS COMPARED WITH CORRESPONDING
$! FILES PRESENT ON THE COSMIC SUBMITTAL TAPE.  THE COMPARISON IS DONE
$! TO VERIFY THAT THE SAME RESULTS ARE OBTAINED.
$!
$!
$ DIREC = "[NQCJP.COSMIC.TEST]"
$!
$ SET DEFAULT 'DIREC'
$!
$!
$! **** LIST THE COMMAND FILES INVOLVED.  IT MAKES READING OF THE
$!      DCL OUTPUT EASIER.
$!
$    TYPE BIGTEST.COM
$    TYPE MAKEOBJ.COM
$    TYPE QVLINK.COM
$    TYPE EXAMPLE1.COM
$    TYPE EXAMPLE2.COM
$!
$!
$! **** COMPILE ALL SOURCE ROUTINES ****
$!
$    SET NOVERIFY
$    WRITE SYS$OUTPUT " "
$    WRITE SYS$OUTPUT " STARTING MAKEOBJ.COM"
$    WRITE SYS$OUTPUT " "
$    @MAKEOBJ    'DIREC'  ! OBJECT IS PLACED IN THE QUIKVIS.OLB LIBRARY 
$    SET VERIFY
$!
$!
$! **** LINK THE PROGRAM ****
$!
$    SET NOVERIFY
$    @QVLINK     'DIREC'  ! IMAGE NAME IS QUIKVIS.LDM
$    SET VERIFY
$!
$!
$! ****  SAMPLE RUN NUMBER 1
$!
$    SET VERIFY
$    @EXAMPLE1 LDM
$    PRINT EX1.U19
$!
$!
$! ****  SAMPLE RUN NUMBER 2
$!
$    SET VERIFY
$    @EXAMPLE2 LDM
$    PRINT EX2.U19
$!
$! ////// THIS IS THE LAST LINE OF BIGTEST.COM
