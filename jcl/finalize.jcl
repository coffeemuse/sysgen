//*
//* JOBCARD REPLACED BY sysgen.py
//*
//*FINALIZE JOB (TSO),
//*             'Finalize MVSCE',
//*             CLASS=A,
//*             MSGCLASS=A,
//*             MSGLEVEL=(1,1),
//*             USER=IBMUSER,
//*             PASSWORD=SYS1
/*JOBPARM   LINES=100
//EDIT  EXEC PGM=IKJEFT01,REGION=1024K,DYNAMNBR=50
//SYSPRINT DD  SYSOUT=*
//SYSTSPRT DD  SYSOUT=*
//SYSTERM  DD  SYSOUT=*
//SYSTSIN  DD  *
EDIT 'SYS1.PARMLIB(COMMND00)' TEXT
FIND JES2
C * /JES2/JES2,,,PARM='WARM,NOREQ'/
LIST
INSERT COM='START NET'
SAVE
END
//* --------------------- Add shutdown JCL and scripts
//*
//*
//* SYS2.EXEC: CREATE SHUTDOWN (USED TO SHUTDOWN MVSCE)       
//*
//SHTDWNRX EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYS2.EXEC,DISP=MOD
//SYSIN    DD  DATA,DLM='><'
./ ADD NAME=SHUTFAST,LIST=ALL
/* REXX SCRIPT TO INITIATE C/OS SHUTDOWN */                       

CALL ANNOUNCE "WARNING! C/OS WILL BE SHUTTING DOWN IN 10 SECONDS"   
CALL WAIT(10000)   

CALL WTO("SHUT002 - BEGINING SHUTDOWN SEQUENCE")                    

ADDRESS COMMAND "CP SCRIPT SCRIPTS/SHUTDOWN.RC"                     

EXIT                                                                

ANNOUNCE:                                                           
  PARSE ARG WHAT_TO_SAY                                             
  CALL WTO("SHUT001 - "|| WHAT_TO_SAY)                              
  CALL CONSOLE("SEND 'SHUT001 - "||WHAT_TO_SAY||"'")                
  RETURN     
./ ADD NAME=SHUTDOWN,LIST=ALL
/* REXX SCRIPT TO INITIATE C/OS SHUTDOWN */                       

DO I = 5 TO 2 BY -1                                                 
 CALL ANNOUNCE "WARNING! C/OS WILL BE SHUTTING DOWN IN" I "MINUTES"
 CALL WAIT(60000)                                                    
END                                                                 

CALL ANNOUNCE "WARNING! C/OS WILL BE SHUTTING DOWN IN 1 MINUTE"   
CALL WAIT(60000)   

CALL WTO("SHUT002 - BEGINING SHUTDOWN SEQUENCE")                    

ADDRESS COMMAND "CP SCRIPT SCRIPTS/SHUTDOWN.RC"                     

EXIT                                                                

ANNOUNCE:                                                           
  PARSE ARG WHAT_TO_SAY                                             
  CALL WTO("SHUT001 - "|| WHAT_TO_SAY)                              
  CALL CONSOLE("SEND 'SHUT001 - "||WHAT_TO_SAY||"'")                
  RETURN                                                            
><
//*
//* SYS2.JCLLIB: CREATE SHUTDOWN (USED TO SHUTDOWN MVSCE)       
//*
//SHTDWNJC EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYS2.JCLLIB,DISP=MOD
//SYSIN    DD  DATA,DLM='><'
./ ADD NAME=SHUTDOWN,LIST=ALL
//SHUTDOWN JOB (JOB),'SHUTDOWN',CLASS=A,MSGCLASS=A
//SHUTDOWN EXEC SHUTDOWN
./ ADD NAME=SHUTFAST,LIST=ALL
//SHUTFAST JOB (JOB),'SHUTFAST',CLASS=A,MSGCLASS=A
//SHUTFAST EXEC SHUTDOWN,TYPE='SHUTFAST'
><
//*
//* SYS1.CMDPROC: CREATE SHUTDOWN (USED TO SHUTDOWN MVSCE)       
//*
//SHTDWNJC EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYS1.CMDPROC,DISP=MOD
//SYSIN    DD  DATA,DLM='><'
./ ADD NAME=SHUTDOWN,LIST=ALL
PROC 0                           
CONTROL NOFLUSH                  
  SUBMIT 'SYS2.JCLLIB(SHUTDOWN)' 
./ ADD NAME=SHUTFAST,LIST=ALL
PROC 0                           
CONTROL NOFLUSH                  
  SUBMIT 'SYS2.JCLLIB(SHUTFAST)'
><
//* --------------------- Add shutdown JCL and scripts
//* --------------------------------------------------
//* Coffee OS Customization
//*
//* First delete the previous version if it exists
//*
//CLEANUP EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
 DELETE SYS1.UMODMAC(COSNET)
 SET MAXCC=0
 SET LASTCC=0
//*
//* Then we "compress" SYS1.UMODMAC to free up space
//*
//COMP    EXEC COMPRESS,LIB='SYS1.UMODMAC'
//*
//* THEN WE COPY THE ORIGINAL NETSOL SOURCE FROM SYS1.AMACLIB
//* TO SYS1.UMODMAC
//*
//UMODMAC  EXEC PGM=IEBGENER
//SYSIN    DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=SHR,DSN=SYS1.AMACLIB(NETSOL)
//SYSUT2   DD DISP=SHR,DSN=SYS1.UMODMAC(NETSOL)
//*
//* THEN WE UPDATE SYS1.UMODMAC(NETSOL) TO DISPLAY OUR CUSTOM 3270
//*
//UPDATE   EXEC PGM=IEBUPDTE
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=SHR,DSN=SYS1.UMODMAC
//SYSUT2   DD DISP=SHR,DSN=SYS1.UMODMAC
//SYSIN    DD DATA,DLM=$$
./ ADD NAME=COSNET
* NETSOL screen created by ANSi2EBCDiC.py
         PUSH  PRINT
         PRINT OFF
