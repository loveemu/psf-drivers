/***************************************************************************/
/*
** PSF-o-Cycle development system
**
** This is an example which demonstrates the basics of how to make a PSF
** driver stub and illustrates the format of the PSF_DRIVER_INFO block.
** It can be customized to create stubs for actual games (whether they use
** the SEQ/VAB library or not).
*/

/*
** Define the location of the PSF driver stub.
** You should define this to somewhere safe where there's no useful data and
** which will not get overwritten by the BSS clear loop.
*/
#define PSFDRV_LOAD         (0x800F7000)
#define PSFDRV_SIZE         (0x00000800)
#define PSFDRV_PARAM        (0x800F7800)
#define PSFDRV_PARAM_SIZE   (0x00000100)
#define MINIPSF_PARAM       (0x80075800)

/*
** You can also define locations of game-specific data here.
*/
#define GM_CD       (0x80010000)
#define GM_CD_SIZE  (0x000E8000)
#define GM_PAC      (0x800FE000)
#define GM_PAC_SIZE (0x00062000) // don't know the exact upper limit

/*
** Parameters - you can make up any parameters you want within the
** PSFDRV_PARAM block.
** In this example, I'm including the sequence volume, reverb type and depth.
*/
#define PARAM_RTYPE     (*((unsigned char*)(PSFDRV_PARAM+0x0000)))
#define PARAM_RDEPTH    (*((unsigned char*)(PSFDRV_PARAM+0x0001)))
#define PARAM_PLAY_A0   (*(unsigned short*)(MINIPSF_PARAM+0x0000))
#define PARAM_PLAY_A1   (*(unsigned short*)(MINIPSF_PARAM+0x0002))
#define PARAM_PLAY_A2   (*(unsigned short*)(MINIPSF_PARAM+0x0004))
#define PARAM_PLAY_A3   (*(unsigned short*)(MINIPSF_PARAM+0x0008))

/***************************************************************************/
/*
** Entry point
*/
int psfdrv(void);
int psfdrv_entry(void) {
  /*
  ** Read the entire driver area, to ensure it doesn't get thrown out by
  ** PSFLab's optimizer
  */
  int *a = ((int*)(PSFDRV_LOAD));
  int *b = ((int*)(PSFDRV_LOAD+PSFDRV_SIZE));
  int c = 0;
  while(a < b) { c += (*a++); }
  /* This return value is completely ignored. */
  return c + psfdrv();
}

/***************************************************************************/

#define ASCSIG(a,b,c,d) ( \
  ((((unsigned long)(a)) & 0xFF) <<  0) | \
  ((((unsigned long)(b)) & 0xFF) <<  8) | \
  ((((unsigned long)(c)) & 0xFF) << 16) | \
  ((((unsigned long)(d)) & 0xFF) << 24)   \
  )

/***************************************************************************/
/*
** PSF_DRIVER_INFO block.
*/
unsigned long driverinfo[] = {
  /*
  ** Signature
  */
  ASCSIG('P','S','F','_'),
  ASCSIG('D','R','I','V'),
  ASCSIG('E','R','_','I'),
  ASCSIG('N','F','O',':'),
  /*
  ** Driver load address (was #defined earlier)
  */
  PSFDRV_LOAD,
  /*
  ** Driver entry point
  */
  (int)psfdrv_entry,
  /*
  ** Driver text string.  This should include the name of the game.
  */
  (int)"Hokuto no Ken psf driver v1.0",
  /*
  ** Original EXE filename and CRC - ignore if zero
  **
  ** You may not want to use the exact original EXE here.  Sometimes you may
  ** want to patch the BSS clearing loop first, to ensure that it doesn't
  ** overwrite your driver stub, SEQ data, or other data that you added after
  ** the fact.  In this case I usually use a different name for the patched
  ** EXE, i.e. "ff8patch.exe" for Final Fantasy 8, and redo the CRC
  ** accordingly.
  */
  (int)"SLPS_029.93", 0x2A0D37A4,
  /*
  ** Jump patch address
  ** You should change this to point to the address of the "jal main"
  ** instruction in the game's original EXE.
  */
  0x8005B7E0,
  /*
  ** List of song-specific areas we DO NOT upgrade.
  ** This is a 0-terminated list of addresses and byte lengths.
  ** Mark the areas containing SEQ, VAB, or other song-specific data here.
  ** Marking the psfdrv parameter area here might also be a good idea.
  */
  //GM_CD, GM_CD_SIZE,
  GM_PAC, GM_PAC_SIZE,
  PSFDRV_PARAM, PSFDRV_PARAM_SIZE,
  0,
  /*
  ** List of parameters (name,address,bytesize)
  ** This is a 0-terminated list.
  */
  (int)"rtype" , (int)(&PARAM_RTYPE ), 1,
  (int)"rdepth", (int)(&PARAM_RDEPTH), 1,
  0
};

/***************************************************************************/
/*
** Handy definitions
*/
#define NULL (0)

