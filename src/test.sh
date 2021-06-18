#! /bin/bash

DOTNET_VERSION=6.0.0-preview.7.21316.3
ARCH=amd64
TAG=bullseye-slim

docker pull mcr.microsoft.com/dotnet/sdk:6.0-$TAG-$ARCH

mkdir logs
git clone --depth 1 https://github.com/dotnet/roslyn
echo composite with TC
time docker run --rm -it  -v $(pwd)/logs:/logs -v $(pwd)/roslyn:/roslyn -w /roslyn mcr.microsoft.com/dotnet/sdk-composite:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-composite.txt"
rm -rf roslyn
git clone --depth 1 https://github.com/dotnet/roslyn
echo composite with TC disabled
time docker run --rm -it -v $(pwd)/logs:/logs -v $(pwd)/roslyn:/roslyn -w /roslyn -e COMPlus_TieredCompilation=0 mcr.microsoft.com/dotnet/sdk-composite:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-composite-no-tc.txt"
rm -rf roslyn
git clone --depth 1 https://github.com/dotnet/roslyn
echo non-composite with TC
time docker run --rm -it -v $(pwd)/logs:/logs -v $(pwd)/roslyn:/roslyn -w /roslyn mcr.microsoft.com/dotnet/sdk:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-baseline.txt"
rm -rf roslyn
git clone --depth 1 https://github.com/dotnet/roslyn
echo composite with TC disabled
time docker run --rm -it -v $(pwd)/logs:/logs -v $(pwd)/roslyn:/roslyn -w /roslyn -e COMPlus_TieredCompilation=0 mcr.microsoft.com/dotnet/sdk:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-baseline-no-tc.txt"
rm -rf roslyn
