#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint64_t bitrev_wrapper(uint64_t a);

int main (int argc, char** argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: ./bitrev <number>\n");
    return -1;
  }

  uint64_t a = strtoul(argv[1], NULL, 16);

  uint64_t r = bitrev_wrapper(a);

  printf("0x%016lx -> 0x%016lx\n", a, r);

  return 0;
}
