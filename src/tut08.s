                jsr     initialise
              
                move.l  #screen1, d0             ; put screen1 address in d0
                clr.b   d0                       ; put on 256 byte boundary  
                move.l  d0, next                 ; store address
                add.l   #32000, d0               ; next screen area
                move.l  d0, last                 ; store address
              
                movem.l font+2, d0-d7
                movem.l d0-d7, $ff8240           ; palette moved in

main
                move.w  #37, -(sp)               ; wait vbl
                trap    #14
                addq.l  #2, sp  
              
                move.l  next, d0
              
                clr.b   $ffff820d               ; clear STe extra bit  
                lsr.l   #8, d0    
                move.b  d0, $ffff8203           ; put in mid screen address byte
                lsr.w   #8, d0
                move.b  d0, $ffff8201           ; put in high screen address byte
              
                move.w  #$707, $ff8240
              
                cmp     #0, font_counter        ; check if new character in message
                bne     has_character           ; if not, skip get new character
                
                move.w  #4, font_counter        ; reset font_counter
; we need to point to a new character in the font

                move.l  message_pointer, a0     ; pointer into the message
                clr.l   d0                      ; clear, just to be sure
                move.b  (a0), d0                ; put letter ascii value in d0
              
                cmp     #0, d0                  ; end of message?
                bne     not_end                 ; if not, branch
                
                move.l  #message, message_pointer  ; reset message_pointer
                move.l  message_pointer, a0
                clr.l   d0                      ; clear, just to be sure
                move.b  (a0), d0                ; put letter ascii value in d0
  
not_end
; now we have a character in d0 for sure
                add.l   #1, message_pointer     ; point to next character
                
                add.b   #-$20, d0               ; align ascii with font number
                divu    #10, d0                 ; 10 letters per row
                
                move.w  d0, d1                  ; d1 contains y value
                swap    d0
                move.w  d0, d2                  ; d2 contains x value
                
                mulu    #16, d2                 ; 16 bytes for each letter
                mulu    #32, d1                 ; 32 lines per row
                mulu    #160, d1                ; 160 bytes per row
                
                move.l  #font+34, a0            ; put font screen start in a0
                
                add.l   d2, d1                  ; add x and y value together
                add.l   d1, a0                  ; a0 points to correct letter
                
                move.l  a0, font_address        ; store calculated pointer
    
has_character
                add.w   #-1, font_counter  
              
                move.l  last, a0
                move.l  next, a1                ; load screens
                move.l  a1, last                ; and flip them for next time around
                move.l  a0, next                ; doubble buffering :)
                move.l  font_address, a2        ; font address
              
                move.l  #31, d1                 ; 32 lines to scroll
                move.l  #18, d0                 ; 19 16 pixel clusters + font part
scroll
                move.b  1(a0), (a1)
                move.b  3(a0), 2(a1)
                move.b  5(a0), 4(a1)
                move.b  7(a0), 6(a1)            ; 8 pixels moved
                move.b  8(a0), 1(a1)            ; watch carefully!
                move.b  10(a0), 3(a1)          
                move.b  12(a0), 5(a1)         
                move.b  14(a0), 7(a1)           ; first 4 word area filled
              
                add.l   #8, a0                  ; jump to next 4 word area
                add.l   #8, a1                  ; jump to next 4 word area
                dbf     d0, scroll              ; keep moving 16 pixel clusters
              
                move.l  #18, d0                 ; reset loop counter
                
                move.b  1(a0), (a1)
                move.b  3(a0), 2(a1)
                move.b  5(a0), 4(a1)
                move.b  7(a0), 6(a1)            ; 152 pixels scrolled
              
                move.b  (a2), 1(a1)             ; now last 8 pixels from font
                move.b  2(a2), 3(a1)
                move.b  4(a2), 5(a1)
                move.b  6(a2), 7(a1)            ; 8 pixels from font
                
                add.l   #8, a0                  ; point to beginning of next line
                add.l   #8, a1                  ; point to beginning of next line
                add.l   #160, a2                ; next line of font
                dbf     d1, scroll              ; do another line
              
                add.l   #1, font_address        ; next byte in font
                cmp     #2, font_counter        ; see if it's time to change 
                bne     font_increment
                add.l   #6, font_address        ; align to next 16 pixels
font_increment

                move.w  #$0, $ff8240
              
                cmp.b   #$39, $fffc02           ; space pressed?
                bne     main                    ; if not, repeat main
              
                jsr     restore
                
                clr.l   -(a7)
                trap    #1
              
                include  initlib.s

                section data
  
font            incbin font.pi1

screen          dc.l   0

font_address    dc.l   0
   
font_counter    dc.w   0

message         dc.b   "A COOL SCROLLER!   MOVING 8 PIXELS PER VBL "
                dc.b   "AND USING DOUBBLE BUFFERING    ", 0

message_pointer dc.l   message

next            dc.l   0
last            dc.l   0

               section bss
  
               ds.b    256
screen1        ds.b    32000
screen2        ds.b    32000

