#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

#define MAT_SIZE 256
#define MAT_DEFAULT_BSIZE 64

#include "data.c.inc"

void fmaddq_stub(float result[4], float a[4], float b[4], float c[4]);

void matmul(float a[MAT_SIZE][MAT_SIZE], float b[MAT_SIZE][MAT_SIZE],
	    float c[MAT_SIZE][MAT_SIZE], size_t size)
{
	for (size_t i = 0; i < size; i++) {
		for (size_t j = 0; j < size; j++) {
			for (size_t k = 0; k < size; k++) {
				c[i][j] += a[i][k] * b[k][j];
			}
		}
 	}
}

void matmul_alt(float a[MAT_SIZE][MAT_SIZE], float b[MAT_SIZE][MAT_SIZE],
		float c[MAT_SIZE][MAT_SIZE], size_t size)
{
	for (size_t j = 0; j < size; j++) {
		for (size_t i = 0; i < size; i++) {
			for (size_t k = 0; k < size; k++) {
				c[i][j] += a[i][k] * b[k][j];
			}
		}
 	}
}

void matmul_transpose(float a[MAT_SIZE][MAT_SIZE], float b[MAT_SIZE][MAT_SIZE],
		      float c[MAT_SIZE][MAT_SIZE], size_t size)
{
	for (size_t i = 0; i < size; i++) {
		for (size_t j = 0; j < size; j++) {
			for (size_t k = 0; k < size; k++) {
				c[i][j] += a[i][k] * b[j][k];
			}
		}
 	}
}

// note that `b` needs to be transposed
void matmul_vector(float a[MAT_SIZE][MAT_SIZE], float b[MAT_SIZE][MAT_SIZE],
		   float c[MAT_SIZE][MAT_SIZE], size_t size)
{
	for (size_t i = 0; i < size; i++) {
		for (size_t j = 0; j < size; j++) {
			float res[4] = {0.0};
			for (size_t k = 0; k < size; k += 4) {
				// essentially we're doing
				// res[0] += a[i][k+0] * b[j][k+0]
				// res[1] += a[i][k+1] * b[j][k+1]
				// res[2] += a[i][k+2] * b[j][k+2]
				// res[3] += a[i][k+3] * b[j][k+3]
				fmaddq_stub(res, &a[i][k], &b[j][k], res);
			}
			c[i][j] = res[0] + res[1] + res[2] + res[3];
		}
 	}
}

void print_result(float c[MAT_SIZE][MAT_SIZE])
{
	for (size_t i = 0; i < MAT_SIZE; i++) {
		for (size_t j = 0; j < MAT_SIZE; j++) {
			printf("%f ", c[i][j]);
		}
		printf("\n");
 	}
}

int main(int argc, char **argv)
{
	size_t blocksize = MAT_DEFAULT_BSIZE;
	bool should_print = false;

	if (argc < 2) {
		fprintf(stderr, "usage: spike [options] matmul <naive/transpose/block/vectorize> [--stdout] [--block-size=<size>]");
		return -1;
	}

	for (int i = 2; i < argc; i++) {
		char *arg = argv[i];
		if (strcmp(arg, "--stdout") == 0) {
			should_print = true;
		} else if (strcmp(arg, "--block-size=")) {
			blocksize = strtoul(&arg[13], NULL, 10);
			if (blocksize == 0) {
				fprintf(stderr, "invalid block size: %s\n", arg);
				return -1;
			}
			printf("blocksize=%lu\n", blocksize);
		}
	}

	if (strcmp(argv[1], "naive") == 0) {
		matmul(mat_a, mat_b, mat_c, MAT_SIZE);
	} else if (strcmp(argv[1], "transpose") == 0) {
		matmul_transpose(mat_a, mat_bt, mat_c, MAT_SIZE);
	} else if (strcmp(argv[1], "vector") == 0) {
		matmul_vector(mat_a, mat_bt, mat_c, MAT_SIZE);
	} else if (strcmp(argv[1], "alt") == 0) {
		matmul_alt(mat_a, mat_b, mat_c, MAT_SIZE);
	} else {
		fprintf(stderr, "unknown multiplication mode: \"%s\"\n", argv[1]);
		return -1;
	}

	if (should_print) {
		print_result(mat_c);
	}

	return 0;
}
