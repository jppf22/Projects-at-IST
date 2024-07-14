;**********************************************************************
;* Grupo nº 48
;* Membros: ist1106022 - João Fernandes
;*			ist1106047 - Salvador Valério
;***********************************************************************

;**********************************************************************
;* Constantes
;**********************************************************************

; Constantes relativas ao teclado
TEC_LIN					EQU 0C000H  						; endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H  						; endereço das colunas do teclado (periférico PIN)
NIBL_LOW				EQU 000FH							; mascara para isolar os 4 bits de menor peso
NIBL_HIGH				EQU	00F0H							; mascara para isolar os 4 bits de maior peso	
LIN_INIT				EQU 1000b							; linha inicial para o varrimento do teclado
N_LINHAS				EQU 4								; nº de linhas do teclado
TEC_NULA				EQU 00FFH							; corresponde ao valor da tecla não premida

; Constantes relativas ao Media Center
COMANDOS				EQU	6000H				; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA				EQU	COMANDOS + 00H		; endereço do comando para apagar os pixels no pscreen especificado
SELECIONA_ECRA			EQU COMANDOS + 04H		; endereço do comando para selecionar o ecrã de pixels em que vamos desenhar
APAGA_ECRÃS	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
APAGA_CENARIO_FUNDO		EQU	COMANDOS + 40H		; endereço do comando para apagar a imagem de fundo (elimina o aviso)
SELECIONA_CENARIO_FUNDO EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
APAGA_CENARIO_FRENTE	EQU	COMANDOS + 44H		; endereço do comando para apagar o cenário frontal
SELECIONA_CENARIO_FRENTE EQU COMANDOS + 46H		; endereço do comando para selecionar o cenário frontal a visualizar
SELECIONA_MEDIA			EQU	COMANDOS + 48H		; endereço do comando para selecionar conteudo media para leitura de estado
OBTEM_ESTADO_MEDIA		EQU	COMANDOS + 52H		; endereço do comando para obter o estado do conteudo media
TOCA_SOM				EQU COMANDOS + 5AH		; endereço do comando para tocar um som/vídeo
LOOP_MEDIA				EQU COMANDOS + 5CH		; endereço do comando que reproduz o som/vídeo até ser parado
PAUSE_MEDIA				EQU COMANDOS + 5EH		; endereço do comando que pausa os sons/vídeos
CONTINUE_MEDIA			EQU	COMANDOS + 60H		; endereço do comando que continua a reprodução do som/vídeo
PAUSE_MEDIA_ALL			EQU COMANDOS + 62H		; endereço do comando para pausar todos os sons/vídeos
CONTINUE_MEDIA_ALL		EQU COMANDOS + 64H		; endereço do comando para continuar todos sons/vídeos
STOP_MEDIA				EQU COMANDOS + 66H		; endereço do comando para terminar a reprodução do som/vídeo
STOP_MEDIA_ALL			EQU COMANDOS + 68H		; endereço do comando para terminar a reprodução de todos sons/vídeos

; Constantes relativas a leitura do media center
ESTADO_MEDIA_TOCAR		EQU	3		; representa som/video a tocar
ESTADO_MEDIA_PAUSA		EQU	2		; representa som/video em pausa
ESTADO_MEDIA_PRONTO		EQU	1		; representa som/video pronto para tocar

; Cenários
ECRA_INICIO				EQU	0		; o ecrão de ínicio de jogo é a imagem 0
ECRA_PAUSA				EQU	1		; o ecrão frontal de pausa do jogo é a imagem 1
ECRA_ENERGIA			EQU	2		; o ecrão de perder por falta de energia é a imagem 2
ECRA_COLISAO			EQU	3		; o ecrã de perder por colisão com a nave é a imagem 3
ECRA_DESISTE			EQU	4		; o ecrão de desistir do jogo voluntariamente é a imagem 4

; Constantes relativas aos bonecos
MIN_COLUNA				EQU 0		; número da coluna mais à esquerda que o objeto pode ocupar
HALF_COLUNA				EQU	31		; número da coluna a meio do ecrã
MAX_COLUNA				EQU 63     	; número da coluna mais à direita que o objeto pode ocupar
MAX_LINHA				EQU 31		; número da linha mais abaixo que o objeto pode ocupar

; Asteroides
LINHA_ASTEROIDE			EQU	0		; a linha inicial dos asteroides
ALTURA_ASTEROIDE 		EQU 4       ; altura do asteroide
ALTURA_ASTEROIDE_DESTRUIDO	EQU	5	; altura do asteroide destruído
LARGURA_ASTEROIDE		EQU	5		; largura do asteroides
FIX_OFFSET				EQU	2		; um offset para quando um asteroide aparece no canto superior direito
PSCREEN_ASTEROIDE_1		EQU 2		; o pixel screen dos asteroides 1 é o 2
PSCREEN_ASTEROIDE_2		EQU 3		; o pixel screen dos asteroides 2 é o 3
PSCREEN_ASTEROIDE_3		EQU 4		; o pixel screen dos asteroides 3 é o 4
PSCREEN_ASTEROIDE_4		EQU 5		; o pixel screen dos asteroides 4 é o 5
N_ASTEROIDES			EQU	4		; número de asteroides (até 4)
N_COMB_TIPO				EQU	16		; o número de tipo de asteroides da tabela de tipos de asteroide
N_COMB_ASTEROIDES		EQU	5		; corresponde ao número de combinações posição-direção de asteróides
ASTEROIDE_MAU			EQU	0		; indica que o tipo de asteroide é não minerável
ASTEROIDE_MINERAVEL		EQU	1		; indica que o tipo de asteroide é minerável


; Asteroides Mineráveis
LARGURA_ASTEROIDE_MIN	EQU 4		; largura do asteroide minerável
ALTURA_ASTEROIDE_MIN	EQU	3		; altura do asteroide minerável

; Sondas
ALTURA_SONDA            EQU 1       ; altura da sonda
LARGURA_SONDA           EQU 1       ; largura da sonda
PSCREEN_SONDA           EQU 1       ; o pixel screen das sondas é o 1
N_SONDAS                EQU 3       ; número de sondas (até 3)
LINHA_SONDA             EQU 27      ; linha inicial da sonda
VIDA_UTIL_SONDA_CONS    EQU 14      ; vida maxima/inicial da sonda 
									; (no nosso programa aparecer e desaparecer são considerados movimentos)
COLUNA_INICIAL_SONDA0   EQU 27		; coluna inicial da sonda da esquerda
COLUNA_INICIAL_SONDA1   EQU 32		; coluna inicial da sonda do meio
COLUNA_INICIAL_SONDA2   EQU 37		; coluna inicial da sonda da direita

; Nave
ALTURA_NAVE				EQU 5 		; altura da nave
LARGURA_NAVE			EQU 15 		; largura da nave
PSCREEN_NAVE			EQU	0 		; o pixel screen da nave é 0

; Painel da Nave
ALTURA_PAINEL 			EQU 2 		; altura do painel
LARGURA_PAINEL 			EQU 7       ; largura do painel
PSCREEN_PAINEL			EQU 1		; o pixel screen do painel é 1
ULTIMO_PAINEL			EQU	16		; existem 9 variantes do painel, sendo incremento 16 correspondente ao último

; Displays
DISPLAYS				EQU	0A000H	; endereço do display de 7 segmentos (periférico POUT-1)
ENERGIA_INICIAL			EQU	0064H	; a energia inicial da nave
ENERGIA_DECRESCIMO		EQU	0003H	; o valor a retirar a energia sempre que a rotina da energia ocorre
ENERGIA_DISPARO			EQU	0005H	; o valor a retirar a energia sempre que se dispara sonda
ENERGIA_FATOR			EQU 1000	; o fator inicial na conversão de hexadecimal para "decimal"
ENERGIA_MINERAVEL		EQU	001EH	; a energia a adicionar quando é minerável

; Cores
COR_VERMELHO			EQU	0FF00H	; cor vermelho RGB
COR_ROXO				EQU 0FB0FH 	; cor roxo RGB
COR_NADA				EQU	00000H	; cor transparente	
COR_LARANJA				EQU 0FFA0H	; cor laranja RGB
COR_VERDE 				EQU 0F0F0H	; cor verde RGB
COR_CIANO 				EQU 0F0FFH  ; cor ciano RGB
COR_AMARELO				EQU 0FFF0H 	; cor amarelo RGB
COR_ROSA				EQU 0FFAFH	; cor de rosa RGB
COR_CINZENTO			EQU 0FBBBH	; cor cinzento RGB
COR_CASTANHO			EQU 0F960H	; cor castanho RGB
COR_AZUL 				EQU 0F00FH 	; cor azul RGB
COR_PRETO               EQU 0F000H  ; cor preto RGB

TAMANHO_PILHA			EQU  100H   ; tamanho de cada pilha, em words

; Estados de jogo
ESTADO_A_JOGAR			EQU	0		; constante que representa o jogo em andamento
ESTADO_PAUSA			EQU	1		; constante que representa o jogo em pausa
ESTADO_FIM				EQU 2		; constante que representa o jogo terminado

; Teclas do jogo
TECLA_JOGO_COMEÇA		EQU	000CH	; tecla usada para começar o jogo
TECLA_JOGO_PARA			EQU	000DH	; tecla usada para parar/continuar o jogo
TECLA_JOGO_TERMINA		EQU	000EH	; tecla usada para terminar o jogo
TECLA_SONDA_ESQUERDA	EQU	0000H	; tecla usada para lançar a sonda para a esquerda	
TECLA_SONDA_FRENTE		EQU	0001H	; tecla usada para lançar a sonda em frente
TECLA_SONDA_DIREITA		EQU 0002H	; tecla usada para lançar a sonda para a direita

; Sons
MUSICA_FUNDO			EQU 0		; o som da música de jogo é o som 0
SOM_ASTEROIDES_MIN		EQU	1		; o som dos asteroides mineráveis é o som 1
SOM_ASTEROIDES_MAU		EQU	2		; o som dos asteroides "maus" é o som 2
SOM_SONDA               EQU 4       ; o som das sondas é o som 4
SOM_NAVE				EQU 5		; o som de colisão com a nave é o som 5
SOM_PAUSA				EQU 6		; o som do ecrã de pausa é o som número 6
SOM_DESISTE				EQU	7		; o som de desistir do jogo é som 7
SOM_INICIO				EQU	8		; o som do ínicio do jogo é som 8
SOM_ENERGIA				EQU	9		; o som de perder por falta de energia é o som 9

; Vídeos
VIDEO_JOGO				EQU	3		; o vídeo de fundo durante o jogo é o vídeo 3


; genérico
TRUE					EQU	1	
FALSE					EQU	0
PROXIMA_PALAVRA			EQU	2		; para se obter uma próxima palavra numa tabela
									; é preciso incrementar 2

; *********************************************************************************
; * Inicializar o Stack
; *********************************************************************************
	PLACE 1000H

