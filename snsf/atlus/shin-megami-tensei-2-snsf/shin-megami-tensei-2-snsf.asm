check title "DIGITAL DEVIL STORY 2"

lorom
arch 65816

INIDISP = $2100
NMITIMEN = $4200
APUI01 = $2141

NullInterrupt = $0083A7
SoundTransferBootstrap = $3C8000
SoundExecuteOp = $3C8088

; Remove Atlus logo
org $008035
    nop #4

; After APU RAM and SNES WRAM initialization
; (SoundTransferBootstrap and SoundExecuteOp #0)
org $0080CF
SNSFMain:
    ; At this point, S-SMP is in the process of initializing and has not reached the main loop.
    ; Messages sent before initialization is complete will not be processed correctly and require waiting.
    ; After initialization is complete, wait for #1 to be written to $2141.
    ; In the actual game, there is no explicit waiting process for initialization.

    jsr InitScreen
    wai
    wai

    sep #$20
    lda SNSFFirstCmd
    jsl SoundExecuteOp

    lda SNSFSecondCmd
    beq .end
    jsl SoundExecuteOp

.end
    ; The STP instruction would be best for use in SNSF, but it freezes SNSF9x.
    ; We have no choice but to enable interrupts and enter low-power mode with the WAI instruction.
    ;jsr InitScreen

..halt
    wai
    bra ..halt

    fill align 4

SNSFFirstCmd:
    db $86 ; $86 Title Demo
SNSFSecondCmd:
    db $00 ; $8b Title without intro

; ASM hint:
; The pointer table for sound data is located at $3C8218 and is referenced from $3C80DD.

    fill align 4

InitScreen:
  php
  sep #$20
  lda #$00
  sta INIDISP
  sta $0943
  lda #$81
  sta NMITIMEN
  sta $0900
  plp
  rts

org $00FFEA : dw NullInterrupt ; Native-mode NMI
org $00FFEE : dw NullInterrupt ; Native-mode IRQ
org $00FFFA : dw NullInterrupt ; Nativtion-mode NMI
org $00FFFE : dw NullInterrupt ; Nativtion-mode IRQ
