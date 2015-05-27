.HIROM

.SNESHEADER
 ID    "AQ3J"
 NAME  "DRAGONQUEST3         "
 HIROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0C
 SRAMSIZE $03
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
  NMI EmptyHandler
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET StartStub
  IRQBRK EmptyHandler
.ENDEMUVECTOR


.BANK 0 SLOT 0

.ORG $0000
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $C00000
	.dw	$0001
.DEFINE PARAM_RESERVED_0 = $C00002
	.dw	$0000
.DEFINE PARAM_RESERVED_1 = $C00004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $C00006
	.dw	$0000

.BASE $C0

; setup routine derived from the original setup ($00/FF98)
Start:
	sep	#$20
	rep	#$10

	; setup for FastROM
	lda	#1
	sta	$420d

	; disable interrupt
	lda	#1
	sta	$4200

	; set stack pointer
	ldx	#$47f
	txs

	; zero memory
	ldx	#0
	lda	#$40

loop_MemSet:
	sta	$7e0000, x
	sta	$7f0000, x
	ina
	inx
	bne	loop_MemSet

	; set data bank
	pea	$0000
	plb
	plb

	rep	#$30

	; initialize sound program
	jsl	$c1e29e

	; request BGM/SFX playback
	lda	PARAM_SONG
	jsl	$c1e314

loc_MainLoop:
	wai
	bra	loc_MainLoop
.ENDS

.ORG $FF98
.SECTION "INTR" SEMIFREE
StartStub:
	sei
	clc
	xce
	cld
	jml	Start

EmptyHandler:
	rti

.ENDS
