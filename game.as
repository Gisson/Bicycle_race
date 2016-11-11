;Parte 1 Constantes		

SP_INICIAL	EQU	FDFFh
Porto_escrita	EQU	FFFEh
Fim_Texto	EQU	'@'
Porto_controlo	EQU	FFFCh
INT_MASK	EQU	1000110000000111b
MASK_PAUSA	EQU	1000010000000000b
INT_MASK_ADDR	EQU	FFFAh
ParedeDir	EQU	1536h
ParedeEsq	EQU	151Fh
Mask_Random	EQU	1000000000010110b
D7_UNI		EQU	FFF0h
D7_DEZ		EQU	FFF1h
D7_CEN		EQU	FFF2h
D7_MIL		EQU	FFF3h
LCD_0		EQU	800Eh
LCD_1		EQU	800Dh
LCD_2		EQU	800Ch
LCD_3		EQU	800Bh
LCD_4		EQU	800Ah
LCD_M0		EQU	801Bh
LCD_M1		EQU	801Ah
LCD_M2		EQU	8019h
LCD_M3		EQU	8018h
LCD_M4		EQU	8017h
Timer_Value	EQU	FFF6h
Timer_Control	EQU	FFF7h
Display_Value	EQU	FFF5h
Display_Control	EQU	FFF4h
Display_Leds	EQU	FFF8h
MASK_N0		EQU	0000h
MASK_N1		EQU	F000h
MASK_N2		EQU	FF00h
MASK_N3		EQU	FFF0h
MASK_TURBO	EQU	FFFFh
Zero_ASCII	EQU	0030h

;Parte 2 Variaveis
		ORIG	8000h
Texto1		STR	'Bem-vindo a corrida de bicicleta!',Fim_Texto	
Texto2		STR	'Prima I1 para comecar',Fim_Texto
Texto3		STR	'Fim do jogo',Fim_Texto
Texto4		STR	'Prima o interruptor I1 para recomecar',Fim_Texto
Texto5		STR	'PAUSA',Fim_Texto
ApagPausa	STR	'     ',Fim_Texto
StrEstrada	STR	'+|                      |+',Fim_Texto
StrDisplay1	STR	'Distancia:00000m',Fim_Texto
StrDisplay2	STR	'Maximo:00000m',Fim_Texto
StrDisplay3	STR	'm'
Bicicleta1	STR	'|'
Bicicleta2	STR	'O'
Obstaculo	STR	'*'
Espaco		STR	' '
Apaga		STR	'                                                                               ',Fim_Texto
int0		WORD	0
int1		WORD	0
int2		WORD	0
intb		WORD	0
inta		WORD	0
intt		WORD	0
Bicicleta	WORD	152Ah
Last_Random	WORD	0000h
ContObstaculos	WORD	0
ContDistancia	WORD	5
Velocidade	WORD	5
TurboMode	WORD	0
BicicletaOrig	WORD	152Ah
DistanciaPerc	WORD	0000h
DistanciaMax	WORD	0000h
D7_Unidades	WORD	0000h
D7_Dezenas	WORD	0000h
D7_Centenas	WORD	0000h
D7_Milhares	WORD	0000h
Distancia_LCD_0	WORD	30h	;Codigo ASCII para zero
Distancia_LCD_1	WORD	30h
Distancia_LCD_2	WORD	30h
Distancia_LCD_3	WORD	30h
Distancia_LCD_4	WORD	30h
Dist_LCD_M0	WORD	30h
Dist_LCD_M1	WORD	30h
Dist_LCD_M2	WORD	30h
Dist_LCD_M3	WORD	30h
Dist_LCD_M4	WORD	30h
NovoJogo	WORD	0
ObstaculosPos	TAB	5

;Parte 3 Interrupções
		ORIG	FE00h
Int_0		WORD	Move_esquerda
Int_1		WORD	Inicia
Int_2		WORD	Turbo
		ORIG	FE0Ah
Int_A		WORD	Paragem		
Int_B		WORD	Move_direita

		ORIG	FE0Fh
IntTemp		WORD	Temp






; inicia as interrupcoes

Inicia:		INC	M[int1]
		RTI

