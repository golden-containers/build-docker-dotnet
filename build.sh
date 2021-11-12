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
[ -z $(command -v gsed) ] && GNU_SED=sed || GNU_SED=gsed

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/" src/runtime-deps/3.1/bullseye-slim/amd64/Dockerfile

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/" src/runtime/3.1/bullseye-slim/amd64/Dockerfile

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime\:3.1-bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime\:3.1-bullseye-slim/" src/aspnet/3.1/bullseye-slim/amd64/Dockerfile

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/buildpack-deps\:bullseye-scm/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/buildpack-deps\:bullseye-scm/" src/sdk/3.1/bullseye/amd64/Dockerfile


# Build

docker build src/runtime-deps/3.1/bullseye-slim/amd64/ --platform linux/amd64 --tag ghcr.io/golden-containers/dotnet/runtime-deps:3.1-bullseye-slim --label ${1:-DEBUG=TRUE}
docker build src/runtime/3.1/bullseye-slim/amd64/ --platform linux/amd64 --tag ghcr.io/golden-containers/dotnet/runtime:3.1-bullseye-slim --label ${1:-DEBUG=TRUE}
docker build src/aspnet/3.1/bullseye-slim/amd64/ --platform linux/amd64 --tag ghcr.io/golden-containers/dotnet/aspnet:3.1-bullseye-slim --label ${1:-DEBUG=TRUE}
docker build src/sdk/3.1/bullseye/amd64/ --platform linux/amd64 --tag ghcr.io/golden-containers/dotnet/sdk:3.1-bullseye-slim --label ${1:-DEBUG=TRUE}

# Push

docker push ghcr.io/golden-containers/dotnet/runtime-deps -a
docker push ghcr.io/golden-containers/dotnet/runtime -a
docker push ghcr.io/golden-containers/dotnet/aspnet -a
docker push ghcr.io/golden-containers/dotnet/sdk -a
