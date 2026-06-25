# Part 1: Custom Linux Mint ISO

**Student:** Jose Martin  
**Course:** UIDE 2026 — Integrative Project

## What I did

I took Linux Mint 22.1 "Xia" Cinnamon 64-bit and modified it with 3 changes. Since I'm on a Mac with Apple Silicon, I couldn't use Cubic (needs GUI + Ubuntu), so I built the ISO using Docker with xorriso and squashfs-tools.

The distro is called **CUBIC OS**.

## The 3 modifications

1. **Dev tools** — neovim, htop, git, curl, build-essential. These are tools I actually use for class work, so it makes sense to have them pre-installed.

2. **Shell aliases** — Added /etc/skel/.bash_aliases with shortcuts like `ll`, `nv` (for neovim), `gs`/`ga`/`gc` (git status/add/commit), and `update` (apt update + upgrade). New users get these automatically.

3. **Welcome banner** — Added a line in /etc/skel/.bashrc that prints "Bienvenido a CUBIC OS - UIDE 2026" when you open the terminal.

I also set up a basic neovim config in /etc/skel/.config/nvim/ (line numbers, 4-space tabs, desert colorscheme).

## Verification

Instead of booting the full ISO (which is slow on ARM Macs because it has to emulate x86_64), I extracted the squashfs and ran the commands directly in a chroot. This confirmed everything is installed correctly.

```
neovim 0.9.5   git 2.43.0   htop 3.3.0   curl 8.5.0
```

## Checksum

```
SHA256: 9196effbaacf37c0442d4c76704890ba7b6a88ded860fa90bbfc28263edc4e72
```

## Boot

The ISO boots with ISOLINUX for BIOS and GRUB for UEFI. During testing it booted correctly in UTM (showed GRUB menu then loaded the Cinnamon desktop).

## Files

- Dockerfile — sets up Ubuntu 24.04 with the tools needed to build ISOs
- build-custom-iso.sh — the script that does everything: download ISO, extract, chroot, modify, repack
- cubic-custom-22.1-cinnamon-64bit.iso — the final ISO (~2.6 GB, not on GitHub, build locally)
- screenshots/ — GRUB boot, desktop, modifications proof
