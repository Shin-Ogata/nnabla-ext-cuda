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

#ifndef NBLA_CUDA_FUNCTION_SORT_HPP
#define NBLA_CUDA_FUNCTION_SORT_HPP

#include <nbla/cuda/cuda.hpp>
#include <nbla/function/sort.hpp>

namespace nbla {

template <typename T> class SortCuda : public Sort<T> {
protected:
  // Members only for cub implementation
  bool use_cub_;
  bool need_transpose_;
  size_t cub_temp_storage_bytes_;
  int cub_num_items_, cub_num_segments_;
  Shape_t transposed_shape_;
  FunctionPtr transpose_converter_, transpose_deconverter_;

public:
  typedef typename CudaType<T>::type Tcu;

  explicit SortCuda(const Context &ctx, int axis, bool reverse, bool with_index,
                    bool only_index)
      : Sort<T>(ctx, axis, reverse, with_index, only_index),
        device_(std::stoi(ctx.device_id)) {}
  virtual ~SortCuda() {}
  virtual string name() { return "SortCuda"; }
  virtual vector<string> allowed_array_classes() {
    return SingletonManager::get<Cuda>()->array_classes();
  }

protected:
  int device_;
  virtual void setup_impl(const Variables &inputs, const Variables &outputs);
  virtual void thrust_sort(const Variables &inputs, const Variables &outputs);
  virtual void forward_impl(const Variables &inputs, const Variables &outputs);
  virtual void backward_impl(const Variables &inputs, const Variables &outputs,
                             const vector<bool> &propagate_down,
                             const vector<bool> &accum);
};
}
#endif
