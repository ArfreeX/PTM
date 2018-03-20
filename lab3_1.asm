TIME	EQU		50	
LOAD	EQU		(65536 - 1000*TIME)
	
ORG 0

;-----------------------------------------------------------------------------------
; Procedura opozniajaca z wykorzystaniem timera
;-----------------------------------------------------------------------------------
delay:
	MOV R0, #20 					;licznik petli, 20, bo 20*50ms daje sekunde
	CLR TR0							;wylacz timer
	MOV TMOD, #00000001B			;ustawienie trybu timera na 16 bit 
	LCALL loop
	
loop: 								;jedno przejscie petli odmierza 50 ms
	MOV TH0,#HIGH(LOAD) 			;ladowanie starszych i mlodszych bitow 
    MOV TL0,#LOW(LOAD)  		;zmiennej LADUJ zawierajacej liczbe cykli
	CLR TF0							;zeruj przepelnienie
	SETB TR0						;wlacz timer
	JNB TF0, $ 						;odliczaj, poki nie ma przepelnienia
	DJNZ R0, loop					;idz do loop1, poki R0 != 0
	
	RET

;-----------------------------------------------------------------------------------
; Procedura z wykorzystaniem przerwan
;-----------------------------------------------------------------------------------

		LCALL	init_timer
		SJMP	$
ORG 0BH			;blok obslugi mechanizmu przerwan, musi startowac 				;pod adresem 0BH
	MOV TH0,#HIGH(LOAD) ;ladowanie starszych i mlodszych bitow 
    	MOV TL0,#LOW(LOAD)  ; zmiennej LADUJ zawierajacej liczbe cykli
	CPL P1.7		;negacja bitu w celu zapalania i gaszenia diody
	RETI			;wyjscie z bloku obslugi przerwania

init_timer:			;procedura inicjujaca timer
	CLR	TR0			;wylaczenie timera
	MOV	TMOD, #00000001B	;ustawienie trybu timera na 16 bit
	MOV	TH0,#HIGH(LOAD) 	
    	MOV	TL0,#LOW(LOAD)  
	CLR	TF0		;zeruj przepelnienie
	SETB	ET0		;ustawienie przerwania timera 0
	SETB	EA		;wlaczenie ukladu przerwan
	SETB	TR0		;wlaczenie timera
	
	RET			;wyjscie z procedury

END