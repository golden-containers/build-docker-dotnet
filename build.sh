#!/bin/bash

set -Eeuxo pipefail
rm -rf working
mkdir working
cd working

GCI_URL="ghcr.io/golden-containers"

# Checkout upstream

git clone --depth 1 --branch main https://github.com/dotnet/dotnet-docker.git
cd dotnet-docker

# Transform

GCI_REGEX_URL=$(echo ${GCI_URL} | sed 's/\//\\\//g')

# This sed syntax is GNU sed specific
[ -z "$(command -v gsed)" ] && GNU_SED=sed || GNU_SED=gsed

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ${GCI_REGEX_URL}\/debian\:bullseye-slim/; t" \
    -e "1,// s//FROM ${GCI_REGEX_URL}\/debian\:bullseye-slim/" \
    src/runtime-deps/3.1/bullseye-slim/amd64/Dockerfile

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ${GCI_REGEX_URL}\/dotnet\/runtime-deps\:3.1-bullseye-slim/; t" \
    -e "1,// s//FROM ${GCI_REGEX_URL}\/dotnet\/runtime-deps\:3.1-bullseye-slim/" \
    src/runtime/3.1/bullseye-slim/amd64/Dockerfile

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ${GCI_REGEX_URL}\/dotnet\/runtime\:3.1-bullseye-slim/; t" \
    -e "1,// s//FROM ${GCI_REGEX_URL}\/dotnet\/runtime\:3.1-bullseye-slim/" \
    src/aspnet/3.1/bullseye-slim/amd64/Dockerfile

${GNU_SED} -i \
    -e "1 s/FROM.*/FROM ${GCI_REGEX_URL}\/buildpack-deps\:bullseye-scm/; t" \
    -e "1,// s//FROM ${GCI_REGEX_URL}\/buildpack-deps\:bullseye-scm/" \
    src/sdk/3.1/bullseye/amd64/Dockerfile

# Build

[ -z "${1:-}" ] && BUILD_LABEL_ARG="" || BUILD_LABEL_ARG=" --label \"${1}\" "

BUILD_PLATFORM=" --platform linux/amd64 "
BUILD_ARGS=" ${BUILD_LABEL_ARG} ${BUILD_PLATFORM} "

docker build src/runtime-deps/3.1/bullseye-slim/amd64/ ${BUILD_ARGS} \
    --tag ${GCI_URL}/dotnet/runtime-deps:3.1-bullseye-slim
    
docker build src/runtime/3.1/bullseye-slim/amd64/ ${BUILD_ARGS} \
    --tag ${GCI_URL}/dotnet/runtime:3.1-bullseye-slim

docker build src/aspnet/3.1/bullseye-slim/amd64/ ${BUILD_ARGS} \
    --tag ${GCI_URL}/dotnet/aspnet:3.1-bullseye-slim

docker build src/sdk/3.1/bullseye/amd64/ ${BUILD_ARGS} \
    --tag ${GCI_URL}/dotnet/sdk:3.1-bullseye

# Push

docker push ${GCI_URL}/dotnet/runtime-deps -a
docker push ${GCI_URL}/dotnet/runtime -a
docker push ${GCI_URL}/dotnet/aspnet -a
docker push ${GCI_URL}/dotnet/sdk -a
