# Docker on OpenWrt
Makefile to generate OpenWrt .opkg packages from official Docker binaries.

## Usage
Run `make` to build the default version for `x86_64`. You can override ARCH and
VERSION, e.g `make ARCH=armhf` but most combinations are untested.