Move_esquerda:	INC	M[int0]
		RTI

Move_direita:	INC	M[intb]
		RTI
		
Paragem:	INC	M[inta]
		RTI
		
Turbo:		INC	M[int2]
		RTI

Temp:		INC	M[intt]
		PUSH	R7
		MOV	R7,M[Velocidade]
		MOV	M[Timer_Value],R7
		MOV	R7,1
		MOV	M[Timer_Control],R7
		POP	R7
		RTI
;Inicio do código. Posição 0000h. Iniciação da pilha e da interface. Salto para o inicio das tarefas.
		DSI
		ORIG	0000h
Recomecar:	MOV	R1,SP_INICIAL
		MOV	SP,R1
		MOV	R2,FFFFh
		MOV	M[Porto_controlo],R2
		MOV     R7, INT_MASK
                MOV     M[INT_MASK_ADDR], R7
		MOV	M[D7_UNI],R0
		MOV	M[D7_DEZ],R0
		MOV	M[D7_CEN],R0
		MOV	M[D7_MIL],R0
		MOV	R2,1
		CMP	M[NovoJogo],R2
		BR.Z	Novo_Jogo
		CALL	EscDisplay
Novo_Jogo:	JMP	INICIO

;LimpaTab:	Limpar a tabela que sera utilizada para as posições dos objectos.
;		Entradas:	R1: Posição na tabela a limpar;
;				R2: Numero máximo de posições na tabela;
;				R3: Numero incrementado para correr a tabela;
;		Saidas:		---
;		Efeitos:	Mete todas as posições dos objectos a zero.
LimpaTab:	MOV	R1,ObstaculosPos
		MOV	R2,5
		MOV	R3,R0
LimpaT:		MOV	M[R1],R0
		INC	R3
		INC	R1
		CMP	R3,R2
		BR.NZ	LimpaT
		RET
		
;EscDisplay:	Escreve no Display.
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no display.


EscDisplay:	MOV	R1,StrDisplay1
		MOV	R2,8000h
		CALL	EscDisp
		MOV	R1,StrDisplay2
		MOV	R2,8010h
		CALL	EscDisp
		RET

;EscCarDisp:	Escreve um caracter no display
;		Entradas:	R4: Caracter a escrever, R2: Posicao no display
;		Saidas:		---
;		Efeitos:	Escreve no display o caracter
EscCarDisp:	MOV	M[Display_Control],R2
		MOV	M[Display_Value],R4
		RET

;EscDisp:	Escreve uma string no display
;		Entradas:	R1: String para escrever
;				R2: Posicao no display
;		Saidas:		---
;		Efeitos:	Escreve no display a string
EscDisp:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R3,Fim_Texto
CicloEscDisp:	MOV	R4,M[R1]
		CMP	R4,Fim_Texto
		BR.Z	FimEscDisp		
		CALL	EscCarDisp
		INC	R1
		INC	R2
		BR	CicloEscDisp
FimEscDisp:	POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET


;Escinicio:	Escreve a mensagem de inicio de jogo. Utiliza a sub-rotina "EscString" para escrever a string no ecran.
;		Entradas:	R1:String R2:Posição
;		Saidas:		---
;		Efeitos: Escreve no ecra a mensagem inicial. Realiza o enable das interrupções e inicia um ciclo ("Pausa") para verificar se a interrupção do botão I1 foi activada. Caso seja activada a interrupção chama a rotina "LimpEcra" para limpar o ecran e volta à rotina anterior.

EscInicio:	MOV	R1,Texto1
		MOV	R2,0C1Eh
		CALL	EscString
		MOV	R1,Texto2
		MOV	R2,0E22h
		CALL	EscString
		ENI
Pausa:		INC	M[Last_Random]
		CMP	R0,M[int1]
		BR.Z	Pausa
		CALL	LimpEcra
		MOV	M[int1],R0
		RET

;LimpEcra:	Limpa ecra
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no ecra
LimpEcra:	PUSH	R2
		PUSH	R1
		MOV	R2,R0
		MOV	R1,Apaga
