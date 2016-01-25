;;PROGRAM BEGINS AT x3000
.ORIG x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
;CLEAR ALL REGISTERS
JSR CLEAR
AND R7,R7,R0
JSR LOOP

;SOME DATA VARIABLES
PSTART: .FILL x3400
PEND: .FILL x3405

;SAVE ALL REGISTERS
PUSH LD R6, PSTART
     STR R0,R6,#0
     STR R1,R6,#1
     STR R2,R6,#2
     STR R3,R6,#3
     STR R4,R6,#4
     STR R5,R6,#5
     RET

;RESTORE ALL REGISTERS     
POP LD R6, PEND
    LDR R5,R6,#0
    LDR R4,R6,#-1
    LDR R3,R6,#-2
    LDR R2,R6,#-3
    LDR R1,R6,#-4
    LDR R0,R6,#-5
    RET
    
;CLEAR ALL REGISTERS
CLEAR AND R0,R0,#0
      AND R1,R1,#0
      AND R2,R2,#0
      AND R3,R0,#0
      AND R4,R1,#0
      AND R5,R2,#0
      AND R6,R0,#0
      RET
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CHOOSE ENCODE OR DECODE;;;;;;;;;;;;;;;;;;;;;;;;;;;

;JUST SOME VARIABLES NEEDED FOR THE FIRST PART
DORE: .STRINGZ "\nDecode or Encode (D or E): "
INVALIDCHARACTERA: .STRINGZ "\nTHAT IS AN ILLEGAL CHARACTER. PLEASE TRY AGAIN.\n"
D: .FILL x-44
E: .FILL x-45
CHOICESTOREA: .FILL x3300

;PRINT OUT FIRST MESSAGE
LOOP LEA R0, DORE
     PUTS

;GET USER CHOICE
GETC
PUTC

;STORE USER INPUT
LD R3,CHOICESTOREA
STR R0,R3,#0

;SEE IF D WAS ENTERED
LD R1,D
ADD R3,R1,R0
BRz ENTEREDD

;SEE IF E WAS ENTERED
LD R2,E
ADD R3,R2,R0
BRz ENTEREDE

;ELSE GO TO BEGINING
LEA R0, INVALIDCHARACTERA
PUTS
BR LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SELECT TRANSLATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;VARIABLES FOR NEXT PART
MESSAGED: .STRINGZ "\nENTER YOUR STRING THAT YOU WANT TO DECODE: "
MESSAGEE: .STRINGZ "\nENTER YOUR STRING THAT YOU WANT TO ENCODE: "

;JUMPS TO HERE IF D WAS ENTERED
ENTEREDD  LEA R0, MESSAGED
          PUTS
          ;GET MESSAGE
          JSR GETMESSAGE
          JSR PUSH
RETURND   JSR CONVERT
RETURNDD  JSR DECODE
DRETURNL  JSR POP
          ;QUIT PROGRAM
          JSR LAST

;JUMPS TO HERE IF E WAS ENTERED
ENTEREDE LEA R0, MESSAGEE
         PUTS
         ;GO GET MESSAGE
         JSR GETMESSAGE
         JSR PUSH
RETURNE  JSR ENCODE
RETURNEE JSR POP 
         ;QUIT PROGRAM
         JSR LAST
         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ENCODE AND DECODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;DATA DECLARATIONS
NUMBOFFSET: .FILL x-30
LETTEROFFSET: .FILL x-41
NEWLINE: .STRINGZ "\nTHE ENCODED MESSAGE: "
NEWLINED: .STRINGZ "\nTHE DECODED MESSAGE: "
TRANSLATESTORE: .FILL x3321
NUMBOFFSETDECODE: .FILL x-30
LETTEROFFSETDECODE: .FILL x-37

;CLEAR THE REGISTERS
DECODE JSR CLEAR
       ;LOAD THE POSITION OF THE FIRST CHAR
       LD R1, TRANSLATESTORE
       ;LOAD THE FIRST CHAR
DGETCH LDR R0,R1,#0
       ;ADD 1 TO POSITION
       ADD R1,R1,#1
       ;SEE IF CHAR IS RETURN
       LD R2,ENTERNUMBER
       ADD R2,R0,R2
       BRz DRETURNL
       ;OTHERWISE CONVERT TO ASCII
       ;LOAD THE ADDRESS OF THE COMPARISON BYTE
       LD R2, DECODEVARADD
       ;LOAD THE COMPARISON VAR
