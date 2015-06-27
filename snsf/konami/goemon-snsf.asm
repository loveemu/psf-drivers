.LOROM

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "...."
 NAME  "GANBARE GOEMON       "
 LOROM
 SLOWROM
 CARTRIDGETYPE $00
 ROMSIZE $0A
 SRAMSIZE $00
 COUNTRY $00
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
	.db	$01
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
	ldx	#$1eff
	txs

	; zero memory ($0000-$1FFF)
	rep	#$30
	phb
	lda	#$0000
	sta	$000000.l
	lda	#$1ffd
	ldx	#$0001
	txy
	iny
	mvn	$00,$00
	plb

	; set direct page 0
	lda	#0
	tcd

	; transfer SPC program
	ldx	#$91df
	jsl	$00991e
	ldx	#$8054
	jsl	$00991e

	sei
	cld

	; set stack pointer, again
	rep	#$30
	ldx	#$1eff
	txs

	; set direct page 0, again
	lda	#0
	tcd

;	; set data bank
;	sep	#$20
;	lda	#1
;	pha
;	plb
;	rep	#$20

	; init song number variables
	jsl	$008362

	; setup interrupt
	rep	#$20
	jsl	$0081dd
	cli

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	bne	loc_PlaySFX

loc_PlayBGM:
	; request BGM transfer
	lda	PARAM_SONG
	and	#$7f
	sta	$c8
	asl	a
	adc	$c8
	sta	$c8
	jsl	$009c67
	jsl	$008380

	bra	loc_MainLoop

loc_PlaySFX:
	; request SFX playback
	lda	PARAM_SONG
	jsl	$0083d2

loc_MainLoop:
	jsl	$009d0d
	bra	loc_MainLoop

VBlank:
	rep	#$30
	pha
	phx
	phy
	phd
	phb

	lda	#0
	tcd

	; clear NMI flag
	sep	#$20
	lda	#1
	pha
	plb
	lda	$4210
	rep	#$20

	jsl	$008334

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
