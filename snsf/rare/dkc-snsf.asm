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

	; zero memory ($0000-$1FFF)
	rep	#$20
	lda	#$a911  ; point to ".byte 0"
	sta	$4302   ; DMA source
	lda	#$80
	sta	$4304   ; DMA source (bank)
	stz	$4305   ; DMA byte-counter
	stz	$2181   ; WRAM address (lower 8bit)
	sep	#$20
	stz	$2183   ; WRAM address (upper 8bit)
	lda	#$80
	sta	$4301   ; DMA/HDMA I/O-Bus Address
	lda	#$08
	sta	$4300   ; DMA params
	lda	#$01
	sta	$420b
	lda	#$01
	sta	$420b

	; set stack pointers
	rep	#$20
	lda	#$1ff
	tcs

	; transfer SPC program
	jsl	$8ab0e8
	jsl	$8ab12e

	; disable interrupt
	sep	#$20
	lda	#$01
	sta	$4200
	rep	#$20

	; transfer waveforms (title logo)
	lda	#$3200
	sta	$16
	lda	#$3300
	sta	$18
	stz	$1a
	lda	#$12
	jsl	$8ab40f

;	; start transfer
;	ldx	#$ff
;	jsl	$8ab1aa

	; start another transfer (related to $8ab3f1)
	jsl	$80c239

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	beq	loc_PlayBGM
	bne	loc_PlaySFX

loc_PlayBGM:
	lda	PARAM_SONG
	jsr	TransferBGMBlock

	; start BGM playback
	sep	#$20
	ldx	#$fe
	jsl	$8ab1aa
	rep	#$30

	bra	loc_EnterMainLoop

loc_PlaySFX:
	lda	PARAM_SONG_PRELOAD
	jsr	TransferBGMBlock

	; start BGM playback
	sep	#$20
	ldx	#$fe
	jsl	$8ab1aa
	rep	#$30

	; TODO: mute BGM

	; request SFX playback
	lda	PARAM_SONG
	tax
	jsl	$8ab1aa

loc_EnterMainLoop:
	; enable interrupt
	sep	#$20
	lda	#$b1
	sta	$4200

loc_MainLoop:
	wai
	bra	loc_MainLoop

TransferBGMBlock:
	; transfer BGM block (reference: $b99036)
	pha
	pha

	; disable NMI
;	sep	#$20
;	lda	#$01
;	sta	$4200
;	rep	#$20

	; start transfer
;	sep	#$20
;	ldx	#$ff
;	jsl	$8ab1aa

	; transfer waveforms
	pla
	jsl	$8ab40f

	; end transfer
	pla
	jsl	$8ab1c6

	rts

VBlank:
	; NMI
	rep	#$30
	phb
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
	plb
	rti

EmptyHandler:
	rti

.ENDS
