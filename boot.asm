ORG 0                               ; ORG 0x7C00  -> if DS:SI has 0x7c0 and 0x7c00 then the address will become 0x7c0*16 + 0x7c00 != `message
BITS 16

start:
    cli                             ; Clear interrupts 
    mov ax, 0x7c0
    mov ds, ax                      ; Data segment and Extra Segment cannot be directly populated. They can only be populated via ax
    mov es, ax
    mov ax, 00
    mov ss, ax
    mov sp, 0x7c00                  ; Stack grows downward
    sti                             ; Set (enable) interrupts
    mov si, message
    call print
    jmp $
print:
    mov bx, 0                       ; For the page number
.loop:
    lodsb                           ; Loads a character from the `si` register to the `al` register
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh                     ; Interrupt to print a character to the terminal -> searches the `al` register for the character to be printed
    int 0x10

    ret

message: db 'Hello, World!', 0
times 510-($-$$) db 0
dw 0xAA55
