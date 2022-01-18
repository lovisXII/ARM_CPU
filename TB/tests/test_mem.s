/*----------------------------------------------------------------
//           test loop                                          //
----------------------------------------------------------------*/
    .text
    .globl    _start
_start:

    mov r0, #10
    mov r1, #1
    mov r2, #0x80000000
    mov r3, r2
//fill a table with the integers in order
_loop1_start:
    str   r1, [r3, #-4]!
    add  r1, r1, #1
    subs r0, r0, #1
    bne  _loop1_start
//add the table
    mov r0, #10
_loop2_start:
    ldr   r1, [r2, #-4]!
    add  r4, r4, r1
    subs r0, r0, #1
    bne  _loop2_start
    cmp  r4, #55
    /* 0x00 Reset Interrupt vector address */
    beq    _good

    /* 0x04 Undefined Instruction Interrupt vector address */
    b    _bad
    nop
_bad :
    add r0, r0, r0
_good :
    add r1, r1, r1
