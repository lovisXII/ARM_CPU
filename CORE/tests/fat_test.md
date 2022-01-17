/*----------------------------------------------------------------
//           Mon premier programme                              //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	add r4,r4,LSL #2     0xe0844104
_loop_start :
	STR r4,[r0]  0xe5804000
	LDR r5,[r4]    0xe5945000
	add r0,r0,#4   0xe2800004
	b _loop_start     0xeafffffb







