TIME EQU 50
CYKLE EQU (1000 * TIME)
LADUJ EQU (65536 - CYKLE)
LICZNIK EQU 60H
SEC EQU 30H
SEC_CHANGE EQU 28H
MINS EQU 40H
HOURS EQU 50H

ORG 0
	MOV SEC, #0
	MOV MINS, #0
	MOV HOURS, #0
	MOV LICZNIK, #0
	LCALL init_timer					
	JMP $

ORG 0BH
	INC LICZNIK 
	MOV TH0, #HIGH(LADUJ)
	MOV TL0, #LOW(LADUJ)

	RETI

sec_add:
	INC SEC
	CJNE SEC, #60, continue_s
	LCALL min_add
	continue_s:
	RET

min_add:
	MOV SEC, #0
	INC MINS
	CJNE MINS, #60, continue_m
	LCALL hour_add
continue_m:
	RET

min_add:
	MOV MINS, #0
	INC HOURS
	RET

;--------------------------------------------------------	
; Ustawienie przerwan dla timera 0 i odpalenie timera
;------------------------------------------------------------	
init_timer:
	CLR TR0
	ANL TMOD, #11110000B
	ORL TMOD, #00000001B 
	MOV TH0, #HIGH(LADUJ)
	MOV TL0, #LOW(LADUJ)

	CLR TF0
	SETB EA
	SETB ET0
	SETB TR0
	program:

	CJNE LICZNIK, #20, $
	MOV LICZNIK, #0
	LCALL sec_add
	CPL P1.0
	JMP program

	RET

;------------------------------------------------------------	
; Procedura opozniania R7 razy
;------------------------------------------------------------
opoznienie:
	CLR TR0
	ANL TMOD, #11110000B
	ORL TMOD, #00000001B 
	MOV TH0, #HIGH(LADUJ)
	MOV TL0, #LOW(LADUJ)

	CLR TF0
	SETB TR0
	JNB TF0, $
	DJNZ R7, opoznienie
	RET

					
;----------------------------------------------------
;procedura migania diodami co R7 za pomoca timera
;----------------------------------------------------
miganie:
	MOV P1, #0
	MOV R7, #50
	LCALL opoznienie
	MOV P1, #11111111B
	MOV R7, #100
	LCALL opoznienie
	JMP miganie
	
	
	
END