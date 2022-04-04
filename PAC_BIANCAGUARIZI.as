;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR               EQU      0Ah
FIM_TEXTO        EQU      '@'
IO_READ          EQU      FFFFh
IO_WRITE         EQU      FFFEh
IO_STATUS        EQU      FFFDh
INITIAL_SP       EQU      FDFFh
CURSOR		       EQU      FFFCh
CURSOR_INIT		   EQU		  FFFFh
ROW_POSITION	   EQU		  0d
COL_POSITION	   EQU		  0d
ROW_SHIFT		     EQU		  8d
COLUMN_SHIFT	   EQU		  8d

FIM_STRING       EQU     '!'


CIMA             EQU      4d
BAIXO            EQU      3d
ESQ              EQU      2d
DIR              EQU      1d
NO_DIRECTION     EQU      0d
PARADO           EQU      0d
MOVIMENTO        EQU      1d
VAZIO            EQU      ' '
PAREDE           EQU      '#'
COMIDA           EQU      '.'
FANTASMA         EQU      '&'
PACMAN           EQU      '$'
BONUS            EQU      '+'

CONFIG_TIMER     EQU      FFF6h
ATIVAR_TIMER     EQU      FFF7h

TIMER_ON         EQU      1d
TIMER_OFF        EQU      0d
INTERVAL_TIMER   EQU      5d

;Quantidade de linhas e colunas que meu mapa contém

QUANT_ROW        EQU      16d
QUANT_COLUMN     EQU      45d ;contando com o FIM_TEXTO de cada linha


BASE_ASCII       EQU      48d

; padrao de bits para geracao de numero aleatorio

RND_MASK	EQU	8016h	; 1000 0000 0001 0110b
LSB_MASK	EQU	0001h	; Mascara para testar o bit menos significativo do Random_Var

; Constantes fantasma

DIR_FANT         EQU      0d
ESQ_FANT         EQU      1d
CIMA_FANT        EQU      2d
BAIXO_FANT       EQU      3d


;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h
RowIndex		    WORD	 1d
ColumnIndex		  WORD	 1d
                      ;123456789012345678901234567890123456789012345678901234567890123456789
String_0        STR   '############################################', FIM_TEXTO
String_1        STR   '######################..               ..###', FIM_TEXTO
String_2        STR   '###........................................#', FIM_TEXTO
String_3        STR   '##.........................................#', FIM_TEXTO
String_4        STR   '###.################################.......#', FIM_TEXTO
String_5        STR   '##.........+#.....................##.....#.#', FIM_TEXTO
String_6        STR   '##.......####........##....................#', FIM_TEXTO
String_7        STR   '##.......#...........##...........##.......#', FIM_TEXTO
String_8        STR   '#........#...........##...........##.......#', FIM_TEXTO
String_9        STR   '##.......#...........##. .#................#', FIM_TEXTO
String_10       STR   '##.......#...........## $ #................#', FIM_TEXTO
String_11       STR   '##.......##########..###############.......#', FIM_TEXTO
String_12       STR   '##...................##...................##', FIM_TEXTO
String_13       STR   '##..#.....................................##', FIM_TEXTO
String_14       STR   '############################################', FIM_TEXTO
String_15       STR   '############################################', FIM_TEXTO
String_fim      STR   FIM_STRING

String_pontos   STR   'PONTUACAO: ', FIM_STRING

; Variáveis vidas

String_vida     STR   'VIDAS: S2 S2 S2', FIM_STRING

vidas           WORD  3d

Column_vida     WORD  0d
Row_vida        WORD  0d

Indice          WORD  0d


String_perda    STR   'VOCE PERDEU, MANO ', FIM_STRING

String_ganha    STR   'VOCE GANHOU, FERA. MANDOU VER ', FIM_STRING


;Variáveis de direção do pacman ($)

Direcao_pacman  WORD  NO_DIRECTION
Andar_pacman    WORD  PARADO
Row_pacman      WORD  11d
Column_pacman   WORD  25d

Row_pacman_i    WORD  11d
Column_pacman_i WORD  25d


;Variável de pontuação pacman

Pontos          WORD  0d

Total_pontos    WORD  500d


; Definicao de variavel da função de número alearório

Random_Var	    WORD	A5A5h


; Variáveis fantasma1

Direcao_fant1   WORD  NO_DIRECTION
Andar_fant1     WORD  PARADO
Row_fant1       WORD  13d
Column_fant1    WORD  6d
Indice_fant1    WORD  0d


; Variáveis fantasma2

Direcao_fant2   WORD  NO_DIRECTION
Andar_fant2     WORD  PARADO
Row_fant2       WORD  2d
Column_fant2    WORD  32d
Indice_fant2    WORD  0d


; Variáveis fantasma3

Direcao_fant3   WORD  NO_DIRECTION
Andar_fant3     WORD  PARADO
Row_fant3       WORD  6d
Column_fant3    WORD  20d
Indice_fant3    WORD  0d


; Variáveis fantasma4

Direcao_fant4   WORD  NO_DIRECTION
Andar_fant4     WORD  PARADO
Row_fant4       WORD  6d
Column_fant4    WORD  6d
Indice_fant4    WORD  0d



;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    Att_pacman_dir
INT1            WORD    Att_pacman_esq
INT2            WORD    Att_pacman_cima
INT3            WORD    Att_pacman_baixo
                ORIG    FE0Fh
INT15           WORD    Timer_pacman

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main


;------------------------------------------------------------------------------
; Rotina Random - ESTA FUNÇÃO PEGA UM NÚMERO ALEATÓRIO
;------------------------------------------------------------------------------


; Random: Rotina que gera um valor aleatório - guardado em M[Random_Var]
; Entradas: M[Random_Var]
; Saidas:   M[Random_Var]


Random:	                PUSH	R1
                        MOV	R1, LSB_MASK
                        AND	R1, M[Random_Var] ; R1 = bit menos significativo de M[Random_Var]
                        BR.Z	Rnd_Rotate
                        MOV	R1, RND_MASK
                        XOR	M[Random_Var], R1


Rnd_Rotate:	            ROR	M[Random_Var], 1

                        ;CALL Pega_Random

			                  POP	R1
			                  RET



;------------------------------------------------------------------------------
; Rotina Timer_pacman - INTERRUPÇÃO TIMER
;------------------------------------------------------------------------------

Timer_pacman:                            PUSH R1


                                         CALL Mov_pacman
                                         CALL Mov_fantasma

                                         MOV R1, INTERVAL_TIMER
                                         MOV M[CONFIG_TIMER], R1
                                         MOV R1, TIMER_ON
                                         MOV M[ATIVAR_TIMER], R1


                                         POP R1

                                         RTI

;------------------------------------------------------------------------------
; Rotina Mov_pacman - FUNÇÃO DE VERIFICAÇÃO DO MOVIMENTO DO PACMAN
;------------------------------------------------------------------------------

                                        ;if direcao_esq { call Mov_pacman_esq }

Mov_pacman:                             PUSH R1

                                        ; Vê a direção que está guardada para saber para onde mover o pacman

                                        MOV R1, M[Direcao_pacman]

                                        CMP R1, DIR
                                        CALL.z Mov_pacman_dir

                                        CMP R1, ESQ
                                        CALL.z Mov_pacman_esq

                                        CMP R1, CIMA
                                        CALL.z Mov_pacman_cima

                                        CMP R1, BAIXO
                                        CALL.z Mov_pacman_baixo

                                        ; FUNÇÕES PARA COMPARAR SE O PACMAN ESTÁ NA MESMA LINHA E COLUNA DOS FANTASMAS

                                        CALL Compara_Fant1_Pac
                                        CALL Compara_fant2_Pac
                                        CALL Compara_fant3_Pac
                                        CALL Compara_fant4_Pac

                                        POP R1

                                        RET


;------------------------------------------------------------------------------
; Rotina Imprime_Nivel - IMPRIME O NÍVEL NA TELA
;------------------------------------------------------------------------------


Imprime_Nivel:                          PUSH R1
                                        PUSH R2
                                        PUSH R3

                                        MOV		R2, M[ RowIndex ] ;pega a posição inicial da linha
                                        SHL		R2, 8 ;shift Left no valor da linha 8 vezes
                                        MOV		R3, M[ ColumnIndex ] ;pega a posição inicial da coluna
                                        OR		R2, R3 ;faz um or entre os valores de linha shiftado e da coluna e põe em R2
                                        MOV		M[ CURSOR ], R2 ;posiciona o cursor na posição definida em R2

                                        MOV		R2, String_0 ;R2 recebe a string a ser printada
                                        MOV   M[ Indice ], R2 ;a posição de memória de Indice recebe o índice de início da memória de R2 (Que contém a string)



