//ZP60012  JOB (SYSGEN),'J07 M26: ZP60012',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             REGION=4096K
/*JOBPARM LINES=100
//JOBCAT   DD  DSN=SYS1.VSAM.MASTER.CATALOG,DISP=SHR
//*
//*  ZAP TO REPORT INTERRUPT CODE OF ABEND IN A TSO SESSION.
//*
//RECEIVE EXEC SMPREC,WORK='SYSALLDA'
//SMPPTFIN DD  *
++USERMOD(ZP60012)      /* REPORT PIC FOR S0CX OR SODX ABEND */  .
++VER(Z038) FMID(EBB1102) PRE(UZ83396,UY02947)
 /*
   PROBLEM DESCRIPTION:
     THE CONTENTS OF GPR15 IS REPORTED AS THE REASON CODE.
       IN THE ABSENCE OF A "REASON" PARAMETER OF THE ABEND MACRO
       THE VALUE STORED IN GENERAL PURPOSE REGISTER 15 IS INSPECTED
       AND IF (LOGICALLY) LESS THAN 4096 IS THEN ARBITRARILY
       REPORTED AS THE REASON CODE OF THE ABEND.  THIS IS NOT
       APPROPRIATE FOR PROGRAM CHECK ABENDS WHERE IT CAN BE MORE
       USEFUL TO REPORT THE PROGRAM INTERRUPT CODE (PIC).

       THIS USERMOD CHANGES THE TSO TMP ESTAI EXIT ROUTINE IKJEFT04
       AND THE TSO TMP ESTAE EXIT ROUTINE IKJEFT05 SO THAT THE PIC
       IS REPORTED AS THE REASON CODE IN MESSAGE IKJ56641I.  AS A
       RESULT, THE DETERMINATION OF WHETHER THE PSW POINTS TO THE
       FAILING INSTRUCTION (AS FOR PIC10, PIC11 AND PIC12) OR THE
       NEXT INSTRUCTION WILL BE EASIER TO MAKE.

   SPECIAL CONDITIONS:
     ACTION:
       A "CLPA" MUST BE PERFORMED AT IPL TIME FOR THIS SYSMOD TO
       BECOME ACTIVE.

   COMMENTS:
     PRYCROFT SIX P/L PUBLIC DOMAIN USERMOD FOR MVS 3.8 NO. 12.

     A TYPICAL USAGE SCENARIO MIGHT CONSIST OF THE FOLLOWING STEPS:
     1) A PROGRAM OR COMMAND ABENDS RESULTING IN:
           IKJ56641I PGM-NAME ENDED DUE TO ERROR+
           READY
     2) THE USER ENTERS A QUESTION MARK RESULTING IN:
           IKJ56641I SYSTEM ABEND CODE 0C4   REASON CODE 011
           READY
     3) THE USER INITIATES THE TEST COMMAND TO COMMENCE DEBUGGING
        KNOWING THAT THE CURRENT LOCATION CONTAINS THE INSTRUCTION
        CAUSING THE PROGRAM CHECK.

     THE FOLLOWING MODULES AND/OR MACROS ARE AFFECTED BY THIS USERMOD:
     MODULES:
       IKJEFT04
       IKJEFT05
 */.
++ZAP(IKJEFT04) DISTLIB(AOST4).
 NAME IKJEFT04
 IDRDATA ZP60012