; Reserva do espaço para as pilhas dos procesos

	STACK	TAMANHO_PILHA
SP_inicial_prog_princ:

	STACK	TAMANHO_PILHA
SP_inicial_teclado:

	STACK	TAMANHO_PILHA*N_ASTEROIDES
SP_inicial_asteroides:

	STACK	TAMANHO_PILHA*N_SONDAS
SP_inicial_sondas:

	STACK	TAMANHO_PILHA
SP_inicial_energia:
	
	STACK	TAMANHO_PILHA
SP_inicial_nave:

; *********************************************************************************
; * Variáveis
; *********************************************************************************

DEF_ASTEROIDE:          ; tabela que define o asteroide (largura, altura, cores)

                        WORD LARGURA_ASTEROIDE, ALTURA_ASTEROIDE
                        WORD COR_NADA, COR_AZUL, COR_AZUL, COR_AZUL, COR_NADA
                        WORD COR_NADA,  COR_CIANO, COR_AZUL, COR_CIANO, COR_NADA
                        WORD COR_NADA,  COR_AZUL, COR_AZUL, COR_AZUL, COR_NADA
                        WORD COR_AZUL, COR_NADA, COR_AZUL, COR_NADA, COR_AZUL	

DEF_ASTEROIDE_EXPLODE:	; tabela que define o asteroide quando explode

						WORD LARGURA_ASTEROIDE, ALTURA_ASTEROIDE_DESTRUIDO
                        WORD COR_NADA, COR_CINZENTO, COR_NADA, COR_CINZENTO, COR_NADA
                        WORD COR_CINZENTO, COR_NADA, COR_CINZENTO, COR_NADA, COR_CINZENTO
                        WORD COR_NADA, COR_CINZENTO, COR_NADA, COR_CINZENTO, COR_NADA
                        WORD COR_CINZENTO, COR_NADA, COR_CINZENTO, COR_NADA, COR_CINZENTO
                        WORD COR_NADA, COR_CINZENTO, COR_NADA, COR_CINZENTO, COR_NADA

DEF_ASTEROIDE_MIN_1:	; tabela que define o asteroide minerável (largura, altura, cores)

                        WORD LARGURA_ASTEROIDE_MIN, ALTURA_ASTEROIDE_MIN
                        WORD COR_CASTANHO, COR_PRETO, COR_PRETO, COR_CASTANHO
                        WORD COR_CASTANHO, COR_AMARELO, COR_AMARELO, COR_CASTANHO
                        WORD COR_CASTANHO, COR_CASTANHO, COR_CASTANHO, COR_CASTANHO

DEF_ASTEROIDE_MIN_EXPLODE:
						; tabela que define o asteroide minéravel quando explode
                        WORD LARGURA_ASTEROIDE_MIN, ALTURA_ASTEROIDE_MIN
                        WORD COR_NADA, COR_NADA, COR_NADA, COR_NADA
                        WORD COR_NADA, COR_VERDE, COR_VERDE, COR_VERDE
                        WORD COR_NADA, COR_NADA, COR_VERDE, COR_NADA
                        WORD COR_NADA, COR_NADA, COR_NADA, COR_NADA

DEF_SONDA:				; table que defina a sonda (largura, altura, cores)
						WORD LARGURA_SONDA, ALTURA_SONDA
						WORD COR_LARANJA

DEF_NAVE:				; table que defina a estrutura da nave
						WORD LARGURA_NAVE, ALTURA_NAVE
						WORD COR_NADA,COR_NADA,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_VERMELHO,COR_NADA,COR_NADA
						WORD COR_NADA,COR_VERMELHO,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_VERMELHO,COR_NADA
						WORD COR_VERMELHO,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_VERMELHO
						WORD COR_VERMELHO,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_NADA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_VERMELHO
						WORD COR_VERMELHO,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_LARANJA,COR_VERMELHO

DEF_NAVE_PAINEIS:		; table que define as diferentes versões do painel de luzes da nave
						WORD DEF_NAVE_PAINEL_0
						WORD DEF_NAVE_PAINEL_1
						WORD DEF_NAVE_PAINEL_2
						WORD DEF_NAVE_PAINEL_3
						WORD DEF_NAVE_PAINEL_4
						WORD DEF_NAVE_PAINEL_5
						WORD DEF_NAVE_PAINEL_6
						WORD DEF_NAVE_PAINEL_7
						WORD DEF_NAVE_PAINEL_8

DEF_NAVE_PAINEL_0:		; table que define a variante do painel 0
						WORD LARGURA_PAINEL, ALTURA_PAINEL
						WORD COR_ROXO, COR_VERMELHO, COR_CINZENTO, COR_VERDE, COR_CIANO, COR_AMARELO, COR_VERMELHO
						WORD COR_LARANJA, COR_VERDE, COR_CIANO, COR_AMARELO, COR_VERMELHO, COR_ROXO, COR_VERMELHO

DEF_NAVE_PAINEL_1:		; table que define a variante do painel 1
						WORD LARGURA_PAINEL, ALTURA_PAINEL
						WORD COR_CINZENTO, COR_ROXO, COR_CIANO, COR_VERDE, COR_CINZENTO, COR_CINZENTO, COR_CINZENTO
						WORD COR_CINZENTO, COR_CINZENTO, COR_CINZENTO, COR_CINZENTO, COR_VERMELHO, COR_AMARELO, COR_ROSA

DEF_NAVE_PAINEL_2:		; table que define a variante do painel 2
						WORD LARGURA_PAINEL, ALTURA_PAINEL
                        WORD COR_VERMELHO, COR_ROXO, COR_AMARELO, COR_VERDE, COR_CINZENTO, COR_CIANO, COR_VERMELHO
                        WORD COR_CIANO, COR_VERDE, COR_CIANO, COR_CINZENTO, COR_VERMELHO, COR_AMARELO, COR_ROSA

DEF_NAVE_PAINEL_3:		; table que define a variante do painel 3
						WORD LARGURA_PAINEL, ALTURA_PAINEL
                        WORD COR_VERMELHO, COR_ROSA, COR_VERDE, COR_CINZENTO, COR_CINZENTO, COR_AMARELO, COR_VERMELHO
                        WORD COR_ROXO, COR_CINZENTO, COR_CIANO, COR_ROSA, COR_CIANO, COR_VERMELHO, COR_VERDE

DEF_NAVE_PAINEL_4:		; table que define a variante do painel 4
						WORD LARGURA_PAINEL, ALTURA_PAINEL
                        WORD COR_ROXO, COR_VERMELHO, COR_CINZENTO, COR_VERDE, COR_CIANO, COR_VERMELHO, COR_AMARELO
                        WORD COR_CIANO, COR_ROXO, COR_VERMELHO, COR_AMARELO, COR_VERDE, COR_ROXO, COR_VERMELHO

DEF_NAVE_PAINEL_5:		; table que define a variante do painel 5
						WORD LARGURA_PAINEL, ALTURA_PAINEL
                        WORD COR_CINZENTO, COR_CASTANHO, COR_ROSA, COR_VERMELHO, COR_CIANO, COR_AMARELO, COR_ROXO
                        WORD COR_ROXO, COR_CIANO, COR_VERDE, COR_ROXO, COR_VERMELHO, COR_VERDE, COR_VERMELHO

DEF_NAVE_PAINEL_6:		; table que define a variante do painel 6
						WORD LARGURA_PAINEL, ALTURA_PAINEL
						WORD COR_AZUL, COR_VERMELHO, COR_VERDE, COR_VERMELHO, COR_VERDE, COR_CINZENTO, COR_VERMELHO
						WORD COR_ROSA, COR_VERDE, COR_ROXO, COR_CINZENTO, COR_AMARELO, COR_ROSA, COR_CIANO

DEF_NAVE_PAINEL_7:		; table que define a variante do painel 7
						WORD LARGURA_PAINEL, ALTURA_PAINEL
						WORD COR_ROXO, COR_AZUL, COR_ROXO, COR_VERDE, COR_AZUL, COR_AMARELO, COR_AZUL
						WORD COR_AMARELO, COR_VERDE, COR_VERMELHO, COR_CINZENTO, COR_CASTANHO, COR_ROXO, COR_VERMELHO

DEF_NAVE_PAINEL_8:		; table que define a variante do painel 8
						WORD LARGURA_PAINEL, ALTURA_PAINEL
						WORD COR_ROXO, COR_CINZENTO, COR_VERMELHO, COR_ROSA, COR_CIANO, COR_AZUL, COR_AMARELO
						WORD COR_VERMELHO, COR_CASTANHO, COR_ROXO, COR_CINZENTO, COR_AMARELO, COR_ROXO, COR_VERMELHO

; Variáveis relacionadas à Nave e Painel

LINHA_NAVE: 			WORD 27					; ao inicio a linha da nave é a 27
COLUNA_NAVE:			WORD 25					; ao inicio a linha da nave é a 25

LINHA_CANTO_INF_DIR:     WORD 31				; linha do canto inferior direito da nave
COLUNA_CANTO_INF_DIR:     WORD 40				; coluna do canto inferior direito da nave


LINHA_PAINEL: 			WORD 29					; ao inicio a linha do painel é a 29
COLUNA_PAINEL: 			WORD 29					; ao inicio a coluna do painel é a 27
PAINEL_ATUAL:			WORD 0					; variável para fazer loops das variantes do painel

; Variáveis relacionadas aos Asteroides

linhas_asteroide:								; linha em que cada asteroide está
	WORD	LINHA_ASTEROIDE
	WORD	LINHA_ASTEROIDE
	WORD	LINHA_ASTEROIDE
	WORD	LINHA_ASTEROIDE

colunas_asteroide:								; coluna em que cada asteroide está
												; é indifirente, pois é escolhida aleatoriamente no aparecimento
	WORD	0
	WORD	0
	WORD	0
	WORD	0

sentido_asteroide:								; sentido para que cada asteroide se desloca
												; é indifirente, pois é escolhida aleatoriamente no aparecimento
	WORD	0
	WORD	0
	WORD	0
	WORD	0

existencia_asteroide:							; mostra se os asteroide já sairam dos limites do ecrã
	
	WORD	0
	WORD	0
	WORD	0
	WORD	0

tipo_asteroide:									; contém o tipo de cada asteroide
												; é indifirente, pois é escolhida aleatoriamente no aparecimento
												; existe 25% de probabilidade do asteroide ser minerável
	WORD	0
	WORD	0
	WORD	0
	WORD	0

comb_asteroides:								; representas as combinações possíveis de posição-direção de um asteroide
	WORD	comb_asteroides_1
	WORD	comb_asteroides_2
	WORD	comb_asteroides_3
	WORD	comb_asteroides_4
	WORD	comb_asteroides_5

comb_asteroides_1: 								; canto superior esquerdo na direção do centro
	WORD	MIN_COLUNA							
	WORD	1									 	

