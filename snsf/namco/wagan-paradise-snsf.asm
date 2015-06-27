.LOROM

; ## Known Issues
; 
; * Initial portamento of the Player Select song (especially oneshot noise)

; Cartridge header should be copied from the original ROM
.SNESHEADER
 ID    "AWLJ"
 NAME  "Ü·Þ¬ÝÊß×ÀÞ²½         "
 LOROM
 FASTROM
 CARTRIDGETYPE $00
 ROMSIZE $0B
 SRAMSIZE $00
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

.DEFINE PARAM_SONG = $808000
	.db	$01
.DEFINE PARAM_TABLES = $808001
	.db	$01
.DEFINE PARAM_SOUND_BANK = $808002
	.db	$03
.DEFINE PARAM_RESERVED = $808003
	.db	$00

.DEFINE HWREGS_INIT_TABLE = $808004
	.dw	$86cc
	.db	$80

; setup routine derived from the original setup
Start:
	; align
	nop

	clc
	xce

	; set stack pointer
	rep	#$10
	ldx	#$1fff
	txs

	; disable interrupt
	sep	#$20
	sei
	lda	#1
	sta	$004200.l

	; set bank register
	pea	$7e7e
	plb
	plb

	; set direct page
	pea	0
	pld

	ldx	#0
	ldy	#1
	lda	#0
	sta	$7f0000
	rep	#$20
	lda	#$fffe
	mvn	$7f,$7f

	ldx	#0
	txy
	lda	#$1eff
	mvn	$7f,$7f

	ldx	#$2200
	txy
	lda	#$ff
	mvn	$7e,$7f

	; setup hardware registers
	lda	HWREGS_INIT_TABLE
	sta	$20
	lda	HWREGS_INIT_TABLE+2
	sta	$22
	jsl	$80b73a

	rep	#$20

	; transfer SPC program
	jsl	$80c562

	; activate NMI
	sep	#$20
	cli
	lda	#$81
	sta	$004200.l

	; $80d0e6 seems to be a large function for the sound manipulation,
	; and the following initialize routines are part of the function

	rep #$20

	; origin $80d0f7

	; initialize RAM
	jsr	$d261

	; wait for APU startup
	jsl	$80c5a5

	; sound data table ($80f000)
	; 
	; #,Data,Length,Destination
	; 00,$878000,$1058,$dc10
	; 01,$869557,$1521,$dc10
	; 02,$8bf618,$03db,$f500
	; 03,$88ce4d,$0aa6,$f300
	; 04,$8ae900,$061b,$f500
	; 05,$8ef758,$0119,$f500
	; 06,$8dfce4,$01b0,$f500
	; 07,$8edb99,$0161,$f500
	; 08,$8cd13b,$0260,$f500
	; 09,$8cf1d2,$01f4,$f500
	; 10,$8c96d7,$039d,$f500
	; 11,$8afb45,$0477,$f500
	; 12,$85f800,$07b3,$f500
	; 13,$899dbc,$091b,$f500
	; 14,$8af539,$0604,$f500
	; 15,$8bd90b,$045c,$f500
	; 16,$8a8e86,$06f0,$f500
	; 17,$8d930b,$01da,$f500
	; 18,$8aa2f0,$069d,$f500
	; 19,$8ed023,$016a,$f500
	; 20,$8f8000,$010c,$f300
	; 21,$8bfdde,$01fd,$f300
	; 22,$8e9b07,$019a,$f300
	; 23,$8fd16b,$000a,$f300
	; 24,$8bc620,$04cf,$f300
	; 25,$87be59,$0dd7,$f200
	; 26,$8bc13f,$04d9,$f300
	; 27,$89e98b,$0799,$f300
	; 28,$8cf7c1,$01ec,$f300
	; 29,$8cb57f,$0309,$f300
	; 30,$8d8b77,$01de,$f300
	; 31,$8ebc92,$0185,$f500
	; 32,$89f12c,$0787,$f500
	; 33,$89f12c,$0787,$f500
	; 34,$8a9c48,$06a0,$f500
	; 35,$8ba806,$0530,$f500
	; 36,$8b8609,$05f8,$f500
	; 37,$8cc97f,$02a3,$f500
	; 38,$8bb275,$04fe,$f500
	; 39,$8b97a6,$0592,$f500
	; 40,$8ba2b3,$054b,$f500
	; 41,$8bdd6f,$0457,$f500
	; 42,$8b97a6,$0592,$f500
	; 43,$89b8a5,$08a0,$f500
	; 44,$8a9c48,$06a0,$f500
	; 45,$000000,$0000,$0000
	; 46,$8a957e,$06c2,$f500
	; 47,$8a957e,$06c2,$f500
	; 48,$88a2c5,$0af7,$f500
	; 49,$8a8000,$0764,$f500
	; 50,$898000,$0a18,$f500
	; 51,$898000,$0a18,$f500
	; 52,$88b8ad,$0ae0,$f500
	; 53,$8bd496,$046d,$f500
	; 54,$8be1ce,$0433,$f500
	; 55,$8b8609,$05f8,$f500
	; 56,$8a876c,$0712,$f500
	; 57,$88e351,$0a4a,$f500
	; 58,$89c9a1,$083e,$f500
	; 59,$8abd2e,$0660,$f500
	; 60,$8abd2e,$0660,$f500
	; 61,$8ae2d7,$0621,$f500
	; 62,$000000,$0000,$0000
	; 63,$000000,$0000,$0000
	; 64,$848000,$00c0,$1120
	; 65,$838800,$0020,$1100
	; 66,$8b8c09,$05e0,$1250
	; 67,$858000,$1b00,$1250
	; 68,$88c395,$0ab0,$1250
	; 69,$859b08,$1b00,$1250
	; 70,$89afed,$08b0,$1250
	; 71,$898a20,$0a00,$1250
	; 72,$86cefd,$1160,$1250
	; 73,$83e653,$17d0,$1250

	; APU RAM Map
	; $1100 Sample DIR
	; $11e0 Sample Rate Table
	; $1250 BRR Samples
	; $dc10 Common Tables
	; $f300 Sequence 1 (e.g. Opening)
	; $f500 Sequence 2 (e.g. Player Select)

	; queue message #7
	lda	#7
	jsl	$80fe74

	; queue "stop playback"
	lda	#$ff02
	jsl	$80fe74

	; queue "transfer #1" (Common Tables)
	lda	PARAM_TABLES
	and	#$00ff
	jsl	$80c7f6

	; queue "play song #48" ?
	lda	#$3001
	jsl	$80fe74

	; queue "transfer #64" (Sample DIR)
	lda	#$40
	jsl	$80c7f6

	; queue "transfer #65" (Sample DIR)
	lda	#$41
	jsl	$80c7f6

	; queue "transfer #3" (Opening Theme)
	lda	PARAM_SOUND_BANK
	and	#$00ff
	jsl	$80c7f6

	; queue "stereo mode"
	lda	#5
	jsl	$80fe74

	; queue playback message (#$xx01)
	sep	#$20
	lda	PARAM_SONG
	xba
	lda	#1
	rep	#$20
	jsl	$80fe74

loc_MainLoop:
	rep	#$20

	; wait for vblank
	lda	$0100
	beq	loc_MainLoop

	; dispatch queued APU messages
	jsl	$80c5ec

	stz	$0100
	bra	loc_MainLoop

VBlank:
	rep	#$20
	phb
	phd
	pha
	phx
	phy

	; clear NMI flag
	sep	#$20
	lda	$4210

	lda	$000100
	beq	loc_VBlankRoutine
	jmp	loc_VBlankFinish

loc_VBlankRoutine:
	inc	a
	sta	$000100

loc_VBlankFinish:
	rep	#$20
	ply
	plx
	pla
	pld
	plb
	rti

EmptyHandler:
	rti

.ENDS
