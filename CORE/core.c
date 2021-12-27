
#include <stdlib.h>
#include <stdio.h>

#define MAX_INST 1000
#define MAX_LINE_SIZE 200

int instructions[MAX_INST];
int cur_inst = 0;

int*** mem[256] = {0};


extern int ghdl_main(int argc, char const* argv[]);

int main(int argc, char const* argv[]) {
    char* line_buf = NULL; 
    size_t line_buf_size = 0;
    FILE *file;
    file = fopen(argv[argc - 1], "r");
    printf("opening file : %s\n", argv[argc - 1]);
    if (!file)
  {
    fprintf(stderr, "Error opening file '%s'\n", argv[argc - 1]);
    return EXIT_FAILURE;
  }
    size_t ls = MAX_LINE_SIZE - 5;
    printf("reading instructions\n");
    while (getline(&line_buf, &line_buf_size, file) > 0) {
        printf("%s", line_buf);
        instructions[cur_inst++] = strtol(line_buf, NULL, 16);
    }
    ghdl_main(argc - 1, argv);
    return 0;
}

int get_inst(int a) {
    a = a/4;
    if (a < cur_inst) {
        return instructions[a];
    }
    else {
        return 0; //andez r0, r0, r0
    }
}

int get_mem(int a) {
    int addr1 = a & 0xFF;
    int addr2 = (a >> 8) & 0xFF;
    int addr3 = (a >> 16) & 0xFF;
    int addr4 = (a >> 24) & 0xFF;
    if (mem[addr1] && mem[addr1][addr2] && mem[addr1][addr2][addr3])  return mem[addr1][addr2][addr3][addr4];
    else return 0;
}

int write_mem(int a, int data) {
    int addr1 = a & 0xFF;
    int addr2 = (a >> 8) & 0xFF;
    int addr3 = (a >> 16) & 0xFF;
    int addr4 = (a >> 24) & 0xFF;
    if (!mem[addr1]) mem[addr1] = calloc(256, sizeof(int*));
    if (!mem[addr1][addr2]) mem[addr1][addr2] = calloc(256, sizeof(int*));
    if (!mem[addr1][addr2][addr3]) mem[addr1][addr2][addr3] = calloc(256, sizeof(int));
    mem[addr1][addr2][addr3][addr4] = data;
    return 0;
}