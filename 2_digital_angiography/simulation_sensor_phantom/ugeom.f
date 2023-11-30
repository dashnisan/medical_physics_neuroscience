*CMZ :          18/08/94  17.00.30  by  S.Ravndal
*CMZ :  3.21/02 29/03/94  15.41.35  by  S.Giani
*-- Author :
      SUBROUTINE UGEOM
C
C Define user geometry set up
C

*KEEP,GCBANK.
      INTEGER IQ,LQ,NZEBRA,IXSTOR,IXDIV,IXCONS,LMAIN,LR1,JCG
      INTEGER KWBANK,KWWORK,IWS
      REAL GVERSN,ZVERSN,FENDQ,WS,Q
C
      PARAMETER (KWBANK=69000,KWWORK=5200)
      COMMON/GCBANK/NZEBRA,GVERSN,ZVERSN,IXSTOR,IXDIV,IXCONS,FENDQ(16)
     +             ,LMAIN,LR1,WS(KWBANK)
      DIMENSION IQ(2),Q(2),LQ(8000),IWS(2)
      EQUIVALENCE (Q(1),IQ(1),LQ(9)),(LQ(1),LMAIN),(IWS(1),WS(1))
      EQUIVALENCE (JCG,JGSTAT)
      INTEGER       JDIGI ,JDRAW ,JHEAD ,JHITS ,JKINE ,JMATE ,JPART
     +      ,JROTM ,JRUNG ,JSET  ,JSTAK ,JGSTAT,JTMED ,JTRACK,JVERTX
     +      ,JVOLUM,JXYZ  ,JGPAR ,JGPAR2,JSKLT

      COMMON/GCLINK/JDIGI ,JDRAW ,JHEAD ,JHITS ,JKINE ,JMATE ,JPART
     +      ,JROTM ,JRUNG ,JSET  ,JSTAK ,JGSTAT,JTMED ,JTRACK,JVERTX
     +      ,JVOLUM,JXYZ  ,JGPAR ,JGPAR2,JSKLT

*KEEP, PVOLUM
      COMMON/PVOLUM/ NL, NR, IMAT, XO

*KEND.

      real AOX, ZOX, RLOX, BCP, DEOX 
      DIMENSION PAR(8)
      DIMENSION ZLG(6),ALG(6),WLG(6)
      DIMENSION A(3),Z(3),WMAT(3)
      
      dimension APLX(3), ZPLX(3), WPLX(3)
      
      dimension AI2(2), ZI2(2), WI2(2)

      dimension AW(2), ZW(2), WW(2)

      dimension AS(2), ZS(2), WSL(2)

      DIMENSION ACAN(3), ZCAN(3), WCAN(3)

c Parameters for new element oxygen are saved
      AOX = 15.99
      ZOX = 8
      RLOX = 30.0
      DEOX = 1.141
      BCP = 1
c BCP is the absorption length, obsolete parameter ignored by GEANT 
      

C Lead glass mixture parameters nucleus charge, atomic wheight, rel. wheight
C of the different compounds

      DATA ZLG/  82.00,  19.00,  14.00,  11.00,  8.00,  33.00/
      DATA ALG/ 207.19,  39.102,  28.088,  22.99, 15.999,  74.922/
      DATA WLG/ .65994, .00799, .126676, .0040073,.199281, .00200485/
C
C BGO compound parameters
C
      DATA A/208.98,72.59,15.999/
      DATA Z/83.,32.,8./
      DATA WMAT/4.,3.,12./
C
C PLEXIGLASS compound parameters
C
      DATA APLX/1.00794,12.0110,15.9994/
      DATA ZPLX/1.00,6.00,8.00/
      DATA WPLX/ 8., 5., 2./
c      data WPLX/0.08, 0.6, 0.32/
*      data WPLX/0.080541,0.599846,0.319613/


C WATER COMPOUND PARAMETERS
      DATA AW/1.00794,15.9994/
      DATA ZW/1.,8./
      DATA WW/2.,1./
