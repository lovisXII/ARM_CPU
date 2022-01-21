extern void _bad();
extern void _good();
__asm__("mov sp, #0x80000000");
__asm__("sub sp, sp, #4");


int main() {
    int table[20] = {0};
    table[0] = 0;
    table[1] = 1;
    int i = 2;
    for (; i < 20; i++) {
        table[i] = table[i-1] + table[i-2];
    }
    if (table[19] == 4181) {
        _good();
    }
    else {
        _bad();
    }
}

__asm__("nop");
__asm__("_bad:");
__asm__("    add r0, r0, r0");
__asm__("_good :");
__asm__("    add r1, r1, r1");
