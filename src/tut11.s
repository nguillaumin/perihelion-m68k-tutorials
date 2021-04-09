x_speed         equ     2                         ; how many x coord to move each VBL
y_speed         equ     1                         ; how many y coord to move each VBL

                jsr     initialise

; pre-shifting sprite
                move.l  #spr_dat, a0              ; original sprite data
                add.l   #34, a0                   ; skip palette
                move.l  #sprite, a1               ; storage of pre-shifted sprite

                move.l  #32-1, d0                 ; 32 scan lines per sprite
first_sprite
                move.l  (a0)+, (a1)+              ; move from original to pre-shifted
                move.l  (a0)+, (a1)+
                move.l  (a0)+, (a1)+
                move.l  (a0)+, (a1)+              ; 32 pixels moved
                add.l   #8, a1                    ; jump over end words
                add.l   #144, a0                  ; jump to next scan line
                dbf     d0, first_sprite
; the picture sprite has been copied to first position in pre-shift

                move.l  #sprite, a0               ; point to beginning of storage area
                move.l  #sprite, a1               ; point to beginning of storage area
                add.l   #768, a1                  ; point to next sprite position

                move.l  #15-1, d1                 ; 15 sprite positions left
positions
                move.l  #32-1, d2                 ; 32 scan lines per sprite
line
                move.l  #4-1, d3                  ; 4 bit planes
plane
                move.w  (a0), d0                  ; move one word
                roxr    #1, d0                    ; pre-shift
                move.w  d0, (a1)                  ; put it in place

                move.w  8(a0), d0                 ; move one word
                roxr    #1, d0                    ; pre-shift
                move.w  d0, 8(a1)                 ; put it in place

                move.w  16(a0), d0                ; move one word
                roxr    #1, d0                    ; pre-shift
                move.w  d0, 16(a1)                ; put it in place

                add.l   #2, a0                    ; next bit plane, also clears X flag
                add.l   #2, a1                    ; next bit plane

                dbf     d3, plane

                add.l   #16, a0                   ; next scan line
                add.l   #16, a1                   ; next scan line

                dbf     d2, line

                dbf     d1, positions
; pre-shift of sprite done, all 16 sprite possitions saved in sprite


; pre-shifting mask
                move.l  #spr_dat, a0
                add.l   #34+160*32, a0            ; skip palette and sprite
                move.l  #mask, a1                 ; load up mask part

                move.l  #32-1, d0                 ; 32 scan lines per sprite
first_mask
                move.l  (a0)+, (a1)               ; move from original to pre-shifted
                not.l   (a1)+                     ; invert the mask data
                move.l  (a0)+, (a1)
                not.l   (a1)+                     ; invert the mask data
                move.l  (a0)+, (a1)
                not.l   (a1)+                     ; invert the mask data
                move.l  (a0)+, (a1)               ;
                not.l   (a1)+                     ; invert the mask data
                move.l  #$ffffffff, (a1)+         ;  fill last two words...
                move.l  #$ffffffff, (a1)+         ;  ... with all 1's

                add.l   #144, a0                  ; jump to next scan line
                dbf     d0, first_mask
; the picture mask has been copied to first position in pre-shift

                move.l  #mask, a0                 ; point to beginning of storage area
                move.l  #mask, a1                 ; point to beginning of storage area
                add.l   #768, a1                  ; point to next mask position

                move.l  #15-1, d1                 ; 15 sprite positions left
positions_mask
                move.l  #32-1, d2                 ; 32 scan lines per sprite
line_mask
                move.l  #4-1, d3                  ; 4 bit planes
plane_mask
                move.w  (a0), d0                  ; move one word
                roxr    #1, d0                    ; pre-shift
                or.w    #%1000000000000000, d0    ; make sure most significant bit set
                move.w  d0, (a1)                  ; put it in place

                move.w  8(a0), d0                 ; move one word
                roxr    #1, d0                    ; pre-shift
                move.w  d0, 8(a1)                 ; put it in place

                move.w  16(a0), d0                ; move one word
                roxr    #1, d0                    ; pre-shift
                move.w  d0, 16(a1)                ; put it in place

                add.l   #2, a0                    ; next bit plane, clears X flag (bad)
                add.l   #2, a1                    ; next bit plane

                dbf     d3, plane_mask

                add.l   #16, a0                   ; next scan line
                add.l   #16, a1                   ; next scan line

                dbf     d2, line_mask

                dbf     d1, positions_mask
; pre-shift of mask done, all 16 sprite possitions saved in mask

                movem.l bg+2, d0-d7
                movem.l d0-d7, $ff8240

                move.l  #bg+34, a0                ; pixel part of background
                move.l  $44e, a1                  ; put screen memory in a1
                move.l  #7999, d0                 ; 8000 longwords to a screen
pic_loop
                move.l  (a0)+, (a1)+              ; move one longword to screen
                dbf     d0, pic_loop              ; background painted

                jsr     save_background           ; something in restore buffer

                move.l  $70, old_70               ; backup $70
                move.l  #main, $70                ; put in main routine

                move.w  #7, -(a7)
                trap    #1
                addq.l  #2, a7                    ; wait keypress

                move.l  old_70, $70               ; restore old $70

                jsr     restore

                clr.l   -(a7)
                trap    #1                        ; exit

