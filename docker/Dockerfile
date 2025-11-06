FROM ubuntu:focal

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential sudo wget cmake git

RUN adduser --disabled-password --gecos "" developer && \
  usermod -a -G sudo developer && \
  echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd

RUN mkdir /opt/toolchains && \
    wget https://github.com/ballaswag/k1-discovery/releases/download/1.0.0/mips-gcc720-glibc229.tar.gz -O /tmp/mips-gcc720-glibc229.tar.gz && \
    tar -zxf /tmp/mips-gcc720-glibc229.tar.gz -C /opt/toolchains && \
    rm /tmp/mips-gcc720-glibc229.tar.gz

# auto-extracts gzip/bzip2/xz tars into /opt/k1-sysroot
ADD k1-sysroot-min.tar.gz /opt/
ENV SYSROOT=/opt/k1-sysroot
RUN test -f $SYSROOT/lib/ld-linux-mipsn8.so.1 && test -f $SYSROOT/lib/libc.so.6

# this is for building nginx
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-user-static

ENV PATH=/opt/toolchains/mips-gcc720-glibc229/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER developer
WORKDIR /home/developer
