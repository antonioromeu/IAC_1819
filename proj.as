; 						António Romeu 92427, Francisco Lisboa 92464, grupo 20            
;						-----------------------------------------------------

;									+--------------------+
;									| Zona de constantes |
;									+--------------------+

IO_READ 	EQU FFFFh
IO_WRITE 	EQU FFFEh
IO_STATE 	EQU FFFDh
IO_CONTROL 	EQU FFFCh
SP_INI      EQU FDFFh
TIMER_COUNT EQU FFF6h
TIMER_CTRL  EQU FFF7h
LIMITE_X	EQU 80
LIMITE_Y	EQU FFh
NBR_MILISEC	EQU 1
INT_MASK    EQU 8000h
vinic       EQU 50
meiograv    EQU 04e6h
ang         EQU 25

;									+--------------------+
;									| Zona de variáveis  |
;									+--------------------+
            
			ORIG  FE0Fh ; Interrupções
int15       WORD  TIMER ; Temporizador

ORIG 		8000h
tempo       WORD 0000h
actualiza 	WORD 0000h
posicao		WORD 1700h
posicaox	WORD 0000h
posicaoy	WORD 0000h
ecra_ini1	STR '------------GORILAS-------------'
linech1		WORD 10
ecra_ini2	STR 'Antonio Romeu & Francisco Lisboa'
linech2		WORD 10
ecra_ini3	STR '  Press any key to continue...  '


;									+--------------------+
;									| Programa Principal |
;									+--------------------+
 
ORIG		0000h
            MOV R7, SP_INI
            MOV SP, R7
			MOV R1, INT_MASK
            MOV M[FFFAh], R1
            MOV R1, NBR_MILISEC			
            MOV M[TIMER_COUNT], R1
			CALL PROMPT_INI			; Aguarda input do utilizador
			MOV R7, FFFFh
			MOV M[IO_CONTROL], R7
            MOV R1, 1
            MOV M[TIMER_CTRL], R1	; Inicializa o temporizador
			ENI			
UPDATE:		MOV R2, 32			  ; Apaga a ultima instancia do projetil
			MOV M[IO_WRITE], R2
			MOV R7, M[posicao]
			MOV M[IO_CONTROL], R7
			MOV R7, ';' 
			MOV M[IO_WRITE], R7
			MOV R7, M[posicaox]
			CMP R7, LIMITE_X		; Verifica se o projetil ja saiu da janela(pela direita)
			BR.NP CHECK
			MOV M[tempo], R0
CHECK:		CMP R0, M[actualiza]
			BR.Z CHECK
			CALL ACT_TERM
            BR UPDATE

;									+--------------------+
;									|    Temporizador    |
;									+--------------------+
			
TIMER:      PUSH R7
			MOV R7, 5
			ADD M[tempo], R7
            INC M[actualiza]
			MOV R7, NBR_MILISEC
            MOV M[TIMER_COUNT], R7
            POP R7
			RTI
			
;									+--------------------+
;									|  Zona de funções   |
;									+--------------------+

; PROMPT_INI: escreve o ecra inicial e aguarda o input do jogador
;
PROMPT_INI:	PUSH R1
			PUSH R2
			PUSH R3
			MOV R1, ecra_ini1
REPETE:		MOV R2, M[R1]
			MOV M[IO_WRITE], R2
			INC R1
			INC R3
			CMP R3, 97
			BR.NZ REPETE
START_GAME:	CMP M[IO_STATE], R0
			BR.Z START_GAME
			POP R3
			POP R2
			POP R1
			RET

; ACT_TERM: atualiza a posiçao do projetil
;				Entradas: variaveis - angulo, tempo, velocidade inicial
ACT_TERM:	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R0
            PUSH vinic
            PUSH M[tempo]
            PUSH ang
            CALL POSX
            POP R1
			PUSH R0
            PUSH vinic
            PUSH M[tempo]
            PUSH ang
            CALL POSY
            POP R2
			MOV M[posicaox], R1
			SHR M[posicaox], 8
			MOV M[posicaoy], R2
			SHR M[posicaoy], 8
			MOV R3, 1700h	; Inverter o y 
			SUB R3, R2
			SHR R1, 8
			MVBL R3, R1
			MOV M[posicao], R3
			DEC M[actualiza]
			MOV R1, 1
			MOV M[TIMER_CTRL], R1
			POP R3
			POP R2
			POP R1
			RET
			
; POSY:	obtem o valor da coordenada y, evocando o sen e o compact
;				Entradas:	pilha - angulo, tempo, velocidade inicial
POSY:       PUSH R1
            PUSH R2
            PUSH R3
            MOV R1, M [SP + 5]
            MOV R2, M [SP + 6]
            MOV R3, M [SP + 7]
            PUSH R0
            PUSH R1
            CALL SEN
            POP R1
            SHL R3, 8
            MUL R1, R2
            PUSH R1
            PUSH R2
            CALL COMPACT
            POP R2
            POP R1
            MUL R2, R3
            PUSH R2
            PUSH R3
            CALL COMPACT
            POP R3
            POP R2
            MOV R1, meiograv
            MOV R2, M [SP + 6]
            PUSH R0
            PUSH R2
            PUSH 200h
            CALL EXP
            POP R2
            MUL R1, R2
            PUSH R1
            PUSH R2
            CALL COMPACT
            POP R2
            POP R1
            SUB R3, R2
            MOV M[SP + 8], R3
            POP R3
            POP R2
            POP R1
            RETN 3

			
