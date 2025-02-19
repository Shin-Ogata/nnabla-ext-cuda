// Copyright 2021 Sony Corporation.
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

#include <nbla/array.hpp>
#include <nbla/cuda/common.hpp>
#include <nbla/cuda/cudnn/cudnn.hpp>
#include <nbla/cuda/cudnn/function/group_normalization.hpp>
#include <nbla/variable.hpp>

namespace nbla {

template <typename T>
void GroupNormalizationCudaCudnn<T>::setup_impl(const Variables &inputs,
                                                const Variables &outputs) {
  NBLA_ERROR(error_code::not_implemented,
             "Falling back into CUDA C implementation.")
}

template <typename T>
void GroupNormalizationCudaCudnn<T>::forward_impl(const Variables &inputs,
                                                  const Variables &outputs) {
  NBLA_ERROR(error_code::not_implemented,
             "Falling back into CUDA C implementation.")
}

template <typename T>
void GroupNormalizationCudaCudnn<T>::backward_impl(
    const Variables &inputs, const Variables &outputs,
    const vector<bool> &propagate_down, const vector<bool> &accum) {
  NBLA_ERROR(error_code::not_implemented,
             "Falling back into CUDA C implementation.")
}
}
