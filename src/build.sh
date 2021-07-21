#! /bin/bash

DOTNET_VERSION=6.0.0-rc.1.21370.5
ARCH=amd64
TAG=bullseye-slim
FLAVOR=-foo

docker build --pull --build-arg DOTNET_VERSION=$DOTNET_VERSION -t mcr.microsoft.com/dotnet/runtime$FLAVOR:6.0-$TAG-$ARCH runtime/6.0/$TAG/$ARCH/
docker build --build-arg ASPNET_VERSION=$DOTNET_VERSION --build-arg REPO=mcr.microsoft.com/dotnet/runtime$FLAVOR -t mcr.microsoft.com/dotnet/aspnet$FLAVOR:6.0-$TAG-$ARCH aspnet/6.0/$TAG/$ARCH/
docker build --build-arg REPO=mcr.microsoft.com/dotnet/aspnet$FLAVOR -t mcr.microsoft.com/dotnet/sdk$FLAVOR:6.0-$TAG-$ARCH sdk/6.0/$TAG/$ARCH/
