The Blue Crystal Rod SNSF - Technical Notes
===========================================

The Blue Crystal Rod is a adventure game released in 1994 for Super Famicom only in Japan.
The game was developed and published by Namco.

Junko Ozawa is the composer of the game's soundtrack as well as the sound programmer.
Her driver is also used in other Namco SFC game titles such as Wagan Paradise.

## Sound Data

A list of addresses of sound data to be transferred to SHVC-SOUND is available at $00:9C6E.

|Index |Address |Bank |Comment|
|------|--------|-----|-------|
|0     |$8000   |$34  |Kingdom of Babylim|
|1     |$8EAB   |$34  |Sample Patch (Kingdom of Babylim, Tower of Druaga, Castle Town)|
|2     |$8000   |$3A  |Sumar Empire|
|3     |$8D50   |$3A  |Sample Patch (Beginning of Story, Sumar Empire, Competition, Epilogue)|
|4     |$8000   |$35  |Sample Patch (Elburz Cave)|
|5     |$93F7   |$35  |Hanging Garden|
|6     |$8000   |$33  |Common Data|
|7     |$8000   |$39  |Storm Mountains|
|8     |$9B3A   |$36  |SE|
|9     |$D803   |$37  |Castle Town|
|10    |$8ABB   |$36  |Beginning of Story|
|11    |$9311   |$36  |Tower of Druaga|
|12    |$8000   |$37  |Sample Patch (Underworld)|
|13    |$8000   |$38  |Opening|
|14    |$C7B2   |$36  |Temple of Ishtar|
|15    |$A775   |$39  |Epilogue|
|16    |$EA4C   |$38  |Competition|
|17    |$F6E0   |$38  |Ziggurat|
|18    |$D3BE   |$36  |Sample Patch (Temple of Ishtar, Ziggurat)|
|19    |$E280   |$3A  |File Selection|
|20    |$B71D   |$39  |Prologue|
|21    |$8B96   |$38  |Sample Patch (Opening, Prologue)|

One or more data transfer packages are placed at the address indicated by the pointer.
Note that multiple forwarding destinations can be defined for a single entry.

```
struct SoundDataTransferPackage {
    uint16_t size;          // 0 indicates the end of list
    uint16_t spc_address;
    uint8_t[] data;
};
```

## Initialization and threads

Transfer of driver code is done by calling $00:9197.
This is done relatively soon after the reset.

The game has a virtual thread-like coroutine mechanism,
which is done by frequently updating the stack pointer.
Setup for this is done in $80E9-8134.
The setup registers three threads in the system: $9CF1, $8329, and $B076.
In actual ROM, these values are expressed as -1 less than the above address.

What is important is that $9CF1 is a thread main for sound.
On the other hand, $8329 is the thread main for game progression.
This one can be used to write your own code for SNSF creation.

These threads are executed through the VBlank interrupt.
The game's NMI handler never returns.

Switching the execution context of the virtual thread is done by $82CA.

Before most music can be played, the common data block must be transferred.
Calling $A02A is an easy way to do this.

## Sound command (SNES high-level side)

The sound thread handles command requests for sound.

The sound command byte is stored in $9D.
The sound thread monitors the value and performs processing according to
the byte code value stored there.

A byte code value of 0xff means that nothing has been requested.
When the value is 0x80 or higher, the lower 7 bits are simply sent to the APUI01.

Otherwise, it is a combination of complex transfers and playback.
The function of each code value is hard-coded after $9D1B.
The jump table for each command is located at $9D2B.

These instructions can load music data and control the start and stop of a song,
thus sending multiple instructions to the SPC side.

A summary of these instructions is below.
I have only examined the sections I was interested in.

