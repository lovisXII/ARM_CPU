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
        .file   "test_fib_rec.c"
#APP
        mov sp, #0x80000000
        sub sp, sp, #4
        .text
        .align  2
        .global main
        .type   main, %function
main:
        @ args = 0, pretend = 0, frame = 0
        @ frame_needed = 1, uses_anonymous_args = 0
        stmfd   sp!, {fp, lr}
        add     fp, sp, #4
        mov     r0, #10
        bl      fib
        mov     r3, r0
        cmp     r3, #55
        bne     .L2
        bl      _good
        b       .L4
.L2:
        bl      _bad
.L4:
        mov     r0, r3
        ldmfd   sp!, {fp, pc}
fib:
        stmfd   sp!, {r4, fp, lr}
        add     fp, sp, #8
        sub     sp, sp, #12
        str     r0, [fp, #-16]
        ldr     r3, [fp, #-16]
        cmp     r3, #0
        bne     .L6
        mov     r3, #0
        b       .L7
.L6:
        ldr     r3, [fp, #-16]
        cmp     r3, #1
        bne     .L8
        mov     r3, #1
        b       .L7
.L8:
        ldr     r3, [fp, #-16]
        sub     r3, r3, #1
        mov     r0, r3
        bl      fib
        mov     r4, r0
        ldr     r3, [fp, #-16]
        sub     r3, r3, #2
        mov     r0, r3
        bl      fib
        mov     r3, r0
        add     r3, r4, r3
.L7:
        mov     r0, r3
        sub     sp, fp, #8
        nop
        @ sp needed
        ldmfd   sp!, {r4, fp, pc}
        nop
        nop
        nop
        .size   fib, .-fib
#APP
        nop
        _bad:
            add r0, r0, r0
        _good :
            add r1, r1, r1
        .ident  "GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-16)"
        .section        .note.GNU-stack,"",%progbits
