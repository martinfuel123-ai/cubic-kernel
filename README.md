# Integrative Project: Build, Boot, and Attack

**Universidad Internacional del Ecuador (UIDE)**  
**Instructor:** Ing. Jonathan E. Tito O., MSc.  
**Term:** March – July 2026  
**Student:** Jose Martin (Parts 1, 2 & 3)

---

## What's in here

This repo has the 3 parts of the Integrative Project:

- **Part 1** — Custom Linux Mint ISO with pre-installed tools and configs
- **Part 2** — 64-bit x86 kernel that boots with GRUB and prints a banner
- **Part 3** — Black Hat Bash offensive security lab with Nuclei scan

Each part is in its own folder with its own README, code, screenshots, etc.

---

## Part 1 — Custom Distro

I built a custom Linux Mint 22.1 ISO without using Cubic (no GUI available on my Mac). Instead I used a Docker container with xorriso and squashfs-tools to:

1. Install neovim, htop, git, curl, build-essential
2. Add useful aliases to /etc/skel/.bash_aliases (ll, nv, gs, etc.)
3. Add a welcome banner that prints "Bienvenido a CUBIC OS - UIDE 2026"

More details in `part1-distro/README.md`.

---

## Part 2 — 64-bit Kernel

A minimal kernel that boots via GRUB (Multiboot2 protocol), sets up paging and long mode, and prints a formatted banner from C code using the VGA text buffer at 0xB8000.

The boot sequence goes:

1. GRUB loads kernel.bin via Multiboot2
2. 32-bit entry: verifies magic, CPUID, long mode support
3. Sets up 4-level paging with 2MB huge pages (identity mapping 1GB)
4. Enables PAE, loads page table, enables long mode
5. Loads a 64-bit GDT, far jumps into long mode
6. 64-bit entry: calls kernel_main() in C
7. C code clears screen and prints the project banner

All source files are in `part2-kernel/src/`. The build uses a Docker container (Debian + nasm + gcc + xorriso + grub).

More details in `part2-kernel/README.md`.

---

## Part 3 — Black Hat Bash Lab

Deployed the lab from dolevf/Black-Hat-Bash with 8 containers split across two networks:

- Public: 172.16.10.0/24 (web servers, FTP, jumpbox)
- Corporate: 10.1.0.0/24 (databases, Redis, backup)

Ran Nuclei against the public targets and found a critical WordPress install page on p-web-02, plus weak FTP credentials and anonymous login on p-ftp-01.

More details in `part3-lab/README.md`.

---

## How to build

You'll need Docker Desktop and QEMU.

**Part 2 kernel:**
```bash
cd part2-kernel
docker build -t cubic-kernel .
docker run --rm -v "$(PWD):/workspace" -w /workspace cubic-kernel make build iso
qemu-system-x86_64 -cdrom kernel.iso
```

At the GRUB menu pick "Cubic Kernel 64-bit - UIDE 2026" and the banner shows up.

**Part 1 ISO rebuild** (takes long, downloads ~3GB):
```bash
cd part1-distro
docker build --platform linux/amd64 -t cubic-iso-builder .
docker run --rm -v "$(PWD):/workspace" cubic-iso-builder
```

**Part 3 lab:**
```bash
cd Black-Hat-Bash/lab
docker compose build --parallel
docker compose up --detach
```

---

## Project log (rough)

- Jun 22: Started kernel, got Multiboot2 working, long mode transition
- Jun 23: Fixed issues (exec flag, SSE instructions), clean build
- Jun 24: Deployed BHB lab, ran Nuclei scan, built custom Linux Mint ISO
- Jun 24: Wrote docs, took screenshots, recorded demo
