; 						Antonio Romeu 92427, Francisco Lisboa 92464, grupo 20            
;						-----------------------------------------------------

;									+--------------------+
;									| Zona de constantes |
;									+--------------------+

IO_READ 	EQU     FFFFh
IO_WRITE 	EQU     FFFEh
IO_STATE 	EQU     FFFDh
IO_CONTROL 	EQU     FFFCh
SP_INI      EQU     FDFFh
TIMER_COUNT EQU     FFF6h
TIMER_CTRL  EQU     FFF7h
LIMITE_X	EQU     004Fh
LIMITE_Y	EQU     007Eh
NBR_MILISEC	EQU     0001h
INT_MASK    EQU     87FFh
FINAL_STR   EQU     0080h
MEIOGRAV    EQU     04E6h
ANG_MAX     EQU     005Ah


;									+--------------------+
;									|Zona de interrupcoes|
;									+--------------------+


			ORIG    FE00h
int00       WORD    TEC_0
int01       WORD    TEC_1
int02       WORD    TEC_2
int03       WORD    TEC_3
int04       WORD    TEC_4 
int05       WORD    TEC_5
int06       WORD    TEC_6
int07       WORD    TEC_7
int08       WORD    TEC_8
int09       WORD    TEC_9
int_enter   WORD    ENTER

            ORIG    FE0Fh
int15       WORD    TIMER


;									+--------------------+
;									|  Zona de variaveis |
;									+--------------------+


            ORIG    8000h
tempo       WORD    0000h
vinic       WORD    0000h
ang         WORD    0000h
actualiza 	WORD    0000h
posicao		WORD    1700h
posicaox	WORD    0000h
posicaoy	WORD    0000h
numero      WORD    1000h
random      WORD    0000h
posi_ban    WORD    0000h
pos_mac2    WORD    0000h
score       WORD    0000h
ecra_ini	STR     '------------GORILLAS------------@'
ecra_ini2	STR     '      Score 3 points to win     @'
ecra_ini3	STR     '     Press IA to continue...     '
fim_ini     WORD    FINAL_STR
vel_str 	STR     'Velocity:                       @'
ang_str 	STR     'Angle:                          @'
pont_str    STR     'Score:                           '
fim_pont    WORD    FINAL_STR
mac_str1 	STR     ' o/@'
mac_str2 	STR     ' U @'
mac_str3    STR     '/ \@'
chao_str1   STR     '---@'
paredes_str STR     '| |@'
chao_str2   STR     '---'
fim_mac1    WORD    FINAL_STR
mac2_str    STR     '\o @'
fim_mac2    WORD    FINAL_STR
ecra_vic    STR     '             You Won            @'
ecra_vic2	STR     '     Press IA to restart...      '
fim_ec      WORD    FINAL_STR
ecra_erro	STR     'Angle has to be between 0 and 90@'
ecra_erro2	STR     '     Press IA to restart...      '
fim_erro    WORD    FINAL_STR


;									+--------------------+
;									| Programa Principal |
;									+--------------------+


            ORIG    0000h
            ENI
            MOV     R7, SP_INI
            MOV     SP, R7
			MOV     R1, INT_MASK
            MOV     M[FFFAh], R1            ; Habilita as interrupcoes
            MOV     R1, NBR_MILISEC
            MOV     M[TIMER_COUNT], R1
			MOV     R7, FFFFh
			MOV     M[IO_CONTROL], R7       ; Inicializa o terminal            
            PUSH    ecra_ini
            PUSH    0918h                   ; Posicao inicial da string
            CALL    ESCREVE
INIC:       INC     M[random]               ; Gera o primeiro valor random
            CMP     R0, M[actualiza]
            BR.Z    INIC
            MOV     M[actualiza], R0
            PUSH    ecra_ini
            PUSH    0918h
            CALL    APAGA
