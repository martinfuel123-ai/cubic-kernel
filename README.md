# Cubic Kernel — Part 2: 64-bit Kernel

**Integrative Project — UIDE**  
**Author:** Jose Martin  
**Instructor:** Ing. Jonathan E. Tito O., MSc.  
**Term:** March–July 2026

---

## Overview

A minimal 64-bit x86 kernel that boots via GRUB with Multiboot2, transitions to long mode with paging (2MB huge pages), and prints a custom banner from C code.

Runs on any x86_64 machine/emulator. Built reproducibly inside Docker.

---

## Quick Start

### Prerequisites

- Docker Desktop
- QEMU (`brew install qemu` on macOS)

### Build and Run

```bash
# Build the Docker image (one-time)
docker build -t cubic-kernel .

# Build the kernel + ISO
docker run --rm -v "$(PWD):/workspace" -w /workspace cubic-kernel make build iso

# Boot in QEMU
qemu-system-x86_64 -cdrom kernel.iso
```

Select **"Cubic Kernel 64-bit – UIDE 2026"** in the GRUB menu.

---

## Project Structure

```
.
├── src/
│   ├── header.asm           # Multiboot2 header
│   ├── boot.asm             # 32-bit entry, checks, paging, GDT, far jump
│   ├── long_mode_init.asm   # 64-bit entry, calls kernel_main
│   ├── kernel.c             # C print functions with custom banner
│   └── linker.ld            # Linker script (base 1 MB)
├── targets/
│   └── x86_64/
│       └── grub.cfg         # GRUB menu entry
├── Dockerfile               # Debian bookworm, amd64, nasm + gcc + grub + xorriso
├── Makefile                 # build / iso / run / clean / docker-*
├── kernel.iso               # Bootable ISO (generated)
└── README.md
```

---

## Makefile Targets

| Target       | Description                        |
|-------------|------------------------------------|
| `make build` | Assemble and link `kernel.bin`     |
| `make iso`   | Generate `kernel.iso` with GRUB    |
| `make run`   | Boot in QEMU                       |
| `make clean` | Remove build artifacts             |

---

## Technical Details

- **Boot protocol:** Multiboot2 (GRUB 2.06+)
- **Architecture:** x86_64 (long mode)
- **Paging:** 4-level page tables, 2MB huge pages, identity-mapped
- **Stack:** 16 KB in BSS
- **Video:** VGA text mode (0xB8000), 80×25
- **Compiler flags:** `-ffreestanding -O2 -mno-sse -mno-sse2 -mno-mmx -msoft-float`

---

## Video Demo

Record a ≤2 minute video showing:

1. `qemu-system-x86_64 -cdrom kernel.iso`
2. GRUB menu appears
3. Select "Cubic Kernel 64-bit – UIDE 2026"
4. Kernel boots and shows the banner with "Jose Martin"
