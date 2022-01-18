/*----------------------------------------------------------------
//           test loop                                          //
----------------------------------------------------------------*/
    .text
    .globl    _start
_start:

    mov r0, #80
    mov r1, #0
_loop_start:
    add  r1, r1, #4
    subs r0, r0, #1
    bne  _loop_start
    cmp  r1, #320
    /* 0x00 Reset Interrupt vector address */
    beq    _good

    /* 0x04 Undefined Instruction Interrupt vector address */
    b    _bad
    nop
_bad :
    add r0, r0, r0
_good :
    add r1, r1, r1
