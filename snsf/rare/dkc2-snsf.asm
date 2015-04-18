.HIROM

.SNESHEADER
 ID    "ADNE"
 NAME  "DIDDY'S KONG QUEST   "
 HIROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0C
 SRAMSIZE $01
 COUNTRY $01
 LICENSEECODE $33
 VERSION $01
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
	.dw	$0002
.DEFINE PARAM_SONG_TYPE = $808002
	.dw	$0000
.DEFINE PARAM_SONG_PRELOAD = $808004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $808006
	.dw	$0000

.DEFINE FrameCount = $002A

; setup routine derived from the original setup ($80/83F7)
Start:
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

	; zero memory ($80/85B9)
	stz	$00
	ldx	#$0000
	ldy	#$0001
	lda	#$ffff
	mvn	$7e,$7e
	ldy	#$0000
	tyx
	lda	#$ffff
	mvn	$7f,$7e
	phk
	plb

	; transfer SPC program
	jsl	$b58000

	; stereo mode
	lda	#0
	sta	$1e

	; setup for SFX?
	jsl	$b58009

	; setup interrupt
	sep	#$20
	lda	#$81
	sta	$4200
	cli
	rep	#$20

	; clear framecount
	lda #0
	sta FrameCount

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	beq	loc_PlayBGM
	bpl	loc_PlaySFX

loc_PlayBGM:
	; request BGM playback
	lda	PARAM_SONG
	jsl	$b5800f

	bra	loc_MainLoop

loc_PlaySFX:
	; setup SFX request monitor
	lda	PARAM_SONG_PRELOAD
	jsl	$b5800f

	; request SFX playback
	lda	PARAM_SONG
	jsl	$b58003

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
	; NMI ($80/F3C1, $80/A86C)
	rep	#$30
	phd
	pha
	phx
	phy

	; clear NMI flag
	sep	#$20
	lda	$004210

	; increment framecount
	lda FrameCount
	inc a
	sta FrameCount

	; dispatch SFX requests
	jsl	$b5801e

	rep	#$30
	ply
	plx
	pla
	pld
	rti

EmptyHandler:
	RTI

.ENDS
