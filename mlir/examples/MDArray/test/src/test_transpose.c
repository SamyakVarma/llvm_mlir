#include <stdint.h>
#include <stdlib.h>

float *test_transpose(int64_t n, int64_t m) {
  float *in = (float *)malloc((size_t)(n * m) * sizeof(float));
  float *out = (float *)malloc((size_t)(m * n) * sizeof(float));
  for (int64_t i = 0; i < n; i++) {
    for (int64_t j = 0; j < m; j++) {
      out[j * n + i] = in[i * m + j];
    }
  }
  return out;
}