#define F0(x) (*((func0)(x)))
#define F1(x) (*((func1)(x)))
#define F2(x) (*((func2)(x)))
#define F3(x) (*((func3)(x)))
#define F4(x) (*((func4)(x)))
typedef int (*func0)(void);
typedef int (*func1)(int);
typedef int (*func2)(int,int);
typedef int (*func3)(int,int,int);
typedef int (*func4)(int,int,int,int);

/*
** die() function - emits a break instruction.
** This isn't emulated in Highly Experimental, so it will cause the emulation
** to halt (this is a desired effect).
*/
unsigned long die_data[] = {0x4D};
#define die F0(die_data)

/*
** loopforever() - emits a simple branch and nop.
** Guaranteed to be detected as idle in H.E. no matter what the compiler
** does.
*/
unsigned long loopforever_data[] = {0x1000FFFF,0};
#define loopforever F0(loopforever_data)

#define ASSERT(x) { if(!(x)) { die(); } }

/***************************************************************************/
/*
** Library call addresses.
**
** You'll want to fill in the proper addresses for these based on what you
** found in IDA Pro or similar.
**
** I left some numbers from a previous rip in here just to make the example
** look pretty.  Trust me, you will want to change these.
*/
  #define ResetCallback                          F0(0x80051C14)

  #define SsInit                                 F0(0x80052844)
  #define SsInitHot                              F0(0x8005B8C8)
  #define SsSetMVol(a,b)                         F2(0x80052A04) ((int)(a),(int)(b))
  #define SsSetRVol(a,b)                         F2(0x80052A54) ((int)(a),(int)(b))

  #define SsStart                                F0(0x80052D14)
  #define SsSetTickMode(a)                       F1(0x800540A4) ((int)(a))

  #define SsUtSetReverbType(a)         ((short)( F1(0x80054F24) ((int)(a)) ))
  #define SsUtSetReverbDepth(a,b)      ((short)( F2(0x80054E94) ((int)(a),(int)(b)) ))
  #define SsUtReverbOff                          F0(0x80054FC4)
  #define SsUtReverbOn                           F0(0x80054FE4)
  #define SsVabOpenHeadSticky(a,b,c)   ((short)( F3(0x80057D54) ((int)(a),(int)(b),(int)(c)) ))
  #define SsVabTransBody(a,b)          ((short)( F2(0x800581B4) ((int)(a),(int)(b)) ))

  #define SsVabTransCompleted(a)       ((short)( F1(0x80058274) ((int)(a)) ))

  #define SpuSetReverb(a)                        F1(0x80059854) ((int)(a))
  #define SpuSetReverbModeParam(a)               F1(0x80059A54) ((int)(a))
  #define SpuSetReverbDepth(a)                   F1(0x8005A404) ((int)(a))
  #define SpuSetReverbVoice(a,b)                 F2(0x8005A484) ((int)(a),(int)(b))

  #define HokutoSsInitHot(a)                     F1(0x800136CC) ((int)(a))
  #define HokutoSsStart                          F0(0x800117D8)
  #define HokutoSsOpenPac(a,b)                   F2(0x80012808) ((int)(a),(int)(b))
  #define HokutoSsPlaySeq(a,b,c,d)               F4(0x8003B714) ((int)(a),(int)(b),(int)(c),(int)(d))

/***************************************************************************/
/*
** PSF driver main() replacement
*/
int psfdrv(void) {
  void *pac;
  int rtype;
  int rdepth;
  int r;
  int play_a0;
  int play_a1;
  int play_a2;
  int play_a3;

  pac = (void*)(GM_PAC);

  /*
  ** Retrieve parameters and set useful defaults if they're zero
  */
  rtype  = PARAM_RTYPE;
  rdepth = PARAM_RDEPTH;

  /*
  ** Retrieve parameters for playback function
  */
  play_a0 = PARAM_PLAY_A0; /* 0 (driver seems to ignore this parameter, perhaps) */
  play_a1 = PARAM_PLAY_A1; /* target set (0 for BGM, maybe reverse-order of the file order?) */
  play_a2 = PARAM_PLAY_A2; /* target song (index of DMF sequence) */
  play_a3 = PARAM_PLAY_A3; /* loading method? (seems to be 1 for BGM, 0 for others) */

  /*
  ** Initialize and startup stuff (comes from original main routine)
  */
  //ResetCallback();
  SsInit();
  SsInitHot(); // since HokutoSsInitHot(0) contains MemCard things
  HokutoSsStart();

  /*
  ** Reverb setup
  ** Actually the game already has set the reverb parameters
  ** during the initialization above. Anyway, here it is.
  */
  if (rtype != 0 || rdepth != 0)
  {
    if(!rtype)  rtype = 4;
    if(!rdepth) rdepth = 0;

    SsUtReverbOff();
    //SsSetRVol(0x20, 0x20);
    SsUtSetReverbType(rtype);
    SsUtSetReverbDepth(rdepth, rdepth);
    SsUtReverbOn();
  }

  /*
  ** Load the PAC
  */
  r = HokutoSsOpenPac(pac, 15);
  ASSERT(r == 0);

  /*
  ** Play the DMF
  */
  HokutoSsPlaySeq(play_a0, play_a1, play_a2, play_a3);

  /*
  ** Loop a while.
  */
  loopforever();

  return 0;
}

/***************************************************************************/
