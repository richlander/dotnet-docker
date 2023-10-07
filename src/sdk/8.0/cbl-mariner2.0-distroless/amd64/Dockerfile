ARG REPO=mcr.microsoft.com/dotnet/aspnet

# Installer image
FROM mcr.microsoft.com/cbl-mariner/base/core:2.0 AS installer
ENV DOTNET_SDK_VERSION=8.0.100-rc.1.23463.5

RUN tdnf install -y \
        gawk \
        shadow-utils \
        ca-certificates \
        tar \
    && tdnf clean all

# Install .NET's dependencies into a staging location
RUN mkdir /staging \
    && tdnf install -y --releasever=2.0 --installroot /staging \
        prebuilt-ca-certificates \
        bash \
        \
        # .NET dependencies
        glibc \
        libgcc \
        libstdc++ \
        openssl-libs \
        zlib \
    && tdnf clean all --releasever=2.0 --installroot /staging

# Generate RPM manifest file by appending to the original manifest file from base distroless image
COPY --from=mcr.microsoft.com/cbl-mariner/distroless/minimal:2.0 /var/lib/rpmmanifest/container-manifest-2 /tmp/rpmmanifest
RUN tmpManifestPath="/tmp/rpmmanifest" \
    && rpm --query --all --queryformat "%{NAME}\t%{VERSION}-%{RELEASE}\t%{INSTALLTIME}\t%{BUILDTIME}\t%{VENDOR}\t%{EPOCH}\t%{SIZE}\t%{ARCH}\t%{EPOCHNUM}\t%{SOURCERPM}\n" --root /staging | grep -v gpg-pubkey >> $tmpManifestPath \
    && mkdir -p /staging/var/lib/rpmmanifest \
    # Remove duplicates that match on the first field (package name)
    && tac $tmpManifestPath | gawk '!x[$1]++' | sort > /staging/var/lib/rpmmanifest/container-manifest-2

# Create a non-root user and group
RUN groupadd \
        --gid=1654 \
        app \
    && useradd -l \
        --uid=1654 \
        --gid=1654 \
        --shell /bin/false \
        --create-home \
        app \
    && install -d -m 0755 -o 1654 -g 1654 "/staging/home/app" \
    && rootOrAppRegex='^\(root\|app\):' \
    && cat /etc/passwd | grep $rootOrAppRegex > "/staging/etc/passwd" \
    && cat /etc/group | grep $rootOrAppRegex > "/staging/etc/group"

# Clean up staging
RUN rm -rf /staging/etc/tdnf \
    && rm -rf /staging/run/* \
    && rm -rf /staging/var/cache/tdnf \
    && rm -rf /staging/var/lib/rpm \
    && rm -rf /staging/usr/share/doc \
    && rm -rf /staging/usr/share/man \
    && find /staging/var/log -type f -size +0 -delete

# Install .NET SDK
RUN curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='ac941fd16fd7c328f7cc44b132b4253ddb2b6a6c152af5f43c71c6cd0d468c89b7276ebf6c08895dcb6e5e25f7cae83b6fbacb91cfcc4a61d49b5657a834a901' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /dotnet \
    && tar -oxzf dotnet.tar.gz -C /dotnet

RUN mkdir /dotnet-symlink \
    && ln -s /usr/share/dotnet/dotnet /dotnet-symlink/dotnet

# .NET runtime-deps image
FROM mcr.microsoft.com/cbl-mariner/distroless/minimal:2.0

ENV \
    # UID of the non-root user 'app'
    APP_UID=1654 \
    # Configure web servers to bind to port 8080 when present
    ASPNETCORE_HTTP_PORTS=8080 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Set the invariant mode since ICU package isn't included (see https://github.com/dotnet/announcements/issues/20)
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    DOTNET_NOLOGO=true \
    # SDK version
    DOTNET_SDK_VERSION=8.0.100-rc.1.23463.5 \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip    

COPY --from=installer /staging/ /

# Workaround for https://github.com/moby/moby/issues/38710
COPY --from=installer --chown=1654:1654 /staging/home/app /home/app
COPY --from=installer ["/dotnet", "/usr/share/dotnet"]
COPY --from=installer ["/dotnet-symlink", "/usr/bin"]

USER app

ENTRYPOINT ["/usr/bin/dotnet"]
CMD ["--info"]