EGMSG    DS 0C EGMSG
         $WCC  (RESETKBD,MDT)
         $SBA  (1,1)
* (1,1) Normal Display 
         DC    X'280000'
         DC    36C' '
         $SBA  (4,37)
* (4,37) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'__   ___    ____'
         $SBA  (5,1)
* (5,1) Normal Display 
         DC    X'280000'
         DC    27C' '
         $SBA  (5,28)
* (5,28) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'___'
         DC    5C' '
         DC    C'/ /  / _ \  / ___|'
         $SBA  (6,1)
* (6,1) Normal Display 
         DC    X'280000'
         DC    26C' '
         $SBA  (6,27)
* (6,27) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'/ __|   / /  | | | | \___ \'
         $SBA  (7,1)
* (7,1) Normal Display 
         DC    X'280000'
         DC    25C' '
         $SBA  (7,26)
* (7,26) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'| (__   / /   | |_| |  ___) |'
         $SBA  (7,55)
* (7,55) Normal Display 
         DC    X'280000'
         DC    26C' '
         $SBA  (8,27)
* (8,27) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'\___| /_/'
         DC    5C' '
         DC    C'\___/  |____/'
         $SBA  (9,1)
* (9,1) Normal Display 
         DC    X'280000'
         DC    32C' '
         $SBA  (10,33)
* (10,33) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'Coffee OS (c/OS)'
         $SBA  (10,49)
* (10,49) Normal Display 
         DC    X'280000'
         DC    33C' '
         $SBA  (11,34)
* (11,34) Bold/Intense (FG) Blue 
         DC    X'2841F82842F1'
         DC    C'Release 1.0.0'
         $SBA  (11,47)
* (11,47) Normal Display 
         DC    X'280000'
         $SBA  (23,1)
* (23,1) Bold/Intense 
         DC    X'2841F8'
         DC    C'==='
         DC    X'6E'
         $SBA  (23,5)
* (23,5) Normal Display 
         DC    X'280000'
* Insert Cursor and unprotected field
         $SBA  (23,5)
         DC    X'2842F2'  SA COLOR RED
         $SF   (UNPROT,HI)
         $IC
         DC    CL20' '
         DC    X'280000'
         DC    X'1DF8'     SF (PROT,HIGH INTENSITY)
         $SBA  (24,80)
         $SF   (SKIP,HI)
EGMSGLN EQU *-EGMSG
         POP   PRINT
./ CHANGE NAME=NETSOL
         CLI   MSGINDEX,X'0C'                                           23164802
         BNE   EGSKIP                                                   23164804
         LA    R3,EGMSGLN                                               23164808
         L     R4,=A(EGMSG)                                             23164810
*                                                                       23164812
         WRITE RPL=(PTRRPL),                                           X23164814
               OPTCD=(LBT,ERASE),                                      X23164816
               AREA=(R4),                                              X23164818
               RECLEN=(R3),                                            X23164820
               EXIT=WRITEND                                             23164822
*                                                                       23164824
         B EGOK                                                         23164826
*                                                                       23164828
*                                                                       23164830
EGSKIP   DS 0H EGSKIP                                                   23164832
EGOK     DS 0H EGOK                                                     23166010
         COPY COSNET                      , logon screen copy book      66810010
$$
//*
//* With that done its time to assemble our new screen
//* We assemble SYS1.UMODMAC(NETSOL) with IFOX00
//*
//ASM     EXEC PGM=IFOX00,REGION=1024K
//SYSLIB   DD  DISP=SHR,DSN=SYS1.UMODMAC,DCB=LRECL=32720
//         DD  DISP=SHR,DSN=SYS2.MACLIB
//         DD  DISP=SHR,DSN=SYS1.MACLIB
//         DD  DISP=SHR,DSN=SYS1.AMODGEN
//SYSUT1   DD  UNIT=VIO,SPACE=(1700,(600,100))
//SYSUT2   DD  UNIT=VIO,SPACE=(1700,(300,50))
//SYSUT3   DD  UNIT=VIO,SPACE=(1700,(300,50))
//SYSPRINT DD  SYSOUT=*,DCB=BLKSIZE=1089
//SYSPUNCH DD  DISP=(NEW,PASS,DELETE),
//             UNIT=VIO,SPACE=(TRK,(2,2)),
//             DCB=(BLKSIZE=80,LRECL=80,RECFM=F)
//SYSIN    DD  *
ISTNSC00 CSECT ,
         NETSOL SYSTEM=VS2
         END   ,
//*
//* Then we link it and put it in SYS1.VTAMLIB(ISTNSC00)
//*
//LKED    EXEC PGM=IEWL,PARM='XREF,LIST,LET,NCAL',REGION=1024K
//SYSPRINT DD  SYSOUT=*
//SYSLIN   DD  DISP=(OLD,DELETE,DELETE),DSN=*.ASM.SYSPUNCH
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.VTAMLIB(ISTNSC00)
//SYSUT1   DD  UNIT=VIO,SPACE=(1024,(200,20))
//* --------------------- Replaced NETSOL with COSNET
