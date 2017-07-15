.LOROM

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "ANIE"
 NAME  "Lufia II(Estpolis II)"
 LOROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0C
 SRAMSIZE $00
 COUNTRY $01
 LICENSEECODE $33
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
	.db	$0D
.DEFINE PARAM_SONG_TYPE = $808001
	.db	$00
.DEFINE PARAM_RESERVED_1 = $808002
	.db	$00
.DEFINE PARAM_RESERVED_2 = $808003
	.db	$00

; setup routine derived from the original setup
Start:
	sei
	cld
	clc
	xce
	sep	#$30

	; screen off
	lda	#$8f
	sta	$2100

	; disable interrupt
	stz	$4200

	; set stack pointer
	rep	#$20
	lda	#$1fff
	tcs

	; set direct page
	lda	#$0000
	tcd

	; set data bank
	sep	#$30
	lda	#$80
	pha
	plb

	; setup for FastROM
	lda	#$01
	sta	$420d

	; transfer SPC program
	jsr	$8117
	jsl	$809383

	; transfer common sound data?
	jsl	$809634

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	bne	loc_PlaySFX

loc_PlayBGM:
	lda	PARAM_SONG
	jsl	$8093fe

	bra loc_MainLoop

loc_PlaySFX:
	lda	PARAM_SONG
	jsl	$80953b

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
EmptyHandler:
	rti

.ENDS
