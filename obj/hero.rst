ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _CODE
                              2 
                              3 ;=======================================================
                              4 ;=======================================================
                              5 ;PRIVATE DATA
                              6 ;======================================================
                              7 ;======================================================
                              8 ;declaración de constantes
                     0000     9 .equ Ent_x, 0
                     0001    10 .equ Ent_y, 1
                     0002    11 .equ Ent_w, 2
                     0003    12 .equ Ent_h, 3
                     0004    13 .equ Ent_jump, 4
                     0005    14 .equ Ent_sptr01, 5
                             15 ;declaración de macro
                             16 .macro defineEntity name, x, y, w, h, spr 	;define a macro to create entities
                             17 	name'_data:
                             18 		name'_x: 		.db 	x		;|
                             19 		name'_y:		.db 	y		;|hero position 
                             20 		name'_w:		.db     w		;|
                             21 		name'_h:		.db 	h		;|hero widht and height in bytes
                             22 		name'_jump:		.db 	#-1	;variable de control del array de salto de Hero
                             23 		name'_sprt01:		.dw 	spr
                             24 .endm	;end of the macro
                             25 
   4082                      26 defineEntity hero, #39, #80, #2, #8, #hero_sprite01	;define hero as in the next coment lines
   0000                       1 	hero_data:
   4082 27                    2 		hero_x: 		.db 	#39		;|
   4083 50                    3 		hero_y:		.db 	#80		;|hero position 
   4084 02                    4 		hero_w:		.db     #2		;|
   4085 08                    5 		hero_h:		.db 	#8		;|hero widht and height in bytes
   4086 FF                    6 		hero_jump:		.db 	#-1	;variable de control del array de salto de Hero
   4087 51 41                 7 		hero_sprt01:		.dw 	#hero_sprite01
                             27 ;hero_data:
                             28 ;	hero_x: 	.db 	#39		;|
                             29 ;	hero_y:		.db 	#80		;|hero position 
                             30 ;	hero_w:		.db     #2		;|
                             31 ;	hero_h:		.db 	#8		;|hero widht and height in bytes
                             32 ;	hero_jump:	.db 	#-1	;variable de control del array de salto de Hero
                             33 ;	hero_sprt01:	.dw 	#hero_sprite01
                             34 
                             35 ;jump Table
   4089                      36 jumpTable:
   4089 FD FE FF FF          37 	.db #-3, #-2, #-1, #-1
   408D FF 00 00 00          38 	.db #-1, #00, #00, #00
   4091 01 02 02 03          39 	.db #01, #02, #02, #03
   4095 80                   40 	.db #0x80 		;byte que marca el final de la tabla de salto 1000 0000
                             41 
                             42 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                             43 ;cpctelera symbols
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             44 .include "keyboard/keyboard.s"
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
   4096                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             45 .include "cpctelera.h.s"
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
                             12 .globl cpct_drawSprite_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             46 ;SPRITE DATA
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                             47 .include "sprite.h.s"
                              1 ;=======================================
                              2 ;=======================================
                              3 ;SPRITE PUBLIC DATA
                              4 ;=======================================
                              5 ;=======================================
                              6 .globl hero_sprite01
                              7 .globl delete_sprite
                              8 .globl hero_sprite02
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                             48 ;=======================================================
                             49 ;=======================================================
                             50 ;PUBLIC FUNCTIONS
                             51 ;======================================================
                             52 ;======================================================
                             53 
                             54 ;============================================
                             55 ;ERASES THE HERO
                             56 ;DESTROYS: 
                             57 ;============================================
   40A0                      58 hero_erase::
                             59 	;ld a, #0x00
   40A0 21 71 41      [10]   60 	ld hl, #delete_sprite
   40A3 DD 21 82 40   [14]   61 	ld ix, #hero_data	;pointer to th entity to draw
   40A7 CD 38 41      [17]   62 	call drawhero 		;call drawhero function :)
                             63 
   40AA C9            [10]   64 	ret
                             65 
                             66 ;============================================
                             67 ;DRAW THE HERO 
                             68 ;DESTROYS: 
                             69 ;============================================
   40AB                      70 hero_draw::
                             71 	;ld a, #0xFF
   40AB 2A 87 40      [16]   72 	ld hl, (hero_sprt01)
   40AE DD 21 82 40   [14]   73 	ld ix, #hero_data	;pointer to th entity to draw
   40B2 CD 38 41      [17]   74 	call drawhero 		;call drawhero function :)
                             75 
   40B5 C9            [10]   76 	ret
                             77 
                             78 ;============================================
                             79 ;UPDATES THE HERO
                             80 ;DESTROYS: 
                             81 ;============================================
   40B6                      82 hero_update::
   40B6 CD C1 40      [17]   83 	call jumpControl	;llamamos a la funcion que controla el salto del personaje 
   40B9 CD 0D 41      [17]   84 	call checkUserInput	;check if user pressed keys
                             85 
   40BC C9            [10]   86 	ret
                             87 
                             88 ;============================================
                             89 ;GETS A POINTER TO HERO DATA IN HL
                             90 ;DESTROYS: HL
                             91 ;RETURNS: Pointer to HERO DATA
                             92 ;============================================
   40BD                      93 hero_getPtrHL::
   40BD 21 82 40      [10]   94 	ld hl, #hero_x	;hl points to the fisrt data of hero (hero_x, hero_y, hero_w, hero_h)
   40C0 C9            [10]   95 	ret
                             96 
                             97 ;=======================================================
                             98 ;=======================================================
                             99 ;PRIVATE FUNCTIONS
                            100 ;======================================================
                            101 ;======================================================
                            102 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



                            103 ;============================================
                            104 ;Controls Jump Movements
                            105 ;DESTROYS: 
                            106 ;============================================
   40C1                     107 jumpControl:
   40C1 3A 86 40      [13]  108 	ld a, (hero_jump)	;comprovamos el estado de la variable de estado
   40C4 FE FF         [ 7]  109 	cp #-1			;comparamos con -1 -> no estoy saltando
   40C6 C8            [11]  110 	ret z			;si la variable de estado es -1, no esta saltando, por lo tanto sale de la funcion
                            111 
                            112 	;Get jump value
   40C7 21 89 40      [10]  113 	ld hl, #jumpTable	;HL Point to the first element of the Jump Table
   40CA 4F            [ 4]  114 	ld c, a			;
   40CB 06 00         [ 7]  115 	ld b, #0		;
   40CD 09            [11]  116 	add hl, bc 		;HL += A -> point to the element of the array 
                            117 
                            118 	;check end of jumping
   40CE 7E            [ 7]  119 	ld a, (hl)		;HL ahora es el puntero a la tabla mas el offset que está en hero_jump 
   40CF FE 80         [ 7]  120 	cp #0x80		;si el contenido de esa direccion de memoria es 0x80 es que hemos llegado al final de la tabla
   40D1 28 10         [12]  121 	jr z, end_of_jump	;
                            122 
                            123 	;do jump Movement
   40D3 47            [ 4]  124 	ld b, a			;B= Jump Movement = Movement in Y	
   40D4 3A 83 40      [13]  125 	ld a, (hero_y)		;A= Y position
   40D7 80            [ 4]  126 	add b			;A+= B -> Add jump movement 
   40D8 32 83 40      [13]  127 	ld (hero_y), a		;Update hero_y Value
                            128 
                            129 	;Increment hero_jump Index
   40DB 3A 86 40      [13]  130 	ld a, (hero_jump)	
   40DE 3C            [ 4]  131 	inc a			;
   40DF 32 86 40      [13]  132 	ld (hero_jump), a	;Hero_jump ++
                            133 
   40E2 C9            [10]  134 	ret 
                            135 
                            136 	;poner el indice hero_jump a -1 lo que quiere decir que el salto no se esta ejecutando
   40E3                     137 	end_of_jump:		;si se ha detectado el final del salto
   40E3 3E FF         [ 7]  138 		ld a, #-1
   40E5 32 86 40      [13]  139 		ld (hero_jump), a
   40E8 C9            [10]  140 	ret
                            141 
                            142 ;============================================
                            143 ;move Hero Right if is not at the screen limit
                            144 ;DESTROYS: AF
                            145 ;============================================
                            146 
   40E9                     147 moveHeroRight:
   40E9 3A 82 40      [13]  148 	ld a, (hero_x)
   40EC FE 4E         [ 7]  149 	cp #80-2 	;comprovamos que no se sale por la derecha (80 bytes pantalla- 2 anchura Hero)
   40EE 28 04         [12]  150 	jr z, not_move_right
   40F0 3C            [ 4]  151 		inc a		;si no se sale de la pantalla se mueve
   40F1 32 82 40      [13]  152 		ld (hero_x), a
                            153 
   40F4                     154 	not_move_right:
                            155 
   40F4 C9            [10]  156 	ret
                            157 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



                            158 ;============================================
                            159 ;move Hero Left if is not at the screen limit
                            160 ;DESTROYS: AF
                            161 ;============================================
   40F5                     162 moveHeroLeft:
   40F5 3A 82 40      [13]  163 	ld a, (hero_x)
   40F8 FE 00         [ 7]  164 	cp #0 	;comprovamos que no se sale por la izquierda (X=0)
   40FA 28 04         [12]  165 	jr z, not_move_left
   40FC 3D            [ 4]  166 		dec a		;si no se sale de la pantalla se mueve
   40FD 32 82 40      [13]  167 		ld (hero_x), a
                            168 
   4100                     169 	not_move_left:
                            170 
   4100 C9            [10]  171 	ret
                            172 
                            173 ;============================================
                            174 ;Start Hero Jump
                            175 ;DESTROYS: AF
                            176 ;============================================
   4101                     177 startJump:
   4101 3A 86 40      [13]  178 	ld a, (hero_jump)	;A=indice de la tabla de salto
   4104 FE FF         [ 7]  179 	cp #-1			;Si no es -1 el salto ya esta activo
   4106 C0            [11]  180 	ret nz			;salimos de la rutina sin hacer nada si el salto esta ya activo
                            181 	;Jump is not active, activate it
   4107 3E 00         [ 7]  182 	ld a, #0
   4109 32 86 40      [13]  183 	ld (hero_jump), a	;activo el salto metiendo en a un 0 -> primer indice de la tabla
                            184 
   410C C9            [10]  185 	ret
                            186 
                            187 ;============================================
                            188 ;CHECK USER INPUT AND REACTS
                            189 ;DESTROYS: 
                            190 ;============================================
   410D                     191 checkUserInput:
                            192 	;/////////////////////////SE PODRÍA GUARDAR EN UN BYTE DE MEMORIA PARA NO HACER TANTOS CÁLCULOS
                            193 	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
                            194 	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
                            195 	;scan whole keyboard
   410D CD FE 42      [17]  196 	call cpct_scanKeyboard_asm
                            197 
                            198 	;Checks if a concrete key is pressed or not.
                            199 	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
                            200 	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
                            201 	;check if d is pressed
   4110 21 07 20      [10]  202 	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
                            203 	;************************************************************
                            204 	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
   4113 CD 81 41      [17]  205 	call cpct_isKeyPressed_asm 
   4116 FE 00         [ 7]  206 	cp #0	;compara lo que hay en el acumuldor
                            207 		;Cero si no se ha presionado
   4118 28 03         [12]  208 	jr z, d_not_pressed
                            209 
   411A CD E9 40      [17]  210 		call moveHeroRight	;si la tecla se ha pulsado llamamos a la rutina moveHeroRight
                            211 
   411D                     212 	d_not_pressed:
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



                            213 
                            214 	;Ahora comprobamos si se ha pulado A
   411D 21 08 20      [10]  215 	ld hl, #Key_A	
   4120 CD 81 41      [17]  216 	call cpct_isKeyPressed_asm 
   4123 FE 00         [ 7]  217 	cp #0	;compara lo que hay en el acumuldor
                            218 		;Cero si no se ha presionado
   4125 28 03         [12]  219 	jr z, a_not_pressed
                            220 
   4127 CD F5 40      [17]  221 		call moveHeroLeft	;si la tecla se ha pulsado llamamos a la rutina moveHeroLeft
                            222 
   412A                     223 	a_not_pressed:
                            224 
   412A 21 07 08      [10]  225 	ld hl, #Key_W
   412D CD 81 41      [17]  226 	call cpct_isKeyPressed_asm
   4130 FE 00         [ 7]  227 	cp #0
   4132 28 03         [12]  228 	jr z, w_not_pressed
                            229 
   4134 CD 01 41      [17]  230 		call startJump		;si se ha pulsado W
                            231 
   4137                     232 	w_not_pressed:
                            233 
   4137 C9            [10]  234 ret	;a dibujar Hero en la nueva posicion
                            235 
                            236 ;============================================
                            237 ;DRAWS ANYTHING
                            238 ;INPUTS 
                            239 ;	A  => Colour pattern 
                            240 ;	IX => Pointer to entity data (0 = X, 1 = Y, 2 = Width, 3 = Height) 
                            241 ;DESTROYS: AF, BC, DE, HL
                            242 ;============================================
   4138                     243 drawhero:
                            244 	;push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
   4138 E5            [11]  245 	push hl
                            246 	;Return Value(HL)
                            247 	;calculate screen position
   4139 11 00 C0      [10]  248 	ld de, #0xC000		;video memoy pointer
   413C DD 4E 00      [19]  249 	ld c, Ent_x(ix)		;| C=Entity_x
   413F DD 46 01      [19]  250 	ld b, Ent_y(ix)		;| B=Entity_y
                            251 
   4142 CD E2 42      [17]  252 	call cpct_getScreenPtr_asm
                            253 
                            254 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                            255 	;habra que pasar hl a de 
   4145 EB            [ 4]  256 	ex de, hl 		;intercambia hl y de 
   4146 DD 4E 02      [19]  257 	ld c, Ent_w(ix)		;C=Entity_w (width)
   4149 DD 46 03      [19]  258 	ld b, Ent_h(ix)		;B=Entity_h (height)
                            259 	;pop af 
   414C E1            [10]  260 	pop hl			;color elegido por el usuario
                            261 	;call cpct_drawSolidBox_asm
   414D CD 8D 41      [17]  262 	call cpct_drawSprite_asm
                            263 
   4150 C9            [10]  264 ret
                            265 
