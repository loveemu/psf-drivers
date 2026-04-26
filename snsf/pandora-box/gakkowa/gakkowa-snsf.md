Gakko de Atta Kowai Hanashi SNSF - Technical Notes
==================================================

Gakkou de atta Kowai Hanashi is a visual novel for the Super Famicom that was released in 1995 by Banpresto in Japan.

This game was developed by Pandora Box, and the sound driver was programmed by Jun Suzuki.
Tsukikomori, which was developed using the same game system, also uses the same driver.

## Data Structure

TBA

## Sound Driver Code

The following is an excerpt from the startup routine located at $C0011E.

```asm
    SEP #$20    ; 8-bit accumulator
    LDA #1
    JSR $2C1E   ; set persistent sample IDs
    JSR $55C9   ; transfer and start sound driver
    JSR $2BA9   ; transfer all SFXs

    STZ $0B3A   ; default is MONO! (1: stereo, 0: mono)
    JSR $2BCD   ; commit stereo/mono
```

Let's modify the second half.
First, change the code to set the output to stereo, and then play the music and/or SFX.

```
    LDA #1      ; stereo
    STA $0B3A
    JSR $2BCD   ; commit stereo/mono

    REP #$20
    LDA #$FF42
    PHA
    SEP #$20

    LDA 1, S
    JSR $2B85   ; transfer and start BGM (0: silence)

    LDA 2, S
    CMP #$FF
    BEQ loaded  ; skip if $FF
    JSR $58AC   ; play SFX

loaded:
    LDA #$81
    JSR $049F   ; enable vblank

loop:
    WAI
    BRA loop
```

All interrupt vectors except RESET must be patched to an empty `RTI`.
