extern void _bad();
extern void _good();
__asm__("mov sp, #0x80000000");
__asm__("sub sp, sp, #4");


int main() {
    int a = 3;
    int b = 4;
    for (;a >= 0; a--) {
        b ++;
    }
    if (b == 3) {
        b = 8;
    }
    else {
        _good();
    }
    _bad();
}

__asm__("nop");
__asm__("_bad:");
__asm__("    add r0, r0, r0");
__asm__("_good :");
__asm__("    add r1, r1, r1");
