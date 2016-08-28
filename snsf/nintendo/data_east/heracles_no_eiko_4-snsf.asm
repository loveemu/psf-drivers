.LOROM

.SNESHEADER
 ID    "C54E"
 NAME  "Í×¸Ú½4 ¶Ð¶ÞÐ¶×Éµ¸ØÓÉ "
 LOROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0B
 SRAMSIZE $03
 COUNTRY $00
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

.DEFINE PARAM_LOAD = $808000
	.db	$38
.DEFINE PARAM_SONG = $808001
	.db	$07
.DEFINE PARAM_RESERVED_1 = $808002
	.dw	$00
.DEFINE PARAM_RESERVED_2 = $808004
	.dw	$0000
.DEFINE PARAM_RESERVED_3 = $808006
	.dw	$0000

.BASE $80

; setup routine derived from the original setup ($80/8000)
Start:
	clc
	xce
	sei

	lda	#$8f
	sta	$2100
	stz	$4200

	rep	#$30

	; set direct page 0
	lda	#0
	tcd

	; set stack pointer
	ldx	#$01ff
	txs

	sep	#$20

	; set data bank
	lda	#$80
	pha
	plb

	stz	$00

	; zero memory (bank $7e)
	rep	#$20
	ldx	#$0000
	txy
	iny
	lda	#$fffe
	mvn	$7e,$7e

	; zero memory (bank $7f)
	ldx	#0
	txy
	lda	#$fffd
	mvn	$7f,$7e

	; load common functions into SNES RAM
	ldx #$8174
	ldy #$1500
	lda #$02fc
	mvn $80,$80

	sep #$20

	; enable interrupts
	lda #$81
	sta $0629
	sta $4200
	cli

	; load program and common data into APU RAM
	jsr	$8751

	; load individual sound data
	lda	PARAM_LOAD
	bmi	loc_PlaySound
	jsr	$17d2

loc_PlaySound:
	; playback request
	lda	PARAM_SONG
	jsr	$17cd

; main loop (origin: $80/1507 copied from $80/817b)
loc_MainLoop:
	sep	#$20
	rep	#$10
	jsr	$1500

;	wai
	bra	loc_MainLoop

VBlank:
	; NMI ($80/da35)
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
	lda	#$80
	pha
	plb

	; clear NMI flag
	lda	$4210

	; sound related function
	jsr	$b9800c

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
