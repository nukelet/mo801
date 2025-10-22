#include <stdio.h>

void fmaddq_stub(float result[4], float a[4], float b[4], float c[4]);

int main(int argc, char **argv)
{
	float a[4] = { 1.0, 2.0, 3.0, 4.0 };
	float b[4] = { 5.0, 6.0, 7.0, 8.0 };
	float c[4] = { 1.0, 1.0, 1.0, 1.0 };
	float result[4] = {0};
	
	fmaddq_stub(result, a, b, c);

	printf("%f %f %f %f\n", result[0], result[1], result[2], result[3]);

	return 0;
}
