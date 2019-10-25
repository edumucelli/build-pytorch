FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
    rm -rf /var/lib/apt/lists/* && \
    NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION 9.1.85

ENV CUDA_PKG_VERSION 9-1=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-9.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=9.1"

# == tensorflow-gpu: tensorflow + cuda and cudnn build with bazel based on the official Dockerfile
# cf until 1.12.3: https://github.com/tensorflow/tensorflow/blob/v1.12.3/tensorflow/tools/docker/Dockerfile.devel-gpu
# or master https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/devel-gpu.Dockerfile
# The difference here is that no jupyter, keras, etc are needed, the goal here is tha bare minimum
# in order to build the tensorflow-gpu with python3.5, cuda 9.1.85 and cudnn 7.1.3

ENV CUDNN_PKG_VERSION 7.1.3.16-1+cuda9.1

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        cuda-command-line-tools-9-1 \
        cuda-cublas-dev-9-1 \
        cuda-cudart-dev-9-1 \
        cuda-cufft-dev-9-1 \
        cuda-curand-dev-9-1 \
        cuda-cusolver-dev-9-1 \
        cuda-cusparse-dev-9-1 \
        cuda-nvrtc-dev-9-1 \
        curl \
        git \
        libcudnn7=$CUDNN_PKG_VERSION \
        libcudnn7-dev=$CUDNN_PKG_VERSION \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \   
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-setuptools \
        python3-scipy \
        python3-wheel \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        wget \
        && \
    rm -rf /var/lib/apt/lists/* && \
    find /usr/local/cuda-9.1/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete && \
    rm /usr/lib/x86_64-linux-gnu/libcudnn_static_v7.a

RUN git clone -b 'v1.0.0' --single-branch --depth 1 https://github.com/pytorch/pytorch.git

WORKDIR '/pytorch'

RUN git submodule update --init --recursive && \
    pip3 install pyyaml==3.13 wheel && \
    pip3 install -r requirements.txt
  
RUN CUDAHOSTCXX='/usr/bin/gcc' \
    USE_OPENCV=1 \
    BUILD_TORCH=ON \
    CMAKE_PREFIX_PATH="/usr/bin/" \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/lib:$LD_LIBRARY_PATH \
    CUDA_BIN_PATH=/usr/local/cuda/bin \
    CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda/ \
    CUDNN_LIB_DIR=/usr/local/cuda/lib64 \
    CUDA_HOST_COMPILER=cc \
    USE_CUDA=1 \
    USE_NNPACK=1 \
    CC=cc \
    CXX=c++ \
    TORCH_CUDA_ARCH_LIST="6.0 6.1+PTX 7.0" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    python3 setup.py bdist_wheel