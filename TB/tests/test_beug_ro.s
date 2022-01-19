/*----------------------------------------------------------------
//           Mon premier programme                              //
----------------------------------------------------------------*/
    .text
    .globl    _start
_start:
    /* 0x00 Reset Interrupt vector address */
    
    mov r0, #10
    ldr   r1, [r3]
    b    _good

    /* 0x04 Undefined Instruction Interrupt vector address */
    b    _bad
    nop 

_bad :
    add r0, r0, r0
_good :
    add r1, r1, r1

