#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

uint16_t *vga_buffer = (uint16_t *)VGA_ADDRESS;
uint16_t vga_index = 0;
uint8_t vga_color = 0x0F;

void clear_screen(void) {
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = (vga_color << 8) | ' ';
    }
    vga_index = 0;
}

void set_color(uint8_t color) {
    vga_color = color;
}

void print_str(const char *str) {
    while (*str) {
        if (*str == '\n') {
            vga_index = (vga_index / VGA_WIDTH + 1) * VGA_WIDTH;
            if (vga_index >= VGA_WIDTH * VGA_HEIGHT) {
                vga_index = (VGA_WIDTH * VGA_HEIGHT) - VGA_WIDTH;
            }
        } else {
            vga_buffer[vga_index++] = (vga_color << 8) | *str;
        }
        str++;
    }
}

void kernel_main(void) {
    clear_screen();
    set_color(0x0A);

    print_str("========================================\n");
    set_color(0x0F);
    print_str("        CUBIC KERNEL v1.0 - UIDE\n");
    set_color(0x0A);
    print_str("========================================\n\n");

    set_color(0x03);
    print_str("  Welcome to the 64-bit long mode!\n\n");
    set_color(0x07);
    print_str("  Integrative Project - March/July 2026\n");
    print_str("  Instructor: Ing. Jonathan E. Tito O., MSc.\n\n");

    set_color(0x0E);
    print_str("  Group Members:\n");
    set_color(0x07);
    print_str("    * Part 1 (Cubic Distro)  : Jose Martin\n");
    print_str("    * Part 2 (Kernel 64-bit) : Jose Martin\n");
    print_str("    * Part 3 (Black Hat Bash): Jose Martin\n\n");

    set_color(0x0A);
    print_str("  System Information:\n");
    set_color(0x07);
    print_str("    - Architecture : x86_64\n");
    print_str("    - Boot Protocol: Multiboot2\n");
    print_str("    - Paging       : 2MB Huge Pages (Identity Mapped)\n");
    print_str("    - Mode         : 64-bit Long Mode\n\n");

    set_color(0x05);
    print_str("  Press Ctrl+Alt+G to release cursor, then close QEMU.\n");

    while (1) {
        __asm__("hlt");
    }
}
