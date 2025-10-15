#include <stddef.h>
#include <string.h>

#define MAT_SIZE 256

// make sure that `c` is zeroed
void matmul(int a[MAT_SIZE][MAT_SIZE], int b[MAT_SIZE][MAT_SIZE], int c[MAT_SIZE][MAT_SIZE], size_t size)
{
	for (size_t i = 0; i < size; i++) {
		for (size_t j = 0; j < size; j++) {
			for (size_t k = 0; k < size; k++) {
				c[i][j] += a[i][k] * b[k][j];
			}
		}
 	}
 
}

int main(int argc, char **argv)
{
	int a[MAT_SIZE][MAT_SIZE], b[MAT_SIZE][MAT_SIZE], c[MAT_SIZE][MAT_SIZE];
	memset(c, 0, MAT_SIZE * MAT_SIZE * sizeof(int));

	matmul(a, b, c, MAT_SIZE);

	return 0;
}
