FROM alpine:latest AS base
RUN apk update
RUN apk add gdb

FROM base AS debug-build
RUN apk add build-base cmake git python3 py3-pip clang ninja util-linux
ARG BINARYEN_VERSION=version_125
RUN git clone --depth 1 --branch "${BINARYEN_VERSION}" https://github.com/WebAssembly/binaryen.git
WORKDIR /binaryen
RUN git submodule init
RUN git submodule update
RUN pip3 install --break-system-packages -r requirements-dev.txt
RUN cmake . -G Ninja -DCMAKE_CXX_FLAGS="-static" -DCMAKE_C_FLAGS="-static" -DCMAKE_BUILD_TYPE=Debug -DBUILD_STATIC_LIB=ON -DBUILD_MIMALLOC=ON -DCMAKE_INSTALL_PREFIX=install
RUN ninja install

FROM base AS debug
WORKDIR /work
COPY --from=debug-build /binaryen/bin/ bin/
COPY main ./
ENTRYPOINT ["gdb", "--batch", "-ex=run", "-ex=backtrace", "--args", "bin/wasm-opt", "--debug"]
CMD ["--asyncify", "-Oz", "-g", "main", "--output", "main.wasmopt"]


FROM base AS release-build
WORKDIR /binaryen
COPY download-binaryen.sh ./
ARG BINARYEN_VERSION=version_125
ARG BUILDARCH
RUN ./download-binaryen.sh "${BINARYEN_VERSION}" "${BUILDARCH}"

FROM base AS release
WORKDIR /work
COPY --from=release-build /binaryen/bin/ bin/
COPY main ./
ENTRYPOINT ["gdb", "-batch", "-ex=run", "-ex=backtrace", "--args", "bin/wasm-opt", "--debug"]
CMD ["--asyncify", "-Oz", "-g", "main", "--output", "main.wasmopt"]
