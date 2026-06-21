FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y \
    # Build tools
    gcc gcc-aarch64-linux-gnu \
    make flex bison bc pahole \
    libelf-dev libssl-dev \
    cpio kmod rsync \
    # Static analysis
    sparse coccinelle \
    # QEMU
    qemu-system-arm \
    qemu-system-x86 \
    # virtme-ng deps
    busybox-static file \
    # Selftest deps
    libpopt-dev \
    libcap-dev \
    libmnl-dev \
    clang llvm \
    # Network tools
    nftables iptables iproute2 iputils-ping \
    ethtool socat netcat-openbsd \
    # Python
    python3 python3-pip python3-yaml \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install virtme-ng from source so the guest init binary is compiled
# for the host architecture (aarch64), not the pre-built x86_64 binary
# bundled in the PyPI wheel.
RUN pip3 install --break-system-packages build && \
    git clone https://github.com/arighi/virtme-ng.git /opt/virtme-ng && \
    cd /opt/virtme-ng && \
    pip3 install --break-system-packages -e .

ENV PATH=$PATH:/root/.local/bin

WORKDIR /kernel
