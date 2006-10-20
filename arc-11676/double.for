      PROGRAM DOUBLE
C*
C* DISPLAY TWO FILES SIDE-BY-SIDE ON THE SCREEN
C*
C* WORKS ON VT100 COMPATIBLE TERMINALS WITH 132 COLUMN MODE.
C*
C* DISPLAYS THE FIRST 65 COLUMNS OF EACH FILE
C*
      CHARACTER *20 FILE1, FILE2
      CHARACTER *65 STRING1, STRING2
      LOGICAL END1, END2
C
      WRITE(6,*)' First file name -->'
      READ(5,900) FILE1
      OPEN(UNIT=1,STATUS='OLD',ERR=1000,FILE=FILE1)
      WRITE(6,*)' Second file name -->'
      READ(5,900) FILE2
      OPEN(UNIT=2,STATUS='OLD',ERR=2000,FILE=FILE2)
      END1 = .FALSE.
      END2 = .FALSE.
C
C ---- ERASE PAGE, PUT FILE LABELS
C
      ISTAT = LIB$ERASE_PAGE(1,1)
      WRITE(6,940)FILE1, FILE2
C
C --- REPEAT UNTIL END-OF-FILE ON BOTH FILES
C
10    IF (.NOT. END1) READ(1,910,END=20) STRING1
      GO TO 30
20    END1 = .TRUE.
      IF ( END2 ) GO TO 3000
      STRING1 = ' '
30    IF (.NOT. END2) READ(2,910,END=40) STRING2
      GO TO 50
40    END2 = .TRUE.
      IF ( END1 ) GO TO 3000
      STRING2 = ' '
50    WRITE(6,920) STRING1, STRING2
      GO TO 10
1000  WRITE(6,*) ' Unable to open file 1. '
      GO TO 3000
2000  WRITE(6,*) ' Unable to open file 2. '
3000  WRITE(6,*)' Hit <RETURN> to continue.'
      READ(5,950)
      STOP
900   FORMAT(A20)
910   FORMAT(A65)
920   FORMAT(' ',A65,2X,A65 )
940   FORMAT(12X,A20,47X,A20,/,12X,'--------------------',47X,
     $ '--------------------',/)
950   FORMAT(A1)
      END
