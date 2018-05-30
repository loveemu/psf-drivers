.text
.thumb
.align 2
gsf_main:
	@ 08000328 Install IRQHandler via DMA3

	@ Link DMA1/2 to DirectSound FIFO and activate them
	bl	InitializeSound

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
InitializeSound: @ 0x802395C
	swi	3

PlayBGM: @ 0x8023E9C
	@ Patching 08023EEA is required for oneshot song
	@ movs	r1, #1
	@ to
	@ movs	r1, #0
	swi	3

PlaySFX: @ 0x8023CB8
	swi	3
