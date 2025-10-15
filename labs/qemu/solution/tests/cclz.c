#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint64_t cclz_wrapper(uint64_t a);

int main (int argc, char** argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: ./cclz <number in hex>\n");
    return -1;
  }

  uint64_t a = strtoul(argv[1], NULL, 16);

  uint64_t r = cclz_wrapper(a);

  printf("0x%016lx: %lu leading zeroes\n", a, r);

  return 0;
}
