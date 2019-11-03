.area _DATA

;declaracion de variables
hero_x: .db  #39		;define byte
hero_y:	.db  #80

jump_pointer: .db #-1		;pointer to the jump_Table

jump_Table:
	.db #-3, #-3, #-2, #-2, #-1	;Jump Up
	.db #00, #00			;Jump Stand
	.db #01, #02, #02, #03, #03	;Jump down
	.db #0x127			;Jump end label			
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
BoxWidth = 2 

.area _CODE
;============================================
;Move Right to the limit of the screen
;DESTROYS: AF
;============================================
heroMoveRight:
		ld a, (hero_x)		;Cargamos la posición actual de Hero en el acumulador
		inc a			;Incrementamos el valor de hero_x
		cp #79-BoxWidth		;Comparamos con la posición máxima en pantalla para X menos la anchura del recuadro
		ret z			;si se ha alcanzado la posición máxima se sale de la rutina sin hacer nada mas

		ld (hero_x), a		;si no, se actualiza la posición en la variable hero_x
	ret
;============================================
;Move Left to the limit of the screen
;DESTROYS: AF
;============================================
heroMoveLeft:
		ld a, (hero_x)		;Cargamos la posición actual de Hero en el acumulador
		dec a			;Decrementamos el valor de hero_x en uno
		cp #0xFF		;Si la posición de hero_x (de su parte superior izquierda) es -1 salimos de la rutina sin hacer nada mas 
		ret z	

		ld (hero_x), a		;si no, se actualiza la posición en la variable hero_x
	ret

;============================================
;When is active, Do the Hero Jump
;DESTROYS: AF BC HL
;============================================
heroJump:
	ld a, (jump_pointer)	;Load jump_pointer in the accumulator
	cp #-1			;Compare with -1 
	ret z			;If jump_pointer is setting in -1 routine ends
		;if not
		ld hl, #jump_Table	;Hl point to the first element of the jump_Table
		ld c, a	
		ld b, #00
		add hl, bc		;HL now stores the Y movemnt of jump's memory position 

		ld a, (hl)		;Load jump_Table,s Y movemnt in the accumulator
		cp #0x127		;compare with ending jump's label
		jr z, jumping_end	;jum is end, set jump_pointer to -1

			;if not -> now a stores correspondent y movemnt of the jump
			ld b, a		;
			ld a, (hero_y)	;
			add b		;
			ld (hero_y), a	;update new hero_y position

			ld a, (jump_pointer)	;
			inc a			;
			ld (jump_pointer), a	;update jump_pointer to the next position 


	ret

	jumping_end:			;jum is end, set jump_pointer to -1
		ld a, #-1
		ld (jump_pointer), a	;set jump_pointer to -1
		ret

;============================================
;CHECK USER INPUT AND REACTS
;DESTROYS: 
;============================================
checkUserInput:

	call cpct_scanKeyboard_asm	;CPCTelera routine that scans whole keyboard

	ld hl, #Key_D			;Input for cpct_isKeyPressed_asm // constant #Key_D include in keyboard/keyboard.s
	call cpct_isKeyPressed_asm 	;Outputs in A & L = 0 if not pressed or 0> if not pressed
	cp #0
	jr z, d_not_pressed		;jump to d_not_pressed

		call heroMoveRight	;if K is pressed call heroMoveRight
	
	d_not_pressed:

	; se repite para la letra A #key_A 
	ld hl, #Key_A	;Constante incluida en keyboard.s
	call cpct_isKeyPressed_asm
	cp #0 	;si es cero no se ha presionado
	jr z, a_not_pressed
		call heroMoveLeft

	a_not_pressed:

	ld hl, #Key_W	;Constante incluida en keyboard.s
	call cpct_isKeyPressed_asm
	cp #0 				;if the accumulator is 0 the key is not pressed
	jr z, w_not_pressed
		ld a, (jump_pointer)
		cp #-1
		jr nz, jump_is_taking_place	;if jump_pointer stores a number different os -1 the jump is taking place
			;if not we can activate the jump setting jump_pointer to 0
			inc a
			ld (jump_pointer), a

		jump_is_taking_place:
	w_not_pressed:
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
	ld a, #0x00		;delete hero -> background color
	call drawhero 		;call drawhero function :)

	call heroJump		;If hero is jumpling update Y position
	call checkUserInput	;check if user pressed keys
	ld a, #0xFF		;select Box color of Hero
	call drawhero 		;call drawhero function :)

	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.

	jr gameLoop
