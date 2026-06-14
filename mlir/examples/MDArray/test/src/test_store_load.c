#include <stdint.h>
#include <stdlib.h>

float test_store_load(int64_t n, int64_t m, int64_t i, int64_t j, float val) {
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  a[i * m + j] = val;
  return a[i * m + j];
}
