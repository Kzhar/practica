ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 .area _CODE
                              3 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              4 .include "hero.h.s"
                              1 ;=======================================
                              2 ;=======================================
                              3 ;HERO PUBLIC FUNCTIONS
                              4 ;=======================================
                              5 ;=======================================
                              6 .globl hero_erase
                              7 .globl hero_update
                              8 .globl hero_draw
                              9 .globl hero_getPtrHL
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                              5 .include "obstacle.h.s"
                              1 ;=======================================
                              2 ;=======================================
                              3 ;OBSTACLE PUBLIC FUNCTIONS
                              4 ;=======================================
                              5 ;=======================================
                              6 .globl obstacle_erase
                              7 .globl obstacle_update
                              8 .globl obstacle_draw
                              9 .globl obstacle_checkCollion
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                              6 .include "cpctelera.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                              7 
                              8 ;============================================
                              9 ;MAIN PROGRAM ENTRY
                             10 ;============================================
   4059                      11 _main::
                             12 
   4059 CD A0 40      [17]   13 	call hero_erase
   405C CD 04 40      [17]   14 	call obstacle_erase
                             15 
   405F CD B6 40      [17]   16 	call hero_update
   4062 CD 10 40      [17]   17 	call obstacle_update
                             18 
   4065 CD BD 40      [17]   19 	call hero_getPtrHL
   4068 CD 1C 40      [17]   20 	call obstacle_checkCollion
   406B 32 00 C0      [13]   21 	ld (0xC000), a 			;Draw if collision in the first video memory byte (FF if yes, 00 if no)
   406E 32 01 C0      [13]   22 	ld (0xC001), a 			;|
   4071 32 02 C0      [13]   23 	ld (0xC002), a 			;|
   4074 32 03 C0      [13]   24 	ld (0xC003), a 			;|enlarge collision bar
                             25 
   4077 CD AB 40      [17]   26 	call hero_draw
   407A CD 0A 40      [17]   27 	call obstacle_draw
                             28 
   407D CD 2D 42      [17]   29 	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.
                             30 
   4080 18 D7         [12]   31 	jr _main
