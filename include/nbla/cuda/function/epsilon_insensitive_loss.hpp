// Copyright 2017,2018,2019,2020,2021 Sony Corporation.
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

/** EpsilonInsensitiveLoss
 */
#ifndef __NBLA_CUDA_FUNCTION_EPSILONINSENSITIVELOSS_HPP__
#define __NBLA_CUDA_FUNCTION_EPSILONINSENSITIVELOSS_HPP__

#include <nbla/cuda/common.hpp>
#include <nbla/cuda/cuda.hpp>
#include <nbla/cuda/function/utils/base_transform_binary.hpp>
#include <nbla/function/epsilon_insensitive_loss.hpp>

namespace nbla {
/** @copydoc EpsilonInsensitiveLoss
*/
NBLA_DECLARE_TRANSFORM_BINARY_CUDA_1(EpsilonInsensitiveLoss, float);
}

#endif