LimpEcra2:  	CALL	EscString
		ADD	R2,0100h
		CMP	R2,1800h
		BR.N	LimpEcra2
		POP	R1
		POP	R2
		RET







;EscEstrada:	Desenha a estrada no ecra de jogo.
;		Entradas:	R1: String que contém uma linha de estrada.
;				R2: Posição para escrever uma linha de estrada.
;		Saidas:		---
;		Efeitos:	Escreve no ecra a estrada.
EscEstrada:	MOV	R2,30
CicloEstrada:	AND	R2,FF00h	;Guarda o valor da coluna inicializando o valor da linha
		ADD	R2,30
		MOV	R1,StrEstrada
		CALL	EscString
		ADD	R2,0100h	;Valor para saltar de linha
		CMP	R2,1800h
		BR.N	CicloEstrada		
		RET

;EscCarater:	Escreve um caracter no ecra
;		Entradas:	R4: Caracter a escrever, R2: Posicao no ecran
;		Saidas:		---
;		Efeitos:	Escreve no ecra o caracter
EscCarater:	MOV	M[Porto_controlo],R2
		MOV	M[Porto_escrita],R4
		RET

;EscString:	Escreve uma string no ecra
;		Entradas:	R1: String para escrever
;				R2: Posicao no ecran
;		Saidas:		---
;		Efeitos:	Escreve no ecra a string
EscString:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R3,Fim_Texto
CicloEscString:	MOV	R4,M[R1]
		CMP	R4,Fim_Texto
		BR.Z	FimEscString		
		CALL	EscCarater
		INC	R1
		INC	R2
		BR	CicloEscString
FimEscString:	POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET



;EscBicicleta:	Escreve a bicicleta no ecra
;		Entradas:	R2: Regiso contendo a posição da bicicleta no ecran.
;				R4: Registo contendo a roda ou o meio da bicicleta.
;		Saidas:		---
;		Efeitos:	Escreve no ecra a bicicleta na posição inicial.


EscBicicleta:	PUSH	R4
		PUSH	R2
		MOV	R2,M[Bicicleta]
		MOV	R4,M[Bicicleta2]
		CALL	EscCarater
		ADD	R2,0100h
		MOV	R4,M[Bicicleta1]
		CALL	EscCarater
		ADD	R2,0100h
		MOV	R4,M[Bicicleta2]
		CALL	EscCarater
		POP	R2
		POP	R4
		RET
;Apaga_Bicicleta: Apaga a bicicleta n caso de um movimento ter sido feito.
;		Entradas:	R2: Contem a posição da bicicleta.
;				R4: Contem o caracter " " para apagar a bicicleta.
;		Saidas:		---
;		Efeitos:	Escreve no ecra espaços na posição anterior da bicicleta.
Apaga_Bicicleta:PUSH	R2
		PUSH	R4
		MOV	R2,M[Bicicleta]
		MOV	R4,M[Espaco]
		CALL 	EscCarater
		ADD	R2,0100h
		CALL	EscCarater
		ADD	R2,0100h
		CALL	EscCarater
		POP	R2
		POP	R4
		RET




;Move_esquerda:	Escreve a bicicleta no ecran uma posição à esquerda.
;		Entradas:	R1: Posição da bicicleta.
;		Saidas:		---
;		Efeitos:	Mete a interrupção a zero. Verifica se a nova posição à esquerda tem uma parede. Caso não tenha continua a rotina apagando a bicicleta da posição inicial e escrevendo-a na nova posição.

MoveEsq:	PUSH	R1
		MOV	M[int0],R0
		MOV	R1,M[Bicicleta]
		DEC	R1
		CMP	R1,ParedeEsq
		BR.Z	Fim_esquerda
		CALL	Apaga_Bicicleta
		MOV	M[Bicicleta],R1
		CALL	EscBicicleta
Fim_esquerda:	POP 	R1
		RET

;Move_direita:	Escreve a bicicleta no ecran uma posição à direita.
;		Entradas:	R1: Posição da bicicleta.
;		Saidas:		---
;		Efeitos:	Mete a interrupção a zero. Verifica se a nova posição à direita tem uma parede. Caso não tenha continua a rotina apagando a bicicleta da posição inicial e escrevendo-a na nova posição.

