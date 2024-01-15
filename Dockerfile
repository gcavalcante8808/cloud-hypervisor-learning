FROM rust:1-bookworm as builder
ARG CH_VERSION=v37.0
ARG PLATFORM=x86_64
WORKDIR /usr/src/
RUN apt-get update && apt-get install git build-essential m4 bison flex uuid-dev qemu-utils musl-tools -y
RUN git clone --branch ${CH_VERSION} https://github.com/cloud-hypervisor/cloud-hypervisor.git
RUN rustup target add ${PLATFORM}-unknown-linux-musl
RUN cd cloud-hypervisor && \
    cargo build --release --target=${PLATFORM}-unknown-linux-musl --all
RUN cd cloud-hypervisor/target/x86_64-unknown-linux-musl/release/ &&  \
    mv cloud-hypervisor ch-remote /usr/local/bin/

FROM scratch as final
COPY --from=builder /usr/local/bin/cloud-hypervisor /usr/local/bin/cloud-hypervisor
COPY --from=builder /usr/local/bin/ch-remote /usr/local/bin/ch-remote
