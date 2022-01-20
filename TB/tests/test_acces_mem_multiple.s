/*----------------------------------------------------------------
//           Mon premier programme                              //
----------------------------------------------------------------*/
    .text
    .globl    _start
_start:
    /* 0x00 Reset Interrupt vector address */
    mov r0, #0x80000000
    sub r0, r0, #4  //r0 = 7FFFFFFC
    mov r1, r0 // r1 = 7FFFFFFC
    mov r2, #2 // r2 = 2
    mov r3, #3 // r3 = 3
    stmda r1!,{r2,r3} // @7FFFFFFC = r2, @7FFFFFF8 = r3
    ldmda r0!, {r1,r2}
    cmp r1, #2
    beq    _good
    /* 0x04 Undefined Instruction Interrupt vector address */
    b    _bad
    nop 

_bad :
    add r0, r0, r0
_good :
    add r1, r1, r1
