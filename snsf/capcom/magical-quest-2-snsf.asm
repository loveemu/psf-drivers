.HIROM

.SNESHEADER
 ID    "    "
 NAME  "THE GREAT CIRCUS     "
 HIROM
 FASTROM
 CARTRIDGETYPE $00
 ROMSIZE $0B
 SRAMSIZE $00
 COUNTRY $01
 LICENSEECODE $08
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
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $c00000
	.db	$18
.DEFINE PARAM_SONG_TYPE = $c00001
	.db	$00
.DEFINE PARAM_SONG_PRELOAD = $c00002
	.db	$00
.DEFINE PARAM_SONG_PRELOAD_FRAMES = $c00003
	.dw	$00
.DEFINE PARAM_RESERVED_1 = $c00004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $c00006
	.dw	$0000

.BASE $C0

; setup routine derived from the original setup
Start:
	lda	#0
	sta	$7fff0d

	; setup for FastROM
	lda	#1
	sta	$420d

	; set stack pointer
	rep	#$10
	ldx	#$1fff
	txs
	sep	#$10

	; set data bank
	lda	#$80
	pha
	plb

;	; load hardware register init table address
;	rep	#$10
;	ldx	#$827c
;
;loc_InitRegs:
;	; initialize hardware registers
;	lda	0, x
;	beq	loc_ZeroMemory
;
;	; length
;	lsr	a
;	sta	$00
;	inx
;
;	; register address
;	lda	0, x
;	sta	$10
;	inx
;	lda	0, x
;	sta	$11
;	inx
;
;loc_SetRegValue:
;	; register value(s)
;	lda	0, x
;	sta	($10)
;	inx
;	bcc	loc_NextReg
;
;	; write the second byte if necessary
;	lda	0, x
;	sta	($10)
;	inx
;
;loc_NextReg:
;	; increase register address
;	ldy	$10
;	iny	
;	sty	$10
;
;	; repeat
;	dec	$00
;	bne	loc_SetRegValue
;	bra	loc_InitRegs

loc_ZeroMemory:
	; initialize main memory
	rep	#$30
	ldx	#$1ffe

loc_ZeroMemoryStep:
	stz	0, x
	dex
	dex
	bpl	loc_ZeroMemoryStep

	; enable interrupts
	lda	#$b1
	sta	$4200
	stz	$009a.w

	sep	#$30

loc_InitSound:
	; initialize sound system
	lda	$7fff0d
	bne	loc_PlaySound

	jsr	$4c70

	lda	#$01
	sta	$7fff0d
	sta	$7fff12
	ldy	#$f9
	jsr	$4c70

	lda	#$02
	ldy	#$f9
	jsr	$4c70

	lda	#$ff
	sta	$7fff10
	sta	$7fff11

	; request BGM playback for echo initialization
	lda	PARAM_SONG_PRELOAD
	beq	loc_PlaySound
	jsl	$c04d1b

	lda	PARAM_SONG_PRELOAD_FRAMES

loc_PreloadWAI:
	beq	loc_PlaySound
	wai
	dec	a
	bra	loc_PreloadWAI

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	bne	loc_PlaySFX

loc_PlayBGM:
	; request BGM playback
	lda	PARAM_SONG
	jsl	$c04d1b

	bra	loc_MainLoop

loc_PlaySFX:
	; request SFX playback
	lda	PARAM_SONG
	jsl	$c04e32

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
	rep	#$38
	pha
	phx
	phy
	phd
	phb

	; set direct page
	lda	#0
	tcd

	; set data bank
	sep	#$30
	lda	#$80
	pha
	plb

	; clear NMI flag
	lda	$4210

	lda	$9a
	bne	loc_SkipVBlank

	; dispatch APU requests
	jsr	$4dcd

loc_SkipVBlank:
	rep	#$30
	plb
	pld
	ply
	plx
	pla
	rti

EmptyHandler:
	rti

.ENDS

.ORG $FF97
.SECTION "INTR" SEMIFREE
.ACCU 8
.INDEX 8
StartEntry:
	; disable interrupts
	stz	$4200

	; clear DMA
	stz	$420c
	stz	$420b

	; off-screen, set brightness
	lda	#$8f
	sta	$2100

	sei
	clc
	xce
	jml	Start

.ENDS

.ORG $FFE0
.SECTION "INTR2" SEMIFREE
VBlankEntry:
	jml	VBlank

.ENDS
