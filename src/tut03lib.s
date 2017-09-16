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