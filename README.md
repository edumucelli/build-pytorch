# Build PyTorch from source

(You may want to see the already built [releases](https://github.com/edumucelli/build-torch/releases) before building yourself)

This project aims to build PyTorch from the source using a Dockerfile.
The idea is to simplify the build so that one can choose the the Cuda/CuDNN
version which better fits ones environment.

As PyTorch pre-built binaries require specific CUDA/CuDNN versions, e.g.,
[#10971](https://github.com/pytorch/pytorch/issues/10971) you can't have pre-built
PyTorch with CUDA 9.1 after the 0.4.0 release. For instance if you are using
Debian Stretch and the Nvidia distribution packages you won't be able to
use newer versions as they are built with CUDA 9.2.

The default configuration of the Dockerfile will build:

* Python 3.5
* PyTorch 1.3
* Cuda 9.1.85
* CuDNN 7.1.3

As it downloads the packages straight from Nvidia you can build the one
you prefer with Cuda, the package comes straight from [here](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64).
The following versions are then available, just replace the `CUDA_VERSION`
variable by one of the following:

* 8.0.44
* 8.0.61
* 9.0.176
* 9.1.85
* 9.2.88
* 9.2.148
* 10.0.130
* 10.1.105
* 10.1.168
* 10.1.243

Likewise, CuDNN version can be one of the following. Just replace the `CUDNN_PKG_VERSION`
variable to the one you prefer. The packages come directly from [here](https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64).

* 7.0.1.13-1+cuda8.0
* 7.0.2.38-1+cuda8.0
* 7.0.3.11-1+cuda8.0
* 7.0.3.11-1+cuda9.0
* 7.0.4.31-1+cuda8.0
* 7.0.4.31-1+cuda9.0
* 7.0.5.15-1+cuda8.0
* 7.0.5.15-1+cuda9.0
* 7.0.5.15-1+cuda9.1
* 7.1.1.5-1+cuda8.0
* 7.1.1.5-1+cuda9.0
* 7.1.1.5-1+cuda9.1
* 7.1.2.21-1+cuda8.0
* 7.1.2.21-1+cuda9.0
* 7.1.2.21-1+cuda9.1
* 7.1.3.16-1+cuda8.0
* 7.1.3.16-1+cuda9.0
* 7.1.3.16-1+cuda9.1
* 7.1.4.18-1+cuda8.0
* 7.1.4.18-1+cuda9.0
* 7.1.4.18-1+cuda9.2
* 7.2.1.38-1+cuda8.0
* 7.2.1.38-1+cuda9.0
* 7.2.1.38-1+cuda9.2
* 7.3.0.29-1+cuda9.0
* 7.3.0.29-1+cuda10.0
* 7.3.1.20-1+cuda9.0
* 7.3.1.20-1+cuda9.2
* 7.3.1.20-1+cuda10.0
* 7.4.1.5-1+cuda9.0
* 7.4.1.5-1+cuda9.2
* 7.4.1.5-1+cuda10.0
* 7.4.2.24-1+cuda9.0
* 7.4.2.24-1+cuda9.2
* 7.4.2.24-1+cuda10.0
* 7.5.0.56-1+cuda9.0
* 7.5.0.56-1+cuda9.2
* 7.5.0.56-1+cuda10.0
* 7.5.0.56-1+cuda10.1
* 7.5.1.10-1+cuda9.0
* 7.5.1.10-1+cuda9.2
* 7.5.1.10-1+cuda10.0
* 7.5.1.10-1+cuda10.1
* 7.6.0.64-1+cuda9.0
* 7.6.0.64-1+cuda9.2
* 7.6.0.64-1+cuda10.0
* 7.6.0.64-1+cuda10.1
* 7.6.1.34-1+cuda9.0
* 7.6.1.34-1+cuda9.2
* 7.6.1.34-1+cuda10.0
* 7.6.1.34-1+cuda10.1
* 7.6.2.24-1+cuda9.0
* 7.6.2.24-1+cuda9.2
* 7.6.2.24-1+cuda10.0
* 7.6.2.24-1+cuda10.1
* 7.6.3.30-1+cuda9.0
* 7.6.3.30-1+cuda9.2
* 7.6.3.30-1+cuda10.0
* 7.6.3.30-1+cuda10.1
* 7.6.4.38-1+cuda9.0
* 7.6.4.38-1+cuda9.2
* 7.6.4.38-1+cuda10.0
* 7.6.4.38-1+cuda10.1

One thing to note is that some of the packages will respect the Cuda version
you are looking for, e.g.,

```
apt-get install ...
    cuda-command-line-tools-9-1 \
    cuda-cublas-dev-9-1 \
    cuda-cudart-dev-9-1 \
    cuda-cufft-dev-9-1 \
    cuda-curand-dev-9-1 \
    cuda-cusolver-dev-9-1 \
    cuda-cusparse-dev-9-1 \
```

have the `9-1` in the package names, if you are building a Cuda `10.1` then
you should replace the `9-1` everywhere by `10-1`.

## Building

Just run `(sudo) docker build -t build-torch .` in the same directory
as the one where the Dockerfile is stored. The pytorch wheel will be
stored on the `/pytorch/dist` directory of the container.

## Getting the wheel out of the container

There are [several ways](https://stackoverflow.com/questions/22049212/copying-files-from-docker-container-to-host) to copy
data from container to the host machine. Here is a suggestion:

`sudo docker cp CONTAINER_ID:/tmp/pip/torch-1.3.0a0+50c90a2-cp35-cp35m-linux_x86_64.whl .`

To get the `CONTAINER_ID` just run `docker ps -alq` or `docker ps` then see the `CONTAINER_ID`
respective to the `build-torch` image, or the one you -t `image tag` you gave in the
building command.
