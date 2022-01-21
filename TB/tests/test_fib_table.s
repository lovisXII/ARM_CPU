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
        .file   "test_fib_table.c"
#APP
        mov sp, #0x80000000
        sub sp, sp, #4
        .text
        .align  2
        .global main
        .type   main, %function
main:
        @ args = 0, pretend = 0, frame = 88
        @ frame_needed = 1, uses_anonymous_args = 0
        stmfd   sp!, {fp, lr}
        add     fp, sp, #4
        sub     sp, sp, #88
        sub     r2, fp, #88
        mov     r3, #80
        mov     r0, r2
        mov     r1, #0
        mov     r2, r3
        //bl      memset comment memset cause we dont have memset
        mov     r3, #0
        str     r3, [fp, #-88]
        mov     r3, #1
        str     r3, [fp, #-84]
        mov     r3, #2
        str     r3, [fp, #-8]
        b       .L2
.L3:
        ldr     r3, [fp, #-8]
        sub     r2, r3, #1
        mvn     r3, #83
        mov     r2, r2, asl #2
        sub     r0, fp, #4
        add     r2, r0, r2
        add     r3, r2, r3
        ldr     r2, [r3]
        ldr     r3, [fp, #-8]
        sub     r1, r3, #2
        mvn     r3, #83
        mov     r1, r1, asl #2
        sub     r0, fp, #4
        add     r1, r0, r1
        add     r3, r1, r3
        ldr     r3, [r3]
        add     r2, r2, r3
        ldr     r1, [fp, #-8]
        mvn     r3, #83
        mov     r1, r1, asl #2
        sub     r0, fp, #4
        add     r1, r0, r1
        add     r3, r1, r3
        str     r2, [r3]
        ldr     r3, [fp, #-8]
        add     r3, r3, #1
        str     r3, [fp, #-8]
.L2:
        ldr     r3, [fp, #-8]
        cmp     r3, #19
        ble     .L3
        ldr     r2, [fp, #-12]
        mov     r3, #4160
        add     r3, r3, #21
        cmp     r2, r3
        bne     .L4
        bl      _good
        b       .L6
.L4:
        bl      _bad
.L6:
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


