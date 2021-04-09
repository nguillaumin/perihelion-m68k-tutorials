                jsr     initialise

                movem.l picture+2, d0-d7         ; put picture palette in d0-d7
                movem.l d0-d7, $ff8240           ; move palette from d0-d7

                move.w  #2, -(a7)                ; get physbase
                trap    #14
                addq.l  #2, a7

                move.l  d0, a0                   ; a0 points to screen memory
                move.l  #picture+34, a1          ; a1 points to picture

                move.l  #7999, d0                ; 8000 longwords to a screen
loop
                move.l  (a1)+, (a0)+             ; move one longword to screen
                dbf     d0, loop

                move.w  #7, -(a7)                ; wait keypress
                trap    #1
                addq.l  #2, a7

                jsr     restore

                clr.l   -(a7)
                trap    #1

                include initlib.s

                section data

picture         incbin  jet_li.pi1

