Tsukikomori SNSF - Technical Notes
==================================

Tsukikomori is a visual novel for the Super Famicom that was released in 1996 by Banpresto in Japan.
A sequel to the company's Gakkou de atta Kowai Hanashi (1995).

This game was developed by Pandora Box, and the sound driver was programmed by Jun Suzuki.

## Data Structure

TBA

## Sound Driver Code

When the transfer of the sound driver program and SFX data to the APU RAM is complete, the program counter reaches $C01EE1.
Therefore, I will write the SNSF driver code starting from that point.

```asm
    ; $9CE9: sound driver initialization (finished)
    ; $9F6A: sound driver soft reset (finished)
    ; $9F77: transfer SFX data (finished)

    REP #$20
    LDA #$FF42  ; low-byte: BGM #, high-byte: SFX #
    PHA
    SEP #$20    ; 8-bit accumulator

    LDA 1, S    ; BGM #
    JSR $7A41   ; transfer and start BGM (0: silence)

    LDA 2, S    ; SFX #
    CMP #$FF
    BEQ loaded  ; skip if $FF
    JSR $9FD8   ; play SFX

loaded:
    LDA #$81
    STA $4200   ; enable vblank

loop:
    WAI
    BRA loop
```

All interrupt vectors except RESET must be patched to an empty `RTI`.
