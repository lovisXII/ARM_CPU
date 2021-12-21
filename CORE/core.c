#include "stdbool.h"

extern int ghdl_main (int argc, char **argv);


int main(int argc, char const *argv[])
{
    ghdl_main(argc, argv);
    return 0;
}


void interface(char* a, char b, char* c) {
    a[0] = 2;
    a[32] = 2;
}