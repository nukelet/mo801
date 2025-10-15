#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint64_t multmod_wrapper(uint64_t a, uint64_t b, uint64_t c);

int main (int argc, char** argv) {
  if (argc != 4) {
    fprintf(stderr, "usage: ./multmod a b c; output = (a*b)%%c\n");
    return -1;
  }

  uint64_t a = strtoul(argv[1], NULL, 16);
  uint64_t b = strtoul(argv[2], NULL, 16);
  uint64_t c = strtoul(argv[3], NULL, 16);

  uint64_t result = multmod_wrapper(a, b, c);

  printf("(%lu * %lu) %% %lu -> %lu\n", a, b, c, result);

  return 0;
}
