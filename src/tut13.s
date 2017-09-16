                jsr     initialise

                moveq   #1, d0                    ; normal song play mode
                bsr     music

                move.l  #palette, a0              ; pointer to palette
                movem.l (a0)+, d0-d7              ; palette in d0-d7
                movem.l d0-d7, $ff8240            ; apply palette

                move.l  $70, -(a7)                ; backup $70
                move.l  #main, $70                ; start main routine

                move.w  #7, -(a7)
                trap    #1
                addq.l  #2, a7                    ; wait keypress

                move.l  (a7)+, $70                ; restore old $70

                moveq   #0, d0                    ; stop music
                bsr     music

                jsr     restore

                clr.l   -(a7)
                trap    #1                        ; exit

main
                movem.l d0-d7/a0-a6, -(a7)

                bsr     music+2                   ; play music

; put in VU bars
                move.l  $44e, a0                  ; get screen address
                add.l   #160*199-(15*2)*160, a0   ; bottom area of screen
                move.l  #bar, a1                  ; point to bar colours

                rept    15                        ; 15 max volume
                movem.l (a1)+, d0-d1              ; VU bar colour in d1-d2
                movem.l d0-d1, (a0)               ; first VU bar
                addq.l  #8, a0                    ; next VU bar
                movem.l d0-d1, (a0)               ; second VU bar
                addq.l  #8, a0                    ; next VU bar
                movem.l d0-d1, (a0)               ; third VU bar
                add.w   #320-16, a0               ; two lines down, two bars left
                endr

; delete VU bars depending on volume
                move.l  $44e, a0                  ; get screen address
                add.l   #160*199-(15*2)*160, a0   ; bottom area of screen

                moveq.l #0, d0                    ; clear d0
                move.b  #8, $ff8800               ; channel a volume
                move.b  $ff8800, d0               ; put volume in d0
                jsr     del_bar

                moveq.l #0, d0                    ; clear d0
                move.b  #9, $ff8800               ; channel b volume
                move.b  $ff8800, d0               ; put volume in d0
                add.l   #8, a0                    ; next VU bar
                jsr     del_bar

                moveq.l #0, d0                    ; clear d0
                move.b  #10, $ff8800              ; channel c volume
                move.b  $ff8800, d0               ; put volume in d0
                add.l   #8, a0                    ; next VU bar
                jsr     del_bar

                movem.l (a7)+, d0-d7/a0-a6
                rte

del_bar
; screen address of top line in a0
; volume in d0, gets detroyed
                move.l  a0, -(a7)                 ; backup a0
                move.l  a1, -(a7)                 ; backup a1
                and.b   #%1111, d0                ; keep only lowest 4 bits

                move.l  #delete, a1               ; beginning of delete blocks
                mulu    #12, d0                   ; length of one delete block
                add.l   d0, a1                    ; skip some delete instructions
                jmp     (a1)                      ; jump to correct delete position

delete
                rept    15
                clr.l   (a0)                      ; clear two bit planes
                clr.l   4(a0)                     ; clear two bit planes
                add.l   #320, a0                  ; hop two lines down
                endr

                move.l  (a7)+, a1                 ; restore a1
                move.l  (a7)+, a0                 ; restore a0
                rts

                include initlib.s

                section data
bar
; colour data for each line of VU bar
                dc.w    $00ff, $00ff, $00ff, $00ff
                dc.w    $0000, $00ff, $00ff, $00ff
                dc.w    $00ff, $0000, $00ff, $00ff
                dc.w    $0000, $0000, $00ff, $00ff
                dc.w    $00ff, $00ff, $0000, $00ff
                dc.w    $0000, $00ff, $0000, $00ff
                dc.w    $00ff, $0000, $0000, $00ff
                dc.w    $0000, $0000, $0000, $00ff
                dc.w    $00ff, $00ff, $00ff, $0000
                dc.w    $0000, $00ff, $00ff, $0000
                dc.w    $00ff, $0000, $00ff, $0000
                dc.w    $0000, $0000, $00ff, $0000
                dc.w    $00ff, $00ff, $0000, $0000
                dc.w    $0000, $00ff, $0000, $0000
                dc.w    $00ff, $0000, $0000, $0000
                dc.w    $00ff, $0000, $0000, $0000

palette
                dc.w    $000, $023, $023, $024, $024, $025, $026, $026
                dc.w    $027, $027, $227, $327, $427, $527, $627, $727

music           incbin  instinct.xms              ; musicfile
