.HIROM

.SNESHEADER
 ID    "A3CE"
 NAME  "DONKEY KONG COUNTRY 3"
 HIROM
 FASTROM
 CARTRIDGETYPE $02
 ROMSIZE $0C
 SRAMSIZE $01
 COUNTRY $01
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
	.dw	$0016
.DEFINE PARAM_SONG_TYPE = $808002
	.dw	$0000
.DEFINE PARAM_SONG_PRELOAD = $808004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $808006
	.dw	$0000

.DEFINE FrameCount = $005A

; setup routine derived from the original setup
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

	; zero memory
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
	jsl	$b28000

	; stereo mode
	lda	#0
	sta	$0432

	; setup for SFX?
	jsl	$b28009

	; setup interrupt
	sep	#$20
	lda	#$81
	sta	$4200
	cli
	rep	#$20

	; clear framecount
;	lda #0
;	sta FrameCount

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	beq	loc_PlayBGM
	bpl	loc_PlaySFX

loc_PlayBGM:
;	; request BGM playback (immediate)
;	jsl	$b28009

	; transfer BGM data
	lda	PARAM_SONG
	and	#$ff
	jsl	$b28003

	; request BGM playback
	lda	PARAM_SONG+1
	and	#$ff
	jsl	$b2800f

	bra	loc_MainLoop

loc_PlaySFX:
	; transfer BGM data
	lda	PARAM_SONG_PRELOAD
	beq	loc_PlaySFXImm
	and	#$ff
	jsl	$b28003

	; request BGM playback
	lda	PARAM_SONG_PRELOAD+1
	and	#$ff
	jsl	$b2800f

	; TODO: mute BGM

loc_PlaySFXImm:
	; request SFX playback
	lda	PARAM_SONG
	jsl	$b28012

;	; request SFX playback (without queue)
;	lda	PARAM_SONG
;	jsl	$b28018

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
	rep	#$30
	phd
	pha
	phx
	phy

	; clear NMI flag
	sep	#$20
	lda	$004210

	; increment counter for SFXs (origin $808344)
	inc	$00

	; increment framecount
;	lda FrameCount
;	inc a
;	sta FrameCount

	; dispatch SFX requests
	jsl	$b28015

	rep	#$30
	ply
	plx
	pla
	pld
	rti

EmptyHandler:
	rti

.ENDS
