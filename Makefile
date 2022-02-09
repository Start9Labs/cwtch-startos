VERSION := $(shell cat ./Dockerfile | head -n 1 | sed -e 's/^.*://')
EMVER := $(shell yq e ".version" manifest.yaml)
S9PK_PATH=$(shell find . -name cwtch.s9pk -print)

.DELETE_ON_ERROR:

all: verify

verify:  cwtch.s9pk $(S9PK_PATH)
	embassy-sdk verify $(S9PK_PATH)

install: cwtch.s9pk
	embassy-cli package install cwtch.s9pk

cwtch.s9pk: manifest.yaml assets/compat/* image.tar docs/instructions.md LICENSE icon.png cwtch/app/main.go
	embassy-sdk pack
	
image.tar: Dockerfile docker_entrypoint.sh
	docker run --privileged --rm tonistiigi/binfmt --install arm64,riscv64,arm
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/cwtch/main:${EMVER} --platform=linux/arm64/v8 -f Dockerfile -o type=docker,dest=image.tar .

clean:
	rm -f cwtch.s9pk
	rm -f image.tar