CHD    LDR R3,R2,#0
       ;ADD 1 TO ADDRESS BYTE
       ADD R2,R2,#1
       ;SEE IF CHAR IS THE SAME
       ADD R3,R3,R0
       BRz PRINT
       ;ADD 1 TO STRING BYTE
       ADD R4,R4,#1
       BR CHD
;LOAD ADDRESS OF PRINT VAR
PRINT  LD R5, PRINTVARADD
PRINTA ADD R5,R5,#1
       ADD R4,R4,#-1
       BRz PRNTCH
       BR PRINTA
;PRINT CHAR
PRNTCH LDR R0,R5,#0
       PUTC
       BR DGETCH
       
;CONVERT 2 CHAR BYTES TO 1 BYTE
CONVERT LEA R0,NEWLINED
        PUTS
        JSR CLEAR
        ;LOAD THE ADDRESS OF WHERE THE MESSAGE IS STORED
        LD R2, MESSAGESTORE
        ;LOAD WHERE TO STORE THE MESSAGES
        LD R5,TRANSLATESTORE
        ;GET THE CHARACTERS
GETCHD  LDR R0,R2,#0
        ;SEE IF THE FIRST CHARACTER IS RETURN
        LD R1,ENTERNUMBER
        ADD R1,R1,R0
        BRz RETURNDDD
        ;ELSE GET SECOND CHARACTER
        LDR R1,R2,#1
        ;ADD TWO TO THE MESSAGE STORE
        ADD R2,R2,#2
        ;SUBTRACT THE OFFSET OF THE FIRST CHARACTER
        BR OFFSETO
        ;MULTIPLY THE FIRST NUMBER BY x10
DMULT   ADD R0,R0,R0
        ADD R0,R0,R0
        ADD R0,R0,R0
        ADD R3,R0,#0
        ADD R0,R3,R0
        ;GET THE SECOND NUMBER OFFSET
        BR OFFSETT
        ;ADD THE SECOND NUMBER
DMULTT  ADD R0,R0,R1
        ;STORE TRANSCODED CHARACTERS
        STR R0,R5,#0
        ;ADD 1 TO MESSAGESTORE
        ADD R5,R5,#1
        JSR GETCHD

        ;SEE IF CHAR IS LETTER
OFFSETO LD R4,A
        ADD R4,R0,R4
        ;IF IT ISNT GO TO LETTER ENCODE
        BRzp LTROFST
        LD R3,NUMBOFFSETDECODE
        ADD R0,R0,R3
        BR DMULT
LTROFST LD R3,LETTEROFFSETDECODE
        ADD R0,R0,R3
        BR DMULT
        
        ;SEE IF CHAR IS LETTER
OFFSETT LD R4,A
        ADD R4,R1,R4
        ;IF IT ISNT GO TO LETTER ENCODE
        BRzp LTRFST
        LD R3,NUMBOFFSETDECODE
        ADD R1,R1,R3
        BR DMULTT
LTRFST  LD R3,LETTEROFFSETDECODE
        ADD R1,R1,R3
        BR DMULTT

RETURNDDD ;STORE THE RETURN CHARACTER
          STR R0,R5,#0
          JSR RETURNDD
;ENCODE MESSAGE
ENCODE   LEA R0,NEWLINE
         PUTS
         JSR CLEAR
         ;LOAD THE ADDRESS OF THE FIRST CHARACTER INTO R0
         LD R4, MESSAGESTORE
;LOAD THE CHARACTER
LOADCHE  LDR R0,R4,#0
         ;ADD 1 TO R4
         ADD R4,R4,#1
         ;SEE IF CHAR IS RETURN
         LD R2,ENTERNUMBER
         ADD R2,R2,R0
         BRz RETURNEE
         ;IF NOT SEE IF CHARACTER IS A NUBMER
         LD R2,A
         ADD R2,R0,R2
         ;IF IT ISNT GO TO LETTER ENCODE
         BRzp LETTERE
         ;LOAD NUMBER OFFSET
         LD R1,NUMBOFFSET
         ;LOAD ADDRESS OF FIRST NUMBER
         LEA R2,NUMBERS
         ;ADD OFFSET TO NUMBER
         ADD R3,R0,R1
         ;CLEAR R0
         AND R0,R0,#0
         ;SET R0 TO PLACE OF CHARACTER TO PRINT
         ADD R0,R2,#0
         ;MULTIPLY TO GET CORRECTED OFF SET
         JSR MULT
         ;ADD OFFSET TO ADDRESS
         ADD R0,R0,R3 
         ;PRINT ENCODED NUMBER
         PUTS
         ;STORE ADDRESS INTO TRANSLATE STORE
         LD R2, TRANSLATESTORE
         STR R0,R2,#0
         LEA R3, TRANSLATESTORE
         ADD R2,R2,#1
         STR R2,R3,#0
         JSR LOADCHE         
