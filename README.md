# Integrative Project: Build, Boot, and Attack

**Institution:** Universidad Internacional del Ecuador (UIDE)  
**Instructor:** Ing. Jonathan E. Tito O., MSc.  
**Term:** March – July 2026  
**Group:** Jose Martin (Part 2 – Kernel 64-bit)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Part 1 — Custom Distro with Cubic](#part-1--custom-distro-with-cubic)
4. [Part 2 — 64-bit Kernel](#part-2--64-bit-kernel)
5. [Part 3 — Black Hat Bash Lab](#part-3--black-hat-bash-lab)
6. [Build Instructions (Quick Start)](#build-instructions)
7. [Project Log](#project-log)

---

## Project Overview

This project covers the full stack of a modern Linux-based system:

| Part | Description | Value |
|------|-------------|-------|
| **Part 1** | Custom bootable Linux distro built with Cubic | 25 pts |
| **Part 2** | 64-bit x86 kernel with Multiboot2, paging, long mode, and C code | 30 pts |
| **Part 3.A** | Deploy the Black Hat Bash offensive security lab | 20 pts |
| **Part 3.B** | Execute a reconnaissance/attack technique inside the lab | 15 pts |
| Documentation & repo management | | 10 pts |
| **Total** | | **100 pts** |

---

## Repository Structure

```
.
├── README.md                   # This file
├── .gitignore
├── part1-distro/               # Part 1 — Cubic custom ISO
│   └── (ISO + README + screenshots)
├── part2-kernel/               # Part 2 — 64-bit kernel
│   ├── src/
│   │   ├── header.asm          # Multiboot2 header structure
│   │   ├── boot.asm            # 32-bit entry point, checks, paging setup
│   │   ├── long_mode_init.asm  # 64-bit entry, calls kernel_main
│   │   ├── kernel.c            # VGA print functions, custom banner
│   │   └── linker.ld           # Linker script (base address 1 MB)
│   ├── targets/
│   │   └── x86_64/
│   │       └── grub.cfg        # GRUB menu entry
│   ├── Dockerfile              # Build environment (amd64)
│   ├── Makefile                # Build automation
│   ├── kernel.bin              # ELF binary (generated)
│   └── kernel.iso              # Bootable ISO (generated)
└── part3-lab/                  # Part 3 — Black Hat Bash
    └── (architecture table + screenshots)
```

---

## Part 1 — Custom Distro with Cubic

*(Handled by Jose Martin)*

A custom bootable ISO was created from a Linux Mint / Ubuntu base using Cubic. Modifications include:

1. *(to be documented)*
2. *(to be documented)*
3. *(to be documented)*

See `part1-distro/README.md` for full details, modification justifications, and boot screenshots.

---

## Part 2 — 64-bit Kernel

### Overview

A minimal 64-bit x86 kernel that:

- Boots via **GRUB** using the **Multiboot2** protocol
- Validates the bootloader magic, CPUID support, and long-mode availability
- Sets up **4-level paging** with **2 MB huge pages** (identity-mapped, covering 1 GB)
- Configures a **64-bit GDT** with one code segment descriptor
- Transitions from 32-bit protected mode → compatibility mode → **long mode**
- Prints a formatted banner from **C code** using direct VGA framebuffer writes

The kernel does **not** rely on BIOS or UEFI services after GRUB hands control — all hardware interaction is done through direct memory-mapped I/O (VGA text buffer at `0xB8000`).

### Boot Flow (detailed)

```
GRUB (Multiboot2)
  │
  ▼
header.asm          Multiboot2 header at the start of the binary.
  │                  GRUB parses magic 0xE85250D6, loads ELF segments,
  │                  sets up initial page tables, and jumps to the entry point.
  ▼
boot.asm (start)    32-bit protected mode entry point.
  │
  ├── 1. Set stack pointer (ESP ← stack_top)
  ├── 2. Verify Multiboot magic (EAX == 0x36d76289)
  ├── 3. Check CPUID support (flipping ID flag in EFLAGS)
  ├── 4. Check long-mode availability (CPUID leaf 0x80000001, bit 29)
  ├── 5. Build page tables:
  │     ├── P4 table: entry 0 → P3 table address
  │     ├── P3 table: entry 0 → P2 table address
  │     └── P2 table: 512 entries, each mapping 2 MB (total 1 GB, identity)
  ├── 6. Enable PAE   (CR4.PAE ← 1)
  ├── 7. Load P4 base (CR3 ← p4_table address)
  ├── 8. Enable long mode (EFER.LME ← 1)
  ├── 9. Enable paging (CR0.PG ← 1)  →  CPU now in compatibility mode
  ├── 10. Load GDT (lgdt [gdt64.pointer])
  └── 11. Far jump to 64-bit code segment (jmp 0x08:long_mode_start)
  │
  ▼
long_mode_init.asm   64-bit long mode entry point.
  │
  ├── 1. Set RSP ← stack_top
  ├── 2. Clear direction flag (cld)
  └── 3. Call kernel_main (C function)
  │
  ▼
kernel.c             C code running in 64-bit long mode.
  │
  ├── clear_screen()     Fill VGA buffer with blank spaces
  ├── set_color(0x0A)    Green foreground on black
  ├── print_str(...)     Print the project banner, group info, system details
  └── while (1) hlt      Infinite halt loop
```

### Memory Layout

```
0x000000  ┌─────────────────────┐
          │  Reserved (hardware) │
0x100000  ├─────────────────────┤  ← Kernel load base (1 MB)
          │  Multiboot2 header   │
0x100018  │  .boot (32-bit code) │
0x101000  │  .text (64-bit code) │
0x102000  │  .rodata (strings)   │
0x103000  │  .data               │
0x104000  ├─────────────────────┤
          │  P4 table  (4 KB)    │
0x105000  │  P3 table  (4 KB)    │
0x106000  │  P2 table  (4 KB)    │
0x107000  │  Stack     (16 KB)   │
0x10B000  ├─────────────────────┤  ← stack_top (ESP/RSP)
          │  End of kernel BSS   │
0x200000  ├─────────────────────┤  ← End of identity-mapped region
          │  (unused)            │
0xB8000   │  VGA text buffer     │
```

### Page Table Structure

```
P4 table (1 entry)  →  P3 table (1 entry)  →  P2 table (512 entries)
                                                   │
                                                   ├── entry 0:  0x000000  (2 MB)
                                                   ├── entry 1:  0x200000  (2 MB)
                                                   ├── entry 2:  0x400000  (2 MB)
                                                   └── ... up to entry 511 (1 GB)
```

Each P2 entry is a 2 MB page with Present, Writable, and Page Size (PS=1) flags set — identity mapping, meaning virtual address = physical address.

### Kernel Deliverables

| File | Description |
|------|-------------|
| `src/header.asm` | Multiboot2 header structure |
| `src/boot.asm` | 32-bit entry → long mode transition |
| `src/long_mode_init.asm` | 64-bit entry → calls C |
| `src/kernel.c` | VGA print with group banner |
| `src/linker.ld` | ELF layout (base 0x100000) |
| `targets/x86_64/grub.cfg` | GRUB menu entry (`multiboot2`) |
| `Dockerfile` | Reproducible build (amd64 Debian) |
| `Makefile` | Build/run/clean targets |
| `kernel.iso` | Bootable ISO (≈5 MB) |

### Build Environment

The kernel is built inside a Docker container to guarantee reproducibility across different host systems.

```
Docker image: cubic-kernel (linux/amd64)
├── Base: Debian Bookworm
├── nasm        (assembler)
├── gcc        (compiler, x86_64-linux-gnu)
├── ld         (linker)
├── xorriso    (ISO creation)
└── grub-pc-bin + grub-common (GRUB bootloader)
```

---

## Part 3 — Black Hat Bash Lab

*(Handled by Jose Martin)*

The offensive security lab from [Black Hat Bash](https://github.com/dolevf/Black-Hat-Bash) is deployed using Docker Compose. It consists of 8 containers across two isolated networks:

- **Public network:** `172.16.10.0/24` — web servers, FTP
- **Corporate network:** `10.1.0.0/24` — internal services

See `part3-lab/README.md` for the full architecture table, network diagram, and attack walkthrough.

---

## Build Instructions

### Prerequisites

- **Docker Desktop** (for kernel build)
- **QEMU** (`brew install qemu` on macOS, `apt install qemu-system-x86` on Linux)

### Part 2 — Build and Run the Kernel

```bash
cd part2-kernel

# 1. Build the Docker image (one-time)
docker build -t cubic-kernel .

# 2. Build kernel.bin + kernel.iso
docker run --rm -v "$(PWD):/workspace" -w /workspace cubic-kernel make build iso

# 3. Boot in QEMU
qemu-system-x86_64 -cdrom kernel.iso
```

At the GRUB menu, select **"Cubic Kernel 64-bit – UIDE 2026"**. The banner will display the project details and group members.

### All Makefile Targets

| Target | Command | Description |
|--------|---------|-------------|
| `build` | `make build` | Assemble `.asm` files, compile `kernel.c`, link → `kernel.bin` |
| `iso` | `make iso` | Generate `kernel.iso` with GRUB using `grub-mkrescue` |
| `run` | `make run` | Launch QEMU with `kernel.iso` |
| `clean` | `make clean` | Remove all build artifacts |
| `docker-build` | `make docker-build` | Build the Docker image (`docker build -t cubic-kernel .`) |
| `docker-run` | `make docker-run` | Build kernel inside Docker and exit |
| `docker-shell` | `make docker-shell` | Open interactive shell in the build container |

---

## Project Log

| Date | Author | Description |
|------|--------|-------------|
| 2026-06-22 | Jose Martin | Initial repo setup, Dockerfile, Makefile, kernel skeleton |
| 2026-06-22 | Jose Martin | Multiboot2 header, 32-bit boot code with CPUID/long-mode checks |
| 2026-06-22 | Jose Martin | Page table setup, PAE, EFER, paging enable, GDT, far jump |
| 2026-06-22 | Jose Martin | 64-bit entry point, C integration with VGA print functions |
| 2026-06-22 | Jose Martin | Debugged `.boot` section exec flag (GRUB rejected non-executable segment) |
| 2026-06-23 | Jose Martin | Fixed SSE instruction generation (added `-mno-sse` flags to GCC) |
| 2026-06-23 | Jose Martin | Removed null-segment loads in long mode (caused triple fault on some CPUs) |
| 2026-06-23 | Jose Martin | Final build, cleanup, README, push to GitHub |

---

*UIDE — Integrative Project — March/July 2026*
