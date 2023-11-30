*CMZ :          25/08/94  14.27.22  by  S.Ravndal
*CMZ :  3.21/02 29/03/94  15.41.35  by  S.Giani
*-- Author :
      SUBROUTINE GUOUT
C
C User routine called at the end of each event
C
*KEEP,GCFLAG.
      COMMON/GCFLAG/IDEBUG,IDEMIN,IDEMAX,ITEST,IDRUN,IDEVT,IEORUN
     +        ,IEOTRI,IEVENT,ISWIT(10),IFINIT(20),NEVENT,NRNDM(2)
      COMMON/GCFLAX/BATCH, NOLOG
      LOGICAL BATCH, NOLOG
C
      INTEGER       IDEBUG,IDEMIN,IDEMAX,ITEST,IDRUN,IDEVT,IEORUN
     +        ,IEOTRI,IEVENT,ISWIT,IFINIT,NEVENT,NRNDM
C
*KEEP,GCSCAN.
      INTEGER MSLIST,NPHI,IPHIMI,IPHIMA,IPHI1,IPHIL,NTETA,MODTET,NSLMAX,
     +        MAXMDT,NSLIST,ISLIST,IPHI,ITETA,ISCUR
      REAL    PHIMIN,PHIMAX,TETMIN,TETMAX,VSCAN,FACTX0,FACTL,
     +        FACTR,SX0,SABS,TETMID,TETMAD
     +       ,SX0S,SX0T,SABSS,SABST,FACTSF
     +       ,DLTPHI,DLTETA,DPHIM1,DTETM1
     +       ,FCX0M1,FCLLM1,FCRRM1
      PARAMETER (MSLIST=32,MAXMDT=3)
      COMMON/GCSCAN/SCANFL,NPHI,PHIMIN,PHIMAX,NTETA,TETMIN,TETMAX,
     +              MODTET,IPHIMI,IPHIMA,IPHI1,IPHIL,NSLMAX,
     +              NSLIST,ISLIST(MSLIST),VSCAN(3),FACTX0,FACTL,
     +              FACTR,IPHI,ITETA,ISCUR,SX0,SABS,TETMID(MAXMDT),
     +              TETMAD(MAXMDT)
     +             ,SX0S,SX0T,SABSS,SABST,FACTSF
     +             ,DLTPHI,DLTETA,DPHIM1,DTETM1
     +             ,FCX0M1,FCLLM1,FCRRM1
      LOGICAL SCANFL
      COMMON/GCSCAC/SFIN,SFOUT
      CHARACTER*80 SFIN,SFOUT
*
*KEEP,PVOLUM.
      COMMON/PVOLUM/ NL,NR,IMAT,X0
*KEEP,CELOSS.
      COMMON/CELOSS/SEL1(40),SEL1C(40),SER1(40),SER1C(40),SNPAT1(40,4),
     *              SEL2(40),SEL2C(40),SER2(40),SER2C(40),SNPAT2(40,4),
     *              EINTOT,DEDL(40),DEDR(40),FNPAT(40,4)
*KEEP,EDEPO.
      PARAMETER ( NLX=200 , NPX=201 )
      COMMON/EDEPO/EDEP(NLX)
     +            ,SEDEP(NLX)
     +            ,SEDEP2(NLX)
     +            ,EFLO(NPX)
     +            ,SEFLO(NPX)
     +            ,SEFLO2(NPX)
     +            ,SIGDET,CUTDET
     +            ,SUMH,SUMH2,EKEV1(2),EKEV2(2),DIVST
      COMMON/GEOMAT/DZLG(NLX),IMATZ(NLX),ZCORS(NPX)
     +             ,NLAYZ,NPLAN
      COMMON/SPCUTS/SPGAM(NLX),SPELE(NLX),SPHAD(NLX)
*KEND.
C     *KEEP,GCTRAK.
      INTEGER NMEC,LMEC,NAMEC,NSTEP ,MAXNST,IGNEXT,INWVOL,ISTOP,MAXMEC
     + ,IGAUTO,IEKBIN,ILOSL, IMULL,INGOTO,NLDOWN,NLEVIN,NLVSAV,ISTORY
     + ,MAXME1,NAMEC1
      REAL  VECT,GETOT,GEKIN,VOUT,DESTEP,DESTEL,SAFETY,SLENG ,STEP
     + ,SNEXT,SFIELD,TOFG  ,GEKRAT,UPWGHT
      REAL POLAR
      PARAMETER (MAXMEC=30)
      COMMON/GCTRAK/VECT(7),GETOT,GEKIN,VOUT(7),NMEC,LMEC(MAXMEC)
     + ,NAMEC(MAXMEC),NSTEP ,MAXNST,DESTEP,DESTEL,SAFETY,SLENG
     + ,STEP  ,SNEXT ,SFIELD,TOFG  ,GEKRAT,UPWGHT,IGNEXT,INWVOL
     + ,ISTOP ,IGAUTO,IEKBIN, ILOSL, IMULL,INGOTO,NLDOWN,NLEVIN
     + ,NLVSAV,ISTORY
      PARAMETER (MAXME1=30)
      COMMON/GCTPOL/POLAR(3), NAMEC1(MAXME1)
     
c    KEEP,GCKINE.
      COMMON/GCKINE/IKINE,PKINE(10),ITRA,ISTAK,IVERT,IPART,ITRTYP
     +      ,NAPART(5),AMASS,CHARGE,TLIFE,VERT(3),PVERT(4),IPAOLD
