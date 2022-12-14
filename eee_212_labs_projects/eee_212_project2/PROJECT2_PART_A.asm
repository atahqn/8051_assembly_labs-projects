;PROJECT2--GRADIENT DESCENT--
;STORE TRUE VALUES A=-3,B=2 IN REGISTERS 40H,41H
ORG 0000
MOV 6,#08H	;      GIVING 07H FOR COMPARISON REASONS
MOV A,#0FDH		;A=-3
ACALL LOOKFORD3
MOV 40H,A
MOV 4,A
MOV A,#02H		;B=2
ACALL LOOKFORD3
MOV 41H,A
MOV 5,A
;INITIAL ESTIMES A1,B1 WILL STORE IN 42H,43H
INC 0	;R0=42H
MOV A,#0FAH		;Ai=0FEH=-2
ACALL LOOKFORD3
MOV 42H,A
MOV 7,A
MOV A,#0FFH		;Bi=4
ACALL LOOKFORD3
MOV 43H,A
MOV 2,A
CLR A
;ASSUME i=1
QUERY:
CLR C
MOV A,20H
MOV DPTR,#LOOKUP1
MOVC A,@A+DPTR	;TAKING Xi VALUE-- THIS CASE X1
ACALL LOOKFORD3
;MOV A,#0F8H	;Xi=6
MOV 3,A		;Xi IS IN R3
;CALCULATING TRUE VALUE  Yi=a+b*Xi
MOV R0,#45H
MOV R1,#44H
ACALL FIND_TRUE_VALUE
;HERE:SJMP HERE
LJMP ESTIMATE
ESTIMATE:CLR C
CLR A
MOV R0,#47H
MOV R1,#46H
MOV 5,2
MOV 4,7
ACALL FIND_TRUE_VALUE
;HERE:SJMP HERE
ACALL GRADFORA
;HERE:SJMP HERE
ACALL GRADFORB
;HERE:SJMP HERE
INC 20H
MOV A,40H
CJNE A,42H,QUERY1				;COMPARING A,B AND Ai,Bi TO CONTINUE OR STOP
CLR C
CLR A
MOV A,41H
CJNE A,43H,QUERY1
HERE:SJMP HERE

QUERY1: 
	MOV 5,41H
	MOV 4,40H
	LJMP QUERY
;HERE: SJMP HERE
			;IF NEGATIVE GIVE 44H VALUE 1

