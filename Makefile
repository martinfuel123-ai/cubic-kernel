ASM=nasm
CC ?= gcc
LD ?= ld

ASMFLAGS=-f elf64
CFLAGS=-ffreestanding -Wall -Wextra -O2 -nostdlib -lgcc -mno-red-zone -mno-sse -mno-sse2 -mno-mmx -msoft-float
LDFLAGS=-T src/linker.ld -nostdlib

OBJS=header.o boot.o long_mode_init.o kernel.o

.PHONY: all iso run clean build docker-build docker-run docker-shell

all: kernel.iso

build: kernel.bin

%.o: src/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

iso: kernel.iso

kernel.iso: kernel.bin targets/x86_64/grub.cfg
	mkdir -p isodir/boot/grub
	cp kernel.bin isodir/boot/
	cp targets/x86_64/grub.cfg isodir/boot/grub/
	grub-mkrescue -o kernel.iso isodir

run: kernel.iso
	qemu-system-x86_64 -cdrom kernel.iso

docker-build:
	docker build -t cubic-kernel .

docker-run:
	docker run --rm -v "$(PWD):/workspace" cubic-kernel

docker-shell:
	docker run --rm -it -v "$(PWD):/workspace" cubic-kernel /bin/bash

clean:
	rm -rf *.o *.bin *.iso isodir/
