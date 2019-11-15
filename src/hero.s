.area _CODE

;=======================================================
;=======================================================
;PRIVATE DATA
;======================================================
;======================================================
;declaración de constantes
.equ Ent_x, 0
.equ Ent_y, 1
.equ Ent_w, 2
.equ Ent_h, 3
.equ Ent_jump, 4
.equ Ent_sptr01, 5
;declaración de macro
.macro defineEntity name, x, y, w, h, spr 	;define a macro to create entities
	name'_data:
		name'_x: 		.db 	x		;|
		name'_y:		.db 	y		;|hero position 
		name'_w:		.db     w		;|
		name'_h:		.db 	h		;|hero widht and height in bytes
		name'_jump:		.db 	#-1	;variable de control del array de salto de Hero
		name'_sprt01:		.dw 	spr
.endm	;end of the macro

defineEntity hero, #39, #80, #2, #8, #hero_sprite01	;define hero as in the next coment lines
;hero_data:
;	hero_x: 	.db 	#39		;|
;	hero_y:		.db 	#80		;|hero position 
;	hero_w:		.db     #2		;|
;	hero_h:		.db 	#8		;|hero widht and height in bytes
;	hero_jump:	.db 	#-1	;variable de control del array de salto de Hero
;	hero_sprt01:	.dw 	#hero_sprite01

;jump Table
jumpTable:
	.db #-3, #-2, #-1, #-1
	.db #-1, #00, #00, #00
	.db #01, #02, #02, #03
	.db #0x80 		;byte que marca el final de la tabla de salto 1000 0000

;Se declaran aqui las funciones de cpctelera que se van a utilizar 
;cpctelera symbols
.include "keyboard/keyboard.s"
.include "cpctelera.h.s"
;SPRITE DATA
.include "sprite.h.s"
;=======================================================
;=======================================================
;PUBLIC FUNCTIONS
;======================================================
;======================================================

;============================================
;ERASES THE HERO
;DESTROYS: 
;============================================
hero_erase::
	;ld a, #0x00
	ld hl, #delete_sprite
	ld ix, #hero_data	;pointer to th entity to draw
	call drawhero 		;call drawhero function :)

	ret

;============================================
;DRAW THE HERO 
;DESTROYS: 
;============================================
hero_draw::
	;ld a, #0xFF
	ld hl, (hero_sprt01)
	ld ix, #hero_data	;pointer to th entity to draw
	call drawhero 		;call drawhero function :)

	ret

;============================================
;UPDATES THE HERO
;DESTROYS: 
;============================================
hero_update::
	call jumpControl	;llamamos a la funcion que controla el salto del personaje 
	call checkUserInput	;check if user pressed keys

	ret

;============================================
;GETS A POINTER TO HERO DATA IN HL
;DESTROYS: HL
;RETURNS: Pointer to HERO DATA
;============================================
hero_getPtrHL::
	ld hl, #hero_x	;hl points to the fisrt data of hero (hero_x, hero_y, hero_w, hero_h)
	ret

;=======================================================
;=======================================================
;PRIVATE FUNCTIONS
;======================================================
;======================================================

;============================================
;Controls Jump Movements
;DESTROYS: 
;============================================
jumpControl:
	ld a, (hero_jump)	;comprovamos el estado de la variable de estado
	cp #-1			;comparamos con -1 -> no estoy saltando
	ret z			;si la variable de estado es -1, no esta saltando, por lo tanto sale de la funcion

	;Get jump value
	ld hl, #jumpTable	;HL Point to the first element of the Jump Table
	ld c, a			;
	ld b, #0		;
	add hl, bc 		;HL += A -> point to the element of the array 

	;check end of jumping
	ld a, (hl)		;HL ahora es el puntero a la tabla mas el offset que está en hero_jump 
	cp #0x80		;si el contenido de esa direccion de memoria es 0x80 es que hemos llegado al final de la tabla
	jr z, end_of_jump	;

	;do jump Movement
	ld b, a			;B= Jump Movement = Movement in Y	
	ld a, (hero_y)		;A= Y position
	add b			;A+= B -> Add jump movement 
	ld (hero_y), a		;Update hero_y Value

	;Increment hero_jump Index
	ld a, (hero_jump)	
	inc a			;
	ld (hero_jump), a	;Hero_jump ++

	ret 

	;poner el indice hero_jump a -1 lo que quiere decir que el salto no se esta ejecutando
	end_of_jump:		;si se ha detectado el final del salto
		ld a, #-1
		ld (hero_jump), a
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
;Start Hero Jump
;DESTROYS: AF
;============================================
startJump:
	ld a, (hero_jump)	;A=indice de la tabla de salto
	cp #-1			;Si no es -1 el salto ya esta activo
	ret nz			;salimos de la rutina sin hacer nada si el salto esta ya activo
	;Jump is not active, activate it
	ld a, #0
	ld (hero_jump), a	;activo el salto metiendo en a un 0 -> primer indice de la tabla

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

	ld hl, #Key_W
	call cpct_isKeyPressed_asm
	cp #0
	jr z, w_not_pressed

		call startJump		;si se ha pulsado W

	w_not_pressed:

ret	;a dibujar Hero en la nueva posicion

;============================================
;DRAWS ANYTHING
;INPUTS 
;	A  => Colour pattern 
;	IX => Pointer to entity data (0 = X, 1 = Y, 2 = Width, 3 = Height) 
;DESTROYS: AF, BC, DE, HL
;============================================
drawhero:
	;push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante
	push hl
	;Return Value(HL)
	;calculate screen position
	ld de, #0xC000		;video memoy pointer
	ld c, Ent_x(ix)		;| C=Entity_x
	ld b, Ent_y(ix)		;| B=Entity_y

	call cpct_getScreenPtr_asm

	;la posicion de memorioa esta ahora en HL que es lo que nos devuelve cpct_getScreenPtr_asm
	;habra que pasar hl a de 
	ex de, hl 		;intercambia hl y de 
	ld c, Ent_w(ix)		;C=Entity_w (width)
	ld b, Ent_h(ix)		;B=Entity_h (height)
	;pop af 
	pop hl			;color elegido por el usuario
	;call cpct_drawSolidBox_asm
	call cpct_drawSprite_asm

ret

