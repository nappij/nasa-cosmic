$ ! COMPILES AND LINKS METAFILE CONVERSION PROGRAMS
$ ! *** LAST REVISED ON 16-MAR-1988 08:25:04.79
$ ! *** SOURCE FILE: [DL.GRAPHICS.LONGLIB]METAFILE.COM
$ WRITE SYS$OUTPUT "Compiling and Linking Metafile Conversion Programs"
$ FORTRAN/NOLIST PRNTRX		! PRINTRONICS
$ LINK PRNTRX
$ DELETE PRNTRX.OBJ;
$ FORTRAN/NOLIST TRILGLO	! LO RES TRILOG
$ LINK TRILGLO
$ DELETE TRILGLO.OBJ;
$ FORTRAN/NOLIST TRILGHI	! HI RES TRILOG
$ LINK TRILGHI
$ DELETE TRILGHI.OBJ;
$ FORTRAN/NOLIST LASER		! QMS LASER PRINTER (LASER)
$ LINK LASER
$ DELETE LASER.OBJ;
$ FORTRAN/NOLIST LASERS		! QMS LASER PRINTER (LASERS)
$ LINK LASERS
$ DELETE LASERS.OBJ;
$ FORTRAN/NOLIST RLASER		! QMS LASER PRINTER (RLASER)
$ LINK RLASER
$ DELETE RLASER.OBJ;
$ FORTRAN/NOLIST HPGL		! HPGL PLOTTER (HPGL)
$ LINK HPGL
$ DELETE HPGL.OBJ;
$ FORTRAN/NOLIST HPGL2		! HPGL PLOTTER (HPGL2)
$ LINK HPGL2
$ DELETE HPGL2.OBJ;
$ FORTRAN/NOLIST HPGLS		! HPGL PLOTTER (HPGLS)
$ LINK HPGLS
$ DELETE HPGLS.OBJ;
$ FORTRAN/NOLIST POSTSCRIPT	! POSTSCRIPT
$ LINK POSTSCRIPT
$ DELETE POSTSCRIPT.OBJ;
$ WRITE SYS$OUTPUT "Finished Linking Metafile Conversion Programs"
