//ZP60034  JOB (SYSGEN),'J08 M45: ZP60034',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             REGION=4096K
/*JOBPARM LINES=100
//JOBCAT   DD  DSN=SYS1.VSAM.MASTER.CATALOG,DISP=SHR
//*
//*  RESOLVE &SYSUID, AND SUPPLY USER= AND PASSWORD= ON JOB STATEMENT.
//*
//STEP1   EXEC PGM=IEBGENER
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  *
++USERMOD(ZP60034)                  /* RESOLVE &SYSUID IN JCL */  .
++VER(Z038) FMID(EBB1102) SUP(ZJW0001)
 /*
   PROBLEM DESCRIPTION:
     THE &SYSUID SYSTEM SYMBOL IS NOT RESOLVED IN SUBMITTED JCL.
       THE &SYSUID SYSTEM SYMBOL CAN BE VERY USEFUL IN REDUCING
       THE CUSTOMIZATION THAT SHIPPED SAMPLE JCL REQUIRES BEFORE
       BEING SUBMITTED, BUT THIS IS NOT SUPPORTED BY MVS 3.8.
     JOBS SUBMITTED BY TSO USERS DO NOT INHERIT THE USER ID.
       USER= AND PASSWORD= MUST MANUALLY BE SUPPLIED BY A TSO USER
       SUBMITTING BATCH JOBS FOR THE JOBS TO RUN WITH THE USER'S
       SECURITY PROFILE, WHICH INCREASES THE RISK THAT THE SECRECY
       OF THE USER'S PASSWORD CAN BECOME COMPROMISED.

       THIS USERMOD SHIPS A VERSION OF THE IKJEFF10 EXIT FOR THE
       TSO SUBMIT COMMAND WHICH APPENDS THE USER AND PASSWORD
       PARAMETERS TO THE JOB JCL STATEMENT IF NOT ALREADY ADDED
       IN AN ENVIRONMENT WHERE A SECURITY PRODUCT IS ACTIVE.
       THIS EXIT HAS BEEN ENHANCED TO RESOLVE THE &SYSUID SYSTEM
       SYMBOL (WITH TRAILING PERIOD IF PRESENT) WHEN FOUND IN THE
       OPERANDS (MEANING NOT IN LABELS OR VERBS) OF THE FOLLOWING
       TYPES OF JCL STATEMENT:

         - JOB
         - DD
         - COMMENT
         - COMMAND

       THE FOLLOWING TYPES OF JCL STATEMENT ARE IGNORED BY THIS EXIT:
         - EXEC
         - JES2 JECL
         - NULL

       NOTE THAT &&SYSUID WILL BE LEFT UNALTERED.

       &SYSUID RESOLUTION DOES NOT REQUIRE AN ACTIVE SECURITY PRODUCT.

   SPECIAL CONDITIONS:
     NONE.

   COMMENTS:
     PRYCROFT SIX P/L PUBLIC DOMAIN USERMOD FOR MVS 3.8 NUMBER 34.

     THE FOLLOWING MODULES AND/OR MACROS ARE AFFECTED BY THIS USERMOD:
     MODULES:
       IKJEFF10
 */.