LETTERE  ;LOAD NUMBER OFFSET
         LD R1,LETTEROFFSET
         ;LOAD ADDRESS OF FIRST NUMBER
         LEA R2,LETTERS
         ;ADD OFFSET TO NUMBER
         ADD R3,R0,R1
         ;CLEAR R0
         AND R0,R0,#0
         ;SET R0 TO PLACE OF CHARACTER TO PRINT
         ADD R0,R2,#0
         ;MULTIPLY TO GET CORRECTED OFF SET
         JSR MULT
         ;ADD OFFSET TO ADDRESS
         ADD R0,R0,R3 
         ;PRINT ENCODED NUMBER
         PUTS
         LD R2, TRANSLATESTORE
         STR R0,R2,#0
         LEA R3, TRANSLATESTORE
         ADD R2,R2,#1
         STR R2,R3,#0
         JSR LOADCHE         

MULT  ADD R5,R3,#0
      BRz RETA
      ADD R3,R3,R3
      ADD R3,R3,R5
RETA  RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GET MESSAGE TO BE TRANSLATED;;;;;;;;;;;;;;;;;;;;;;

;data declarations below
CHOICESTORE: .FILL x3300
MESSAGEERROR: .STRINGZ "\nERROR TO MANY CHARACTERS! TRY AGAIN!"
INVALIDCHARACTERB: .STRINGZ "\nTHAT IS AN ILLEGAL CHARACTER. PLEASE TRY AGAIN.\n"
A: .FILL x-41
F: .FILL x-46
Z: .FILL x-5A
ZO: .FILL x-30
N: .FILL x-39
MESSAGESTORE: .FILL X3301
ENTERNUMBER: .FILL x-A
ITERATIONS: .FILL #31
DA: .FILL x-44
PRINTVARADD: .FILL x0000
DECODEVARADD: .FILL x0000


;GET THE MESSAGE TO TRANSLATE
GETMESSAGE LD R1, ENTERNUMBER
           AND R2,R2,#0
           AND R3,R3,#0
           LD R2,ITERATIONS
           LD R3, MESSAGESTORE
           LEA R4,PRINTVAR
           LEA R5,PRINTVARADD
           STR R4,R5,#0
           LEA R4, DECODEVAR
           LEA R5, DECODEVARADD
           STR R4,R5,#0
;GET THE CHARACTER
GETCHARACTER GETC
             ;MAKE SURE CHARACTER IS VALID
             JSR VALID
             ;STORE CHARACTER
RETURNGC     JSR POP
             STR R0,R3,#0
             ;ADD 1 TO MESSAGESTORE
             ADD R3,R3,#1
             ;SEE IF CHARACTER IS ENTER
             ADD R4,R1,R0
             ;IF SO TRANSLATE THE MESSAGE
             BRz CHOICE
             ;OTHERWISE PUT THE CHARACTER
             PUTC
             ;SUBTRACT 1 FROM THE ITERATIONS
             ADD R2,R2,#-1
             ;IF POSITIVE GET ANOTHER CHARACTER
             BRp GETCHARACTER
             ;OTHERWISE PRINT OUT ERROR AND GET MESSAGE AGAIN
             LEA R0, MESSAGEERROR
             PUTS
             BR GETMESSAGE
             
;RETURN TO WHERE IT WAS STARTED
CHOICE LD R0,CHOICESTORE
       LDR R3,R0,#0
       LD R1,DA
       ADD R1,R1,R3
       ;IF D WAS CHOICE RETURN THERE
       BRz RETURNDA
       ;OTHERWISE RETURN TO E
       BR RETURNEA
RETURNDA JSR RETURND
RETURNEA JSR RETURNE

;SEE IF CHARACTER IS VALID
VALID   JSR PUSH
        ;FIRST SEE IF IT IS RETURN
        LD R1, ENTERNUMBER
        ADD R3,R0,R1
        BRz RETURNGC
        ;CHECK THE CHOICE
        LD R1, CHOICESTORE
        LDR R3,R1,#0
        LD R2,DA
        ADD R1,R3,R2
        ;IF D IS CHOICE SKIP
        BRz CHOICED