MoveDir:	PUSH	R1
		MOV	M[intb],R0
		MOV	R1,M[Bicicleta]
		INC	R1
		CMP	R1,ParedeDir
		BR.Z	Fim_direita
		CALL	Apaga_Bicicleta
		MOV	M[Bicicleta],R1
		CALL	EscBicicleta
Fim_direita:	POP 	R1
		RET
;Random:	Funcao que aleatoria algo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no ecra
Random:		PUSH	R1
		MOV	R1,M[Last_Random]
		AND	R1,0001h
		CMP	R1,R0
		BR.NZ	Random_Alt
		ROR	M[Last_Random],1
		POP	R1
		RET
Random_Alt:	MOV	R1,Mask_Random
		XOR	M[Last_Random],R1
		ROR	M[Last_Random],1
		POP	R1
		RET

;CriaObstaculo:	Funcao que cria os obstaculos
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no ecra
CriaObstaculo:	CALL	Random
		MOV	M[ContDistancia],R0
		MOV	R1,M[Last_Random]
		MOV	R2,20	;Posição aleatória no meio da estrada
		DIV	R1,R2
		ADD	R2,32	;32 é onde começa a estrada
		MOV	R3,ObstaculosPos
VerificaObs:	CMP	M[R3],R0
		BR.Z	Desenhar
		INC	R3
		BR	VerificaObs
Desenhar:	MOV	M[R3],R2
		PUSH	R2
		CALL	DesenhaObs
		RET



;MoveObstaculo:	Funcao que move os obstaculos
;		Entradas:	R2:Tabela das 5 posições dos obstáculos;
;				R4:Indicador de uma das 5 posições da tabela dos obstáculos.
;		Saidas:		---
;		Efeitos:	Escreve no ecra

MoveObstaculo:	MOV	M[intt],R0
		INC	M[ContDistancia]
		INC	M[DistanciaPerc]
		CALL	Num_Disp_LCD
		MOV	R4,R0
Ciclo_MoveObs:	MOV	R2,ObstaculosPos
		ADD	R2,R4
		CMP	M[R2],R0
		CALL.NZ	Inc_Obs
		INC	R4
		CMP	R4,4
		BR.NZ	Ciclo_MoveObs
		RET

Inc_Obs:	MOV	R1,0100h
		PUSH	M[R2]
		CALL	ApagaObs
		ADD	M[R2],R1
		MOV	R3,M[R2]
		SUB	R3,1733h	;ultima posição na estrada
		BR.NN	Ponto_Obs
;Parte em que a verificação de ter passado o limite da estrada tem que estar.
		PUSH	M[R2]
		CALL	DesenhaObs
Inc_ObsFim:	RET

Ponto_Obs:	MOV	M[R2],R0
		INC	M[ContObstaculos]
		CALL	Inc_D7
		BR	Inc_ObsFim


;DesenhaObs:	Desenha um obstaculo
;		Entradas:	Stack:Posicao do obstaculo
;		Saidas:		---
;		Efeitos:	---
DesenhaObs:	PUSH	R4
		PUSH	R2
		MOV	R2,M[SP+4]
		MOV	R4,M[Obstaculo]
		CALL	EscCarater
		INC	R2
		CALL	EscCarater
		INC	R2
		CALL	EscCarater
		POP	R2
		POP	R4
		RETN	1

;ApagaObs:	Apaga um obstaculo
;		Entradas:	Stack: Posicao de obstaculo
;		Saidas:		---
;		Efeitos:	---
ApagaObs:	PUSH	R4
		PUSH	R2
		MOV	R2,M[SP+4]
		MOV	R4,M[Espaco]
		CALL	EscCarater
		INC	R2
		CALL	EscCarater
		INC	R2
		CALL	EscCarater
		POP	R2
		POP	R4
		RETN	1



;VerificaEmbate:Funcao principal que chama as outras funcoes
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no ecra
VerificaEmbate:	MOV	R3,ObstaculosPos
		MOV	R5,M[Bicicleta]
		MOV	R2,5
		MOV	R1,R0
