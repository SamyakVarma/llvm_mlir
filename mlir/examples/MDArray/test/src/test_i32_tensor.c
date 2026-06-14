#include <stdint.h>
#include <stdlib.h>

int32_t test_i32_tensor(int64_t n, int64_t m, int64_t i, int64_t j,
                        int32_t val) {
  int32_t *a = (int32_t *)malloc((size_t)(n * m) * sizeof(int32_t));
  a[i * m + j] = val;
  return a[i * m + j];
}