WriteR:                                 MOV R2, M[ Indice ] ; R2 recebe o índice guardado anteriormente em M [ Indice ]
                                        MOV R2, M[ R2 ] ; pega o o conteúdo armazenado em M[ R2 ] (a string em questão), e põe em R2
                                        CMP R2, FIM_TEXTO ; faz uma comparação para ver se está no fim da string
                                        JMP.Z Mov_Row ; caso o cmp der ZERO (é igual), então jmp para Mov_Row
                                				MOV	M[ IO_WRITE ], R2 ; escreve o conteúdo de R2 na tela
                                        INC M[ ColumnIndex ]
                                        INC M[ Indice ]

                                        MOV		R2, M[ RowIndex ]
                                				SHL		R2, 8
                                				MOV		R3, M[ ColumnIndex ]
                                				OR		R2, R3
                                				MOV		M[ CURSOR ], R2
                                        JMP WriteR



Mov_Row:                                MOV R1, 1d
                                        MOV M[ ColumnIndex ], R1
                                        INC M[ RowIndex ]

                                        INC M[ Indice ]
                                        MOV R2, M[ Indice ] ; R2 recebe o índice guardado anteriormente em M [ Indice ]
                                        MOV R2, M[ R2 ] ; pega o o conteúdo armazenado em M[ R2 ] (a string em questão), e põe em R2
                                        CMP R2, FIM_STRING ; faz uma comparação para ver se está no fim da string
                                        JMP.Z Termina_Imprime_Nivel ; caso o cmp der ZERO (é igual), então jmp para halt


                                        ;Reposiciona o cursor
                                        MOV		R2, M[ RowIndex ]
                                				SHL		R2, 8
                                				MOV		R3, M[ ColumnIndex ]
                                				OR		R2, R3
                                				MOV		M[ CURSOR ], R2
                                        JMP WriteR



Termina_Imprime_Nivel:                   MOV R1, 1d
                                         MOV M[ ColumnIndex ], R1

                                         POP R3
                                         POP R2
                                         POP R1
                                         RET

;------------------------------------------------------------------------------
; Rotina Imprime_Ponto - IMPRIME A PONTUAÇÃO NA TELA
;------------------------------------------------------------------------------


Imprime_Ponto:                          PUSH R1
                                        PUSH R2
                                        PUSH R3
                                        PUSH R4
                                        PUSH R5

                                        MOV R1, 1d
                                        MOV M[ColumnIndex], R1

                                        ;Pegando início String_pontos

                                        MOV R2, String_pontos
                                        MOV M[ Indice ], R2

                                        ;MOVENDO CURSOR

Cursor_imprime_ponto:                   MOV		R2, M[ RowIndex ]
                                        SHL		R2, 8
                                        MOV		R3, M[ ColumnIndex ]
                                        OR		R2, R3
                                        MOV		M[ CURSOR ], R2

                                        MOV R2, M[ Indice ]
                                        MOV R2, M[ R2 ]


                                        CMP R2, FIM_STRING
                                        JMP.Z Fim_imprime_ponto

                                        MOV M[ IO_WRITE ], R2
                                        INC M[ ColumnIndex ]
                                        INC M[ Indice ]

                                        JMP Cursor_imprime_ponto

                                        ;IMPRIMINDO O PRIMEIRO DÍGITO

Fim_imprime_ponto:                      INC M[ ColumnIndex ]
                                        MOV		R4, M[ RowIndex ]
                                        SHL		R4, 8
                                        MOV		R5, M[ ColumnIndex ]
                                        OR		R4, R5
                                        MOV		M[ CURSOR ], R4

                                        MOV R1, M[ Pontos ]
                                        MOV R2, 100d
                                        DIV R1, R2

                                        MOV R3, BASE_ASCII
                                        ADD R1, R3

                                        MOV M[ IO_WRITE ], R1

                                        ;IMPRIMINDO SEGUNDO DÍGITO

                                        INC M[ ColumnIndex ]
                                        MOV		R4, M[ RowIndex ]
                                        SHL		R4, 8
                                        MOV		R5, M[ ColumnIndex ]
                                        OR		R4, R5
                                        MOV		M[ CURSOR ], R4

                                        MOV R1, R2
                                        MOV R2, 10d
                                        DIV R1, R2
                                        ADD R1, R3

                                        MOV M[ IO_WRITE ], R1

                                        ;IMPRIMINDO TERCEIRO DÍGITO

                                        INC M[ ColumnIndex ]
                                        MOV		R4, M[ RowIndex ]
                                        SHL		R4, 8
                                        MOV		R5, M[ ColumnIndex ]
                                        OR		R4, R5
                                        MOV		M[ CURSOR ], R4

                                        ADD R2, R3

                                        MOV M[ IO_WRITE ], R2

                                        POP R5
                                        POP R4
                                        POP R3
                                        POP R2
                                        POP R1
                                        RET

;------------------------------------------------------------------------------
; Rotina Imprime_Vidas - IMPRIME AS VIDAS DO PACMAN NA TELA
;------------------------------------------------------------------------------


Imprime_Vidas:          PUSH R1
                        PUSH R2
                        PUSH R3

                        MOV R1, 30d
                        MOV M[ColumnIndex], R1

                        INC M[ RowIndex ]

                        ;Pegando início String_pontos

                        MOV R2, String_vida
                        MOV M[ Indice ], R2

                        ;MOVENDO CURSOR

Cursor_imprime_vidas:   MOV		R2, M[ RowIndex ]
                        SHL		R2, 8
                        MOV		R3, M[ ColumnIndex ]
                        OR		R2, R3
                        MOV		M[ CURSOR ], R2

                        MOV R2, M[ Indice ]
                        MOV R2, M[ R2 ]


                        CMP R2, FIM_STRING
                        JMP.Z Fim_imprime_vidas

                        MOV M[ IO_WRITE ], R2
                        INC M[ ColumnIndex ]
                        INC M[ Indice ]

                        JMP Cursor_imprime_vidas

Fim_imprime_vidas:      MOV R1, M[ RowIndex ]
                        MOV M[ Row_vida ], R1
                        MOV R1, M[ ColumnIndex ]
                        DEC R1
                        MOV M[ Column_vida ], R1
                        DEC M[ RowIndex ]
                        POP R3
                        POP R2
                        POP R1
                        RET


;------------------------------------------------------------------------------
; Rotina Mov_pacman_dir
;------------------------------------------------------------------------------


Mov_pacman_dir:       PUSH R1
                      PUSH R2
                      PUSH R3

                      CALL Verifica_parede_dir

                      MOV R1, M[Andar_pacman]
                      CMP R1, PARADO
                      JMP.z Fim_Mov_pacman_dir

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R1, VAZIO
                      MOV M[IO_WRITE], R1
                      INC M[Column_pacman]

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R3, '$'
                      MOV M[IO_WRITE], R3


Fim_Mov_pacman_dir:   POP R3
                      POP R2
                      POP R1
                      RET


;------------------------------------------------------------------------------
; Rotina Att_pacman_dir
;------------------------------------------------------------------------------

                      ;Configura as variáveis de direção e andar do pacman

Att_pacman_dir:       PUSH R1

                      MOV R1, DIR
                      MOV M[Direcao_pacman], R1
                      ;MOV M[Andar_pacman], R1

                      POP R1

                      RTI


;------------------------------------------------------------------------------
; Rotina Mov_pacman_esq
;------------------------------------------------------------------------------


Mov_pacman_esq:       PUSH R1
                      PUSH R2
                      PUSH R3

                      CALL Verifica_parede_esq

                      MOV R1, M[Andar_pacman]
                      CMP R1, PARADO
                      JMP.z Fim_Mov_pacman_dir

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R1, VAZIO
                      MOV M[IO_WRITE], R1
                      DEC M[Column_pacman]

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R3, '$'
                      MOV M[IO_WRITE], R3


                      POP R3
                      POP R2
                      POP R1
                      RET


;------------------------------------------------------------------------------
; Rotina Att_pacman_esq
;------------------------------------------------------------------------------

                      ;Configura as variáveis de direção e andar do pacman

