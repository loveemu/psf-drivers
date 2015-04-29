.LOROM

; Note: A patch to kill communication with SA-1 is required:
; 00/8C70 (ROM:0C70) BMI loc_808C7B (30 09) => NOP NOP (EA EA)

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "AKFJ"
 NAME  "KIRBY SUPER DELUXE   "
 LOROM
 SLOWROM
 CARTRIDGETYPE $35
 ROMSIZE $0C
 SRAMSIZE $03
 COUNTRY $00
 LICENSEECODE $33
 VERSION $00
.ENDSNES

; Patch SNES header for SA-1
.org $7fd5
 .db $23

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
  NMI EmptyHandler
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Start
  IRQBRK $0	; used by DMA
.ENDEMUVECTOR


.BANK 0 SLOT 0

.ORG $0000
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $008000
	.dw	$0015
.DEFINE PARAM_SONG_TYPE = $008002
	.dw	$0000
.DEFINE PARAM_RESERVED = $008004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $008006
	.dw	$0000

; setup routine derived from the original setup ($80/8004)
Start:
	sei
	clc
	xce

	sep	#$20
	rep	#$10

	; set stack pointer
	ldx	#$1fff
	txs

	phk
	plb

	stz	$4200

	; zero memory ($0000-$1FFF)
	ldx	#$0000
	stx	$2181
	stz	$2183   ; DMA destination
	lda	#$08
	sta	$4310   ; DMA params
	ldx	#$fffe
	stx	$4312   ; DMA source: Emulation Mode IRQ (must be 0)
	stz	$4314
	lda	#$80
	sta	$4311
	ldx	#$2000  ; DMA size
	stx	$4315
	lda	#$02
	sta	$420b

	; zero memory (IRAM $3000-$37FF)
	; originally it is done by SA-1, see $008bcf
	stz	$3000
	rep	#$30
	ldx	#$3000
	ldy	#$3001
	lda	#$7fe
	mvn	$00,$00

	; transfer SPC program
	; (uses I-RAM, but write only)
	rep	#$20
	jsl	$00d4ee

	; stereo (originally done by SA-1)
	lda	#0
	jsl	$00cdd8

loc_PlaySound:
	lda	PARAM_SONG_TYPE.l
	bne	loc_PlaySFX

loc_PlayBGM:
	lda	PARAM_SONG.l
	jsl	$00cf98

	bra	loc_MainLoop

loc_PlaySFX:
	lda	PARAM_SONG.l
	jsl	$00d0c2

loc_MainLoop:
	wai
	bra	loc_MainLoop

EmptyHandler:
	rti

.ENDS
