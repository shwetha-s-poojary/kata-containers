# Copyright (c) 2021 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

FROM public.ecr.aws/ubuntu/ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_IN_GOPATH=false

COPY install_yq.sh /usr/bin/install_yq.sh

# Switch to HTTPS repositories to work around HTTP port 80 being blocked
RUN sed -i 's|http://ports.ubuntu.com|https://ports.ubuntu.com|g' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null || true && \
    sed -i 's|http://archive.ubuntu.com|https://archive.ubuntu.com|g' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null || true

# kernel deps
# Temporarily disable certificate verification to install ca-certificates (chicken-and-egg problem)
RUN apt-get -o Acquire::https::Verify-Peer=false -o Acquire::https::Verify-Host=false update && \
    apt-get -o Acquire::https::Verify-Peer=false -o Acquire::https::Verify-Host=false install -y --no-install-recommends ca-certificates && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
	    bc \
	    bison \
	    build-essential \
	    curl \
	    debhelper \
	    dwarves \
	    flex \
	    git \
	    iptables \
	    kmod \
	    libdw-dev \
	    libelf-dev \
	    libssl-dev \
	    gettext \
	    rsync \
	    cpio \
	    patch \
	    python3 && \
    apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*

RUN install_yq.sh
