$ SET NOVERIFY
$ ON WARNING THEN EXIT
$ ON ERROR THEN EXIT
$ IF P1 .NES. "" THEN GOTO POK
$NOP:
$ INQUIRE P1 "Filename"
$ IF P1 .EQS. "" THEN GOTO NOP
$POK:
$ ASSIGN 'P1' FOR001
$ ASSIGN TEMP.FRT FOR002
$ RUN MERLIN:FORTVMS
$ RENAME TEMP.FRT 'P1'
$ DEASSIGN/ALL