Att_pacman_esq:       PUSH R1

                      MOV R1, ESQ
                      MOV M[Direcao_pacman], R1
                      ;MOV M[Andar_pacman], R1

                      POP R1

                      RTI


;------------------------------------------------------------------------------
; Rotina Mov_pacman_cima
;------------------------------------------------------------------------------


Mov_pacman_cima:      PUSH R1
                      PUSH R2
                      PUSH R3

                      CALL Verifica_parede_cima

                      MOV R1, M[Andar_pacman]
                      CMP R1, PARADO
                      JMP.z Fim_Mov_pacman_dir

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R1, VAZIO
                      MOV M[IO_WRITE], R1
                      DEC M[Row_pacman]

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R3, '$'
                      MOV M[IO_WRITE], R3


                      POP R3
                      POP R2
                      POP R1
                      RET


;------------------------------------------------------------------------------
; Rotina Att_pacman_cima
;------------------------------------------------------------------------------

                      ;Configura as variáveis de direção e andar do pacman

Att_pacman_cima:      PUSH R1

                      MOV R1, CIMA
                      MOV M[Direcao_pacman], R1
                      ;MOV M[Andar_pacman], R1

                      POP R1

                      RTI


;------------------------------------------------------------------------------
; Rotina Mov_pacman_baixo
;------------------------------------------------------------------------------


Mov_pacman_baixo:     PUSH R1
                      PUSH R2
                      PUSH R3

                      CALL Verifica_parede_baixo

                      MOV R1, M[Andar_pacman]
                      CMP R1, PARADO
                      JMP.z Fim_Mov_pacman_dir

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R1, VAZIO
                      MOV M[IO_WRITE], R1
                      INC M[Row_pacman]

                      MOV R1, M[Row_pacman]
                      SHL R1, 8
                      MOV R2, M[Column_pacman]
                      OR R1, R2
                      MOV M[CURSOR], R1
                      MOV R3, '$'
                      MOV M[IO_WRITE], R3


                      POP R3
                      POP R2
                      POP R1
                      RET


;------------------------------------------------------------------------------
; Rotina Att_pacman_baixo
;------------------------------------------------------------------------------

                      ;Configura as variáveis de direção e andar do pacman

Att_pacman_baixo:     PUSH R1

                      MOV R1, BAIXO
                      MOV M[Direcao_pacman], R1
                      ;MOV M[Andar_pacman], R1

                      POP R1

                      RTI


;endereco da pos que pacman tá:
;     pos = (rowpac - 1) * Quant_Column + (columnpac - 1)
;     M[String_0 + pos] --> posição da string que o pacman está

; UTILIZO ESTE CÁLCULO PARA AS FUNÇÕES DE VERIFICAÇÃO DE PAREDE, COMIDA OU BONUS

;------------------------------------------------------------------------------
; Rotina Verifica_parede_dir
;------------------------------------------------------------------------------

Verifica_parede_dir:                 PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     ; SETA O ANDAR DO PACMAN

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_pacman], R1

                                     ; PEGA A LINHA, DECREMENTA

                                     MOV R1, M[Row_pacman]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ; MULTIPLICA A QUANTIDADE DE LINHAS PELA QUANTIDADE DE COLUNAS TOTAL

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     ; PEGA A QUANTIDADE DE COLUNAS E SOMA COM A MULTIPLICAÇÃO ANTERIOR

                                     MOV R3, M[Column_pacman]
                                     ADD R1, R3

                                     ; PERGA A POSIÇÃO DE MEMÓRIA INICIAL DA STRING QUE GUARDA O MAPA E SOMA COM O VALOR ENCONTRADO ANTERIORMENTE

                                     MOV R2, String_0
                                     MOV M[Indice], R2
                                     MOV R2, M[Indice]
                                     ADD R2, R1

                                     MOV M[Indice], R2

                                     ; PEGA O ENDERECO DE MEMORIA CORRESPONDENTE E ACESSA O QUE TEM NELE PARA DESCOBRIR DE É PAREDE, COMIDA OU BONUS

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_pacman
                                     CMP R2, COMIDA
                                     CALL.z Conta_pontos
                                     CMP R2, BONUS
                                     CALL.z Conta_bonus


Fim_verifica_parede_dir:             POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_parede_esq
;------------------------------------------------------------------------------

Verifica_parede_esq:                 PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     ;SETA O ANDAR DO PACMAN

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_pacman], R1

                                     ; PEGA A LINHA E SUBTRAI 1

                                     MOV R1, M[Row_pacman]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ; MULTIPLICA A QUANTIDADE DE LINHAS E MULTIPLICA PELA QUANTIDADE DE COLUNAS

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_pacman]
                                     SUB R3, 2d
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice], R2
                                     MOV R2, M[Indice]
                                     ADD R2, R1

                                     MOV M[Indice], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_pacman
                                     CMP R2, COMIDA
                                     CALL.z Conta_pontos
                                     CMP R2, BONUS
                                     CALL.z Conta_bonus


Fim_verifica_parede_esq:             POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_parede_cima
;------------------------------------------------------------------------------

Verifica_parede_cima:                PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_pacman], R1

                                     MOV R1, M[Row_pacman]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_pacman]
                                     MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                     SUB R3, R2
                                     DEC R3
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice], R2
                                     MOV R2, M[Indice]
                                     ADD R2, R1

                                     MOV M[Indice], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_pacman
                                     CMP R2, COMIDA
                                     CALL.z Conta_pontos
                                     CMP R2, BONUS
                                     CALL.z Conta_bonus


Fim_verifica_parede_cima:            POP R3
                                     POP R2
                                     POP R1
                                     RET

 ;------------------------------------------------------------------------------
 ; Rotina Verifica_parede_baixo
 ;------------------------------------------------------------------------------

 Verifica_parede_baixo:              PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_pacman], R1

                                     MOV R1, M[Row_pacman]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_pacman]
                                     MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                     ADD R3, R2
                                     DEC R3
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice], R2
                                     MOV R2, M[Indice]
                                     ADD R2, R1

                                     MOV M[Indice], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_pacman
                                     CMP R2, COMIDA
                                     CALL.z Conta_pontos
                                     CMP R2, BONUS
                                     CALL.z Conta_bonus


 Fim_verifica_parede_baixo:          POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Parar_pacman
;------------------------------------------------------------------------------

Parar_pacman:                        PUSH R1

                                     MOV R1, PARADO
                                     MOV M[Andar_pacman], R1

                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Conta_pontos
;------------------------------------------------------------------------------

Conta_pontos:                        PUSH R1
                                     PUSH R2

                                     INC M[Pontos]

                                     MOV R1, M[Indice]
                                     MOV R2, VAZIO
                                     MOV M[R1], R2

                                     CALL Imprime_Ponto

                                     MOV R1, M[ Pontos ]
                                     MOV R2, M[ Total_pontos ]

                                     CMP R1, R2
                                     JMP.z Fim_jogo_ganha

                                     POP R1
                                     POP R2
                                     RET

;------------------------------------------------------------------------------
; Rotina Conta_bonus
;------------------------------------------------------------------------------

Conta_bonus:                        PUSH R1
                                    PUSH R2

                                    MOV R1, 100d
                                    ADD M[Pontos], R1

                                    MOV R1, M[Indice]
                                    MOV R2, VAZIO
                                    MOV M[R1], R2

                                    CALL Imprime_Ponto

                                    MOV R1, M[ Pontos ]
                                    MOV R2, M[ Total_pontos ]

                                    CMP R1, R2
                                    JMP.z Fim_jogo_ganha

                                    POP R1
                                    POP R2
                                    RET


;------------------------------------------------------------------------------
; Rotina Pega_Random
;------------------------------------------------------------------------------

Pega_Random:                        PUSH R1
                                    PUSH R2

                                    CALL Random

                                    MOV R1, M[ Random_Var ]
                                    MOV R2, 4d

                                    DIV R1, R2
                                    MOV M [ Direcao_fant1 ], R2

                                    POP R2
                                    POP R1
                                    RET

;------------------------------------------------------------------------------
; Rotina Pega_Random2
;------------------------------------------------------------------------------

Pega_Random2:                       PUSH R1
                                    PUSH R2

                                    CALL Random

                                    MOV R1, M[ Random_Var ]
                                    MOV R2, 4d

                                    DIV R1, R2
                                    MOV M [ Direcao_fant2 ], R2

                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Pega_Random3
