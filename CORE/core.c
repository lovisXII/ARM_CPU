
extern int ghdl_main (int argc, char **argv);


int main(int argc, char const *argv[])
{
    ghdl_main(argc, argv);
    return 0;
}


void interface(char* a, char b, char* c) {
    c[0] = 2;
    c[31] = 2;
}