// Copyright 2018,2019,2020,2021 Sony Corporation.
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

#include <nbla/array.hpp>
#include <nbla/cuda/common.hpp>
#include <nbla/cuda/function/selu.hpp>
#include <nbla/cuda/math.hpp>
#include <nbla/variable.hpp>

namespace nbla {

template <typename T>
__global__ void kernel_selu_forward(const int num, const float scale_,
                                    const float coef, T *y, const T *x) {
  NBLA_CUDA_KERNEL_LOOP(idx, num) {
    y[idx] = x[idx] > (T)0 ? (T)scale_ * x[idx]
                           : (T)coef * (std::exp(x[idx]) - (T)1);
  }
}

template <typename T, bool accum = true>
__global__ void kernel_selu_backward(const int num, const float scale_,
                                     const float coef, T *dx, const T *x,
                                     const T *dy) {
  NBLA_CUDA_KERNEL_LOOP(idx, num) {
    dx[idx] = (accum ? dx[idx] : (T)0) +
              (x[idx] > (T)0 ? dy[idx] * (T)scale_
                             : dy[idx] * (T)coef * std::exp(x[idx]));
  }
}

template <typename T>
void SELUCuda<T>::setup_impl(const Variables &inputs,
                             const Variables &outputs) {
  cuda_set_device(this->device_);
  SELU<T>::setup_impl(inputs, outputs);
}

template <typename T>
void SELUCuda<T>::forward_impl(const Variables &inputs,
                               const Variables &outputs) {
  cuda_set_device(this->device_);
  const Tc *x = inputs[0]->get_data_pointer<Tc>(this->ctx_);
  Tc *y = outputs[0]->cast_data_and_get_pointer<Tc>(this->ctx_, true);
  size_t size = inputs[0]->size();
  const float coef = this->alpha_ * this->scale_;
  NBLA_CUDA_LAUNCH_KERNEL_SIMPLE(kernel_selu_forward, size, this->scale_, coef,
                                 y, x);
}

template <typename T>
void SELUCuda<T>::backward_impl(const Variables &inputs,
                                const Variables &outputs,
                                const vector<bool> &propagate_down,
                                const vector<bool> &accum) {
  if (!propagate_down[0]) {
    return;
  }
  cuda_set_device(this->device_);
  const Tc *x = inputs[0]->get_data_pointer<Tc>(this->ctx_);
  Tc *dx = inputs[0]->cast_grad_and_get_pointer<Tc>(this->ctx_, !accum[0]);
  const Tc *dy = outputs[0]->get_grad_pointer<Tc>(this->ctx_);
  size_t size = inputs[0]->size();
  const float coef = this->alpha_ * this->scale_;
  if (accum[0]) {
    NBLA_CUDA_LAUNCH_KERNEL_SIMPLE((kernel_selu_backward<Tc, true>), size,
                                   this->scale_, coef, dx, x, dy);
  } else {
    NBLA_CUDA_LAUNCH_KERNEL_SIMPLE((kernel_selu_backward<Tc, false>), size,
                                   this->scale_, coef, dx, x, dy);
  }
}
}
