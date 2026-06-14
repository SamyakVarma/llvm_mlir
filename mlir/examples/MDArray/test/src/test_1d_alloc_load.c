#include <stdint.h>
#include <stdlib.h>

float test_1d_alloc_load(int64_t n, int64_t i) {
  float *a = (float *)malloc((size_t)n * sizeof(float));
  return a[i];
}
