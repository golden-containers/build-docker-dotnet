#!/bin/bash

set -Eeuxo pipefail
rm -rf working
mkdir working
cd working

# Checkout upstream

git clone --depth 1 --branch main https://github.com/dotnet/dotnet-docker.git
cd dotnet-docker

# Transform

# This sed syntax is GNU sed specific
[ -z "$(command -v gsed)" ] && GNU_SED=sed || GNU_SED=gsed

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/; t" \
    -e "1,// s//FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/" \
    src/runtime-deps/3.1/bullseye-slim/amd64/Dockerfile

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/; t" \
    -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/" \
    src/runtime/3.1/bullseye-slim/amd64/Dockerfile

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime\:3.1-bullseye-slim/; t" \
    -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime\:3.1-bullseye-slim/" \
    src/aspnet/3.1/bullseye-slim/amd64/Dockerfile

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/buildpack-deps\:bullseye-scm/; t" \
    -e "1,// s//FROM ghcr.io\/golden-containers\/buildpack-deps\:bullseye-scm/" \
    src/sdk/3.1/bullseye/amd64/Dockerfile

# Build

[ -z "${1:-}" ] && BUILD_LABEL_ARG="" || BUILD_LABEL_ARG=" --label \"${1}\" "

BUILD_PLATFORM=" --platform linux/amd64 "
GCI_URL="ghcr.io/golden-containers"
BUILD_ARGS=" ${BUILD_LABEL_ARG} ${BUILD_PLATFORM} "

docker build src/runtime-deps/3.1/bullseye-slim/amd64/ --tag ${GCI_URL}/dotnet/runtime-deps:3.1-bullseye-slim ${BUILD_ARGS}
docker build src/runtime/3.1/bullseye-slim/amd64/ --tag ${GCI_URL}/dotnet/runtime:3.1-bullseye-slim ${BUILD_ARGS}
docker build src/aspnet/3.1/bullseye-slim/amd64/ --tag ${GCI_URL}/dotnet/aspnet:3.1-bullseye-slim ${BUILD_ARGS}
docker build src/sdk/3.1/bullseye/amd64/ --tag ${GCI_URL}/dotnet/sdk:3.1-bullseye ${BUILD_ARGS}

# Push

docker push ${GCI_URL}/dotnet/runtime-deps -a
docker push ${GCI_URL}/dotnet/runtime -a
docker push ${GCI_URL}/dotnet/aspnet -a
docker push ${GCI_URL}/dotnet/sdk -a
