#!/bin/bash
set -e

BASE_ISO="linuxmint-22.1-cinnamon-64bit.iso"
CUSTOM_ISO="cubic-custom-22.1-cinnamon-64bit.iso"
WORK="/tmp/iso-work"
SQUASHFS_ROOT="$WORK/squashfs-root"

echo "[1] Downloading Linux Mint ISO..."
wget -c "https://mirrors.layeronline.com/linuxmint/stable/22.1/$BASE_ISO" -O "$BASE_ISO" 2>&1 | tail -1

echo "[2] Extracting ISO..."
rm -rf "$WORK"
mkdir -p "$WORK/iso"
xorriso -osirrox on -indev "$BASE_ISO" -extract / "$WORK/iso" 2>&1 | tail -1

echo "[3] Extracting squashfs..."
unsquashfs -d "$SQUASHFS_ROOT" "$WORK/iso/casper/filesystem.squashfs" 2>&1 | tail -1

echo "[4] Modifying filesystem..."
mount --bind /proc "$SQUASHFS_ROOT/proc" 2>/dev/null || true
mount --bind /sys "$SQUASHFS_ROOT/sys" 2>/dev/null || true
mount --bind /dev "$SQUASHFS_ROOT/dev" 2>/dev/null || true
mount --bind /dev/pts "$SQUASHFS_ROOT/dev/pts" 2>/dev/null || true
mount --bind /run "$SQUASHFS_ROOT/run" 2>/dev/null || true

chroot "$SQUASHFS_ROOT" /bin/bash << 'CHROOT'
export DEBIAN_FRONTEND=noninteractive
echo "nameserver 8.8.8.8" > /etc/resolv.conf

apt-get update

apt-get install -y neovim htop git curl build-essential
cat > /etc/skel/.bash_aliases << 'EOF'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias update='sudo apt-get update && sudo apt-get upgrade -y'
alias nv='nvim'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
EOF

mkdir -p /etc/skel/.config/nvim
cat > /etc/skel/.config/nvim/init.vim << 'EOF'
set number
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
colorscheme desert
EOF

cat >> /etc/skel/.bashrc << 'EOF'
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
echo "Bienvenido a CUBIC OS - UIDE 2026"
echo "Integrative Project - Build, Boot, and Attack"
EOF

apt-get clean
rm -rf /var/lib/apt/lists/*
rm /etc/resolv.conf
CHROOT

umount -R "$SQUASHFS_ROOT/proc" 2>/dev/null || true
umount -R "$SQUASHFS_ROOT/sys" 2>/dev/null || true
umount -R "$SQUASHFS_ROOT/dev" 2>/dev/null || true
umount -R "$SQUASHFS_ROOT/run" 2>/dev/null || true

echo "[5] Repacking squashfs..."
rm -f "$WORK/iso/casper/filesystem.squashfs"
mksquashfs "$SQUASHFS_ROOT" "$WORK/iso/casper/filesystem.squashfs" -comp xz -b 1M 2>&1 | tail -1

echo "[6] Generating custom ISO..."
FS_SIZE=$(du -s --block-size=1 "$SQUASHFS_ROOT" | cut -f1)
echo $FS_SIZE > "$WORK/iso/casper/filesystem.size"

rm -f "$WORK/iso/casper/filesystem.squashfs.gpg" 2>/dev/null || true

xorriso -as mkisofs \
  -r -V 'CUBIC_OS_UIDE_2026' \
  -J -l \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -o "/workspace/$CUSTOM_ISO" \
  "$WORK/iso" 2>&1 | tail -5

echo "DONE: /workspace/$CUSTOM_ISO"
ls -lh "/workspace/$CUSTOM_ISO"