;------------------------------------------------------------------------------

Pega_Random3:                       PUSH R1
                                    PUSH R2

                                    CALL Random

                                    MOV R1, M[ Random_Var ]
                                    MOV R2, 4d

                                    DIV R1, R2
                                    MOV M [ Direcao_fant3 ], R2

                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Pega_Random4
;------------------------------------------------------------------------------

Pega_Random4:                       PUSH R1
                                    PUSH R2

                                    CALL Random

                                    MOV R1, M[ Random_Var ]
                                    MOV R2, 4d

                                    DIV R1, R2
                                    MOV M [ Direcao_fant4 ], R2

                                    POP R2
                                    POP R1
                                    RET



;------------------------------------------------------------------------------
; Rotina Mov_fantasma
;------------------------------------------------------------------------------

                    ;if direcao_esq { call Mov_pacman_esq }

Mov_fantasma:                       PUSH R1

                                    ;FANTASMA 1

                                    MOV R1, M[ Direcao_fant1 ]

                                    CMP R1, DIR_FANT
                                    CALL.z Mov_fantasma1_dir

                                    CMP R1, ESQ_FANT
                                    CALL.z Mov_fantasma1_esq

                                    CMP R1, CIMA_FANT
                                    CALL.z Mov_fantasma1_cima

                                    CMP R1, BAIXO_FANT
                                    CALL.z Mov_fantasma1_baixo

                                    CALL Compara_Fant1_Pac

                                    ; FANTASMA 2

                                    MOV R1, M[ Direcao_fant2 ]

                                    CMP R1, DIR_FANT
                                    CALL.z Mov_fantasma2_dir

                                    CMP R1, ESQ_FANT
                                    CALL.z Mov_fantasma2_esq

                                    CMP R1, CIMA_FANT
                                    CALL.z Mov_fantasma2_cima

                                    CMP R1, BAIXO_FANT
                                    CALL.z Mov_fantasma2_baixo


                                    CALL Compara_fant2_Pac


                                    ; FANTASMA 3

                                    MOV R1, M[ Direcao_fant3 ]

                                    CMP R1, DIR_FANT
                                    CALL.z Mov_fantasma3_dir

                                    CMP R1, ESQ_FANT
                                    CALL.z Mov_fantasma3_esq

                                    CMP R1, CIMA_FANT
                                    CALL.z Mov_fantasma3_cima

                                    CMP R1, BAIXO_FANT
                                    CALL.z Mov_fantasma3_baixo

                                    CALL Compara_fant3_Pac

                                    ; FANTASMA 4

                                    MOV R1, M[ Direcao_fant4 ]

                                    CMP R1, DIR_FANT
                                    CALL.z Mov_fantasma4_dir

                                    CMP R1, ESQ_FANT
                                    CALL.z Mov_fantasma4_esq

                                    CMP R1, CIMA_FANT
                                    CALL.z Mov_fantasma4_cima

                                    CMP R1, BAIXO_FANT
                                    CALL.z Mov_fantasma4_baixo


                                    CALL Compara_fant4_Pac

                                    POP R1

                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma1_dir
;------------------------------------------------------------------------------


Mov_fantasma1_dir:                  PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    CALL Verifica_parede_fant1_dir

                                    MOV R1, M[Andar_fant1]
                                    CMP R1, PARADO
                                    JMP.z Fim_Mov_fant1_dir

                                    CALL Verifica_pos_fant1_dir

                                    MOV R1, M[ Row_fant1 ]
                                    SHL R1, 8
                                    MOV R2, M[ Column_fant1 ]
                                    OR R1, R2
                                    MOV M[ CURSOR ], R1
                                    MOV R3, '&'
                                    MOV M[ IO_WRITE ], R3

Fim_Mov_fant1_dir:                  POP R3
                                    POP R2
                                    POP R1
                                    RET



;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant1_dir
;------------------------------------------------------------------------------

;endereco da pos que pacman tá:
;     pos = (rowpac - 1) * Quant_Column + (columnpac - 1)
;     M[String_0 + pos] --> posição da string que o pacman está


Verifica_parede_fant1_dir:           PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant1], R1

                                     MOV R1, M[Row_fant1]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant1]
                                     ;DEC R3
                                     ADD R1, R3


                                     ;INC R1
                                     MOV R2, String_0
                                     MOV M[Indice_fant1], R2
                                     MOV R2, M[Indice_fant1]
                                     ADD R2, R1

                                     MOV M[Indice_fant1], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.z Parar_fantasma


                                     POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant1_dir
;------------------------------------------------------------------------------


Verifica_pos_fant1_dir:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant1]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant1]
                                    ;DEC R3
                                    ADD R1, R3


                                    ;INC R1
                                    MOV R2, String_0
                                    MOV M[Indice_fant1], R2
                                    MOV R2, M[Indice_fant1]
                                    ADD R2, R1

                                    DEC R2

                                    MOV M[Indice_fant1], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant1 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant1 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    INC M[ Column_fant1 ]


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma1_esq
;------------------------------------------------------------------------------


Mov_fantasma1_esq:                   PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant1_esq

                                     MOV R1, M[Andar_fant1]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant1_esq

                                     CALL Verifica_pos_fant1_esq

                                     MOV R1, M[Row_fant1]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant1]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant1_esq:                   POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant1_esq
;------------------------------------------------------------------------------

Verifica_parede_fant1_esq:          PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant1], R1


                                    MOV R1, M[Row_fant1]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant1]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant1], R2
                                    MOV R2, M[Indice_fant1]
                                    ADD R2, R1

                                    MOV M[Indice_fant1], R2

                                    MOV R2, M[R2]
                                    CMP R2, PAREDE
                                    CALL.Z Parar_fantasma
                                    ;CMP R2, COMIDA


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant1_esq
;------------------------------------------------------------------------------

Verifica_pos_fant1_esq:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant1]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant1]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant1], R2
                                    MOV R2, M[Indice_fant1]
                                    ADD R2, R1
                                    INC R2

                                    MOV M[Indice_fant1], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant1 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant1 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Column_fant1 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma1_cima
;------------------------------------------------------------------------------


Mov_fantasma1_cima:                   PUSH R1
                                      PUSH R2
                                      PUSH R3

                                      CALL Verifica_parede_fant1_cima

                                      MOV R1, M[Andar_fant1]
                                      CMP R1, PARADO
                                      JMP.z Fim_Mov_fant1_cima

                                      CALL Verifica_pos_fant1_cima

                                      MOV R1, M[Row_fant1]
                                      SHL R1, 8
                                      MOV R2, M[Column_fant1]
                                      OR R1, R2
                                      MOV M[CURSOR], R1
                                      MOV R3, '&'
                                      MOV M[IO_WRITE], R3

Fim_Mov_fant1_cima:                   POP R3
                                      POP R2
                                      POP R1
                                      RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant1_cima
;------------------------------------------------------------------------------

Verifica_parede_fant1_cima:          PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant1], R1


                                     MOV R1, M[Row_fant1]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant1]
                                     MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                     SUB R3, R2
                                     DEC R3
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice_fant1], R2
                                     MOV R2, M[Indice_fant1]
                                     ADD R2, R1

                                     MOV M[Indice_fant1], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_fantasma
                                     ;CMP R2, COMIDA

                                     POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant1_cima
;------------------------------------------------------------------------------

Verifica_pos_fant1_cima:            PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant1], R1


                                    MOV R1, M[Row_fant1]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant1]
                                    MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                    SUB R3, R2
                                    DEC R3
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant1], R2
                                    MOV R2, M[Indice_fant1]
                                    ADD R2, R1

                                    ADD R2, QUANT_COLUMN

                                    MOV M[Indice_fant1], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant1 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant1 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Row_fant1 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma1_baixo
;------------------------------------------------------------------------------


Mov_fantasma1_baixo:                 PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant1_baixo

                                     MOV R1, M[Andar_fant1]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant1_baixo

                                     CALL Verifica_pos_fant1_baixo

                                     MOV R1, M[Row_fant1]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant1]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant1_baixo:                 POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant1_baixo
;------------------------------------------------------------------------------

