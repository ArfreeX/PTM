ORG 0
	
	LCALL xcopyx_start
;------------------------------------------------------------
; Procedura wczytuje parametry kopiowania miedzy XRAM a XRAM
;------------------------------------------------------------
xcopyx_start:
	MOV R1, #12h 		;	rejestr przechowujacy adres celu ( starsze bity )
	MOV R0, #34h 		;	rejestr przechowujacy adres celu ( mlodsze bity )
	MOV DPTR, #1564h 	;	rejestr przechowujacy adres zrodla
	MOV R2, #5   		;	rejestr trzymajacy dlugosc bloku

	LCALL xcopyx
	RET

;------------------------------------------------------------
; Procedura kopiowania miedzy XRAM a XRAM
;------------------------------------------------------------

xcopyx:
	MOVX A, @DPTR		;	do akumulatora przepisujemy wartosc wskazywana przez dptr
	INC DPTR		
	PUSH DPH			; 	wrzucenie gornej polowy adresu na stos
	PUSH DPL			; 	wrzucenie dolnej polowy adresu na stos
	
	MOV DPH, R1			; 	przepinamy adres z R1 do DPH
	MOV DPL, R0			; 	-||- z R0 do DPH
	
	MOVX @DPTR, A		; 	do nowego adresu przepisujemy wartosc z akumulatora
	INC DPTR			; 	inkrementujemy DPTR
	
	MOV R1, DPH			; 	zinkrementowane adresy przepinamy spowrotem do R1 i R0
	MOV R0, DPL			;	-||-
	
	POP DPL				; 	sciagamy ze stosu pierwotna wartosc DPL
	POP DPH				;   -||- DPH
	DJNZ R2,xcopyx	
	RET
	

;------------------------------------------------------------	
; Procedura migania diody
;------------------------------------------------------------

program:
	MOV P1, #1			;	Zapalenie diody
	MOV R7, #200		;	Opoznienie 200x10ms = 2s
	LCALL delay			;	Procedura opozniajaca
	MOV P1, #0			;	Zgaszenie diody
	MOV R7,#100			;	Opoznienie 1s
	LCALL delay			; 	-||-
	JMP program			;	zapetlenie procedury

;------------------------------------------------------------	
; Procedura opozniajaca o czas R7 x 10ms
;------------------------------------------------------------	

delay:
	MOV R1, #10			;	Licznik odpowiadajacy za powtorzenie petli step 10x, co da nam 10ms
loop:	
	MOV R0, #250		;	Licznik petli step, przy 250 uzyskamy 1000 cykli procesora czyli 1ms         
step:					;	Ponizej przedstawione cykle procesora poszczegolnych operacji
	NOP					;1
	NOP					;1
	DJNZ R0, step		;2
	DJNZ R1, loop		
	DJNZ R7, delay		;	Nalezy pamietac aby w rejestrze R7 zapisac wartosc >0, 
						;	w przeciwnym wypadku rozkaz DJNZ zdekrementuje wartosc 
	RET					;	i wykona procedure delay 257 razy R7 do FF 
					
	
;---------------------------------------------------------------
; Procedura wczytuje parametry kopiowania miedzy IRAM oraz XRAM
;---------------------------------------------------------------
icopyx_start:

	MOV R2, #5			; 	rejestr trzymajacy dlugosc bloku
	MOV R0, #30H		; 	rejestr zrodlowy
	MOV DPTR, #50H		;	rejestr docelowy
	LCALL icopyx
	RET	


;------------------------------------------------------------
; Procedura kopiowania miedzy IRAM oraz XRAM
;------------------------------------------------------------

icopyx:

	MOV A, @R0 			;	przesun wartosc zrodla do akumulatora
	MOVX @DPTR, A 		;	przesun wartosc akumulatora pod adres celu
	INC R0
	INC DPTR
	DJNZ R2,icopyx
	RET




	
;------------------------------------------------------------
; Procedura wczytuje parametry kopiowania miedzy rejestrami
;------------------------------------------------------------
copy_start:

	MOV R2, #5			; 	rejestr trzymajacy dlugosc bloku
	MOV R0, #30H		; 	rejestr zrodlowy
	MOV R1, #38H		;	rejestr docelowy
	LCALL copy
	RET	
	
;------------------------------------------------------------
; Procedura kopiujaca bloki danych
;------------------------------------------------------------

copy:
	MOV A, @R0       	;	przenosimy bloki pamieci miedzy rejestrami z wykorzystaniem akumulatora
	MOV @R1,A
	INC R0
	INC R1
	DJNZ R2,copy     	;	powtarzamy dopoki R2 przechowujace dlugosc bloku nie osiagnie 0
	RET
	
	
	
END