comb_asteroides_2:								; meio na direção do canto inferior esquerdo
	WORD	HALF_COLUNA
	WORD	-1

comb_asteroides_3:								; meio na direção do centro
	WORD	HALF_COLUNA
	WORD	0

comb_asteroides_4:								; meio na direção do conta inferior direito
	WORD	HALF_COLUNA
	WORD	1

comb_asteroides_5:								; canto superior direito na direção do centro
	WORD	MAX_COLUNA							; é necessário fazer um offset da largura do asteroide se calhar esta							
	WORD	-1	

comb_asteroides_tipo:							; tabela com uma sequência "aleatória" de tipos de asteroide
	WORD	ASTEROIDE_MAU
	WORD	ASTEROIDE_MINERAVEL
	WORD	ASTEROIDE_MAU
	WORD	ASTEROIDE_MAU

comb_asteroides_tipo_contador: WORD 0			; contandor que iterar sobre a sequência de tipos de asteroide

screens_asteroide:								; tabela com os pixelscreens de cada asteroide
	WORD	PSCREEN_ASTEROIDE_1
	WORD	PSCREEN_ASTEROIDE_2
	WORD	PSCREEN_ASTEROIDE_3
	WORD	PSCREEN_ASTEROIDE_4

; Variáveis relacionadas as Sondas

linhas_sonda:									; tabela com a linha atual de cada sonda
    WORD    LINHA_SONDA
    WORD    LINHA_SONDA
    WORD    LINHA_SONDA

colunas_sonda:									; tabela com a coluna atual de cada sonda
    WORD    COLUNA_INICIAL_SONDA0  
    WORD    COLUNA_INICIAL_SONDA1
    WORD    COLUNA_INICIAL_SONDA2

vida_util_sonda:								; tabela com a "vida" de cada sonda 
												;(o número de passos que podem ainda dar)
    WORD    VIDA_UTIL_SONDA_CONS
    WORD    VIDA_UTIL_SONDA_CONS
    WORD    VIDA_UTIL_SONDA_CONS

existencia_sonda:								; tabela que indica se cada sonda existe
    WORD    0
    WORD    0
    WORD    0

sentido_sonda:									; tabela com os sentidos de cada sonda
    WORD    -1
    WORD    0
    WORD    1
  

; Tabela das rotinas de interrupção
tab:
	WORD 	rot_int_0							; rotina de atendimento da interrupção 0
	WORD 	rot_int_1							; rotina de atendimento da interrupção 1
	WORD 	rot_int_2							; rotina de atendimento da interrupção 2
	WORD 	rot_int_3							; rotina de atendimento da interrupção 3

; Tabela com os LOCKS para os eventos de cada interrupção
evento_int:
	LOCK	0									; LOCK para a rotina de interrupção 0
	LOCK	0									; LOCK para a rotina de interrupção 1
	LOCK	0									; LOCK para a rotina de interrupção 2
	LOCK	0									; LOCK para a rotina de interrupção 3

; Tecla carregada
tecla_carregada:
	LOCK	0									; LOCK para o teclado comunicar aos processos a tecla presisonada

; Variáveis de desenrolar de jogo
estado_jogo:	LOCK	0						; este LOCK irá travar os processos quando uma pausa ocorre   
				WORD	ESTADO_FIM				; Varíavel com a fase do jogo (jogável, pausado, fim)

energia_atual: WORD ENERGIA_INICIAL				; corresponde à energia atual da nave (inicialmente 100% isto é 64H)

;**********************************************************************
;* Código
;**********************************************************************
PLACE 0
inicio:
		MOV		SP, SP_inicial_prog_princ 		; inicializa o SP do programa principal
		MOV		BTE, tab				  		; inicializa o BTE (registo da Base da Tabela de Exceções)
		MOV		[APAGA_AVISO], R1			
		MOV		[APAGA_ECRÃS], R1
		

		; damos enable aos pinos de interrupção
		EI0								
		EI1
		EI2
		EI3
		EI 		

		; criação de processos
		CALL	teclado
		CALL	energia
		CALL	nave	

		MOV		R11, N_ASTEROIDES			; número de asteroides a usar
loop_asteroides:
		SUB		R11, 1						; próximo asteroide
		CALL	asteroide

		CMP		R11, 0						; já criou todas as instâncias?
		JNZ		loop_asteroides				; se não, continua

		MOV		R11, N_SONDAS				; número de sondas a usar
loop_sondas:
		SUB		R11, 1						; próxima sonda
		CALL	sonda

		CMP		R11, 0						; já criou todas as instâncias?
		JNZ		loop_sondas					; se não, continua


		MOV		R1, ECRA_INICIO
		MOV		[SELECIONA_CENARIO_FUNDO], R1
		MOV		R1, SOM_INICIO
		MOV		[TOCA_SOM], R1

		; o resto do programa principal é o processo de controlo

;**********************************************************************
;CONTROLO - Processo que trata das teclas de começar, suspender/continuar
;		e terminar o jogo
;**********************************************************************

controlo:	
	MOV		R0, [tecla_carregada]			; espera até alguma tecla ser pressionada

	MOV		R2, estado_jogo					; +0: corresponde ao LOCK, +2: varíavel do estado do jogo

	MOV		R1, TECLA_JOGO_COMEÇA	
	CMP		R0, R1							
	JZ		controlo_tecla_comeca			; se for premida a tecla de começar o jogo (C)	

	MOV		R1, TECLA_JOGO_PARA		
	CMP		R0, R1							
	JZ		controlo_tecla_para				; se for premida a tecla de parar o jogo (D)	

	MOV		R1, TECLA_JOGO_TERMINA
	CMP		R0, R1
	JZ		controlo_tecla_termina			; se for premida a tecla de terminar o jogo (E)	

	JMP		controlo

controlo_tecla_comeca:						; lidar com tecla de começo
	; apaga imagem de fundo
	; muda para música e vídeo de fundo jogo
	; Altera o estado_jogo (desloqueia LOCK e coloca ESTADO_A_JOGAR)

	MOV		R1, [R2+2]
	MOV		R3, ESTADO_FIM
	CMP		R1, R3							; se o estado do jogo não for fim
	JNZ		controlo_tecla_comeca_fim		; então a tecla não tem efeito	

	MOV		R1, ESTADO_A_JOGAR
	MOV		[R2+2], R1						; indica que o programa estará a jogar

	MOV		[APAGA_CENARIO_FUNDO],R5		; apaga o antigo cenário de fundo
	MOV		R1, VIDEO_JOGO					; corresponde ao video que dá em loop no jogo
	MOV		[LOOP_MEDIA], R1				; mete o video a dar em loop

	MOV		R1, MUSICA_FUNDO				; corresponde à música que dá no jogo
	MOV		[LOOP_MEDIA], R1				; fica a loopar

	MOV		R1, ENERGIA_INICIAL
	MOV		[energia_atual], R1				; dá reset à energia
	CALL	energia_converte				; converte a energia
	MOV		[DISPLAYS], R1					; mostra a energia 

	EI0										; volta a dar enable às interrupções
	EI1
	EI2
	EI3
	EI

	MOV		[R2+0], R1						; desbloqueia o LOCK
controlo_tecla_comeca_fim:

	JMP		controlo

controlo_tecla_para:						; lidar com tecla de suspensão/continuação

	MOV		R1, [R2+2]						; obtém estado atual do programa			
	MOV		R0, ESTADO_A_JOGAR
	CMP		R1, R0							; se o estado atual for a jogar
	JZ		controlo_tecla_para_jogar

	MOV		R0, ESTADO_PAUSA
	CMP		R1, R0							; se o estado atual do jogo for pausa
	JZ		controlo_tecla_para_pausa		

	JMP		controlo_tecla_para_final		; se for fim, não faz nada

controlo_tecla_para_jogar:			
	; se for ESTADO_JOGO:
	; Altera o estado_jogo (coloca ESTADO_PAUSA)
	; desenha um cenário por cima e toca som da pausa
	MOV		R1, ESTADO_PAUSA
	MOV		[R2+2], R1						; passa o estado de jogo para pausa
	DI 
	MOV		[PAUSE_MEDIA_ALL], R5			; pausa a musica e video de fundo

	MOV		R1, SOM_PAUSA
	MOV		[TOCA_SOM], R1					; toca o som de pausa sempre que entra/sai de uma

	MOV		R1, ECRA_PAUSA			
	MOV		[SELECIONA_CENARIO_FRENTE], R1	; coloca um cenário à frente do jogo de pausa

	JMP		controlo_tecla_para_final

controlo_tecla_para_pausa:
	; se for ESTADO_PAUSA:
	; Altera o estado_jogo (coloca ESTADO_JOGO e desbloqueia LOCK)
	; retira o cenário de cima

	MOV		[APAGA_CENARIO_FRENTE], R5 		; apaga o cenário frontal colocado na pausa
	MOV		[CONTINUE_MEDIA_ALL], R5	
	MOV		R1, ESTADO_A_JOGAR
	MOV		[R2+2], R1						; passa o estado de jogo para a jogar
	MOV		[R2+0], R5						; desbloqueia o LOCK para o programa continuar

	EI0										; volta a dar enable às interrupções
	EI1
	EI2
	EI3
	EI

controlo_tecla_para_final: 
	JMP		controlo

controlo_tecla_termina:						; lidar com tecla de termino
	; retira o cenário de cima (se houver)
	; apaga tudo no ecrã
	; toca som de fim de jogo
	; Altera o estado_jogo (coloca ESTADO_FIM)

	MOV		R1, [R2+2]						; obtém estado atual do programa			
	MOV		R0, ESTADO_FIM
	CMP		R1, R0							; se o estado atual já for fim, não faz nada
	JZ		controlo_tecla_termina_fim

	MOV		[R2+0], R5						; desbloqueia o LOCK para o programa mudar de estado

	MOV		R1, ESTADO_FIM
	MOV		[R2+2], R1						; passa o estado de jogo para fim

	MOV		[APAGA_CENARIO_FUNDO], R5
	MOV		[APAGA_CENARIO_FRENTE], R5 
	MOV		[APAGA_ECRÃS], R5				; apaga tudo o que está desenhado
	MOV		[STOP_MEDIA_ALL], R5			; para todos os media que estejam a dar
	MOV		R1, ECRA_DESISTE	
	MOV		[SELECIONA_CENARIO_FUNDO], R1	; coloca o cenário de fundo de desistir
	MOV		R1, SOM_DESISTE
	MOV		[TOCA_SOM], R1					; toca o som de desistir

	DI										; dá disable às interrupções

controlo_tecla_termina_fim:
	JMP		controlo



;**********************************************************************
;TECLADO - Processo que deteta quando se carrega numa tecla do teclado
;	e escreve o valor obtido num LOCK 
;**********************************************************************

PROCESS SP_inicial_teclado			; inicializa o processo teclado

