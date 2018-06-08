@ Medabots AX - Metabee Version GSF driver block (non-portable)
@ written by loveemu <https://github.com/loveemu/psf-drivers>

.text
.thumb
.align 2
gsf_main:
	@ 08000294 IRQ setup has done.

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
	.word	0x1c

song_type:
	.word	0                       @ bgm: 0, sfx: 1

.align
	.ascii	"___DRIVER_END___"

.thumb
.align 2
InitializeSound: @ 0x800062C
	swi	3

PlayBGM: @ 0x8054E08 (or 0x804755C)
	swi	3

PlaySFX: @ 0x8054F3C (or 0x8047584)
	swi	3

SoundMain: @ 0x805368C
	swi	3

@ Purge graphic routines from VBlank callback.
@ VBlankCallback: @ 0x8000410
@	push	{r4,lr}
@	sub	sp, sp, #0x18
@	mov	r1, sp --> b 0x80004CA
