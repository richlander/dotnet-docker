# Learn about building .NET container images:
# https://github.com/dotnet/dotnet-docker/blob/main/samples/README.md
FROM mcr.microsoft.com/dotnet/sdk:8.0-preview-alpine AS build
RUN apk add build-base clang zlib-dev

WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore --use-current-runtime

# copy everything else and build app
COPY . .
RUN dotnet publish --use-current-runtime --no-restore -o /app


# final stage/image
FROM alpine
ENV \
    # UID of the non-root user 'app'
    APP_UID=64198 \
    # Configure web servers to bind to port 8080 when present
    ASPNETCORE_HTTP_PORTS=8080 \
    # Set the invariant mode since ICU package isn't included (see https://github.com/dotnet/announcements/issues/20)
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

WORKDIR /app
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT ["./webapi"]
