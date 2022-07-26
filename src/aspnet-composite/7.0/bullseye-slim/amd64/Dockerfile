ARG REPO=mcr.microsoft.com/dotnet/runtime-deps

# Installer image
FROM amd64/buildpack-deps:bullseye-curl AS installer

# Retrieve ASP.NET Core 
RUN aspnetcore_version=7.0.0-rc.1.22365.3 \
    && curl -fSL --output aspnetcore.tar.gz https://dotnetbuilds.blob.core.windows.net/public/aspnetcore/Runtime/7.0.0-rc.1.22376.1/aspnetcore-runtime-7.0.0-rc.1.22376.1-linux-x64-composite.tar.gz \
    && mkdir -p /dotnet \
    && tar -oxzf aspnetcore.tar.gz -C /dotnet \
    && rm aspnetcore.tar.gz

# ASP.NET Core image
FROM $REPO:7.0.0-preview.7-bullseye-slim-amd64

# ASP.NET Core version
ENV ASPNET_VERSION=7.0.0-rc.1.22365.3

COPY --from=installer ["/dotnet", "/usr/share/dotnet"]

RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