FIND_TRUE_VALUE:
CJNE R3,#0,Xi_NOT_ZERO	;CHECKING WHETHER Xi IS ZERO OR NOT
LJMP Xi_IS_ZERO
;X IS NOT ZERO LETS FIND OUT WHETHER IT IS NEGATIVE OR POSITIVE
Xi_NOT_ZERO:
MOV A,3		;Xi IS IN ACC
CJNE A,6,$+3
JNC Xi_NEGATIVE
CLR C
MOV 18H,#0
;NOW WE KNOW Xi IS POSITIVE, LETS FIND OUT WHICH IS B
CJNE R5,#0,B_NOT_ZERO	;CHECKING WHETHER B IS ZERO OR NOT
LJMP B_ZERO
B_NOT_ZERO:; B IS NOT ZERO LETS FIND OUT WHETHER IT IS NEGATIVE OR POSITIVE
MOV A,5
CJNE A,6,$+3
JNC B_IS_NEGATIVE1
CLR C
;CONTINUING AS B NOT NEGATIVE AND NOT ZERO
;WE ALSO KNOW Xi IS NOT ZERO AND POSITIVE
MOV A,3	; Xi IS IN ACC
MOV B,5 ;B IS IN B REGISTER
MUL AB
;NOW WE KNOW Xi*B, WE NEED TO FIND A 
XCH A,B ; Xi*B RESULT IS IN B REGISTER
MOV A,4	; A IS ON ACC
CJNE A,6,$+3
JNC A_IS_NEGATIVE1
; NOW WE KNOW A IS ZERO OR POSITIVE WE CAN SIMPLY ADD TO RESULT
ADD A,B	;Xi*B+A TRUE VALUE			A>0,,,,,,,B>0,,,,,Xi>0	ALWAYS POSITIVE
DEC 0
MOV @R0,#0
INC 0
MOV @R0,A	;MOVING TRUE RESULT TO 45H REGISTER    47
RET 	;RETURN TO BEGINNING
;-------------------------------------------------------------------------------------
;-----------------------------------------------
B_IS_NEGATIVE1: AJMP B_IS_NEGATIVE
;-----------------------------------------------
A_IS_NEGATIVE1: AJMP A_IS_NEGATIVE
;-------------------------------------------------------------------------------------
Xi_NEGATIVE:	;WE KNOW Xi IS NEGATIVE LETS SEE WHETHER B IS POSITIVE OR NEGATIVE
MOV 18H,#1
CJNE R5,#0,NXi_B_NOT_ZERO	;CHECKING WHETHER B IS ZERO OR NOT
LJMP B_ZERO
NXi_B_NOT_ZERO:; B IS NOT ZERO LETS FIND OUT WHETHER IT IS NEGATIVE OR POSITIVE
MOV A,5
CJNE A,6,$+3
JNC NXi_B_IS_NEGATIVE1
CLR C				; X<0, B>0
;NOW WE KNOW B IS POSITIVE AND NOT ZERO
MOV A,3 ; Xi IS IN ACC
LCALL SIGNED_CONVERSION
MOV B,5 ; B IS IN B REGISTER
MUL AB	; -RESULT IS IN ACC
;NOW WE KNOW Xi*B, WE NEED TO FIND A
XCH A,B ; Xi*B RESULT IS IN B REGISTER
MOV A,4	; A IS ON ACC
PUSH ACC	;SAVING VALUE A INCASE WE NEED IT
CJNE A,6,$+3
JNC NXi_A_IS_NEGATIVE
CLR C			; X<0,B>0,A>0
; NOW WE KNOW A IS ZERO OR POSITIVE WE SHOULD DECREASE THIS VALUE FROM RESULT BECAUSE WE HAVE (-)RESULT
;IF NOT ZERO MOVE ON
CHECK: CJNE A,B,$+3
JNC POSRES2	;A>=B
CLR C		;A<B
XCH A,B
SUBB A,B
MOV @R1,#1
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUA A VALUE R4 AGAIN
RET		;RETURN TO BEGINNING

POSRES2:
SUBB A,B
DEC 0
MOV @R0,#0
INC 0
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUA A VALUE R4 AGAIN
RET		;RETURN TO BEGINNING

NXi_A_IS_NEGATIVE:				; X<0, B>0,X<0
ACALL SIGNED_CONVERSION
ADD A,B
MOV @R1,#1
MOV @R0,A
POP ACC
MOV 4,A
RET
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
SUBTRACT0: DEC B
DJNZ 4,SUBTRACT0
XCH A,B ;X??*B IS IN ACC
SJMP NXi_A_is_Positive
;NOW WE HAVE OUR RESULT OF A+Xi*B
NXi_A_ZERO:	;NOW WE SHOULD STORE IT IN 45H	A=0,,,,,Xi<0,,,,,B>0    NEGATIVE
MOV @R1,#1
NXi_A_IS_POSITIVE: ;CJNE A,6,$+3
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUA A VALUE R4 AGAIN
RET		;RETURN TO BEGINNING
;----------------------------------------------------------------------------------
NXi_B_IS_NEGATIVE1: AJMP NXi_B_IS_NEGATIVE
;----------------------------------------------------------------------------------
B_IS_NEGATIVE:
; NOW WE HAVE Xi>0 AND B<0 FIRST CONVERTING B
LCALL SIGNED_CONVERSION
MOV B,3; Xi IS IN B REGISTER
MUL AB
; NOW WE HAVE Xi*B -RESULT IN ACC
XCH A,B ; Xi*B RESULT IS IN B REGISTER
MOV A,4	; A IS ON ACC
PUSH ACC	;SAVING VALUE A INCASE WE NEED IT
CJNE A,6,$+3
JNC PXi_A_IS_NEGATIVE
CLR C
; NOW WE KNOW A IS ZERO OR POSITIVE WE SHOULD DECREASE THIS VALUE FROM RESULT BECAUSE WE HAVE (-)RESULT
;IF NOT ZERO MOVE ON	X>0 B<0 A>0
CJNE A,B,$+3	;IF A>=B POSITIVE RESULT
JNC POSRES1
CLR C		;A<B
XCH A,B ;	A IS XB
SUBB A,B
MOV @R1,#1
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUE A VALUE R4 AGAIN
RET	;RETURN TO BEGINNING

