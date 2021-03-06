# compile srsLTE with qemu CPU "Denverton" (atom variant):
#
# docker build -f Dockerfile .
# fails with:
# 
#   /srsLTE/lib/include/srslte/adt/bounded_bitset.h:219:32: error: ‘newmask.srslte::bounded_bitset<100, true>::buffer[<unknown>]’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
#    219 |       buffer[i] &= other.buffer[i];
#        |                    ~~~~~~~~~~~~^
#   cc1plus: all warnings being treated as errors
#
# no problem most other amd64 platforms tested.

FROM ubuntu:20.04
MAINTAINER Charlie Lewis <clewis@iqt.org>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install --no-install-recommends -yq \
     cmake \
     libuhd-dev \
     uhd-host \
     libboost-program-options-dev \
     libvolk2-dev \
     libfftw3-dev \
     libmbedtls-dev \
     libsctp-dev \
     libconfig++-dev \
     libzmq3-dev \
     build-essential \
     git \
     ca-certificates \
     libpcsclite-dev \
     lksctp-tools \
     qemu-user

COPY cc /root
COPY c++ /root
COPY ccpatch.txt /root

WORKDIR /root
RUN git clone https://github.com/srsLTE/srsLTE.git -b release_20_10_1
WORKDIR /root/srsLTE
RUN patch -p1 < /root/ccpatch.txt

RUN mkdir -p /root/srsLTE/build
RUN mkdir /config
WORKDIR /root/srsLTE/build
RUN cmake ../
RUN gcc -v

RUN make -j srsenb_mac

ENTRYPOINT ["/bin/sh"]
