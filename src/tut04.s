                jsr     initialise              ; jump to initialise
                
                move.w  $ffff8240, -(a7)        ; push old colour to stack
                move.l  #$ffff8240, a0          ; a0 points to colour 0
                move.w  #$700, (a0)             ; put $700 where a0 points
                
                move.w  #7, -(a7)               ; wait for a keypress
                trap    #1                      ; call gemdos
                addq.l  #2, a7                  ; clear up stack
                
                move.w  (a7)+, (a0)             ; pop from stack
                
                jsr     restore                 ; jump to restore
                
                clr.l   -(a7)                   ; clean exit
                trap    #1                      ; call gemdos
                
initialise
* set supervisor
                clr.l   -(a7)                   ; clear stack
                move.w  #32, -(a7)              ; prepare for user mode
                trap    #1                      ; call gemdos
                addq.l  #6, a7                  ; clean up stack
                move.l  d0, old_stack           ; backup old stack pointer
* end set supervisor
                
                rts
                
restore
* set user mode again
                move.l  old_stack, -(a7)        ; restore old stack pointer
                move.w  #32, -(a7)              ; back to user mode
                trap    #1                      ; call gemdos
                addq.l  #6, a7                  ; clear stack
* end set user
                
                rts
                
                section data
                
old_stack       dc.l    0
