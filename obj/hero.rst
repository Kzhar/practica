ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _CODE
                              2 
                              3 ;=======================================================
                              4 ;=======================================================
                              5 ;PRIVATE DATA
                              6 ;======================================================
                              7 ;======================================================
                              8 ;declaracion de variables
   4049 27                    9 hero_x: 	.db 	#39		;;define byte
   404A 50                   10 hero_y:		.db 	#80
                             11 
   404B FF                   12 hero_jump:	.db 	#-1	;variable de control del array de salto de Hero
                             13 ;jump Table
   404C                      14 jumpTable:
   404C FD FE FF FF          15 	.db #-3, #-2, #-1, #-1
   4050 FF 00 00 00          16 	.db #-1, #00, #00, #00
   4054 01 02 02 03          17 	.db #01, #02, #02, #03
   4058 80                   18 	.db #0x80 		;byte que marca el final de la tabla de salto 1000 0000
                             19 
                             20 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                             21 ;cpctelera symbols
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             22 .include "keyboard/keyboard.s"
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
   4059                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             23 .include "cpctelera.h.s"
                              1 ;=======================================
                              2 ;=======================================
                              3 ;OBSTACLE PUBLIC FUNCTIONS
                              4 ;=======================================
                              5 ;=======================================
                              6 
                              7 .globl cpct_drawSolidBox_asm
                              8 .globl cpct_getScreenPtr_asm
                              9 .globl cpct_scanKeyboard_asm
                             10 .globl cpct_isKeyPressed_asm
                             11 .globl cpct_waitVSYNC_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             24 ;=======================================================
                             25 ;=======================================================
                             26 ;PUBLIC FUNCTIONS
                             27 ;======================================================
                             28 ;======================================================
                             29 
                             30 ;============================================
                             31 ;ERASES THE HERO
                             32 ;DESTROYS: 
                             33 ;============================================
   4063                      34 hero_erase::
   4063 3E 00         [ 7]   35 	ld a, #0x00
   4065 CD ED 40      [17]   36 	call drawhero 		;call drawhero function :)
                             37 
   4068 C9            [10]   38 	ret
                             39 
                             40 ;============================================
                             41 ;DRAW THE HERO 
                             42 ;DESTROYS: 
                             43 ;============================================
   4069                      44 hero_draw::
   4069 3E FF         [ 7]   45 	ld a, #0xFF
   406B CD ED 40      [17]   46 	call drawhero 		;call drawhero function :)
                             47 
   406E C9            [10]   48 	ret
                             49 
                             50 ;============================================
                             51 ;UPDATES THE HERO
                             52 ;DESTROYS: 
                             53 ;============================================
   406F                      54 hero_update::
   406F CD 76 40      [17]   55 	call jumpControl	;llamamos a la funcion que controla el salto del personaje 
   4072 CD C2 40      [17]   56 	call checkUserInput	;check if user pressed keys
                             57 
   4075 C9            [10]   58 	ret
                             59 
                             60 ;=======================================================
                             61 ;=======================================================
                             62 ;PRIVATE FUNCTIONS
                             63 ;======================================================
                             64 ;======================================================
                             65 
                             66 ;============================================
                             67 ;Controls Jump Movements
                             68 ;DESTROYS: 
                             69 ;============================================
   4076                      70 jumpControl:
   4076 3A 4B 40      [13]   71 	ld a, (hero_jump)	;comprovamos el estado de la variable de estado
   4079 FE FF         [ 7]   72 	cp #-1			;comparamos con -1 -> no estoy saltando
   407B C8            [11]   73 	ret z			;si la variable de estado es -1, no esta saltando, por lo tanto sale de la funcion
                             74 
                             75 	;Get jump value
   407C 21 4C 40      [10]   76 	ld hl, #jumpTable	;HL Point to the first element of the Jump Table
   407F 4F            [ 4]   77 	ld c, a			;
   4080 06 00         [ 7]   78 	ld b, #0		;
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



   4082 09            [11]   79 	add hl, bc 		;HL += A -> point to the element of the array 
                             80 
                             81 	;check end of jumping
   4083 7E            [ 7]   82 	ld a, (hl)		;HL ahora es el puntero a la tabla mas el offset que está en hero_jump 
   4084 FE 80         [ 7]   83 	cp #0x80		;si el contenido de esa direccion de memoria es 0x80 es que hemos llegado al final de la tabla
   4086 28 10         [12]   84 	jr z, end_of_jump	;
                             85 
                             86 	;do jump Movement
   4088 47            [ 4]   87 	ld b, a			;B= Jump Movement = Movement in Y	
   4089 3A 4A 40      [13]   88 	ld a, (hero_y)		;A= Y position
   408C 80            [ 4]   89 	add b			;A+= B -> Add jump movement 
   408D 32 4A 40      [13]   90 	ld (hero_y), a		;Update hero_y Value
                             91 
                             92 	;Increment hero_jump Index
   4090 3A 4B 40      [13]   93 	ld a, (hero_jump)	
   4093 3C            [ 4]   94 	inc a			;
   4094 32 4B 40      [13]   95 	ld (hero_jump), a	;Hero_jump ++
                             96 
   4097 C9            [10]   97 	ret 
                             98 
                             99 	;poner el indice hero_jump a -1 lo que quiere decir que el salto no se esta ejecutando
   4098                     100 	end_of_jump:		;si se ha detectado el final del salto
   4098 3E FF         [ 7]  101 		ld a, #-1
   409A 32 4B 40      [13]  102 		ld (hero_jump), a
   409D C9            [10]  103 	ret
                            104 
                            105 ;============================================
                            106 ;move Hero Right if is not at the screen limit
                            107 ;DESTROYS: AF
                            108 ;============================================
                            109 
   409E                     110 moveHeroRight:
   409E 3A 49 40      [13]  111 	ld a, (hero_x)
   40A1 FE 4E         [ 7]  112 	cp #80-2 	;comprovamos que no se sale por la derecha (80 bytes pantalla- 2 anchura Hero)
   40A3 28 04         [12]  113 	jr z, not_move_right
   40A5 3C            [ 4]  114 		inc a		;si no se sale de la pantalla se mueve
   40A6 32 49 40      [13]  115 		ld (hero_x), a
                            116 
   40A9                     117 	not_move_right:
                            118 
   40A9 C9            [10]  119 	ret
                            120 
                            121 ;============================================
                            122 ;move Hero Left if is not at the screen limit
                            123 ;DESTROYS: AF
                            124 ;============================================
   40AA                     125 moveHeroLeft:
   40AA 3A 49 40      [13]  126 	ld a, (hero_x)
   40AD FE 00         [ 7]  127 	cp #0 	;comprovamos que no se sale por la izquierda (X=0)
   40AF 28 04         [12]  128 	jr z, not_move_left
   40B1 3D            [ 4]  129 		dec a		;si no se sale de la pantalla se mueve
   40B2 32 49 40      [13]  130 		ld (hero_x), a
                            131 
   40B5                     132 	not_move_left:
                            133 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   40B5 C9            [10]  134 	ret
                            135 
                            136 ;============================================
                            137 ;Start Hero Jump
                            138 ;DESTROYS: AF
                            139 ;============================================
   40B6                     140 startJump:
   40B6 3A 4B 40      [13]  141 	ld a, (hero_jump)	;A=indice de la tabla de salto
   40B9 FE FF         [ 7]  142 	cp #-1			;Si no es -1 el salto ya esta activo
   40BB C0            [11]  143 	ret nz			;salimos de la rutina sin hacer nada si el salto esta ya activo
                            144 	;Jump is not active, activate it
   40BC 3E 00         [ 7]  145 	ld a, #0
   40BE 32 4B 40      [13]  146 	ld (hero_jump), a	;activo el salto metiendo en a un 0 -> primer indice de la tabla
                            147 
   40C1 C9            [10]  148 	ret
                            149 
                            150 ;============================================
                            151 ;CHECK USER INPUT AND REACTS
                            152 ;DESTROYS: 
                            153 ;============================================
   40C2                     154 checkUserInput:
                            155 	;/////////////////////////SE PODRÍA GUARDAR EN UN BYTE DE MEMORIA PARA NO HACER TANTOS CÁLCULOS
                            156 	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
                            157 	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
                            158 	;scan whole keyboard
   40C2 CD E2 41      [17]  159 	call cpct_scanKeyboard_asm
                            160 
                            161 	;Checks if a concrete key is pressed or not.
                            162 	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
                            163 	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
                            164 	;check if d is pressed
   40C5 21 07 20      [10]  165 	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
                            166 	;************************************************************
                            167 	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
   40C8 CD 05 41      [17]  168 	call cpct_isKeyPressed_asm 
   40CB FE 00         [ 7]  169 	cp #0	;compara lo que hay en el acumuldor
                            170 		;Cero si no se ha presionado
   40CD 28 03         [12]  171 	jr z, d_not_pressed
                            172 
   40CF CD 9E 40      [17]  173 		call moveHeroRight	;si la tecla se ha pulsado llamamos a la rutina moveHeroRight
                            174 
   40D2                     175 	d_not_pressed:
                            176 
                            177 	;Ahora comprobamos si se ha pulado A
   40D2 21 08 20      [10]  178 	ld hl, #Key_A	
   40D5 CD 05 41      [17]  179 	call cpct_isKeyPressed_asm 
   40D8 FE 00         [ 7]  180 	cp #0	;compara lo que hay en el acumuldor
                            181 		;Cero si no se ha presionado
   40DA 28 03         [12]  182 	jr z, a_not_pressed
                            183 
   40DC CD AA 40      [17]  184 		call moveHeroLeft	;si la tecla se ha pulsado llamamos a la rutina moveHeroLeft
                            185 
   40DF                     186 	a_not_pressed:
                            187 
   40DF 21 07 08      [10]  188 	ld hl, #Key_W
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



   40E2 CD 05 41      [17]  189 	call cpct_isKeyPressed_asm
   40E5 FE 00         [ 7]  190 	cp #0
   40E7 28 03         [12]  191 	jr z, w_not_pressed
                            192 
   40E9 CD B6 40      [17]  193 		call startJump		;si se ha pulsado W
                            194 
   40EC                     195 	w_not_pressed:
                            196 
   40EC C9            [10]  197 ret	;a dibujar Hero en la nueva posicion
                            198 
                            199 ;============================================
                            200 ;DRAW THE HERO
                            201 ;INPUTS A=> Colour pattern 
                            202 ;DESTROYS: AF, BC, DE, HL
                            203 ;============================================
   40ED                     204 drawhero:
   40ED F5            [11]  205 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                            206 	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
                            207 	;Input Parameters (4 Bytes)
                            208 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                            209 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                            210 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
                            211 
                            212 	;Return Value(HL)
                            213 	;calculate screen position
   40EE 11 00 C0      [10]  214 	ld de, #0xC000		;video memoy pointer
   40F1 3A 49 40      [13]  215 	ld a, (hero_x)		;|
   40F4 4F            [ 4]  216 	ld c, a			;| C=hero_x
   40F5 3A 4A 40      [13]  217 	ld a, (hero_y)		;|
   40F8 47            [ 4]  218 	ld b, a			;| B=hero_y
                            219 
   40F9 CD C6 41      [17]  220 	call cpct_getScreenPtr_asm
                            221 
                            222 
                            223 	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
                            224 	;Input Parameters (5 bytes)
                            225 	;(2B DE) memory	Video memory pointer to the upper left box corner byte
                            226 	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
                            227 	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
                            228 	;(1B B ) height	Box height in bytes (>0)
                            229 
                            230 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                            231 	;habra que pasar hl a de 
   40FC EB            [ 4]  232 	ex de, hl 	;intercambia hl y de 
   40FD F1            [10]  233 	pop af 		;color elegido por el usuario
                            234 	;ld a, #0x0F	;cyan
   40FE 01 02 08      [10]  235 	ld bc, #0x0802	;alto por ancho en pixeles 8x8
   4101 CD 19 41      [17]  236 	call cpct_drawSolidBox_asm
                            237 
   4104 C9            [10]  238 ret
                            239 
