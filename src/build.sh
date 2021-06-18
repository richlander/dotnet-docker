#! /bin/bash

DOTNET_VERSION=6.0.0-preview.7.21316.3
ARCH=amd64
TAG=bullseye-slim

docker build --pull --build-arg DOTNET_VERSION=$DOTNET_VERSION -t mcr.microsoft.com/dotnet/runtime-composite:6.0-$TAG-$ARCH runtime/6.0/$TAG/$ARCH/
docker build --build-arg REPO=mcr.microsoft.com/dotnet/runtime-composite -t mcr.microsoft.com/dotnet/aspnet-composite:6.0-$TAG-$ARCH aspnet/6.0/$TAG/$ARCH/
docker build --build-arg REPO=mcr.microsoft.com/dotnet/aspnet-composite -t mcr.microsoft.com/dotnet/sdk-composite:6.0-$TAG-$ARCH sdk/6.0/$TAG/$ARCH/
