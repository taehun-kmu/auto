#!/bin/bash
set -e

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

user_can_sudo() {
  command_exists sudo || return 1
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

if user_can_sudo; then
  SUDO="sudo"
else
  SUDO="" # To support docker environment
fi

user_can_apt() {
  command_exists apt-fast
}

if user_can_apt; then
  APT="apt-fast"
else
  APT="apt-get" # Basic command
fi


build_dir="$HOME/Workspace/3rdparty/library/opencv"
opencv_contrib_dir="$HOME/Workspace/3rdparty/library/opencv_contrib"
cd "$build_dir"

# Source Build
cmake -S . -B build -G Ninja \
                    -D CMAKE_BUILD_TYPE=RELEASE \
                    -D CMAKE_INSTALL_PREFIX=/usr/local \
                    -D CMAKE_C_STANDARD=17 \
                    -D CMAKE_CXX_STANDARD=17 \
                    -D CMAKE_C_FLAGS="-march=native" \
                    -D CMAKE_CXX_FLAGS="-march=native" \
                    -D OPENCV_EXTRA_MODULES_PATH="$opencv_contrib_dir/modules" \
                    -D CPU_BASELINE=DETECT \
                    -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
                    -D WITH_EIGEN=ON \
                    -D BUILD_EIGEN=ON \
                    -D WITH_OPENCL=OFF \
                    -D CUDA_ARCH_BIN=8.7 \
                    -D CUDA_ARCH_PTX="sm_87" \
                    -D WITH_CUDA=ON \
                    -D WITH_CUDNN=ON \
                    -D WITH_CUBLAS=ON \
                    -D WITH_NVCUVID=OFF \
                    -D WITH_NVCUVENC=OFF \
                    -D ENABLE_FAST_MATH=ON \
                    -D CUDA_FAST_MATH=ON \
                    -D OPENCV_DNN_CUDA=ON \
                    -D CUDA_NVCC_FLAGS="-std=c++17" \
                    -D WITH_QT=OFF \
                    -D WITH_OPENMP=ON \
                    -D BUILD_TIFF=ON \
                    -D BUILD_ZLIB=ON \
                    -D BUILD_JASPER=ON \
                    -D BUILD_JPEG=ON \
                    -D BUILD_GIF=ON \
                    -D BUILD_FFMPEG=ON \
                    -D WITH_GSTREAMER=ON \
                    -D WITH_TBB=ON \
                    -D BUILD_TBB=ON \
                    -D BUILD_TESTS=OFF \
                    -D WITH_V4L=ON \
                    -D WITH_LIBV4L=ON \
                    -D WITH_PROTOBUF=ON \
                    -D OPENCV_ENABLE_NONFREE=ON \
                    -D INSTALL_C_EXAMPLES=OFF \
                    -D INSTALL_CXX_EXAMPLES=OFF \
                    -D INSTALL_PYTHON_EXAMPLES=OFF \
                    -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
                    -D OPENCV_GENERATE_PKGCONFIG=ON \
                    -D BUILD_EXAMPLES=OFF
