ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 
                              3 ;declaracion de variables
   4178 27                    4 hero_x: .db 	#39		;;define byte
   4179 50                    5 hero_y:	.db 	#80
                              6 
   417A FF                    7 hero_jump:	.db #-1	;variable de control del array de salto de Hero
                              8 ;declaracion de sprites
                              9 
                             10 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                             11 ;cpctelera symbols
                             12 .globl cpct_drawSolidBox_asm
                             13 .globl cpct_getScreenPtr_asm
                             14 .globl cpct_scanKeyboard_asm
                             15 .globl cpct_isKeyPressed_asm
                             16 .globl cpct_waitVSYNC_asm
                             17 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             18 .include "keyboard/keyboard.s"
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
   417B                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             19 
                             20 ;Declaración de constantes
                             21 
                             22 
                             23 .area _CODE
                             24 ;============================================
                             25 ;Controls Jump Movements
                             26 ;DESTROYS: 
                             27 ;============================================
   4000                      28 jumpControl:
   4000 3A 7A 41      [13]   29 	ld a, (hero_jump)	;comprovamos el estado de la variable de estado
   4003 FE FF         [ 7]   30 	cp #-1			;comparamos con -1 -> no estoy saltando
   4005 C8            [11]   31 	ret z			;si la variable de estado es -1, no esta saltando, por lo tanto sale de la funcion
                             32 
   4006 C9            [10]   33 	ret 
                             34 
                             35 ;============================================
                             36 ;move Hero Right if is not at the screen limit
                             37 ;DESTROYS: AF
                             38 ;============================================
                             39 
   4007                      40 moveHeroRight:
   4007 3A 78 41      [13]   41 	ld a, (hero_x)
   400A FE 4E         [ 7]   42 	cp #80-2 	;comprovamos que no se sale por la derecha (80 bytes pantalla- 2 anchura Hero)
   400C 28 04         [12]   43 	jr z, not_move_right
   400E 3C            [ 4]   44 		inc a		;si no se sale de la pantalla se mueve
   400F 32 78 41      [13]   45 		ld (hero_x), a
                             46 
   4012                      47 	not_move_right:
                             48 
   4012 C9            [10]   49 	ret
                             50 
                             51 ;============================================
                             52 ;move Hero Left if is not at the screen limit
                             53 ;DESTROYS: AF
                             54 ;============================================
   4013                      55 moveHeroLeft:
   4013 3A 78 41      [13]   56 	ld a, (hero_x)
   4016 FE 00         [ 7]   57 	cp #0 	;comprovamos que no se sale por la izquierda (X=0)
   4018 28 04         [12]   58 	jr z, not_move_left
   401A 3D            [ 4]   59 		dec a		;si no se sale de la pantalla se mueve
   401B 32 78 41      [13]   60 		ld (hero_x), a
                             61 
   401E                      62 	not_move_left:
                             63 
   401E C9            [10]   64 	ret
                             65 
                             66 ;============================================
                             67 ;CHECK USER INPUT AND REACTS
                             68 ;DESTROYS: 
                             69 ;============================================
   401F                      70 checkUserInput:
                             71 	;/////////////////////////SE PODRÍA GUARDAR EN UN BYTE DE MEMORIA PARA NO HACER TANTOS CÁLCULOS
                             72 	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
                             73 	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             74 	;scan whole keyboard
   401F CD 47 41      [17]   75 	call cpct_scanKeyboard_asm
                             76 
                             77 	;Checks if a concrete key is pressed or not.
                             78 	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
                             79 	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
                             80 	;check if d is pressed
   4022 21 07 20      [10]   81 	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
                             82 	;************************************************************
                             83 	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
   4025 CD 6A 40      [17]   84 	call cpct_isKeyPressed_asm 
   4028 FE 00         [ 7]   85 	cp #0	;compara lo que hay en el acumuldor
                             86 		;Cero si no se ha presionado
   402A 28 03         [12]   87 	jr z, d_not_pressed
                             88 
   402C CD 07 40      [17]   89 		call moveHeroRight	;si la tecla se ha pulsado llamamos a la rutina moveHeroRight
                             90 
   402F                      91 	d_not_pressed:
                             92 
                             93 	;Ahora comprobamos si se ha pulado A
   402F 21 08 20      [10]   94 	ld hl, #Key_A	
   4032 CD 6A 40      [17]   95 	call cpct_isKeyPressed_asm 
   4035 FE 00         [ 7]   96 	cp #0	;compara lo que hay en el acumuldor
                             97 		;Cero si no se ha presionado
   4037 28 03         [12]   98 	jr z, a_not_pressed
                             99 
   4039 CD 13 40      [17]  100 		call moveHeroLeft	;si la tecla se ha pulsado llamamos a la rutina moveHeroLeft
                            101 
   403C                     102 	a_not_pressed:
                            103 
   403C C9            [10]  104 ret	;a dibujar Hero en la nueva posicion
                            105 
                            106 ;============================================
                            107 ;DRAW THE HERO
                            108 ;INPUTS A=> Colour pattern 
                            109 ;DESTROYS: AF, BC, DE, HL
                            110 ;============================================
   403D                     111 drawhero:
   403D F5            [11]  112 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                            113 	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
                            114 	;Input Parameters (4 Bytes)
                            115 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                            116 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                            117 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
                            118 
                            119 	;Return Value(HL)
                            120 	;calculate screen position
   403E 11 00 C0      [10]  121 	ld de, #0xC000		;video memoy pointer
   4041 3A 78 41      [13]  122 	ld a, (hero_x)		;|
   4044 4F            [ 4]  123 	ld c, a			;| C=hero_x
   4045 3A 79 41      [13]  124 	ld a, (hero_y)		;|
   4048 47            [ 4]  125 	ld b, a			;| B=hero_y
                            126 
   4049 CD 2B 41      [17]  127 	call cpct_getScreenPtr_asm
                            128 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                            129 
                            130 	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
                            131 	;Input Parameters (5 bytes)
                            132 	;(2B DE) memory	Video memory pointer to the upper left box corner byte
                            133 	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
                            134 	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
                            135 	;(1B B ) height	Box height in bytes (>0)
                            136 
                            137 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                            138 	;habra que pasar hl a de 
   404C EB            [ 4]  139 	ex de, hl 	;intercambia hl y de 
   404D F1            [10]  140 	pop af 		;color elegido por el usuario
                            141 	;ld a, #0x0F	;cyan
   404E 01 02 08      [10]  142 	ld bc, #0x0802	;alto por ancho en pixeles 8x8
   4051 CD 7E 40      [17]  143 	call cpct_drawSolidBox_asm
                            144 
   4054 C9            [10]  145 ret
                            146 
                            147 
                            148 ;============================================
                            149 ;MAIN PROGRAM ENTRY
                            150 ;============================================
   4055                     151 _main::
                            152 
   4055 3E 00         [ 7]  153 	ld a, #0x00
   4057 CD 3D 40      [17]  154 	call drawhero 		;call drawhero function :)
                            155 
   405A CD 00 40      [17]  156 	call jumpControl	;llamamos a la funcion que controla el salto del personaje 
   405D CD 1F 40      [17]  157 	call checkUserInput	;check if user pressed keys
                            158 
   4060 3E FF         [ 7]  159 	ld a, #0xFF
   4062 CD 3D 40      [17]  160 	call drawhero 		;call drawhero function :)
                            161 
   4065 CD 76 40      [17]  162 	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.
                            163 
   4068 18 EB         [12]  164 	jr _main
