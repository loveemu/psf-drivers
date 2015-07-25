.LOROM

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "...."
 NAME  "SUPER CASTLEVANIA 4  "
 LOROM
 SLOWROM
 CARTRIDGETYPE $00
 ROMSIZE $0A
 SRAMSIZE $00
 COUNTRY $01
 LICENSEECODE $A4
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
  IRQBRK EmptyHandler
.ENDEMUVECTOR


.BANK 0 SLOT 0

.ORG $0000
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $808000
	.db	$13
.DEFINE PARAM_SONG_TYPE = $808001
	.db	$00
.DEFINE PARAM_RESERVED = $808002
	.db	$00
.DEFINE PARAM_RESERVED_2 = $808003
	.db	$00

; setup routine derived from the original setup
Start:
	clc
	xce
	sei
	cld

	; set stack pointer
	rep	#$30
	ldx	#$1dff
	txs

	; set direct page
	ldx	#0
	phx
	pld

	; set data bank
	sep	#$20
	lda	#1
	pha
	plb

	; disable interrupt
	lda	#0
	sta	$4200

	; zero memory
	rep	#$30
	phb
	lda	#0
	sta	$000000.l
	lda	#$bc
	ldx	#0
	txy
	iny
	mvn	$00,$00
	plb
	;
	rep	#$30
	phb
	lda	#0
	sta	$0000c4.l
	lda	#$1d3a
	ldx	#$c4
	txy
	iny
	mvn	$00,$00
	plb
	;
;	rep	#$30
;	phb
;	lda	#0
;	sta	$7e2000.l
;	lda	#$5ffe
;	ldx	#$2000
;	txy
;	iny
;	mvn	$7e,$7e
;	plb

	; transfer SPC program
	ldx	#$b5f9
	jsl	$0280e8
	ldx	#$b4ac
	jsl	$0280e8

	sei
	cld

	; set stack pointer, again
	rep	#$30
	ldx	#$1dff
	txs

;	; set direct page 0, again
;	lda	#0
;	tcd

	; set data bank, again
	; (data bank has set to 0, in the MVN routines)
	sep	#$20
	lda	#1
	pha
	plb
	rep	#$20

	; setup interrupt
	rep	#$20
	jsl	$008387
	cli

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	and	#$ff
	bne	loc_PlaySFX

loc_PlayBGM:
	; clear APU port 0
	jsl	$008584

	; request BGM transfer
	lda	PARAM_SONG
	asl	a
	and	#$fe
	jsl	$0280dd

	; request BGM playback
	jsl	$00859e

	bra	loc_MainLoop

loc_PlaySFX:
	; request SFX playback
	lda	PARAM_SONG
	and	#$ff
	jsl	$0085e3

loc_MainLoop:
	jsl	$028405
	bra	loc_MainLoop

VBlank:
	rep	#$30
	pha
	phx
	phy
	phd
	phb

	; set direct page
	sep	#$20
	ldx	#0
	phx
	pld

	; clear NMI flag
	lda	#1
	pha
	plb
	lda	$4210
	rep	#$20

	stz	$5c
	jsl	$008557

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
