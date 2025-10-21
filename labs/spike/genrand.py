#!/usr/bin/env python
from random import uniform
import numpy as np
import sys

def print_c(arr):
    for i in range(0, 256):
        print("{ ", end='')
        for j in range(0, 256):
            print(f"{arr[i][j] :.4f}", end=', ')
        print("},")

a = np.random.rand(256, 256)
b = np.random.rand(256, 256)
bt = b.T

print("float mat_a[MAT_SIZE][MAT_SIZE] = {")
print_c(a)
print("};")

print("float mat_b[MAT_SIZE][MAT_SIZE] = {")
print_c(b)
print("};")

print("float mat_bt[MAT_SIZE][MAT_SIZE] = {")
print_c(bt)
print("};")

print("float mat_c[MAT_SIZE][MAT_SIZE] = {0};")
