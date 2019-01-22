VERSION  ?= 18.09.1
PVERSION ?= 1
ARCH     ?= x86_64

FILES = $(shell find files/ -type f)
DIR   = build/$(VERSION)/$(ARCH)
OUT   = build/docker_$(VERSION)_$(ARCH).opk

define CONTROL
Package: docker
Version: ${VERSION}-${PVERSION}
Architecture: x86_64
Maintainer: Johannes 'fish' Ziemke
Depends: iptables kmod-ipt-extra iptables-mod-extra kmod-br-netfilter ca-certificates
Description: The Docker Engine packages for OpenWrt
endef
export CONTROL

.PHONY: all
all: $(OUT)

build-all:
	if [ -n "$$(ls build/)" ]; then echo build/ not empty && exit 1; fi
	for a in $$(cat ARCHS); do \
		for v in $$(cat VERSIONS); do \
			make ARCH=$$a VERSION=$$v; \
		done; \
	done

.PHONY: release
release: build-all
	ghr -t ${GITHUB_TOKEN} -u ${CIRCLE_PROJECT_USERNAME} -r ${CIRCLE_PROJECT_REPONAME} \
		-c ${CIRCLE_SHA1} -delete ${PVERSION} build/

$(OUT): $(DIR)/pkg/control.tar.gz $(DIR)/pkg/data.tar.gz $(DIR)/pkg/debian-binary
	tar -C $(DIR)/pkg -czvf "$@" debian-binary data.tar.gz control.tar.gz

$(DIR)/data: $(FILES)
	mkdir -p "$@/usr/bin"
	cp -r files/* "$@"
	curl -L https://download.docker.com/linux/static/stable/$(ARCH)/docker-$(VERSION).tgz \
  	| tar -C "$@/usr/bin/" --strip=1 -xzvf -

$(DIR)/pkg/data.tar.gz: $(DIR)/data
	tar -C "$<" -czvf "$@" .

$(DIR)/pkg:
	mkdir -p $@

$(DIR)/pkg/debian-binary: $(DIR)/pkg
	echo 2.0 > $@

$(DIR)/pkg/control: $(DIR)/pkg
	echo "$$CONTROL" > "$@"

$(DIR)/pkg/control.tar.gz: $(DIR)/pkg/control
	tar -C $(DIR)/pkg -czvf "$@" control

.PHONY: clean
clean:
	rm -rf build/