POSRES1:
SUBB A,B
DEC 0
MOV @R0,#0
INC 0
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUE A VALUE R4 AGAIN
RET	;RETURN TO BEGINNING

PXi_A_IS_NEGATIVE:
LCALL SIGNED_CONVERSION
ADD A,B
MOV @R1,#1
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUE A VALUE R4 AGAIN
RET	;RETURN TO BEGINNING
;----------------------------------------------------------
NXi_B_IS_NEGATIVE:
; NOW WE HAVE Xi<0 AND B<0 FIRST CONVERTING B
LCALL SIGNED_CONVERSION
MOV B,3; Xi IS IN B REGISTER
XCH A,B	;Xi IS IN ACC
LCALL SIGNED_CONVERSION
MUL AB
; NOW WE HAVE Xi*B +RESULT IN ACC	RESULT IS POSITIVE
XCH A,B ; Xi*B RESULT IS IN B REGISTER
MOV A,4	; A IS ON ACC
PUSH ACC	;SAVING VALUE A INCASE WE NEED IT
CJNE A,6,$+3
JNC NXi_NB_A_IS_NEGATIVE ;IF A<0 THEN SUBB A
CLR C	;A >0 
; NOW WE KNOW A IS ZERO OR POSITIVE WE SHOULD SIMPLY ADD IT BECAUSE RESULT IS POSITIVE
ADD A,B	;Xi*B+A TRUE VALUE			A>=0,,,,Xi<0,,,,,B<0	ALWAYS POSITIVE
DEC 0
MOV @R0,#0
INC 0
MOV @R0,A	;MOVING TRUE RESULT TO 45H REGISTER
DEC SP
RET
;----------------------------------------------------------------
NXi_NB_A_IS_NEGATIVE:
LCALL SIGNED_CONVERSION	;MAKING A POSITIVE
XCH A,B		; A IS IN B, XB IN A
CJNE A,B,$+3	;A>=B ISE POSITIVE RESULT
JNC POSRES
CLR C	; A<B ISE NEGATIVE RESULT
XCH A,B	;A IS IN A
SUBB A,B
MOV @R1,#1
MOV @R0,A	;MOVING TRUE RESULT TO 45H REGISTER
DEC SP
RET
;---------
POSRES:
SUBB A,B
DEC 0
MOV @R0,#0
INC 0
MOV @R0,A	;MOVING TRUE RESULT TO 45H REGISTER
DEC SP
RET
;---------------------------------------------------------------
A_IS_NEGATIVE:
;NOW WE KNOW Xi>0, B>0, A<0           WE FIRST CONVERT A
ACALL SIGNED_CONVERSION
; NOW WE KNOW A IS NEGATIVE WE SHOULD DECREASE THIS VALUE FROM RESULT BECAUSE WE HAVE (+)RESULT
MOV 4,A
CJNE A,B,MOVEON
LJMP ZEROO
MOVEON:CJNE A,B,$+3	;A>=B NEGATIVE RESULT
JNC NEGRES	;A<B ISE POSITIVE RESULT
CLR C
XCH A,B ;X??*B IS IN ACC
SUBB A,B
DEC 0
MOV @R0,#0
INC 0
MOV @R0,A
POP ACC
MOV 4,A 	;GIVE TRUE A VALUE R4 AGAIN
INC SP
RET

NEGRES:
SUBB A,B
MOV @R1,#1
MOV @R0,A
POP ACC
MOV 4,A
INC SP
RET

ZEROO:
SUBB A,B
MOV @R1,#0
MOV @R0,A
POP ACC
MOV 4,A
INC SP
RET


