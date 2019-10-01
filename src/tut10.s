                jsr     initialise

                move.l  $44e, a0                  ; a0 poins to screen memory
                move.w  #0, $ff8240               ; black background
                move.l  #7999, d0
clear
                clr.l   (a0)
                dbf     d0, clear                 ; clears screen to colour 0

main
                move.w  #37, -(a7)
                trap    #14
                addq.l  #2, a7                    ; wait retrace
  
get_x
                move.w  #17, -(a7)
                trap    #14
                addq.l  #2, a7                    ; get random number
                and.l   #%111111111, d0           ; make it maximum 511
                cmp     #319, d0      
                bgt     get_x                     ; loop until d0 < 320
                move.l  d0, d7                    ; store x coordinate

get_y
                move.w  #17, -(a7)
                trap    #14
                addq.l  #2, a7                    ; get random number
                and.l   #%11111111, d0            ; make it maximum 255
                cmp     #199, d0                  ; loop until d0 < 200
                bgt     get_y
                move.l  d0, d6                    ; store y coordinate
  
                move.w  #17, -(a7)
                trap    #14
                addq.l  #2, a7                    ; get random number
                and.l   #%1111, d0                ; make it maximum 15
                move.b  d0, d2                    ; put colour number in d2
                                
                move.l  d7, d0                    ; put x coordinate in d0
                move.l  d6, d1                    ; put y coordinate in d1
              
                move.l  $44e, a0                  ; a0 points to screen memory
                jsr     putpixel                  ; put pixel on screen
              
                cmp.b   #$39, $fffc02             ; space pressed?
                bne     main                      ; if not, repeat main
                
                jsr     restore
                
                clr.l  -(a7)                      ; clean
                trap   #1                         ; exit


putpixel:
; putpixel routine
; a0 screen adress
; d0 x-coordinate
; d1 y-coordinate
; d2 colour
                mulu.w  #160, d1                  ; 160 bytes to a scan line
                add.l   d1, a0                    ; add y value to screen memory
                divu.w  #16, d0                   ; number of clusters in low, bit in high
                clr.l   d1                        ; clear d1
                move.w  d0, d1                    ; move cluster part to d1
                mulu.w  #8, d1                    ; 8 bytes to a cluster
                add.l   d1, a0                    ; add cluster part to screen memory
                clr.w   d0                        ; clear out the cluster value
                swap    d0                        ; bit to alter in low part of d0

; now a0 points to the first word of the bitplane to use
; d0.w  holds the bit number to be manipulated in the word  

                swap    d2                        ; colour in the high part of d2
                move.w  #%0111111111111111, d1
                ror.w   d0, d1                    ; clear mask prepared
              
                rept    4                         ; do this 4 times
                lsr.l   #1, d2                    ; shift in the next colour bit
                ror.w   d0, d2                    ; shift colour bit into position
                and.w   d1, (a0)                  ; prepare with mask (bclr)
                or.w    d2, (a0)+                 ; or in the colour
                clr.w   d2                        ; clear the old used bit
                endr
                  
                rts
; end putpixel

                include initlib.s
