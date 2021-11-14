ORG 0x7C00
BITS 16

start:
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
