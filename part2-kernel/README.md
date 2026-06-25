# Part 2: 64-bit Kernel

**Student:** Jose Martin  
**Course:** UIDE 2026 — Integrative Project

## What it does

A minimal x86_64 kernel that boots via GRUB with Multiboot2. It checks CPU features, sets up paging with 2MB pages, switches to 64-bit long mode, and prints a banner to the screen from C code.

## Files

- src/header.asm — Multiboot2 header
- src/boot.asm — 32-bit entry, CPU checks, paging, long mode switch
- src/long_mode_init.asm — 64-bit entry, calls kernel_main
- src/kernel.c — VGA text output, banner
- src/linker.ld — memory layout
- targets/x86_64/grub.cfg — GRUB menu entry
- Dockerfile — Debian with nasm, gcc, xorriso, grub
- Makefile — build/iso/run/clean targets

## Build and run

```bash
docker build -t cubic-kernel .
docker run --rm -v "$(PWD):/workspace" -w /workspace cubic-kernel make build iso
qemu-system-x86_64 -cdrom kernel.iso
```

Pick "Cubic Kernel 64-bit - UIDE 2026" in the GRUB menu.
