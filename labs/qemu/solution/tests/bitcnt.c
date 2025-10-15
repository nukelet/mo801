#include <stdio.h>
#include <stdlib.h>

int bitcnt_wrapper (int a, int b);

int main (int argc, char* argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Argumentos insuficientes.\n");
    return -1;
  }

  int a = atoi(argv[1]);
  int b = atoi(argv[2]);

  int r = bitcnt_wrapper(a, b);

  printf("Bit Count: %d\n", r);

  return 0;
}
