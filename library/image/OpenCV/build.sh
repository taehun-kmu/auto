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


# System
$SUDO $APT purge -y *libopencv* opencv-data python3-data
$SUDO $APT autoremove -y --purge


# Requirement
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends zsh curl wget \
                                                                   git ccache gcc-12 g++-12 \
                                                                   cmake cmake-curses-gui ninja-build \
                                                                   libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev \
                                                                   libpng-dev libtiff-dev libglew-dev \
                                                                   libavif-dev libva-dev libopenjp2-7 \
                                                                   libopenjp2-7-dev libopenjpip-dec-server libopenjpip-server \
                                                                   libopenjpip-viewer libopenjpip7 libopenjp2-tools \
                                                                   libopenjp3d-tools libavcodec-dev libavformat-dev \
                                                                   libswscale-dev libgtk2.0-dev libgtk-3-dev \
                                                                   libcanberra-gtk* \
                                                                   python3 python3-dev python3-pip \
                                                                   python3-venv python3-venv python3-numpy \
                                                                   libxvidcore-dev libx264-dev libtbb-dev \
                                                                   libdc1394-dev libxine2-dev libv4l-dev \
                                                                   v4l-utils qv4l2 \
                                                                   libtesseract-dev libpostproc-dev libswresample-dev \
                                                                   libvorbis-dev libfaac-dev libmp3lame-dev \
                                                                   libtheora-dev libopencore-amrnb-dev libopencore-amrwb-dev \
                                                                   libopenblas-base libopenblas-dev libatlas-base-dev \
                                                                   libblas-dev liblapack-dev liblapacke-dev \
                                                                   libeigen3-dev gfortran libhdf5-dev \
                                                                   libprotobuf-dev protobuf-compiler libgoogle-glog-dev \
                                                                   libgflags-dev openjdk-8-jdk libvtk9-dev \
                                                                   libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev \
                                                                   libogre-1.12-dev libceres-dev


# Symbolic Link 
$SUDO ln -s /usr/include/lapacke.h /usr/include/$(uname -m)-linux-gnu


# Installation
cd && git clone -b 4.11.0 https://github.com/taehun-kmu/opencv.git .opencv
cd && git clone -b 4.11.0 https://github.com/taehun-kmu/opencv_contrib.git .opencv_contrib


# Source Build
cd && .opencv cmake -S . -B build -G Ninja \
                                  -D CMAKE_BUILD_TYPE=RELEASE \
                                  -D CMAKE_INSTALL_PREFIX=/usr/local/opencv-4.11.0 \
                                  -D CMAKE_C_STANDARD=17 \
                                  -D CMAKE_CXX_STANDARD=17 \
                                  -D CMAKE_C_FLAGS="-march=native" \
                                  -D CMAKE_CXX_FLAGS="-march=native" \
                                  -D OPENCV_EXTRA_MODULES_PATH=$HOME/.opencv_contrib/modules \
                                  -D CPU_BASELINE=DETECT \
                                  -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
                                  -D WITH_EIGEN=ON \
                                  -D BUILD_EIGEN=ON \
                                  -D WITH_OPENCL=OFF \
                                  -D WITH_CUBLAS=ON \
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
                                  -D BUILD_FFMPEG=ON \
                                  -D WITH_GSTREAMER=ON \
                                  -D WITH_TBB=ON \
                                  -D BUILD_TBB=OFF \
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

ninja --build build -j$(nproc)
$SUDO ninja --install bulid


# Symbolic Link to OpenCV
$SUDO ln -sfn /usr/local/opencv-4.11.0 /usr/local/opencv

# Path
echo "export PKG_CONFIG_PATH=/usr/local/opencv/lib/pkgconfig:$PKG_CONFIG_PATH"
echo "export LD_LIBRARY_PATH=/usr/local/opencv/lib:$LD_LIBRARY_PATH"


# Reset the shared library cache
$SUDO ldconfig


# APT Update
$SUDO $APT update
