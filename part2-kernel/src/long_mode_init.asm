global long_mode_start
extern kernel_main
extern stack_top

section .text
bits 64

long_mode_start:
    mov rsp, stack_top

    cld

    call kernel_main

    hlt
