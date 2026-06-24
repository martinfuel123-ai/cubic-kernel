FROM --platform=linux/amd64 debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    gcc \
    nasm \
    xorriso \
    grub-pc-bin \
    grub-common \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["make"]
