$ !
$ ! *** LAST REVISED ON  1-APR-1985 13:31:21.19
$ ! *** SOURCE FILE: [LONG.GRAPHICS.LONGLIB]TCLEAR.COM
$ ! COMMAND FILE TO CLEAR SCREEN ON VT125
$ WRITE SYS$OUTPUT """0g[H[J[24B"
