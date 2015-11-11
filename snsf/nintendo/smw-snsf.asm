.LOROM

; ## Known Issues
; 
; * Slowdown caused by uninitialized vibrato parameter (Castle Level, etc.)

; Cartridge header should be copied from the original ROM
.SNESHEADER
;ID    "    "
 NAME  "SUPER MARIOWORLD     "
 LOROM
 SLOWROM
 CARTRIDGETYPE $02
 ROMSIZE $09
 SRAMSIZE $01
 COUNTRY $01
 LICENSEECODE $01
 VERSION $00
.ENDSNES

.MEMORYMAP
 SLOTSIZE $8000
 DEFAULTSLOT 0
 SLOT 0 $8000
.ENDME

.ROMBANKSIZE $8000
.ROMBANKS 1

.SNESNATIVEVECTOR               ; Define Native Mode interrupt vector table
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI VBlank
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Start
  IRQBRK $0	; used by DMA
.ENDEMUVECTOR


.BANK 0 SLOT 0

.ORG $0000
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $008000
	.db	$01
.DEFINE PARAM_SOUND_BANK = $008001
	.db	$00
.DEFINE PARAM_SONG_TYPE = $008002
	.db	$00
.DEFINE PARAM_SONG_FLAGS = $008003
	.db	$00
.DEFINE PARAM_RESERVED = $008004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $008006
	.dw	$0000

; setup routine derived from the original setup ($80/8004)
Start:
	sei

	; disable interrupt
	stz	$4200

	; clear APU ports
	stz	$2140
	stz	$2141
	stz	$2142
	stz	$2143

	clc
	xce
	rep	#$38

	; set direct page
	lda	#0
	tcd

	; set stack pointer
	lda	#$1ff
	tcs

	sep	#$30

	lda	#$6b
	sta	$7f8182

	jsr	SetupSound

	; enable interrupt
	lda	#$80
	sta	$4200

loc_MainLoop:
	wai
	bra	loc_MainLoop

.ENDS

.ORG $016A
.SECTION "VBLANK" SEMIFREE

SetupSound:
	; transfer SPC program
	jsr	$80e8

	; zero memory
	stz	$0100
	stz	$0109
	jsr	$8a4e

	; transfer common set
	jsr	$80fd

	; transfer sound set
	lda	PARAM_SOUND_BANK
	jsr	LoadMusicSet

	; write APU port
	lda	PARAM_SONG
	ldy	PARAM_SONG_TYPE
	jsr	PlaySound

	; additional effects
	lda	PARAM_SONG_FLAGS
	bit	#1
	beq	loc_TestSongFlag2

	; turn off Yoshi Drum channel
	lda	#3
	sta	$1dfa

loc_TestSongFlag2:
	lda	PARAM_SONG_FLAGS
	bit	#2
	beq	loc_TestSongFlag3

	; Time is running out!
	lda	#$80
	sta	$1df9

loc_TestSongFlag3:
	rts

LoadMusicSet:
	pha
	jsr	$8a4e
	pla
	asl
	tax
	jsr	(jpt_LoadMusicSet, x)
	rts

jpt_LoadMusicSet
	.dw	$810e	; OW music
	.dw	$8134	; Level music
	.dw	$8159	; Credit music

PlaySound:
	; reorder register index
	pha
	lda	byte_APUPortIndexes, y
	tay
	pla

	; write APU port shadow
	sta	$1df9, y

	; turn on Yoshi Drum channel if BGM
	cpy	#2
	bne	loc_PlaySoundEnd
	lda	#2
	sta	$1dfa

loc_PlaySoundEnd:
	rts

byte_APUPortIndexes:
	; http://www.smwcentral.net/?p=viewthread&t=6665
	.db	2	; BGM
	.db	0	; SFX 1
	.db	3	; SFX 2
	.db	1	; misc

VBlank:
	sei
	php
	rep	#$30
	pha
	phx
	phy
	phb
	phk
	plb

	sep	#$30

	; clear NMI flag
	lda	$4210

	lda	$1dfb
	bne	loc_APU2NonZero

	ldy	$2142
	cpy	$1dff
	bne	loc_APU3Changed

loc_APU2NonZero:
	sta	$2142
	sta	$1dff
	stz	$1dfb

loc_APU3Changed:
	lda	$1df9
	sta	$2140

	lda	$1dfa
	sta	$2141

	lda	$1dfc
	sta	$2143

	stz	$1df9
	stz	$1dfa
	stz	$1dfc

	rep	#$30
	plb
	ply
	plx
	pla
	plp
	rti

EmptyHandler:
	rti

.ENDS