REP_LANC:   MOV     R7, FFFFh
			MOV     M[IO_CONTROL], R7       ; Apaga os dois macacos
            MOV     R7, MEIOGRAV
            ADD     M[random], R7
            PUSH    R0
            CALL    RANDOM                  ; Gera atraves do primeiro valor um proximo valor aparentemente random
            CALL    POS_MACS
            PUSH    vel_str
            PUSH    0000h
            CALL    ESCREVE
            MOV     R1, ANG_MAX
            MOV     R2, M[ang]
            CMP     R1, R2
            JMP.N   ECRA_ERRO
            MOV     R3, M[score]
            CMP     R3, 0003h
            JMP.Z   ECRA_VIC                ; Verifica se a posicao maxima (3) foi atingida
            ADD     R3, 0030h
            MOV     R2, 0207h
            MOV     M[IO_CONTROL], R2
            MOV     M[IO_WRITE], R3         ; Escreve pontuacao na placa
            PUSH    R0
            PUSH    000Ah
            CALL    REC_VAL
            POP     M[vinic]                ; Guarda valor da velocidade inicial inserido pelo jogador atraves das interrupcoes na variavel ang
            PUSH    R0
            PUSH    0107h
            CALL    REC_VAL                 ; Transforma os digitos introduziudos num valor que pode ser usado para calcular a trajetoria
            POP     M[ang]                  ; Guarda valor do angulo inserido pelo jogador
            PUSH    vel_str
            PUSH    0000h
            CALL    APAGA
            CALL    VOO
            JMP     REP_LANC                ; Repete o lancamento caso a pontuacao maxima nao tenha sido atingida
            BR      -1


;									+--------------------+
;									|    Temporizador    |
;									+--------------------+


TIMER:      PUSH    R7
			MOV     R7, 0005h
			ADD     M[tempo], R7
            INC     M[actualiza]
			MOV     R7, NBR_MILISEC
            MOV     M[TIMER_COUNT], R7
            POP     R7
			RTI


;									+--------------------+
;									| Zona de interações |
;									+--------------------+


; Relaciona as os butoes da placa com o respetivo numero (ex: a TEC_O corresponde o numero 0 e assim sucessivamente)
TEC_0:      MOV     M[numero], R0
            RTI

TEC_1:      PUSH    R1
            MOV     R1, 0001h
            JMP     MOVER

TEC_2:      PUSH    R1
            MOV     R1, 0002h
            JMP     MOVER

TEC_3:      PUSH    R1
            MOV     R1, 0003h
            JMP     MOVER

TEC_4:      PUSH    R1
            MOV     R1, 0004h
            JMP     MOVER

TEC_5:      PUSH    R1
            MOV     R1, 0005h
            JMP     MOVER

TEC_6:      PUSH    R1
            MOV     R1, 0006h
            JMP     MOVER

TEC_7:      PUSH    R1
            MOV     R1, 0007h
            JMP     MOVER

TEC_8:      PUSH    R1
            MOV     R1, 0008h
            JMP     MOVER

TEC_9:      PUSH    R1
            MOV     R1, 0009h
            JMP     MOVER

ENTER:      INC     M[actualiza]
            RTI

MOVER:      MOV     M[numero], R1
            POP     R1
            RTI


;									+--------------------+
;									|  Zona de funções   |
;									+--------------------+


; ECRA_ERRO: ecra de erro que aparece no angulo quando este e superior a 90
ECRA_ERRO:  MOV     M[ang], R0
            MOV     R7, FFFFh
            MOV     M[IO_CONTROL], R7       ; Limpa o terminal
            PUSH    ecra_erro
            PUSH    0918h
            CALL    ESCREVE                 ; Atraves da sub rotina ESCREVE escreve o ecra de vitoria na janela de texto
EE_AUX:     CMP     M[actualiza], R0
            JMP.NZ  0000h
            BR      EE_AUX


; ECRA_VIC: ecra de vitoria que aparece quando a pontuacao atinge os 3 valores
ECRA_VIC:   MOV     M[score], R0            ; Da reset a pontuacao caso o seu valor anterior seja 3
            MOV     R7, FFFFh
            MOV     M[IO_CONTROL], R7       ; Limpa o terminal
            PUSH    ecra_vic
            PUSH    0918h
            CALL    ESCREVE                 ; Atraves da sub rotina ESCREVE escreve o ecra de vitoria na janela de texto
