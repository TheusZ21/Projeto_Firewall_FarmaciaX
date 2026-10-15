FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends iptables iproute2 iputils-ping && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
