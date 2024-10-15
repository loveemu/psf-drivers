The Blue Crystal Rod SNSF - Technical Notes
===========================================

The Blue Crystal Rod is a adventure game released in 1994 for Super Famicom only in Japan.
The game was developed and published by Namco.

Junko Ozawa is the composer of the game's soundtrack as well as the sound programmer.
Her driver is also used in other Namco SFC game titles such as Wagan Paradise.

## Sound Data

A list of addresses of sound data to be transferred to SHVC-SOUND is available at $00:9C6E.

|Index |Address |Bank |Comment|
|------|--------|-----|-------|
|0     |$8000   |$34  |Kingdom of Babylim|
|1     |$8EAB   |$34  |Sample Patch (Kingdom of Babylim, Tower of Druaga, Castle Town)|
|2     |$8000   |$3A  |Sumar Empire|
|3     |$8D50   |$3A  |Sample Patch (Beginning of Story, Sumar Empire, Competition, Epilogue)|
|4     |$8000   |$35  |Sample Patch (Elburz Cave)|
|5     |$93F7   |$35  |Hanging Garden|
|6     |$8000   |$33  |Common Data|
|7     |$8000   |$39  |Storm Mountains|
|8     |$9B3A   |$36  |SE|
|9     |$D803   |$37  |Castle Town|
|10    |$8ABB   |$36  |Beginning of Story|
|11    |$9311   |$36  |Tower of Druaga|
|12    |$8000   |$37  |Sample Patch (Underworld)|
|13    |$8000   |$38  |Opening|
|14    |$C7B2   |$36  |Temple of Ishtar|
|15    |$A775   |$39  |Epilogue|
|16    |$EA4C   |$38  |Competition|
|17    |$F6E0   |$38  |Ziggurat|
|18    |$D3BE   |$36  |Sample Patch (Temple of Ishtar, Ziggurat)|
|19    |$E280   |$3A  |File Selection|
|20    |$B71D   |$39  |Prologue|
|21    |$8B96   |$38  |Sample Patch (Opening, Prologue)|

One or more data transfer packages are placed at the address indicated by the pointer.
Note that multiple forwarding destinations can be defined for a single entry.

```
struct SoundDataTransferPackage {
    uint16_t size;          // 0 indicates the end of list
    uint16_t spc_address;
    uint8_t[] data;
};
```

## Initialization and threads

Transfer of driver code is done by calling $00:9197.
This is done relatively soon after the reset.

The game has a virtual thread-like coroutine mechanism,
which is done by frequently updating the stack pointer.
Setup for this is done in $80E9-8134.
The setup registers three threads in the system: $9CF1, $8329, and $B076.
In actual ROM, these values are expressed as -1 less than the above address.

What is important is that $9CF1 is a thread main for sound.
On the other hand, $8329 is the thread main for game progression.
This one can be used to write your own code for SNSF creation.

These threads are executed through the VBlank interrupt.
The game's NMI handler never returns.

Before most music can be played, the common data block must be transferred.
Calling $A02A is an easy way to do this.

## Sound thread

The sound thread monitors the value of $7E:009D and performs processing
according to the byte code value stored there.

A byte code value of 0xff means that nothing has been requested.
When the value is 0x80 or higher, the lower 7 bits are simply sent to the APU.

Otherwise, it is a combination of complex transfers and playback.
The function of each code value is hard-coded after $9D1B.

Switching the execution context of the virtual thread is probably done by $82CA.
