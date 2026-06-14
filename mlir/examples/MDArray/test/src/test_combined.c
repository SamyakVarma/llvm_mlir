#include <stdint.h>
#include <stdlib.h>

float test_combined(int64_t n, int64_t m, int64_t i, int64_t j, float val) {
  float *a = (float *)malloc((size_t)(n * m) * sizeof(float));
  a[i * m + j] = val;

  float *out = (float *)malloc((size_t)(m * n) * sizeof(float));
  for (int64_t r = 0; r < n; r++) {
    for (int64_t c = 0; c < m; c++) {
      out[c * n + r] = a[r * m + c];
    }
  }
  return out[j * n + i];
}
