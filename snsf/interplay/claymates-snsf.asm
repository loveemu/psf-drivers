.HIROM

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "    "
 NAME  "CLAYMATES            "
 HIROM
 FASTROM
 CARTRIDGETYPE $00
 ROMSIZE $0A
 SRAMSIZE $00
 COUNTRY $01
 LICENSEECODE $71
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
  NMI EmptyHandler
  IRQ IRQEntry
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET StartEntry
  IRQBRK EmptyHandler
.ENDEMUVECTOR


.BANK 0 SLOT 0

.ORG $7E00
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $C07E00
	.dw	$0012
.DEFINE PARAM_SOUND_BANK = $C07E02
	.dw	$0000
.DEFINE PARAM_SONG_TYPE = $C07E04
	.dw	$0000
.DEFINE PARAM_RESERVED = $C07E06
	.dw	$0000

.BASE $C0

; setup routine derived from the original setup ($CC/5540)
.ACCU 16
.INDEX 16
Start:
	; set direct page
	lda	#0
	tcd

	; set stack pointer
	lda	#$21f
	tcs

	; set data bank
	pea	$7e7e
	plb
	plb

	lda	#0
	ldx	#$3fff

loc_FillMemory:
	sta	$0000.w, x
	sta	$4000, x
	sta	$8000, x
	sta	$c000, x
	sta	$7f0000, x
	sta	$7f4000, x
	sta	$7f8000, x
	sta	$7fc000, x
	dex
	dex
	bpl	loc_FillMemory

;	jsl	$c03122
	jsl	$cd5c81
	jsl	$cd5e2c

	; transfer sample data
	lda	PARAM_SOUND_BANK
	jsl	$cd5e72

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	bne	loc_PlaySFX

loc_PlayBGM:
	lda	PARAM_SONG
	jsl	$cd5f02
	bra	loc_MainLoop

loc_PlaySFX:
	lda	PARAM_SONG
	jsl	$cd5fd1

loc_MainLoop:
	wai
	bra	loc_MainLoop

IRQHandler:
	rep	#$30
	pha
	phx
	phy
	phb
	phd

	; set data bank
	pea	$7e7e
	plb
	plb

	; set direct page
	lda	#0
	tcd

	cld
	sei

	lda	$f66b
	lsr
	bcc	loc_SkipIRQSub

	jsr	IRQSub

loc_SkipIRQSub:
	jsl	$c00000
	sep	#$20
	inc	$f66b
	lda	$004211.l

	pld
	plb
	rep	#$30
	ply
	plx
	pla
	rti

IRQSub: ; origin $CD/60E3
	ldx	$f67e
	cpx	$f67c
	beq	locret_IRQSub

	txa
	inc	a
	inc	a
	and	#$f
	sta	$f67e

	lda	$f66c, x
	and	#$ff
	bit	#$80
	bne	loc_IRQSub_1

	ora	#$80
	pha
	pea	$7fff
	lda	$f66d, x
	and	#$ff
	pha
	pea	$0003
	jsl	$0002
	bra	locret_IRQSub

loc_IRQSub_1:
	ora	#$80
	pha
	pea	$ffff
	pea	$0004
	jsl	$c00002

locret_IRQSub:
	rts

.ENDS

.ORG $FDD4
.SECTION "INTR" SEMIFREE
StartEntry:
	sei
	clc
	xce
	rep	#$30
	jml	Start

IRQEntry:
	;jml	IRQHandler

	; keep the original address
	jml	$cd6152

EmptyHandler:
	rti

.ENDS
