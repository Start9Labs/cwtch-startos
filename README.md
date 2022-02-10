# Wrapper for Cwtch

`Cwtch` is an open source flutter based messaging service.

## Dependencies

- [docker](https://docs.docker.com/get-docker)
- [docker-buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [yq](https://mikefarah.gitbook.io/yq)
- [toml](https://crates.io/crates/toml-cli)
- [make](https://www.gnu.org/software/make/)
- [embassy-sdk]

## Cloning

Clone the project locally. Note the submodule link to the original project(s). 

```
git clone git@github.com:Start9Labs/cwtch-wrapper.git
cd cwtch-wrapper
git submodule update --init --recursive
```

## Building

To build the project, run the following commands:

```
make
```

## Installing (on Embassy)

SSH into an Embassy device.
`scp` the `.s9pk` to any directory from your local machine.

```
scp cwtch.s9pk root@<LAN ID>:/root
```

Run the following command to determine successful install:

```
embassy-cli auth login
embassy-cli package install cwtch.s9pk
```
