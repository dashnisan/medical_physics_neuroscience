*CMZ :          30/08/94  16.03.40  by  S.Ravndal
*CMZ :  3.21/02 29/03/94  15.41.35  by  S.Giani
*-- Author :
      SUBROUTINE UGINIT
C
C To initialise GEANT/USER  program and read data cards
C
*KEEP,GCKINE.
      COMMON/GCKINE/IKINE,PKINE(10),ITRA,ISTAK,IVERT,IPART,ITRTYP
     +      ,NAPART(5),AMASS,CHARGE,TLIFE,VERT(3),PVERT(4),IPAOLD
C
      INTEGER       IKINE,ITRA,ISTAK,IVERT,IPART,ITRTYP,NAPART,IPAOLD
      REAL          PKINE,AMASS,CHARGE,TLIFE,VERT,PVERT
C
*KEEP,PVOLUM.
      COMMON/PVOLUM/ NL,NR,IMAT,X0
*KEEP,CELOSS.
      COMMON/CELOSS/SEL1(40),SEL1C(40),SER1(40),SER1C(40),SNPAT1(40,4),
     *              SEL2(40),SEL2C(40),SER2(40),SER2C(40),SNPAT2(40,4),
     *              EINTOT,DEDL(40),DEDR(40),FNPAT(40,4)
*KEND.
   
      COMMON/COUNT/NOPHO,INDI,ZAHL,INDI2,NPHVER,NUMVER,TEMPH,SEC,NELECT
     +             ,XOLD,YOLD,ZOLD,KOLD,TOFGOLD
      INTEGER NOPHO,INDI,ZAHL,INDI2,NPHVER,NUMVER,TEMPH,SEC,NELECT
      REAL    XOLD,YOLD,ZOLD,KOLD,TOFGOLD

      NOPHO=0
      ZAHL=0
      NUMVER=1
      NPHVER=0
      TEMPH=0
      SEC=0
      NELECT=0
      XOLD=0.
      YOLD=0.
      ZOLD=0.
      KOLD=0.
      TOFGOLD=0.
     
C
C Open user files
C
      CALL UFILES
C
C Initialise GEANT
C
      CALL GINIT
C
      EINTOT=0.
      CALL VZERO(SEL1,640)
C
C Define user FFREAD data cards (format free input)
C
      CALL FFKEY('BINS',NL,2,'INTEGER')
      CALL FFKEY('MATE',IMAT,1,'INTEGER')
      CALL FFSET('LINP',4)
C
C Read the data cards
C
      PKINE(4) = 12345.
      CALL GFFGO
C
C Initialise Zebra structure
C
      CALL GZINIT

C INITIALISES BASIC GRAPHICS PACAGE  AND HPLOT PACKAGE (DRAW 001-2)
C     CALL HPLOT (DOES NOT WORK WITH THIS)

C INITIALISES GEANT DRAWING PACKAGE
      CALL GDINIT

C      CALL GPHYSI   called in ugeom
C
C Geometry and materials description
C
      CALL UGEOM
C
C Print the defined materials, tracking media and volumes
C
      CALL GPRINT('MATE',0)
      CALL GPRINT('TMED',0)
      CALL GPRINT('VOLU',0)
C
C Define user histograms and n-tuple
C
      CALL UHINIT
C
      END










