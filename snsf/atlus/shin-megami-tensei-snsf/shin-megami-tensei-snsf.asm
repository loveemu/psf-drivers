check title "DIGITAL DEVIL STORY  "

lorom
arch 65816

INIDISP = $2100
NMITIMEN = $4200

NullInterrupt = $008686
SoundTransferDriver = $0C8000
SoundExecuteOp = $0C807A

; Remove Atlus logo
org $008035
    nop #4

; After APU RAM and SNES WRAM initialization
org $008099
SNSFMain:
    sep #$20
    lda SNSFFirstCmd
    jsl SoundExecuteOp

    lda SNSFSecondCmd
    beq .end
    jsl SoundExecuteOp

.end
    ; The STP instruction would be best for use in SNSF, but it freezes SNSF9x.
    ; We have no choice but to enable interrupts and enter low-power mode with the WAI instruction.
    jsr InitScreen

..halt
    wai
    bra ..halt

    fill align 4

SNSFFirstCmd:
    db $44
SNSFSecondCmd:
    db $40

; Commands:
;    $38 Demon Appears (without FX)
;    $39 Demon Appears
;    $3a Demon Appears
;    $3b Demon Appears
;    $3c Battle
;    $3d Level Up
;    $3f Demon Appears
;    $40 Fusion (preloading $44 Jakyou is required)
;    $42 Demon Appears
;    $43 Demon Appears
;    $44 Jakyou

    fill align 4

; The following code is copied from $0FCA7E
InitScreen:
  php
  sep #$20
  lda #$00
  sta INIDISP
  sta $0f43
  lda #$81
  sta NMITIMEN
  sta $0f00
  plp
  rts

org $00FFEA : dw NullInterrupt ; Native-mode NMI
org $00FFEE : dw NullInterrupt ; Native-mode IRQ
org $00FFFA : dw NullInterrupt ; Nativtion-mode NMI
org $00FFFE : dw NullInterrupt ; Nativtion-mode IRQ
