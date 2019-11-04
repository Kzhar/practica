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

	call hero_draw
	call obstacle_draw

	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.

	jr _main
