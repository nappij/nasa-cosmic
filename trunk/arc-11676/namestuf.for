      SUBROUTINE INITC ( NAME )
C
C *** INITIALIZE AN ENTIRE COMMON BLOCK, OR ALL COMMON BLOCKS
C
**
*1 --- THE USER'S COMMON BLOCKS ARE PLACED HERE BY THE NAMEIO PROGRAM
      CHARACTER *(*) NAME
      DATA VALUE/0.0/
C
      IF (NAME .NE. ' ') THEN
         DO 10 I=1,NCOM
            IF (CNAMES(I) .EQ. NAME) THEN
               IS = I
               IE = I
               GO TO 20
            ENDIF
10          CONTINUE
         GO TO 1000
      ELSE
         IS = 1
         IE = NCOM
      ENDIF
C
C --- IS=FIRST COMMON TO ZERO, IE=LAST COMMON TO ZERO
C
20    DO 100 ICOM = IS,IE
         DO 90 J = 1,NUMVAR(ICOM)
*4 --- THE VALUE ASSIGNMENT DONE HERE BY CODE INSERTED BY THE NAMEIO PROGRAM
90          CONTINUE
100      CONTINUE
      RETURN
C
1000  CALL ERROR0('Common name '//NAME//' unknown to NAMEIO.')
      RETURN
      END
C
C---END INITC
C
      SUBROUTINE READC
      PARAMETER (MAXBUF=81,MAXTOK=40)
**
      COMMON / READC0 / CH, DONE, ICOM, IBPTR, BUFF, LBUFF, TOKEN, EOF
      CHARACTER *(MAXBUF) BUFF
      CHARACTER *(MAXTOK) TOKEN
      CHARACTER *1 CH
      LOGICAL DONE, EOF
C
      ICOM = 0
      DONE = .FALSE.
      EOF  = .FALSE.
5     READ(NIN,900,END=1000) BUFF
      LBUFF = LENGTH(BUFF)+1
      IF ( LBUFF .EQ. 1 ) GO TO 5
      IBPTR = 1
C
10    CALL GETC0
      IF ((CH .NE. ' ') .AND. (CH .NE. SIGNAL)) THEN
         CALL ERROR0('Invalid character before ' // SIGNAL // '.')
20       CALL GETC0
         IF (CH .NE. SIGNAL) GO TO 20
      ELSE
         IF (CH .EQ. ' ') GO TO 10
      ENDIF
C
30    CALL GETOK0
      CALL DOTOK0
      IF (.NOT. DONE) GO TO 30
      RETURN
1000  CALL ERROR0('Unexpected end of file.')
      RETURN
900   FORMAT(A)
      RETURN
      END
C
C---END READC
C
      SUBROUTINE GETOK0
C
C *** GET THE NEXT TOKEN FROM THE COMMON FILE
C
      PARAMETER (MAXBUF=81,MAXTOK=40)
**
      COMMON / READC0 / CH, DONE, ICOM, IBPTR, BUFF, LBUFF, TOKEN, EOF
      CHARACTER *(MAXBUF) BUFF
      CHARACTER *(MAXTOK) TOKEN
      CHARACTER *1 CH
      LOGICAL DONE, EOF
C
      TOKEN = ' '
      ITOKE = 1
10    IF (CH .NE. ' ') GO TO 20
      CALL GETC0
      GO TO 10
C
C --- CHECK TO SEE IF IT IS A NEW COMMON NAME OR AND END TOKEN
C
20    IF (CH .EQ. SIGNAL) THEN
         TOKEN(ITOKE:ITOKE) = SIGNAL
         ITOKE = ITOKE + 1
30       CALL GETC0
         IF (CH .EQ. ' ') GO TO 50
         TOKEN(ITOKE:ITOKE) = CH
         ITOKE = ITOKE + 1
         GO TO 30
      ELSE
C
C --- ASSIGNMENT TOKEN
C
         TOKEN(ITOKE:ITOKE) = CH
         ITOKE = ITOKE + 1
40       CALL GETC0
         IF (CH .EQ. ',') THEN
            CALL GETC0
            GO TO 50
         ELSE IF (CH .EQ. SIGNAL) THEN
            GO TO 50
         ENDIF
         TOKEN(ITOKE:ITOKE) = CH
         ITOKE = ITOKE + 1
         GO TO 40
      ENDIF
50    RETURN
      END
C
C---END GETOK0
C
      SUBROUTINE DOTOK0
C
C *** INTERPRET THIS TOKEN
C
      PARAMETER (MAXBUF=81,MAXTOK=40)
**
      COMMON / READC0 / CH, DONE, ICOM, IBPTR, BUFF, LBUFF, TOKEN, EOF
      CHARACTER *(MAXBUF) BUFF
      CHARACTER *(MAXTOK) TOKEN
      CHARACTER *1 CH
      LOGICAL DONE, EOF, INARR
      CHARACTER *(MAXTOK) NAME, VALUE
      CHARACTER *10 WORK
      SAVE INARR,J,ISUB
C
C --- IF WE ARE IN AN ARRAY INITIALIZATION, USE THE SAME NAME AS BEFORE,
C ---  BUT INCREMENT THE SUBSCRIPT POINTER
C
      IF ( INARR ) THEN
         ISUB = ISUB + 1
         I = INDEX(TOKEN,')')
         IF ( I .NE. 0 ) THEN
            INARR = .FALSE. 
            VALUE = TOKEN(1:I-1)
         ELSE
            VALUE = TOKEN
         ENDIF
         GO TO 50
      ENDIF
C
C --- NOT IN AN ARRAY, EITHER A NEW COMON NAME OR A VARIABLE ASSIGNMENT
C
      IF (TOKEN(1:1) .EQ. SIGNAL) THEN
         IF (TOKEN .EQ. SIGNAL//'END') THEN
            DONE = .TRUE.
         ELSE
C
C  -----  NEW COMMON NAME
C
            NAME = TOKEN(2:MAXTOK)
            DO 10 ICOM = 1, NCOM
               IF (CNAMES(ICOM) .EQ. NAME) GO TO 20
10             CONTINUE
            CALL ERROR0('Unknown common name '//NAME )
            ICOM = 0
20          RETURN
         ENDIF
      ELSE
C
C  ----  VARIABLE ASSIGNMENT
C
         I = INDEX(TOKEN,'=')
         IF (I .EQ. 0) THEN
            CALL ERROR0('Invalid value assignment.')
            RETURN
         ENDIF
C
C ----- CHECK FOR ARRAY
C
         K = INDEX(TOKEN,'(')
         IF (K .EQ. 0) THEN
            NAME = TOKEN(1:I-1)
            ISUB = 1
         ELSE
            IF ( K .GT. I ) THEN
C
C ------ INITIALIZING AN ARRAY
C
               NAME = TOKEN(1:I-1)
               INARR = .TRUE.
               ISUB = 1
               I = I + 1
            ELSE
C
C --------- INITIALIZING ONE ELEMENT OF ARRAY
C
               NAME = TOKEN(1:K-1)
               M    = INDEX(TOKEN,')')
               WORK = TOKEN(K+1:M-1)
               CALL RIGHT ( WORK )
               READ(WORK,900) ISUB
            ENDIF
         ENDIF
         DO 30 J = 1,NUMVAR(ICOM)
            IF (NAME .EQ. VNAMES(J,ICOM)) GO TO 40
30          CONTINUE
         CALL ERROR0('Variable '//NAME(1:LENGTH(NAME))//
     $   ' not in common.')
         RETURN
40       VALUE = TOKEN(I+1:MAXTOK)
50       CALL ASIGN0 ( J, VALUE, ISUB )
      ENDIF
      RETURN
900   FORMAT(I10)
      END
C
C---END DOTOK0
C
      SUBROUTINE GETC0
C
C *** GET THE NEXT CHARACTER FROM THE COMMON FILE, IGNORING LINE BREAKS
C ***  AND CHECKING FOR BLANK LINES AND COMMENTS
C
      PARAMETER (MAXBUF=81,MAXTOK=40)
**
      COMMON / READC0 / CH, DONE, ICOM, IBPTR, BUFF, LBUFF, TOKEN, EOF
      CHARACTER *(MAXBUF) BUFF
      CHARACTER *(MAXTOK) TOKEN
      CHARACTER *1 CH
      LOGICAL DONE, EOF
C
5     IF (IBPTR .GT. LBUFF) THEN
10       READ(NIN,900,END=1000) BUFF
         LBUFF = LENGTH(BUFF)+1
         IF (LBUFF .EQ. 1) GO TO 10
         IBPTR = 1
      ENDIF
      CH = BUFF(IBPTR:IBPTR)
      IBPTR = IBPTR + 1
C
C --- SKIP COMMENTS
C
      IF (CH .EQ. '!') THEN
         IBPTR = LBUFF+1
         GO TO 5
      ENDIF
      RETURN
C
C --- END OF FILE BEFORE '&END' IS FOUND
C
1000  IF ( EOF ) THEN
         CALL ERROR0('Unexpected end of file.')
         STOP
      ELSE
         CH = ' '
         EOF = .TRUE.
      ENDIF
      RETURN
900   FORMAT(A)
      END
C
C---END GETC0
C
      SUBROUTINE ERROR0 ( TEXT )
C
C *** PRINT ERROR MESSAGE
C
      PARAMETER (MAXBUF=81,MAXTOK=40)
**
      COMMON / READC0 / CH, DONE, ICOM, IBPTR, BUFF, LBUFF, TOKEN, EOF
      CHARACTER *(MAXBUF) BUFF
      CHARACTER *(MAXTOK) TOKEN
      CHARACTER *1 CH
      LOGICAL DONE, EOF
      CHARACTER *(*) TEXT
      WRITE(NOUT,900)TEXT
      RETURN
900   FORMAT(' *** NAMEIO Error, ',A)
      END
C
C---END ERROR0
C
      SUBROUTINE ASIGN0 ( J, VALUE, ISUB )
C
C *** ASSIGN THE VALUE 'VALUE' TO THE 'J'TH WORD OF THE 'ISUB'TH COMMON
C
      PARAMETER (MAXBUF=81,MAXTOK=40)
**
      COMMON / READC0 / CH, DONE, ICOM, IBPTR, BUFF, LBUFF, TOKEN, EOF
*1 --- THE USER'S COMMON BLOCKS ARE PLACED HERE BY THE NAMEIO PROGRAM
      CHARACTER *(MAXBUF) BUFF
      CHARACTER *(MAXTOK) TOKEN
      CHARACTER *1 CH
      LOGICAL DONE, EOF
      CHARACTER *(*) VALUE
      CHARACTER *20 VAL
      LOGICAL LV
      EQUIVALENCE (RV,IV,LV)
C
C --- CONVERT TO PROPER TYPE
C
      IF (VTYPES(J,ICOM) .EQ. 'R') THEN
         READ(VALUE,900,ERR=2000) RV
      ELSE IF (VTYPES(J,ICOM) .EQ. 'I') THEN
         VAL = VALUE
         CALL RIGHT(VAL)
         READ(VAL,910,ERR=2000) IV
      ELSE
         READ(VALUE,920,ERR=2000) LV
      ENDIF
*2 --- THE ASSIGNMENT CODE IS PLACED HERE BY THE NAMEIO PROGRAM
1000  RETURN
2000  CALL ERROR0('Illegal value for variable '//VNAMES(J,ICOM))
      RETURN
900   FORMAT(E20.5)
910   FORMAT(I20)
920   FORMAT(L20)
      END
C
C---END ASIGN0
C
      SUBROUTINE WRITEC ( NAME )
C
C *** WRITE AN ENTIRE COMMON BLOCK, OR ALL COMMON BLOCKS
C
**
*1 --- THE USER'S COMMON BLOCKS ARE PLACED HERE BY THE NAMEIO PROGRAM
      COMMON / WRITE0 / IP, BUFF
      CHARACTER *80 BUFF
      CHARACTER *(*) NAME
      CHARACTER *20 WORK
      EQUIVALENCE (VALUE,IVALUE,LVALUE)
C
      IP = 1
      BUFF = ' '
      IF (NAME .NE. ' ') THEN
         DO 10 I=1,NCOM
            IS = I
            IE = I
            IF (CNAMES(I) .EQ. NAME) GO TO 20
10          CONTINUE
         GO TO 1000
      ELSE
         IS = 1
         IE = NCOM
      ENDIF
C
C --- IS=FIRST COMMON TO PRINT, IE=LAST COMMON TO PRINT
C
20    DO 100 ICOM = IS,IE
         IF ((ICOM .NE. IS) .AND. (IP .NE. 1)) CALL FLUSH0
         CALL OUTP0(SIGNAL//CNAMES(ICOM))
         DO 90 J = 1,NUMVAR(ICOM)
            IF (J .NE. 1) CALL OUTP0(',')
            IF (IP .GT. 68) THEN
               CALL FLUSH0
               CALL OUTP0(VNAMES(J,ICOM))
            ELSE
               CALL OUTP0('  '//VNAMES(J,ICOM))
            ENDIF
            CALL OUTP0('=')
            IF (VSIZES(J,ICOM) .GT. 1) CALL OUTP0('(')
            DO 80 K=1,VSIZES(J,ICOM)
*3 --- THE VALUE EXTRACTION DONE HERE BY CODE INSERTED BY THE NAMEIO PROGRAM
40             IF (K .NE. 1) THEN
                  CALL OUTP0(',')
                  IF (IP .GT. 68) CALL FLUSH0
               ENDIF
               IF (VTYPES(J,ICOM) .EQ. 'R') THEN
                   WRITE(WORK,910) VALUE
               ELSE IF (VTYPES(J,ICOM) .EQ. 'I') THEN
                  WRITE(WORK,920) IVALUE
               ELSE
                  WRITE(WORK,930) LVALUE
               ENDIF
               CALL LEFT(WORK)
               CALL OUTP0('  '//WORK)
80             CONTINUE
            IF (VSIZES(J,ICOM) .GT. 1) CALL OUTP0(')')
90          CONTINUE
100      CONTINUE
C
C --- ALL DONE
C
      CALL OUTP0(' '//SIGNAL//'END')
      IF (IP .NE. 1) WRITE(NOUT,900) BUFF
      RETURN
1000  CALL ERROR0('Common name '//NAME//' unknown to NAMEIO.')
      RETURN
900   FORMAT(' ',A)
910   FORMAT(E20.8)
920   FORMAT(I20)
930   FORMAT(L20)
      END
C
C---END WRITEC
C
      SUBROUTINE OUTP0(TEXT)
C
C *** OUTPUT A TEXT STRING
C
**
      COMMON / WRITE0 / IP, BUFF
      CHARACTER *80 BUFF
      CHARACTER *(*) TEXT
C
      IT = LENGTH(TEXT)
      DO 10 I=1,IT
         BUFF(IP:IP) = TEXT(I:I)
         IP = IP + 1
         IF (IP .GT. 79) CALL FLUSH0
10       CONTINUE
      RETURN
      END
C
C---END OUTP0
C
      SUBROUTINE FLUSH0
C
C *** PRINT THE CURRENT LINE AND INTIIALIZE IT
C
**
      COMMON / WRITE0 / IP, BUFF
      CHARACTER *80 BUFF
      WRITE(NOUT,900)BUFF
      BUFF = ' '
      IP = 1
      RETURN
900   FORMAT(' ',A)
      END
C
C---END FLUSH0
C