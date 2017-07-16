.LOROM

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "ANIE"
 NAME  "Lufia I (ESTPOLIS I) "
 LOROM
 SLOWROM
 CARTRIDGETYPE $02
 ROMSIZE $0A
 SRAMSIZE $00
 COUNTRY $01
 LICENSEECODE $C0
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

.DEFINE PARAM_SONG = $008000
	.db	$1c
.DEFINE PARAM_SONG_TYPE = $008001
	.db	$00
.DEFINE PARAM_RESERVED_1 = $008002
	.db	$00
.DEFINE PARAM_RESERVED_2 = $008003
	.db	$00

; setup routine derived from the original setup
Start:
	sei
	cld
	clc
	xce
	sep	#$30

	; set data bank
	lda	#$00
	pha
	plb

	; screen off
	lda	#$8f
	sta	$2100

	; disable interrupt
	stz	$4200

	; set stack pointer
	rep	#$20
	lda	#$1ffe
	tcs

	; set direct page
	lda	#$0000
	tcd

	; set data bank
	sep	#$30
	lda	#$80
	pha
	plb

	; transfer SPC program and common data
	jsl	$008de2

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	bne	loc_PlaySFX

loc_PlayBGM:
	lda	PARAM_SONG
	jsl	$008e13

	bra loc_MainLoop

loc_PlaySFX:
;	; play silence BGM (unused #)
	lda	#$13
	jsl	$008e13

	lda	PARAM_SONG
	jsl	$008e8f

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
EmptyHandler:
	rti

.ENDS
