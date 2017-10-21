.LOROM

.SNESHEADER
 ID    "    "
 NAME  "Sansa 2              "
 LOROM
 SLOWROM
 CARTRIDGETYPE $02
 ROMSIZE $0B
 SRAMSIZE $00 ; $03
 COUNTRY $00
 LICENSEECODE $AA
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
  NMI EmptyHandler
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

.DEFINE PARAM_SONG_TYPE = $008000
	.dw	$0000
.DEFINE PARAM_SONG = $008002
	.dw	$000B
.DEFINE PARAM_SFX_VOL = $008004
	.dw	$007F
.DEFINE PARAM_SFX_PAN = $008006
	.dw	$0000
.DEFINE PARAM_SFX_PRM4E = $008008
	.dw	$0011
.DEFINE PARAM_RESERVED_1 = $00800A
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $00800C
	.dw	$0000
.DEFINE PARAM_RESERVED_3 = $00800E
	.dw	$0000

.BASE $80

; setup routine derived from the original setup ($00/8000)
Start:
	clc
	xce
	sep #$20
	rep #$10

	; set stack pointer
	ldx #$1ff0
	txs

	; set data bank
	lda #$0
	pha
	plb

	; disable interrupts
	lda	#0
	sta	$4200

;	rep	#$20
;	jsl	$00835f
;	jsl	$008391

;	lda	#$8000
;	sta	$2102

	; initialize WRAM
	jsl	$008426

;	sep	#$20
;	lda	#$80
;	sta	$3c
;
;	rep	#$20
;	jsr	$84c3
;
;	lda	#$0010
;	sta	$0f0c
;
;	lda	#$0001
;	sta	$0f0a
;
;	lda	#$2000
;	sta	$1000
;
;	sep	#$20
;	lda	#$7f
;	sta	$1002

	rep	#$20
;	lda	#$0000
;	sta	$7f2000
;	sta	$7f2002
;	sta	$7f2004
;	sta	$7f2006
	jsl	$00f713
	jsl	$00fb20

	; playback request
	lda	PARAM_SONG_TYPE
	bne	loc_PlaySFX

loc_PlayBGM:
	; request BGM playback
	lda	PARAM_SONG
	jsl	$00f964

	bra	loc_MainLoop

loc_PlaySFX:
	; request SFX playback
	lda	PARAM_SONG
	sta	$48
	lda	PARAM_SFX_VOL
	sta	$4a
	lda	PARAM_SFX_PAN
	sta	$4c
	lda	PARAM_SFX_PRM4E
	sta	$4e
	jsl	$00f9b6

loc_MainLoop:
	wai
	bra	loc_MainLoop

EmptyHandler:
	rti

.ENDS
