                jsr     initialise
                
                move.w  #2, -(a7)                ; get physbase
                trap    #14    
                addq.l  #2, a7    
                
                move.l  d0, a0                   ; a0 points to screen

; clears the screen to colour 0, background
                move.l  #7999, d1                ; size of screen memory
clrscr
                clr.l  (a0)+                     ; all 0 means colour 0 :)
                dbf    d1, clrscr      

                move.l  d0, a0                   ; a0 points to screen

* fills screen with colours, ok 180 scanlines :)
                move.l  #1199, d0                ; 60 scanlines
fill1  
                move.w  #%1111111111111111, (a0)+
                move.w  #%0000000000000000, (a0)+
                move.w  #%0000000000000000, (a0)+
                move.w  #%0000000000000000, (a0)+
                dbf     d0, fill1                ; filled with colour 1

                move.l  #1199, d0                ; 60 scanlines
fill2  
                move.w  #%0000000000000000, (a0)+
                move.w  #%1111111111111111, (a0)+
                move.w  #%0000000000000000, (a0)+
                move.w  #%0000000000000000, (a0)+
                dbf     d0, fill2                ; filled with colour 2

                move.l  #1199, d0                ; 60 scanlines
fill3  
                move.w  #%1111111111111111, (a0)+
                move.w  #%1111111111111111, (a0)+
                move.w  #%0000000000000000, (a0)+
                move.w  #%0000000000000000, (a0)+
                dbf     d0, fill3                ; filled with colour 3

                move.w  #$000, $ff8240           ; black background
                move.w  #$700, $ff8242           ; red colour 1
                move.w  #$070, $ff8244           ; green colour 2
                move.w  #$007, $ff8246           ; blue colour 3
                
                move.l  #24, d5                  ; 25 VBL's per loop
                move.w  #6, d6                   ; make 7 loops
main
                move.w  #37, -(a7)               ; wait VBL
                trap    #14
                addq.l  #2, a7
                
                dbf     d5, main                 ; loop vbl's

                add.w   #-$100, $ff8242          ; subtract one from red
                add.w   #-$010, $ff8244          ; subtract one from green
                add.w   #-$001, $ff8246          ; subtract one from blue

                move.l  #24, d5                  ; reset VBL counter
                
                dbf     d6, main                 ; end of main loop

                jsr     restore
                
                clr     -(a7)
                trap    #1

initialise
* set supervisor
                clr.l   -(a7)                    ; clear stack
                move.w  #32, -(a7)               ; prepare for user mode
                trap    #1                       ; call gemdos
                addq.l  #6, a7                   ; clean up stack
                move.l  d0, old_stack            ; backup old stack pointer
* end set supervisor

* save the old palette; old_palette
                move.l  #old_palette, a0         ; put backup address in a0
                movem.l $ffff8240, d0-d7         ; all palettes in d0-d7
                movem.l d0-d7, (a0)              ; move data into old_palette
* end palette save

* saves the old screen adress
                move.w  #2, -(a7)                ; get physbase
                trap    #14
                addq.l  #2, a7
                move.l  d0, old_screen           ; save old screen address
* end screen save

* save the old resolution into old_resolution
* and change resolution to low (0)
                move.w  #4, -(a7)                ; get resolution
                trap    #14
                addq.l  #2, a7
                move.w  d0, old_resolution       ; save resolution
                
                move.w  #0, -(a7)                ; low resolution
                move.l  #-1, -(a7)               ; keep physbase
                move.l  #-1, -(a7)               ; keep logbase
                move.w  #5, -(a7)                ; change screen
                trap    #14
                add.l   #12, a7
* end resolution save  

                rts

restore  
* restores the old resolution and screen adress
                move.w  old_resolution, d0       ; res in d0
                move.w  d0, -(a7)                ; push resolution
                move.l  old_screen, d0           ; screen in d0
                move.l  d0, -(a7)                ; push physbase
                move.l  d0, -(a7)                ; push logbase
                move.w  #5, -(a7)                ; change screen
                trap    #14
                add.l   #12, a7
* end resolution and screen adress restore

* restores the old palette
                move.l  #old_palette, a0         ; palette pointer in a0
                movem.l (a0), d0-d7              ; move palette data
                movem.l d0-d7, $ffff8240         ; smack palette in
* end palette restore

* set user mode again
                move.l  old_stack, -(a7)         ; restore old stack pointer
                move.w  #32, -(a7)               ; back to user mode
                trap    #1                       ; call gemdos
                addq.l  #6, a7                   ; clear stack
* end set user
                
                rts

                section data

old_resolution  dc.w    0
old_stack       dc.l    0
old_screen      dc.l    0


                section bss

old_palette     ds.l    8