VER 0190 58E0,D004           L     R14,SAVRBAK
VER 0194 D503,E014,B94C      CLC   REG0,=F'12'    SDWA PROVIDED?
VER 019A 4780,B1EC           BE    L1             NO
VER 019E 58E0,E018           L     R14,REG1       SDWA ADDRESS
VER 01A2 D503,E054,B980 L5   CLC   SDWAGR15,=F'4095'
VER 01A8 47D0,B1B6           BNH   L2
VER 01AC 1FEE           L4   SLR   R14,R14        NO REASON CODE
VER 01AE 50E0,A01C      L6   ST    R14,SUBCDRS
VER 01B2 47F0,B1F2           B     L3
VER 01B6 58E0,D004      L2   L     R14,SAVRBAK
VER 01BA 58E0,E018           L     R14,REG1       SDWA ADDRESS
VER 01BE 58E0,E054           L     R14,SDWAGR15
VER 01C2 50E0,A01C           ST    R14,SUBCDRS
VER 08C4 B8C4,B8C6      PA   DC    2S(*)
VER 08C8 B8C8,B8CA           DC    2S(*)
VER 08CC B8CC,B8CE           DC    2S(*)
VER 08D0 B8D0,B8D2           DC    2S(*)
VER 08D4 B8D4,B8D6           DC    2S(*)
VER 08D8 B8D8,B8DA           DC    2S(*)
VER 08DC B8DC,B8DE           DC    2S(*)
REP 019E 47F0,B8C4           B     PA
REP 08C4 58E0,E018           L     R14,REG1       SDWA ADDRESS
REP 08C8 950C,E005           CLI   SDWACMPC,X'0C'
REP 08CC 4740,B1A2           BL    L5             NOT PROGRAM CHECK
REP 08D0 950D,E005           CLI   SDWACMPC,X'0D'
REP 08D4 4720,B1A2           BH    L5             NOT PROGRAM CHECK
REP 08D8 48E0,E00A           LH    R14,SDWAINTA   GET INTERRUPT CODE
REP 08DC 47F0,B1AE           B     L6             GO USE IT AS REASON
++ZAP(IKJEFT05) DISTLIB(AOST4).
 NAME IKJEFT05
 IDRDATA ZP60012
VER 0032 05B0                BALR  R11,0          BASE REGISTERS 1
VER 0034 4140,BFFF           LA    R4,4095(,R11)             AND 2
VER 00F2 D503,3054,42ED      CLC   SDWAGR15,=F'4095'
VER 00F8 47D0,B0D2           BNH   LBL1
VER 00FC 1F77                SLR   R7,R7          NO REASON CODE
VER 00FE 5070,A01C           ST    R7,SUBCDRS
VER 0102 47F0,B0E6           B     LBL2
VER 0106 5830,8008   LBL1    L     R3,8(,R8)
VER 010A 5870,304C           L     R7,76(,R3)
VER 010E 5830,7018           L     R3,24(,R7)
VER 0112 5830,3054           L     R3,SDWAGR15
VER 0116 5030,A01C           ST    R3,SUBCDRS
VER 011A 5060,A00C   LBL2    ST    R6,ABNDCD
VER 011E 8960,0008           SLL   R6,8
VER 0122 8C60,0014   LBL3    SRDL  R6,20
VER 11F6 41C3,41C5   PATCH   DC    2S(*)
VER 11FA 41C7,41C9           DC    2S(*)
VER 11FE 41CB,41CD           DC    2S(*)
VER 1202 41CF,41D1           DC    2S(*)
VER 1206 41D3,41D5           DC    2S(*)
VER 120A 41D7,41D9           DC    2S(*)
VER 120E 41DB,41DD           DC    2S(*)
VER 1212 41DF,41E1           DC    2S(*)
REP 0112 5870,3054           L     R7,SDWAGR15    KEEP R3 AS
REP 0116 5070,A01C           ST    R7,SUBCDRS          SDWA ADDRESS
REP 011E 47F0,41C3           B     PATCH          OVERLAYS SLL
REP 11F6 8960,0008   PATCH   SLL   R6,8           DISPLACED BY BRANCH
REP 11FA 950C,3005           CLI   SDWACMPC,X'0C'
REP 11FE 4740,B0EE           BL    LBL3           NOT PROGRAM CHECK
REP 1202 950D,3005           CLI   SDWACMPC,X'0D'
REP 1206 4720,B0EE           BH    LBL3           NOT PROGRAM CHECK
REP 120A BF73,300A           ICM   R7,3,SDWAINTA  TOP HALF OF R7 IS 0
REP 120E 5070,A01C           ST    R7,SUBCDRS
REP 1212 47F0,B0EE           B     LBL3
/*
//SMPCNTL  DD  *
  RECEIVE
          SELECT(ZP60012)
          .
/*
//*
//APPLYCK EXEC SMPAPP,WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(ZP60012)
        CHECK
        .
/*
//*
//APPLY   EXEC SMPAPP,COND=(0,NE),WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(ZP60012)
        DIS(WRITE)
        .
/*
//
