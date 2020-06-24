#!/bin/bash
#
# Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.
#

######################################
# GenomeWorks CPU/GPU conda build script for CI #
######################################
set -e

START_TIME=$(date +%s)

export PATH=/conda/bin:/usr/local/cuda/bin:$PATH

# Set home to the job's workspace
export HOME=$WORKSPACE

cd "${WORKSPACE}"

################################################################################
# Init
################################################################################

source ci/common/logger.sh

logger "Calling prep-init-env..."
source ci/common/prep-init-env.sh "${WORKSPACE}" "${CONDA_ENV_NAME}"

################################################################################
# SDK build/test
################################################################################

logger "Build SDK in Release mode..."
CMAKE_COMMON_VARIABLES=(-DCMAKE_BUILD_TYPE=Release -Dgw_profiling=ON)
source ci/common/build-test-sdk.sh "${WORKSPACE}" "${CMAKE_COMMON_VARIABLES[@]}"

cd "${WORKSPACE}"
rm -rf "${WORKSPACE}"/build

logger "Build SDK in Debug mode..."
CMAKE_COMMON_VARIABLE=(-DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG="-g -O2")
source ci/common/build-test-sdk.sh "${WORKSPACE}" "${CMAKE_COMMON_VARIABLES[@]}"

rm -rf "${WORKSPACE}"/build

################################################################################
# Pygenomeworks tests
################################################################################
logger "Build Pygenomeworks..."
cd "${WORKSPACE}"
source ci/common/test-pygenomeworks.sh "${WORKSPACE}"/pygenomeworks

logger "Upload Wheel to PyPI..."
cd "${WORKSPACE}"
source ci/release/pypi_uploader.sh

logger "Done..."
