#! /bin/bash

DOTNET_VERSION=6.0.0-preview.7.21316.3
ARCH=amd64
TAG=bullseye-slim

git clone --depth 1 https://github.com/dotnet/roslyn roslyn-temp
docker pull mcr.microsoft.com/dotnet/sdk:6.0-$TAG-$ARCH

echo check for composite file
docker run --rm -it -w /usr/share/dotnet/shared mcr.microsoft.com/dotnet/sdk-composite:6.0-$TAG-$ARCH find . | grep r2r

mkdir -p logs

echo composite with TC
cp -r roslyn-temp roslyn-temp1
time docker run --rm -it  -v $(pwd)/logs:/logs -v $(pwd)/roslyn-temp1:/roslyn -w /roslyn mcr.microsoft.com/dotnet/sdk-composite:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-composite.txt"
echo composite with TC disabled
cp -r roslyn-temp roslyn-temp2
time docker run --rm -it -v $(pwd)/logs:/logs -v $(pwd)/roslyn-temp2:/roslyn -w /roslyn -e COMPlus_TieredCompilation=0 mcr.microsoft.com/dotnet/sdk-composite:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-composite-no-tc.txt"
echo non-composite with TC
cp -r roslyn-temp roslyn-temp3
time docker run --rm -it -v $(pwd)/logs:/logs -v $(pwd)/roslyn-temp3:/roslyn -w /roslyn mcr.microsoft.com/dotnet/sdk:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-baseline.txt"
echo composite with TC disabled
cp -r roslyn-temp roslyn-temp4
time docker run --rm -it -v $(pwd)/logs:/logs -v $(pwd)/roslyn-temp4:/roslyn -w /roslyn -e COMPlus_TieredCompilation=0 mcr.microsoft.com/dotnet/sdk:6.0-$TAG-$ARCH bash -c "dotnet build Compilers.sln > /logs/logs-baseline-no-tc.txt"
rm -rf roslyn-temp* > /dev/null
