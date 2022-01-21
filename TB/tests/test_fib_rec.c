extern void _bad();
extern void _good();
__asm__("mov sp, #0x80000000");
__asm__("sub sp, sp, #4");

int main() {
    if (fib(10) == 55) {
        _good();
    }
    else {
        _bad();
    }
}

int fib(int n) {
    if (n == 0) {
        return 0;
    }
    else if (n == 1) {
        return 1;
    }
    else {
        return fib(n-1) + fib(n-2);
    }
}

__asm__("nop");
__asm__("_bad:");
__asm__("    add r0, r0, r0");
__asm__("_good :");
__asm__("    add r1, r1, r1");
