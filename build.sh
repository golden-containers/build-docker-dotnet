#!/bin/sh

set -Eeuxo pipefail
rm -rf working
mkdir working
cd working

# Checkout upstream

git clone --depth 1 --branch main https://github.com/dotnet/dotnet-docker.git
cd dotnet-docker

# Transform

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/debian\:bullseye-slim/" src/runtime-deps/3.1/bullseye-slim/amd64/Dockerfile
echo "LABEL ${1:-DEBUG=TRUE}" >> src/runtime-deps/3.1/bullseye-slim/amd64/Dockerfile

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime-deps\:3.1-bullseye-slim/" src/runtime/3.1/bullseye-slim/amd64/Dockerfile
echo "LABEL ${1:-DEBUG=TRUE}" >> src/runtime/3.1/bullseye-slim/amd64/Dockerfile

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/dotnet\/runtime\:3.1-bullseye-slim/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/dotnet\/runtime\:3.1-bullseye-slim/" src/aspnet/3.1/bullseye-slim/amd64/Dockerfile
echo "LABEL ${1:-DEBUG=TRUE}" >> src/aspnet/3.1/bullseye-slim/amd64/Dockerfile

sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/buildpack-deps\:bullseye-scm/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/buildpack-deps\:bullseye-scm/" src/sdk/3.1/bullseye/amd64/Dockerfile
echo "LABEL ${1:-DEBUG=TRUE}" >> src/sdk/3.1/bullseye/amd64/Dockerfile


# Build

docker build --tag ghcr.io/golden-containers/dotnet/runtime-deps:3.1-bullseye-slim src/runtime-deps/3.1/bullseye-slim/amd64/
docker build --tag ghcr.io/golden-containers/dotnet/runtime:3.1-bullseye-slim src/runtime/3.1/bullseye-slim/amd64/
docker build --tag ghcr.io/golden-containers/dotnet/aspnet:3.1-bullseye-slim src/aspnet/3.1/bullseye-slim/amd64/
docker build --tag ghcr.io/golden-containers/dotnet/sdk:3.1-bullseye-slim src/sdk/3.1/bullseye/amd64/

# Push

docker push ghcr.io/golden-containers/dotnet/runtime-deps -a
docker push ghcr.io/golden-containers/dotnet/runtime -a
docker push ghcr.io/golden-containers/dotnet/aspnet -a
docker push ghcr.io/golden-containers/dotnet/sdk -a
