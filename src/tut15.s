                section text

                jsr     initialise

                movem.l picture+2, d0-d7          ; put picture palette in d0-d7
                movem.l d0-d7, pal                ; copy palette to pal

                movem.l temp_pal, d0-d7           ; put current palette in d0-d7
                movem.l d0-d7, $ff8240            ; apply current palette (all 0)

                move.w  #2, -(a7)                 ; get physbase
                trap    #14
                addq.l  #2, a7

                move.l  d0, a0                    ; a0 points to screen memory
                move.l  #picture+34, a1           ; a1 points to picture

                move.l  #7999, d0                 ; 8000 longwords to a screen
loop
                move.l  (a1)+, (a0)+              ; move one longword to screen
                dbf     d0, loop

                move.l  $70, old_70               ; backup $70
                move.l  #main, $70                ; start main routine

                move.w  #7, -(a7)                 ; wait keypress
                trap    #1
                addq.l  #2, a7

                move.l  old_70, $70               ; restore $70

                jsr restore

                clr.l   -(a7)
                trap    #1

main
                move.w  sr, -(a7)                 ; backup status register
                or.w    #$0700, sr                ; disable interrupts
                movem.l d0-d7/a0-a6, -(a7)        ; backup registers

                add.l   #1, counter               ; increment counter variable
                cmp.l   #15, counter              ; only execute main sometimes
                bne     do_nothing                ; skip instructions
                clr.l   counter                   ; reset counter

                move.l  #pal, a0                  ; a0 points to values to reach
                move.l  #temp_pal, a1             ; a1 points to current values

                rept    16                        ; do for each color
                jsr     check_red                 ; see if red intensity should increase
                jsr     check_green               ; see if green intensity should increase
                jsr     check_blue                ; see if blue intensity should increase
                add.l   #2, a0                    ; point to next color
                add.l   #2, a1                    ; point to next color
                endr

                movem.l temp_pal, d0-d7           ; put current palette in d0-d7
                movem.l d0-d7, $ff8240            ; apply current palette

do_nothing
                movem.l (a7)+, d0-d7/a0-a6        ; restore registers
                move.w  (a7)+, sr                 ; restore status register
                rte                               ; finished interrupt


check_red
                move.w  (a0), d0                  ; move one final color into d0
                move.w  (a1), d1                  ; move one temp color into d1

                and.w   #%011100000000, d0        ; mask off all but red values
                and.w   #%011100000000, d1        ; mask off all but red values

                cmp.w   d1, d0                    ; see if red is correct intensity
                beq     red_fin                   ; if not ...
                add.w   #%000100000000, (a1)      ; ... add one intensity of red
red_fin
                rts

check_green
                move.w  (a0), d0                  ; move one final color into d0
                move.w  (a1), d1                  ; move one temp color into d1

                and.w   #%000001110000, d0        ; mask off all but green values
                and.w   #%000001110000, d1        ; mask off all but green values

                cmp.w   d1, d0                    ; see if green at correct intensity
                beq     green_fin                 ; if not ...
                add.w   #%000000010000, (a1)      ; ... add one intensity of green
green_fin
                rts

check_blue
                move.w  (a0), d0                  ; move one final color into d0
                move.w  (a1), d1                  ; move one temp color into d1

                and.w   #%000000000111, d0        ; mask off all but blue values
                and.w   #%000000000111, d1        ; mask off all but blue values

                cmp.w   d1, d0                    ; see if blue at correct intensity
                beq     blue_fin                  ; if not ...
                add.w   #%000000000001, (a1)      ; ... add one intensity of blue
blue_fin
                rts

                include initlib.s

                section data

old_70          dc.l    0
picture         incbin  sleepsun.pi1
counter         dc.l    0

                section bss
pal             ds.w    16
temp_pal        ds.w    16
