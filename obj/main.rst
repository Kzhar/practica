ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 
                              3 ;declaracion de variables
   414D 27                    4 hero_x: .db  #39		;;define byte
   414E 50                    5 hero_y:	.db  #80
                              6 ;declaracion de sprites
                              7 
                              8 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                              9 ;cpctelera symbols
                             10 .globl cpct_drawSolidBox_asm
                             11 .globl cpct_getScreenPtr_asm
                             12 .globl cpct_scanKeyboard_asm
                             13 .globl cpct_isKeyPressed_asm
                             14 .globl cpct_waitVSYNC_asm
                             15 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             16 .include "keyboard/keyboard.s"
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
   414F                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             17 
                             18 ;Declaración de constantes
                             19 
                             20 
                             21 .area _CODE
                             22 
                             23 ;============================================
                             24 ;CHECK USER INPUT AND REACTS
                             25 ;DESTROYS: 
                             26 ;============================================
   4000                      27 checkUserInput:
                             28 	;/////////////////////////SE PODRÍA GUARDAR EN UN BYTE DE MEMORIA PARA NO HACER TANTOS CÁLCULOS
                             29 	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
                             30 	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
                             31 	;scan whole keyboard
   4000 CD 1C 41      [17]   32 	call cpct_scanKeyboard_asm
                             33 	;Checks if a concrete key is pressed or not.
                             34 	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
                             35 	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
                             36 
                             37 	;check if d is pressed
   4003 21 07 20      [10]   38 	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
                             39 	;************************************************************
                             40 	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
   4006 CD 3F 40      [17]   41 	call cpct_isKeyPressed_asm 
   4009 FE 00         [ 7]   42 	cp #0	;compara lo que hay en el acumuldor
                             43 		;Cero si no se ha presionado
   400B 28 07         [12]   44 	jr z, d_not_pressed
                             45 
   400D 3A 4D 41      [13]   46 		ld a, (hero_x)
   4010 3C            [ 4]   47 		inc a
   4011 32 4D 41      [13]   48 		ld (hero_x), a
                             49 	
                             50 
                             51 
   4014                      52 	d_not_pressed:
                             53 
   4014 C9            [10]   54 ret	;a dibujar Hero en la nueva posicion
                             55 
                             56 ;============================================
                             57 ;DRAW THE HERO
                             58 ;INPUTS A=> Colour pattern 
                             59 ;DESTROYS: AF, BC, DE, HL
                             60 ;============================================
   4015                      61 drawhero:
   4015 F5            [11]   62 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                             63 	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
                             64 	;Input Parameters (4 Bytes)
                             65 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                             66 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                             67 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
                             68 
                             69 	;Return Value(HL)
                             70 	;calculate screen position
   4016 11 00 C0      [10]   71 	ld de, #0xC000		;video memoy pointer
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



   4019 3A 4D 41      [13]   72 	ld a, (hero_x)		;|
   401C 4F            [ 4]   73 	ld c, a			;| C=hero_x
   401D 3A 4E 41      [13]   74 	ld a, (hero_y)		;|
   4020 47            [ 4]   75 	ld b, a			;| B=hero_y
                             76 
   4021 CD 00 41      [17]   77 	call cpct_getScreenPtr_asm
                             78 
                             79 
                             80 	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
                             81 	;Input Parameters (5 bytes)
                             82 	;(2B DE) memory	Video memory pointer to the upper left box corner byte
                             83 	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
                             84 	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
                             85 	;(1B B ) height	Box height in bytes (>0)
                             86 
                             87 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                             88 	;habra que pasar hl a de 
   4024 EB            [ 4]   89 	ex de, hl 	;intercambia hl y de 
   4025 F1            [10]   90 	pop af 		;color elegido por el usuario
                             91 	;ld a, #0x0F	;cyan
   4026 01 02 08      [10]   92 	ld bc, #0x0802	;alto por ancho en pixeles 8x8
   4029 CD 53 40      [17]   93 	call cpct_drawSolidBox_asm
                             94 
   402C C9            [10]   95 ret
                             96 
                             97 
                             98 ;============================================
                             99 ;MAIN PROGRAM ENTRY
                            100 ;============================================
   402D                     101 _main::
                            102 
   402D 3E 00         [ 7]  103 	ld a, #0x00
   402F CD 15 40      [17]  104 	call drawhero 		;call drawhero function :)
                            105 
   4032 CD 00 40      [17]  106 	call checkUserInput	;check if user pressed keys
                            107 
   4035 3E FF         [ 7]  108 	ld a, #0xFF
   4037 CD 15 40      [17]  109 	call drawhero 		;call drawhero function :)
                            110 
   403A CD 4B 40      [17]  111 	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.
                            112 
   403D 18 EE         [12]  113 	jr _main