main
                movem.l d0-d7/a0-a6, -(a7)        ; backup registers

                jsr     restore_background
                jsr     move_sprite
                jsr     save_background
                jsr     apply_mask
                jsr     put_sprite

                movem.l (a7)+, d0-d7/a0-a6        ; restore registers

                rte

move_sprite
; moves the sprite one pixel in x and y
; see if any headings need to be changed
                cmp     #319-32-x_speed+1, x_coord
                blt     x_right_ok                ; see if x is < 319-32 for width
                move.w  #0, x_heading             ; if x >=319, change heading
x_right_ok

                cmp     #0, x_coord
                bgt     x_left_ok                 ; see if x is > 0
                move.w  #1, x_heading             ; if x <=0, change heading
x_left_ok

                cmp     #199-32-y_speed+1, y_coord
                blt     y_low_ok                  ; see if y is < 199-32 for lines
                move.w  #0, y_heading             ; if y >=199, change heading
y_low_ok

                cmp     #0, y_coord
                bgt     y_high_ok                 ; see if y is > 0
                move.w  #1, y_heading             ; if y <=0, change heading
y_high_ok
; all eventual heading changes now made

; move sprite coordinates (change coordinates)
                cmp     #0, x_heading             ; check x heading
                bne     x_move_right              ; if 1, move right, otherwise left
                sub.w   #x_speed, x_coord         ; move sprite left
                bra     x_move_done               ; done moving sprite in x
x_move_right
                add.w   #x_speed, x_coord         ; move sprte right
x_move_done

                cmp     #0, y_heading             ; check y heading
                bne     y_move_down               ; if 1, move down, otherwise up
                sub.w   #y_speed, y_coord         ; move sprite up
                bra     y_move_done               ; done moving sprite in y
y_move_down
                add.w   #y_speed, y_coord         ; move sprte down
y_move_done
; finnished moving sprite

                rts

apply_mask
; applies the mask to the background
                jsr     get_coordinates
                move.l  #mask, a0
                mulu    #768, d0                  ; multiply position with size
                add.l   d0, a0                    ; add value to mask pointer

                move.l  #32-1, d7                 ; mask is 32 scan lines
maskloop
                rept    6                         ; mask is 6*4 bytes width
                move.l  (a0)+, d0                 ; mask data in d0
                move.l  (a1), d1                  ; background data in d1
                and.l   d0, d1                    ; and mask and picture data
                move.l  d1, (a1)+                 ; move masked data to background
                endr
                add.l   #136, a1                  ; next scan line
                dbf     d7, maskloop

                rts

put_sprite
; paints the sprite to the screen
                jsr     get_coordinates
                move.l  #sprite, a0
                mulu    #768, d0                  ; multiply position with size
                add.l   d0, a0                    ; add value to sprite pointer

                move.l  #32-1, d7                 ; sprite is 32 scan lines
bgloop
                rept    6                         ; sprite is 6*4 bytes width
                move.l  (a0)+, d0                 ; sprite data in d0
                move.l  (a1), d1                  ; background data in d1
                or.l    d0, d1                    ; or sprite and background data
                move.l  d1, (a1)+                 ; move ored sprite data to background
                endr
                add.l   #136, a1
                dbf     d7, bgloop

                rts

save_background
; saves the background into bgsave
                jsr     get_coordinates
                move.l  #bgsave, a0

                move.l  #32-1, d7                 ; sprite is 32 scan lines
bgsaveloop
                rept    6                         ; sprite is 6*4 bytes width
                move.l  (a1)+, (a0)+              ; copy background to save buffer
                endr
                add.l   #136, a1                  ; next scan line
                dbf     d7, bgsaveloop

                rts

restore_background
; restores the background using data from bgsave
                jsr     get_coordinates
                move.l  #bgsave, a0

                move.l  #32-1, d7                 ; sprite is 32 scan lines
bgrestoreloop
                rept    6                         ; sprite is 6*4 bytes width
                move.l  (a0)+, (a1)+              ; copy save buffer to background
                endr
                add.l   #136, a1                  ; next scan line
                dbf     d7, bgrestoreloop

                rts

get_coordinates
; makes a1 point to correct place on screen
; sprite position in d0.b
                move.l  $44e, a1                  ; screen memory in a1
                move.w  y_coord, d0               ; put y coordinate in d0
                mulu    #160, d0                  ; 160 bytes to a scan line
                add.l   d0, a1                    ; add to screen pointer
                move.w  x_coord, d0               ; put x coordinate in d0
                divu.w  #16, d0                   ; number of clusters in low, bit in high
                clr.l   d1                        ; clear d1
                move.w  d0, d1                    ; move cluster part to d1
                mulu.w  #8, d1                    ; 8 bytes to a cluster
                add.l   d1, a1                    ; add cluster part to screen memory
                clr.w   d0                        ; clear out the cluster value
                swap    d0                        ; bit to alter in low part of d0

                rts

                include initlib.s

                section data
x_coord         dc.w    0
y_coord         dc.w    0
x_heading       dc.w    1
y_heading       dc.w    1

spr_dat         incbin  sprite.pi1
bg              incbin  autumn.pi1
old_70          dc.l    0

                section bss
sprite          ds.l    3072                      ; 32/2+8*32 bytes 16 positions / 4 for long
mask            ds.l    3072                      ; same as above
bgsave          ds.l    192                       ; 32/2+8*32 bytes / 4 for long
