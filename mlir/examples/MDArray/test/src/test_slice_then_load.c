#include <stdint.h>
#include <stdlib.h>

float test_slice_then_load(int64_t n, int64_t m, int64_t off0, int64_t off1,
                           int64_t sz0, int64_t sz1, int64_t i, int64_t j) {
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  /* Load from logical position (off0+i, off1+j) inside the parent array. */
  return a[(off0 + i) * m + (off1 + j)];
}