;---------------------------------------------------------------
Xi_IS_ZERO:
B_ZERO: 		;SAME THING WHETHER B OR Xi IS ZERO RESULT IS EXACTLY A
MOV A,4	; IF B OR Xi IS ZERO RESULT IS A
CJNE A,6,$+3
JC SAVE4
LCALL SIGNED_CONVERSION
MOV @R1,#1
SAVE4:CLR C
MOV @R0,A		;			B=0 OR Xi=0,,,,,, A	DEPENDS FOR A
RET
;--------------------------------------------------------------------
GRADFORA: 		;(Y1-^Y1)>0 ise Ai+1, (Y1-^Y1)<0 ise Ai-1
;FIRST LOOK AT WHETHER POSITIVE OR NEGATIVE
DEC 1
DEC 1
MOV A,44H ; SIGN OF Y1	;44
JZ POSY1
NEGY1:		;Y1 IS NEGATIVE
INC 1
INC 1
MOV A,46H ;SIGN OF ^Y1	;46
JZ NEGY1POSEY1
NEGY1_NEGEY1:	;WE KNOW BOTH OF THEM ARE NEGATIVE WE HAVE TO COMPARE THEM
DEC 1
MOV A,45H	;45
XCH A,B
INC 1
INC 1
MOV A,@R1	;47
CJNE A,B,MOVEE
LJMP EXACT
MOVEE:JNC NEY1GTY1 	;A>B ISE NO CARRY B>A ISE CARRY
CLR C
NY1GTEY1:		;Y1 > ^Y1 THEN RESULT IS NEGATIVE DECREASE Ai
DEC 7
DEC 42H
XCH A,B
SUBB A,B
INC 1
MOV 48H,#1		;NEGATIVE SIGN	48
INC 1
MOV 49H,A			;49
DEC 1
DEC 1
DEC 1
RET
NEY1GTY1:		;^Y1 > Y1 THEN RESULT IS POSITIVE INCREASE Ai
INC 7
INC 42H
SUBB A,B
INC 1
INC 1
MOV @R1,A		;49
DEC 1
MOV 48H,#0
DEC 1
DEC 1
RET
POSY1:
INC 1
INC 1
MOV A,@R1; SIGN OF ^Y1	46
JZ POSY1POSEY1
POSY1NEGEY1:		;WE KNOW THAT Y1 IS POSITIVE AND EY1 IS NEGATIVE
INC 7			;FOR (Y1-^Y1) MUST BE POSITIVE THEREFORE INCREASE Ai
INC 42H
MOV 48H,#0
DEC 1
;DEC 1
MOV A,@R1		;WE HAVE TO CALCULATE FOR OTHER PART	45
XCH A,B
INC 1
INC 1
MOV A,@R1		;47
ADD A,B
INC 1
INC 1
MOV @R1,A		;49
DEC 1
DEC 1
DEC 1
RET
NEGY1POSEY1:		;WE KNOW THAT Y1 IS NEGATIVE AND EY1 IS POSITIVE 
DEC 7			;FOR (Y1-^Y1) MUST BE NEGATIVE THEREFORE DECREASE Ai
DEC 42H
DEC 1
MOV A,@R1		;WE HAVE TO CALCULATE FOR OTHER PART	45
XCH A,B
INC 1
INC 1
MOV A,@R1	;47
ADD A,B
INC 1
MOV @R1,#1		;BECAUSE IT IS NEGATIVE		48
INC 1
MOV @R1,A		;49
DEC 1
DEC 1
DEC 1
RET
POSY1POSEY1:		;WE BOTH OF THEM ARE POSITIVE
DEC 1
MOV A,@R1		;FOR (Y1-^Y1) WE CAN'T DECIDE WE HAVE TO CALCULATE	46
XCH A,B
INC 1
INC 1
MOV A,@R1		;48
CJNE A,B,TRY		;;CHECKING WHETHER IT IS EQUAL TO ZERO
LJMP EXACT
TRY:CJNE A,B,$+3
JNC EY1GTY1			;FOR A>B NO CARRY, B>A CARRY
CLR C				; Y1 IS GREATER THAN EY1
INC 7				; INCREASE Ai
MOV 48H,#0
INC 42H
XCH A,B
SUBB A,B
INC 1
INC 1
MOV @R1,A		;RESULT IS POSITIVE NO NEED TO SEND 1 TO 48H	49
DEC 1
DEC 1
DEC 1
RET
EY1GTY1:		; ^Y1 GREATER THAN Y1
DEC 7
DEC 42H
SUBB A,B
CLR AC
INC 1
MOV @R1,#1		;RESULT IS NEGATIVE	48
INC 1
MOV @R1,A		;49
DEC 1
DEC 1
DEC 1
RET
EXACT:			;WE HAVE TRUE VALUE OF A
INC 1
INC 1
MOV 48H,#0
MOV @R1,#0		;WE ALSO NEED TO CALCULATE RESULT FOR OTHER PART
DEC 1
DEC 1
DEC 1
RET
;-------------------------------------------------------------------------
GRADFORB:		;     X(Y1-^Y1)<0  Bi+1
			;     X(Y1-^Y1)>0  Bi-1
			; WE JUST NEED TO KNOW SIGNS OF X AND (Y1-^Y1)
			;SIGN OF X IS IN REGISTER 18H, AND Y1-^Y1 IS IN 48H