teclado:
	MOV  	R2, TEC_LIN				; endereço do periférico das linhas
	MOV  	R3, TEC_COL				; endereço do periférico das colunas
	MOV  	R5, NIBL_LOW			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

espera_tecla_reset:					; dá-se reset ao iterador (isto é volta a ser a 4ªlinha após ser a 1ª)

	WAIT							; se não houver tecla nenhuma a ser pressionada, adormece processo
	MOV  	R1, LIN_INIT

espera_tecla_linha:					; neste ciclo espera-se até uma tecla ser premida (numa certa linha)
	
	YIELD							; este ciclo é potencialmente bloqueante, pelo que tem de
									; ter um ponto de fuga (aqui pode comutar para outro processo)

	MOVB 	[R2], R1				; escrever no periférico de saída (linhas)
	MOVB 	R0, [R3]				; ler do periférico de entrada (colunas)
	AND  	R0, R5					; elimina bits para além dos bits 0-3
	JNZ  	ha_tecla_1_vez			; se há tecla premida, quebra o ciclo
	
	SHR		R1,	1					; passa para a linha anterior 	
	JZ		espera_tecla_reset		; R1 volta a ser a linha 4
	JMP		espera_tecla_linha		; repete o ciclo

ha_tecla_1_vez:						; dá LOCK há varíavel de tecla pressionada

	CALL	teclado_conversao		; converte o valor das coordenadas da tecla para um de 0-F
	MOV		[tecla_carregada], R0	; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada

ha_tecla:							; neste ciclo espera-se até NENHUMA tecla estar premida

	YIELD							; este ciclo é potencialmente bloqueante, pelo que tem de
									; ter um ponto de fuga (aqui pode comutar para outro processo)								

    MOVB 	[R2], R1				; escrever no periférico de saída (linhas)
    MOVB 	R0, [R3]				; ler do periférico de entrada (colunas)
	AND  	R0, R5					; elimina bits para além dos bits 0-3
    CMP  	R0, 0					; há tecla premida?
    JNZ  	ha_tecla				; se ainda houver uma tecla premida, espera até não haver

	JMP		espera_tecla_reset		; esta "rotina" nunca retorna porque nunca termina


;TECLADO_CONVERSAO: Converte as coordenadas de uma tecla (ou seja a sua linha e coluna)
;	numa valor de 0-F correspondente a sua etiqueta.
; Argumentos: R0,R1
; Return: R0

teclado_conversao:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	MOV		R3, N_LINHAS			; corresponde ao número de linhas do teclado
	MOV 	R2, R1					; copia o valor da linha para o valor temporario
	CALL 	teclado_conversao_num	; converte o valor temporario de 1,2,4,8 para 0,1,2,3
	MOV		R1, R2					; a linha passa a ter o valor convertido
	MOV		R2, R0					; copia o valor da coluna para o valor temporario
	CALL 	teclado_conversao_num	; converte o valor temporario de 1,2,4,8 para 0,1,2,3
	MOV 	R0, R2					; a coluna passa a ter o valor convertido
	MUL		R1, R3					; 4*linhas
	ADD		R0, R1					; 4*linhas + colunas = tecla premida

	POP		R3 
	POP		R2
	POP		R1
	RET	


; TECLADO_CONVERSAO_NUM: Converte um numero de 1,2,4,8 para 0,1,2,3 
; (através da contagem de SHR continuos até chegar ao zero)
; Argumentos: R2
; Return: R2
teclado_conversao_num:			
	PUSH	R1		
	MOV		R1, -1 					; o contandor de SHR 

teclado_conversao_num_loop:
	ADD     R1, 1					; incrementa o contandor
	SHR		R2, 1 					; faz o shift right
	JZ      teclado_conversao_num_fim; se o numero não convertido já tiver chegado a zero, termina
	JMP 	teclado_conversao_num_loop; caso contrário continua a fazer SHR

teclado_conversao_num_fim:
	MOV 	R2,R1					; passa o valor temporário para o retorno
	POP 	R1
	RET

; **********************************************************************
; ASTEROIDES - Processo que controla os asteroides e verifica as colisões
;	com nave e sondas
; **********************************************************************
PROCESS SP_inicial_asteroides

; Verificar se está em pausa ou no fim
;		-> Pausa: espera-se até jogo resumido
;		-> Fim:	apagam-se e dão-se reset aos asteroides e espera-se até jogo resumido

; Verifica se o asteroide correspondente existe (na tabela)
;		-> Sim:	Continua
;		-> Nao: Chama rotina de escolha aleatória (escolhe o tipo de asteroide, posição e direção que terá) 
;			e coloca-o em jogo (passa a existir na tabela)

; Verificamos se ocorre colisão na sua posição atual (chamando uma rotina que verifica se bate na nave e outra que verifica se bate na sonda)
;		-> Nao: Continua
;		-> Sim: Chama rotina que lida com a colisão (minerável dá energia contra sonda, asteroide desaperece contra sonda, contra nave game over)

; Deslocam-se (apagando posição atual, usando os incrementos da tabela e chegando à nova posição)

; Verifica-se se já saiu do ecrã (chamando rotina que tem em conta a direção em que se desloca)
;		-> Nao: Continua
;		-> Sim: Apaga asteroide e diz-se que já não existe

asteroide:
	MOV		R0, TAMANHO_PILHA
	MUL		R0, R11					; multiplica o tamanho de um processo pelo nº de instância
	SUB		SP, R0					; inicializa o SP deste asteroide (subtraindo o valor necessário)

	MOV		R10, R11				; cópia do nº da instância do boneco
	SHL		R10, 1					; multiplica por 2 pois as tabelas são WORDs

asteroide_loop_pausa:
	MOV		R1, [estado_jogo+0]		; fica à espera até que volte a ser resumido o jogo
	JMP		asteroide_loop			; depois pode simplesmente continuar normalmente

asteroide_loop_reset:
	CALL	apaga_asteroide			; apaga o asteroide (o seu pixel screen inteiro)
	CALL	reset_asteroide			; coloca as posições iniciais no asteroide
	MOV		R1, [estado_jogo+0]		; fica à espera que o estado mude para jogável

asteroide_loop:
	
	MOV		R1, estado_jogo
	MOV		R1, [R1+2]				; obtém o estado do jogo atual
									; se for tanto fim como pausa deve voltar ao loop de inicialização	
	MOV		R0, ESTADO_FIM
	CMP		R1, R0
	JZ		asteroide_loop_reset

	MOV		R0, ESTADO_PAUSA
	CMP		R1, R0
	JZ		asteroide_loop_pausa

	MOV		R0, [evento_int+0]		; a rotina de interrupção 0 é a associada ao relógio dos asteróides

asteroide_existe:					; verifica se o asteróide correspondente existe
	MOV		R7, existencia_asteroide
	MOV		R1, [R7+R10]			
	CMP		R1, 0					; R1 é 0 se o ainda não existir
	JNZ		asteroide_colisao		; se já existir pode passar ao próximo check

asteroide_nao_existe:
	CALL	gerador_asteroide		; gera um asteroide com direção, posição e tipo aleatório
	MOV		R1, TRUE				; asteroide já existe 
	MOV		[R7+R10], R1			; atualiza a tabela de "existência"

asteroide_colisao:				
	MOV		R8, screens_asteroide	; tabela com pointers para os diferentes pixels screens para cada asteroide
	MOV		R1, [R8+R10]			; obtém o pixel screen correspondente a esta instância do asteroide
	MOV		[SELECIONA_ECRA], R1	; seleciona esse pixel screen para futuros desenhos neste processo 
	CALL	trata_colisao			; verifica e trata caso o asteroide colidiu com a nave ou uma das sondas
	CMP		R1, 1					; vê-se se houve uma colisão
	JZ		asteroide_loop_fim	; se sim, então o jogo perde, e dá-se reset 
	JMP		asteroide_deslocamento	; caso contrário, continua o deslocamento

asteroide_deslocamento:				; desloca o asteroide se este não tiver colidido
	MOV		R6, sentido_asteroide
	ADD		R6, R10
	MOV		R7, colunas_asteroide
	ADD		R7, R10
	MOV		R8, linhas_asteroide
	ADD		R8, R10
	MOV		R9, tipo_asteroide
	ADD		R9, R10
	MOV		R2, R7					; obtém coluna do asteroíde desta instância
	MOV		R1, R8					; obtém linha do asteroíde desta instância
	MOV		R4, [R9]				; obtém tipo do asteroíde desta instância
	CALL	determina_def_asteroide ; passa o R4 do tipo de asteroide para a definição correspondente
	CALL	apaga_boneco			; apaga a posição anterior desta instância do asteroide
	MOV		R1, [R1]
	MOV		R2, [R2]
	ADD		R1, 1					; a linha desce sempre 1
	MOV		R3, [R6]				; corresponde ao incremento gerador (sentido do asteroide)
	ADD		R2, R3					; soma-se à coluna atual o incremento
	MOV		[R8], R1				; atualiza a linha na varíavel global
	MOV		[R7], R2 				; atualiza a coluna na varíavel global
	MOV		R2, R7					; obtém coluna do asteroíde desta instância
	MOV		R1, R8					; obtém linha do asteroíde desta instância
	CALL	desenha_boneco

asteroide_limites:					; verifica se o asteroide ainda se encontra nos limites do ecrã
	MOV		R1, [R1]				; R1 passa a ter o valor da linha (em vez de pointer)
	CALL 	verifica_limites
	CMP		R1, 0
	JZ		asteroide_loop_fim		; se não sai dos limites, então passa à próxima iteração

asteroide_limites_saiu:				; se saiu, então passa a não existir 
	MOV		R7, existencia_asteroide
	MOV		R8, FALSE
	MOV		[R7+R10], R8
	MOV		R7, linhas_asteroide
	MOV		R8, LINHA_ASTEROIDE		; a sua linha volta a ser 0
	MOV		[R7+R10], R8	

asteroide_loop_fim:					; final do loop dos asteroides
	JMP		asteroide_loop

; APAGA_ASTEROIDE: Apaga o pixel screen deste asteroide
; Argumento: R10 (nº instância)
apaga_asteroide:
	PUSH	R0
	MOV		R0, screens_asteroide
	MOV		R0, [R0+R10]			; seleciona o pixel screen do asteroide
	MOV		[APAGA_ECRA], R0		; apaga-o
	POP		R0
	RET	

; RESET_ASTEROIDE: Reinicia a linha e existência do asteroide
; Argumento: R10 (nº instância)
reset_asteroide:
	PUSH	R0
	PUSH	R1
	MOV		R0, linhas_asteroide
	MOV		R1, LINHA_ASTEROIDE
	MOV		[R0+R10], R1 

	MOV		R0, existencia_asteroide
	MOV		R1, 0
	MOV		[R0+R10], R1

	POP		R1
	POP		R0
	RET

