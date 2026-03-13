# Use x86_64 Ubuntu 20.04 on Apple Silicon
FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install basic tools and add repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    curl \
    sudo \
    git \
    locales \
    build-essential \
    gnupg \
    ca-certificates \
    lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add LLVM repository for Clang 16
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-16 main" >> /etc/apt/sources.list \
    && apt-get update

# Add Ubuntu Toolchain PPA for newer GCC versions
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update

# Install PandA dependencies (GCC, Clang, multilib, libraries)
RUN apt-get install -y --no-install-recommends \
    autoconf \
    autoconf-archive \
    automake \
    bison \
    clang-16 \
    clang-tools-16 \
    llvm-16-dev \
    llvm-16-tools \
    libclang-16-dev \
    doxygen \
    flex \
    g++-8 \
    g++-8-multilib \
    g++-9 \
    g++ \
    gcc-8 \
    gcc-8-plugin-dev \
    gcc-8-multilib \
    gcc-9 \
    gcc \
    gfortran-8 \
    gfortran-8-multilib \
    gfortran-9 \
    gfortran \
    gcc-multilib \
    g++-multilib \
    graphviz \
    libbdd-dev \
    libboost-all-dev \
    libfl-dev \
    libglpk-dev \
    libicu-dev \
    liblzma-dev \
    libmpc-dev \
    libmpfi-dev \
    libmpfr-dev \
    libsuitesparse-dev \
    libtool \
    libxml2-dev \
    make \
    pkg-config \
    verilator \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# PYTHON 3.13 INSTALLATION (NEW SECTION)
# ---------------------------------------------------------

RUN apt-get update && apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN curl https://pyenv.run | bash

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Install Python 3.13
RUN pyenv install 3.13.0 && \
    pyenv global 3.13.0

# ---------------------------------------------------------
# COMPILER CONFIGURATION
# ---------------------------------------------------------

# Set default GCC/Clang versions
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 70 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-8 \
    --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-8 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-16 100

# PANDA configuration
# ENV PATH="/opt/panda/bin:${PATH}"

# ---------------------------------------------------------
# SETUP USER WORKSPACE
# ---------------------------------------------------------

WORKDIR /workspace

CMD ["/bin/bash"]