EC_AUX:     CMP     M[actualiza], R0
            JMP.NZ  0000h
            BR      EC_AUX


; POS_MACS: insere os "macacos" nas respetivas zonas (macaco1 fica entre o-19 e macaco2 entre 49-79 em termos de x)
POS_MACS:   PUSH    R1
            PUSH    R2
            PUSH    R3
            MOV     R1, M[SP + 5]
            MOV     R2, 0014h
            DIV     R1, R2                  ; R2 com valor entre 0-19
            ADD     R2, 0300h
            MOV     R1, M[SP + 5]
            ROR     R1, 0004h
            MOV     R3, 0011h
            DIV     R1, R3                  ; R3 com valor entre 0-9
            SHL     R3, 0008h
            ADD     R2, R3
            PUSH    mac_str1
            PUSH    R2
            CALL    ESCREVE
            ADD     R2, 0003h
            MOV     M[posi_ban], R2
            MOV     R1, 1700h
            SUB     R1, M[posi_ban]
            MVBH    M[posi_ban], R1
            MOV     R1, M[SP + 5]
            ROR     R1, 0008h
            MOV     R2, 0014h
            DIV     R1, R2
            ADD     R2, 153Ah
            MOV     M[pos_mac2], R2
            PUSH    mac_str1
            PUSH    R2
            CALL    ESCREVE
            PUSH    mac2_str
            PUSH    R2
            CALL    ESCREVE
            POP     R3
            POP     R2
            POP     R1
            RET


; RANDOM: calcula um valor pseudo aleatorio
RANDOM:     PUSH    R1
            PUSH    R2
            MOV     R2, 0005h
REP_RANDOM: MOV     R1, M[random]
            TEST    R1, 0001h
            BR.Z    SALTA
            XOR     R1, MEIOGRAV
SALTA:      ROR     R1, 0001h
            DEC     R2
            CMP     R2, R0
            BR.NZ   REP_RANDOM
            MOV     M[SP + 4], R1
            POP     R2
            POP     R1
            RET


;VOO: poe a banana a voar
VOO:        PUSH    R1
            PUSH    R2
            PUSH    R7
            PUSH    R6
            MOV     R6, R0
            MOV     R1, 0001h
            MOV     M[TIMER_CTRL], R1	    ; Inicializa o temporizador
            JMP     CHECK
UPDATE:	    MOV     R2, 0020h			    ; Apaga a ultima instancia do projetil
			MOV     M[IO_WRITE], R2
			MOV     R7, M[posicao]
			MOV     M[IO_CONTROL], R7
            CMP     R6, R0
            BR.Z    ANIMA
			MOV     R7, '<'
			MOV     M[IO_WRITE], R7
            DEC     R6
            BR      CHECK_Y
ANIMA:      MOV     R7, '>'
			MOV     M[IO_WRITE], R7
            INC     R6
CHECK_AMX:  MOV     R1, ANG_MAX
            MOV     R2, M[ang]
            CMP     R1, R2
            JMP.N   FIM_VOO
CHECK_Y:    MOV     R7, M[posicaoy]
        	CMP     R7, LIMITE_Y		    ; Verifica se o projetil ja saiu da janela (por baixo)
			BR.N	CHECK_X
			CMP		R7, 00FFh
			BR.Z	CHECK_X
            MOV     M[posicaoy], R0
            BR      FIM_VOO
CHECK_X:	MOV     R7, M[posicaox]
			CMP     R7, LIMITE_X		    ; Verifica se o projetil ja saiu da janela (por baixo)
			BR.NP   CHECK_H
            MOV     M[posicaox], R0
            BR      FIM_VOO
