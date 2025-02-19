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
#include <nbla/cuda/function/stack.hpp>
#include <nbla/cuda/math.hpp>
#include <nbla/variable.hpp>

namespace nbla {

template <typename T>
__global__ void forward_stack_kernel(const int num, const int num_inputs_,
                                     const int outer_size_,
                                     const int inner_size_, const int i0,
                                     const T *x, T *y) {
  NBLA_CUDA_KERNEL_LOOP(idx, num) {
    const int i1 = idx / inner_size_;
    const int i2 = idx % inner_size_;
    y[i1 * (inner_size_ * num_inputs_) + i0 * inner_size_ + i2] =
        x[i1 * inner_size_ + i2];
  }
}

template <typename T>
void StackCuda<T>::forward_impl(const Variables &inputs,
                                const Variables &outputs) {
  cuda_set_device(std::stoi(this->ctx_.device_id));
  Tc *y = outputs[0]->cast_data_and_get_pointer<Tc>(this->ctx_, true);
  for (int i0 = 0; i0 < this->num_inputs_; ++i0) {
    const Tc *x = inputs[i0]->get_data_pointer<Tc>(this->ctx_);
    NBLA_CUDA_LAUNCH_KERNEL_SIMPLE(
        forward_stack_kernel, this->inner_size_ * this->outer_size_,
        this->num_inputs_, this->outer_size_, this->inner_size_, i0, x, y);
  }
}

template <typename T, bool accum>
__global__ void backward_stack_kernel(const int num, const int num_inputs_,
                                      const int outer_size_,
                                      const int inner_size_, const int i0,
                                      T *dx, const T *dy) {
  NBLA_CUDA_KERNEL_LOOP(idx, num) {
    const int i1 = idx / inner_size_;
    const int i2 = idx % inner_size_;
    T &ref = dx[i1 * inner_size_ + i2];
    ref = (accum ? ref : (T)0) +
          dy[i1 * (inner_size_ * num_inputs_) + i0 * inner_size_ + i2];
  }
}

template <typename T>
void StackCuda<T>::backward_impl(const Variables &inputs,
                                 const Variables &outputs,
                                 const vector<bool> &propagate_down,
                                 const vector<bool> &accum) {
  cuda_set_device(std::stoi(this->ctx_.device_id));
  const Tc *dy = outputs[0]->get_grad_pointer<Tc>(this->ctx_);
  for (int i0 = 0; i0 < this->num_inputs_; ++i0) {
    if (propagate_down[i0]) {
      Tc *dx =
          inputs[i0]->cast_grad_and_get_pointer<Tc>(this->ctx_, !accum[i0]);
      if (accum[i0]) {
        NBLA_CUDA_LAUNCH_KERNEL_SIMPLE((backward_stack_kernel<Tc, true>),
                                       this->inner_size_ * this->outer_size_,
                                       this->num_inputs_, this->outer_size_,
                                       this->inner_size_, i0, dx, dy);
      } else {
        NBLA_CUDA_LAUNCH_KERNEL_SIMPLE((backward_stack_kernel<Tc, false>),
                                       this->inner_size_ * this->outer_size_,
                                       this->num_inputs_, this->outer_size_,
                                       this->inner_size_, i0, dx, dy);
      }
    }
  }
}
}
