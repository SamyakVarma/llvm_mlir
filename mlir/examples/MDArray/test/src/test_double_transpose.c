#include <stdint.h>
#include <stdlib.h>

float *test_double_transpose(int64_t n, int64_t m) {
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  float *b = (float *)malloc((size_t)(m * n) * sizeof(float));
  for (int64_t i = 0; i < n; i++) {
    for (int64_t j = 0; j < m; j++) {
      b[j * n + i] = a[i * m + j];
    }
  }
  float *c = (float *)malloc((size_t)(n * m) * sizeof(float));
  for (int64_t i = 0; i < m; i++) {
    for (int64_t j = 0; j < n; j++) {
      c[j * m + i] = b[i * n + j];
    }
  }
  return c;
}
