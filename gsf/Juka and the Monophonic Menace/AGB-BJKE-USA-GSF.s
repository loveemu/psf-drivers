.text
.thumb
.align 2
gsf_main:
	@ do initialization

	ldr	r0, song_index
	ldr	r3, song_type
	cmp	r3, #0
	bne	play_sfx

play_bgm:
	bl	PlayBGM
	b	main_loop

play_sfx:
	bl	PlaySFX

main_loop:
	swi	5                       @ VSyncIntrWait
	b	main_loop

.align 2
song_index:
	.word	0x0e

song_type:
	.word	0                       @ bgm: 0, sfx: 1

.align
	.ascii	"___DRIVER_END___"

.thumb
.align 2
PlayBGM: @ 0x8023E9C
	swi	3

PlaySFX: @ 0x8023CB8
	swi	3