; GERADOR_ASTEROIDE: Gera um asteroide aleatório, isto é:
;	a sua coluna inicial, sentido do movimento, tipo de asteroide
; Argumento: R10 (nº instância)
gerador_asteroide:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3 
	PUSH	R4
	PUSH	R5
	PUSH	R6
	PUSH	R7

gerador_asteroide_posicao:							

	MOV		R2, N_COMB_ASTEROIDES				; corresponde ao número de valores possíveis que podem ser gerados
	CALL	gera_numero_aleatorio				; R6 receberá número aleatório de 0 a N_COMB_ASTEROIDES-1
	SHL		R6, 1								; multiplica-se por 2 para obter o endereço correto na tabela					
	MOV		R1, comb_asteroides					; tabela com as diferentes combinações coluna-incremento
	ADD		R6, R1					
	MOV		R4, [R6]							; corresponde à combinação obtida
	MOV		R2, [R4+0]							; corresponde à coluna inicial do asteroide dessa combinação
	MOV		R5, MAX_COLUNA
	CMP		R2, R5								; vê se calhou o canto superior direito
	JNZ		gerador_asteroide_posicao_assign	; se não calhou pode continuar, caso contrário retira-se a largura

gerador_asteroide_posicao_offset:				; faz um asset à coluna inicial se esta corresponder ao limite direito do ecrã
	SUB		R2, LARGURA_ASTEROIDE				; retira-se a largura de um asteroide
	ADD		R2, FIX_OFFSET						; um fix para as sondas conseguirem bater sempre independentemente do tipo

gerador_asteroide_posicao_assign:
	MOV		R3, [R4+2]							; corresponde ao incremento no nº de colunas (sentido) dessa combinação
	MOV		R4, colunas_asteroide
	MOV		[R4+R10], R2						; a coluna desta instância de asteroide
	MOV		R4, sentido_asteroide	
	MOV		[R4+R10], R3						; o sentido (incremento) desta instância de asteroide

gerador_asteroide_tipo:
	MOV		R2, N_ASTEROIDES
	CALL	gera_numero_aleatorio				; R6 receberá número aleatório de 0 a N_ASTEROIDES
	MOV		R1, comb_asteroides_tipo
	SHL		R6, 1								; multiplica-se por 2 para obter o endereço correto na tabela	
	ADD		R6, R1								; obtém-se o endereço correto na tabela
	MOV		R4, [R6]							; obtém-se o tipo gerado
	MOV		R2, tipo_asteroide					; tabela com o tipo de asteroide de cada instância
	MOV		[R2+R10], R4						; guarda o tipo desta instância do asteroide

gerador_asteroide_fim:
	POP		R7
	POP		R6
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	RET 

; TRATA_COLISAO: Verifica e trata se o asteroide colidiu ou com sondas ou com a nave
; Argumentos: R10 - instância do asteroide
; Return: R1 - (0 se não houve colisão, 1 se houve)
trata_colisao: 
	PUSH	R0
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R6
	PUSH	R7
	PUSH	R8
	PUSH	R9

	MOV		R6, linhas_asteroide
	MOV		R6, [R6+R10]					; obtém a linha de asteroide
	MOV		R7, colunas_asteroide
	MOV		R7, [R7+R10]					; obtém a coluna de asteroide
	MOV		R8, tipo_asteroide
	MOV		R8, [R8+R10]					; obtém o tipo de asteroide
	CALL	determina_dim_asteroide			; determina as dimensões do tipo de asteroide

trata_colisao_sonda:						; verifica se o asteroide colide com uma das sondas
	MOV		R4, ALTURA_SONDA
	MOV		R5, LARGURA_SONDA
	MOV		R0, N_SONDAS
	MOV		R2, PROXIMA_PALAVRA
	SUB		R0, 1							; pois a primeira posição na tabela de sondas é 0 e não 1
	MUL		R0, R2							; para obter o equivalente ao R10 das sondas,
											; isto é,as suas instâncias			

trata_colisao_sonda_loop_check:				; antes de ver se colidem, vê se a sonda existe
	MOV		R2, existencia_sonda
	MOV		R2, [R2+R0]
	CMP		R2, FALSE						; vê se a sonda existe, se não existir não verifica se colide
	JZ		trata_colisao_sonda_loop_incremento

trata_colisao_sonda_loop:

	MOV		R2, linhas_sonda
	MOV		R2, [R2+R0]						; obtém as linhas desta instância da sonda
	MOV		R3, colunas_sonda
	MOV		R3, [R3+R0]						; obtém as colunas desta instância da sonda

	CALL	verifica_colisao				; vê se a sonda e o asteroide colidem
	CMP		R1, TRUE						
	JZ		trata_colisao_sonda_ocorre		; se colidem, faz as operações necessárias
											; se não colidem, vê se a próxima o faz

trata_colisao_sonda_loop_incremento:		; passa à sonda seguinte
	MOV		R2, PROXIMA_PALAVRA							
	SUB		R0, R2 							; subtraí 2 para obter a instância da próxima
	MOV		R2, 0							; como a última instância é 0 (1ª sonda), vemos se é menor
	CMP		R0, R2							; já vimos as sondas todas ?
	JLT		trata_colisao_nave				; se sim pode agora ver se colide com a nave
	JMP		trata_colisao_sonda_loop_check	; senão passa à próxima sonda

trata_colisao_sonda_ocorre:					; faz as operações referentes à colisão sonda - asteroide
	; sonda deixa de existir
	; se o tipo for minéravel, dá 30 de energia
	; se o tipo for minerável, toca um certo som
	; se o tipo for minerável, faz um certa animação
	; se o tipo for mau, toca um certo som
	; se o tipo for mau, faz uma certa animação
	; o asteroide deixa de existir
	; R0 fica TRUE
	; termina a rotina
	MOV		R2, existencia_sonda
	MOV		R3, FALSE
	MOV		[R2+R0], R3						; a instância da sonda deixa de existir

	MOV		R0, screens_asteroide
	MOV		R0, [R0+R10]					; obtém-se o pixel screen do asteroide
	MOV		[SELECIONA_ECRA], R0			; seleciona-se o pixel screen do asteroide

	MOV		R2, tipo_asteroide
	MOV		R2, [R2+R10]					; obtém o tipo do asteroide que colidiu

	CMP		R2, ASTEROIDE_MAU			
	JZ		trata_colisao_sonda_ocorre_mau	; se for não minerável trata esse tipo de colisão

trata_colisao_sonda_ocorre_min:				; lida com colisões entre asteroides mineráveis e sondas
	
	MOV		R2, [energia_atual]
	MOV		R3, ENERGIA_MINERAVEL
	ADD		R2, R3							; adiciona a energia que se obtém de minerar à atual
	MOV		[energia_atual], R2				; atualiza-se a energia atual
	MOV		R1, R2
	CALL	energia_converte
	MOV		[DISPLAYS], R1					; dá display à energia atualizada

	MOV		R1, linhas_asteroide
	ADD		R1, R10							; obtem-se a linha do asteroide
	MOV		R2, colunas_asteroide
	ADD		R2, R10							; obtem-se a coluna do asteroide
	MOV		R4, DEF_ASTEROIDE_MIN_1			; obtem-se a definição do asteroide minerável
	CALL	apaga_boneco					; apaga-se o asteroide

	MOV		R4, DEF_ASTEROIDE_MIN_EXPLODE	; obtem-se a definição da explosão do minerável
	CALL	desenha_boneco					; desenha-se a explosão

	MOV		R3, SOM_ASTEROIDES_MIN
	MOV		[TOCA_SOM], R3					; toca o som do asteroide minerável

	JMP		trata_colisao_sonda_ocorre_fim	

trata_colisao_sonda_ocorre_mau:				; lida com colisões entre asteroides "maus" e sondas
	
	MOV		R1, linhas_asteroide
	ADD		R1, R10							; obtem-se a linha do asteroide
	MOV		R2, colunas_asteroide
	ADD		R2, R10							; obtem-se a coluna do asteroide
	MOV		R4, DEF_ASTEROIDE				; obtem-se a definição do asteroide "mau"
	CALL	apaga_boneco					; apaga-se o asteroide

	MOV		R4, DEF_ASTEROIDE_EXPLODE		; obtem-se a definição da explosão do "mau"
	CALL	desenha_boneco					; desenha-se a explosão

	MOV		R3, SOM_ASTEROIDES_MAU
	MOV		[TOCA_SOM], R3					; toca o som do asteroide mau

trata_colisao_sonda_ocorre_fim:				; o fim comum de lidar com colisões asteroide-sonda

	MOV		R5, [evento_int+0]				; espera-se pelo próximo ciclo para se ver a animação

	MOV		R0, screens_asteroide
	MOV		R0, [R0+R10]					; obtém-se o pixel screen do asteroide
	MOV		[SELECIONA_ECRA], R0			; seleciona-se o pixel screen do asteroide
	CALL	apaga_boneco					; apaga-se o asteroide 

	MOV		R2, existencia_asteroide	
	MOV		R3, FALSE	
	MOV		[R2+R10], R3 					; o asteroide já não existe

	MOV		R2, linhas_asteroide
	MOV		R3, LINHA_ASTEROIDE
	MOV		[R2+R10], R3					; dá reset linha do asteroide

	MOV		R0, TRUE						; o booleano da colisão passa a TRUE
	JMP		trata_colisao_fim

trata_colisao_nave:							; verifica se o asteroide colide com a nave
	MOV		R2, [LINHA_NAVE]
	MOV		R3, [COLUNA_NAVE]
	MOV		R4, ALTURA_NAVE
	MOV		R5, LARGURA_NAVE
	
	CALL	verifica_colisao				; vê se a sonda e a nave colidem
	CMP		R1, TRUE						
	JNZ		trata_colisao_fim				; se não colidem, nada colide

trata_colisao_nave_ocorre:					; faz as operações referentes à colisão nave - asteroide
	CALL	perde_jogo_colisao
	MOV		R0, TRUE						; o booleano de colisão passa a TRUE

trata_colisao_fim:
	MOV		R1, R0							; copia o valor do booleano da colisão (o que vai retornar)
	POP		R9
	POP		R8
	POP		R7
	POP		R6
	POP		R5 
	POP		R4
	POP		R3 
	POP		R2
	POP		R0
	RET

; GERA_NUMERO_ALEATORIO: Gera um número aleatório dado certas restrições
; Argumentos: R2 - número a seguir ao máximo
; Return: R6 -  o número de 0 a R2-1

gera_numero_aleatorio:
	PUSH	R0 
	PUSH	R1
	PUSH	R2
	MOV		R0, [TEC_COL]						; os bits 7 a 4 do periférico PIN são aleatórios
	MOV		R1, NIBL_HIGH						; mascara para isolar bits
	AND		R0, R1								; isola-se o nibble 
	SHR		R0, 4								; para colocá-los no nibble low
	MOD		R0, R2								; faz-se com que R0 apenas possa ter R2-1 valores possíveis
	MOV		R6, R0								; retorna-se o número aleatório
	POP		R2
	POP		R1
	POP		R0 
	RET


