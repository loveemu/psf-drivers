@ Dragon Ball Z - The Legacy of Goku II GSF driver block (non-portable) [BETA]
@ written by loveemu <https://github.com/loveemu/psf-drivers>

@ Known issue:
@   SFX is unplayable
@   Strange CPU usage

.text
.thumb
.align 2
GSFMain:
	@ 0x80001B4
	@ r0 = local variable?
	bl	SoundInit

	ldr	r0, refSoundPlayer
	ldr	r1, songIndex
	ldr	r3, songType
	cmp	r3, #0
	bne	playSFX

playBGM:
	@ refBGMTableStart[r1 * 20]
	lsl	r3, r1, #2
	add	r1, r3, r1
	lsl	r1, r1, #2
	ldr	r2, refBGMTableStart
	add	r1, r1, r2

	bl	PlayBGM
	b	mainLoop

playSFX:
	@ TODO: does not work at all
	@ refSFXTableStart[r1 * 12]
	lsl	r3, r1, #1
	add	r1, r3, r1
	lsl	r1, r1, #2
	ldr	r2, refSFXTableStart
	add	r1, r1, r2

	ldr	r2, sfxVolume
	mov	r3, #0
	bl	PlaySFX

mainLoop:
	swi	5                       @ VSyncIntrWait
	b	mainLoop

.align 2
songIndex:
	.word	0

songType:
	.word	0                       @ bgm: 0, sfx: 1

sfxVolume:
	.word	0x40

refSoundPlayer:
	.word	0x30026C8

refBGMTableStart:
	.word	0x81D4B2C

refSFXTableStart:
	.word	0x80E15B0

.align
	.ascii	"___DRIVER_END___"

.thumb
.align 2
SoundInit: @ 0x801F248
	swi	3

PlayBGM: @ 0x8020A4C
	swi	3

PlaySFX: @ 0x801FC9C
	swi	3
