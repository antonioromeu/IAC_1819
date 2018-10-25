            MOV R7, fdffh
            MOV SP, R7
vinic       EQU 50
tempo       EQU 0080h
meiograv    EQU 04e6h
ang         EQU 60
            PUSH R0
            PUSH vinic
            PUSH tempo
            PUSH ang
            CALL POSX
            POP R1
            BR -1      

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

COMPACT:    PUSH R1
            PUSH R2
            MOV R1, M[SP + 5]
            MOV R2, M[SP + 4]
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            SHR R1, 1
            RORC R2, 1
            MOV M[SP + 4], R2
            MOV M[SP + 5], R1
            POP R2
            POP R1
            RET

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