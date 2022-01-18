/*----------------------------------------------------------------
//           Mon premier programme                              //
----------------------------------------------------------------*/
    .text
    .globl    _start
_start:
    /* 0x00 Reset Interrupt vector address */
    adds r1,r0,#15 //r1 =15
    adds r2,r0,#15 //r2 =15
    adds r3,r0,#15 //r3 =15
    adds r4,r0,#15 //r4 =15
    adds r5,r0,#15 //r5 =15
    adds r6,r0,#25 //r6 =25
    adds r7,r0,#35 //r7 =35
    adds r8,r0,#55 //r8 =55
    adds r9,r0,#15 //r9 =15
    adds r10,r0,#15 //r10 =15
    adds r11,r0,#52 //r11 =52
    adds r12,r0,#85 //r12 =85
    
    andeqs r2,r1,r0 // ne fait rien
    subs r2,r2,r0 // r2-r0 => r2 = 15
    rsbs r1,r0,#4 // 4-r0 => r1 = 4
    adcs r5,r0,r1,LSL #3 // r1*8 = 32, 
    sbcs r3,r1,r12 // rn-op2+c-1, r1-r12+0-1, 32-85-1= -58
    tst r10,r0 // stup flag pour 0x 0000 0000
    adds r3,r3,#-58 // -58+58 
    bne    _good

    /* 0x04 Undefined Instruction Interrupt vector address */
    b    _bad
    nop 

_bad :
    add r0, r0, r0
_good :
    add r1, r1, r1
