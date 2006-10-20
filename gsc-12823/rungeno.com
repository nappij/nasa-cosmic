$ SET DEFAULT DISK$USER:[NBJH.GENOPTICS]
$ SET NOON
$ IF P1 .EQS. "" THEN INQUIRE P1 "ENTER INPUT FILE"
$ ASSIGN /USER DUMMY1 SYS$OUTPUT
$ DIR 'P1'.PLT
$ IF $STATUS THEN DELETE 'P1'.PLT;*
$ ASSIGN /USER DUMMY2 SYS$OUTPUT
$ DIR 'P1'.RAY
$ IF $STATUS THEN DELETE 'P1'.RAY;*
$ ASSIGN /USER DUMMY3 SYS$OUTPUT
$ DIR 'P1'.OUT
$ IF $STATUS THEN DELETE 'P1'.OUT;*
$ SET ON
$ WRITE SYS$OUTPUT "BEGIN GENOPTICS EXECUTION: INPUT FILE IS ''P1'.DAT"
$ WRITE SYS$OUTPUT " "
$ DEL DUMMY%.*;*
$ X :== 'F$LOGICAL("DATAIN")'
$ IF X .NES. "" THEN DEASSIGN DATAIN
$ X :== 'F$LOGICAL("FOR006")'
$ IF X .NES. "" THEN DEASSIGN FOR006
$ X :== 'F$LOGICAL("FOR010")'
$ IF X .NES. "" THEN DEASSIGN FOR010
$ X :== 'F$LOGICAL("FOR020")'
$ IF X .NES. "" THEN DEASSIGN FOR020
$ ASSIGN 'P1'.DAT DATAIN
$ ASSIGN 'P1'.OUT FOR006
$ ASSIGN 'P1'.PLT FOR010
$ ASSIGN 'P1'.RAY FOR020
$ R GENO
$ DEASSIGN DATAIN
$ DEASSIGN FOR006
$ DEASSIGN FOR010
$ DEASSIGN FOR020
$ WRITE SYS$OUTPUT " "
$ WRITE SYS$OUTPUT "FINISHED GENOPTICS EXECUTION..."
