.area _DATA

;declaracion de variables
hero_x: 	.db 	#39		;;define byte
hero_y:		.db 	#80

hero_jump:	.db 	#-1	;variable de control del array de salto de Hero
;jump Table
jumpTable:
	.db #-3, #-2, #-1, #-1
	.db #-1, #00, #00, #00
	.db #01, #02, #02, #03
	.db #0x80 		;byte que marca el final de la tabla de salto 1000 0000

;Se declaran aqui las funciones de cpctelera que se van a utilizar 
;cpctelera symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isKeyPressed_asm
.globl cpct_waitVSYNC_asm

.include "keyboard/keyboard.s"

;Declaración de constantes


.area _CODE
;============================================
;Controls Jump Movements
;DESTROYS: 
;============================================
jumpControl:
	ld a, (hero_jump)	;comprovamos el estado de la variable de estado
	cp #-1			;comparamos con -1 -> no estoy saltando
	ret z			;si la variable de estado es -1, no esta saltando, por lo tanto sale de la funcion

	;Move hero (jump)
	ld hl, jumpTable	;HL Point to the first element of the Jump Table
	ld c, a			;
	ld b, #0		;
	add hl, bc 		;HL += A -> point to the element of the array 

	ret 

;============================================
;move Hero Right if is not at the screen limit
;DESTROYS: AF
;============================================

moveHeroRight:
	ld a, (hero_x)
	cp #80-2 	;comprovamos que no se sale por la derecha (80 bytes pantalla- 2 anchura Hero)
	jr z, not_move_right
		inc a		;si no se sale de la pantalla se mueve
		ld (hero_x), a

	not_move_right:

	ret

;============================================
;move Hero Left if is not at the screen limit
;DESTROYS: AF
;============================================
moveHeroLeft:
	ld a, (hero_x)
	cp #0 	;comprovamos que no se sale por la izquierda (X=0)
	jr z, not_move_left
		dec a		;si no se sale de la pantalla se mueve
		ld (hero_x), a

	not_move_left:

	ret

;============================================
;CHECK USER INPUT AND REACTS
;DESTROYS: 
;============================================
checkUserInput:
	;/////////////////////////SE PODRÍA GUARDAR EN UN BYTE DE MEMORIA PARA NO HACER TANTOS CÁLCULOS
	;Reads the status of keyboard and joysticks and stores it in the 10 bytes reserved as cpct_keyboardStatusBuffer
	;Ver a que corresponde cada tecla del keyboardStatusBuffer en la documenacion de cpctelera
	;scan whole keyboard
	call cpct_scanKeyboard_asm

	;Checks if a concrete key is pressed or not.
	;input HL -> se mete en HL el codigo de la tecla que queremos comprobar 
	;en el .include "keyboard/keyboard.s tenemos las constantes de todas las teclas, por lo tanto podemos tuilizar Key_D"
	;check if d is pressed
	ld hl, #Key_D	;;equ Key_D definido en el fichero keyboard.s que hemos incluido en la parte de _DATA .include "keyboard/keyboard.s"
	;************************************************************
	;Return value (for Assembly, L=A=key_status) <u8> false (0, if not pressed) or true (>0, if pressed).  Take into account that true is not 1, but any non-0 number.
	call cpct_isKeyPressed_asm 
	cp #0	;compara lo que hay en el acumuldor
		;Cero si no se ha presionado
	jr z, d_not_pressed

		call moveHeroRight	;si la tecla se ha pulsado llamamos a la rutina moveHeroRight

	d_not_pressed:

	;Ahora comprobamos si se ha pulado A
	ld hl, #Key_A	
	call cpct_isKeyPressed_asm 
	cp #0	;compara lo que hay en el acumuldor
		;Cero si no se ha presionado
	jr z, a_not_pressed

		call moveHeroLeft	;si la tecla se ha pulsado llamamos a la rutina moveHeroLeft

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


;============================================
;MAIN PROGRAM ENTRY
;============================================
_main::

	ld a, #0x00
	call drawhero 		;call drawhero function :)

	call jumpControl	;llamamos a la funcion que controla el salto del personaje 
	call checkUserInput	;check if user pressed keys

	ld a, #0xFF
	call drawhero 		;call drawhero function :)

	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.

	jr _main