VerificaETab:	CMP	R2,R1
		BR.Z	NEmbate
		CALL	VerificaAux
		INC	R3
		INC	R1
		BR	VerificaETab
NEmbate:	RET


VerificaAux:	MOV	R7,R5
		CALL	VerificaAux2
		MOV	R6, 0100h
		ADD	R7,R6
		CALL	VerificaAux2
		ADD	R7,R6
		CALL	VerificaAux2
		RET

VerificaAux2:	MOV	R4,M[R3]
		CMP	R7,R4
		CALL.Z	GameOver
		INC	R4
		CMP	R7,R4
		CALL.Z	GameOver
		INC	R4
		CMP	R7,R4
		CALL.Z	GameOver
		RET

;Num_Disp_LCD:Escreve um numero no display do LCD em decimal
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no displaydo LCD

Num_Disp_LCD:	PUSH	R1
		PUSH	R7
		PUSH	R2
		PUSH	R4
		MOV	R1,Zero_ASCII
		MOV	R7,003Ah
		INC	M[Distancia_LCD_0]
		CMP	M[Distancia_LCD_0],R7
		BR.Z	Num_Disp_LCD2
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		JMP	Disp_LCD_Fim
Num_Disp_LCD2:	MOV	M[Distancia_LCD_0],R1
		INC	M[Distancia_LCD_1]
		CMP	M[Distancia_LCD_1],R7
		BR.Z	Num_Disp_LCD3
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	R2,LCD_1
		CALL	EscCarDisp
		JMP	Disp_LCD_Fim
Num_Disp_LCD3:	MOV	M[Distancia_LCD_1],R1
		INC	M[Distancia_LCD_2]
		CMP	M[Distancia_LCD_2],R7
		BR.Z	Num_Disp_LCD4
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	R2,LCD_1
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_2]
		MOV	R2,LCD_2
		CALL	EscCarDisp
		JMP	Disp_LCD_Fim
Num_Disp_LCD4:	MOV	M[Distancia_LCD_2],R1
		INC	M[Distancia_LCD_3]
		CMP	M[Distancia_LCD_3],R7
		BR.Z	Num_Disp_LCD5
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	R2,LCD_1
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_2]
		MOV	R2,LCD_2
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_3]
		MOV	R2,LCD_3
		CALL	EscCarDisp
		JMP	Disp_LCD_Fim
Num_Disp_LCD5:	MOV	M[Distancia_LCD_3],R1
		INC	M[Distancia_LCD_4]
		CMP	M[Distancia_LCD_4],R7
		JMP.Z	Num_Disp_LCD6
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	R2,LCD_1
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_2]
		MOV	R2,LCD_2
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_3]
		MOV	R2,LCD_3
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_4]
		MOV	R2,LCD_4
		CALL	EscCarDisp
		JMP	Disp_LCD_Fim
Num_Disp_LCD6:	MOV	M[Distancia_LCD_0],R1
		MOV	M[Distancia_LCD_1],R1
		MOV	M[Distancia_LCD_2],R1
		MOV	M[Distancia_LCD_3],R1
		MOV	M[Distancia_LCD_4],R1
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	R2,LCD_1
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_2]
		MOV	R2,LCD_2
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_3]
		MOV	R2,LCD_3
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_4]
		MOV	R2,LCD_4
		CALL	EscCarDisp
Disp_LCD_Fim:	POP	R4
		POP	R2
		POP	R7
		POP	R1
		RET


;Inc_D7:Display de sete segmentos dos objectos
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no display

Inc_D7:		PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R7,000Ah
		INC	M[D7_Unidades]
		CMP	M[D7_Unidades],R7
		BR.Z	Inc_D72
		MOV	R1,M[D7_Unidades]
		MOV	M[D7_UNI],R1
		JMP	D7_Fim
Inc_D72:	MOV	M[D7_Unidades],R0
		INC	M[D7_Dezenas]
		CMP	M[D7_Dezenas],R7
		BR.Z	Inc_D73
		MOV	R1,M[D7_Unidades]
		MOV	R2,M[D7_Dezenas]
		MOV	M[D7_UNI],R1
		MOV	M[D7_DEZ],R2
		JMP	D7_Fim
