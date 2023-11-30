*CMZ :          29/08/94  14.34.57  by  S.Ravndal
*CMZ :  3.21/02 29/03/94  15.41.35  by  S.Giani
*-- Author :
      SUBROUTINE UFILES
*
*            To open FFREAD and HBOOK files
*
      CHARACTER*(*) FILNAM, FSTAT
      PARAMETER (FILNAM='exercise_1.dat')
*
      PARAMETER (FSTAT='OLD')
*
      OPEN(UNIT=4,FILE=FILNAM,STATUS=FSTAT,
     +     FORM='FORMATTED')
      OPEN(UNIT=10, FILE='phot.dat', STATUS='UNKNOWN')
      OPEN(UNIT=11, FILE='elec.dat', STATUS='UNKNOWN')
      END
