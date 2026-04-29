Tsukikomori SNSF - Technical Notes
==================================

Tsukikomori is a visual novel for the Super Famicom that was released in 1996 by Banpresto in Japan.
A sequel to the company's Gakkou de atta Kowai Hanashi (1995).

This game was developed by Pandora Box, and the sound driver was programmed by Jun Suzuki.

## Sound Test

This game includes a sound test feature.

Select any save file and open the settings menu to listen to the music and SFX.
You can also view the song titles there, written in kanji.

However, the songs used on the credits screen will not be unlocked unless you have reached the credits screen.
To unlock them quickly, just mash the A button through the story.

## Code Analysis Guide

This game appears to contain a kind of bytecode interpreter. Commands are dispatched at $C01F25.
Below are 4 commands that were useful for verifying the behavior of the sound test.

|Command |Function |Description                  |
|--------|---------|-----------------------------|
|$88     |$C0264C  |Load BGM and play            |
|$89     |$C02399  |Play SFX                     |
|$90     |$C02771  |Load BGM                     |
|$91     |$C027AF  |Play BGM (must be preloaded) |

The middleware-level sound driver code is identical to that of Gakkou de Atta Kowai Hanashi.

## Data Structure

TBA

## Sound Driver Code

When the transfer of the sound driver program and SFX data to the APU RAM is complete, the program counter reaches $C01EE4.
Therefore, I will write the SNSF driver code starting from that point.

```asm
    ; $9CE9: sound driver initialization (finished)
    ; $9F6A: sound driver soft reset (finished)
    ; $9F77: transfer SFX data (finished)
    ; $27E9: reset RAM data (finished)

    REP #$20
    LDA #$112F  ; low-byte: BGM #, high-byte: SFX # (use $xx35 for SFX without BGM)
    PHA
    SEP #$20    ; 8-bit accumulator

    LDA 1, S    ; BGM #
    JSR $7A41   ; transfer and start BGM (0: silence)

    LDA 2, S    ; SFX #
    BEQ loaded  ; skip if zero
    JSR $7A09   ; play SFX

loaded:
    LDA #$81
    STA $4200   ; enable vblank

loop:
    WAI
    BRA loop
```

All interrupt vectors except RESET must be patched to an empty `RTI`.
