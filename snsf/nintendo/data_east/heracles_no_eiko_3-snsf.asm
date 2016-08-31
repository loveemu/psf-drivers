.LOROM

.SNESHEADER
 ID    "    "
 NAME  "HERAKLES 3           "
 LOROM
 SLOWROM
 CARTRIDGETYPE $02
 ROMSIZE $0A
 SRAMSIZE $03
 COUNTRY $00
 LICENSEECODE $C5
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

.DEFINE PARAM_LOAD = $808000
	.db	$23
.DEFINE PARAM_SONG = $808001
	.db	$07
.DEFINE PARAM_PRELOAD = $808002
	.db	$FF
.DEFINE PARAM_PRELOAD_2 = $808003
	.db	$FF
.DEFINE PARAM_RESERVED_1 = $808004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $808006
	.dw	$0000

.BASE $80

; setup routine derived from the original setup ($80/8000)
Start:
	clc
	xce
	sei

	rep	#$10
	sep	#$20

	; set stack pointer
	ldx	#$01ff
	txs

	; set data bank and direct page
	lda	#0
	xba
	lda	#0
	pha
	plb
	tcd

	lda	#$8f
	sta	$2100
	stz	$4200

	; zero memory
	ldy	#0
	sty	$2181	; WMADDL
	stz	$2183	; WMADDH

loc_ZeroMemory:
	stz	$2180	; WMDATA
	stz	$2180	; WMDATA
	iny
	cpy	#$fff7
	bne	loc_ZeroMemory

	; load program and common data into APU RAM
	jsr $1c8000

	; enable interrupts
	lda	#$81
	sta	$4200
	cli

	; load prerequisite bank
	lda	PARAM_PRELOAD
	bmi	loc_LoadSound
	jsr	$8f8b

loc_LoadSound:
	; load individual sound data
	lda	PARAM_LOAD
	bmi	loc_PlaySound
	jsr	$8f8b

loc_PlaySound:
	; playback request
	lda	PARAM_SONG
	jsr	$8fad

; main loop (origin: $80/xxxx copied from $80/xxxx)
loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
	; NMI ($80/810d)
	php
	phb
	phd
	rep	#$20
	rep	#$10
	pha
	phx
	phy

	; set direct page 0
	lda	#0
	tcd

	; set data bank
	sep	#$20
	pha
	plb

	; clear NMI flag
	lda	$4210

	; sound related function
	jsl	$1c8018

	rep	#$20
	rep	#$10
	ply
	plx
	pla
	pld
	plb
	plp
	rti

EmptyHandler:
	rti

.ENDS
