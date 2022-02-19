; The Scared Scroll - game edition
; (not to confuse with "The Sacred Scroll")

; 2021-12-25, F#READY

; R1 game version
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

STICK0      = $0278
STRIG0      = $0284
HITCLR      = $d01e
           
hposm0_tab  = $4000

            org $80

            dta $2c         ; bit adr
SCROL_PTR   dta a($b000)

            ldx #text_end-text_msg
fill_page
            lda text_msg-1,x
            sta $b020,x
            sta $b060,x
            sta $b0a0,x
            dex
            bne fill_page

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

; move tank

            lda STICK0
            cmp #7
            bne no_right
            inc TANK_CURX
no_right
            cmp #11
            bne no_left
            dec TANK_CURX
no_left

            lda STRIG0
            tax
            bne no_fire
PREV_TRIG   = *+1            
            lda #1
            beq no_fire
            
            lda #$e8
            ;sta $d201
            sta $d200
TANK_CURX   = *+1            
            lda #128              ;tank_curx
            clc
            adc #2
            sta hposm0_tab+4
            sta hposm0_tab+5
            
no_fire
            stx prev_trig

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

            ldx #16
scan_bullits            
            lda $40a4,x ; 40a9
            lsr
            lsr
            lsr
            tay
            lda #0
            sta (SCROL_PTR),y            
skip_space            
            dex
            bpl scan_bullits

hit_done

            ldx #0
check_end_game
            lda $b000,x
            bne chars_left
            inx
            bne check_end_game  

flash
            lda 20
            sta $d01a
            bvc flash

chars_left
            lda #$9f
            sta $d200
no_hit            
            jmp loop

text_msg    dta d'we all love scrollers'
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

