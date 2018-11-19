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
INT_MASK    EQU 87FFh
FINAL_STR   EQU 0080h
meiograv    EQU 04e6h


;									+--------------------+
;									|Zona de interrupcoes|
;									+--------------------+

			ORIG FE00h
int00       WORD TEC_0
int01       WORD TEC_1
int02       WORD TEC_2
int03       WORD TEC_3
int04       WORD TEC_4 
int05       WORD TEC_5
int06       WORD TEC_6
int07       WORD TEC_7
int08       WORD TEC_8
int09       WORD TEC_9
int_enter   WORD ENTER

            ORIG FE0Fh
int15       WORD TIMER

;									+--------------------+
;									|  Zona de variáveis |
;									+--------------------+

            ORIG 8000h
tempo       WORD 0000h
vinic       WORD 0000h
ang         WORD 0000h
actualiza 	WORD 0000h
posicao		WORD 1700h
posicaox	WORD 0000h
posicaoy	WORD 0000h
numero      WORD 1000h
ecra_ini	STR '------------GORILAS-------------@'
ecra_ini2	STR 'Antonio Romeu & Francisco Lisboa@'
ecra_ini3	STR '  Press any key to continue...  '
fim_ini     WORD FINAL_STR
vel_str 	STR 'Velocidade:                    @'
ang_str 	STR 'Angulo:                        '
fim_input   WORD FINAL_STR


;									+--------------------+
;									| Programa Principal |
;									+--------------------+

            ORIG 0000h
            ENI
            MOV R7, SP_INI
            MOV SP, R7
			MOV R1, INT_MASK
            MOV M[FFFAh], R1        ; Habilita as interrupcoes
            MOV R1, NBR_MILISEC
            MOV M[TIMER_COUNT], R1
			MOV R7, FFFFh
			MOV M[IO_CONTROL], R7   ; Inicializa o terminal            
            PUSH ecra_ini
            PUSH 0918h              ; Posiçao inicial da string
            CALL ESCREVE
INIC:       CMP R0, M[actualiza]
            BR.Z INIC
            MOV M[actualiza], R0
            PUSH ecra_ini
            PUSH 0918h
            CALL APAGA
            PUSH vel_str
            PUSH 0000h
            CALL ESCREVE
            PUSH R0
            PUSH 000dh
            CALL REC_VAL
            POP M[vinic]
            PUSH R0
            PUSH 0109h
            CALL REC_VAL
            POP M[ang]
            PUSH vel_str
            PUSH 0000h
            CALL APAGA
            CALL VOO
            JMP INIC
            BR -1


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
;									| Zona de interações |
;									+--------------------+

; Relaciona as "teclas" com o respetivo numero (ex: a TEC_O corresponde o numero 0 e assim sucessivamente)
TEC_0:      MOV M[numero], R0
            RTI

TEC_1:      PUSH R1
            MOV R1, 1
            JMP MOVER

TEC_2:      PUSH R1
            MOV R1, 2
            JMP MOVER

TEC_3:      PUSH R1
            MOV R1, 3
            JMP MOVER

TEC_4:      PUSH R1
            MOV R1, 4
            JMP MOVER

TEC_5:      PUSH R1
            MOV R1, 5
            JMP MOVER

TEC_6:      PUSH R1
            MOV R1, 6
            JMP MOVER

TEC_7:      PUSH R1
            MOV R1, 7
            JMP MOVER

TEC_8:      PUSH R1
            MOV R1, 8
            JMP MOVER

TEC_9:      PUSH R1
            MOV R1, 9
            JMP MOVER

ENTER:      INC M[actualiza]
            RTI

MOVER:      MOV M[numero], R1
            POP R1
            RTI


;									+--------------------+
;									|  Zona de funções   |
;									+--------------------+

VOO:        PUSH R1
            PUSH R2
            PUSH R7
            MOV R1, 1
            MOV M[TIMER_CTRL], R1	; Inicializa o temporizador