CHECK_H:    MOV     R7, 0002h
            CMP     M[posicaoy], R7
            BR.P    CHECK                   ; Verifica se a banana atinjiu o macaco2
            MVBL    R7, M[pos_mac2]
            CMP     M[posicaox], R7
            BR.N    CHECK                   ; Verifica se a banana atinjiu o macaco2
            ADD     R7, 0002h
            CMP     M[posicaox], R7
            BR.P    CHECK                   ; Verifica se a banana atinjiu o macaco2
            INC     M[score]                ; Caso a banana atinja o macaco2, a pontuacao e incrementada
            MOV     R7, 0020h
            MOV     M[IO_WRITE], R7
FIM_VOO:    MOV     M[TIMER_CTRL], R0
            MOV     M[tempo], R0
			POP     R6
            POP     R7
            POP     R2
            POP     R1
            RET
CHECK:		CMP     R0, M[actualiza]
			BR.Z    CHECK
			CALL    ACT_TERM
            JMP     UPDATE


; REC_VAL: recebe os valores introduzidos pelo jogador
REC_VAL:    PUSH    R1
            PUSH    R2
VER_VAL:    MOV     R2, 000Ah
            MOV     R1, M[SP + 4]
            MOV     M[IO_CONTROL], R1
            CMP     M[actualiza], R0
            BR.NZ   DEV_VAL
            MOV     R1, M[numero]
            CMP     R1, 1000h
            BR.Z    VER_VAL
            MUL     R2, M[SP + 5]
            MOV     R2, 1000h
            MOV     M[numero], R2           ; Escreve o valor introduzido em R2
            ADD     M[SP + 5], R1
            ADD     R1, 0030h
            MOV     M[IO_WRITE], R1
            INC     M[SP + 4]
            BR      VER_VAL
DEV_VAL:    MOV     M[actualiza], R0        ; Devolve o valor introduzido para ser utilizado como valor noutras sub rotinas
            POP     R2
            POP     R1
            RETN    0001h


; ESCREVE: escreve uma string
;               Entradas: variaveis - strings que pretendemos escrever 
ESCREVE:    PUSH    R1
            PUSH    R2
            PUSH    R3
            PUSH    R4
            PUSH    R5
            MOV     R5, R0
            MOV     R1, M[SP + 8]           ; Move para R1 o local em memoria do primeiro caracter
            MOV     R2, M[SP + 7]           ; Move para R2 a posição inicial do terminal
REP_ESC:    MOV     R3, M[R1]               ; Move o primeiro caracter para R3
            MOV     R4, FINAL_STR
            CMP     R4, R3
            BR.Z    ACA_ESC
            MOV     R4, '@'
            CMP     R4, R3
            BR.NZ   CONT_ESC
            MOV     R2, M[SP + 7]
            ADD     R5, 0100h
            ADD     R2, R5                  ; Muda de linha
            BR      NL_ESC
CONT_ESC:   MOV     M[IO_CONTROL], R2
            MOV     M[IO_WRITE], R3         ; Escreve no terminal as strings
            INC     R2                      ; Incrementa o cursor que escreve na janela de texto
NL_ESC:     INC     R1
            BR      REP_ESC
ACA_ESC:    POP     R5
            POP     R4
            POP     R3
            POP     R2
            POP     R1
            RETN    2


; APAGA: apaga uma string substituindo as letras por espacos
APAGA:      PUSH    R1
            PUSH    R2
            PUSH    R3
            PUSH    R4
            PUSH    R5
            MOV     R5, R0
            MOV     R1, M[SP + 8]           ; Move para R1 o local em memoria do primeiro caracter
            MOV     R2, M[SP + 7]           ; Move para R2 a posicao inicial do terminal
REP_APA:    MOV     R3, M[R1]               ; Move o primeiro caracter para R3
            MOV     R4, FINAL_STR
            CMP     R4, R3
            BR.Z    ACA_APA
            MOV     R4, '@'
            CMP     R4, R3
            BR.NZ   CONT_APA
            MOV     R2, M[SP + 7]
            ADD     R5, 0100h
            ADD     R2, R5                  ; Muda de linha
            BR      NL_APA 
