.area _CODE

.include "cpctelera.h.s"
;=======================================================
;=======================================================
;PRIVATE DATA
;======================================================
;======================================================
obs_x: .db #80-1	;posicion x del obstaculo (al final de la pantalla)
obs_y: .db #82		;posicióny del obstaculo
obs_w: .db #1		;ancho del obstaculo en bytes
obs_h: .db #4		;alto del obstaculo en bytes

;=======================================================
;=======================================================
;PUBLIC FUNCTIONS
;======================================================
;======================================================

;============================================
;ERASES THE OBSTACLE
;DESTROYS: 
;============================================
obstacle_erase::
	ld a, #0x00			;background color
	call drawObstacle 		;call drawObstacle function :)

	ret

;============================================
;DRAW THE OBSTACLE 
;DESTROYS: 
;============================================
obstacle_draw::
	ld a, #0xF0			;cyan
	call drawObstacle 		;call drawObstacle function :)

	ret

;============================================
;UPDATES THE OBSTACLE
;DESTROYS: 
;============================================
obstacle_update::
	;Move obstacle to the left
	ld a, (obs_x)
	dec a
	jr nz, not_restart_x	;dec a también activa los flags, por lo tanto mientras no sea cero no se resetea su posición

		ld a, #80-1	;start location

	not_restart_x:
	ld (obs_x), a		;update obs_x position

	ret

;============================================
;CHECK COLISION BETWEEN OBSTACLE AND ANOTHER ENTITY
;INPUT:
;	HL: POINTS TO THE OTHER ENTITY 
;RETURN;XXXXXX
;DESTROYS: 
;============================================
obstacle_checkCollion::
	;if (obs_x + obs_w <= hero_x) no_collision
	;obs_x + obs_w - hero_x <= 0
	ld a, (obs_x)		;|	
	ld c, a			;|
	ld a, (obs_w)		;|
	add c 			;|obs_x + obs_w
				
	sub (hl)		;hl points to other entity data in this order(first-> hero_x, second-> hero_y, 
				;third-> hero_w, forurh-> hero_h)	
	jr z, no_collision	;if is equal to zero, there´s no collision
	jp m, no_collision	;if is negative (minus) there´s no collision too

	;if (hero_x + hero_w <= obs_x)
	;hero_x + hero_w - obs_x <=0

	ld a, (hl)		;ld en a hl pointer to hero_x
	inc hl			;|
	inc hl			;|move the pointe twice. now poits to hero_w
	add (hl)		;now a stores hero_x + hero_w

	ld c, a			;c stores hero_x + hero_w
	ld a, (obs_x)		;ld a obs_x
	ld b, a			;b stores obs_x
	ld a, c			;a stores hero_x + hero_w
	sub b			;hero_x + hero_w - obs_x

	jr z, no_collision	;if is equal to zero, there´s no collision
	jp m, no_collision	;if is negative (minus) there´s no collision too

	;collision
	ld a, #0xFF

	ret

	;no collision 
	no_collision:
		ld a, #0x00
	ret 


	;other posibilities

	ret
;=======================================================
;=======================================================
;PRIVATE FUNCTIONS
;======================================================
;======================================================

;============================================
;DRAW THE OBSTACLE
;INPUTS A=> Colour pattern 
;DESTROYS: AF, BC, DE, HL
;============================================
drawObstacle:
	push af 	;guardamos en la pila el patron de color para utilizarlo mas adelante

	;calculate screen position
	;cpct_getScreenPtr_asm inputs
	ld de, #0xC000		;video memoy pointer
	ld a, (obs_x)		;|
	ld c, a			;| C=obs_x
	ld a, (obs_y)		;|
	ld b, a			;| B=obs_y
	call cpct_getScreenPtr_asm

	;draw a box 
	;cpct_drawSolidBox_asm inputs
	ex de, hl 	;intercambia hl y de 
	pop af 		;color elegido por el usuario
	ld bc, #0x0401	;alto por ancho en pixeles 4x4
	call cpct_drawSolidBox_asm

ret