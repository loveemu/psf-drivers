# Wizardry VI SNSF - Technical Notes

Wizardry VI: Bane of Cosmic Forge is a game that was released for the PC and
ported to the SNES in 1995. It was developed by Game Studio and published by ASCII.

The sound driver was programmed by Shuichi Ukai.

Down the World, also from ASCII, uses a compatible sound driver,
but the 65C816-side code may not be very similar.

## Understanding Coroutines

The game makes full use of a coroutine mechanism.

After a reset, the game performs a brief hardware initialization and coroutine setup,
then immediately stops in an infinite loop at $00:818D. All coroutines are executed via NMI.

Here are the functions needed to read and interpret these coroutines.

|Type |Address  |Description |Parameters |
|-----|---------|------------|-----------|
|JSR  |$00:8259 |(For NMI routine) execute coroutine |X: RAM address of the coroutine's stack pointer (starting from $100)|
|JSL  |$00:8263 |Wait for VBlank interrupt (i.e. yielding; The execution context returns to NMI) |n/a|
|JSR  |$00:8267 |Wait for VBlank interrupt (JSR version) |n/a|
|JSR  |$00:8278 |Add empty coroutine $8272 (used for initialization) |X: RAM address of the coroutine's stack pointer|
|JSR  |$00:828f |Set coroutine entrypoint |X: RAM address of the coroutine's stack pointer, A: coroutine function address **- 1** |

Nearly 10 coroutines are registered from the reset vector,
but only one of the following is needed to analyze the music

```asm
.00:811e
    ldx     #$0100  ; stack pointer address: $7e0100
    lda     #$8921  ; coroutine function: $80:8922 (main thread of the game)
    jsr     $828f   ; register the coroutine
```

Side note:
`jsl $82f1ad`, executed before registering the coroutines,
checks for SRAM corruption and initialization. It should be removed from SNSF.

## CPU-APU Communication Overview

The following high-level commands send a combination of messages.

|Type |Address  |Description |Parameters |
|-----|---------|------------|-----------|
|JSL  |$9e:8a4a |Transfer the sound driver code and some common data to APU |n/a |
|JSL  |$9e:8686 |Play SFX. Missing samples may be transferred before playback |A: SFX number ($00..89)  Note that some can only be played during exploration/battle|
|JSL  |$9e:8703 |Play BGM. Transfer the music sequence and samples and playback |A: song number ($00..24)|

The following lower-level functions are called.

|Type |Address  |Description |Parameters |
|-----|---------|------------|-----------|
|JSL  |$9e:8a02 |Start SFX 0x7e for some resets? |n/a |
|JSL  |$9e:8a1d |Fade-out sound immediately |n/a |
|JSL  |$9e:8af8 |Transfer sound data groups to APU |A: data group index ($00..95)|

### Data Groups

Data group table is at $a0:8000. Table item is in simple address/bank form.

A data group is one or more repetitions of the following entry.

```c
struct sound_data_entry {
    uint16_t size;          // 0: end of data group
    uint16_t apu_address;
    uint8_t data[size];
}
```

### BGM Entries

As for BGM, sound is played by executing command 0xe0 after some transfers.

BGM entries starts at $9e:8919. The format of the item is as follows.

```c
struct bgm_data_entry {
    uint8_t data_group[5];      // will be loaded before the BGM playback (0xff: none)
}
```

### SFX Entries

As for SFX, sound is played by executing command 0xe6 after some transfers.

SFX entries starts at $9e:8781. The format of the item is as follows.

```c
struct sfx_data_entry {
    uint8_t required_data_group;    // must be preloaded, or else no playback (0xff: none)
    uint8_t additional_data_group;  // will be loaded before the SFX playback (0xff: none)
    uint8_t sfx_seq_index;          // sequence index for the SFX (APUI01 value of command 0xe6)
}
```

SFX #0 and #1 are the door opening and closing sounds after the adventure begins,
but these are not included in the table and are hard coded.

## CPU-APU Low-Level Protocol

The following are messages interpreted by the S-SMP side.
Only messages of interest are listed below.

|Command (APUI00) |Description |Parameters |
|-----------------|------------|-----------|
|$e0 |Play BGM |APUI01: ? |
|$e1 |Volume fade-out |APUI01: fade-out length (0: immediately) |
|$e6 |Play SFX |APUI01: index of SFX |
|$ff |Send data to APU |(Summary) destination APU RAM address, size, data |

## Sound driver code

Below is the code to play the title screen music that exists in the original ROM.

```asm
.8d:8156
    lda     #0
    jsl     $9e8703     ; play the title BGM
```

Creating an infinite loop immediately after this code and cutting off any
unnecessary code before it results in SNSF.

If BGM is turned off in the settings screen, $7e:0923 is set to 1.
SFX is similarly set to 1 for $7e:0924.
Utilizing these flags, it may also be possible to create SNSFs to play SFX.
