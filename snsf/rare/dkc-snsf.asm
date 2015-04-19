.HIROM

.SNESHEADER
 ID    "ADNE"
 NAME  "DONKEY KONG COUNTRY  "
 HIROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0C
 SRAMSIZE $01
 COUNTRY $01
 LICENSEECODE $33
 VERSION $02
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

.ORG $8000
.SECTION "SETUP" SEMIFREE

.EMPTYFILL $FF

.DEFINE PARAM_SONG = $808000
	.dw	$0000
.DEFINE PARAM_SONG_TYPE = $808002
	.dw	$0000
.DEFINE PARAM_SONG_PRELOAD = $808004
	.dw	$0000
.DEFINE PARAM_RESERVED = $808006
	.dw	$0000

.DEFINE FrameCount = $0024

; setup routine derived from the original setup ($80/8000)
Start:
	clc
	xce
	sei

	; disable interrupt
	lda	#$01
	sta	$4200

	; setup for FastROM
	sta	$420d

	; switch to Native Mode
	clc
	xce
	rep	#$30

	; zero memory (note: actual game uses DMA)
	stz	$00
	ldx	#$0000
	ldy	#$0001
	lda	#$ffff
	mvn	$7e,$7e
	phk
	plb

	; transfer SPC program
	jsl	$8ab0ed
	jsl	$8ab133

	; setup interrupt
	sep	#$20
	lda	#$81
	sta	$4200
	cli
	rep	#$20

	; transfer waveforms (title logo)
	lda	#$3200
	sta	$16
	lda	#$3300
	sta	$18
	stz	$1a
	lda	#$1b
	jsl	$8ab414

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	beq	loc_PlayBGM
	bne	loc_PlaySFX

loc_PlayBGM:
	; transfer waveforms
	jsl	$8ab3f6
	lda	PARAM_SONG
	jsl	$8ab414

	; load BGM
	lda	PARAM_SONG
	jsl	$8ab1cb

	; start playing
	sep	#$20
	ldx	#$00fe
	jsl	$8ab1af
	rep	#$30

	bra	loc_MainLoop

loc_PlaySFX:
	; transfer waveforms
	jsl	$8ab3f6
	lda	PARAM_SONG_PRELOAD
	jsl	$8ab414

	; load BGM
	lda	PARAM_SONG_PRELOAD
	jsl	$8ab1cb

	; start playing
	sep	#$20
	ldx	#$00fe
	jsl	$8ab1af
	rep	#$30

	; TODO: mute BGM

	; request SFX playback
	lda	PARAM_SONG
	tax
	jsl	$8ab1af

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
	; NMI
	rep	#$30
	phd
	pha
	phx
	phy

	; clear NMI flag
	sep	#$20
	lda	$004210

	rep	#$30
	ply
	plx
	pla
	pld
	rti

EmptyHandler:
	RTI

.ENDS