Verifica_parede_fant1_baixo:       PUSH R1
                                   PUSH R2
                                   PUSH R3


                                   MOV R1, MOVIMENTO
                                   MOV M[Andar_fant1], R1


                                   MOV R1, M[Row_fant1]
                                   DEC R1
                                   MOV R3, QUANT_COLUMN

                                   ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                   MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                   MOV R3, M[Column_fant1]
                                   MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                   ADD R3, R2
                                   DEC R3
                                   ADD R1, R3

                                   MOV R2, String_0
                                   MOV M[Indice_fant1], R2
                                   MOV R2, M[Indice_fant1]
                                   ADD R2, R1

                                   MOV M[Indice_fant1], R2

                                   MOV R2, M[R2]
                                   CMP R2, PAREDE
                                   CALL.Z Parar_fantasma
                                   ;CMP R2, COMIDA

                                   POP R3
                                   POP R2
                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant1_baixo
;------------------------------------------------------------------------------

Verifica_pos_fant1_baixo:         PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R1, M[Row_fant1]
                                  DEC R1
                                  MOV R3, QUANT_COLUMN

                                  ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                  MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                  MOV R3, M[Column_fant1]
                                  MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                  ADD R3, R2
                                  DEC R3
                                  ADD R1, R3

                                  MOV R2, String_0
                                  MOV M[Indice_fant1], R2
                                  MOV R2, M[Indice_fant1]
                                  ADD R2, R1

                                  SUB R2, QUANT_COLUMN

                                  MOV M[Indice_fant1], R2

                                  MOV R2, M[R2]

                                  MOV R1, M[ Row_fant1 ]
                                  SHL R1, 8
                                  MOV R3, M[ Column_fant1 ]
                                  OR R1, R3
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R2

                                  INC M[ Row_fant1 ]

                                  POP R3
                                  POP R2
                                  POP R1
                                  RET




;------------------------------------------------------------------------------
; Rotina Parar_fantasma
;------------------------------------------------------------------------------

Parar_fantasma:                    PUSH R1

                                   MOV R1, PARADO
                                   MOV M[Andar_fant1], R1

                                   CALL Pega_Random

                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Compara_Fant1_Pac
;------------------------------------------------------------------------------

Compara_Fant1_Pac:                PUSH R1
                                  PUSH R2

                                  MOV R1, M[ Row_fant1 ]
                                  MOV R2, M[ Row_pacman ]
                                  CMP R2, R1
                                  JMP.NZ  Fim_Compara
                                  MOV R1, M[ Column_fant1 ]
                                  MOV R2, M[ Column_pacman ]
                                  CMP R2, R1
                                  CALL.Z Perde_vida

Fim_Compara:                      POP R2
                                  POP R1
                                  RET





; FUNÇÕES PARA O SEGUNDO FANTASMA


;------------------------------------------------------------------------------
; Rotina Mov_fantasma2_dir
;------------------------------------------------------------------------------


Mov_fantasma2_dir:                  PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    CALL Verifica_parede_fant2_dir

                                    MOV R1, M[Andar_fant2]
                                    CMP R1, PARADO
                                    JMP.z Fim_Mov_fant2_dir

                                    CALL Verifica_pos_fant2_dir

                                    MOV R1, M[ Row_fant2 ]
                                    SHL R1, 8
                                    MOV R2, M[ Column_fant2 ]
                                    OR R1, R2
                                    MOV M[ CURSOR ], R1
                                    MOV R3, '&'
                                    MOV M[ IO_WRITE ], R3

Fim_Mov_fant2_dir:                  POP R3
                                    POP R2
                                    POP R1
                                    RET



;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant2_dir
;------------------------------------------------------------------------------

;endereco da pos que pacman tá:
;     pos = (rowpac - 1) * Quant_Column + (columnpac - 1)
;     M[String_0 + pos] --> posição da string que o pacman está


Verifica_parede_fant2_dir:           PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant2], R1

                                     MOV R1, M[Row_fant2]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant2]
                                     ;DEC R3
                                     ADD R1, R3


                                     ;INC R1
                                     MOV R2, String_0
                                     MOV M[Indice_fant2], R2
                                     MOV R2, M[Indice_fant2]
                                     ADD R2, R1

                                     MOV M[Indice_fant2], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.z Parar_fantasma2


                                     POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant2_dir
;------------------------------------------------------------------------------


Verifica_pos_fant2_dir:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant2]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant2]
                                    ;DEC R3
                                    ADD R1, R3


                                    ;INC R1
                                    MOV R2, String_0
                                    MOV M[Indice_fant2], R2
                                    MOV R2, M[Indice_fant2]
                                    ADD R2, R1

                                    DEC R2

                                    MOV M[Indice_fant2], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant2 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant2 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    INC M[ Column_fant2 ]


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma2_esq
;------------------------------------------------------------------------------


Mov_fantasma2_esq:                   PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant2_esq

                                     MOV R1, M[Andar_fant2]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant2_esq

                                     CALL Verifica_pos_fant2_esq

                                     MOV R1, M[Row_fant2]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant2]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant2_esq:                   POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant2_esq
;------------------------------------------------------------------------------

Verifica_parede_fant2_esq:          PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant2], R1


                                    MOV R1, M[Row_fant2]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant2]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant2], R2
                                    MOV R2, M[Indice_fant2]
                                    ADD R2, R1

                                    MOV M[Indice_fant2], R2

                                    MOV R2, M[R2]
                                    CMP R2, PAREDE
                                    CALL.Z Parar_fantasma2
                                    ;CMP R2, COMIDA


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant2_esq
;------------------------------------------------------------------------------

Verifica_pos_fant2_esq:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant2]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant2]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant2], R2
                                    MOV R2, M[Indice_fant2]
                                    ADD R2, R1
                                    INC R2

                                    MOV M[Indice_fant2], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant2 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant2 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Column_fant2 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma2_cima
;------------------------------------------------------------------------------


Mov_fantasma2_cima:                   PUSH R1
                                      PUSH R2
                                      PUSH R3

                                      CALL Verifica_parede_fant2_cima

                                      MOV R1, M[Andar_fant2]
                                      CMP R1, PARADO
                                      JMP.z Fim_Mov_fant2_cima

                                      CALL Verifica_pos_fant2_cima

                                      MOV R1, M[Row_fant2]
                                      SHL R1, 8
                                      MOV R2, M[Column_fant2]
                                      OR R1, R2
                                      MOV M[CURSOR], R1
                                      MOV R3, '&'
                                      MOV M[IO_WRITE], R3

Fim_Mov_fant2_cima:                   POP R3
                                      POP R2
                                      POP R1
                                      RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant2_cima
;------------------------------------------------------------------------------

Verifica_parede_fant2_cima:          PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant2], R1


                                     MOV R1, M[Row_fant2]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant2]
                                     MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                     SUB R3, R2
                                     DEC R3
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice_fant2], R2
                                     MOV R2, M[Indice_fant2]
                                     ADD R2, R1

                                     MOV M[Indice_fant2], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_fantasma2
                                     ;CMP R2, COMIDA

                                     POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant2_cima
;------------------------------------------------------------------------------

Verifica_pos_fant2_cima:            PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant2], R1


                                    MOV R1, M[Row_fant2]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant2]
                                    MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                    SUB R3, R2
                                    DEC R3
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant2], R2
                                    MOV R2, M[Indice_fant2]
                                    ADD R2, R1

                                    ADD R2, QUANT_COLUMN

                                    MOV M[Indice_fant2], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant2 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant2 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Row_fant2 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma2_baixo
;------------------------------------------------------------------------------


Mov_fantasma2_baixo:                 PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant2_baixo

                                     MOV R1, M[Andar_fant2]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant2_baixo

                                     CALL Verifica_pos_fant2_baixo

                                     MOV R1, M[Row_fant2]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant2]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant2_baixo:                 POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant2_baixo
;------------------------------------------------------------------------------

Verifica_parede_fant2_baixo:       PUSH R1
                                   PUSH R2
                                   PUSH R3


                                   MOV R1, MOVIMENTO
                                   MOV M[Andar_fant2], R1


                                   MOV R1, M[Row_fant2]
                                   DEC R1
                                   MOV R3, QUANT_COLUMN

                                   ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                   MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                   MOV R3, M[Column_fant2]
                                   MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                   ADD R3, R2
                                   DEC R3
                                   ADD R1, R3

                                   MOV R2, String_0
                                   MOV M[Indice_fant2], R2
                                   MOV R2, M[Indice_fant2]
                                   ADD R2, R1

                                   MOV M[Indice_fant2], R2

                                   MOV R2, M[R2]
                                   CMP R2, PAREDE
                                   CALL.Z Parar_fantasma2
                                   ;CMP R2, COMIDA

                                   POP R3
                                   POP R2
                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant2_baixo
