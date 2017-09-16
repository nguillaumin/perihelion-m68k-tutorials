                jsr     initialise
               
                movem.l font+2, d0-d7
                movem.l d0-d7, $ff8240
                
                move.w  #2, -(a7)                ; get physbase
                trap    #14
                addq.l  #2, a7
                move.l  d0, screen               ; store screen memory
 
main
                move.w  #37, -(sp)               ; wait vbl
                trap    #14
                addq.l  #2, sp
               
                cmp     #0, font_counter         ; check if new character in message
                bne     has_character            ; if not, skip get new character
                
                move.w  #2, font_counter         ; reset font_counter
; we need to point to a new characetr in the font

                move.l  message_pointer, a0      ; pointer into the message
                clr.l   d0                       ; clear, just to be sure
                move.b  (a0), d0                 ; put letter ascii value in d0

                cmp     #0, d0                   ; end of message?
                bne     not_end                  ; if not, branch
                
                move.l  #message, message_pointer; reset message_pointer
                move.l  message_pointer, a0
                clr.l   d0                       ; clear, just to be sure
                move.b  (a0), d0                 ; put letter ascii value in d0
 
not_end
; now we have a character in d0 for sure
               add.l    #1, message_pointer      ; point to next character
              
               add.b    #-$20, d0                ; align ascii with font number
               divu     #10, d0                  ; 10 letters per row
               
               move.w   d0, d1                   ; d1 contains y value
               swap     d0
               move.w   d0, d2                   ; d2 contains x value
              
               mulu     #16, d2                  ; 16 bytes for each letter
               mulu     #32, d1                  ; 32 lines per row
               mulu     #160, d1                 ; 160 bytes per row
              
               move.l   #font+34, a0             ; put font screen start in a0
              
               add.l    d2, d1                   ; add x and y value together
               add.l    d1, a0                   ; a0 points to correct letter
              
               move.l   a0, font_address         ; store calculated pointer
  
has_character
               add.w    #-1, font_counter 
              
               move.l   screen, a0
               move.l   screen, a1
               move.l   font_address, a2
               add.l    #8, a1                   ; put a1 16 pixels ahead of a0
              
               move.l   #31, d1                  ; 32 lines to scroll
               move.l   #18, d0                  ; 19 16 pixel clusters + font part
scroll
               move.w   (a1)+, (a0)+ 
               move.w   (a1)+, (a0)+ 
               move.w   (a1)+, (a0)+
               move.w   (a1)+, (a0)+             ; 16 pixels moved
               dbf      d0, scroll               ; keep moving 16 pixel clusters
               
               move.l   #18, d0                  ; reset loop counter
               
               move.w   (a2), (a0)+
               move.w   2(a2), (a0)+
               move.w   4(a2), (a0)+             ; 16 pixels of the font 
               move.w   6(a2), (a0)+             ; character moved in 
               add.l    #8, a1                   ; increment screen pointer, align with a0
               add.l    #160, a2                 ; next line of font
               
               dbf      d1, scroll               ; do another line
               
               add.l    #8, font_address         ; move 16 pixels forward in font
               
               cmp.b    #$39, $fffc02            ; space pressed?
               bne      main                     ; if not, repeat main
               
               jsr      restore
 
               clr.l    -(a7)
               trap     #1

               include initlib.s

               section data

font           incbin  font.pi1
screen         dc.l    0
font_address   dc.l    0
font_counter   dc.w    0

message        dc.b    "A  COOL  SCROLLER!    BUT  A  BIT  FAST, "
               dc.b    "  SCROLLING  16  PIXELS  EACH  VBL."
               dc.b    "    THAT'S 2.5 SCREENS EACH SECOND!"
               dc.b    "             ", 0

message_pointer dc.l   message