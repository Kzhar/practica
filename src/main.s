.area _DATA
.area _CODE

.include "hero.h.s"
.include "obstacle.h.s"
.include "cpctelera.h.s"

;============================================
;MAIN PROGRAM ENTRY
;============================================
_main::

	call hero_erase
	call obstacle_erase

	call hero_update
	call obstacle_update

	call hero_getPtrHL
	call obstacle_checkCollion
	ld (0xC000), a 			;Draw if collision in the first video memory byte (FF if yes, 00 if no)
	ld (0xC001), a 			;|
	ld (0xC002), a 			;|
	ld (0xC003), a 			;|enlarge collision bar

	call hero_draw
	call obstacle_draw

	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.

	jr _main
