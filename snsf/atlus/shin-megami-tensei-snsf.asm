check title "DIGITAL DEVIL STORY  "

lorom
arch 65816

NullInterrupt = $008686
ExecSoundOp = $0C807A

; Remove Atlus logo
org $008035
    nop #4

; After APU RAM and SNES WRAM initialization
org $008099
SNSFMain:
    sep #$20
    lda SNSFFirstCmd
    jsl ExecSoundOp

    lda SNSFSecondCmd
    beq .end
    jsl ExecSoundOp

.end
    stp

    fill align 4

SNSFFirstCmd:
    db $44
SNSFSecondCmd:
    db $40

.end
    stp

    fill align 4

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

org $00FFEA : dw NullInterrupt ; Native-mode NMI
org $00FFEE : dw NullInterrupt ; Native-mode IRQ
org $00FFFA : dw NullInterrupt ; Nativtion-mode NMI
org $00FFFE : dw NullInterrupt ; Nativtion-mode IRQ
