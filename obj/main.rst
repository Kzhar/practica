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
   4032                      11 _main::
                             12 
   4032 CD 63 40      [17]   13 	call hero_erase
   4035 CD 02 40      [17]   14 	call obstacle_erase
                             15 
   4038 CD 6F 40      [17]   16 	call hero_update
   403B CD 0E 40      [17]   17 	call obstacle_update
                             18 
   403E CD 69 40      [17]   19 	call hero_draw
   4041 CD 08 40      [17]   20 	call obstacle_draw
                             21 
   4044 CD 11 41      [17]   22 	call cpct_waitVSYNC_asm	;Waits until CRTC produces vertical synchronization signal (VSYNC) and returns.
                             23 
   4047 18 E9         [12]   24 	jr _main
