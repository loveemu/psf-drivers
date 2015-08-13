.HIROM

.SNESHEADER
 ID    "AJEJ"
 NAME  "CLOCK TOWER SFX      "
 HIROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0C
 SRAMSIZE $01
 COUNTRY $00
 LICENSEECODE $33
 VERSION $00
.ENDSNES

.MEMORYMAP
 SLOTSIZE $10000
 DEFAULTSLOT 0
 SLOT 0 $0000
.ENDME

.ROMBANKSIZE $10000
.ROMBANKS 1

.SNESNATIVEVECTOR               ; Define Native Mode interrupt vector table
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI VBlankEntry
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET StartEntry
  IRQBRK EmptyHandler
.ENDEMUVECTOR


.BANK 0 SLOT 0

.ORG $0000
.SECTION "START" SEMIFREE

.EMPTYFILL $FF

.BASE $C0

.DEFINE PARAM_SONG = $c00000
	.db	$04
.DEFINE PARAM_SONG_TYPE = $c00001
	.db	$00
.DEFINE PARAM_SEQ_BANK = $c00002
	.dw	$0003
.DEFINE PARAM_BRR_BANK = $c00004
	.dw	$0000
.DEFINE PARAM_CHAN_MASK = $c00006
	.db	$00
.DEFINE PARAM_RESERVED = $c00007
	.db	$00

StartC0:
	jml	Start

VBlankC0:
	jml	VBlank

.ENDS

.ORG $fc00
.SECTION "SETUP" SEMIFREE

.BASE $80

Start:
	sei
	rep	#$f8

	; set stack pointer
	lda	#$1fff
	tcs

	; set direct page
	lda	#0
	tcd

	; set data bank
	sep	#$20
	lda	#$80
	pha
	plb

	; screen off
	lda	#$8f
	sta	$2100

	; disable DMA
	stz	$420c

	; setup hardware registers
	jsr $d039

	; clear memory
	rep	#$20
	jsr	$d063
	jsr	$d092
	jsr	$d138

	jsl	Main
	jmp	$dd8b

.BASE $C0

; origin $c0d026
Main:
	ldx	#$0c72
	jsl	$80dee1

	; initialize sound variables (required for stereo setup)
	;jsl	$c01c32

	; transfer APU executable
	;jsr	$1edb
	lda	#4
	jsl	$81852a
	; stereo mode
	lda	#1
	jsl	$818858

	; initialize APU transfer
	jsl	$c01026

	; initial transfer:
	; transfer common sequences and
	; send some reset messages
	jsr	$3598

	; transfer specified sequence set if requested
	lda	PARAM_SEQ_BANK
	beq	loc_SkipTransferSeq

	; transfer sequence set
	; $01: Common (already done)
	; $7e: Common (already done)
	; $02: Common (already done)
	; $0b: Title ~ Prologue (already done)
	; $03: Main
	; $d4: Dad's Testament
	; $0a: Demonic Giant Baby
	; $05: Elevator ~ The Top Floor
	; $09: Ending
	jsl	$c020c7

loc_SkipTransferSeq:
	; setup interrupt
	jsr	$359c

	; transfer common waveforms
	lda	#$5a
	jsl	$c02034

	lda	PARAM_BRR_BANK
	beq	loc_PlaySound

	; transfer specified waveforms
	; $011f: Prologue
	; $0040: Courtyard, Execution Room, etc.
	; $004d: Bedroom
	; $01d5: Saloon
	; $001c: Garage
	; $0093: Jail
	; $00bb: The Room Before Dad
	; $0068: Collection Room
	; $0033: Music Room (Piano)
	; $0078: Long Ladder
	; $0027: Top Floor
	jsl	$c02034

	; bonus tips:
	; request sample delay-load
	;   $c051d8 (=> $c01fbd => $c02005)

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	and	#$ff
	bne	loc_PlaySFX

loc_PlayBGM:
	; request BGM playback
	sep	#$20
	lda	PARAM_SONG
	tax
	lda	#$ff
	jsl	$8185e7
	rep	#$20

	sep	#$20
	lda	PARAM_CHAN_MASK
	beq	loc_SkipChanMask

	; channel mask
	jsl	$818716

loc_SkipChanMask:
	rep	#$20

	bra	loc_MainLoop

loc_PlaySFX:
	; request SFX playback
	sep	#$20
	lda	#7
	xba
	lda	PARAM_SONG
	rep	#$20
	ldx	#$ff
	ldy	#$0a
	jsl	$c07819

loc_MainLoop:
	wai
	bra	loc_MainLoop

.BASE $80

VBlank:
	rep	#$30
	pha
	phd

	; set direct page
	lda	#0
	tcd

	; save stack pointer
	tsc
	sta	$d4

	; set stack pointer
	lda	#$07dd
	tcs

	phx
	phy
	phb
	sep	#$20

	; set data bank
	lda	#$80
	pha
	plb

	; clear NMI flag
	bit	$4210

	; disable vblank interrupt
	lda	#$31
	sta	$4200

	lda	$c1
	bne	loc_SkipXXX1

	rep	#$20
	lda	#1
	jsl	$80e0f8
	sep	#$20

loc_SkipXXX1:

	lda	$086d
	beq	loc_SkipAPUVBlank

	; dispatch APU requests
	rep	#$20
	jsr	$f300
	sep	#$20

loc_SkipAPUVBlank:
	inc	$c1
	bne	loc_EndSetC1
	dec	$c1

loc_EndSetC1:
	lda	$c2
	ror
	ror
	rep	#$20
	plb
	ply
	plx

	; restore stack pointer
	lda	$d4
	tcs

	; restore direct page
	pld
	bcc	loc_SkipRestoreInterrupt

	; restore vblank interrupt
	sep	#$20
	lda	#$b1
	sta	$004200
	rep	#$20

loc_SkipRestoreInterrupt:
	pla
	rti

.ENDS

.ORG $ff90
.SECTION "INTR" SEMIFREE

StartEntry:
	clc
	xce
	jml	StartC0

VBlankEntry:
	jml	VBlankC0

EmptyHandler:
	rti

.ENDS
