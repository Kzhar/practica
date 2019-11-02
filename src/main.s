.area _DATA

;declaracion de variables
hero_x: .db  #39		;define byte
hero_y:	.db  #80
;declaracion de sprites
groundTile01:
	.db #0xF0, #0xF0
	.db #0xF0, #0xF0
	.db #0xA5, #0xA5
	.db #0x5A, #0x5A
	.db #0x0F, #0x0F
	.db #0x05, #0x05
	.db #0x0A, #0x0A
;Se declaran aqui las funciones de cpctelera que se van a utilizar 
;cpctelera symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isKeyPressed_asm
.globl cpct_waitVSYNC_asm
.globl cpct_drawSprite_asm

.include "keyboard/keyboard.s"

;Declaración de constantes
BoxWidth = 0x02 

.area _CODE

;============================================
;CHECK USER INPUT AND REACTS
;DESTROYS: 
;============================================
checkUserInput:

	call cpct_scanKeyboard_asm	;CPCTelera routine that scans whole keyboard

	ld hl, #Key_D				;Input for cpct_isKeyPressed_asm // constant #Key_D include in keyboard/keyboard.s
	call cpct_isKeyPressed_asm 	;Outputs in A & L = 0 if not pressed or 0> if not pressed
	cp #0
	jr z, d_not_pressed			;jump to d_not_pressed

		ld a, (hero_x)
		inc a
		add a, #BoxWidth 	;al final de drawhero popeamos bc para ulizar la anchura guardada en b en esta rutina
		cp #79		;maximo número de bytes en modo 0 (de 0 a 79)
		jp nc, d_not_pressed
		sub a, #BoxWidth
		ld (hero_x), a
	


	d_not_pressed:
	; se repite para la letra A #key_A 
	ld hl, #Key_A	;Constante incluida en keyboard.s
	call cpct_isKeyPressed_asm
	cp #0 	;si es cero no se ha presionado
	jr z, a_not_pressed
		ld a, (hero_x)
		dec a
		cp #0xFF
		jp z, a_not_pressed	;si es menor que 0 hay acarreo por lo tanto hero_x se queda ne la misma posicion
					;no actualizamos 

		ld (hero_x), a

	a_not_pressed:
ret	;a dibujar Hero en la nueva posicion

;============================================
;DRAW THE HERO
;INPUTS A=> Colour pattern 
;DESTROYS: AF, BC, DE, HL
;============================================
drawhero:
	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
	;USING GET SCREEN POINTER CPCTELERA FUNCTION*******************************
	;Input Parameters (4 Bytes)
	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)

	;Return Value(HL)
	;calculate screen position
	ld de, #0xC000		;video memoy pointer
	ld a, (hero_x)		;|
	ld c, a			;| C=hero_x
	ld a, (hero_y)		;|
	ld b, a			;| B=hero_y

	call cpct_getScreenPtr_asm


	;USING DRAW SOLID BOX CPCTELERA FUNCTION***************************** 
	;Input Parameters (5 bytes)
	;(2B DE) memory	Video memory pointer to the upper left box corner byte
	;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
	;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
	;(1B B ) height	Box height in bytes (>0)

	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
	;habra que pasar hl a de 
	ex de, hl 	;intercambia hl y de 
	pop af 		;color elegido por el usuario
	;ld a, #0x0F	;cyan
	ld bc, #0x0802	;alto por ancho en pixeles 8x8
	call cpct_drawSolidBox_asm

ret

drawGround:
	;Input Parameters (4 Bytes)
	;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
	;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
	;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
	ld c, #0x00	;y pasarla a la función cpct_drawSprite_asm primera X=0 Y=posición del cuadrado +8
	groundBucle:
	ld de, #0xC000	;Parametros de la funcion cpct_getScreenPtr_asm para calcular la posición de memoria de video
	push bc
	ld b, #88
	call cpct_getScreenPtr_asm
	;el resutado -> la posicion de memoria esta ahora en Hl y habra que pasarla a DE

	ex de, hl
	ld hl, #groundTile01	;Source Sprite Pointer (array with pixel data)
	ld c, #0x02		;C ) width Sprite Width in bytes [1-63] (Beware, not in pixels!)
	ld b, #0x08		;B ) height Sprite Height in bytes (>0)
	;Input Parameters (6 bytes)
	;2B HL) sprite	Source Sprite Pointer (array with pixel data)
	;2B DE) memory	Destination video memory pointer
	;1B C ) width	Sprite Width in bytes [1-63] (Beware, not in pixels!)
	;1B B ) height	Sprite Height in bytes (>0)	
	call cpct_drawSprite_asm

	pop bc 
	ld a, c 
	add #0x02
	ld c, a 
	cp #78
	jp nz, groundBucle



ret

;============================================
;MAIN PROGRAM ENTRY
;============================================
_main::
	call drawGround

	gameLoop:
	ld a, #0x00
	call drawhero 		;call drawhero function :)

	call checkUserInput	;check if user pressed keys

	ld a, #0xFF
	call drawhero 		;call drawhero function :)

	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.

	jr gameLoop
