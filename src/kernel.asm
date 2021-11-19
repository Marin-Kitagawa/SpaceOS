[BITS 32]
global _start

extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:                             ; Enters into the 32-bit protected mode. This means that BIOS can no longer be access from here. Also, we cannot read from the disk too. So, we have to write our own disk driver. 
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x00200000
    mov esp, ebp
    ; Enable the A20 line via Fast A20 Gate
    in al, 0x92
    or al, 0x02
    out 0x92, al
    call kernel_main               ; Calling the function `kernel_main()` from `kernel.c`
    jmp $                           ; Also, since this can only handle 512 bytes, there will be problems if this gets bigger than 512 bytes.


times 512-($ - $$) db 0