;------------------------------------------------------------------------------

Verifica_pos_fant2_baixo:         PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R1, M[Row_fant2]
                                  DEC R1
                                  MOV R3, QUANT_COLUMN

                                  ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                  MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                  MOV R3, M[Column_fant2]
                                  MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                  ADD R3, R2
                                  DEC R3
                                  ADD R1, R3

                                  MOV R2, String_0
                                  MOV M[Indice_fant2], R2
                                  MOV R2, M[Indice_fant2]
                                  ADD R2, R1

                                  SUB R2, QUANT_COLUMN

                                  MOV M[Indice_fant2], R2

                                  MOV R2, M[R2]

                                  MOV R1, M[ Row_fant2 ]
                                  SHL R1, 8
                                  MOV R3, M[ Column_fant2 ]
                                  OR R1, R3
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R2

                                  INC M[ Row_fant2 ]

                                  POP R3
                                  POP R2
                                  POP R1
                                  RET




;------------------------------------------------------------------------------
; Rotina Parar_fantasma2
;------------------------------------------------------------------------------

Parar_fantasma2:                   PUSH R1

                                   MOV R1, PARADO
                                   MOV M[Andar_fant2], R1

                                   CALL Pega_Random2

                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Compara_fant2_Pac
;------------------------------------------------------------------------------

Compara_fant2_Pac:                PUSH R1
                                  PUSH R2

                                  MOV R1, M[ Row_fant2 ]
                                  MOV R2, M[ Row_pacman ]
                                  CMP R2, R1
                                  JMP.NZ  Fim_Compara2
                                  MOV R1, M[ Column_fant2 ]
                                  MOV R2, M[ Column_pacman ]
                                  CMP R2, R1
                                  CALL.Z Perde_vida

Fim_Compara2:                     POP R2
                                  POP R1
                                  RET



; FUNÇÕES FANTASMA 3



;------------------------------------------------------------------------------
; Rotina Mov_fantasma3_dir
;------------------------------------------------------------------------------


Mov_fantasma3_dir:                  PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    CALL Verifica_parede_fant3_dir

                                    MOV R1, M[Andar_fant3]
                                    CMP R1, PARADO
                                    JMP.z Fim_Mov_fant3_dir

                                    CALL Verifica_pos_fant3_dir

                                    MOV R1, M[ Row_fant3 ]
                                    SHL R1, 8
                                    MOV R2, M[ Column_fant3 ]
                                    OR R1, R2
                                    MOV M[ CURSOR ], R1
                                    MOV R3, '&'
                                    MOV M[ IO_WRITE ], R3

Fim_Mov_fant3_dir:                  POP R3
                                    POP R2
                                    POP R1
                                    RET



;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant3_dir
;------------------------------------------------------------------------------

;endereco da pos que pacman tá:
;     pos = (rowpac - 1) * Quant_Column + (columnpac - 1)
;     M[String_0 + pos] --> posição da string que o pacman está


Verifica_parede_fant3_dir:           PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant3], R1

                                     MOV R1, M[Row_fant3]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant3]
                                     ;DEC R3
                                     ADD R1, R3


                                     ;INC R1
                                     MOV R2, String_0
                                     MOV M[Indice_fant3], R2
                                     MOV R2, M[Indice_fant3]
                                     ADD R2, R1

                                     MOV M[Indice_fant3], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.z Parar_fantasma3


                                     POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant3_dir
;------------------------------------------------------------------------------


Verifica_pos_fant3_dir:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant3]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant3]
                                    ;DEC R3
                                    ADD R1, R3


                                    ;INC R1
                                    MOV R2, String_0
                                    MOV M[Indice_fant3], R2
                                    MOV R2, M[Indice_fant3]
                                    ADD R2, R1

                                    DEC R2

                                    MOV M[Indice_fant3], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant3 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant3 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    INC M[ Column_fant3 ]


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma3_esq
;------------------------------------------------------------------------------


Mov_fantasma3_esq:                   PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant3_esq

                                     MOV R1, M[Andar_fant3]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant3_esq

                                     CALL Verifica_pos_fant3_esq

                                     MOV R1, M[Row_fant3]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant3]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant3_esq:                   POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant3_esq
;------------------------------------------------------------------------------

Verifica_parede_fant3_esq:          PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant3], R1


                                    MOV R1, M[Row_fant3]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant3]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant3], R2
                                    MOV R2, M[Indice_fant3]
                                    ADD R2, R1

                                    MOV M[Indice_fant3], R2

                                    MOV R2, M[R2]
                                    CMP R2, PAREDE
                                    CALL.Z Parar_fantasma3
                                    ;CMP R2, COMIDA


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant3_esq
;------------------------------------------------------------------------------

Verifica_pos_fant3_esq:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant3]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant3]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant3], R2
                                    MOV R2, M[Indice_fant3]
                                    ADD R2, R1
                                    INC R2

                                    MOV M[Indice_fant3], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant3 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant3 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Column_fant3 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma3_cima
;------------------------------------------------------------------------------


Mov_fantasma3_cima:                   PUSH R1
                                      PUSH R2
                                      PUSH R3

                                      CALL Verifica_parede_fant3_cima

                                      MOV R1, M[Andar_fant3]
                                      CMP R1, PARADO
                                      JMP.z Fim_Mov_fant3_cima

                                      CALL Verifica_pos_fant3_cima

                                      MOV R1, M[Row_fant3]
                                      SHL R1, 8
                                      MOV R2, M[Column_fant3]
                                      OR R1, R2
                                      MOV M[CURSOR], R1
                                      MOV R3, '&'
                                      MOV M[IO_WRITE], R3

Fim_Mov_fant3_cima:                   POP R3
                                      POP R2
                                      POP R1
                                      RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant3_cima
;------------------------------------------------------------------------------

Verifica_parede_fant3_cima:          PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant3], R1


                                     MOV R1, M[Row_fant3]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant3]
                                     MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                     SUB R3, R2
                                     DEC R3
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice_fant3], R2
                                     MOV R2, M[Indice_fant3]
                                     ADD R2, R1

                                     MOV M[Indice_fant3], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_fantasma3
                                     ;CMP R2, COMIDA

                                     POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant3_cima
;------------------------------------------------------------------------------

Verifica_pos_fant3_cima:            PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant3], R1


                                    MOV R1, M[Row_fant3]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant3]
                                    MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                    SUB R3, R2
                                    DEC R3
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant3], R2
                                    MOV R2, M[Indice_fant3]
                                    ADD R2, R1

                                    ADD R2, QUANT_COLUMN

                                    MOV M[Indice_fant3], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant3 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant3 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Row_fant3 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma3_baixo
;------------------------------------------------------------------------------


Mov_fantasma3_baixo:                 PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant3_baixo

                                     MOV R1, M[Andar_fant3]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant3_baixo

                                     CALL Verifica_pos_fant3_baixo

                                     MOV R1, M[Row_fant3]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant3]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant3_baixo:                 POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant3_baixo
;------------------------------------------------------------------------------

Verifica_parede_fant3_baixo:       PUSH R1
                                   PUSH R2
                                   PUSH R3


                                   MOV R1, MOVIMENTO
                                   MOV M[Andar_fant3], R1


                                   MOV R1, M[Row_fant3]
                                   DEC R1
                                   MOV R3, QUANT_COLUMN

                                   ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                   MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                   MOV R3, M[Column_fant3]
                                   MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                   ADD R3, R2
                                   DEC R3
                                   ADD R1, R3

                                   MOV R2, String_0
                                   MOV M[Indice_fant3], R2
                                   MOV R2, M[Indice_fant3]
                                   ADD R2, R1

                                   MOV M[Indice_fant3], R2

                                   MOV R2, M[R2]
                                   CMP R2, PAREDE
                                   CALL.Z Parar_fantasma3
                                   ;CMP R2, COMIDA

                                   POP R3
                                   POP R2
                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant3_baixo