UPDATE:	    MOV R2, 32			    ; Apaga a ultima instancia do projetil
			MOV M[IO_WRITE], R2
			MOV R7, M[posicao]
			MOV M[IO_CONTROL], R7
			MOV R7, '<'
			MOV M[IO_WRITE], R7
			MOV R7, M[posicaox]
			CMP R7, LIMITE_X		; Verifica se o projetil ja saiu da janela (pela direita)
			BR.NP CHECK
            MOV M[TIMER_CTRL], R0
            MOV M[tempo], R0
			POP R7
            POP R2
            POP R1
            RET
CHECK:		CMP R0, M[actualiza]
			BR.Z CHECK
			CALL ACT_TERM
            BR UPDATE


; REC_VAL: recebe os valores introduzidos pelo jogador
REC_VAL:    PUSH R1
            PUSH R2
VER_VAL:    MOV R2, 10
            MOV R1, M[SP + 4]
            MOV M[IO_CONTROL], R1
            CMP M[actualiza], R0
            BR.NZ DEV_VAL
            MOV R1, M[numero]
            CMP R1, 1000h
            BR.Z VER_VAL
            MUL R2, M[SP + 5]
            MOV R2, 1000h
            MOV M[numero], R2
            ADD M[SP + 5], R1
            ADD R1, 30h
            MOV M[IO_WRITE], R1
            INC M[SP + 4]
            BR VER_VAL
DEV_VAL:    MOV M[actualiza], R0
            POP R2
            POP R1
            RETN 1


; ESCREVE: escreve uma string
ESCREVE:    PUSH R1
            PUSH R2
            PUSH R3
            PUSH R4
            PUSH R5
            MOV R5, R0
            MOV R1, M[SP + 8]       ; Move para R1 o local em memoria do primeiro caracter
            MOV R2, M[SP + 7]       ; Move para R2 a posição inicial do terminal
REP_ESC:    MOV R3, M[R1]           ; Move o primeiro caracter para R3
            MOV R4, FINAL_STR
            CMP R4, R3
            BR.Z ACA_ESC
            MOV R4, '@'
            CMP R4, R3
            BR.NZ CONT_ESC
            MOV R2, M[SP + 7]
            ADD R5, 0100h
            ADD R2, R5              ; Mudar de linha
            BR NL_ESC
CONT_ESC:   MOV M[IO_CONTROL], R2
            MOV M[IO_WRITE], R3     ; Escreve no terminal as strings
            INC R2
NL_ESC:     INC R1
            BR REP_ESC
ACA_ESC:    POP R5
            POP R4
            POP R3
            POP R2
            POP R1
            RETN 2


; APAGA: apaga uma string
APAGA:      PUSH R1
            PUSH R2
            PUSH R3
            PUSH R4
            PUSH R5
            MOV R5, R0
            MOV R1, M[SP + 8]       ; Move para R1 o local em memoria do primeiro caracter
            MOV R2, M[SP + 7]       ; Move para R2 a posição inicial do terminal
REP_APA:    MOV R3, M[R1]           ; Move o primeiro caracter para R3
            MOV R4, FINAL_STR
            CMP R4, R3
            BR.Z ACA_APA
            MOV R4, '@'
            CMP R4, R3
            BR.NZ CONT_APA
            MOV R2, M[SP + 7]
            ADD R5, 0100h
            ADD R2, R5              ; Mudar de linha
            BR NL_APA 
CONT_APA:   MOV R3, ' '
            MOV M[IO_CONTROL], R2
            MOV M[IO_WRITE], R3     ; Apaga o que foi escrito anteriormente com a funcao ESCREVE
            INC R2
NL_APA:     INC R1
            BR REP_APA
ACA_APA:    POP R5
            POP R4
            POP R3
            POP R2
            POP R1
            RETN 2


; ACT_TERM: atualiza a posiçao do projetil
;			    Entradas: variaveis - angulo, tempo, velocidade inicial
ACT_TERM:	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R0
            PUSH M[vinic]
            PUSH M[tempo]
            PUSH M[ang]
            CALL POSX
            POP R1
			PUSH R0
            PUSH M[vinic]
            PUSH M[tempo]
            PUSH M[ang]
            CALL POSY
            POP R2
			MOV M[posicaox], R1
			SHR M[posicaox], 8
			MOV M[posicaoy], R2
			SHR M[posicaoy], 8
			MOV R3, 1700h	        ; Inverter o y
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