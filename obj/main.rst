ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 
                              3 ;declaracion de variables
   416E 27                    4 hero_x: .db  #39		;;define byte
   416F 50                    5 hero_y:	.db  #80
                              6 ;Se declaran aqui las funciones de cpctelera que se van a utilizar 
                              7 ;cpctelera symbols
                              8 .globl cpct_drawSolidBox_asm
                              9 .globl cpct_getScreenPtr_asm
                             10 .globl cpct_scanKeyboard_asm
                             11 .globl cpct_isKeyPressed_asm
                             12 .globl cpct_waitVSYNC_asm
                             13 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             14 .include "keyboard/keyboard.s"
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
   4170                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             15 
                             16 .area _CODE
                             17 
                             18 ;============================================
                             19 ;CHECK USER INPUT AND REACTS
                             20 ;DESTROYS: 
                             21 ;============================================
   4000                      22 checkUserInput:
   4000 C5            [11]   23 	push bc
                             24 	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
                             25 	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
                             26 	;scan whole keyboard
   4001 CD 3D 41      [17]   27 	call cpct_scanKeyboard_asm
                             28 	;Checks if a concrete key is pressed or not.
                             29 	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
                             30 	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
                             31 
                             32 	;check if d is pressed
   4004 21 07 20      [10]   33 	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
                             34 	;************************************************************
                             35 	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
   4007 CD 60 40      [17]   36 	call cpct_isKeyPressed_asm 
   400A C1            [10]   37 	pop bc
   400B FE 00         [ 7]   38 	cp #0	;compara lo que hay en el acumuldor
                             39 		;Cero si no se ha presionado
   400D 28 0E         [12]   40 	jr z, d_not_pressed
                             41 
   400F 3A 6E 41      [13]   42 		ld a, (hero_x)
   4012 3C            [ 4]   43 		inc a
   4013 81            [ 4]   44 		add a, c 	;al final de drawhero popeamos bc para ulizar la anchura guardada en b en esta rutina
   4014 FE 4F         [ 7]   45 		cp #79		;maximo número de bytes en modo 0 (de 0 a 79)
   4016 D2 1D 40      [10]   46 		jp nc, d_not_pressed
   4019 91            [ 4]   47 		sub a, c
   401A 32 6E 41      [13]   48 		ld (hero_x), a
                             49 	
                             50 
                             51 
   401D                      52 	d_not_pressed:
                             53 	; se repite para la letra A #key_A 
   401D 21 08 20      [10]   54 	ld hl, #Key_A	;Constante incluida en keyboard.s
   4020 CD 60 40      [17]   55 	call cpct_isKeyPressed_asm
   4023 FE 00         [ 7]   56 	cp #0 	;si es cero no se ha presionado
   4025 28 0C         [12]   57 	jr z, a_not_pressed
   4027 3A 6E 41      [13]   58 		ld a, (hero_x)
   402A 3D            [ 4]   59 		dec a
   402B FE FF         [ 7]   60 		cp #0xFF
   402D CA 33 40      [10]   61 		jp z, a_not_pressed	;si es menor que 0 hay acarreo por lo tanto hero_x se queda ne la misma posicion
                             62 					;no actualizamos 
                             63 
   4030 32 6E 41      [13]   64 		ld (hero_x), a
                             65 
   4033                      66 	a_not_pressed:
   4033 C9            [10]   67 ret	;a dibujar Hero en la nueva posicion
                             68 
                             69 ;============================================
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             70 ;DRAW THE HERO
                             71 ;INPUTS A=> Colour pattern 
                             72 ;DESTROYS: AF, BC, DE, HL
                             73 ;============================================
   4034                      74 drawhero:
   4034 F5            [11]   75 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                             76 	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
                             77 	;Input Parameters (4 Bytes)
                             78 	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
                             79 	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
                             80 	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
                             81 
                             82 	;Return Value(HL)
                             83 	;calculate screen position
   4035 11 00 C0      [10]   84 	ld de, #0xC000		;video memoy pointer
   4038 3A 6E 41      [13]   85 	ld a, (hero_x)		;|
   403B 4F            [ 4]   86 	ld c, a			;| C=hero_x
   403C 3A 6F 41      [13]   87 	ld a, (hero_y)		;|
   403F 47            [ 4]   88 	ld b, a			;| B=hero_y
                             89 
   4040 CD 21 41      [17]   90 	call cpct_getScreenPtr_asm
                             91 
                             92 
                             93 	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
                             94 	;Input Parameters (5 bytes)
                             95 	;(2B DE) memory	Video memory pointer to the upper left box corner byte
                             96 	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
                             97 	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
                             98 	;(1B B ) height	Box height in bytes (>0)
                             99 
                            100 	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
                            101 	;habra que pasar hl a de 
   4043 EB            [ 4]  102 	ex de, hl 	;intercambia hl y de 
   4044 F1            [10]  103 	pop af 		;color elegido por el usuario
                            104 	;ld a, #0x0F	;cyan
   4045 01 02 08      [10]  105 	ld bc, #0x0802	;alto por ancho en pixeles 8x8
   4048 C5            [11]  106 	push bc
   4049 CD 74 40      [17]  107 	call cpct_drawSolidBox_asm
   404C C1            [10]  108 	pop bc
                            109 
   404D C9            [10]  110 ret
                            111 
                            112 ;============================================
                            113 ;MAIN PROGRAM ENTRY
                            114 ;============================================
   404E                     115 _main::
   404E 3E 00         [ 7]  116 	ld a, #0x00
   4050 CD 34 40      [17]  117 	call drawhero 		;call drawhero function :)
                            118 
   4053 CD 00 40      [17]  119 	call checkUserInput	;check if user pressed keys
                            120 
   4056 3E FF         [ 7]  121 	ld a, #0xFF
   4058 CD 34 40      [17]  122 	call drawhero 		;call drawhero function :)
                            123 
   405B CD 6C 40      [17]  124 	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                            125 
   405E 18 EE         [12]  126 	jr _main
