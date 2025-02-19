// Copyright 2020,2021 Sony Corporation.
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

#include <nbla/cuda/array/cuda_array.cuh>
#include <nbla/cuda/array/cuda_dlpack_array.hpp>

namespace nbla {
NBLA_DEFINE_FUNC_COPY_FROM(CudaDlpackArray, cuda_array_copy, cuda);
NBLA_DEFINE_FUNC_FILL(CudaDlpackArray, cuda_fill, cuda);
}