C
      INTEGER       IKINE,ITRA,ISTAK,IVERT,IPART,ITRTYP,NAPART,IPAOLD
      REAL          PKINE,AMASS,CHARGE,TLIFE,VERT,PVERT
C

      COMMON/COUNT/NOPHO,INDI,ZAHL,INDI2,NPHVER,NUMVER,TEMPH,SEC,NELECT
     +             ,XOLD,YOLD,ZOLD,KOLD,TOFGOLD

      PARAMETER(WINDOW=100)

c      REAL TEMPH
      INTEGER TEMP
      LOGICAL LOGVAR
      SAVE NID1
      DATA NID1/0/
      DLC = 0.
      DRC = 0.
C
C Compute the longitudinal profile of the shower
C
      DO 10 I = 1,NL
          SEL1 (I) = SEL1 (I) + DEDL(I)
          SEL2 (I) = SEL2 (I) + DEDL(I)**2
C
C Compute the cummulative longitudinal profile of the shower
C
          DLC = DLC + DEDL(I)
          SEL1C(I) = SEL1C(I) + DLC
          SEL2C(I) = SEL2C(I) + DLC**2
   10 CONTINUE
C
C Compute the radial profile of the shower
C
      DO 20 I = 1,NR
          SER1 (I) = SER1 (I) + DEDR(I)
            SER2 (I) = SER2 (I) + DEDR(I)**2
C
C Compute the cummulative radial profile of the shower
C
            DRC = DRC + DEDR(I)
            SER1C(I) = SER1C(I) + DRC
            SER2C(I) = SER2C(I) + DRC**2
   20 CONTINUE
C
C Compute the particle flux
C
      DO 30 IPAT = 1,3
          DO 30 NPL = 1,NL
              SNPAT1(NPL,IPAT) = SNPAT1(NPL,IPAT) + FNPAT(NPL,IPAT)
              SNPAT2(NPL,IPAT) = SNPAT2(NPL,IPAT) + FNPAT(NPL,IPAT)**2
   30 CONTINUE
C
C Fill the total energy of the event in the histogram
C
      IF (EINTOT.NE.0.0) THEN
          ETOT = 100.*IEVENT*DLC/EINTOT
          CALL HF1( 1, ETOT,1.)
      END IF
C
      EVIS=0
C
      DO 100 I=1,90
C
          CALL HFILL(31,FLOAT(I),0.,EDEP(I))
          EVIS=EVIS+EDEP(I)
C
  100  CONTINUE
C
      CALL HFILL(32,EVIS,0.,1.)

c Una division de enteros da la condicion de impresion cada 100 eventos (windows) pues cuando IEVENT>9999999
c aparecen asteriscos por el formato de impresion.

      TEMP = (IEVENT)/WINDOW
c      write(*,*)'                 ',TEMP, WINDOW
      IF(TEMP*WINDOW.EQ.IEVENT)THEN
         WRITE(*,*)''
         WRITE(*,*)'                              EVENT       ',IEVENT
         WRITE(*,*)
         NUMVER = NUMVER + 1
      ENDIF

c       write(*,*)'out NOPHO=',NOPHO
c       write(*,*)'out ZAHL=',ZAHL
c       write(*,*)'out NEVENT=',NEVENT
c       write(*,*)'out IEVENT=',IEVENT
c       write(*,*)'out NUMVER=',NUMVER
c       write(*,*)'out TEMPH=',TEMPH
              
c       IF(IEVENT.EQ.NEVENT)THEN
c        IF(NUMVER.EQ.1)THEN
c          write(*,*)'out TEMPH1=',TEMPH
c          write(*,*)'out NUMVER=',NUMVER  
c          NPHVER=NOPHO
c          NUMVER=NUMVER+1
c          TEMPH=NOPHO
c          write(*,*)'11111111111111111111'
c          write(*,*)'out TEMPH1=',TEMPH
c          write(*,*)'out NUMVER=',NUMVER
c          write(*,*)'***************** NPHVER =',NPHVER
c          write(*,*)
c          WRITE(11,8),NUMVER-1, PKINE(5),NOPHO,NPHVER
c 8        FORMAT(' ',I5,3X,E12.6,3X,I5,3X,I5)
                                 
c        ELSE  
c          write(*,*)'out TEMPH2=',TEMPH
c          write(*,*)'out NUMVER=',NUMVER
c          NPHVER=NOPHO-TEMPH
c          NUMVER=NUMVER+1
c          TEMPH=NOPHO
c          write(*,*)'22222222222222222222'
c          write(*,*)'out NUMVER=',NUMVER
c          write(*,*)'out TEMPH2=',TEMPH
c          write(*,*)'***************** NPHVER =',NPHVER
c          write(*,*)
c          WRITE(11,9),NUMVER-1, PKINE(5),NOPHO,NPHVER
c 9        FORMAT(' ',I5,3X,E12.6,3X,I5,3X,I5)
            
c        ENDIF
    
          
c       ENDIF
       
       
C DEBUG      write(*,*)'TOTP SEC =',SEC
C DEBUG      write(*,*)'ZAHL =',ZAHL 
C DEBUG      write(*,*)'NELECT =',NELECT
C DEBUG      write(*,*)'NOPHO =',NOPHO
  
      END







