ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 
                              3 ;declaracion de variables
   4270 27                    4 hero_x: .db  #39		;define byte
   4271 50                    5 hero_y:	.db  #80
                              6 
   4272 FF                    7 jump_pointer: .db #-1		;pointer to the jump_Table
                              8 
   4273                       9 jump_Table:
   4273 FD FD FE FE FF       10 	.db #-3, #-3, #-2, #-2, #-1	;Jump Up
   4278 00 00                11 	.db #00, #00			;Jump Stand
   427A 01 02 02 03 03       12 	.db #01, #02, #02, #03, #03	;Jump down
   427F 27                   13 	.db #0x127			;Jump end label			
                             14 ;declaracion de sprites
   4280                      15 groundTile01:
   4280 F0 F0                16 	.db #0xF0, #0xF0
   4282 F0 F0                17 	.db #0xF0, #0xF0
   4284 A5 A5                18 	.db #0xA5, #0xA5
   4286 5A 5A                19 	.db #0x5A, #0x5A
   4288 0F 0F                20 	.db #0x0F, #0x0F
   428A 05 05                21 	.db #0x05, #0x05
   428C 0A 0A                22 	.db #0x0A, #0x0A
                             23 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                             24 ;cpctelera symbols
                             25 .globl cpct_drawSolidBox_asm
                             26 .globl cpct_getScreenPtr_asm
                             27 .globl cpct_scanKeyboard_asm
                             28 .globl cpct_isKeyPressed_asm
                             29 .globl cpct_waitVSYNC_asm
                             30 .globl cpct_drawSprite_asm
                             31 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             32 .include "keyboard/keyboard.s"
                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 ;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
                              3 ;;  Copyright (C) 2014 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
                              4 ;;
                              5 ;;  This program is free software: you can redistribute it and/or modify
                              6 ;;  it under the terms of the GNU Lesser General Public License as published by
                              7 ;;  the Free Software Foundation, either version 3 of the License, or
                              8 ;;  (at your option) any later version.
                              9 ;;
                             10 ;;  This program is distributed in the hope that it will be useful,
                             11 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                             12 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             13 ;;  GNU Lesser General Public License for more details.
                             14 ;;
                             15 ;;  You should have received a copy of the GNU Lesser General Public License
                             16 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             17 ;;-------------------------------------------------------------------------------
                             18 .module cpct_keyboard
                             19 
                             20 ;; bndry directive does not work when linking previously compiled files
                             21 ;.bndry 16
                             22 ;;   16-byte aligned in memory to let functions use 8-bit maths for pointing
                             23 ;;   (alignment not working on user linking)
                             24 
   428E                      25 _cpct_keyboardStatusBuffer:: .ds 10
                             26 
                             27 ;;
                             28 ;; Assembly constant definitions for keyboard mapping
                             29 ;;
                             30 
                             31 ;; Matrix Line 0x00
                     0100    32 .equ Key_CursorUp     ,#0x0100  ;; Bit 0 (01h) => | 0000 0001 |
                     0200    33 .equ Key_CursorRight  ,#0x0200  ;; Bit 1 (02h) => | 0000 0010 |
                     0400    34 .equ Key_CursorDown   ,#0x0400  ;; Bit 2 (04h) => | 0000 0100 |
                     0800    35 .equ Key_F9           ,#0x0800  ;; Bit 3 (08h) => | 0000 1000 |
                     1000    36 .equ Key_F6           ,#0x1000  ;; Bit 4 (10h) => | 0001 0000 |
                     2000    37 .equ Key_F3           ,#0x2000  ;; Bit 5 (20h) => | 0010 0000 |
                     4000    38 .equ Key_Enter        ,#0x4000  ;; Bit 6 (40h) => | 0100 0000 |
                     8000    39 .equ Key_FDot         ,#0x8000  ;; Bit 7 (80h) => | 1000 0000 |
                             40 ;; Matrix Line 0x01
                     0101    41 .equ Key_CursorLeft   ,#0x0101
                     0201    42 .equ Key_Copy         ,#0x0201
                     0401    43 .equ Key_F7           ,#0x0401
                     0801    44 .equ Key_F8           ,#0x0801
                     1001    45 .equ Key_F5           ,#0x1001
                     2001    46 .equ Key_F1           ,#0x2001
                     4001    47 .equ Key_F2           ,#0x4001
                     8001    48 .equ Key_F0           ,#0x8001
                             49 ;; Matrix Line 0x02
                     0102    50 .equ Key_Clr          ,#0x0102
                     0202    51 .equ Key_OpenBracket  ,#0x0202
                     0402    52 .equ Key_Return       ,#0x0402
                     0802    53 .equ Key_CloseBracket ,#0x0802
                     1002    54 .equ Key_F4           ,#0x1002
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                     2002    55 .equ Key_Shift        ,#0x2002
                     4002    56 .equ Key_BackSlash    ,#0x4002
                     8002    57 .equ Key_Control      ,#0x8002
                             58 ;; Matrix Line 0x03
                     0103    59 .equ Key_Caret        ,#0x0103
                     0203    60 .equ Key_Hyphen       ,#0x0203
                     0403    61 .equ Key_At           ,#0x0403
                     0803    62 .equ Key_P            ,#0x0803
                     1003    63 .equ Key_SemiColon    ,#0x1003
                     2003    64 .equ Key_Colon        ,#0x2003
                     4003    65 .equ Key_Slash        ,#0x4003
                     8003    66 .equ Key_Dot          ,#0x8003
                             67 ;; Matrix Line 0x04
                     0104    68 .equ Key_0            ,#0x0104
                     0204    69 .equ Key_9            ,#0x0204
                     0404    70 .equ Key_O            ,#0x0404
                     0804    71 .equ Key_I            ,#0x0804
                     1004    72 .equ Key_L            ,#0x1004
                     2004    73 .equ Key_K            ,#0x2004
                     4004    74 .equ Key_M            ,#0x4004
                     8004    75 .equ Key_Comma        ,#0x8004
                             76 ;; Matrix Line 0x05
                     0105    77 .equ Key_8            ,#0x0105
                     0205    78 .equ Key_7            ,#0x0205
                     0405    79 .equ Key_U            ,#0x0405
                     0805    80 .equ Key_Y            ,#0x0805
                     1005    81 .equ Key_H            ,#0x1005
                     2005    82 .equ Key_J            ,#0x2005
                     4005    83 .equ Key_N            ,#0x4005
                     8005    84 .equ Key_Space        ,#0x8005
                             85 ;; Matrix Line 0x06
                     0106    86 .equ Key_6            ,#0x0106
                     0106    87 .equ Joy1_Up          ,#0x0106
                     0206    88 .equ Key_5            ,#0x0206
                     0206    89 .equ Joy1_Down        ,#0x0206
                     0406    90 .equ Key_R            ,#0x0406
                     0406    91 .equ Joy1_Left        ,#0x0406
                     0806    92 .equ Key_T            ,#0x0806
                     0806    93 .equ Joy1_Right       ,#0x0806
                     1006    94 .equ Key_G            ,#0x1006
                     1006    95 .equ Joy1_Fire1       ,#0x1006
                     2006    96 .equ Key_F            ,#0x2006
                     2006    97 .equ Joy1_Fire2       ,#0x2006
                     4006    98 .equ Key_B            ,#0x4006
                     4006    99 .equ Joy1_Fire3       ,#0x4006
                     8006   100 .equ Key_V            ,#0x8006
                            101 ;; Matrix Line 0x07
                     0107   102 .equ Key_4            ,#0x0107
                     0207   103 .equ Key_3            ,#0x0207
                     0407   104 .equ Key_E            ,#0x0407
                     0807   105 .equ Key_W            ,#0x0807
                     1007   106 .equ Key_S            ,#0x1007
                     2007   107 .equ Key_D            ,#0x2007
                     4007   108 .equ Key_C            ,#0x4007
                     8007   109 .equ Key_X            ,#0x8007
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                            110 ;; Matrix Line 0x08
                     0108   111 .equ Key_1            ,#0x0108
                     0208   112 .equ Key_2            ,#0x0208
                     0408   113 .equ Key_Esc          ,#0x0408
                     0808   114 .equ Key_Q            ,#0x0808
                     1008   115 .equ Key_Tab          ,#0x1008
                     2008   116 .equ Key_A            ,#0x2008
                     4008   117 .equ Key_CapsLock     ,#0x4008
                     8008   118 .equ Key_Z            ,#0x8008
                            119 ;; Matrix Line 0x09
                     0109   120 .equ Joy0_Up          ,#0x0109
                     0209   121 .equ Joy0_Down        ,#0x0209
                     0409   122 .equ Joy0_Left        ,#0x0409
                     0809   123 .equ Joy0_Right       ,#0x0809
                     1009   124 .equ Joy0_Fire1       ,#0x1009
                     2009   125 .equ Joy0_Fire2       ,#0x2009
                     4009   126 .equ Joy0_Fire3       ,#0x4009
                     8009   127 .equ Key_Del          ,#0x8009
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                             33 
                             34 ;Declaración de constantes
                     0002    35 BoxWidth = 2 
                             36 
                             37 .area _CODE
                             38 ;============================================
                             39 ;Move Right to the limit of the screen
                             40 ;DESTROYS: AF
                             41 ;============================================
   4000                      42 heroMoveRight:
   4000 3A 70 42      [13]   43 		ld a, (hero_x)		;Cargamos la posición actual de Hero en el acumulador
   4003 3C            [ 4]   44 		inc a			;Incrementamos el valor de hero_x
   4004 FE 4D         [ 7]   45 		cp #79-BoxWidth		;Comparamos con la posición máxima en pantalla para X menos la anchura del recuadro
   4006 C8            [11]   46 		ret z			;si se ha alcanzado la posición máxima se sale de la rutina sin hacer nada mas
                             47 
   4007 32 70 42      [13]   48 		ld (hero_x), a		;si no, se actualiza la posición en la variable hero_x
   400A C9            [10]   49 	ret
                             50 ;============================================
                             51 ;Move Left to the limit of the screen
                             52 ;DESTROYS: AF
                             53 ;============================================
   400B                      54 heroMoveLeft:
   400B 3A 70 42      [13]   55 		ld a, (hero_x)		;Cargamos la posición actual de Hero en el acumulador
   400E 3D            [ 4]   56 		dec a			;Decrementamos el valor de hero_x en uno
   400F FE FF         [ 7]   57 		cp #0xFF		;Si la posición de hero_x (de su parte superior izquierda) es -1 salimos de la rutina sin hacer nada mas 
   4011 C8            [11]   58 		ret z	
                             59 
   4012 32 70 42      [13]   60 		ld (hero_x), a		;si no, se actualiza la posición en la variable hero_x
   4015 C9            [10]   61 	ret
                             62 
                             63 ;============================================
                             64 ;When is active, Do the Hero Jump
                             65 ;DESTROYS: AF BC HL
                             66 ;============================================
   4016                      67 heroJump:
   4016 3A 72 42      [13]   68 	ld a, (jump_pointer)	;Load jump_pointer in the accumulator
   4019 FE FF         [ 7]   69 	cp #-1			;Compare with -1 
   401B C8            [11]   70 	ret z			;If jump_pointer is setting in -1 routine ends
                             71 		;if not
   401C 21 73 42      [10]   72 		ld hl, #jump_Table	;Hl point to the first element of the jump_Table
   401F 4F            [ 4]   73 		ld c, a	
   4020 06 00         [ 7]   74 		ld b, #00
   4022 09            [11]   75 		add hl, bc		;HL now stores the Y movemnt of jump's memory position 
                             76 
   4023 7E            [ 7]   77 		ld a, (hl)		;Load jump_Table,s Y movemnt in the accumulator
   4024 FE 27         [ 7]   78 		cp #0x127		;compare with ending jump's label
   4026 28 10         [12]   79 		jr z, jumping_end	;jum is end, set jump_pointer to -1
                             80 
                             81 			;if not -> now a stores correspondent y movemnt of the jump
   4028 47            [ 4]   82 			ld b, a		;
   4029 3A 71 42      [13]   83 			ld a, (hero_y)	;
   402C 80            [ 4]   84 			add b		;
   402D 32 71 42      [13]   85 			ld (hero_y), a	;update new hero_y position
                             86 
   4030 3A 72 42      [13]   87 			ld a, (jump_pointer)	;
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



   4033 3C            [ 4]   88 			inc a			;
   4034 32 72 42      [13]   89 			ld (jump_pointer), a	;update jump_pointer to the next position 
                             90 
                             91 
   4037 C9            [10]   92 	ret
                             93 
   4038                      94 	jumping_end:			;jum is end, set jump_pointer to -1
   4038 3E FF         [ 7]   95 		ld a, #-1
   403A 32 72 42      [13]   96 		ld (jump_pointer), a	;set jump_pointer to -1
   403D C9            [10]   97 		ret
                             98 
                             99 ;============================================
                            100 ;CHECK USER INPUT AND REACTS
                            101 ;DESTROYS: 
                            102 ;============================================
   403E                     103 checkUserInput:
                            104 
   403E CD 3F 42      [17]  105 	call cpct_scanKeyboard_asm	;CPCTelera routine that scans whole keyboard
                            106 
   4041 21 07 20      [10]  107 	ld hl, #Key_D			;Input for cpct_isKeyPressed_asm // constant #Key_D include in keyboard/keyboard.s
   4044 CD C2 40      [17]  108 	call cpct_isKeyPressed_asm 	;Outputs in A & L = 0 if not pressed or 0> if not pressed
   4047 FE 00         [ 7]  109 	cp #0
   4049 28 03         [12]  110 	jr z, d_not_pressed		;jump to d_not_pressed
                            111 
   404B CD 00 40      [17]  112 		call heroMoveRight	;if K is pressed call heroMoveRight
                            113 	
   404E                     114 	d_not_pressed:
                            115 
                            116 	; se repite para la letra A #key_A 
   404E 21 08 20      [10]  117 	ld hl, #Key_A	;Constante incluida en keyboard.s
   4051 CD C2 40      [17]  118 	call cpct_isKeyPressed_asm
   4054 FE 00         [ 7]  119 	cp #0 	;si es cero no se ha presionado
   4056 28 03         [12]  120 	jr z, a_not_pressed
   4058 CD 0B 40      [17]  121 		call heroMoveLeft
                            122 
   405B                     123 	a_not_pressed:
                            124 
   405B 21 07 08      [10]  125 	ld hl, #Key_W	;Constante incluida en keyboard.s
   405E CD C2 40      [17]  126 	call cpct_isKeyPressed_asm
   4061 FE 00         [ 7]  127 	cp #0 				;if the accumulator is 0 the key is not pressed
   4063 28 0B         [12]  128 	jr z, w_not_pressed
   4065 3A 72 42      [13]  129 		ld a, (jump_pointer)
   4068 FE FF         [ 7]  130 		cp #-1
   406A 20 04         [12]  131 		jr nz, jump_is_taking_place	;if jump_pointer stores a number different os -1 the jump is taking place
                            132 			;if not we can activate the jump setting jump_pointer to 0
   406C 3C            [ 4]  133 			inc a
   406D 32 72 42      [13]  134 			ld (jump_pointer), a
                            135 
   4070                     136 		jump_is_taking_place:
   4070                     137 	w_not_pressed:
   4070 C9            [10]  138 ret	;a dibujar Hero en la nueva posicion
                            139 
                            140 ;============================================
                            141 ;DRAW THE HERO
                            142 ;INPUTS A=> Colour pattern 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                            143 ;DESTROYS: AF, BC, DE, HL
                            144 ;============================================
   4071                     145 drawhero:
   4071 F5            [11]  146 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                            147 	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
                            148 	;Input Parameters (4 Bytes)
                            149 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                            150 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                            151 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
                            152 
                            153 	;Return Value(HL)
                            154 	;calculate screen position
   4072 11 00 C0      [10]  155 	ld de, #0xC000		;video memoy pointer
   4075 3A 70 42      [13]  156 	ld a, (hero_x)		;|
   4078 4F            [ 4]  157 	ld c, a			;| C=hero_x
   4079 3A 71 42      [13]  158 	ld a, (hero_y)		;|
   407C 47            [ 4]  159 	ld b, a			;| B=hero_y
                            160 
   407D CD 23 42      [17]  161 	call cpct_getScreenPtr_asm
                            162 
                            163 
                            164 	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
                            165 	;Input Parameters (5 bytes)
                            166 	;(2B DE) memory	Video memory pointer to the upper left box corner byte
                            167 	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
                            168 	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
                            169 	;(1B B ) height	Box height in bytes (>0)
                            170 
                            171 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                            172 	;habra que pasar hl a de 
   4080 EB            [ 4]  173 	ex de, hl 	;intercambia hl y de 
   4081 F1            [10]  174 	pop af 		;color elegido por el usuario
                            175 	;ld a, #0x0F	;cyan
   4082 01 02 08      [10]  176 	ld bc, #0x0802	;alto por ancho en pixeles 8x8
   4085 CD 76 41      [17]  177 	call cpct_drawSolidBox_asm
                            178 
   4088 C9            [10]  179 ret
                            180 
   4089                     181 drawGround:
                            182 	;Input Parameters (4 Bytes)
                            183 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                            184 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                            185 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
   4089 0E 00         [ 7]  186 	ld c, #0x00	;y pasarla a la función cpct_drawSprite_asm primera X=0 Y=posición del cuadrado +8
   408B                     187 	groundBucle:
   408B 11 00 C0      [10]  188 	ld de, #0xC000	;Parametros de la funcion cpct_getScreenPtr_asm para calcular la posición de memoria de video
   408E C5            [11]  189 	push bc
   408F 06 58         [ 7]  190 	ld b, #88
   4091 CD 23 42      [17]  191 	call cpct_getScreenPtr_asm
                            192 	;el resutado -> la posicion de memoria esta ahora en Hl y habra que pasarla a DE
                            193 
   4094 EB            [ 4]  194 	ex de, hl
   4095 21 80 42      [10]  195 	ld hl, #groundTile01	;Source Sprite Pointer (array with pixel data)
   4098 0E 02         [ 7]  196 	ld c, #0x02		;C ) width Sprite Width in bytes [1-63] (Beware, not in pixels!)
   409A 06 08         [ 7]  197 	ld b, #0x08		;B ) height Sprite Height in bytes (>0)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                            198 	;Input Parameters (6 bytes)
                            199 	;2B HL) sprite	Source Sprite Pointer (array with pixel data)
                            200 	;2B DE) memory	Destination video memory pointer
                            201 	;1B C ) width	Sprite Width in bytes [1-63] (Beware, not in pixels!)
                            202 	;1B B ) height	Sprite Height in bytes (>0)	
   409C CD CE 40      [17]  203 	call cpct_drawSprite_asm
                            204 
   409F C1            [10]  205 	pop bc 
   40A0 79            [ 4]  206 	ld a, c 
   40A1 C6 02         [ 7]  207 	add #0x02
   40A3 4F            [ 4]  208 	ld c, a 
   40A4 FE 4E         [ 7]  209 	cp #78
   40A6 C2 8B 40      [10]  210 	jp nz, groundBucle
                            211 
                            212 
                            213 
   40A9 C9            [10]  214 ret
                            215 
                            216 ;============================================
                            217 ;MAIN PROGRAM ENTRY
                            218 ;============================================
   40AA                     219 _main::
   40AA CD 89 40      [17]  220 	call drawGround
                            221 
   40AD                     222 	gameLoop:
   40AD 3E 00         [ 7]  223 	ld a, #0x00		;delete hero -> background color
   40AF CD 71 40      [17]  224 	call drawhero 		;call drawhero function :)
                            225 
   40B2 CD 16 40      [17]  226 	call heroJump		;If hero is jumpling update Y position
   40B5 CD 3E 40      [17]  227 	call checkUserInput	;check if user pressed keys
   40B8 3E FF         [ 7]  228 	ld a, #0xFF		;select Box color of Hero
   40BA CD 71 40      [17]  229 	call drawhero 		;call drawhero function :)
                            230 
   40BD CD 6E 41      [17]  231 	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.
                            232 
   40C0 18 EB         [12]  233 	jr gameLoop