; DETERMINA_DEF_ASTEROIDE: Consoante o tipo de asteroide dado, determina a sua forma
; Argumento: R4 
; Return: R4
determina_def_asteroide: 
	CMP		R4, ASTEROIDE_MAU				; vê se o asteroide é do tipo não minerável
	JZ		determina_def_asteroide_mau		; se não for minerável, terá forma de não minerável

determina_def_asteroide_mineravel:
	MOV		R4, DEF_ASTEROIDE_MIN_1			; se é minerável, tem forma de minerável
	JMP		determina_def_asteroide_fim

determina_def_asteroide_mau:
	MOV		R4, DEF_ASTEROIDE				; se não é minerável, terá forma de não minerável

determina_def_asteroide_fim:
	RET 

; DETERMINA_DIM_ASTEROIDE: Consoante o tipo de asteroide dado, determina as suas dimensões
; Argumento: R8 (tipo de asteroide)
; Return: R8 (Altura), R9 (Largura)
determina_dim_asteroide:
	PUSH	R0
	MOV		R0, ASTEROIDE_MAU
	CMP		R8, R0							; vê-se o asteroide é não minerável
	JZ		determina_dim_asteroide_mau		; se for, determina dimensões

	MOV		R0, ASTEROIDE_MINERAVEL
	CMP		R8, R0							; vê-se o asteroide é minerável
	JZ		determina_dim_asteroide_min		; se for, determina dimensões

determina_dim_asteroide_mau:
	MOV		R8, ALTURA_ASTEROIDE
	MOV		R9, LARGURA_ASTEROIDE
	JMP		determina_dim_asteroide_fim

determina_dim_asteroide_min:
	MOV		R8, ALTURA_ASTEROIDE_MIN
	MOV		R9, LARGURA_ASTEROIDE_MIN
	JMP		determina_dim_asteroide_fim

determina_dim_asteroide_fim:
	POP		R0
	RET

;VERIFICA_COLISAO: Verifica se dois objetos colidem um com o outro
; Argumentos: R2,R3,R4,R5 - linha, coluna, altura, largura da nave/sonda (objeto 1)
;			  R6,R7,R8,R9 - linha, coluna, altura, largura do asteroide (objeto 2)
; Return: R1 - (0 se não, 1 se sim)

verifica_colisao:
    PUSH 	R2      						; linha canto superior esquerdo do objeto 1
    PUSH 	R3                              ; coluna canto superior esquerdo do objeto 1
    PUSH 	R4								; altura do objeto 1
    PUSH 	R5								; largura do objeto 1

    PUSH	R6								; linha do canto superior esquerdo do objeto 2
    PUSH	R7								; coluna do canto superior esquerdo do objeto 2
    PUSH 	R8								; altura do objeto 2
    PUSH 	R9								; largura do objeto 2

    ADD		R5, R3 							; coluna lado direito objeto 1
    CMP		R5, R7							; se lado direito objeto 1 for menor que lado esquerdo do objeto 2
    JLT		nao_colide

    ADD		R9, R7							; coluna lado direito objeto 2
    CMP		R9, R3							; se lado direito objeto 2 for menor que lado esquerdo do objeto 1
    JLT		nao_colide

    ADD		R4, R2							; linha inferior objeto 1
    CMP		R4,	R6							; se linha inferior objeto 1 for menor que linha superior objeto 2
    JLT		nao_colide										

    ADD		R8,	R6							; linha inferior objeto 2
    CMP		R8,	R2							; se linha inferior objeto 2 for menor que linha superior objeto 1
    JLT		nao_colide

    JMP		colide

nao_colide:
    MOV 	R1, FALSE
    JMP 	verifica_colisao_fim
colide:
     MOV 	R1, TRUE
     JMP 	verifica_colisao_fim

verifica_colisao_fim:
    POP 	R9
    POP 	R8
    POP 	R7
    POP		R6
    POP 	R5
    POP 	R4
    POP 	R3
    POP 	R2
    RET

; VERIFICA_LIMITES: Verifica se o asteroide saiu ou não dos limites do ecrã
; Argumentos: R1 - linha do asteroide
; Return: R1 - (0 se não, 1 se sim)
verifica_limites:							; de notar que pode-se apenas verificar se passou apenas a linha inferior
	PUSH	R0
	MOV		R0, MAX_LINHA
	CMP		R1, R0							; compara a linha atual do asteroide com a linha máxima
	JGT		verifica_limites_saiu			; se for maior, quer dizer que saiu dos limites do ecrã

verifica_limites_nao_saiu:					
	MOV		R1, FALSE
	POP		R0
	RET	

verifica_limites_saiu:
	MOV		R1, TRUE
	POP		R0
	RET
	
; **********************************************************************
; SONDA: Processo que controla as sondas 
; **********************************************************************

PROCESS SP_inicial_sondas

sonda:
	;-> sonda criar triagem do comando direção
    ;-> ver se a sonda existe na direção
    ;-> criar nova sonda se necessário
    ;-> move sondas que existam na tabela
    ;-> ver a vida util e caso chegue a 0 resetar as coordenadas e a existência da propria

    MOV     R0, TAMANHO_PILHA
    MUL     R0, R11                      ; multiplica o tamanho de um processo pelo nº de instância
    SUB     SP, R0                       ; inicializa o SP deste asteroide (subtraindo o valor necessário)

    MOV     R10, R11                     ; cópia do nº da instância do boneco
    SHL     R10, 1                       ; multiplica por 2 pois as tabelas são WORDs

sonda_loop_pausa:
	MOV		R1, [estado_jogo+0]			; fica à espera até que volte a ser resumido o jogo
	JMP		sonda_loop					; depois pode continuar normalmente

sonda_loop_reset:
	CALL	apaga_sonda					; apaga a sonda
	CALL	reset_sonda					; coloca as posições iniciais na sonda
	MOV		R1, [estado_jogo+0]			; fica à espera que o estado mude para jogável

sonda_loop:
	
	
	MOV		R1, estado_jogo
	MOV		R1, [R1+2]					; obtém o estado do jogo atual
										; se for tanto fim como pausa deve voltar ao loop de inicialização	
	MOV		R0, ESTADO_FIM
	CMP		R1, R0
	JZ		sonda_loop_reset

	MOV		R0, ESTADO_PAUSA
	CMP		R1, R0
	JZ		sonda_loop_pausa

    MOV     R3, [evento_int+2]          ; a rotina de interrupção 1 é a associada ao relógio das sondas
 	MOV     R0, PSCREEN_SONDA           ; seleciona o o pixel screen da nave
    MOV     [SELECIONA_ECRA], R0

sonda_existe:
    MOV     R7, existencia_sonda						
    ADD     R7, R10
    MOV     R7, [R7]									
    CMP     R7, TRUE										
    JZ      sonda_mov                  	; se a sonda existir, então continua o processo
    									; se não existir, fica-se preso num LOCK até existir, após resetar posição

sonda_espera_tecla:						; primeiro dá reset à sonda, depois fica à espera da tecla
	MOV		R1, linhas_sonda
	ADD		R1, R10 
	MOV		R2, colunas_sonda
	ADD		R2, R10
	MOV		R4, DEF_SONDA
	CALL	apaga_boneco				; apaga antiga sonda

	MOV		R0, LINHA_SONDA
	MOV		[R1], R0					; dá reset à linha da sonda
	CALL	seleciona_coluna_inicial	; obtem coluna inicial da sonda
	MOV		[R2], R5					; dá reset à coluna da sonda
	MOV		R6, vida_util_sonda
	MOV		R7, VIDA_UTIL_SONDA_CONS	; o valor máximo de vida útil
	MOV		[R6+R10], R7				; dá reset à vida útil

	CALL	associa_sonda_tecla			; consoante o sentido desta sonda, R7 fica com a tecla correspondente

sonda_espera_tecla_loop:
	MOV		R0, [tecla_carregada]		; fica à espera de uma tecla carregada

	MOV		R1, [estado_jogo+2]			; pode no entanto ter mudado de estado enquanto se esperava
	MOV		R2, ESTADO_FIM
	CMP		R1, R2
	JZ		sonda_loop_reset			; se for o fim, dá reset
	MOV		R2, ESTADO_PAUSA
	CMP		R1, R2
	JZ		sonda_loop_pausa			; se for pausa, fica à espera que o jogo volte

	CMP		R0, R7
	JNZ		sonda_espera_tecla_loop		; se a tecla carregada não for a correspondente, continua à espera

sonda_eh_tecla_certa:					; se a tecla é a correspondente, passa a existir sonda e diminui energia
	MOV		R7, existencia_sonda
	MOV		R8, TRUE
	MOV		[R7+R10], R8				; esta instância da sonda passa a existir

	MOV		R1, [energia_atual]
	SUB		R1, ENERGIA_DISPARO			; sempre que dispara sonda diminuí 5%
	MOV		[energia_atual], R1			; atualiza varíavel da energia

	MOV		R2, 0
	CMP		R1, R2						; vê se a energia é menor ou igual a 0
	JLE		sonda_eh_tecla_certa_sem_energia	
	JMP		sonda_eh_tecla_certa_mostra_decrescimo


sonda_eh_tecla_certa_sem_energia:		; a nave fica sem energia, caso em que termina o jogo

	CALL	perde_jogo_energia	
	JMP		sonda_loop_reset

sonda_eh_tecla_certa_mostra_decrescimo:	; a nave ainda tem energia, podemos continuar o jogo

	CALL	energia_converte			; converte a energia para o display
	MOV		[DISPLAYS], R1				

	JMP		sonda_fim

sonda_mov:
    
    MOV     R6, sentido_sonda           ; tabela com o sentido de cada sonda
    ADD     R6, R10                     ; pointer para o sentido da sonda especifica
    MOV     R7, linhas_sonda            ; tabela com a linha de cada sonda
    ADD     R7, R10                     ; pointer para a linha da sonda especifica
    MOV     R8, colunas_sonda           ; tabela com a coluna de cada sonda
    ADD     R8, R10                     ; pointer para a coluna da sonda especifica
    MOV     R4, DEF_SONDA               ; tabela com a sonda
    MOV     R1, R7                      ; seleciona o argumento da linha
    MOV     R2, R8                      ; seleciona o argumento da coluna
    CALL    apaga_boneco
    MOV     R1, [R1]					; fica com o valor da linha
    MOV     R2, [R2]					; fica com o valor da coluna
    ADD     R1, -1                  	; a linha sobe sempre 1 (retira 1 ao valor antigo)
    MOV     R3, [R6]                	; corresponde ao incremento gerador (sentido do asteroide)
    ADD     R2, R3                  	; soma-se à coluna atual o incremento
    MOV     [R7], R1                	; atualiza a linha na varíavel global
    MOV     [R8], R2                	; atualiza a coluna na varíavel global
    MOV     R2, R8                  	; obtém coluna do asteroíde desta instância
    MOV     R1, R7                  	; obtém linha do asteroíde desta instância
    CALL    desenha_boneco

