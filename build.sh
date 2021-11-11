#!/bin/sh

set -xe
rm -rf working
mkdir working
cd working

# Checkout upstream

git clone --depth 1 --branch main https://github.com/dotnet/dotnet-docker.git
cd dotnet-docker

# Transform

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/" src/runtime-deps/3.1/bullseye-slim/amd64/Dockerfile
sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/" src/runtime/3.1/bullseye-slim/amd64/Dockerfile

# Build

docker build --tag ghcr.io/golden-containers/dotnet/runtime-deps:3.1-bullseye-slim src/runtime-deps/3.1/bullseye-slim/amd64/

# Push

docker push ghcr.io/golden-containers/dotnet/runtime-deps -a