c      data WW/0.112, 0.888/
*****************************************************************************************************************************************
C PARAMETROS DE LA SOLUCION YODADA   
      DATA AS/126.904, 18.015/
      DATA ZS/53., 10./
c Para concentracion de 370mgI/ml solucion: DENSIDAD=1.2949g/cm3. Cambiar valor en GSMIXT
*      DATA WSL/0.2857, 0.7143/
c Para concentracion de 185mgI/ml solucion: DENSIDAD=1.1475g/cm3 Cambiar valor en GSMIXT
      DATA WSL/0.1612, 0.8388/
c Para concentracion de  92mgI/ml solucion: DENSIDAD=1.0733g/cm3 Cambiar valor en GSMIXT
*      DATA WSL/0.08572, 0.9143/

*****************************************************************************************************************************************
      DATA ACAN/1.00794, 15.9994, 126.904/
      DATA ZCAN/1., 8., 53./
      DATA WCAN/0.0817, 0.6482, 0.2701/
*****************************************************************************************************************************************
 
C Definition of 16 default Geant materials, see manual CONS100-1
C
      CALL GIDROP
      CALL GMATE

C Define the default particles

      CALL GPART
      CALL GPIONS
      
     
C Defines USER particular materials
      CALL GSMATE(17,'OXYGEN', AOX, ZOX, DEOX, RLOX, BCP, 0.,0)
      CALL GSMATE(18,'SI',28.0855,14.,2.33,9.36,BCP,0.,0)
      CALL GSMATE(19,'IODINE',126.904,53.,4.930,1.72,BCP,0.,0)
      CALL GSMATE(20, 'VACUUM2',1.E-16,1.,1.E-16,1.E16,BCP,0.,0 )

      CALL GSMIXT(21,'BGO(COMPOUND)$',A,Z,7.1,-3,WMAT)
      CALL GSMIXT(22,'LEAD GLASS$',ALG,ZLG,5.2,6,WLG)
      
      CALL GSMIXT(23,'PLEXIGLASS$',APLX,ZPLX,1.18,-3,WPLX)
      CALL GSMIXT(24,'WATER', AW, ZW, 1.0, -2, WW) 
      CALL GSMIXT(25,'I-SOL',AS,ZS,1.1475,2,WSL)
      CALL GSMIXT(26, 'CAN',ACAN, ZCAN, 1.370,3,WCAN)




C
C Defines USER tracking media parameters which describes the tracking
C throughout a material
C

      FIELDM =  0.
      IFIELD =  0
      TMAXFD =  10.
      STEMAX =  1000.
      DEEMAX =  0.2
      EPSIL  =  0.0001
      STMIN  =  0.0001

   
        
     
C
C Define  tracking media, first consists of Air,  second of
C either BGO or Lead Glass, depending on the IMAT value.
C
      CALL GSTMED( 1,'DEFAULT MEDIUM AIR'    , 15 , 0 , IFIELD,
     +                FIELDM,TMAXFD,STEMAX,DEEMAX, EPSIL, STMIN, 0 , 0 )
      CALL GSTMED( 2,'ABSORBER'              ,IMAT, 0 , IFIELD,
     +                FIELDM,TMAXFD,STEMAX,DEEMAX, EPSIL, STMIN, 0 , 0 )

      CALL GSTMED( 4,'PLEXIGLASS', 23 , 0 , IFIELD, 
     +                FIELDM,TMAXFD,STEMAX, DEEMAX, EPSIL, STMIN, 0 , 0)
      CALL GSTMED( 5,'WATER', 24 , 0 , IFIELD, 
     +                FIELDM,TMAXFD,STEMAX, DEEMAX, EPSIL, STMIN, 0 , 0)
      CALL GSTMED( 6,'I-SOL', 25 , 0 , IFIELD, 
     +                FIELDM,TMAXFD,STEMAX, DEEMAX, EPSIL, STMIN, 0 , 0)
      CALL GSTMED( 7,'CAN', 26 , 0 , IFIELD, 
     +                FIELDM,TMAXFD,STEMAX, DEEMAX, EPSIL, STMIN, 0 , 0)
