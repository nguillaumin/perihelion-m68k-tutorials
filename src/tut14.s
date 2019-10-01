                jsr     initialise

                move.l  #palette, a0              ; pointer to palette
                movem.l (a0)+, d0-d7              ; palette in d0-d7
                movem.l d0-d7, $ff8240            ; apply palette

                move.l  #ym_file, a0              ; start of ym file
                move.l  12(a0), frames            ; store number of frames

                add.l   #34, a0                   ; beginning of text

song_name
                cmp.b   #0, (a0)+                 ; search for 0
                bne     song_name
comment
                cmp.b   #0, (a0)+                 ; search for 0
                bne     comment
song_data
                cmp.b   #0, (a0)+                 ; search for 0
                bne     song_data

                move.l  a0, music                 ; skipped 3 zero, store address

                move.l  $70, -(a7)                ; backup $70
                move.l  #main, $70                ; start main routine
                move.w  #7, -(a7)
                trap    #1
                addq.l  #2, a7                    ; wait keypress
                move.l  (a7)+, $70                ; restore $70

                jsr     restore

                clr.l   -(a7)
                trap    #1                        ; exit


main
                movem.l d0-d7/a0-a6, -(a7)        ; backup registers

                move.l  music, a0                 ; pointer to current music data
                moveq.l #0, d0                    ; first yammy register
play
                move.b  d0, $ff8800               ; write to register
                move.b  (a0), $ff8802             ; write music data
                add.l   frames, a0                ; jump to next register in data
                addq.b  #1, d0                    ; next register
                cmp.b   #16, d0                   ; see if last register
                bne     play                      ; if not, write next one

                addq.l  #1, music                 ; next set of registers
                addq.l  #1, play_time             ; 1/50th second play time

                move.l  frames, d0
                move.l  play_time, d1
                cmp.l   d0, d1                    ; see if at end of music file
                bne     no_loop
                sub.l   d0, music                 ; beginning of music data
                move.l  #0, play_time             ; reset play time
no_loop
                jsr     vu_bars                   ; paint the vu bars

                movem.l (a7)+, d0-d7/a0-a6        ; restore registers
                rte

; put in VU bars
vu_bars
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
                move.b  #8, $ff8800               ; chanenl a volume
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

                rts

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
music           dc.l    0                         ; address of music data
frames          dc.l    0                         ; how many frames of music data
play_time       dc.l    0                         ; how many VBL's has elapsed

ym_file         incbin  jamblv1.ym

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
