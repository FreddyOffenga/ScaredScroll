; The Scared Scroll
; (not to confuse with "The Sacred Scroll")

; 2021-12-25, F#READY

; R1 release v1
; v5
; - removed shot count, added color, added direction change, 255 bytes
; - custom DL without setting mode, 245 bytes
; v4.1 - inc tank instead of add, 251 bytes
; v4 - drastic change, simplified tank move logic: 256 bytes! :)
; v3 - some optimisations: 305 (move to zp didn't help much)
; v2 - complete version, not optimised: 312 bytes
; v1 - first concept version: 205 bytes

HPOSP0      = $d000
HPOSP1      = $d001
HPOSM0      = $d004
GRAFP1      = $d00e
GRAFM       = $d011
RANDOM      = $d20a
HSCROL      = $d404
WSYNC       = $d40a
VCOUNT      = $d40b

HITCLR      = $d01e
           
hposm0_tab  = $4000

            org $8000

            ldx #text_end-text_msg
fill_page
            lda text_msg-1,x
            sta $b020,x
            sta $b060,x
            sta $b0a0,x
            dex
            bne fill_page

            stx 19
            inx
            stx GRAFM

            lda #$ea
            sta $d201
            sta 705
            
loop

wait_top
            lda VCOUNT
            bne wait_top
            sta HITCLR

            ldx #208
fill_pf
            lda hposm0_tab,x
            sta WSYNC
            sta HPOSM0
            txa
            sta $d012
;            lsr
;            lsr
            eor #%11000000
            sta $d017

            dex
            bne fill_pf

; poor man's vbi here

            stx $d200

            lda TANK_CURX
            sta HPOSP1

            ldx #7
show_shooter            
            lda shooter,x
            sta WSYNC
            sta GRAFP1
            dex
            bpl show_shooter

            lda 20
            and #7
            bne smooth
            inc scrol_adr
            inc SCROL_PTR
smooth
            eor #7
            sta HSCROL

            lda 19
            beq tank_done

; move tank

            lda TANK_CURX
            clc
            adc TANK_DIR
            sta TANK_CURX                        

            cmp #$c4
            beq max_x

TANK_MIN_X  = *+1
            cmp #0
            bcs no_min_x
max_x
            lda #$2c
            sta TANK_MIN_X

            lda TANK_DIR
            eor #255
            clc
            adc #1
            sta TANK_DIR

no_min_x
            ;lda 20
            ;and #3
            ;bne no_fire
            
            lda RANDOM
            and #%00011111
            bne no_fire
            
            lda #$e8
            ;sta $d201
            sta $d200
TANK_CURX   = *+1            
            lda #0              ;tank_curx
            clc
            adc #2
            sta hposm0_tab+4
            sta hposm0_tab+5
            
no_fire

tank_done

; move missiles up

            ldx #0
moveup            
            lda hposm0_tab,x
            sta hposm0_tab+3,x
            dex
            bne moveup
                        
            lda HPOSP0
            beq no_hit

            ldx #6
scan_bullits            
            lda $40a7,x ; 40a9
            lsr
            lsr
            lsr
            tay
            lda #0

;SCROL_PTR   = *+1
            sta (SCROL_PTR),y   ;$b000,y

            lda #$9f
            sta $d200
            
            dex
            bpl scan_bullits

no_hit            
            jmp loop

text_msg    dta d'we all love', 192, 'scrollers'
text_end

;hack_dl
DL_ADR
            dta $70,$70,$70
            dta $47+$10     ; enable scroll
scrol_adr            
            dta a($b000+4)  ; offset 4, so that collision matches with 4 chars less
            dta $41,a(DL_ADR)
shooter
            dta %00000000
            dta %11000110
            dta %11111110
            dta %10111010
            dta %00111000
            dta %00010000
            dta %00010000

            org $022f
            dta 35
            dta a(DL_ADR)

            org $f0
TANK_DIR    dta 1
SCROL_PTR   dta a($b000)