validade_sonda:
    MOV 	R6, vida_util_sonda         ; tabela com a validade das sondas
    ADD 	R6, R10                     ; validade da sonda em particular
    MOV 	R5, [R6]                    ; copia da validade da sonda
    SUB 	R5, 1                       ; diminui 1 pois acabou de realizar um movimento
    MOV 	[R6], R5                    ; atualiza a vida util da sonda
    MOV 	R9, FALSE                   ; se a validade chegar a 0 vai para o reseta_posicao_sonda
    CMP 	R5, R9
    JNZ 	sonda_fim

reseta_posicao_sonda:               	; reseta a vida util e a posicao inicial da sonda
	CALL	seleciona_coluna_inicial	; obtém coluna inicial da instância da sonda
    CALL 	apaga_boneco				; apaga a sonda que estava na ultima posição
    MOV 	R1, [R7]					; copia da linha do boneco
    MOV 	R2, [R8]					; copia da coluna do boneco
    MOV 	R2, R5                      ; substitui a coluna inicial da sonda em questao com a inicial da propria
    MOV 	R5, VIDA_UTIL_SONDA_CONS	; copia da vida util de uma sonda
    MOV		R1, LINHA_SONDA				; dá reset à linha da sonda
    MOV 	[R7], R1					; guarda na memoria a nova linha da sonda
    MOV 	[R8], R2					; guarda na memoria a nova coluna da sonda
    MOV 	[R6], R5					; reinicia a vida util da sonda
    MOV		R5, existencia_sonda		; endereço com a tabela das existencias das sondas
    ADD		R5, R10						; endereço com existencia da sonda pretendida
    MOV		R6, FALSE
    MOV		[R5], R6					

sonda_fim:
    JMP 	sonda_loop 


; APAGA_SONDA - Apaga a sonda nessa instância
; Argumentos:   R10 - instância
apaga_sonda:
    PUSH 	R1
    PUSH 	R2 
    PUSH 	R4
    MOV 	R1, linhas_sonda         	; seleciona a tabela com as linhas das varias sondas
    MOV 	R2, colunas_sonda         	; seleciona a tabela com as colunas das varias tabelas
    ADD 	R1, R10          			; seleciona a linha da sonda em questão
    ADD 	R2, R10                  	; seleicona a coluna da sonda em questão
    MOV 	R4, DEF_SONDA              	; seleciona a tabela com a definição da sonda
    CALL 	apaga_boneco

apaga_sonda_fim:
    POP 	R4
    POP 	R2
    POP 	R1
    RET

; RESET_SONDA - Reseta a sonda ao seu estado inicial
; Argumentos: 	R10, R11 - instância, nº sonda
reset_sonda:
	PUSH	R0
	PUSH	R1 

	MOV		R0, existencia_sonda		
	MOV		R1, FALSE
	MOV		[R0+R10], R1				; a sonda deixa de existir

	MOV		R0, vida_util_sonda
	MOV		R1, VIDA_UTIL_SONDA_CONS	
	MOV		[R0+R10], R1				; volta a ter toda a sua vida

	CALL	seleciona_coluna_inicial	
	MOV		R0, colunas_sonda
	MOV		[R0+R10], R5				; volta à coluna inicial

	MOV		R0, linhas_sonda
	MOV		R1, LINHA_SONDA
	MOV		[R0+R10], R1				; volta à linha inicial

	POP		R1
	POP		R0	


; SELECIONA_COLUNA_INICIAL: Associa a instância da sonda à sua coluna inicial no reset
; Argumento: R11 - número da sonda
; Return: R5 - coluna inicial da sonda
seleciona_coluna_inicial:
    CMP 	R11, 0
    JZ 		seleciona_coluna_inicial0	
    CMP 	R11, 1
    JZ 		seleciona_coluna_inicial1
    CMP 	R11, 2
    JZ 		seleciona_coluna_inicial2

seleciona_coluna_inicial0:					; se for a sonda 0, escolhe a coluna da esquerda
    MOV 	R5, COLUNA_INICIAL_SONDA0
    JMP 	seleciona_coluna_inicial_end

seleciona_coluna_inicial1:					; se for a sonda 1, escolhe a coluna do meio
    MOV 	R5, COLUNA_INICIAL_SONDA1
    JMP 	seleciona_coluna_inicial_end

seleciona_coluna_inicial2:					; se for a sonda 2, escolhe a coluna da direita
    MOV 	R5, COLUNA_INICIAL_SONDA2
    JMP 	seleciona_coluna_inicial_end

seleciona_coluna_inicial_end:
	RET

; ASSOCIA_SONDA_TECLA: Associa a constante da tecla correspondente ao sentido desta instância
; Argumento: R10 - instância desta sonda
; Return: R7 - tecla da sonda na direção da instância
associa_sonda_tecla:
	PUSH	R6
	MOV 	R6, sentido_sonda
    ADD 	R6, R10  					               	
    MOV		R6, [R6]					; obtém o sentido desta instância da sonda
    CMP 	R6, -1						; se o seu sentido for para a esquerda
    JZ 		escolhe_tecla_sonda_esquerda	
    CMP 	R6, 0						; se o seu sentido for em frente
    JZ 		escolhe_tecla_sonda_meio
    CMP 	R6, 1						; se o seu sentido for para a direita
    JZ 		escolhe_tecla_sonda_direita

escolhe_tecla_sonda_esquerda:			; associa à tecla da esquerda se for nesse sentido
    MOV 	R7, TECLA_SONDA_ESQUERDA	
    JMP		associa_sonda_tecla_fim

escolhe_tecla_sonda_meio:				; associa à tecla do meio se for nesse sentido
    MOV 	R7, TECLA_SONDA_FRENTE
    JMP		associa_sonda_tecla_fim

escolhe_tecla_sonda_direita:			; associa à tecla da direita se for nesse sentido
    MOV 	R7, TECLA_SONDA_DIREITA

 associa_sonda_tecla_fim:
 	POP		R6
 	RET

; **********************************************************************
; NAVE - Processo que desenha a nave e atualiza o seu painel
; **********************************************************************
PROCESS SP_inicial_nave

nave:

nave_loop_reset:									; se estivermos no fim do jogo, damos reset e esperamos pelo reinício
	CALL	apaga_nave								; apaga a nave
	CALL	apaga_painel							; apaga o painel
	MOV		R8, [estado_jogo+0]						; fica à espera do recomeço do jogo
	JMP		nave_desenha_chassi						; volta a desenhar a nave
	
nave_loop_pausa:									; se estivermos na pausa, esperamos que seja resumido
	MOV		R8, [estado_jogo+0]						; fica à espera até que volte a ser resumido o jogo
	JMP		nave_painel_loop

nave_loop:											; apenas escolhe uma variante e desenha-a no ínicio de cada ciclo do relógio

	MOV		R8, estado_jogo
	MOV		R8, [R8+2]								; obtém o estado do jogo atual

	MOV		R0, ESTADO_FIM
	CMP		R8, R0
	JZ		nave_loop_reset							; se estivermos no fim é preciso apagar tudo e esperar pelo recomeço		

	MOV		R0, ESTADO_PAUSA
	CMP		R8, R0
	JZ		nave_loop_pausa							; se estivermos na pausa apenas é preciso parar o efeito do painel

	MOV		R0, ESTADO_A_JOGAR
	CMP		R8, R0
	JZ		nave_painel_loop						; se estivermos no jogo normal, continua normalmente

nave_desenha_chassi:								; desenha o chassi da nave (isto é, tudo menos o painel)
	MOV 	R1, LINHA_NAVE		
	MOV 	R2, COLUNA_NAVE		
	MOV 	R4, DEF_NAVE

	MOV 	R0, PSCREEN_NAVE   						
	MOV 	[SELECIONA_ECRA], R0					; seleciona o pixel screen da nave
	CALL 	desenha_boneco							; desenha o chassi

nave_painel:										; cicla entre as variantes do painel e vai desenhando-as
	MOV 	R1, LINHA_PAINEL
	MOV 	R2, COLUNA_PAINEL
	MOV		R5, ULTIMO_PAINEL

nave_painel_loop:
	MOV 	R8, [evento_int+6]
	MOV 	R0, PSCREEN_PAINEL   					; seleciona o o pixel screen do painel
	MOV 	[SELECIONA_ECRA], R0
	MOV		R3, [PAINEL_ATUAL]						; vê qual qual foi a última variante do painel a ser desenhado
	MOV 	R4, DEF_NAVE_PAINEIS					; corresponde à tabela com todas as variantes do painel

nave_painel_escolhe_variante:						; escolhe entre uma das 9 variantes de cores do painel			
	CMP		R3, R5									; apenas existem 9 paineis, logo vê se chegamos ao último
	JNZ		nave_painel_desenha_variante			; se não for o último painel, desenha a variante
	MOV		R3, 0									; caso seja, voltamos à primeira variante

nave_painel_desenha_variante:   					; desenha a variante do painel escolhida
	ADD		R4, R3									; acedemos à variante escolhida, somando ao primeiro painel o incremento necessário
	ADD		R3, PROXIMA_PALAVRA						; atualizamos o incremento para corresponder ao painel seguinte na próxima chamada
	MOV		[PAINEL_ATUAL], R3						; atualiza-se o PAINEL_ATUAL para o seguinte
	MOV		R4, [R4]								; para aceder à tabela de desenho do painel escolhido
	CALL 	desenha_boneco							; desenha a variante do painel
	JMP		nave_loop

; APAGA_NAVE: Rotina que apaga nave
apaga_nave:
	PUSH	R1
	MOV		R1, PSCREEN_NAVE						; seleciona-se o pixel screen da nave
	MOV		[APAGA_ECRA], R1						; apagamo-lo (é apenas habitado pela nave)
	POP		R1
	RET

; APAGA_PAINEL: Rotina que apaga o painel da nave
apaga_painel:
	PUSH	R1
	MOV		R1, PSCREEN_PAINEL						; seleciona-se o pixel screen do painel
	MOV		[APAGA_ECRA], R1						; apagamo-lo (é também habitado pelas sondas,
	POP		R1 										; mas em qualquer situação em que seja preciso apagar
	RET 											; o painel, também é preciso apagar as sondas)

; **********************************************************************
; ENERGIA - Processo que diminuí a energia ao longo do tempo
; **********************************************************************

PROCESS SP_inicial_energia

energia:

energia_loop_pausa:							; se estivermos em pausa ou no fim do jogo
	MOV		R1, [estado_jogo+0]				; fica-se à espera até que volte a ser resumido o jogo

