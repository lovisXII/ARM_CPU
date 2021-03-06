
#include <stdlib.h>
#include <stdio.h>

#define MAX_INST 1000
#define MAX_LINE_SIZE 200

int instructions[MAX_INST]; //tableau mémoire instructions
int cur_inst = 0;

int*** mem[256] = {0};


extern int ghdl_main(int argc, char const* argv[]);
//argc nombre d'arguments du terminal
//argv nom des arguments
int main(int argc, char const* argv[]) {
    char* line_buf = NULL; 
    size_t line_buf_size = 0;
    FILE *file;
    file = fopen(argv[argc - 1], "r"); // on récup le denier argument du terminal
    printf("opening file : %s\n", argv[argc - 1]);
    if (!file)
  {
    fprintf(stderr, "Error opening file '%s'\n", argv[argc - 1]);
    return EXIT_FAILURE;
  }
    printf("reading instructions\n");
    while (getline(&line_buf, &line_buf_size, file) > 0) // getline renvoie le nombre de caractère de lue et ca mets les carctères lus dans line_buff 
    {
        printf("%s", line_buf);
        int i = strtol(line_buf, NULL, 16);
        write_mem(4*cur_inst, i);
        instructions[cur_inst++] = i;
    }
    ghdl_main(argc - 1, argv);
    return 0;
}

int get_inst(int a) {
    a = a >> 2;
    if (a < cur_inst) {
        return instructions[a];
    }
    else {
        return 0; //andez r0, r0, r0
    }
}

int get_mem(int a) {
    a = a >> 2; // permet de gérer l'alignement
    /**
    La mémoire est composée de 4 tableau de pointeurs imbriqués les uns dans les autres.
    Chaque section de l'adresse va définir la case de mem accéder.
    Pour ce faire on va considérer des groupes de 8 bits de l'adresse (2^8 = 256) et on va utilisé l'opérateur logique and FF afin de ne conserver que le paquet de 8 bits voulu.
    Ce paquet permettant de définir l'adresse accéder.
    */
    int addr1 = a & 0xFF;
    int addr2 = (a >> 8) & 0xFF ;
    int addr3 = (a >> 16) & 0xFF;
    int addr4 = (a >> 24) & 0xFF;
    if (mem[addr1] && mem[addr1][addr2] && mem[addr1][addr2][addr3])  {
        printf("######### Read %x in mem to address %x. #############\n", mem[addr1][addr2][addr3][addr4], a);
        return mem[addr1][addr2][addr3][addr4];
    }
    else return 0;    
}

int write_mem(int a, int data) {
    a = a >> 2;
    printf("######### Write %x in mem to address %x. #############\n", data, a);
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