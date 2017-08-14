regs = [
    (0x4000000, "DISPCNT", "LCD Control (Read/Write)"),
    (0x4000004, "DISPSTAT", "General LCD Status (Read/Write)"),
    (0x4000006, "VCOUNT", "Vertical Counter (Read only)"),
    (0x4000008, "BG0CNT", "BG0 Control"),
    (0x400000a, "BG1CNT", "BG1 Control"),
    (0x400000c, "BG2CNT", "BG2 Control"),
    (0x400000e, "BG3CNT", "BG3 Control"),
    (0x4000010, "BG0HOFS", "BG0 X-Offset"),
    (0x4000012, "BG0VOFS", "BG0 Y-Offset"),
    (0x4000014, "BG1HOFS", "BG1 X-Offset"),
    (0x4000016, "BG1VOFS", "BG1 Y-Offset"),
    (0x4000018, "BG2HOFS", "BG2 X-Offset"),
    (0x400001a, "BG2VOFS", "BG2 Y-Offset"),
    (0x400001c, "BG3HOFS", "BG3 X-Offset"),
    (0x400001e, "BG3VOFS", "BG3 Y-Offset"),
    (0x4000020, "BG2PA", "BG2 Rotation/Scaling Parameter A (dx)"),
    (0x4000022, "BG2PB", "BG2 Rotation/Scaling Parameter B (dmx)"),
    (0x4000024, "BG2PC", "BG2 Rotation/Scaling Parameter C (dy)"),
    (0x4000026, "BG2PD", "BG2 Rotation/Scaling Parameter D (dmy)"),
    (0x4000028, "BG2X", "BG2 Reference Point X-Coordinate"),
    (0x400002c, "BG2Y", "BG2 Reference Point Y-Coordinate"),
    (0x4000030, "BG3PA", "BG3 Rotation/Scaling Parameter A (dx)"),
    (0x4000032, "BG3PB", "BG3 Rotation/Scaling Parameter B (dmx)"),
    (0x4000034, "BG3PC", "BG3 Rotation/Scaling Parameter C (dy)"),
    (0x4000036, "BG3PD", "BG3 Rotation/Scaling Parameter D (dmy)"),
    (0x4000038, "BG3X", "BG3 Reference Point X-Coordinate"),
    (0x400003c, "BG3Y", "BG3 Reference Point Y-Coordinate"),
    (0x4000040, "WIN0H", "Window 0 Horizontal Dimensions"),
    (0x4000042, "WIN1H", "Window 1 Horizontal Dimensions"),
    (0x4000044, "WIN0V", "Window 0 Vertical Dimensions"),
    (0x4000046, "WIN1V", "Window 1 Vertical Dimensions"),
    (0x4000048, "WININ", "Inside of Window 0 and 1"),
    (0x400004a, "WINOUT", "Inside of OBJ Window & Outside of Windows"),
    (0x400004c, "MOSAIC", "Mosaic Size"),
    (0x4000050, "BLDCNT", "Color Special Effects Selection"),
    (0x4000052, "BLDALPHA", "Alpha Blending Coefficients"),
    (0x4000054, "BLDY", "Brightness (Fade-In/Out) Coefficient"),
    (0x4000060, "DISP3DCNT", "3D Display Control Register (R/W)"),
    (0x4000064, "DISPCAPCNT", "Display Capture Control Register (R/W)"),
    (0x4000068, "DISP_MMEM_FIFO", "Main Memory Display FIFO (R?/W)"),
    (0x400006c, "MASTER_BRIGHT", "Master Brightness Up/Down"),
    (0x40000b0, "DMA0SAD", "DMA 0 Source Address"),
    (0x40000b4, "DMA0DAD", "DMA 0 Destination Address"),
    (0x40000b8, "DMA0CNT_L", "DMA 0 Word Count"),
    (0x40000ba, "DMA0CNT_H", "DMA 0 Control"),
    (0x40000bc, "DMA1SAD", "DMA 1 Source Address"),
    (0x40000c0, "DMA1DAD", "DMA 1 Destination Address"),
    (0x40000c4, "DMA1CNT_L", "DMA 1 Word Count"),
    (0x40000c6, "DMA1CNT_H", "DMA 1 Control"),
    (0x40000c8, "DMA2SAD", "DMA 2 Source Address"),
    (0x40000cc, "DMA2DAD", "DMA 2 Destination Address"),
    (0x40000d0, "DMA2CNT_L", "DMA 2 Word Count"),
    (0x40000d2, "DMA2CNT_H", "DMA 2 Control"),
    (0x40000d4, "DMA3SAD", "DMA 3 Source Address"),
    (0x40000d8, "DMA3DAD", "DMA 3 Destination Address"),
    (0x40000dc, "DMA3CNT_L", "DMA 3 Word Count"),
    (0x40000de, "DMA3CNT_H", "DMA 3 Control"),
    (0x40000e0, "DMA0FILL", "DMA 0 Filldata"),
    (0x40000e4, "DMA1FILL", "DMA 1 Filldata"),
    (0x40000e8, "DMA2FILL", "DMA 2 Filldata"),
    (0x40000ec, "DMA3FILL", "DMA 3 Filldata"),
    (0x4000100, "TM0D", "Timer 0 Counter/Reload"),
    (0x4000102, "TM0CNT", "Timer 0 Control"),
    (0x4000104, "TM1D", "Timer 1 Counter/Reload"),
    (0x4000106, "TM1CNT", "Timer 1 Control"),
    (0x4000108, "TM2D", "Timer 2 Counter/Reload"),
    (0x400010a, "TM2CNT", "Timer 2 Control"),
    (0x400010c, "TM3D", "Timer 3 Counter/Reload"),
    (0x400010e, "TM3CNT", "Timer 3 Control"),
    (0x4000130, "KEYINPUT", "Key Status"),
    (0x4000132, "KEYCNT", "Key Interrupt Control"),
    (0x4000180, "IPCSYNC", "IPC Synchronize Register (R/W)"),
    (0x4000184, "IPCFIFOCNT", "IPC Fifo Control Register (R/W)"),
    (0x4000188, "IPCFIFOSEND", "IPC Send Fifo (W)"),
    (0x40001a0, "AUXSPICNT", "Gamecard ROM and SPI Control"),
    (0x40001a2, "AUXSPIDATA", "Gamecard SPI Bus Data/Strobe"),
    (0x40001a4, "CARD_CR2", "Gamecard bus timing/control"),
    (0x40001a8, "CARD_COMMAND", "Gamecard bus 8-byte command out"),
    (0x40001b0, "CARD_1B0", "Gamecard Encryption Seed 0 Lower 32bit"),
    (0x40001b4, "CARD_1B4", "Gamecard Encryption Seed 1 Lower 32bit"),
    (0x40001b8, "CARD_1B8", "Gamecard Encryption Seed 0 Upper 7bit (bit7-15 unused)"),
    (0x40001ba, "CARD_1BA", "Gamecard Encryption Seed 1 Upper 7bit (bit7-15 unused)"),
    (0x4000204, "EXMEMCNT", "External Memory Control (R/W)"),
    (0x4000208, "IME", "Interrupt Master Enable (R/W)"),
    (0x4000210, "IE", "Interrupt Enable (R/W)"),
    (0x4000214, "IF", "Interrupt Request Flags (R/W)"),
    (0x4000240, "VRAMCNT_A", "VRAM-A (128K) Bank Control (W)"),
    (0x4000241, "VRAMCNT_B", "VRAM-B (128K) Bank Control (W)"),
    (0x4000242, "VRAMCNT_C", "VRAM-C (128K) Bank Control (W)"),
    (0x4000243, "VRAMCNT_D", "VRAM-D (128K) Bank Control (W)"),
    (0x4000244, "VRAMCNT_E", "VRAM-E (64K) Bank Control (W)"),
    (0x4000245, "VRAMCNT_F", "VRAM-F (16K) Bank Control (W)"),
    (0x4000246, "VRAMCNT_G", "VRAM-G (16K) Bank Control (W)"),
    (0x4000247, "WRAMCNT", "WRAM Bank Control (W)"),
    (0x4000248, "VRAMCNT_H", "VRAM-H (32K) Bank Control (W)"),
    (0x4000249, "VRAMCNT_I", "VRAM-I (16K) Bank Control (W)"),
    (0x4000280, "DIVCNT", "Division Control (R/W)"),
    (0x4000290, "DIV_NUMER", "Division Numerator (R/W)"),
    (0x4000298, "DIV_DENOM", "Division Denominator (R/W)"),
    (0x40002a0, "DIV_RESULT", "Division Quotient (=Numer/Denom) (R)"),
    (0x40002a8, "DIVREM_RESULT", "Division Remainder (=Numer MOD Denom) (R)"),
    (0x40002b0, "SQRTCNT", "Square Root Control (R/W)"),
    (0x40002b4, "SQRT_RESULT", "Square Root Result (R)"),
    (0x40002b8, "SQRT_PARAM", "Square Root Parameter Input (R/W)"),
    (0x4000300, "POSTFLG", ""),
    (0x4000304, "POWCNT1", "Graphics Power Control Register (R/W)"),
    (0x4000320, "RDLINES_COUNT", "Rendered Line Count Register (R)"),
    (0x4000330, "EDGE_COLOR", "Edge Colors 0..7 (W)"),
    (0x4000340, "ALPHA_TEST_REF", "Alpha-Test Comparision Value (W)"),
    (0x4000350, "CLEAR_COLOR", "Clear Color Attribute Register (W)"),
    (0x4000354, "CLEAR_DEPTH", "Clear Depth Register (W)"),
    (0x4000356, "CLRIMAGE_OFFSET", "Rear-plane Bitmap Scroll Offsets (W)"),
    (0x4000358, "FOG_COLOR", "Fog Color (W)"),
    (0x400035c, "FOG_OFFSET", "Fog Depth Offset (W)"),
    (0x4000360, "FOG_TABLE", "Fog Density Table, 32 entries (W)"),
    (0x4000380, "TOON_TABLE", "Toon Table, 32 colors (W)"),
    (0x4000400, "GXFIFO", "Geometry Command FIFO (W)"),
    (0x4000440, "MTX_MODE", "Set Matrix Mode (W)"),
    (0x4000444, "MTX_PUSH", "Push Current Matrix on Stack (W)"),
    (0x4000448, "MTX_POP", "Pop Current Matrix from Stack (W)"),
    (0x400044c, "MTX_STORE", "Store Current Matrix on Stack (W)"),
    (0x4000450, "MTX_RESTORE", "Restore Current Matrix from Stack (W)"),
    (0x4000454, "MTX_IDENTITY", "Load Unit Matrix to Current Matrix (W)"),
    (0x4000458, "MTX_LOAD_4x4", "Load 4x4 Matrix to Current Matrix (W)"),
    (0x400045c, "MTX_LOAD_4x3", "Load 4x3 Matrix to Current Matrix (W)"),
    (0x4000460, "MTX_MULT_4x4", "Multiply Current Matrix by 4x4 Matrix (W)"),
    (0x4000464, "MTX_MULT_4x3", "Multiply Current Matrix by 4x3 Matrix (W)"),
    (0x4000468, "MTX_MULT_3x3", "Multiply Current Matrix by 3x3 Matrix (W)"),
    (0x400046c, "MTX_SCALE", "Multiply Current Matrix by Scale Matrix (W)"),
    (0x4000470, "MTX_TRANS", "Mult. Curr. Matrix by Translation Matrix (W)"),
    (0x4000480, "COLOR", "Directly Set Vertex Color (W)"),
    (0x4000484, "NORMAL", "Set Normal Vector (W)"),
    (0x4000488, "TEXCOORD", "Set Texture Coordinates (W)"),
    (0x400048c, "VTX_16", "Set Vertex XYZ Coordinates (W)"),
    (0x4000490, "VTX_10", "Set Vertex XYZ Coordinates (W)"),
    (0x4000494, "VTX_XY", "Set Vertex XY Coordinates (W)"),
    (0x4000498, "VTX_XZ", "Set Vertex XZ Coordinates (W)"),
    (0x400049c, "VTX_YZ", "Set Vertex YZ Coordinates (W)"),
    (0x40004a0, "VTX_DIFF", "Set Relative Vertex Coordinates (W)"),
    (0x40004a4, "POLYGON_ATTR", "Set Polygon Attributes (W)"),
    (0x40004a8, "TEXIMAGE_PARAM", "Set Texture Parameters (W)"),
    (0x40004ac, "PLTT_BASE", "Set Texture Palette Base Address (W)"),
    (0x40004c0, "DIF_AMB", "MaterialColor0 - Diffuse/Ambient Reflect. (W)"),
    (0x40004c4, "SPE_EMI", "MaterialColor1 - Specular Ref. & Emission (W)"),
    (0x40004c8, "LIGHT_VECTOR", "Set Light's Directional Vector (W)"),
    (0x40004cc, "LIGHT_COLOR", "Set Light Color (W)"),
    (0x40004d0, "SHININESS", "Specular Reflection Shininess Table (W)"),
    (0x4000500, "BEGIN_VTXS", "Start of Vertex List (W)"),
    (0x4000504, "END_VTXS", "End of Vertex List (W)"),
    (0x4000540, "SWAP_BUFFERS", "Swap Rendering Engine Buffer (W)"),
    (0x4000580, "VIEWPORT", "Set Viewport (W)"),
    (0x40005c0, "BOX_TEST", "Test if Cuboid Sits inside View Volume (W)"),
    (0x40005c4, "POS_TEST", "Set Position Coordinates for Test (W)"),
    (0x40005c8, "VEC_TEST", "Set Directional Vector for Test (W)"),
    (0x4000600, "GXSTAT", "Geometry Engine Status Register (R and R/W)"),
    (0x4000604, "RAM_COUNT", "Polygon List & Vertex RAM Count Register (R)"),
    (0x4000610, "DISP_1DOT_DEPTH", "1-Dot Polygon Display Boundary Depth (W)"),
    (0x4000620, "POS_RESULT", "Position Test Results (R)"),
    (0x4000630, "VEC_RESULT", "Vector Test Results (R) "),
    (0x4000640, "CLIPMTX_RESULT", "Read Current Clip Coordinates Matrix (R)"),
    (0x4000680, "VECMTX_RESULT", "Read Current Directional Vector Matrix (R)"),
    (0x4001000, "DISPCNT_SUB", "LCD Control (Read/Write)"),
    (0x4001008, "BG0CNT_SUB", "BG0 Control"),
    (0x400100a, "BG1CNT_SUB", "BG1 Control"),
    (0x400100c, "BG2CNT_SUB", "BG2 Control"),
    (0x400100e, "BG3CNT_SUB", "BG3 Control"),
    (0x4001010, "BG0HOFS_SUB", "BG0 X-Offset"),
    (0x4001012, "BG0VOFS_SUB", "BG0 Y-Offset"),
    (0x4001014, "BG1HOFS_SUB", "BG1 X-Offset"),
    (0x4001016, "BG1VOFS_SUB", "BG1 Y-Offset"),
    (0x4001018, "BG2HOFS_SUB", "BG2 X-Offset"),
    (0x400101a, "BG2VOFS_SUB", "BG2 Y-Offset"),
    (0x400101c, "BG3HOFS_SUB", "BG3 X-Offset"),
    (0x400101e, "BG3VOFS_SUB", "BG3 Y-Offset"),
    (0x4001020, "BG2PA_SUB", "BG2 Rotation/Scaling Parameter A (dx)"),
    (0x4001022, "BG2PB_SUB", "BG2 Rotation/Scaling Parameter B (dmx)"),
    (0x4001024, "BG2PC_SUB", "BG2 Rotation/Scaling Parameter C (dy)"),
    (0x4001026, "BG2PD_SUB", "BG2 Rotation/Scaling Parameter D (dmy)"),
    (0x4001028, "BG2X_SUB", "BG2 Reference Point X-Coordinate"),
    (0x400102c, "BG2Y_SUB", "BG2 Reference Point Y-Coordinate"),
    (0x4001030, "BG3PA_SUB", "BG3 Rotation/Scaling Parameter A (dx)"),
    (0x4001032, "BG3PB_SUB", "BG3 Rotation/Scaling Parameter B (dmx)"),
    (0x4001034, "BG3PC_SUB", "BG3 Rotation/Scaling Parameter C (dy)"),
    (0x4001036, "BG3PD_SUB", "BG3 Rotation/Scaling Parameter D (dmy)"),
    (0x4001038, "BG3X_SUB", "BG3 Reference Point X-Coordinate"),
    (0x400103c, "BG3Y_SUB", "BG3 Reference Point Y-Coordinate"),
    (0x4001040, "WIN0H_SUB", "Window 0 Horizontal Dimensions"),
    (0x4001042, "WIN1H_SUB", "Window 1 Horizontal Dimensions"),
    (0x4001044, "WIN0V_SUB", "Window 0 Vertical Dimensions"),
    (0x4001046, "WIN1V_SUB", "Window 1 Vertical Dimensions"),
    (0x4001048, "WININ_SUB", "Inside of Window 0 and 1"),
    (0x400104a, "WINOUT_SUB", "Inside of OBJ Window & Outside of Windows"),
    (0x400104c, "MOSAIC_SUB", "Mosaic Size"),
    (0x4001050, "BLDCNT_SUB", "Color Special Effects Selection"),
    (0x4001052, "BLDALPHA_SUB", "Alpha Blending Coefficients"),
    (0x4001054, "BLDY_SUB", "Brightness (Fade-In/Out) Coefficient"),
    (0x400106c, "MASTER_BRIGHT_SUB", "Master Brightness Up/Down"),
    (0x4100000, "IPCFIFORECV", "IPC Receive Fifo (R)"),
    (0x4100010, "CARD_DATA_RD", "Gamecard bus 4-byte data in, for manual or dma read"),
]

for (ea, name, comment) in regs:
    idc.MakeName(ea, name)
    idc.MakeRptCmt(ea, comment)
