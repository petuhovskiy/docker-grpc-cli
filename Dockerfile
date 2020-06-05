FROM ubuntu:bionic as builder

# RUN set -xe \
#     && apk add --no-cache \
#         autoconf \
#         automake \
#         build-base \
#         cmake \
#         git \
#         libtool \
#         zlib-dev

RUN apt-get update && apt-get install -y \
    build-essential autoconf libtool pkg-config \
    cmake libgflags-dev git

ARG GRPC_VERSION

# RUN if [[ -z "$GRPC_VERSION" ]]; then echo "GRPC_VERSION argument MUST be set" && exit 1; fi

RUN git clone --depth 1 --recursive -b v1.29.1 https://github.com/grpc/grpc.git /grpc
RUN cd /grpc && git submodule update --init

# ENV LDFLAGS=-static

RUN mkdir -p /grpc/cmake/build \
    && cd /grpc/cmake/build \
    && cmake -DgRPC_BUILD_TESTS=ON ../.. 
    
RUN cd /grpc/cmake/build && make -j4 grpc_cli

RUN pwd

RUN ls -lah

RUN ls -lah /grpc

RUN ls -lah /grpc/cmake/build

# RUN cd /grpc/third_party/gflags \
#     && mkdir build && cd build \
#     && cmake -DBUILD_SHARED_LIBS=0 -DGFLAGS_INSTALL_SHARED_LIBS=0 .. \
#     && make -j2 \
#     && make install

# RUN cd /grpc && make -j2 grpc_cli


FROM debian:buster
COPY --from=builder /grpc/cmake/build/grpc_cli /grpc_cli
COPY --from=builder /grpc/etc/roots.pem /usr/local/share/grpc/roots.pem

ENTRYPOINT ["/grpc_cli"]
CMD ["help"]
