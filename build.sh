#!/bin/sh

set -xe
rm -rf working
mkdir working
cd working

# Checkout upstream

# git clone --depth 1 --branch main https://github.com/upstream/upstream.git
# cd upstream

# Transform

# sed -i -e "1 s/FROM.*/FROM ghcr.io\/golden-containers\/bullseye/; t" -e "1,// s//FROM ghcr.io\/golden-containers\/bullseye/" 17/bullseye/Dockerfile

# Build

# docker build --tag ghcr.io/golden-containers/upstream-bullseye-slim:17 17/bullseye-slim

# Push

# docker push ghcr.io/golden-containers/upstream-bullseye-slim:17