;;;;;;;;;CHARACTER VALIDATION FOR E
        ;SEE IF ITS GREATER THAN OR EQUAL TO 0
        LD R2, ZO
        ADD R3,R0,R2
        BRn INVALID
        ;SEE IF ITS LESS THAN OR EQUAL TO 9
        LD R2,N
        ADD R3,R0,R2
        BRp CHECKE
        JSR POP
        JSR RETURNGC
        ;SEE IF ITS GREATER THAN OR EQUAL TO A
CHECKE  LD R2, A
        ADD R3,R0,R2
        BRn INVALID
        ;SEE IF ITS LESS THAN OR EQUAL TO Z
        LD R2, Z
        ADD R3,R0,R2
        BRp INVALID
        JSR POP
        JSR RETURNGC
;;;;;;;;CHARACTER VALIDATION FOR DECODE
CHOICED LD R2, ZO
        ADD R3,R0,R2
        BRn INVALID
        ;SEE IF ITS LESS THAN OR EQUAL TO 9
        LD R2,N
        ADD R3,R0,R2
        BRp CHECKD
        JSR POP
        JSR RETURNGC
        ;SEE IF ITS GREATER THAN OR EQUAL TO A
CHECKD   LD R2, A
        ADD R3,R0,R2
        BRn INVALID
        ;SEE IF ITS LESS THAN OR EQUAL TO F
        LD R2, F
        ADD R3,R0,R2
        BRp INVALID
        JSR POP
        JSR RETURNGC
INVALID LEA R0,INVALIDCHARACTERB
        PUTS
        JSR POP
        JSR GETCHARACTER

;LETTER DECLARATIONS
NUMBERS: .STRINGZ "04"
.STRINGZ "84"
.STRINGZ "C4"
.STRINGZ "E4"
.STRINGZ "F4"
.STRINGZ "FC"
.STRINGZ "7C"
.STRINGZ "3C"
.STRINGZ "1C"
.STRINGZ "0C"
LETTERS: .STRINGZ "A0"
.STRINGZ "78"
.STRINGZ "58"
.STRINGZ "70"
.STRINGZ "C0"
.STRINGZ "D8"
.STRINGZ "30"
.STRINGZ "F8"
.STRINGZ "E0"
.STRINGZ "88"
.STRINGZ "50"
.STRINGZ "B8"
.STRINGZ "20"
.STRINGZ "60"
.STRINGZ "10"
.STRINGZ "98"
.STRINGZ "28"
.STRINGZ "B0"
.STRINGZ "F0"
.STRINGZ "40"
.STRINGZ "D0"
.STRINGZ "E8"
.STRINGZ "90"
.STRINGZ "68"
.STRINGZ "48"
.STRINGZ "38"

DECODEVAR: .FILL x-04
.FILL x-84
.FILL x-C4
.FILL x-E4
.FILL x-F4
.FILL x-FC
.FILL x-7C
.FILL x-3C
.FILL x-1C
.FILL x-0C
.FILL x-A0
.FILL x-78
.FILL x-58
.FILL x-70
.FILL x-C0
.FILL x-D8
.FILL x-30
.FILL x-F8
.FILL x-E0
.FILL x-88
.FILL x-50
.FILL x-B8
.FILL x-20
.FILL x-60
.FILL x-10
.FILL x-98
.FILL x-28
.FILL x-B0
.FILL x-F0
.FILL x-40
.FILL x-D0
.FILL x-E8
.FILL x-90
.FILL x-68
.FILL x-48
.FILL x-38

PRINTVAR: .FILL x30
.FILL x31
.FILL x32
.FILL x33
.FILL x34
.FILL x35
.FILL x36
.FILL x37
.FILL x38
.FILL x39
.FILL x41
.FILL x42 
.FILL x43
.FILL x44
.FILL x45
.FILL x46
.FILL x47
.FILL x48
.FILL x49
.FILL x4A
.FILL x4B
.FILL x4C
.FILL x4D
.FILL x4E
.FILL x4F
.FILL x50
.FILL x51
.FILL x52
.FILL x53
.FILL x54
.FILL x55
.FILL x56
.FILL x57
.FILL x58
.FILL x59
.FILL x5A
;END INSTRUCTION
LAST HALT

.END