|Command |Comment|
|--------|-------|
|$00     |Common Data Transfer|
|$01     |ME: Babylim|
|$02     |Load 5th bank (Hanging Garden), play $32|
|$03     |Load 5th bank (Hanging Garden), play $33|
|$04     |ME: Hanging Garden|
|$05     |play $19|
|$06     |play $1E|
|$07     |play $1F|
|$08     |ME: Storm Mountains|
|$09     |Load 8th bank, then play $26|
|$0A     |play $27|
|$0B     |ME: Ishtar|
|$0C     |ME: Tower of Druaga|
|$0D     |ME: Castle Town|
|$0E     |ME: Sumar Empire|
|$0F     |ME: Competition|
|$10     |ME: Underworld|
|$11     |ME: Field of Niebana (Preloading Required)|
|$12     |ME: Druaga (Preloading Required)|
|$13     |ME: Lost Forest (with SE $10?)|
|$14     |SE: Water Drop (Elburz Cave)|
|$15     |ME: Ziggurat|
|$16     |ME: Heaven|
|$17     |ME: Begining of Story|
|$18     |ME: Fields of Niebana (Alternative?)|
|$19     |ME: Begining of Story (No Intro)|
|$1A     |SE: Rock of the Sky|
|$1B     |Unknown|
|$1C     |ME: File Selection|
|$1D     |ME: Prologue|
|$1E     |ME: Tower of Druaga (Loading Only?)|
|$1F     |FX: Fade Out|
|$20     |FX: Stop Song|
|$21     |ME: Opening (Loading Only?)|
|$22     |ME: Opening (?)|
|$23     |0|
|$24     |0|
|$25     |0|
|$26     |Direct Send|
|$27     |Direct Send|
|$28     |Direct Send|
|$29     |Direct Send|
|$2A     |Direct Send|
|$2B     |Direct Send|
|$2C     |Direct Send|
|$2D     |Direct Send|
|$2E     |Direct Send|
|$2F     |Direct Send|
|$30     |Direct Send|
|$31     |Direct Send|
|$32     |Direct Send|
|$33     |Direct Send|
|$34     |Direct Send|
|$35     |Direct Send|
|$36     |Direct Send|
|$37     |Direct Send|
|$38     |Direct Send|
|$39     |Direct Send|
|$3A     |Direct Send|
|$3B     |Direct Send|
|$3C     |Direct Send|
|$3D     |Direct Send|
|$3E     |Direct Send|
|$3F     |Direct Send|
|$40     |Unknown|
|$41     |ME: Epilogue (No Intro)|
|$42     |ME: Epilogue|
|$43     |Unknown|
|$44     |Unknown|
|$45     |Unknown|
|$46     |Unknown|
|$47     |Unknown|
|$48     |Unknown|
|$49     |Unknown|
|$4A     |Unknown|
|$4B     |Unknown|
|$4C     |Unknown|
|$4D     |Unknown|
|$4E     |Unknown|
|$4F     |NOP|
|$50     |Unknown|
|$51     |Unknown|
|$52     |NOP|
|$53     |NOP|
|$54     |NOP|
|$55     |NOP|
|$56     |NOP|
|$57     |NOP|
|$58     |NOP|
|$59     |NOP|
|$5A     |NOP|
|$5B     |NOP|
|$5C     |NOP|
|$5D     |NOP|
|$5E     |NOP|
|$5F     |NOP|
|$60     |Unknown|

## Sound driver code

```asm
loc_00833A:
	; load common sound data
	JSR $A02A

	; param 1: sound data offset (multiple of 3) to load (to disable, use $ff)
	LDA #$00
	XBA
	LDA $836C
	CMP #$FF
	BEQ loc_00835E

	; transfer 1
	TAX
	STX $B4
	JSR $A17D

	; param 2: sound data offset (multiple of 3) to load (to disable, use the same value as param 1)
	LDA #$00
	XBA
	LDA $836D
	CMP $836C
	BEQ loc_00835E

	; transfer 2
	TAX
	STX $B6
	JSR $A17D

loc_00835E:
	; param 3: command byte (to disable, use $ff)
	LDA $836E
	STA $9D

loc_008363:
	JSR $82CA       ; switch to next virtual thread (yield)
	BRA loc_008363

loc_00836D:
	db $ff,$ff,$ff,$ff
```
