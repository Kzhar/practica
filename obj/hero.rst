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
   4082 27                    9 hero_x: 	.db 	#39		;|
   4083 50                   10 hero_y:		.db 	#80		;|hero position 
   4084 02                   11 hero_w:		.db     #2		;|
   4085 08                   12 hero_h:		.db 	#8		;|hero widht and height in bytes
                             13 
   4086 FF                   14 hero_jump:	.db 	#-1	;variable de control del array de salto de Hero
                             15 
                             16 ;jump Table
   4087                      17 jumpTable:
   4087 FD FE FF FF          18 	.db #-3, #-2, #-1, #-1
   408B FF 00 00 00          19 	.db #-1, #00, #00, #00
   408F 01 02 02 03          20 	.db #01, #02, #02, #03
   4093 80                   21 	.db #0x80 		;byte que marca el final de la tabla de salto 1000 0000
                             22 
                             23 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                             24 ;cpctelera symbols
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             25 .include "keyboard/keyboard.s"
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
   4094                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             26 .include "cpctelera.h.s"
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



                             27 ;=======================================================
                             28 ;=======================================================
                             29 ;PUBLIC FUNCTIONS
                             30 ;======================================================
                             31 ;======================================================
                             32 
                             33 ;============================================
                             34 ;ERASES THE HERO
                             35 ;DESTROYS: 
                             36 ;============================================
   409E                      37 hero_erase::
   409E 3E 00         [ 7]   38 	ld a, #0x00
   40A0 CD 2C 41      [17]   39 	call drawhero 		;call drawhero function :)
                             40 
   40A3 C9            [10]   41 	ret
                             42 
                             43 ;============================================
                             44 ;DRAW THE HERO 
                             45 ;DESTROYS: 
                             46 ;============================================
   40A4                      47 hero_draw::
   40A4 3E FF         [ 7]   48 	ld a, #0xFF
   40A6 CD 2C 41      [17]   49 	call drawhero 		;call drawhero function :)
                             50 
   40A9 C9            [10]   51 	ret
                             52 
                             53 ;============================================
                             54 ;UPDATES THE HERO
                             55 ;DESTROYS: 
                             56 ;============================================
   40AA                      57 hero_update::
   40AA CD B5 40      [17]   58 	call jumpControl	;llamamos a la funcion que controla el salto del personaje 
   40AD CD 01 41      [17]   59 	call checkUserInput	;check if user pressed keys
                             60 
   40B0 C9            [10]   61 	ret
                             62 
                             63 ;============================================
                             64 ;GETS A POINTER TO HERO DATA IN HL
                             65 ;DESTROYS: HL
                             66 ;RETURNS: Pointer to HERO DATA
                             67 ;============================================
   40B1                      68 hero_getPtrHL::
   40B1 21 82 40      [10]   69 	ld hl, #hero_x	;hl points to the fisrt data of hero (hero_x, hero_y, hero_w, hero_h)
   40B4 C9            [10]   70 	ret
                             71 
                             72 ;=======================================================
                             73 ;=======================================================
                             74 ;PRIVATE FUNCTIONS
                             75 ;======================================================
                             76 ;======================================================
                             77 
                             78 ;============================================
                             79 ;Controls Jump Movements
                             80 ;DESTROYS: 
                             81 ;============================================
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



   40B5                      82 jumpControl:
   40B5 3A 86 40      [13]   83 	ld a, (hero_jump)	;comprovamos el estado de la variable de estado
   40B8 FE FF         [ 7]   84 	cp #-1			;comparamos con -1 -> no estoy saltando
   40BA C8            [11]   85 	ret z			;si la variable de estado es -1, no esta saltando, por lo tanto sale de la funcion
                             86 
                             87 	;Get jump value
   40BB 21 87 40      [10]   88 	ld hl, #jumpTable	;HL Point to the first element of the Jump Table
   40BE 4F            [ 4]   89 	ld c, a			;
   40BF 06 00         [ 7]   90 	ld b, #0		;
   40C1 09            [11]   91 	add hl, bc 		;HL += A -> point to the element of the array 
                             92 
                             93 	;check end of jumping
   40C2 7E            [ 7]   94 	ld a, (hl)		;HL ahora es el puntero a la tabla mas el offset que está en hero_jump 
   40C3 FE 80         [ 7]   95 	cp #0x80		;si el contenido de esa direccion de memoria es 0x80 es que hemos llegado al final de la tabla
   40C5 28 10         [12]   96 	jr z, end_of_jump	;
                             97 
                             98 	;do jump Movement
   40C7 47            [ 4]   99 	ld b, a			;B= Jump Movement = Movement in Y	
   40C8 3A 83 40      [13]  100 	ld a, (hero_y)		;A= Y position
   40CB 80            [ 4]  101 	add b			;A+= B -> Add jump movement 
   40CC 32 83 40      [13]  102 	ld (hero_y), a		;Update hero_y Value
                            103 
                            104 	;Increment hero_jump Index
   40CF 3A 86 40      [13]  105 	ld a, (hero_jump)	
   40D2 3C            [ 4]  106 	inc a			;
   40D3 32 86 40      [13]  107 	ld (hero_jump), a	;Hero_jump ++
                            108 
   40D6 C9            [10]  109 	ret 
                            110 
                            111 	;poner el indice hero_jump a -1 lo que quiere decir que el salto no se esta ejecutando
   40D7                     112 	end_of_jump:		;si se ha detectado el final del salto
   40D7 3E FF         [ 7]  113 		ld a, #-1
   40D9 32 86 40      [13]  114 		ld (hero_jump), a
   40DC C9            [10]  115 	ret
                            116 
                            117 ;============================================
                            118 ;move Hero Right if is not at the screen limit
                            119 ;DESTROYS: AF
                            120 ;============================================
                            121 
   40DD                     122 moveHeroRight:
   40DD 3A 82 40      [13]  123 	ld a, (hero_x)
   40E0 FE 4E         [ 7]  124 	cp #80-2 	;comprovamos que no se sale por la derecha (80 bytes pantalla- 2 anchura Hero)
   40E2 28 04         [12]  125 	jr z, not_move_right
   40E4 3C            [ 4]  126 		inc a		;si no se sale de la pantalla se mueve
   40E5 32 82 40      [13]  127 		ld (hero_x), a
                            128 
   40E8                     129 	not_move_right:
                            130 
   40E8 C9            [10]  131 	ret
                            132 
                            133 ;============================================
                            134 ;move Hero Left if is not at the screen limit
                            135 ;DESTROYS: AF
                            136 ;============================================
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   40E9                     137 moveHeroLeft:
   40E9 3A 82 40      [13]  138 	ld a, (hero_x)
   40EC FE 00         [ 7]  139 	cp #0 	;comprovamos que no se sale por la izquierda (X=0)
   40EE 28 04         [12]  140 	jr z, not_move_left
   40F0 3D            [ 4]  141 		dec a		;si no se sale de la pantalla se mueve
   40F1 32 82 40      [13]  142 		ld (hero_x), a
                            143 
   40F4                     144 	not_move_left:
                            145 
   40F4 C9            [10]  146 	ret
                            147 
                            148 ;============================================
                            149 ;Start Hero Jump
                            150 ;DESTROYS: AF
                            151 ;============================================
   40F5                     152 startJump:
   40F5 3A 86 40      [13]  153 	ld a, (hero_jump)	;A=indice de la tabla de salto
   40F8 FE FF         [ 7]  154 	cp #-1			;Si no es -1 el salto ya esta activo
   40FA C0            [11]  155 	ret nz			;salimos de la rutina sin hacer nada si el salto esta ya activo
                            156 	;Jump is not active, activate it
   40FB 3E 00         [ 7]  157 	ld a, #0
   40FD 32 86 40      [13]  158 	ld (hero_jump), a	;activo el salto metiendo en a un 0 -> primer indice de la tabla
                            159 
   4100 C9            [10]  160 	ret
                            161 
                            162 ;============================================
                            163 ;CHECK USER INPUT AND REACTS
                            164 ;DESTROYS: 
                            165 ;============================================
   4101                     166 checkUserInput:
                            167 	;/////////////////////////SE PODRÍA GUARDAR EN UN BYTE DE MEMORIA PARA NO HACER TANTOS CÁLCULOS
                            168 	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
                            169 	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
                            170 	;scan whole keyboard
   4101 CD 21 42      [17]  171 	call cpct_scanKeyboard_asm
                            172 
                            173 	;Checks if a concrete key is pressed or not.
                            174 	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
                            175 	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
                            176 	;check if d is pressed
   4104 21 07 20      [10]  177 	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
                            178 	;************************************************************
                            179 	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
   4107 CD 44 41      [17]  180 	call cpct_isKeyPressed_asm 
   410A FE 00         [ 7]  181 	cp #0	;compara lo que hay en el acumuldor
                            182 		;Cero si no se ha presionado
   410C 28 03         [12]  183 	jr z, d_not_pressed
                            184 
   410E CD DD 40      [17]  185 		call moveHeroRight	;si la tecla se ha pulsado llamamos a la rutina moveHeroRight
                            186 
   4111                     187 	d_not_pressed:
                            188 
                            189 	;Ahora comprobamos si se ha pulado A
   4111 21 08 20      [10]  190 	ld hl, #Key_A	
   4114 CD 44 41      [17]  191 	call cpct_isKeyPressed_asm 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



   4117 FE 00         [ 7]  192 	cp #0	;compara lo que hay en el acumuldor
                            193 		;Cero si no se ha presionado
   4119 28 03         [12]  194 	jr z, a_not_pressed
                            195 
   411B CD E9 40      [17]  196 		call moveHeroLeft	;si la tecla se ha pulsado llamamos a la rutina moveHeroLeft
                            197 
   411E                     198 	a_not_pressed:
                            199 
   411E 21 07 08      [10]  200 	ld hl, #Key_W
   4121 CD 44 41      [17]  201 	call cpct_isKeyPressed_asm
   4124 FE 00         [ 7]  202 	cp #0
   4126 28 03         [12]  203 	jr z, w_not_pressed
                            204 
   4128 CD F5 40      [17]  205 		call startJump		;si se ha pulsado W
                            206 
   412B                     207 	w_not_pressed:
                            208 
   412B C9            [10]  209 ret	;a dibujar Hero en la nueva posicion
                            210 
                            211 ;============================================
                            212 ;DRAW THE HERO
                            213 ;INPUTS A=> Colour pattern 
                            214 ;DESTROYS: AF, BC, DE, HL
                            215 ;============================================
   412C                     216 drawhero:
   412C F5            [11]  217 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                            218 	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
                            219 	;Input Parameters (4 Bytes)
                            220 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                            221 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                            222 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
                            223 
                            224 	;Return Value(HL)
                            225 	;calculate screen position
   412D 11 00 C0      [10]  226 	ld de, #0xC000		;video memoy pointer
   4130 3A 82 40      [13]  227 	ld a, (hero_x)		;|
   4133 4F            [ 4]  228 	ld c, a			;| C=hero_x
   4134 3A 83 40      [13]  229 	ld a, (hero_y)		;|
   4137 47            [ 4]  230 	ld b, a			;| B=hero_y
                            231 
   4138 CD 05 42      [17]  232 	call cpct_getScreenPtr_asm
                            233 
                            234 
                            235 	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
                            236 	;Input Parameters (5 bytes)
                            237 	;(2B DE) memory	Video memory pointer to the upper left box corner byte
                            238 	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
                            239 	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
                            240 	;(1B B ) height	Box height in bytes (>0)
                            241 
                            242 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                            243 	;habra que pasar hl a de 
   413B EB            [ 4]  244 	ex de, hl 	;intercambia hl y de 
   413C F1            [10]  245 	pop af 		;color elegido por el usuario
                            246 	;ld a, #0x0F	;cyan
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



   413D 01 02 08      [10]  247 	ld bc, #0x0802	;alto por ancho en pixeles 8x8
   4140 CD 58 41      [17]  248 	call cpct_drawSolidBox_asm
                            249 
   4143 C9            [10]  250 ret
                            251 