++MOD(IKJEFF10) DISTLIB(ACMDLIB).
/*
//SYSUT2   DD  DSN=&&SMPMCS,DISP=(NEW,PASS),UNIT=SYSALLDA,
//             SPACE=(CYL,3),
//             DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=4080)
//SYSIN    DD  DUMMY
//*
//STEP2   EXEC PGM=IFOX00,PARM='OBJECT,NODECK,NOTERM,XREF(SHORT),RENT'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT2   DD  UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT3   DD  UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//         DD  DSN=SYS1.SMPMTS,DISP=SHR
//         DD  DSN=SYS1.AMODGEN,DISP=SHR
//SYSGO    DD  DSN=&&SMPMCS,DISP=(MOD,PASS)
//SYSIN    DD  *
IKJEFF10 TITLE ' TSO SUBMIT EXIT FOR &&SYSUID, USER AND PASSWORD '
*
*  THIS VERSION OF THE IKJEFF10 EXIT FOR THE TSO SUBMIT COMMAND HAS
*  BEEN MODIFIED TO ALLOW THE JCL SYMBOL &SYSUID TO BE RESOLVED TO
*  THE ACTUAL USER ID OF THE SUBMITTER AT SUBMIT TIME.
*
*  THIS SUPPORT IS EXPECTED TO REDUCE - AND IN SOME CASES ELIMINATE -
*  THE MANUAL CUSTOMIZATION REQUIRED BY SAMPLE JCL BEFORE SUBMISSION.
*
*  WHILE THE MAIN INTEREST IS RESOLVING &SYSUID IN THE JOB NOTIFY
*  PARAMETER AND THE DD DSNAME PARAMETER, IT WILL BE RESOLVED ANYWHERE
*  IN JOB STATEMENT OPERANDS (SUCH AS THE ACCOUNT OR PROGRAMMER NAME),
*  IN DD STATEMENT OPERANDS (SUCH AS DCB), COMMANDS (GOOD PRACTICE
*  MEANS THESE ARE USUALLY DISABLED, BUT IF ALLOWED, THEN WHY NOT?),
*  AND JCL COMMENTS.  EXEC STATEMENTS ARE NOT PROCESSED BY THIS EXIT.
*
*  JCL STATEMENT LABELS AND VERBS ARE NOT SCANNED BY THIS EXIT.
*
*  USE A DOUBLE AMPERSAND TO PREVENT SUBSTITUTION.  THE DOUBLE
*  AMPERSAND WILL REMAIN UNCHANGED AND WILL NOT BE CONVERTED TO A
*  SINGLE AMPERSAND.
*
*  &SYSUID. (WITH A TRAILING PERIOD) WILL BE CHANGED TO THE SUBMITTER'S
*  USER ID - AS WILL &SYSUID (WITHOUT A TRAILING PERIOD) IF FOLLOWED
*  IMMEDIATELY BY A BLANK, COMMA, AMPERSAND, OR EITHER PARENTHESIS.
*
*  THE &SYSUID RESOLUTION WILL BE PERFORMED WHEN THE USER ID CAN BE
*  ASCERTAINED FROM THE RACF USER ID OR THE UADS USER ID EVEN IF NO
*  SECURITY PACKAGE SUCH AS RACF IS INSTALLED ON THE SYSTEM.
*
*  THIS EXIT'S ORIGINAL PROCESSING OF APPENDING USER AND PASSWORD
*  PARAMETERS ON TO THE JOB STATEMENT WILL ONLY OCCUR IF A SECURITY
*  PRODUCT IS PRESENT.
*
*  GREG PRICE, MARCH 2017
*
*
*  THE PROGRAM'S ORIGINAL COMMENTS FROM DECADES AGO NOW FOLLOW:
         EJECT
*
*  THIS EXIT INSERTS A CONTINUATION OF EACH JOB CARD SUBMITTED BY
*  A RACF DEFINED USER. THE CONTINUATION CARD CONTAINS THE USER ID
*  AND LOGON PASSWORD OF THE PERSON SUBMITTING THE JOB. IF THERE
*  IS NO ROOM TO INSERT A COMMA AND A BLANK THE JOB IS SUBMITTED
*  WITHOUT ADDING A CONTINNUATION CARD AND A MESSAGE IS SENT TO THE
*  USER INFORMING THEM OF THIS. IF THE USER IS NOT RACF DEFINED OR
*  EITHER 'USER' OR 'PASSWORD' KEY WORDS ARE FOUND THEN THE JOB IS
*  PASSED ON ASIS AND NO MESSAGE IS SENT. YOU CANNOT GET SOMEONE
*  ELSE'S PASSWORD BY USING THIS EXIT AS WRITTEN.
*
*  THIS EXIT IKJEFF10 REPLACES THE IBM VERSION OF IKJEFF10 WHICH IS
*  EFECTIVELY A BR14.  THIS EXIT WORKS WITH OR WITHOUT THE TSO/E OR
*  THE EARLIER TSO COMMAND PACKAGE AS THE DUMMY EXIT IS IN THE BASE
*  TSO CODE.  THIS EXIT WAS DEVELOPED AT THE GEORGIA DEPARTMENT OF
*  LABOR AND HAS BEEN IN USE FOR OVER ONE YEAR WITH NO KNOWN PROBLEMS.
*  WE WILL ATTEMPT TO FIX ERRORS AS LONG AS WE CONTINUE TO USE THIS
*  EXIT, BUT DO NOT PROMISE THAT WE WILL FIX BUGS OR PROVIDE ANY
*  SUPPORT IN THE FUTURE.
*
*  SEND COMMENTS AND ERROR REPORTS TO:
*        SYSTEMS SUPPORT UNIT
*        GEORGIA DEPARTMENT OF LABOR
*        ROOM 370 STATE LABOR BUILDING
*        ATLANTA, GA  30334
*
R0       EQU 0  OS LINKAGE
R1       EQU 1  OS LINKAGE - POINTER TO POINTER TO PARM LIST (IEEXITL)
R2       EQU 2  WORK REGISTER FOR GETMAIN, CVT, USERJCL, AND GENCD
R3       EQU 3  BASE REGISTER FOR ASCB, TCB, JSCB, AND PSCB
R4       EQU 4  BASE REGISTER FOR ASXB
R5       EQU 5  BASE REGISTER FOR ACEE
R6       EQU 6  BASE REGISTER FOR TSB
R7       EQU 7  BASE REGISTER FOR IEEXITL
R8       EQU 8  BASE REGISTER FOR IESUBCTD
R9       EQU 9  WORK REGISTER FOR CHANGING USERJCL (BASE FROM IECARDP)
R10      EQU 10 WORK REGISTER FOR USERJCL, MSGTEXT1, AND GENCD
R11      EQU 11 BASE REGISTER FOR GETMAIN AREA (STORED IN IEEXITWD)
R12      EQU 12 BASE REGISTER
R13      EQU 13 SAVE AREA
R14      EQU 14 OS LINKAGE
R15      EQU 15 OS LINKAGE - RETURN CODE FOR CALLING PROGRAM IKJEFF09
*
         USING PSA,0
         USING IKJEFF10,R12
IKJEFF10 CSECT
         SAVE  (14,12),,IKJEFF10-SUBMIT-USER-EXIT-&SYSDATE-&SYSTIME
         LR    R12,R15
*
*                                    REGISTERS NOT CHAINED UNTIL AFTER
*                                      GETMAIN
*
         L     R7,0(0,R1)            GET ADDRESS OF PARM LIST (IEEXITL)
         USING IEEXITL,R7
         L     R8,IESUBCTP           GET ADDRESS OF SUBMIT JCL INFO
         USING IESUBCTD,R8
*
         ICM   R11,15,IEEXITWD       FIRST INVOCATION OF THIS EXIT?
         BNZ   CONTINUA              NO, GO AROUND GETMAIN
*
         LA    R2,SIZDATD
         GETMAIN  R,LV=(2),SP=230
         LR    R11,R1                GET ADDRESS OF GETMAIN DSECT
         USING DATD,R11
         ST    R11,IEEXITWD          POINT TO GETMAIN AREA
         XC    DATD(SIZDATD),DATD    CLEAR GETMAIN AREA
*
         L     R3,PSATOLD            GET ADDRESS OF CURRENT TCB
         L     R3,TCBJSCB-TCB(,R3)   GET ADDRESS OF CURRENT JSCB
         USING IEZJSCB,R3
         L     R3,JSCBPSCB           GET ADDRESS OF PSCB
         DROP  R3                    (IEZJSCB)
         LTR   R3,R3                 ANY PSCB FOUND?
         BZ    DONEPSCB              NO
         USING PSCB,R3
         MVC   SAVEUSRI,PSCBUSER
         MVI   SAVEUSRI+7,BLANK
         MVC   SAVEUSRL,PSCBUSRL
         DROP  R3                    (PSCB)
         MVI   IETAKEEX,IETJOB+IETDD+IETCMD+IETCOMNT
DONEPSCB EQU   *
*
         L     R3,PSAAOLD            GET ADDRESS OF CURRENT ASCB
         USING ASCB,R3
         L     R4,ASCBASXB           GET ADDRESS OF CURRENT ASXB
         USING ASXB,R4
         L     R5,ASXBSENV           GET ADDRESS OF CURRENT ACEE
         LTR   R5,R5                 IS THERE AN ACEE ADDRESS?
         BZ    TAKEEXOF              NO, CAN'T INSERT CARD
         USING ACEE,R5
         TM    ACEEFLG1,ACEERACF     IS USER RACF DEFINED?
         BZ    TAKEEXOF              NO, NO MORE JOB CARDS TO COME
*                                      TO THIS EXIT FOR THIS SUBMIT
         L     R6,ASCBTSB            GET ADDRESS OF TSB
         LTR   R6,R6                 IS THERE A TSB ADDRESS?
         BZ    TAKEEXOF              NO, CAN'T INSERT CARD
*
         USING TSB,R6
         MODESET KEY=ZERO
         MVC   SAVEPSWD,TSBPSWD      SAVE PASSWORD FROM TSB
         MODESET KEY=NZERO
         CLI   SAVEPSWD,BLANK        IS THERE A LOGON PASSWORD?
         BNH   TAKEEXOF              NO, CAN'T INSERT CARD
*
         MVC   SAVEUSER,ACEEUSER     SAVE PASSWORD FROM TSB
         MVI   IETAKEEX,IETJOB+IETDD+IETCMD+IETCOMNT
         B     CONTINUA
         DROP  R3,R4,R5,R6           (ASCB,ASXB,ACEE,TSB)
*
TAKEEXOF EQU   *
         OI    SW,NOACEE             NO USABLE SECURITY FOR THIS ID
         MVI   IETAKEEX,ZEROHEX      TURN OFF TAKE EXIT SWITCH
         CLI   SAVEUSRL,ZEROHEX      GOT A USER ID?
         BE    SETRC0                NO, CAN'T DO MUCH HERE
         CLI   SAVEUSRL,SEVENX       SENSIBLE LENGTH?
         BH    SETRC0                NO, CAN'T DO MUCH HERE
         MVI   IETAKEEX,IETJOB+IETDD+IETCMD+IETCOMNT
*        B     CONTINUA              YES, CAN PROCESS &SYSUID
*
CONTINUA EQU   *
         LA    R1,SAVE
         ST    R13,4(,R1)            BACK CHAIN SAVE AREAS
         ST    R1,8(,R13)            FORWARD CHAIN SAVE AREAS
         LR    R13,R1                SET R13 TO NEW SAVE AREA
         L     R1,4(R13)             SET R1 TO SAVE AREA AT ENTRY
         L     R1,24(,R1)            RESTORE R1 FROM SAVE AREA
*
         TM    IETAKEEX,IETJOB       TAKE EXIT FOR JOB CARD?
         BZ    SETRC0                SHOULD NOT BE IN THIS EXIT
*
         CLC   IEMSGP,ZEROS          RETURN FROM SENDING MESSAGE?
         BE    REENT                 NO,
*
         MVC   IEMSGP,ZEROS          YES, CLEAR POINTER TO MESSAGE
         B     SETRC0                THIS CARD ALREADY PROCESSED
*
REENT    EQU   *
         L     R9,IECARDP            GET ADDRESS OF CURRENT CARD
         LTR   R9,R9                 IS EXIT BEING RE-ENTERED?
         BZ    GENCD                 YES, INSERT USER AND PASSWORD CARD
*
         CLI   IEOPRAND,ZEROHEX      OPERAND COLUMN?
         BZ    NOOPRAND              NO OPERANDS ON THIS CARD
*
UIDSRCH  EQU   *
         SR    R2,R2
         IC    R2,IEOPRAND
         AR    R9,R2                 REGISTER TO POINT TO OPERAND
         BCTR  R9,0
*
         LA    R10,COMMALMT-SEVENX+2 GET MAX COLUMN COUNT TO EXAMINE
         SR    R10,R2                LESS FIRST PART OF CARD
         BNP   UIDDONE               NOT ENOUGH ROOM LEFT FOR &SYSUID
*
UIDLOOP  EQU   *
         CLC   =C'&&SYSUID',0(R9)    FOUND THE SYMBOL?
         BE    UIDMTCH               YES
UIDNEXT  EQU   *
         LA    R9,1(,R9)             NO, POINT TO NEXT CHARACTER
         BCT   R10,UIDLOOP           TRY AGAIN
         B     UIDDONE               &SYSUID NOT FOUND
*
UIDMTCH  EQU   *
         LA    R4,SEVENX(,R9)        POINT PAST MATCHED STRING
         CLI   0(R4),COMMA           FOLLOWED BY COMMA?
         BE    UIDSUB                YES, PERFORM SUBSTITUTION
         CLI   0(R4),AMPER           FOLLOWED BY AMPERSAND?
         BE    UIDSUB                YES, PERFORM SUBSTITUTION
         CLI   0(R4),BLANK           FOLLOWED BY A BLANK?
         BE    UIDSUB                YES, PERFORM SUBSTITUTION\
         CLI   0(R4),LPAREN          FOLLOWED BY AN OPEN BRACKET?
         BE    UIDSUB                YES, PERFORM SUBSTITUTION
         CLI   0(R4),RPAREN          FOLLOWED BY A CLOSE BRACKET?
         BE    UIDSUB                YES, PERFORM SUBSTITUTION
         CLI   0(R4),PERIOD          TRAILING PERIOD?
         BNE   UIDNEXT               NO, SO NOT A MATCH TO ACTION
         LA    R4,SEVENX+1(,R9)      YES, CONSUME IT AS WELL
UIDSUB   EQU   *
         BCTR  R9,0                  POINT BEHIND AMPERSAND
         CLI   0(R9),AMPER           REALLY DOUBLE AMPERSAND?
         LA    R9,1(,R9)             RESTORE POINTER
         BE    UIDNEXT               YES, SO NOT A MATCH TO ACTION
         MVC   0(SEVENX,R9),SAVEUSRI LOAD IN THE USERID
         SR    R0,R0
         IC    R0,SAVEUSRL           GET ITS LENGTH
         ALR   R9,R0                 POINT PAST LOADED USERID
         L     R5,IECARDP            GET ADDRESS OF CURRENT CARD
         LA    R5,COMMALMT(,R5)      GET ADDRESS OF SHUFFLE LIMIT
         MVC   1(8,R5),UIDSTAMP      STAMP THIS RECORD AS ALTERED
UIDSHFL  EQU   *
         CR    R9,R4                 TEXT AMENDMENT COMPLETE?
         BNL   REENT                 YES, NOW RESCAN FOR REPEATS
         MVI   0(R9),BLANK           NO, ADD A BLANK
         CR    R4,R5                 SHUFFLE SOURCE ALL GONE?
         BH    UIDSHFLD              YES, JUST KEEP INSERTING BLANKS
         MVC   0(1,R9),0(R4)         NO, SHUFFLE A BYTE UP
         CLI   0(R4),BLANK           IS SOURCE BYTE A BLANK?
         BE    UIDSHFLD              YES, DO NOT ADVANCE SOURCE
         LA    R4,1(,R4)             NO, INCREMENT SHUFFLE SOURCE
UIDSHFLD EQU   *
         LA    R9,1(,R9)             INCREMENT SHUFFLE TARGET
         B     UIDSHFL               CONTINUE THE SHUFFLE
*
UIDDONE  EQU   *
         TM    IESTMTYP,IESJOB       IS STATEMENT JOB CARD?
         BZ    SETRC0                NO, DONT INSERT
*
         L     R9,IECARDP            GET ADDRESS OF CURRENT CARD
         SR    R2,R2
         IC    R2,IEOPRAND
         AR    R9,R2                 REGISTER TO POINT TO OPERAND
         BCTR  R9,0
*
         LA    R10,COMMALMT          IN LOOP, LOOK AT 71 COLUMNS
         SR    R10,R2                LESS FIRST PART OF CARD
*
         SR    R2,R2                 CLEAR FOR QUOTE SEARCH
*
COMPQUOT EQU   *
         CLC   0(1,R9),QUOTE         IS IT A QUOTE MARK?
         BNE   CKQUOT                NO,
*
         LTR   R2,R2                 IS IT THE BEGINNING QUOTE?
         BZ    BEGQUOT               YES
*
         SR    R2,R2                 NO, END OF QUOTE, RESET SWITCH
         B     NEXTCOL
*
BEGQUOT  EQU   *
         LA    R2,1                  SET SWITCH ON FOR QUOTE
         B     NEXTCOL               AND GO TO NEXT COLUMN
*
CKQUOT   EQU   *
         LTR   R2,R2                 ARE WE IN A QUOTATION?
         BP    NEXTCOL               YES, DONT LOOK FOR PASSWORD=
*
COMPPSWD EQU   *
         CLC   0(9,R9),PSWDCON       IS IT PASSWORD=?
         BE    SETSW                 YES, DONT INSERT CARD
*
COMPUSER EQU   *
         CLC   0(5,R9),USRCON        IS IT USER=?
         BE    SETSW                 YES, DONT INSERT CARD
*
COMPBLK  EQU   *
         CLC   0(1,R9),BLANKS        END OF OPERANDS?
         BNE   NEXTCOL               NO,
*
         B     CONTOPER              YES
*
NEXTCOL  EQU   *
         LA    R9,1(R9)              TRY NEXT COLUMN
         BCT   R10,COMPQUOT          IF NOT AT END OF CARD, LOOP
*
         B     CONTOPER              YES, IS OPERAND CONTINUED?
*
SETSW    EQU   *
         OI    SW,UPHERE             TURN SWITCH ON, DONT NEED CARD
*
CONTOPER EQU   *
         TM    IESTMTYP,IESOPCON     IS OPERAND TO BE CONTINUED?
         BO    SETRC0                YES
*
         TM    SW,UPHERE+NOACEE      NEED TO INSERT CARD?
         BNZ   NOINSERT              NO, GO GET NEXT STATEMENT, IF ANY
*
         CLC   0(2,R9),BLANKS        ROOM FOR COMMA AND BLANK?
         BE    MVCOMMA               YES, CAN INSERT CARD
*
         CLC   0(1,R9),BLANKS        ROOM FOR JUST COMMA?
         BE    LASTCOL               MAYBE OK
*
         B     WARNING               CAN'T INSERT CARD
*
LASTCOL  EQU   *
         C     R10,ZEROS             AT COLUMN 71?
         BE    MVCOMMA               YES, CAN PUT COMMA WITHOUT BLANK
*                                       FOLLOWING
WARNING  EQU   *
         MVC   MSG,MSG1              MOVE MSG TO MSG AREA
         LA    R10,MSG               POINT REGISTER TO MESSAGE AREA
         ST    R10,IEMSGP            GIVE ADDRESS TO CALLER
         LA    R15,IEMSG             RC=8, TELL CALLER TO SEND MESSAGE
         B     RETURN
*
MVCOMMA  EQU   *
         MVI   0(R9),COMMA
*
         MVC   SAVETYP,IESTMTYP      SAVE SWITCHES
         OI    IESTMTYP,IESOPCON     NOW THERE IS A COMMA,
         OI    IESTMTYP,IESSCON        SO SET THE FLAGS
         LA    R15,IERETURN          RC=4, TELL CALLER TO RETURN FOR
         B     RETURN                    INSERTED CARDS
*
NOOPRAND EQU   *
         CLI   SW,ONE                USER OR PASSWORD ALREADY FOUND
         BNE   SETRC0                OR NOT FOUND AND GENERATED
*
NOINSERT EQU   *
         NI    SW,255-UPHERE         TURN SWITCH OFF FOR NEXT JOB CARD
*
SETRC0   EQU   *
         LA    R15,IECONTIN          RC=0, TELL CALLER TO COMPLETE
*
RETURN   EQU   *
         L     R13,4(R13)            RESTORE SAVE AREA
         RETURN (14,12),RC=(15)
*
GENCD    EQU   *
         LA    R10,CD               POINT WORK REGISTER TO GETMAIN AREA
         ST    R10,IECARDP          POINT TO INSERTED CARD FOR CALLER
         MVI   CD,BLANK
         MVC   CD+1(ENDCD-CD-1),CD  CLEAR CARD AREA
         MVC   0(19,R10),CDUSER     MOVE USER CONSTANT
         LA    R10,19(R10)
         MVC   0(8,R10),SAVEUSRI    MOVE USER TO CARD
         SR    R2,R2                CLEAR REG FOR LENGTH
         IC    R2,SAVEUSRL
         AR    R10,R2               BUMP PAST USER
         MVC   0(10,R10),CDPSWD     MOVE PASSWORD CONSTANT TO CARD
         LA    R10,10(R10)
         MVC   0(8,R10),SAVEPSWD    MOVE PASSWORD TO CARD
         MVC   CD+50(21),CDMSG      MOVE COMMENT CONSTANT
*
         MVI   IEOPRAND,FIFTEEN     MOVE OPERAND COLUMN NUMBER
*
         MVC   IESTMTYP,SAVETYP     RESTORE SWITCH
         TM    IESTMTYP,IESSCON     IS THIS LAST CARD?
         BZ    SETCONTN             YES
*
         LR    R10,R11              SET UP WORK REGISTER
         LA    R10,71(R10)          TO COLUMN 72
         MVI   0(R10),NONBLANK      AND MOVE X TO COLUMN 72
*
SETCONTN EQU   *
         OI    IESTMTYP,IESCONTN    SET CONTINUATION FLAG
         B     SETRC0               AND LEAVE
         TITLE ' CONSTANTS AND LITERALS '
ZEROS    DC    D'0'
*
*
USRCON   DC    CL5'USER='
PSWDCON  DC    CL9'PASSWORD='
BLANKS   DC    CL9'         '
QUOTE    DC    XL1'7D'
*
CDUSER   DC    CL19'//            USER='
CDPSWD   DC    CL10',PASSWORD='
CDMSG    DC    CL21'GENERATED BY IKJEFF10'
UIDSTAMP EQU   *-8,8
*
MSG1     EQU   *
MSGL1    DC    AL2(L'MSGTEXT1+2)
MSGTEXT1 DC    C'NO SPACE FOR COMMA - CAN NOT INSERT USER/PASSWORD'
*
MSGAREAL EQU   L'MSGTEXT1+2         LENGTH OF AREA IN GETMAIN AREA
*
COMMALMT EQU   71
BLANK    EQU   C' '
PERIOD   EQU   C'.'
AMPER    EQU   X'50'
LPAREN   EQU   C'('
RPAREN   EQU   C')'
COMMA    EQU   C','
ONE      EQU   C'1'
NONBLANK EQU   C'+'
ZEROHEX  EQU   X'00'
SEVENX   EQU   X'07'
FIFTEEN  EQU   X'0F'
*
         LTORG
*
         DC    0D'0'                END OF CSECT
         TITLE ' WORKING STORAGE '
DATD     DSECT
*
CD       DS    CL80                 CARD TO BE INSERTED IN JCL
ENDCD    EQU   *
*
SAVE     DS    CL72                 REGISTER SAVE AREA
*
MSG      DS    CL(MSGAREAL)         WARNING MESSAGE TO TSO USER
*
SW       DS    XL1                  FLAG BYTE
UPHERE   EQU   X'80'                FOUND USER OR PASSWORD ON JOB CARD
NOACEE   EQU   X'40'                THERE IS NO ACEE SO NO SECURITY
*
SAVEUSER DS    0CL9
SAVEUSRL DS    AL1
SAVEUSRI DS    CL8
*
SAVEPSWD DS    CL8
*
SAVETYP  DS    CL1
*
ENDDATD  DS    0D
SIZDATD  EQU   ENDDATD-DATD
         TITLE ' PARAMETER LIST '
         IKJEFFIE IETYPE=SUBMIT
         TITLE ' CONTROL BLOCKS '
         PRINT NOGEN
         IHAPSA
         SPACE
         IHAASCB
         SPACE
         IHAASXB
         SPACE
         IHAACEE
         SPACE
         IKJTSB   LIST=NO
         SPACE
         IKJTCB   LIST=NO
         SPACE
         IEZJSCB
         SPACE
         IKJPSCB
         SPACE
         END   IKJEFF10
/*
//*
//STEP3   EXEC PGM=IEBGENER
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  *
  IDENTIFY IKJEFF10('ZP60034')
/*
//SYSUT2   DD  DSN=&&SMPMCS,DISP=(MOD,PASS)
//SYSIN    DD  DUMMY
//*
//STEP4   EXEC SMPREC,WORK='SYSALLDA'
//SMPPTFIN DD  DSN=&&SMPMCS,DISP=(OLD,DELETE)
//SMPCNTL  DD  *
  RECEIVE
          SELECT(ZP60034)
          .
/*
//*
//STEP5   EXEC SMPAPP,WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(ZP60034)
        CHECK
        .
/*
//*
//STEP5   EXEC SMPAPP,COND=(0,NE),WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(ZP60034)
        DIS(WRITE)
        .
/*
//
