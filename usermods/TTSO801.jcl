//TTSO801  JOB (SYSGEN),'J03 M13: TTSO801',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             REGION=4096K
/*JOBPARM LINES=100
//JOBCAT   DD  DSN=SYS1.VSAM.MASTER.CATALOG,DISP=SHR
//*
//* 2009/10/20 @kl TTSO801 eliminate msgikt012d after p tso
//*
//RECEIVE  EXEC SMPREC,WORK='SYSALLDA'
//SMPPTFIN   DD DATA,DLM='??'
++ USERMOD(TTSO801)     /* REWORK(20091020) */             .
++ VER (Z038)
   FMID(ETV0108)
 /*
  PROBLEM DESCRIPTION(S):
    TTSO801 -
      Eliminate msgIKT012D after P TSO.

  COMPONENT:  5752-SC1T9-ETV0108

  APARS FIXED: TTSO801

  SPECIAL CONDITIONS:
    ACTION:  TSO must be restarted after this user modification
      is installed.

  COMMENTS:
    LAST CHANGE:  2009/10/20

    REWORK HISTORY:
      2009/10/20: Allow msgIKT012D to be issued in the case of
                  HALT NET,CANCEL (previous logic resulted in
                  abend0C4 in IKTCAS41 with TCAS hung if HALT
                  NET,CANCEL issued).

    THE FOLLOWING MODULES AND/OR MACROS ARE AFFECTED BY THIS USERMOD:

    MODULES
      IKTCAS41

    NOTE:  This was fixed in ACF/VTAM V3 for MVS/370 HVT3204 by
      OY24140 (UY41051) and in ACF/VTAM V3 for MVS/XA HVT3205
      by OY24473 (UY41052)

    LISTEND
 */.
++ ZAP      (IKTCAS41) DISTLIB(AOST3   ).
 NAME IKTCAS41
 IDRDATA TTSO801
 EXPAND IKTCAS41(28)
VER 000004 10                        DC    AL1(16)             VERIFY LENGTH
VER 000005 C9D2E3C3C1E2F4F1          DC    C'IKTCAS41  78.045' VERIFY IDENTIFIER
VER 00000D 4040F7F84BF0F4F5
VER 000015 00
VER 000016 90EC,D00C        @PROLOG  STM   @14,@12,12(@13)
VER 00001A 05C0                      BALR  @12,0
VER 0001E6 9207,A009                 MVI   WERC2(@10),X'07'    SET FUNCTION
VER 0004D0 0000000000000000          DC    (PATCHLEN)X'00'     VERIFY PATCH AREA
VER 0004D8 0000000000000000
VER 0004E0 0000000000000000
VER 0004E8 00000000
REP 0001E6 45E0,C4B4                 BAL   @14,PATCH1          TO PATCH AREA
REP 0004D0 9504,4000        PATCH1   CLI   WECODE1T(@04),X'04' TEST HALT COMMAND
REP 0004D4 4770,C4CA                 BNE   PATCH1A             NOT HALT
REP 0004D8 9512,4001                 CLI   WECODE1F(@04),X'12' TEST FOR CANCEL
REP 0004DC 4770,C4CA                 BNE   PATCH1A             NOT HALT CANCEL
REP 0004E0 9207,A009                 MVI   WERC2(@10),X'07'    TERM WITH WTOR
REP 0004E4 07FE                      BR    @14                 RETURN TO MAIN
REP 0004E6 9206,A009        PATCH1A  MVI   WERC2(@10),X'06'    TERM WITHOUT WTOR
REP 0004EA 07FE                      BR    @14                 RETURN TO MAIN
??
/*
//*
//SMPCNTL  DD  *
  RECEIVE
          SELECT(TTSO801)
          .
/*
//*
//APPLYCK  EXEC SMPAPP,WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(TTSO801)
        BYPASS(ID)
        CHECK
        .
/*
//*
//APPLY    EXEC SMPAPP,COND=(0,NE),WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(TTSO801)
        DIS(WRITE)
        .
/*
//
