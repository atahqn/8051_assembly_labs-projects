;PART A

AGAIN:SETB P1.0

ACALL DELAY70

CLR P1.0

ACALL DELAY30

SJMP AGAIN



;TIME DELAY

DELAY70:MOV R1,#35

HERE1:MOV R2, #32

HERE2:DJNZ R2,HERE2

DJNZ R1,HERE1

RET



;TIME DELAY

DELAY30:MOV R3,#22

HERE3:MOV R4, #21

HERE4:DJNZ R4,HERE4

DJNZ R3,HERE3

RET

;;PART B

ACALL KEYBOARD

SUBB A,#30H

MOV R1,A

CJNE R1,#6,ABC

MOV R1,#5

ABC:CJNE R1,#8,ABCD

MOV R1,#6

ABCD:CJNE R1,#2,ABCDE

MOV R1,#3

ABCDE:CJNE R1,#0,ABCDEF

MOV R1,#2

ABCDEF:

MOV A,#10 ;%10

SUBB A,R1

MOV R7,A

;DUTY CYCLE

DCYC:SETB P2.5;INPUT FOR OSCİLLOSCOPE

MOV R2,1

HERE:ACALL DELAY1

DJNZ R2,HERE

CLR P2.5;CLEAR INPUT

MOV R3,7

HERE0:ACALL DELAY1

DJNZ R3,HERE0

SJMP DCYC



DELAY1: ;FOR 250 LOOP DELAY

MOV R4,#162

HERE1:DJNZ R4,HERE1

RET



	acall	CONFIGURE_LCD



KEYBOARD_LOOP:

	acall KEYBOARD

	;now, A has the key pressed

	acall SEND_DATA

	sjmp KEYBOARD_LOOP

	









CONFIGURE_LCD:	;THIS SUBROUTINE SENDS THE INITIALIZATION COMMANDS TO THE LCD

	mov a,#38H	;TWO LINES, 5X7 MATRIX

	acall SEND_COMMAND

	mov a,#0FH	;DISPLAY ON, CURSOR BLINKING

	acall SEND_COMMAND

	mov a,#06H	;INCREMENT CURSOR (SHIFT CURSOR TO RIGHT)

	acall SEND_COMMAND

	mov a,#01H	;CLEAR DISPLAY SCREEN

	acall SEND_COMMAND

	mov a,#80H	;FORCE CURSOR TO BEGINNING OF THE FIRST LINE

	acall SEND_COMMAND

	ret







SEND_COMMAND:

	mov p1,a		;THE COMMAND IS STORED IN A, SEND IT TO LCD

	clr p3.5		;RS=0 BEFORE SENDING COMMAND

	clr p3.6		;R/W=0 TO WRITE

	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN

	acall DELAY

	clr p3.7

	ret





SEND_DATA:

	mov p1,a		;SEND THE DATA STORED IN A TO LCD

	setb p3.5	;RS=1 BEFORE SENDING DATA

	clr p3.6		;R/W=0 TO WRITE

	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN

	acall DELAY

	clr p3.7

	ret





DELAY:

	push 0

	push 1

	mov r0,#50

DELAY_OUTER_LOOP:

	mov r1,#255

	djnz r1,$

	djnz r0,DELAY_OUTER_LOOP

	pop 1

	pop 0

	ret





KEYBOARD: ;takes the key pressed from the keyboard and puts it to A

	mov	P0, #0ffh	;makes P0 input

K1:

	mov	P2, #0	;ground all rows

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, K1

K2:

	acall	DELAY

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, KB_OVER

	sjmp	K2

KB_OVER:

	acall DELAY

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, KB_OVER1

	sjmp	K2

KB_OVER1:

	mov	P2, #11111110B

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, ROW_0

	mov	P2, #11111101B

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, ROW_1

	mov	P2, #11111011B

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, ROW_2

	mov	P2, #11110111B

	mov	A, P0

	anl	A, #00001111B

	cjne	A, #00001111B, ROW_3

	ljmp	K2

	

ROW_0:

	mov	DPTR, #KCODE0

	sjmp	KB_FIND

ROW_1:

	mov	DPTR, #KCODE1

	sjmp	KB_FIND

ROW_2:

	mov	DPTR, #KCODE2

	sjmp	KB_FIND

ROW_3:

	mov	DPTR, #KCODE3

KB_FIND:

	rrc	A

	jnc	KB_MATCH

	inc	DPTR

	sjmp	KB_FIND

KB_MATCH:

	clr	A

	movc	A, @A+DPTR; get ASCII code from the table 

	ret



;ASCII look-up table 

KCODE0:	DB	'1', '2', '3', 'A'

KCODE1:	DB	'4', '5', '6', 'B'

KCODE2:	DB	'7', '8', '9', 'C'

KCODE3:	DB	'*', '0', '#', 'D'



END