INC 0
INC 0
MOV A,@R0		;LETS LOOK AT WHETHER ONE OF THEM IS ZERO	49
DEC 0
DEC 0
JZ YZERO
MOV A,3
JZ XZERO
CLR A
MOV A,18H		;FIRST LOOKING AT Xi
JZ POSX
NEGX:
INC 0
MOV A,@R0		;NOW LOOKING AT Y1-^Y1	48
DEC 0
JZ NEGXPOSY
NEGXNEGY:		; -*- = + THEN Bi+1
INC 2
INC 43H
RET
NEGXPOSY:		; - * + = - THEN Bi-A
DEC 2
DEC 43H
RET
POSX:
INC 0
MOV A,@R0		;NOW LOOKING AT Y1-^Y1	48
DEC 0
JZ POSXPOSY
POSXNEGY:		; + * - = - THEN Bi-A
DEC 2
DEC 43H
RET
POSXPOSY:		; + * + = + THEN Bi+1
INC 2
INC 43H
RET
YZERO:
XZERO:
RET			;NO NEED TO CHANGE VALUES



SIGNED_CONVERSION: ;A IS THE SIGNED VALUE
CJNE A,#0F8H,NEXT
SJMP EIGHT
NEXT:CJNE A,#0F9H,NEXT1
SJMP SEVEN
NEXT1:CJNE A,#0FAH,NEXT2
SJMP SIX
NEXT2:CJNE A,#0FBH,NEXT3
SJMP FIVE
NEXT3:CJNE A,#0FCH,NEXT4
SJMP FOUR
NEXT4:CJNE A,#0FDH,NEXT5
SJMP THREE
NEXT5:CJNE A,#0FEH,NEXT6
SJMP TWO
NEXT6:CJNE A,#0FFH,$+3
SJMP ONE
EIGHT:MOV A,#8
RET
SEVEN:MOV A,#7
RET
SIX:MOV A,#6
RET
FIVE:MOV A,#5
RET
FOUR:MOV A,#4
RET
THREE:MOV A,#3
RET
TWO:MOV A,#2
RET
ONE:MOV A,#1
RET
CONVERSION_SIGNED:
CJNE A,#1,NEXT0
SJMP MONE
NEXT0:CJNE A,#2,NEXT10
SJMP MTWO
NEXT10:CJNE A,#3,NEXT20
SJMP MTHREE
NEXT20:CJNE A,#4,NEXT30
SJMP MFOUR
NEXT30:CJNE A,#5,NEXT40
SJMP MFIVE
NEXT40:CJNE A,#6,NEXT50
SJMP MSIX
NEXT50:CJNE A,#7,NEXT60
SJMP MSEVEN
NEXT60:CJNE A,#8,$+3
SJMP MEIGHT
MEIGHT:MOV A,#0F8H
RET
MSEVEN:MOV A,#0F9H
RET
MSIX:MOV A,#0FAH
RET
MFIVE:MOV A,#0FBH
RET
MFOUR:MOV A,#0FCH
RET
MTHREE:MOV A,#0FDH
RET
MTWO:MOV A,#0FEH
RET
MONE:MOV A,#0FFH
RET

LOOKFORD3:
	MOV C,A.3
	JC OR
	ANL A,#0FH
	RET
OR:
	ORL A,#0F0H
	RET