C
C All the default material defined via GMATE are also defined as
C tracking media, even if they are not needed right now.
C
      DO 100 IMT= 1,19
          CALL GSTMED( IMT+7,'DUMMY-MEDIUM'    , IMT , 0 , IFIELD,
     +                FIELDM,TMAXFD,STEMAX,DEEMAX, EPSIL, STMIN, 0 , 0 )
  100 CONTINUE
C
C Energy loss and cross-sections initialisations, creating LUT banks
C
      CALL GPHYSI



C DEFINICION DE LOS VOLUMENES

      PAR(1)=3.1265
      PAR(2)=2.5
      PAR(3)=2.
      CALL GSVOLU('MAMA' , 'BOX ' ,1, PAR, 3, IVOL)
      
      PAR(1)=0.5765
      PAR(2)=1.9955
      PAR(3)=0.015
      CALL GSVOLU('DETE','BOX ',25,PAR,0,IVOL)
      CALL GSPOSP('DETE',1,'MAMA',2.05,0.,0.,0,'ONLY',PAR,3)
      
      CALL GSVOLU('PIPE','TUBE',6,PAR,0,IVOL)
      CALL GSVOLU('IJAT' , 'BOX ' ,4, PAR, 0, IVOL)
      
      PAR(1)=0.
      PAR(2)=0.05
      PAR(3)=2.
      CALL GSPOSP('PIPE',1,'IJAT',0.,-1.46,0.,0,'ONLY',PAR,3)
      CALL GSPOSP('PIPE',2,'IJAT',0.,-0.44,0.,0,'ONLY',PAR,3)
      CALL GSPOSP('PIPE',3,'IJAT',0.,0.6,0.,0,'ONLY',PAR,3)
      CALL GSPOSP('PIPE',4,'IJAT',0.,1.62,0.,0,'ONLY',PAR,3)
    
      PAR(1)=0.5
      PAR(2)=2.5
      PAR(3)=2.
      CALL GSPOSP('IJAT'  , 1, 'MAMA ',0.9735,0.,0.,0, 'ONLY', PAR, 3)
          
      PAR(1)=0.5
      PAR(2)=2.5
      PAR(3)=2.
      CALL GSVOLU('HIJA' , 'BOX ' ,4, PAR, 0, IVOL)

      PAR(1)=0.5
      PAR(2)=1.805
      PAR(3)=2.
      CALL GSPOSP('HIJA', 1, 'MAMA ',-0.0265,-0.695,0.,0,'ONLY', PAR, 3)

      PAR(1)=0.1
      PAR(2)=1.805
      PAR(3)=2.
      CALL GSVOLU('IJAL' , 'BOX ' ,16, PAR, 0, IVOL)
      CALL GSPOSP('IJAL', 1, 'MAMA ',-0.6265,-0.695,0.,0,'ONLY', PAR, 3)

      PAR(1)=0.5
      PAR(2)=1.29
      PAR(3)=2.0
      CALL GSPOSP('HIJA',2,'MAMA ',-1.2265,-1.21,0.,0,'ONLY',PAR,3)

      PAR(1)=0.1
      PAR(2)=1.29
      PAR(3)=2.
      CALL GSPOSP('IJAL',2,'MAMA ',-1.8265,-1.21,0.,0,'ONLY',PAR,3)

      PAR(1)=0.5
      PAR(2)=0.765
      PAR(3)=2.
      CALL GSPOSP('HIJA',3,'MAMA ',-2.4265,-1.735,0.,0,'ONLY',PAR,3)

      PAR(1)=0.1
      PAR(2)=0.765
      PAR(3)=2.
      CALL GSPOSP('IJAL',3,'MAMA ',-3.0265,-1.735,0.,0,'ONLY',PAR,3)

C Close geometry banks. (obligatory system routine)
C
C
      CALL GGCLOS
C
      END