Inc_D73:	MOV	M[D7_Dezenas],R0
		INC	M[D7_Centenas]
		CMP	M[D7_Centenas],R7
		BR.Z	Inc_D74
		MOV	R2,M[D7_Dezenas]
		MOV	R3,M[D7_Centenas]
		MOV	M[D7_UNI],R1
		MOV	M[D7_DEZ],R2
		MOV	M[D7_CEN],R3
		JMP	D7_Fim
Inc_D74:	MOV	M[D7_Centenas],R0
		INC	M[D7_Milhares]
		CMP	M[D7_Milhares],R7
		BR.Z	Inc_D75
		MOV	R4,M[D7_Milhares]
		MOV	R3,M[D7_Centenas]
		MOV	M[D7_UNI],R1
		MOV	M[D7_DEZ],R2
		MOV	M[D7_CEN],R3
		MOV	M[D7_MIL],R4
		JMP	D7_Fim
Inc_D75:	MOV	M[D7_Unidades],R0
		MOV	M[D7_Dezenas],R0
		MOV	M[D7_Centenas],R0
		MOV	M[D7_Milhares],R0
		MOV	M[D7_UNI],R0
		MOV	M[D7_DEZ],R0
		MOV	M[D7_CEN],R0
		MOV	M[D7_MIL],R0
D7_Fim:		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET




;VerificaNivel:Verifica os niveis
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no ecra

VerificaNivel:	MOV	R1,M[ContObstaculos]
		MOV	R2,Velocidade
		CMP	R1,4
		CALL.Z	Nivel_2
		CMP	R1,8
		CALL.Z	Nivel_3
		RET

Nivel_2:	MOV	R3,4
		MOV	R4,MASK_N2
		MOV	M[R2],R3
		MOV	M[Display_Leds],R4
		RET
Nivel_3:	MOV	R3,3
		MOV	R4,MASK_N3
		MOV	M[R2],R3
		MOV	M[Display_Leds],R4
		RET



;GameOver:	Funcao principal que chama as outras funcoes
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve no ecra
GameOver:	CALL	LimpEcra
		MOV	R2,0C2Ah
		MOV	R1,Texto3
		CALL	EscString
		MOV	R2,0E1Eh
		MOV	R1,Texto4
		CALL	EscString
		MOV	R4,MASK_N0		;Reset Leds
		MOV	M[Display_Leds],R4
		MOV	R3,5
		MOV	M[Velocidade],R3
		MOV	M[ContObstaculos],R0
		CALL	VerificaPoint
PausaEnd:	CMP	R0,M[int1]
		BR.Z	PausaEnd
		CALL	LimpEcra
		MOV	M[int1],R0
		MOV	R3,M[BicicletaOrig]
		MOV	M[Bicicleta],R3
		MOV	M[D7_Unidades],R0
		MOV	M[D7_Dezenas],R0
		MOV	M[D7_Centenas],R0
		MOV	M[D7_Milhares],R0
		MOV	R3,5
		MOV	M[ContDistancia],R3
		JMP	Recomecar

VerificaPoint:	MOV	R2,M[DistanciaPerc]
		MOV	R4,M[DistanciaMax]
		SUB	R4,R2
		JMP.NN	FinalPoint
		MOV	M[DistanciaMax],R2
		MOV	R4,M[Distancia_LCD_0]
		MOV	M[Dist_LCD_M0],R4
		MOV	R2,LCD_M0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	M[Dist_LCD_M1],R4
		MOV	R2,LCD_M1
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_2]
		MOV	M[Dist_LCD_M2],R4
		MOV	R2,LCD_M2
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_3]
		MOV	M[Dist_LCD_M3],R4
		MOV	R2,LCD_M3
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_4]
		MOV	M[Dist_LCD_M4],R4
		MOV	R2,LCD_M4
		CALL	EscCarDisp
FinalPoint:	MOV	R3,30h
		MOV	M[Distancia_LCD_0],R3
		MOV	M[Distancia_LCD_1],R3
		MOV	M[Distancia_LCD_2],R3
		MOV	M[Distancia_LCD_3],R3
		MOV	M[Distancia_LCD_4],R3
		MOV	R2,1
		MOV	M[NovoJogo],R2
		MOV	R1,StrDisplay1
		MOV	R2,8000h
		CALL	EscDisp
		RET