CONT_APA:   MOV     R3, ' '
            MOV     M[IO_CONTROL], R2
            MOV     M[IO_WRITE], R3         ; Apaga o que foi escrito anteriormente, através de espacos, com a sub rotino ESCREVE
            INC     R2
NL_APA:     INC     R1
            BR      REP_APA
ACA_APA:    POP     R5
            POP     R4
            POP     R3
            POP     R2
            POP     R1
            RETN    0002h


; ACT_TERM: atualiza a posiçao do projetil
;			    Entradas: pilha - angulo, tempo, velocidade inicial
ACT_TERM:	PUSH    R1
			PUSH    R2
			PUSH    R3
            PUSH    R4
			PUSH    R0
            PUSH    M[vinic]
            PUSH    M[tempo]
            PUSH    M[ang]
            CALL    POSX
            POP     R1
			PUSH    R0
            PUSH    M[vinic]
            PUSH    M[tempo]
            PUSH    M[ang]
            CALL    POSY
            POP     R2
            ADD     R2, M[posi_ban]
            ADD     R2, 0100h
			MOV     M[posicaoy], R2
			SHR     M[posicaoy], 0008h
			MOV     R3, 1700h	            ; Inverter o y
			SUB     R3, R2
			SHR     R1, 0008h
            MVBL    R4, M[posi_ban]
            ADD     R1, R4
			MOV     M[posicaox], R1
			MVBL    R3, R1
			MOV     M[posicao], R3
			DEC     M[actualiza]
			MOV     R1, 0001h
			MOV     M[TIMER_CTRL], R1
            POP     R4
			POP     R3
			POP     R2
			POP     R1
			RET


; POSY:	obtem o valor da coordenada y, evocando o sen e o compact
;				Entradas: pilha - angulo, tempo, velocidade inicial
POSY:       PUSH    R1
            PUSH    R2
            PUSH    R3
            MOV     R1, M [SP + 5]
            MOV     R2, M [SP + 6]
            MOV     R3, M [SP + 7]
            PUSH    R0
            PUSH    R1
            CALL    SEN
            POP     R1
            SHL     R3, 0008h
            MUL     R1, R2
            PUSH    R1
            PUSH    R2
            CALL    COMPACT
            POP     R2
            POP     R1
            MUL     R2, R3
            PUSH    R2
            PUSH    R3
            CALL    COMPACT
            POP     R3
            POP     R2
            MOV     R1, MEIOGRAV
            MOV     R2, M [SP + 6]
            PUSH    R0
            PUSH    R2
            PUSH    0200h
            CALL    EXP
            POP     R2
            MUL     R1, R2
            PUSH    R1
            PUSH    R2
            CALL    COMPACT
            POP     R2
            POP     R1
            SUB     R3, R2
            MOV     M[SP + 8], R3
            POP     R3
            POP     R2
            POP     R1
            RETN    0003h


; POSX:	obtem o valor da coordenada x, evocando o cos e o compact
;				Entradas: pilha - angulo, tempo, velocidade inicial
POSX:       PUSH    R1
            PUSH    R2
            PUSH    R3
            MOV     R1, M [SP + 5]
            MOV     R2, M [SP + 6]
            MOV     R3, M [SP + 7]
            PUSH    R0
            PUSH    R1
            CALL    COS
            POP     R1
            SHL     R3, 0008h
            MUL     R1, R2
            PUSH    R1
            PUSH    R2
            CALL    COMPACT
            POP     R2
            POP     R1
            MUL     R2, R3
            PUSH    R2
            PUSH    R3
            CALL    COMPACT
            POP     R3
            POP     R2
            MOV     M[SP + 8], R3
            POP     R3
            POP     R2
            POP     R1
            RETN    0003h


