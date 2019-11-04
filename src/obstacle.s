.area _CODE

.include "cpctelera.h.s"
;=======================================================
;=======================================================
;PRIVATE DATA
;======================================================
;======================================================
obs_x: .db #80-1
obs_y: .db #82

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