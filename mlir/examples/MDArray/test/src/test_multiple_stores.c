#include <stdint.h>
#include <stdlib.h>

float test_multiple_stores(int64_t n, int64_t m, int64_t i0, int64_t j0,
                           float v0, int64_t i1, int64_t j1, float v1) {
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  a[i0 * m + j0] = v0;
  a[i1 * m + j1] = v1;
  return a[i0 * m + j0];
}