; POSX:	obtem o valor da coordenada x, evocando o cos e o compact
;				Entradas:	pilha - angulo, tempo, velocidade inicial
POSX:       PUSH R1
            PUSH R2
            PUSH R3
            MOV R1, M [SP + 5]
            MOV R2, M [SP + 6]
            MOV R3, M [SP + 7]
            PUSH R0
            PUSH R1
            CALL COS
            POP R1
            SHL R3, 8
            MUL R1, R2
            PUSH R1
            PUSH R2
            CALL COMPACT
            POP R2
            POP R1
            MUL R2, R3
            PUSH R2
            PUSH R3
            CALL COMPACT
            POP R3
            POP R2
            MOV M[SP + 8], R3
            POP R3
            POP R2
            POP R1
            RETN 3

			
; SEN:	obtem o sen do angulo dado, atraves do cos
;				Entradas:	pilha - angulo
SEN:        PUSH R1
            PUSH R2
            MOV R1, M[SP + 4]
            MOV R2, 5ah
            SUB R2, R1
            PUSH R0
            PUSH R2
            CALL COS
            POP R1
            MOV M[SP + 5], R1
            POP R2
            POP R1
            RETN 1

			
; COS:	obtem o cos do angulo dado, evocando rad, exp e fact
;				Entradas:	pilha - angulo
COS:        PUSH R1
            PUSH R2
            PUSH R3
            PUSH R4
            MOV R1, M[SP + 6]
            SHL R1, 8
            PUSH R1
            CALL RAD
            POP R2
            MOV R1, 0100h
            MOV R4, 2
            PUSH R0
            PUSH R2
            PUSH 200h
            CALL EXP
            POP R3
            DIV R3, R4
            SUB R1, R3
            MOV R4, 4
            PUSH R0
            PUSH R2
            PUSH 400h
            CALL EXP
            POP R3
            PUSH R0
            PUSH 0400h
            CALL FACT
            POP R4
            SHR R4, 8
            DIV R3, R4
            ADD R1, R3
            MOV M[SP + 7], R1
            POP R4
            POP R3
            POP R2
            POP R1
            RETN 1

			
; RAD:	transforma o angulo em graus para radianos, atraves do chamamento de compact
;				Entradas:	pilha - angulo
RAD:        PUSH R1
            PUSH R2
            PUSH R3
            MOV R1, M[SP + 5]
            MOV R2, 0324h
            MOV R3, 04h
            DIV R1, R3
            MUL R2, R1
            PUSH R2
            PUSH R1
            CALL COMPACT
            POP R1
            POP R2
            MOV R3, 05h
            DIV R1, R3
            MOV R3, 09h
            DIV R1, R3
            MOV M[SP + 5], R1
            POP R3
            POP R2
            POP R1
            RET

			
; FACT:	aplica o factorial a um determinado numero, chama compact
;				Entradas:	pilha - n
FACT:       PUSH R1
            PUSH R2
            PUSH R3
            MOV R1, M[SP + 5]
            MOV R2, 100h

COMP_FACT:  CMP R1, R0
            BR.Z FIM_FACT
            MOV R3, R1
            MUL R3, R2
            PUSH R3
            PUSH R2
            CALL COMPACT
            POP R2
            POP R3
            SUB R1, 0100h
            BR COMP_FACT

FIM_FACT:   MOV M[SP + 6], R2
            POP R3
            POP R2
            POP R1
            RETN 1

			
; COMPACT:	faz a alteracao da posicao da virgula fixa
;				Entradas:	pilha - n
COMPACT:    PUSH R1
            PUSH R2
            MOV R1, M[SP + 5]
            MOV R2, M[SP + 4]
            MVBL R2, R1
			ROR R2, 8
            MOV M[SP + 4], R2
            MOV M[SP + 5], R1
            POP R2
            POP R1
            RET

			
; EXP:	calcula a exponencial do valor dado
;				Entradas:	pilha - n
EXP:        PUSH R1
            PUSH R2
            PUSH R3
            PUSH R4
            MOV R1, M[SP + 6]
            MOV R2, M[SP + 7]
            MOV R4, 100h

COMP_EXP:   CMP R1, R0
            BR.Z FIM_EXP
            MOV R3, R2
            MUL R3, R4
            PUSH R3 
            PUSH R4
            CALL COMPACT
            POP R4
            POP R3
            SUB R1, 100h
            BR COMP_EXP

FIM_EXP:    MOV M[SP + 8], R4
            POP R4
            POP R3
            POP R2
            POP R1
            RETN 2