ORG 1000H
LOOKUP1: DB 96H, 58H, 65H, 8FH, 2BH, 41H, 4DH, 0D3H, 6DH, 73H, 40H, 62H, 8AH, 0E5H, 75H, 8FH, 3DH, 0B1H, 0DCH, 0EEH, 0C6H, 0BFH, 31H, 6AH, 0AAH, 0EEH, 0A0H, 0CFH, 0C1H, 8BH, 17H, 24H, 0B0H, 0A8H, 0CFH, 0CAH, 73H, 0DFH, 0BAH, 0E5H, 4EH, 0F7H, 0CEH, 0E3H, 5AH, 0D0H, 0C5H, 30H, 6AH, 0ABH, 86H, 0E1H, 0DBH, 0BAH, 0E0H, 86H, 0B3H, 8BH, 74H, 9CH, 4H, 0CH, 0E5H, 0C6H, 0B7H, 71H, 61H, 8H, 36H, 0FBH, 44H, 7DH, 57H, 0F6H, 0BAH, 0C2H, 56H, 1CH, 2BH, 0E0H, 25H, 0BH, 0D1H, 0E0H, 0F9H, 6BH, 27H, 67H, 33H, 49H, 10H, 0D0H, 96H, 8H, 0E5H, 0C3H, 7FH, 35H, 24H, 9FH, 0F0H, 2FH, 8DH, 0A8H, 0FBH, 0EAH, 4DH, 42H, 85H, 90H, 30H, 22H, 0EBH, 0D7H, 53H, 0C6H, 3FH, 31H, 0DEH, 8AH, 64H, 1DH, 7AH, 9H, 40H, 0AH, 0CAH, 99H, 4FH, 0F0H, 0D7H, 4DH, 76H, 0A5H, 0AEH, 0ADH, 1DH, 9EH, 0A9H, 86H, 0E3H, 0BH, 38H, 0C8H, 70H, 65H, 0A9H, 5BH, 0EBH, 0BCH, 0ABH, 79H, 39H, 0C3H, 89H, 0C5H, 76H, 1AH, 76H, 0EFH, 3EH, 7EH, 87H, 75H, 0FAH, 75H, 94H, 45H, 6FH, 6H, 0AH, 97H, 91H, 4CH, 43H, 0ECH, 0B9H, 65H, 4DH, 0FBH, 2DH, 55H, 6AH, 0D8H, 0BEH, 43H, 3BH, 21H, 5BH, 54H, 64H, 0E9H, 5AH, 0D9H, 0EDH, 7AH, 0DCH, 8H, 0B6H, 0FBH, 0F0H, 5DH, 0DDH, 4BH, 0FH, 0AH, 9DH, 1H, 0C5H, 0C9H, 0C2H, 34H, 0CCH, 0DEH, 50H, 74H, 6CH, 84H, 0D9H, 19H, 5AH, 0CH, 0A5H, 0C6H, 0EDH, 61H, 0A4H, 0D6H, 6CH, 1FH, 0A1H, 73H, 0A0H, 62H, 49H, 5DH, 58H, 83H, 0FFH, 6FH, 80H, 7AH, 0A4H, 0C8H, 0DCH, 85H, 3EH, 0H, 37H, 98H, 0FDH, 0A1H, 0B2H, 0C8H, 0CDH, 6DH, 69H, 50H, 0FDH, 44H, 7AH, 4FH, 30H, 0D7H, 0A3H, 46H, 0EAH, 0CDH, 42H, 31H, 0B0H, 0BAH, 9FH, 5EH, 1FH, 98H, 0DBH, 0D1H, 18H, 39H, 0B5H, 79H, 23H, 0D3H, 16H, 0BH, 0E9H, 20H, 0C9H, 5H, 2CH, 0E4H, 83H, 7EH, 7H, 75H, 4EH, 55H, 1EH, 0F8H, 0DAH, 0CEH, 0C1H, 8AH, 7FH, 65H, 0A4H, 0D3H, 0A4H, 5BH, 0E4H, 0E4H, 66H, 0B6H, 80H, 88H, 0F4H, 9FH, 8H, 0EFH, 53H, 0F6H, 0BFH, 0AH, 12H, 59H, 0BCH, 26H, 0F1H, 0C2H, 4H, 4CH, 0E5H, 9CH, 0A7H, 0B4H, 0BFH, 52H, 0D2H, 1EH, 4AH, 8AH, 0C3H, 5H, 25H, 0CCH, 0C9H, 0C8H, 0A4H, 45H, 54H, 7EH, 0F9H, 0C5H, 17H, 72H, 40H, 63H, 0E2H, 0A4H, 61H, 0F4H, 56H, 20H, 4BH, 0D5H, 1AH, 0ECH, 0FFH, 15H, 90H, 92H, 0F2H, 0F0H, 57H, 4DH, 0C2H, 85H, 24H, 10H, 0A8H, 56H, 62H, 9BH, 0DH, 22H, 0DFH, 0F7H, 6DH, 5BH, 0H, 44H, 0A0H, 5FH, 41H, 29H, 73H, 1FH, 0BAH, 0BH, 7EH, 0B8H, 0ADH, 0CH, 76H, 0FEH, 0D6H, 29H, 0D7H, 0BFH, 26H, 0F2H, 7AH, 0C7H, 70H, 68H, 21H, 14H, 0CH, 0F3H, 36H, 26H, 4CH, 0CAH, 0C4H, 47H, 0F3H, 64H, 76H, 82H, 0B6H, 46H, 0F8H, 9DH, 0D6H, 5DH, 0F7H, 0DBH, 0ABH, 8H, 0D1H, 0E3H, 41H, 0A8H, 1BH, 0EAH, 8EH, 0FAH, 0A8H, 9CH, 0F2H, 0FCH, 0B7H, 43H, 31H, 0B1H, 0D2H, 0DEH, 4AH, 64H, 0F3H, 4AH, 46H, 23H, 0E5H, 0E6H, 0B7H, 5CH, 0E9H, 6AH, 59H, 0D6H, 0B6H, 0FH, 0D0H, 8DH, 70H, 3BH, 19H, 9BH, 64H, 0AH, 0E2H, 0D9H, 69H, 0DAH, 6DH, 79H, 0D0H, 0EBH, 0H, 0CBH, 0F8H, 26H, 0AEH, 1AH, 85H, 0D7H, 28H, 0BEH, 96H, 73H, 9DH, 6AH, 3DH, 76H, 0C4H, 0C6H, 9BH, 91H, 42H, 73H, 60H, 62H, 0A7H, 6DH, 17H, 0E0H, 10H, 43H, 0AEH, 69H, 0BDH, 75H, 0C8H, 25H, 2DH, 0A1H, 4AH, 8H, 13H, 33H, 2DH, 0B0H, 0A2H, 5FH, 43H, 0F9H, 0F1H, 37H, 4CH, 0DDH, 5CH, 97H, 0DAH, 0B4H, 0D1H, 62H, 29H, 5DH, 2FH, 1BH, 58H, 0DEH, 0F7H, 6CH, 33H, 41H, 50H, 0DBH, 34H, 0D0H, 0BEH, 48H, 0C3H, 0E9H, 0C5H, 1H, 82H, 0D1H, 5EH, 49H

