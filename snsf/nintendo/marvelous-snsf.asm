.LOROM

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "AVRJ"
 NAME  "ϰ�ު׽              "
 LOROM
 SLOWROM
 CARTRIDGETYPE $35
 ROMSIZE $0C
 SRAMSIZE $06
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
  NMI VBlank
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
	.dw	$0003
.DEFINE PARAM_SOUND_BANK = $008002
	.dw	$0027
.DEFINE PARAM_SONG_TYPE = $008004
	.dw	$0000
.DEFINE PARAM_RESERVED_2 = $008006
	.dw	$0000

; setup routine derived from the original setup ($80/8004)
Start:
	sei
	clc
	xce

	; set stack pointer
	sep	#$20
	rep	#$10
	ldx	#$1FFF
	txs

	; set data bank
	lda	#$00
	pha
	plb

	; set direct page
	ldx	#$3000
	phx
	pld

	; disable interrupt
	stz	$4200

	; clear APU ports
	stz	$2140
	stz	$2141
	stz	$2142
	stz	$2143

	; transfer APU program
	sep	#$10
	jsr	$ba87

	; set data bank
	lda	#0
	pha
	plb

	; transfer sound set
	lda	PARAM_SOUND_BANK
	cmp	#$27
	beq	loc_LoadOPSoundBank
	tay
	jsl	$00ba38
	bra	loc_LoadSoundBankDone

loc_LoadOPSoundBank:
	jsl	$00b9e9

loc_LoadSoundBankDone:
	; enable interrupt
	lda	#$81
	sta	$4200

loc_PlaySound:
	lda	PARAM_SONG_TYPE
	beq	loc_PlayBGM
	bpl	loc_PlayCommonSFX
	bmi	loc_PlaySFX

loc_PlayBGM:
	lda	PARAM_SONG
	jsl	$00fba9

	bra loc_MainLoop

loc_PlayCommonSFX:
	lda	PARAM_SONG
	jsl	$00fc1a

	bra loc_MainLoop

loc_PlaySFX:
	lda	PARAM_SONG
	jsl	$00fbfc

loc_MainLoop:
	wai
	bra	loc_MainLoop

VBlank:
	rep	#$30
	pha
	phx
	phy
	phd
	phb

	; clear NMI flag
	lda	$4210

	; dispatch sound requests
	; (originally called from main loop)
	sep	#$30
	jsr	$a835

	rep	#$30
	plb
	pld
	ply
	plx
	pla
	rti

EmptyHandler:
	rti

.ENDS
