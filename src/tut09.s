                jsr     initialise

                movem.l picture+2, d0-d7         ; put picture palette in d0-d7
                movem.l d0-d7, $ff8240           ; move palette from d0-d7
              
                move.l  #screen, d0              ; put screen1 address in d0
                clr.b   d0                       ; put on 256 byte boundary  
                move.l  d0, a0                   ; a0 points to screen memory
              
                clr.b   $ff820d                  ; clear STe extra bit  
                lsr.l   #8, d0    
                move.b  d0, $ff8203              ; put in mid screen address byte
                lsr.w   #8, d0
                move.b  d0, $ff8201              ; put in high screen address byte
              
                move.l  #picture+34, a1          ; a1 points to picture
                
                move.l  #11199, d0               ; 320*280 / 8 - 1
loop
                move.l  (a1)+, (a0)+             ; move one longword to screen
                dbf     d0, loop

                move.l  #backup, a0              ; get ready with backup space
                move.b  $fffa07, (a0)+           ; backup enable a
                move.b  $fffa13, (a0)+           ; backup mask a
                move.b  $fffa15, (a0)+           ; backup mask b
                move.b  $fffa1b, (a0)+           ; backup timer b control
                move.b  $fffa21, (a0)+           ; backup timer b data
                add.l   #1, a0                   ; make address even
                move.l  $120, (a0)+              ; backup vector $120 (timer b)
                move.l  $70, (a0)+               ; backup vector $70 (vbl)
;              
                bclr    #5, $fffa15              ; disable timer c
                clr.b   $fffa1b                  ; disable timer b
                move.l  #timer_b, $120           ; move in my timer b address
                bset    #0, $fffa07              ; turn on timer b in enable a
                bset    #0, $fffa13              ; turn on timer b in mask a
              
                move.l  #vbl, $70
                
                move.w  #7, -(a7)                ; wait keypress
                trap    #1
                addq.w  #2, a7
                  
                move.l  #backup, a0
                move.b  (a0)+, $fffa07           ; restore enable a
                move.b  (a0)+, $fffa13           ; restore mask a
                move.b  (a0)+, $fffa15           ; restore mask b
                move.b  (a0)+, $fffa1b           ; restore timer b control
                move.b  (a0)+, $fffa21           ; restore timer b data
                add.l   #1, a0                   ; make address even
                move.l  (a0)+, $120              ; restore vector $120 (timer b)
                move.l  (a0)+, $70               ; restore vector $70 (vbl)
                
                jsr     restore
              
                clr.l   -(a7)
                trap    #1

vbl
                move.w  sr, -(a7)                ; backup status register
                or.w    #$0700, sr               ; disable interrupts
                movem.l d0-d7/a0-a6, -(a7)       ; backup registers
                
                move.w  #1064, d0
pause
                nop                              
                dbf     d0, pause                ; about 15000 cycles pause
            
                eor.b   #2, $ff820a              ; toggle PAL/NTSC
                rept    8      
                nop                              ; wait a bit ...
                endr                             ; ... for effect to kick in
                eor.b   #2, $ff820a              ; toggle PAL/NTSC back again
            
                clr.b   $fffa1b                  ; disable timer b
                move.b  #228, $fffa21            ; number of counts 
                move.b  #8, $fffa1b              ; set timer b to event count mode
            
                movem.l (a7)+, d0-d7/a0-a6       ; restore registers
                move.w  (a7)+, sr                ; restore status register
                rte                              ; finnished interrupt
    
timer_b
                movem.l d0/a0, -(a7)             ; backup registers
                move.l  #$fffa21, a0             ; timer b counter address
                move.b  (a0), d0                 ; get timer b count value

pause_b
                cmp.b   (a0), d0                 ; wait for it to change
                beq     pause_b                  ; EXACTLY on next line now!
              
                eor.b   #2, $ff820a              ; toggle PAL/NTSF
                rept    8      
                nop                              ; wait a bit ...
                endr                             ; ... for effect to kick in
                eor.b   #2, $ff820a              ; toggle PAL/NTSC back again
              
                movem.l (a7)+, d0/a0             ; restore registers
                bclr    #0, $fffa0f              ; tell ST interrupt is done
                rte                              ; exit interrupt
  
                include initlib.s  

                section data
  
picture         incbin  kenshin.pi1

                section bss

                ds.b    256
screen          ds.l    11200

backup          ds.b    14 
