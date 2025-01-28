# Use an official Python runtime as a parent image
FROM nvidia/cuda:12.6.1-devel-ubuntu24.04

# Set the working directory in the container
WORKDIR /app


ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES},video

RUN apt-get update && apt-get install -y python3-pip build-essential git yasm nasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev pkg-config \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    libcpu-features-dev \
    pkg-config \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Install system dependencies
RUN apt-get update && apt-get install -y python3-pip

RUN pip3 install --break-system-packages fastapi==0.101.0 \
    pydantic==2.1.1 \
    pydantic_core==2.4.0 \
    urllib3==2.0.4 \
    uvicorn==0.23.2 \
    transformers \
    torch==2.5.1 \
    boto3 \
    accelerate


RUN mkdir /app/nvidia/ && cd /app/nvidia/ \
    && git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git nv-codec-headers \
    && cd nv-codec-headers && make install 

RUN cd /var/nvidia/ \
    && git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/ \
    && cd ffmpeg/ \
    && ./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 \
    && make -j $(nproc) \
    && make install


COPY . /app

# Make port 8000 available to the world outside this container
EXPOSE 8080

# Define an environment variable
# This variable will be used by Uvicorn as the binding address
ENV HOST 0.0.0.0

# Run the FastAPI application using Uvicorn when the container launches
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
