# Docker on OpenWrt
Makefile to generate OpenWrt .opkg packages from official Docker binaries.

## Use it
### Build compatible kernel
TBD, for now see my personal openwrt build here for sample config:
https://github.com/5pi-home/openwrt

### Install it
```
opkg install https://github.com/discordianfish/docker-on-openwrt/releases/download/2/docker_18.09.0_x86_64.opk
```

### Run containers
The package contains the `/etc/init.d/containers` init script to provide an easy
way to start containers. Here is an example how to use it to run Prometheus and
Plex:

```
config container 'plex'
  option name 'plex'
  option image 'plexinc/pms-docker:1.14.1.5488-cc260c476'
  option hostname 'plex'

  list 'port' '32400:32400/tcp'
  list 'port' '3005:3005/tcp'
  list 'port' '8324:8324/tcp'
  list 'port' '32469:32469/tcp'
  list 'port' '1900:1900/udp'
  list 'port' '32410:32410/udp'
  list 'port' '32412:32412/udp'
  list 'port' '32413:32413/udp'
  list 'port' '32414:32414/udp'

  list 'env' 'TZ=Europe/Berlin'
  list 'env' 'PLEX_CLAIM=claim-abcd'
  list 'env' 'ADVERTISE_IP=http://openwrt:32400'
  list 'env' 'HOSTNAME=plex'

  list 'volume' '/data/plex/config:/config'
  list 'volume' '/data/plex/temp:/transcode'
  list 'volume' '/hdd/media:/data'

config container 'prometheus'
  option name  'prometheus'
  option image 'prom/prometheus:v2.7.2'
  option user  'root:root'

  list port   '9090:9090/tcp'
  list volume '/data/prometheus:/prometheus'
```

## Build it
Run `make` to build the default version for `x86_64`. You can override ARCH and
VERSION, e.g `make ARCH=armhf` but most combinations are untested.
