# Integrative Project: Build, Boot, and Attack

**Universidad Internacional del Ecuador (UIDE)**  
**Instructor:** Ing. Jonathan E. Tito O., MSc.  
**Term:** March – July 2026  
**Student:** Jose Martin (Part 2) and Rafael Patin (Parts 1 & 3)

---

## What's in here

This repo has the 3 parts of the Integrative Project:

- **Part 1** — Custom Linux Mint ISO with pre-installed tools and configs
- **Part 2** — 64-bit x86 kernel that boots with GRUB and prints a banner
- **Part 3** — Black Hat Bash offensive security lab with Nuclei scan

Each part is in its own folder with its own README and screenshots.

---

# Custom Linux Distribution Report — Part 1

## General Information
* Developer: PATIN COTACACHI RAFAEL ALEXANDRE
* Base OS: Ubuntu 24.04.4 LTS (Noble Numbat)
* Generation Date: 2026-06-25

---

## ISO Download and Verification
* Download Link: https://drive.google.com/file/d/11HdAZHv6kOFGyHo4dCXdqz5MJmD_Q3Ri/view?usp=sharing
* MD5 Checksum: dfa07646a501c0446620ca4fc4ceceaf

### Technical Specifications
* File Name: ubuntu-24.04.4-2026.06.25-desktop-amd64.iso
* Volume ID: Ubuntu 24.04.4 2026.06.25 LTS
* Compression Algorithm: XZ (Optimized for size)
* Final Size: 5.50 GiB (5,901,291,520 bytes)

---

## List of Modifications and Justifications

1. Software Replacement: Celluloid to MPV
* Modification: Replaced the default stock media player with mpv.
* Justification: The default media player was removed and MPV was installed. MPV is a lightweight, efficient, and highly customizable open-source alternative that minimizes CPU and RAM resource consumption, with superior codec support ideal for systems administration environments.

2. Pre-installation of Development Tools (Neovim)
* Modification: Integrated and pre-installed the advanced text editing environment Neovim.
* Justification: Neovim was incorporated directly into the base ISO along with its basic dependencies. This ensures that the system provides an agile, resource-efficient development editor ready for scripting and Unix administration tasks from the first boot without relying on external repositories.

3. Persistent Customization of the Default User Environment via /etc/skel
* Modification: Configured a persistent custom welcome banner within the command interpreter.
* Justification: The master file '/etc/skel/.bashrc' was edited to add optimized global aliases ('ll') and a personalized welcome message in English. This guarantees that any new user account created automatically inherits these configurations persistently, establishing a distinct operating system identity for administrative auditing and direct developer recognition.

---

## Deliverables and Verification
* Demonstration Video: Included as UNIX.mp4 in the project directory https://drive.google.com/file/d/1wx6NPJzGhx_9C5vbWJREChPdSg4Tjf0O/view?usp=drive_link
* Boot Test Status: Successfully verified and tested on Oracle VirtualBox, running perfectly in a clean Live session using the "Try Ubuntu" mode.

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
