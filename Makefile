VERSION := $(shell cat ./Dockerfile | head -n 1 | sed -e 's/^.*://')
EMVER := $(shell yq e ".version" manifest.yaml)
S9PK_PATH=$(shell find . -name cwtch.s9pk -print)
CONFIGURATOR_SRC := $(shell find ./configurator/src)

.DELETE_ON_ERROR:

all: verify

verify:  cwtch.s9pk $(S9PK_PATH)
	embassy-sdk verify $(S9PK_PATH)

install: cwtch.s9pk
	embassy-cli package install cwtch.s9pk

cwtch.s9pk: manifest.yaml assets/compat/* image.tar docs/instructions.md LICENSE icon.png cwtch/app/main.go
	embassy-sdk pack
	
image.tar: Dockerfile docker_entrypoint.sh configurator/target/aarch64-unknown-linux-musl/release/configurator
	docker run --privileged --rm tonistiigi/binfmt --install arm64,riscv64,arm
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/cwtch/main:${EMVER} --platform=linux/arm64/v8 -f Dockerfile -o type=docker,dest=image.tar .

configurator/target/aarch64-unknown-linux-musl/release/configurator: $(CONFIGURATOR_SRC)
	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/configurator:/home/rust/src start9/rust-musl-cross:aarch64-musl cargo +beta build --release
	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/configurator:/home/rust/src start9/rust-musl-cross:aarch64-musl musl-strip target/aarch64-unknown-linux-musl/release/configurator

clean:
	rm -f cwtch.s9pk
	rm -f image.tar
