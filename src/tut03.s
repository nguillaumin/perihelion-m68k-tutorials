                jsr     initialise             ; jump to initialise

                move.w  $ffff8240, d7          ;save background color
                move.w  #$700, $ffff8240       ; red background color

                move.w  #7, -(a7)              ; wait for a keypress
                trap    #1                     ; call gemdos
                addq.l  #2, a7                 ; clear up stack

                move.w  d7, $ffff8240          ; move back old color

                jsr     restore                ; jump to restore

                clr.l   -(a7)                  ; clean exit
                trap    #1                     ; call gemdos

initialise
; set supervisor
                clr.l   -(a7)
                move.w  #32, -(a7)
                trap    #1
                addq.l  #6, a7
                move.l  d0, old_stack
; end set supervisor
                rts

restore
; set user mode again
                move.l  old_stack, -(a7)
                move.w  #32, -(a7)
                trap    #1
                addq.l  #6,a7
; end set user
                rts

                section data
old_stack       dc.l    0