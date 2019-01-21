VERSION  ?= 18.09.1
PVERSION ?= 1
ARCH     ?= x86_64

DIR=build/$(VERSION)/$(ARCH)

OUT=$(DIR)/docker_$(VERSION)_$(ARCH).opk

define CONTROL:
Package: docker
Version: ${VERSION}-${PVERSION}
Architecture: x86_64
Maintainer: Johannes 'fish' Ziemke
Depends: iptables kmod-ipt-extra iptables-mod-extra kmod-br-netfilter ca-certificates
Description: The Docker Engine packages for OpenWrt
endef

all: $(OUT)

$(OUT): $(DIR)/pkg/control.gz $(DIR)/pkg/data.tar.gz
	tar -czvf "$@" $<

$(DIR)/data:
	mkdir -p "$@/usr/bin"
	curl -L https://download.docker.com/linux/static/stable/$(ARCH)/docker-$(VERSION).tgz \
  	| tar -C "$@/usr/bin/" --strip=1 -xzvf -

$(DIR)/pkg/data.tar.gz: $(DIR)/data
	tar -C "$<" -czvf "$@" .

$(DIR)/pkg/control:
	mkdir -p $(dir $@)
	echo "$$CONTROL" > "$@"

$(DIR)/pkg/control.gz: $(DIR)/pkg/control
	tar -czvf "$@" "$<"