energia_loop:
	
	MOV		R1, estado_jogo
	MOV		R1, [R1+2]						; obtém-se o estado de jogo atual

	MOV		R0, ESTADO_A_JOGAR
	CMP		R1, R0
	JNZ		energia_loop_pausa				; se não estivermos no estado jogável, para o contador

	MOV		R2, [evento_int+4]				; a rotina correspondente ao relógio da energia é a rotina 2
						
	MOV		R1, [energia_atual]				; obtém-se o valor da energia atual
	MOV		R3, R1							; faz-se uma cópia do mesmo

	MOV		R2, 0
	CMP		R3, R2							; vê se a energia chega ao fim	
	JLE		energia_loop_sem_energia	 	; se for menor ou igual a 0, termina o jogo
	JMP		energia_loop_decresce_timer		; caso contrário, continua a iteração

energia_loop_sem_energia:					; se já não há energia, então perde-se o jogo
	CALL	perde_jogo_energia			
	JMP		energia_loop_pausa

energia_loop_decresce_timer:				; aplicar o descréscimo de 3% de acordo com o timer do relógio
	
	MOV		R0, DISPLAYS
	MOV		R1, R3	
	CALL	energia_converte				; converte a energia atual para um valor "decimal"
	MOV		[R0], R1						; mostra o valor de energia no display 


	MOV		R4, ENERGIA_DECRESCIMO			; corresponde ao decréscimo de 3%
	SUB		R3, R4							; retira-se 3% ao valor atual da energia (não convertido)
	MOV		[energia_atual], R3				; atualiza o valor da energia na varíavel global (não convertido)
	JMP		energia_loop 					; volta ao ínicio do loop


; ENERGIA_CONVERTE: Rotina que converte um valor de energia hexadecimal para um "decimal", isto é,
;			que permite os valores obtidos nos displays serem decimais de 0-999
; Argumentos: R1
; Return: R1
energia_converte:					; converte a energia para decimal, de acordo com a sugestão do lab7
	PUSH	R0	
	PUSH	R2
	PUSH	R3
	PUSH	R4
	MOV		R0, ENERGIA_FATOR		; corresponde ao fator 1000d, necessário para a conversão
	MOV		R4, 10					; usado para ir diminuindo o fator
	MOV		R3, 0

energia_converte_loop:					
	MOD		R1, R0					; número = número MOD fator
	DIV		R0, R4					; fator = fator DIV 10
	MOV		R2, R1									
	DIV		R2, R0					; digito = número DIV fator
	SHL		R3, 4					; resultado = resultado SHL 4, para dar espaço ao dígito
	OR		R3, R2					; resultado = resultado OR dígito
	CMP		R0, R4
	JLT		energia_converte_final
	JMP		energia_converte_loop	; passa à próxima iteração

energia_converte_final:
	MOV		R1, R3					; passa o resultado para o registo R1
	POP		R4
	POP		R3
	POP		R2
	POP		R0
	RET 	

; **********************************************************************
; Rotinas de perder jogo
; **********************************************************************

; **********************************************************************
; PERDE_JOGO_ENERGIA: Rotina chamada quando se perde o jogo por falta de energia
; **********************************************************************

perde_jogo_energia:
	PUSH	R0
	PUSH	R1
	PUSH	R2

perde_jogo_energia_verifica:				; verifica se por acaso o jogo já se perdeu antes
	MOV		R2, [estado_jogo+2]
	MOV		R1, ESTADO_FIM
	CMP		R2, R1
	JZ		perde_jogo_energia_fim			; se o jogo já estiver perdido, nada faz

perde_jogo_energia_valido:					; o jogo ainda não perdeu antes, logo perde agora
	MOV		R0, DISPLAYS
	MOV		R1, 0							
	MOV		[R0], R1						; queremos mostrar 0, se for negativa

	MOV		R2, estado_jogo
	MOV		R1, ESTADO_FIM
	MOV		[R2+2], R1 						; passa o estado jogo para fim

	MOV		[APAGA_CENARIO_FUNDO], R5
	MOV		[APAGA_CENARIO_FRENTE], R5 
	MOV		[APAGA_ECRÃS], R5				; apaga tudo o que está desenhado
	MOV		[STOP_MEDIA_ALL], R5			; para todos os media que estejam a dar

	MOV		R1, ECRA_ENERGIA
	MOV		[SELECIONA_CENARIO_FUNDO], R1	; coloca o cenário de fundo de perder por falta de energia
	MOV		R1, SOM_ENERGIA							
	MOV		[TOCA_SOM], R1					; toca o som de ficar sem energia

perde_jogo_energia_fim:
	POP		R2
	POP		R1
	POP		R0
	RET 

; **********************************************************************
; PERDE_JOGO_COLISAO: Rotina chamada quando se perde o jogo por colisao com a nave
; **********************************************************************

perde_jogo_colisao:
	PUSH	R0
	PUSH	R1
	PUSH	R2

perde_jogo_colisao_verifica:				; verifica se por acaso o jogo já se perdeu antes
	MOV		R2, [estado_jogo+2]
	MOV		R1, ESTADO_FIM
	CMP		R2, R1
	JZ		perde_jogo_colisao_fim			; se o jogo já estiver perdido, nada faz

perde_jogo_colisao_valido:					; o jogo ainda não perdeu antes, logo perde agora

	MOV		R2, estado_jogo
	MOV		R1, ESTADO_FIM
	MOV		[R2+2], R1 						; passa o estado jogo para fim

	MOV		[APAGA_CENARIO_FUNDO], R5
	MOV		[APAGA_CENARIO_FRENTE], R5 
	MOV		[APAGA_ECRÃS], R5				; apaga tudo o que está desenhado
	MOV		[STOP_MEDIA_ALL], R5			; para todos os media que estejam a dar

	MOV		R1, ECRA_COLISAO
	MOV		[SELECIONA_CENARIO_FUNDO], R1	; coloca o cenário de fundo de perder por colisão com nave
	MOV		R1, SOM_NAVE					; toca o som associado
	MOV		[TOCA_SOM], R1					; toca o som de ficar sem energia


perde_jogo_colisao_fim:
	POP		R2
	POP		R1
	POP		R0
	RET 

; **********************************************************************
; Rotinas de interrupção
; **********************************************************************

; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz com que os asteroides desçam cada vez que o seu relógio
;			completa um ciclo
; **********************************************************************
rot_int_0:
	PUSH	R1
	MOV		R1, evento_int
	MOV		[R1+0], R0				; desbloqueia o processo asteroides
	POP		R1 
	RFE

; **********************************************************************
; ROT_INT_1 - 	Rotina de atendimento da interrupção 1
;			Faz com que as sondas subam cada vez que o seu relógio
;			completa um ciclo (se existirem)
; **********************************************************************
rot_int_1:
	PUSH	R1
	MOV		R1, evento_int
	MOV		[R1+2], R0				; desbloqueia o processo sondas
	POP		R1 
	RFE

; **********************************************************************
; ROT_INT_2 - 	Rotina de atendimento da interrupção 2
;			Faz com que a energia diminui 3% cada vez que o seu relógio
;			completa um ciclo
; **********************************************************************
rot_int_2:
	PUSH	R1
	MOV		R1, evento_int
	MOV		[R1+4], R0				; desbloqueia o processo energia
	POP		R1 
	RFE

; **********************************************************************
; ROT_INT_3 - 	Rotina de atendimento da interrupção 3
;			Faz com que o painel de instrumentos da nave mude cada vez
;			que o seu relógio completa um ciclo
; **********************************************************************
rot_int_3:
	PUSH	R1
	MOV		R1, evento_int
	MOV		[R1+6], R0				; desbloqueia o processo nave
	POP		R1 
	RFE

; **********************************************************************
; Rotinas de Desenho
; **********************************************************************

; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH 	R6
	PUSH 	R8
	PUSH 	R9
	PUSH 	R10

	MOV 	R8,	[R4+2]					; obtém uma copia da altura do boneco (vai servir de contador)
	MOV 	R9, [R4]					; obtém uma copia da largura do boneco
	MOV 	R10,[R2]					; uma copia da coluna do boneco
	MOV		R1, [R1]					; cópia da linha do boneco
	SUB 	R1,	1						; ajuste na linha do boneco (para começar na linha antes)
loop_desenha_linha:
	ADD		R4, 4						; endereço da cor do 1º pixel (4 porque a largura e altura são words)
desenha_linha_boneco:
	MOV 	R2, R10						; restaura o coluna com a copia
	ADD 	R1, 1 						; passa para a linha seguinte
	MOV		R5, R9						; obtém a largura do boneco
desenha_pixels:       					; desenha os pixels do boneco a partir da tabela
	MOV		R3, [R4]					; obtém a cor do próximo pixel do boneco
	CALL 	escreve_pixel				; escreve cada pixel do boneco
	ADD		R4, 2						; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
	ADD 	R2, 1            			; próxima coluna
	SUB 	R5, 1						; menos uma coluna para tratar
 	JNZ 	desenha_pixels    			; continua até percorrer toda a largura do objeto
	SUB 	R8,1 						; diminui uma unidade por cada linha do boneco ja desenhada
	JNZ 	desenha_linha_boneco		; desenha as linhas todas do boneco

   	POP 	R10
   	POP 	R9
   	POP 	R8
   	POP 	R6
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP 	R1
	RET

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH 	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH 	R6
	PUSH 	R7
	PUSH 	R8
	PUSH 	R9
	PUSH	R10
	MOV 	R9, [R4+2]				; obtém uma copia da altura do boneco (vai servir de contador)
	MOV		R5, [R4]				; obtém a largura do boneco
	ADD		R4, 4					; endereço da cor do 1º pixel (4 porque a largura e altura são words)
	MOV		R3, COR_NADA			; cor para apagar o próximo pixel do boneco
	MOV 	R6, R5					; cópia do largura do boneco
	MOV 	R7, [R2]				; cópia da coluna inicial do boneco
	MOV		R1, [R1]				; cópia da linha inicial do boneco
	SUB 	R1, 1					; ajuste na linha do boneco (para começar na linha antes)
apaga_pixels:       				
	ADD 	R1, 1					; passa para a linha seguinte
	MOV 	R5, R6					; obtém a largura do boneco	
	MOV 	R2, R7					; obtém a coluna inicial do boneco

loop_apaga_pixel:					; apaga os pixeis de cada linha
	CALL	escreve_pixel			; apaga o pixel do boneco
	ADD	 	R4, 2					; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  	R2, 1               	; próxima coluna
    SUB  	R5, 1					; menos uma coluna para tratar
    JNZ  	loop_apaga_pixel      	; continua até percorrer toda a largura do objeto

	SUB 	R9,1					; diminui uma unidade por cada linha do boneco já apagada
	JNZ 	apaga_pixels

	POP		R10
	POP 	R9
	POP 	R8
	POP		R7
	POP		R6
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	RET

; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas, com cor dada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************	
escreve_pixel:
	MOV  [DEFINE_LINHA], R1			; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3			; altera a cor do pixel na linha e coluna já selecionadas
	RET