LOOKUP2: DB 68H, 10H, 0FCH, 76H, 2BH, 9EH, 95H, 0E6H, 0D6H, 34H, 0DFH, 0E6H, 85H, 0CH, 50H, 8EH, 7CH, 0D8H, 0AFH, 0ABH, 6CH, 71H, 91H, 88H, 0E3H, 7H, 0D8H, 0C6H, 83H, 51H, 5FH, 95H, 9H, 8EH, 3AH, 0A8H, 72H, 0C2H, 0B3H, 0D4H, 0ACH, 1DH, 9FH, 0C1H, 0C7H, 0F7H, 70H, 53H, 59H, 0E7H, 5EH, 75H, 8H, 25H, 0C3H, 91H, 5H, 6BH, 0FCH, 1FH, 3H, 0A3H, 0BBH, 0E2H, 57H, 59H, 0E2H, 96H, 31H, 4DH, 0B2H, 5H, 45H, 0CCH, 0BEH, 50H, 3H, 0F4H, 23H, 68H, 6EH, 4CH, 9BH, 2CH, 4AH, 0B3H, 6BH, 74H, 5FH, 0BCH, 21H, 0E9H, 4H, 69H, 2DH, 0F5H, 6AH, 41H, 16H, 0ABH, 0E9H, 0B9H, 61H, 0EDH, 0FEH, 7CH, 0B9H, 0C7H, 9DH, 0E0H, 0ADH, 4BH, 6EH, 62H, 0ABH, 8DH, 19H, 13H, 24H, 0B5H, 60H, 8BH, 8FH, 0E4H, 19H, 6EH, 2CH, 9BH, 5BH, 0D2H, 14H, 0DAH, 3H, 49H, 2BH, 0A8H, 65H, 5AH, 63H, 0FDH, 7CH, 0BAH, 7FH, 5EH, 0DCH, 20H, 0F6H, 0DDH, 0DAH, 0E7H, 0E9H, 0EDH, 41H, 0A4H, 0FBH, 0E4H, 7DH, 0CEH, 5EH, 52H, 10H, 0CEH, 26H, 92H, 7AH, 0B0H, 0E8H, 0CFH, 90H, 63H, 1AH, 64H, 0BFH, 0AAH, 12H, 0C0H, 14H, 0CEH, 23H, 5AH, 3EH, 0F5H, 7FH, 9H, 44H, 0AAH, 0CFH, 0C8H, 0A3H, 5DH, 92H, 13H, 98H, 0D5H, 0E1H, 94H, 0E2H, 77H, 59H, 0CFH, 1EH, 53H, 22H, 9FH, 0F7H, 37H, 4BH, 0C5H, 9AH, 0FAH, 0BBH, 0A4H, 27H, 84H, 8BH, 49H, 94H, 70H, 27H, 79H, 83H, 0D3H, 8FH, 0A3H, 1H, 0F2H, 51H, 3FH, 95H, 7EH, 16H, 9DH, 19H, 5H, 0D4H, 24H, 5DH, 20H, 43H, 95H, 11H, 4EH, 27H, 4EH, 1BH, 2EH, 2EH, 11H, 0C9H, 3FH, 3CH, 56H, 0C5H, 83H, 52H, 0E7H, 56H, 35H, 3H, 87H, 1BH, 0CAH, 8EH, 0D7H, 20H, 0FEH, 9DH, 0D1H, 45H, 31H, 0B6H, 0CAH, 18H, 27H, 5H, 0E3H, 0BCH, 0A0H, 81H, 0F1H, 5DH, 0DCH, 23H, 4EH, 1EH, 0E6H, 6AH, 54H, 5EH, 0F9H, 0E8H, 9FH, 10H, 2FH, 4EH, 10H, 0D6H, 0E6H, 8FH, 9CH, 0D9H, 4H, 52H, 55H, 6H, 38H, 0C7H, 28H, 0A8H, 66H, 0E2H, 0A0H, 0C1H, 0F1H, 7H, 0CCH, 0E6H, 90H, 44H, 2H, 8FH, 5AH, 0A9H, 6DH, 1BH, 0H, 1EH, 0B0H, 9AH, 9FH, 73H, 97H, 0FAH, 0B4H, 0FCH, 0EAH, 4BH, 32H, 2H, 0E9H, 2AH, 59H, 8CH, 0A6H, 0CAH, 0EH, 0D7H, 94H, 0DEH, 17H, 6CH, 0F0H, 0F9H, 7DH, 0D7H, 0F6H, 0EH, 0E2H, 0DCH, 0A1H, 9EH, 28H, 0EEH, 16H, 3FH, 0C9H, 1EH, 54H, 3AH, 59H, 9AH, 56H, 5BH, 33H, 7CH, 58H, 0AFH, 1FH, 4CH, 0FBH, 2CH, 3DH, 2BH, 0CCH, 0C5H, 28H, 0AAH, 0B6H, 60H, 88H, 37H, 27H, 25H, 0E3H, 91H, 28H, 0E3H, 9EH, 70H, 2EH, 51H, 0C9H, 65H, 2CH, 93H, 1BH, 0D9H, 0B6H, 2H, 58H, 0C2H, 97H, 74H, 84H, 0C4H, 11H, 3H, 0AFH, 5BH, 0ECH, 0A4H, 6DH, 14H, 58H, 0D3H, 7FH, 23H, 0D4H

END