;------------------------------------------------------------------------------

Verifica_pos_fant3_baixo:         PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R1, M[Row_fant3]
                                  DEC R1
                                  MOV R3, QUANT_COLUMN

                                  ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                  MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                  MOV R3, M[Column_fant3]
                                  MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                  ADD R3, R2
                                  DEC R3
                                  ADD R1, R3

                                  MOV R2, String_0
                                  MOV M[Indice_fant3], R2
                                  MOV R2, M[Indice_fant3]
                                  ADD R2, R1

                                  SUB R2, QUANT_COLUMN

                                  MOV M[Indice_fant3], R2

                                  MOV R2, M[R2]

                                  MOV R1, M[ Row_fant3 ]
                                  SHL R1, 8
                                  MOV R3, M[ Column_fant3 ]
                                  OR R1, R3
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R2

                                  INC M[ Row_fant3 ]

                                  POP R3
                                  POP R2
                                  POP R1
                                  RET




;------------------------------------------------------------------------------
; Rotina Parar_fantasma3
;------------------------------------------------------------------------------

Parar_fantasma3:                   PUSH R1

                                   MOV R1, PARADO
                                   MOV M[Andar_fant3], R1

                                   CALL Pega_Random3

                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Compara_fant3_Pac
;------------------------------------------------------------------------------

Compara_fant3_Pac:                PUSH R1
                                  PUSH R2

                                  MOV R1, M[ Row_fant3 ]
                                  MOV R2, M[ Row_pacman ]
                                  CMP R2, R1
                                  JMP.NZ  Fim_Compara3
                                  MOV R1, M[ Column_fant3 ]
                                  MOV R2, M[ Column_pacman ]
                                  CMP R2, R1
                                  CALL.Z Perde_vida

Fim_Compara3:                     POP R2
                                  POP R1
                                  RET



; FUNÇÕES PARA O FANTASMA 4

;------------------------------------------------------------------------------
; Rotina Mov_fantasma4_dir
;------------------------------------------------------------------------------


Mov_fantasma4_dir:                  PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    CALL Verifica_parede_fant4_dir

                                    MOV R1, M[Andar_fant4]
                                    CMP R1, PARADO
                                    JMP.z Fim_Mov_fant4_dir

                                    CALL Verifica_pos_fant4_dir

                                    MOV R1, M[ Row_fant4 ]
                                    SHL R1, 8
                                    MOV R2, M[ Column_fant4 ]
                                    OR R1, R2
                                    MOV M[ CURSOR ], R1
                                    MOV R3, '&'
                                    MOV M[ IO_WRITE ], R3

Fim_Mov_fant4_dir:                  POP R3
                                    POP R2
                                    POP R1
                                    RET



;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant4_dir
;------------------------------------------------------------------------------

;endereco da pos que pacman tá:
;     pos = (rowpac - 1) * Quant_Column + (columnpac - 1)
;     M[String_0 + pos] --> posição da string que o pacman está


Verifica_parede_fant4_dir:           PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant4], R1

                                     MOV R1, M[Row_fant4]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant4]
                                     ;DEC R3
                                     ADD R1, R3


                                     ;INC R1
                                     MOV R2, String_0
                                     MOV M[Indice_fant4], R2
                                     MOV R2, M[Indice_fant4]
                                     ADD R2, R1

                                     MOV M[Indice_fant4], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.z Parar_fantasma4


                                     POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant4_dir
;------------------------------------------------------------------------------


Verifica_pos_fant4_dir:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant4]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant4]
                                    ;DEC R3
                                    ADD R1, R3


                                    ;INC R1
                                    MOV R2, String_0
                                    MOV M[Indice_fant4], R2
                                    MOV R2, M[Indice_fant4]
                                    ADD R2, R1

                                    DEC R2

                                    MOV M[Indice_fant4], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant4 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant4 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    INC M[ Column_fant4 ]


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma4_esq
;------------------------------------------------------------------------------


Mov_fantasma4_esq:                   PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant4_esq

                                     MOV R1, M[Andar_fant4]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant4_esq

                                     CALL Verifica_pos_fant4_esq

                                     MOV R1, M[Row_fant4]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant4]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant4_esq:                   POP R3
                                     POP R2
                                     POP R1
                                     RET

;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant4_esq
;------------------------------------------------------------------------------

Verifica_parede_fant4_esq:          PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant4], R1


                                    MOV R1, M[Row_fant4]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant4]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant4], R2
                                    MOV R2, M[Indice_fant4]
                                    ADD R2, R1

                                    MOV M[Indice_fant4], R2

                                    MOV R2, M[R2]
                                    CMP R2, PAREDE
                                    CALL.Z Parar_fantasma4
                                    ;CMP R2, COMIDA


                                    POP R3
                                    POP R2
                                    POP R1
                                    RET

;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant4_esq
;------------------------------------------------------------------------------

Verifica_pos_fant4_esq:             PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, M[Row_fant4]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant4]
                                    SUB R3, 2d
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant4], R2
                                    MOV R2, M[Indice_fant4]
                                    ADD R2, R1
                                    INC R2

                                    MOV M[Indice_fant4], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant4 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant4 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Column_fant4 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma4_cima
;------------------------------------------------------------------------------


Mov_fantasma4_cima:                   PUSH R1
                                      PUSH R2
                                      PUSH R3

                                      CALL Verifica_parede_fant4_cima

                                      MOV R1, M[Andar_fant4]
                                      CMP R1, PARADO
                                      JMP.z Fim_Mov_fant4_cima

                                      CALL Verifica_pos_fant4_cima

                                      MOV R1, M[Row_fant4]
                                      SHL R1, 8
                                      MOV R2, M[Column_fant4]
                                      OR R1, R2
                                      MOV M[CURSOR], R1
                                      MOV R3, '&'
                                      MOV M[IO_WRITE], R3

Fim_Mov_fant4_cima:                   POP R3
                                      POP R2
                                      POP R1
                                      RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant4_cima
;------------------------------------------------------------------------------

Verifica_parede_fant4_cima:          PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     MOV R1, MOVIMENTO
                                     MOV M[Andar_fant4], R1


                                     MOV R1, M[Row_fant4]
                                     DEC R1
                                     MOV R3, QUANT_COLUMN

                                     ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                     MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                     MOV R3, M[Column_fant4]
                                     MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                     SUB R3, R2
                                     DEC R3
                                     ADD R1, R3

                                     MOV R2, String_0
                                     MOV M[Indice_fant4], R2
                                     MOV R2, M[Indice_fant4]
                                     ADD R2, R1

                                     MOV M[Indice_fant4], R2

                                     MOV R2, M[R2]
                                     CMP R2, PAREDE
                                     CALL.Z Parar_fantasma4
                                     ;CMP R2, COMIDA

                                     POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant4_cima
;------------------------------------------------------------------------------

Verifica_pos_fant4_cima:            PUSH R1
                                    PUSH R2
                                    PUSH R3

                                    MOV R1, MOVIMENTO
                                    MOV M[Andar_fant4], R1


                                    MOV R1, M[Row_fant4]
                                    DEC R1
                                    MOV R3, QUANT_COLUMN

                                    ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                    MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                    MOV R3, M[Column_fant4]
                                    MOV R2, QUANT_COLUMN ; vou diminuir a quantidade de colunas e decrementar mais 1 para pegar a posição a cima do pacman
                                    SUB R3, R2
                                    DEC R3
                                    ADD R1, R3

                                    MOV R2, String_0
                                    MOV M[Indice_fant4], R2
                                    MOV R2, M[Indice_fant4]
                                    ADD R2, R1

                                    ADD R2, QUANT_COLUMN

                                    MOV M[Indice_fant4], R2

                                    MOV R2, M[R2]

                                    MOV R1, M[ Row_fant4 ]
                                    SHL R1, 8
                                    MOV R3, M[ Column_fant4 ]
                                    OR R1, R3
                                    MOV M[ CURSOR ], R1
                                    MOV M[ IO_WRITE ], R2

                                    DEC M [ Row_fant4 ]

                                    POP R3
                                    POP R2
                                    POP R1
                                    RET


;------------------------------------------------------------------------------
; Rotina Mov_fantasma4_baixo
;------------------------------------------------------------------------------


