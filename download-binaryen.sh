#!/bin/sh
set -o errexit
set -o nounset
set -o pipefail

version="$1"
arch="$2"

case "${arch}" in
  "amd64")
    arch="x86_64"
    ;;

  "arm64")
    arch="aarch64"
    ;;
esac

download_release_artifact() {
  filename="$1"
  wget -O "$filename" "https://github.com/WebAssembly/binaryen/releases/download/${version}/${filename}"
}

archive="binaryen-${version}-${arch}-linux.tar.gz"
checksum="${archive}.sha256"

download_release_artifact "${checksum}"
download_release_artifact "${archive}"

sha256sum -c "${checksum}"

tar --extract --file="${archive}" --strip-components=1
