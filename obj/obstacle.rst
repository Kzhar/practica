ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _CODE
                              2 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              3 .include "cpctelera.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                              4 ;=======================================================
                              5 ;=======================================================
                              6 ;PRIVATE DATA
                              7 ;======================================================
                              8 ;======================================================
   4000 4F                    9 obs_x: .db #80-1	;posicion x del obstaculo (al final de la pantalla)
   4001 52                   10 obs_y: .db #82		;posicióny del obstaculo
   4002 01                   11 obs_w: .db #1		;ancho del obstaculo en bytes
   4003 04                   12 obs_h: .db #4		;alto del obstaculo en bytes
                             13 
                             14 ;=======================================================
                             15 ;=======================================================
                             16 ;PUBLIC FUNCTIONS
                             17 ;======================================================
                             18 ;======================================================
                             19 
                             20 ;============================================
                             21 ;ERASES THE OBSTACLE
                             22 ;DESTROYS: 
                             23 ;============================================
   4004                      24 obstacle_erase::
   4004 3E 00         [ 7]   25 	ld a, #0x00			;background color
   4006 CD 41 40      [17]   26 	call drawObstacle 		;call drawObstacle function :)
                             27 
   4009 C9            [10]   28 	ret
                             29 
                             30 ;============================================
                             31 ;DRAW THE OBSTACLE 
                             32 ;DESTROYS: 
                             33 ;============================================
   400A                      34 obstacle_draw::
   400A 3E F0         [ 7]   35 	ld a, #0xF0			;cyan
   400C CD 41 40      [17]   36 	call drawObstacle 		;call drawObstacle function :)
                             37 
   400F C9            [10]   38 	ret
                             39 
                             40 ;============================================
                             41 ;UPDATES THE OBSTACLE
                             42 ;DESTROYS: 
                             43 ;============================================
   4010                      44 obstacle_update::
                             45 	;Move obstacle to the left
   4010 3A 00 40      [13]   46 	ld a, (obs_x)
   4013 3D            [ 4]   47 	dec a
   4014 20 02         [12]   48 	jr nz, not_restart_x	;dec a también activa los flags, por lo tanto mientras no sea cero no se resetea su posición
                             49 
   4016 3E 4F         [ 7]   50 		ld a, #80-1	;start location
                             51 
   4018                      52 	not_restart_x:
   4018 32 00 40      [13]   53 	ld (obs_x), a		;update obs_x position
                             54 
   401B C9            [10]   55 	ret
                             56 
                             57 ;============================================
                             58 ;CHECK COLISION BETWEEN OBSTACLE AND ANOTHER ENTITY
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                             59 ;INPUT:
                             60 ;	HL: POINTS TO THE OTHER ENTITY 
                             61 ;RETURN;XXXXXX
                             62 ;DESTROYS: 
                             63 ;============================================
   401C                      64 obstacle_checkCollion::
                             65 	;if (obs_x + obs_w <= hero_x) no_collision
                             66 	;obs_x + obs_w - hero_x <= 0
   401C 3A 00 40      [13]   67 	ld a, (obs_x)		;|	
   401F 4F            [ 4]   68 	ld c, a			;|
   4020 3A 02 40      [13]   69 	ld a, (obs_w)		;|
   4023 81            [ 4]   70 	add c 			;|obs_x + obs_w
                             71 				
   4024 96            [ 7]   72 	sub (hl)		;hl points to other entity data in this order(first-> hero_x, second-> hero_y, 
                             73 				;third-> hero_w, forurh-> hero_h)	
   4025 28 16         [12]   74 	jr z, no_collision	;if is equal to zero, there´s no collision
   4027 FA 3D 40      [10]   75 	jp m, no_collision	;if is negative (minus) there´s no collision too
                             76 
                             77 	;if (hero_x + hero_w <= obs_x)
                             78 	;hero_x + hero_w - obs_x <=0
                             79 
   402A 7E            [ 7]   80 	ld a, (hl)		;ld en a hl pointer to hero_x
   402B 23            [ 6]   81 	inc hl			;|
   402C 23            [ 6]   82 	inc hl			;|move the pointe twice. now poits to hero_w
   402D 86            [ 7]   83 	add (hl)		;now a stores hero_x + hero_w
                             84 
   402E 4F            [ 4]   85 	ld c, a			;c stores hero_x + hero_w
   402F 3A 00 40      [13]   86 	ld a, (obs_x)		;ld a obs_x
   4032 47            [ 4]   87 	ld b, a			;b stores obs_x
   4033 79            [ 4]   88 	ld a, c			;a stores hero_x + hero_w
   4034 90            [ 4]   89 	sub b			;hero_x + hero_w - obs_x
                             90 
   4035 28 06         [12]   91 	jr z, no_collision	;if is equal to zero, there´s no collision
   4037 FA 3D 40      [10]   92 	jp m, no_collision	;if is negative (minus) there´s no collision too
                             93 
                             94 	;collision
   403A 3E FF         [ 7]   95 	ld a, #0xFF
                             96 
   403C C9            [10]   97 	ret
                             98 
                             99 	;no collision 
   403D                     100 	no_collision:
   403D 3E 00         [ 7]  101 		ld a, #0x00
   403F C9            [10]  102 	ret 
                            103 
                            104 
                            105 	;other posibilities
                            106 
   4040 C9            [10]  107 	ret
                            108 ;=======================================================
                            109 ;=======================================================
                            110 ;PRIVATE FUNCTIONS
                            111 ;======================================================
                            112 ;======================================================
                            113 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                            114 ;============================================
                            115 ;DRAW THE OBSTACLE
                            116 ;INPUTS A=> Colour pattern 
                            117 ;DESTROYS: AF, BC, DE, HL
                            118 ;============================================
   4041                     119 drawObstacle:
   4041 F5            [11]  120 	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
                            121 
                            122 	;calculate screen position
                            123 	;cpct_getScreenPtr_asm inputs
   4042 11 00 C0      [10]  124 	ld de, #0xC000		;video memoy pointer
   4045 3A 00 40      [13]  125 	ld a, (obs_x)		;|
   4048 4F            [ 4]  126 	ld c, a			;| C=obs_x
   4049 3A 01 40      [13]  127 	ld a, (obs_y)		;|
   404C 47            [ 4]  128 	ld b, a			;| B=obs_y
   404D CD E2 42      [17]  129 	call cpct_getScreenPtr_asm
                            130 
                            131 	;draw a box 
                            132 	;cpct_drawSolidBox_asm inputs
   4050 EB            [ 4]  133 	ex de, hl 	;intercambia hl y de 
   4051 F1            [10]  134 	pop af 		;color elegido por el usuario
   4052 01 01 04      [10]  135 	ld bc, #0x0401	;alto por ancho en pixeles 4x4
   4055 CD 35 42      [17]  136 	call cpct_drawSolidBox_asm
                            137 
   4058 C9            [10]  138 ret
