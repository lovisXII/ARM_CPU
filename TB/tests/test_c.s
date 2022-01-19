        .arch armv2a
        .fpu softvfp
        .eabi_attribute 20, 1
        .eabi_attribute 21, 1
        .eabi_attribute 23, 3
        .eabi_attribute 24, 1
        .eabi_attribute 25, 1
        .eabi_attribute 26, 2
        .eabi_attribute 30, 6
        .eabi_attribute 34, 0
        .eabi_attribute 18, 4
        .file   "a.c"
#APP
        mov sp, #0x80000000
        sub sp, sp, #4
        .text
        .align  2
        .global main
        .type   main, %function
main:
        @ args = 0, pretend = 0, frame = 8
        @ frame_needed = 1, uses_anonymous_args = 0
        stmfd   sp!, {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #8
        mov     r3, #3
        str     r3, [fp, #-8]
        mov     r3, #4
        str     r3, [fp, #-12]
        b       .L2
.L3:
        ldr     r3, [fp, #-12]
        add     r3, r3, #1
        str     r3, [fp, #-12]
        ldr     r3, [fp, #-8]
        sub     r3, r3, #1
        str     r3, [fp, #-8]
.L2:
        ldr     r3, [fp, #-8]
        cmp     r3, #0
        bge     .L3
        ldr     r3, [fp, #-12]
        cmp     r3, #3
        bne     .L4
        mov     r3, #8
        str     r3, [fp, #-12]
        b       .L5
.L4:
        bl      _good
.L5:
        bl      _bad
        mov     r0, r3
        sub     sp, fp, #4
        @ sp needed
        ldmfd   sp!, {fp, pc}
        .size   main, .-main
#APP
        nop
        _bad:
            add r0, r0, r0
        _good :
            add r1, r1, r1
        .ident  "GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-16)"
        .section        .note.GNU-stack,"",%progbits