; SEN: obtem o sen do angulo dado, atraves do cos
;				Entradas: pilha - angulo
SEN:        PUSH    R1
            PUSH    R2
            MOV     R1, M[SP + 4]
            MOV     R2, 005Ah
            SUB     R2, R1                  ; Transforma o seno em cosseno atraves de um subtracao do valor 90 (005Ah)
            PUSH    R0
            PUSH    R2
            CALL    COS
            POP     R1
            MOV     M[SP + 5], R1
            POP     R2
            POP     R1
            RETN    0001h


; COS: obtem o cos do angulo dado, evocando rad, exp e fact
;				Entradas: pilha - angulo
COS:        PUSH    R1
            PUSH    R2
            PUSH    R3
            PUSH    R4
            MOV     R1, M[SP + 6]
            SHL     R1, 0008h
            PUSH    R1
            CALL    RAD
            POP     R2
            MOV     R1, 0100h
            MOV     R4, 0002h
            PUSH    R0
            PUSH    R2
            PUSH    0200h
            CALL    EXP
            POP     R3
            DIV     R3, R4
            SUB     R1, R3
            MOV     R4, 0004h
            PUSH    R0
            PUSH    R2
            PUSH    0400h
            CALL    EXP
            POP     R3
            PUSH    R0
            PUSH    0400h
            CALL    FACT
            POP     R4
            SHR     R4, 0008h
            DIV     R3, R4
            ADD     R1, R3
            MOV     M[SP + 7], R1
            POP     R4
            POP     R3
            POP     R2
            POP     R1
            RETN    0001h


; RAD: transforma o angulo em graus para radianos, atraves do chamamento de compact
;				Entradas: pilha - angulo
RAD:        PUSH    R1
            PUSH    R2
            PUSH    R3
            MOV     R1, M[SP + 5]
            MOV     R2, 0324h
            MOV     R3, 0004h
            DIV     R1, R3
            MUL     R2, R1
            PUSH    R2
            PUSH    R1
            CALL    COMPACT
            POP     R1
            POP     R2
            MOV     R3, 0005h
            DIV     R1, R3
            MOV     R3, 0009h
            DIV     R1, R3
            MOV     M[SP + 5], R1
            POP     R3
            POP     R2
            POP     R1
            RET


; FACT:	aplica o factorial a um determinado numero, chama compact
;				Entradas: pilha - n
FACT:       PUSH    R1
            PUSH    R2
            PUSH    R3
            MOV     R1, M[SP + 5]
            MOV     R2, 0100h

COMP_FACT:  CMP     R1, R0
            BR.Z    FIM_FACT
            MOV     R3, R1
            MUL     R3, R2
            PUSH    R3
            PUSH    R2
            CALL    COMPACT
            POP     R2
            POP     R3
            SUB     R1, 0100h
            BR      COMP_FACT

FIM_FACT:   MOV     M[SP + 6], R2
            POP     R3
            POP     R2
            POP     R1
            RETN    0001h


; COMPACT: faz a alteracao da posicao da virgula fixa
;				Entradas: pilha - n
COMPACT:    PUSH    R1
            PUSH    R2
            MOV     R1, M[SP + 5]
            MOV     R2, M[SP + 4]
            MVBL    R2, R1
			ROR     R2, 0008h
            MOV     M[SP + 4], R2
            MOV     M[SP + 5], R1
            POP     R2
            POP     R1
            RET


; EXP: calcula a exponencial do valor dado
;				Entradas: pilha - n
EXP:        PUSH    R1
            PUSH    R2
            PUSH    R3
            PUSH    R4
            MOV     R1, M[SP + 6]
            MOV     R2, M[SP + 7]
            MOV     R4, 0100h

COMP_EXP:   CMP     R1, R0
            BR.Z    FIM_EXP
            MOV     R3, R2
            MUL     R3, R4
            PUSH    R3 
            PUSH    R4
            CALL    COMPACT
            POP     R4
            POP     R3
            SUB     R1, 0100h
            BR      COMP_EXP

FIM_EXP:    MOV     M[SP + 8], R4
            POP     R4
            POP     R3
            POP     R2
            POP     R1
            RETN    0002h