Mov_fantasma4_baixo:                 PUSH R1
                                     PUSH R2
                                     PUSH R3

                                     CALL Verifica_parede_fant4_baixo

                                     MOV R1, M[Andar_fant4]
                                     CMP R1, PARADO
                                     JMP.z Fim_Mov_fant4_baixo

                                     CALL Verifica_pos_fant4_baixo

                                     MOV R1, M[Row_fant4]
                                     SHL R1, 8
                                     MOV R2, M[Column_fant4]
                                     OR R1, R2
                                     MOV M[CURSOR], R1
                                     MOV R3, '&'
                                     MOV M[IO_WRITE], R3

Fim_Mov_fant4_baixo:                 POP R3
                                     POP R2
                                     POP R1
                                     RET


;------------------------------------------------------------------------------
; Rotina Verifica_parede_fant4_baixo
;------------------------------------------------------------------------------

Verifica_parede_fant4_baixo:       PUSH R1
                                   PUSH R2
                                   PUSH R3


                                   MOV R1, MOVIMENTO
                                   MOV M[Andar_fant4], R1


                                   MOV R1, M[Row_fant4]
                                   DEC R1
                                   MOV R3, QUANT_COLUMN

                                   ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                   MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                   MOV R3, M[Column_fant4]
                                   MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                   ADD R3, R2
                                   DEC R3
                                   ADD R1, R3

                                   MOV R2, String_0
                                   MOV M[Indice_fant4], R2
                                   MOV R2, M[Indice_fant4]
                                   ADD R2, R1

                                   MOV M[Indice_fant4], R2

                                   MOV R2, M[R2]
                                   CMP R2, PAREDE
                                   CALL.Z Parar_fantasma4
                                   ;CMP R2, COMIDA

                                   POP R3
                                   POP R2
                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Verifica_pos_fant4_baixo
;------------------------------------------------------------------------------

Verifica_pos_fant4_baixo:         PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R1, M[Row_fant4]
                                  DEC R1
                                  MOV R3, QUANT_COLUMN

                                  ;em uma multiplicação é usado os dois registradores para guardar o valor da operação
                                  MUL R3, R1 ;os bits mais significativos são guardados em R3 e os menos significativos (que vão conter de fato o valor que eu quero), serão guardados em R1

                                  MOV R3, M[Column_fant4]
                                  MOV R2, QUANT_COLUMN ; vou adicionar a quantidade de colunas e somar mais 1 para pegar a posição logo a baixo do pacman
                                  ADD R3, R2
                                  DEC R3
                                  ADD R1, R3

                                  MOV R2, String_0
                                  MOV M[Indice_fant4], R2
                                  MOV R2, M[Indice_fant4]
                                  ADD R2, R1

                                  SUB R2, QUANT_COLUMN

                                  MOV M[Indice_fant4], R2

                                  MOV R2, M[R2]

                                  MOV R1, M[ Row_fant4 ]
                                  SHL R1, 8
                                  MOV R3, M[ Column_fant4 ]
                                  OR R1, R3
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R2

                                  INC M[ Row_fant4 ]

                                  POP R3
                                  POP R2
                                  POP R1
                                  RET




;------------------------------------------------------------------------------
; Rotina Parar_fantasma4
;------------------------------------------------------------------------------

Parar_fantasma4:                   PUSH R1

                                   MOV R1, PARADO
                                   MOV M[Andar_fant4], R1

                                   CALL Pega_Random4

                                   POP R1
                                   RET


;------------------------------------------------------------------------------
; Rotina Compara_fant4_Pac
;------------------------------------------------------------------------------

Compara_fant4_Pac:                PUSH R1
                                  PUSH R2

                                  MOV R1, M[ Row_fant4 ]
                                  MOV R2, M[ Row_pacman ]
                                  CMP R2, R1
                                  JMP.NZ  Fim_Compara4
                                  MOV R1, M[ Column_fant4 ]
                                  MOV R2, M[ Column_pacman ]
                                  CMP R2, R1
                                  CALL.Z Perde_vida

Fim_Compara4:                     POP R2
                                  POP R1
                                  RET









;------------------------------------------------------------------------------
; Rotina Perde_vida
;------------------------------------------------------------------------------

Perde_vida:                       PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R3, ' '

                                  MOV R1, M[ Row_vida ]
                                  MOV R2, M[ Column_vida ]
                                  SHL R1, 8
                                  OR R1, R2
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R3

                                  DEC M[ Column_vida ]
                                  MOV R1, M[ Row_vida ]
                                  MOV R2, M[ Column_vida ]
                                  SHL R1, 8
                                  OR R1, R2
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R3

                                  DEC M[ Column_vida ]
                                  MOV R1, M[ Row_vida ]
                                  MOV R2, M[ Column_vida ]
                                  SHL R1, 8
                                  OR R1, R2
                                  MOV M[ CURSOR ], R1
                                  MOV M[ IO_WRITE ], R3

                                  DEC M[ Column_vida ]


                                  ;Reposiciona pacman para a posição inicial

                                  MOV R1, M[ Row_pacman_i ]
                                  MOV R2, M[ Column_pacman_i ]

                                  MOV M[ Row_pacman ], R1
                                  MOV M[ Column_pacman ], R2

                                  SHL R1, 8
                                  OR R1, R2
                                  MOV M[ CURSOR ], R1
                                  MOV R1, '$'
                                  MOV M[ IO_WRITE ], R1

                                  MOV R3, PARADO
                                  MOV M[ Andar_pacman ], R3
                                  MOV R3, NO_DIRECTION
                                  MOV M[ Direcao_pacman ], R3


                                  DEC M[ vidas ]
                                  MOV R3, M[ vidas ]
                                  CMP R3, R0
                                  JMP.Z Fim_jogo

                                  POP R3
                                  POP R2
                                  POP R1
                                  RET




;------------------------------------------------------------------------------
; Rotina Main
;------------------------------------------------------------------------------



Main:			                           ENI
                        				     MOV		R1, INITIAL_SP
                            				 MOV		SP, R1		 		; We need to initialize the stack
                            				 MOV		R1, CURSOR_INIT		; We need to initialize the cursor
                            				 MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

                                     CALL Imprime_Nivel
                                     CALL Imprime_Ponto
                                     CALL Imprime_Vidas

                                     CALL Random

                                     MOV R1, 137d
                                     MOV R2, 100d
                                     DIV R1, R2
                                     MOV R1, R2
                                     MOV R2, 10d
                                     DIV R1, R2



                                     MOV R1, INTERVAL_TIMER
                                     MOV M[CONFIG_TIMER], R1
                                     MOV R1, TIMER_ON
                                     MOV M[ATIVAR_TIMER], R1



Cycle: 			BR		Cycle

;------------------------------------------------------------------------------
; Rotina Fim_jogo
;------------------------------------------------------------------------------

Fim_jogo_ganha:                   PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R1, 20d
                                  MOV R2, 1d

                                  MOV R3, String_ganha
                                  MOV M[ Indice ], R3

Cursor_imprime_ganha:             MOV   R1, 20d
                                  SHL		R1, 8
                                  OR		R1, R2
                                  MOV		M[ CURSOR ], R1

                                  MOV R3, M[ Indice ]
                                  MOV R3, M[ R3 ]

                                  CMP R3, FIM_STRING
                                  JMP.Z Mov_fim_jogo

                                  MOV M[ IO_WRITE ], R3

                                  INC M[ Indice ]
                                  INC R2

                                  JMP Cursor_imprime_ganha


;------------------------------------------------------------------------------
; Rotina Fim_jogo
;------------------------------------------------------------------------------

Fim_jogo:                         PUSH R1
                                  PUSH R2
                                  PUSH R3

                                  MOV R1, 20d
                                  MOV R2, 1d

                                  MOV R3, String_perda
                                  MOV M[ Indice ], R3

Cursor_imprime_jogo:              MOV   R1, 20d
                                  SHL		R1, 8
                                  OR		R1, R2
                                  MOV		M[ CURSOR ], R1

                                  MOV R3, M[ Indice ]
                                  MOV R3, M[ R3 ]

                                  CMP R3, FIM_STRING
                                  JMP.Z Mov_fim_jogo

                                  MOV M[ IO_WRITE ], R3

                                  INC M[ Indice ]
                                  INC R2

                                  JMP Cursor_imprime_jogo

Mov_fim_jogo:                     MOV M[ IO_WRITE ], R3



Halt:           BR		Halt



; ./p3as-linux pacman.as
; java -jar p3sim.jar pacman.exe
