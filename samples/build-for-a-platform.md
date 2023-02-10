# Building images for a specific platform

Docker exposes [multiple ways to interact with platforms](https://docs.docker.com/build/building/multi-platform/). These mechanisms will sometimes result in the images you want and sometimes not depending on how you use them. The most common scenario for needing to pay attention to platform targeting is if you have an Arm64 development machine (like Apple M1) and are pushing images to an x64 cloud.

In Docker terminology, `platform` means operating system + architecture. For example the combination of Linux and x64 is a platform, described by the `linux/amd64` platform string. The `linux` part is relevant, however, the most common use for platform targeting is controlling the architecture, choosing (primarily) between `amd64` and `arm64`.

Note: `amd64` is used for historical reasons and is synonymous with "x64", however, `x64` is not an accepted alias.

## Tag types

Container registries support two tag types. These tag types are the most important aspect of platform targeting. It is common to use both tag types within a single `Dockerfile`.

Regular tags point directly to container content, like to a `linux/amd64` image. For example, the `6.0-jammy-amd64` tag will always give you an x64 image, no matter if you pull it on an Arm64 or x64 machine. The same is true with `6.0-alpine-arm64v8`, but will always result in a `linux/arm64` image.

Multi-platform (AKA "multi-arch" or "manifest") tags point to a list of images, each matching a specific platform. For example, one of these tags might point to `linux/amd64` and `linux/arm64` images. In that case (by default), you'll get a x64 image on an x64 machine and an Arm64 image on an Arm64 machine.

.NET offers many multi-arch tags. They are very useful, so it makes sense to use them liberally.

- `6.0` -- Two-part version tags provide Arm64, Arm32, and x64 images, both for Linux and Windows. The Linux images are always Debian, while the Windows images are Nano Server.
- `6.0.13` -- Same as the two-part tag, but for a specific patch version.
- `6.0-alpine` -- Two part version tag, specific to the latest Alpine.
- `6.0-alpine-3.17` -- Two part version tag, specific to one Alpine version.
- `6.0-bullseye-slim` -- Two-part version tag, specific to Debian 11.
- `6.0-jammy` -- Two-part version tag, specific to Ubuntu 22.04.

Note: two-part .NET version tags always pull the latest .NET patch. For example, if `6.0.13` was the latest .NET 6 patch version, then the `6.0` and `6.0.13` tags would point to the exact same content.

You can tell the difference between these tags, because regular tags include the processor-architecture and manifest tags do not.

Note: "multi-platform" is the correct name for these tags, while "multi-arch" is more commonly used, since most scenarios only require architecture targeting
.

## Dockerfiles that build everywhere

The default scenario is using multi-arch tags, which will work in multiple environments.

The [Dockerfile](Dockerfile) example demonstrates this case, using the following `docker build` invocation.

```bash
docker build -t app .
```

It can be built on any supported operating system and architecture. For example, if built on an Apple M1 machine, Docker will produce a `linux/armv8` image, while on a Windows x64 machine, it will produce a `linux/amd64` image or some form of Windows x64 container image (in Windows Container mode).

This model works very well given a homogenous compute environment. For example, it works well if dev, CI, and prod machines are all x64. However, it doesn't as well in heterogenous environments, like if dev machines are Arm64 and prod machines are x64. This is because multiple chip architectures need to run on the same machine, which requires the use of emulation. .NET doesn't support this kind of emulation, which is discussed at the end of this document.

## Lock Dockerfiles to one platform

Arguably, the simplest approach is to always build for one platform with Dockerfiles that reference tags for that platform. This model has the benefit that Dockerfiles are simple and simple to build. It has the downside that it can result in a Dockerfile per platform, that each needs to be built separately, and the right one needs to be picked for a given environment (although the filenames can be sufficiently descriptive).

The following are examples of this model:

- [Dockerfile.debian-x64](Dockerfile.debian-x64)
- [Dockerfile.alpine-arm64](Dockerfile.debian-arm64)

They can be built with:

```bash
docker build -t app .
```

That's the same simple invocation as shared earlier. The same approach can be applied to other variants other than two examples listed.

## Conditionalize Dockerfile with `--platform`

Docker offers the `--platform` argument, which both is both perfect for building for one or more arbitrary platforms and can also be the reason why .NET sometimes runs emulated and fail to build. The trick is to get the SDK to always run natively, but use the `--platform` switch to select the final image.



## .NET and QEMU

Docker desktop uses [QEMU](https://www.qemu.org/) for emulation, for example running x64 code on an Arm64 machine. .NET doesn't support being run in QEMU. That means that the SDK needs to always be run natively, to enable [multi-stage build](https://docs.docker.com/build/building/multi-stage/). Multi-stage build is used by all of our samples.

As a result, we need a reliable pattern that enables produces multiple variants of images on one machine, but that doesn't use emulation.

Context: https://gitlab.com/qemu-project/qemu/-/issues/249 