Paragem_Jogo:	MOV	R3,MASK_PAUSA
		MOV     M[INT_MASK_ADDR], R3
		MOV	M[inta],R0
		MOV	R7,8020h
		MOV	M[Display_Control],R7
		MOV	R2,8009h
		MOV	R1,Texto5
		CALL	EscDisp
Paragem_Jogo2:	CMP	R0,M[inta]
		BR.Z	Paragem_Jogo2
		MOV	M[Display_Control],R7
		CALL	EscDisplay
		MOV	R4,M[Distancia_LCD_0]
		MOV	R2,LCD_0
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_1]
		MOV	R2,LCD_1
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_2]
		MOV	R2,LCD_2
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_3]
		MOV	R2,LCD_3
		CALL	EscCarDisp
		MOV	R4,M[Distancia_LCD_4]
		MOV	R2,LCD_4
		CALL	EscCarDisp
		MOV	R4,M[Dist_LCD_M0]
		MOV	R2,LCD_M0
		CALL	EscCarDisp
		MOV	R4,M[Dist_LCD_M1]
		MOV	R2,LCD_M1
		CALL	EscCarDisp
		MOV	R4,M[Dist_LCD_M2]
		MOV	R2,LCD_M2
		CALL	EscCarDisp
		MOV	R4,M[Dist_LCD_M3]
		MOV	R2,LCD_M3
		CALL	EscCarDisp
		MOV	R4,M[Dist_LCD_M4]
		MOV	R2,LCD_M4
		CALL	EscCarDisp
		MOV	M[inta],R0
		MOV	R3,INT_MASK
		MOV	M[INT_MASK_ADDR], R3
		RET

;Fazer Leds de turbo e leds de niveis.
		
TurboControl:	CMP	M[TurboMode],R0
		BR.Z	TurboON
		MOV	R1,5
		MOV	M[Velocidade],R1
		MOV	M[TurboMode],R0
		MOV	M[int2],R0
		JMP	Movimentos
TurboON:	MOV	R1,2
		MOV	M[Velocidade],R1   ;Verificar velocidade de turbo
		INC	M[TurboMode]
		MOV	M[int2],R0
		MOV	R7,MASK_TURBO
		MOV	M[Display_Leds],R7
		RET

		
		
;INICIO:	Funcao principal que chama as outras funcoes
;		Entradas:	---
;		Saidas:		---
;		Efeitos: Começa por escrever a mensagem inicial, de seguida limpa o ecran e ecreve a estrada e a bicicleta. Define os valores do temporizador para controlar a velocidade inicial.
INICIO:		CALL	LimpaTab
		CALL	EscInicio
		MOV	M[DistanciaPerc],R0
		MOV	R4,MASK_N1		;Leds iniciais
		MOV	M[Display_Leds],R4
		CALL	EscEstrada
		CALL	EscBicicleta
		MOV	R7,M[Velocidade]
		MOV	M[Timer_Value],R7
		MOV	R7,1
		MOV	M[Timer_Control],R7
		ENI
;Ciclo dos Movimentos possiveis: cada movimento esta dependente do valor da interrupção associada. Se a interrupção não se encontrar com o valor 0 irá chamar a rotina associada.
Movimentos:	CMP	M[int0],R0
		CALL.NZ	MoveEsq

		CMP	M[intb],R0
		CALL.NZ	MoveDir

		MOV	R1,6
		CMP	M[ContDistancia],R1
		CALL.Z	CriaObstaculo

		CMP	M[intt],R0
		CALL.NZ	MoveObstaculo
		 
		CMP	M[inta],R0
		CALL.NZ	Paragem_Jogo
		
		;CMP	M[int2],R0
		;CALL.NZ	TurboControl

		CALL	VerificaNivel

		;Falta pontuacao
		CALL	VerificaEmbate

		BR	Movimentos	;Passo necessário para criar o ciclo de constante verificação da activação das sub-rotinas.

fim:		BR	fim
