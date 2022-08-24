		CLR 0
		CLR 1
		CLR 2
		ACALL CONFIGURE_LCD
BACK1:		CLR A
		MOV A,#50H; hexadecimal equivalent of P
		ACALL SEND_DATA
		MOV A,#48H; hexadecimal equivalent of H
		ACALL SEND_DATA
		MOV A,#49H; hexadecimal equivalent of I
		ACALL SEND_DATA
		MOV A,#28H; hexadecimal equivalent of (
		ACALL SEND_DATA
		CLR A
		ADD A,0
		ADD A,1
		ADD A,2
		CJNE A,#0,NEW_INPUT
		SJMP INPUT
NEW_INPUT:	POP ACC
		ACALL SEND_DATA
		LJMP HERE
INPUT:		CLR A
		ACALL KEYBOARD
		ACALL SEND_DATA
		SUBB A,#30H
		MOV R3,A
BACKKK:		ACALL KEYBOARD
		ACALL SEND_DATA
		SUBB A,#30H
		MOV R4,A
		ACALL KEYBOARD
		ACALL SEND_DATA
		SUBB A,#30H
		MOV R5,A
		CLR A

		MOV B,#100
		MOV A,3
		MUL AB
		PUSH ACC	;DECIMAL INPUT
		MOV B,#10
		MOV A,4
		MUL AB
		XCH A,B
		POP ACC
		ADD A,B
		ADD A,5
;		CJNE A,#1,NOT_SPECIAL_CASE
;		LJMP SPECIAL_CASE
		CJNE A,#252,NOT252
		LJMP	IS252
NOT252:		CJNE A,#253,NOT253
		LJMP	IS253
NOT253:		CJNE A,#254,NOT254
		LJMP	IS254
NOT254:		CJNE A,#255,NOT255
		LJMP	IS255
NOT255:		NOP
		CJNE A,#1,NOT_SPECIAL_CASE
		LJMP SPECIAL_CASE
NOT_SPECIAL_CASE:MOV 7,A
		CLR A

		MOV 5,7 ; FİNAL PHİ İN R5
		MOV DPTR,#LOOKUP-1
		BACK: INC DPTR
		MOVC A,@A+DPTR ; A HAS the first prime
		CJNE A,7,XXX
		SJMP A_GREAT_R7
		XXX:JNC A_GREAT_R7
		MOV B,A
		MOV R6,A ;PRİME R6 DA
		MOV A,R7
		DIV AB
		MOV A,B
		JNZ MOVE
		
		MOV A,R5
		MOV B,R6
		DIV AB
		DEC 6
		MOV B,R6
		MUL AB
		MOV R5,A
MOVE:		MOV A,#0
		SJMP BACK
A_GREAT_R7:	MOV A,R5
		MOV B,#10
		DIV AB	;	divide by 100
		XCH A,B
		ADD A,#30H
		MOV R0,A; 	ONES 		IN ASCII
		XCH A,B
		MOV B,#10 
		DIV AB ;	divide by 10
		ADD A,#30H
		MOV R1,A;	HUNDREDS	IN ASCII
		XCH A,B 
		ADD A,#30H
		MOV R2,A	;TENS		IN ASCII
AGAIN2:		ACALL KEYBOARD
		CJNE A,#44H,AGAIN2 ; TAKE INPUT UNTIL INPUT IS D(44H)
		SJMP SKIP2
SKIP2:		MOV A,#29H
		ACALL SEND_DATA
		MOV A,#0C0H
		ACALL SEND_COMMAND
		MOV A,#3DH	; =========
		ACALL SEND_DATA		
		MOV A,R1
		JZ DEVAM
		ACALL SEND_DATA
DEVAM:		MOV A,R2
		JZ DEVAM1
		ACALL SEND_DATA
DEVAM1:		MOV A,R0
		ACALL SEND_DATA
		ACALL KEYBOARD
		PUSH ACC
		ACALL CONFIGURE_LCD
		LJMP BACK1


SPECIAL_CASE:	MOV R0,#31H	;ONES
		MOV R1,#30H	;HUNDREDS
		MOV R2,#30H	;TENS
		LJMP AGAIN2
IS252:		MOV R0,#32H
		MOV R1,#30H
		MOV R2,#37H
		LJMP AGAIN2
IS253:		MOV R0,#30H
		MOV R1,#32H
		MOV R2,#32H
		LJMP AGAIN2
IS254:		MOV R0,#36H
		MOV R1,#31H
		MOV R2,#32H
		LJMP AGAIN2
IS255:		MOV R0,#38H
		MOV R1,#31H
		MOV R2,#32H
		LJMP AGAIN2

HERE:		SUBB A,#30H
		MOV R3,A
		LJMP BACKKK



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









LOOKUP: DB 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151,157, 163 ,167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241,251
END

