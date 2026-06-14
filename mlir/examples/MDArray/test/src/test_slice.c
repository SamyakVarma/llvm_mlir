#include <stdint.h>
#include <stdlib.h>

/* Returns a pointer into the parent buffer (C has no tensor slice type). */
float *test_slice(int64_t n, int64_t m, int64_t off0, int64_t off1,
                  int64_t sz0, int64_t sz1) {
  (void)sz0;
  (void)sz1;
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  return &a[off0 * m + off1];
}
