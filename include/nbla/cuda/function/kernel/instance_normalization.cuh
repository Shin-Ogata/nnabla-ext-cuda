// Copyright 2021 Sony Group Corporation.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <nbla/cuda/common.hpp>

namespace nbla {

template <typename T, typename index_t>
__global__ void
instance_norm_forward_normalization(const index_t outer_size,
                                    const index_t reduce_size, const T *x,
                                    const T *mean, const T *var, const T *beta,
                                    const T *gamma, T *y, const float eps) {
  const index_t bidy = blockIdx.y;
  const index_t gdimy = gridDim.y;
  const index_t tidx = threadIdx.x;
  const index_t bdimx = blockDim.x;

  // Grid-stride loop
  for (index_t outer_idx = blockIdx.x; outer_idx < outer_size;
       outer_idx += gridDim.x) {
    for (index_t i = tidx + bdimx * bidy; i < reduce_size; i += bdimx * gdimy) {
      const index_t idx = outer_idx * reduce_size + i;
      const T scale = gamma ? gamma[outer_idx] : (T)1.0f;
      const T bias = beta ? beta[outer_idx] : (T)0.0f;
      const T invstd = rsqrt(var[outer_idx] + eps);

      y[idx] = scale * invstd * (x[idx] - mean[outer_idx]) + bias;
    }
  }
}

template <typename T, typename index_t>
__global__ void instance_norm_backward_dx_factor(
    const index_t outer_size, const index_t reduce_size, const T *gamma,
    const T *mean, const T *var, const T *dmean, const T *dvar, const T *sum_dy,
    const T *sum_dyx, T *factor_a, T *factor_b, const float eps) {
  // Grid-stride loop
  for (index_t idx = blockIdx.x * blockDim.x + threadIdx.x; idx < outer_size;
       idx += gridDim.x * blockDim.x) {
    const float inv_reduce_size = 1.0f / reduce_size;
    const float invstd = rsqrt(var[idx] + eps);
    const float scale = gamma ? static_cast<float>(gamma[idx]) : 1.0f;

    const float tmp = (sum_dy[idx] * scale * mean[idx] - sum_dyx[idx] * scale) *
                          invstd * invstd * invstd * inv_reduce_size +
                      (dvar ? 2.0f * dvar[idx] * inv_reduce_size : 0.0f);

    factor_a[idx] = tmp;
    factor_b[idx] = -tmp * mean[idx] -
                    sum_dy[idx] * scale * invstd * inv_reduce_size +
                    (dmean ? dmean[idx] * inv_reduce_size : 0.0f);
  }
}

template <bool accum, typename T, typename index_t>
__global__ void
instance_norm_backward_dx(const index_t outer_size, const index_t reduce_size,
                          const T *x, const T *gamma, const T *dy, const T *var,
                          const T *factor_a, const T *factor_b, T *dx,
                          const float eps) {

  const index_t bidy = blockIdx.y;
  const index_t gdimy = gridDim.y;
  const index_t tidx = threadIdx.x;
  const index_t bdimx = blockDim.x;

  // Grid-stride loop
  for (index_t outer_idx = blockIdx.x; outer_idx < outer_size;
       outer_idx += gridDim.x) {
    for (index_t i = tidx + bdimx * bidy; i < reduce_size; i += bdimx * gdimy) {
      const index_t idx = outer_idx * reduce_size + i;
      const T scale = gamma ? gamma[outer_idx] : (T)1.0f;
      const T invstd = rsqrt(var[outer_idx] + eps);

      dx[idx] = dy[idx] * invstd * scale + factor_a[outer_idx] * x[idx] +
                factor_b[outer_idx] + (accum ? dx[idx] : (T)0.0f);
    }
  }
}

template <bool accum_beta, bool accum_gamma, typename T, typename index_t>
__global__ void instance_norm_backward_dbeta_dgamma(
    const index_t outer_size, const index_t reduce_size, const T *x,
    const T *gamma, const T *dy, const T *sum_dy, const T *sum_dyx,
    const T *mean, const T *var, T *dbeta_out, T *dgamma_out, const float eps) {
  // Grid-stride loop
  for (index_t idx = blockIdx.x * blockDim.x + threadIdx.x; idx < outer_size;
       idx += gridDim.x * blockDim.x) {
    const float invstd = rsqrt(var[idx] + eps);
    const float dbeta = sum_dy[idx];
    const float dgamma =
        sum_dyx[idx] * invstd - sum_dy[idx] * mean[idx] * invstd;

    if (dbeta_out) {
      dbeta_out[idx] = dbeta + (accum_beta ? dbeta_out[idx] : (T)0.0f);
    }
    if (dgamma_out) {
      dgamma_out[idx] = dgamma + (accum_gamma ? dgamma_out[idx] : (T)0.0f);
    }
  }
}
}
