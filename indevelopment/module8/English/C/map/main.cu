/*
 * Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

extern "C" void dot_acc(int*, int*, int*, int, int);
extern "C" void dot(int*, int*, int*, int, int);
extern "C" void map(int*, int*, int);
extern "C" void unmap(int*);

int main()
{

	int i, j, m, n;
	int *A, *B, *C, *D;
	int *A_d, *B_d, *C_d;

	srand(0);

	m = 4098;
	n = 4098;

	A = (int*) malloc( m*n * sizeof(int));
	B = (int*) malloc( m*n * sizeof(int));
	C = (int*) malloc(  m  * sizeof(int));
	D = (int*) malloc(  m  * sizeof(int));

	for( i = 0; i < m; i++ ) {
		for( j = 0; j < n; j++ ) {
			A[i*n+j] = rand() % 100 + 1;
			B[i*n+j] = rand() % 100 + 1;
		}
	}

	cudaMalloc((void **)&A_d, m*n*sizeof(int));
	cudaMalloc((void **)&B_d, m*n*sizeof(int));
	cudaMalloc((void **)&C_d, m*  sizeof(int));
	
	cudaMemcpy(A_d, A, m*n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(B_d, B, m*n*sizeof(int), cudaMemcpyHostToDevice);

	map(A, A_d, m*n*sizeof(int));
	map(B, B_d, m*n*sizeof(int));
	map(C, C_d, m*sizeof(int));

	dot_acc(A,B,C,m,n);
	
	cudaMemcpy(C, C_d, m*sizeof(int), cudaMemcpyDeviceToHost);

	unmap(A);
	unmap(B);
	unmap(C);
	cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);

	dot(A,B,D,m,n);

	for( i = 0; i < m; i++ ) {
		if( C[i] != D[i] ) {
			printf("Error at index %i\n", i);
			return 0;
		}
	}

	free(A); free(B); free(C); free(D);

	printf("Program finished sucessfully.\n");
	return 0;

}
