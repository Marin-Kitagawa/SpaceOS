ORG 0                               ; ORG 0x7C00  -> if DS:SI has 0x7c0 and 0x7c00 then the address will become 0x7c0*16 + 0x7c00 != `message
BITS 16
_start:                             ; For the first BIOS parameter block (https://wiki.osdev.org/FAT)
    jmp short start
    nop

times 33 db 0                       ; For rest of the BIOS parameter blocks i.e. all the remaining set to 0

start:
    jmp 0x7c0:step                  ; Makes our code segment 0x7c0
                                    ; For more information on interrupts/exceptions, see https://wiki.osdev.org/Exceptions

step:
    cli                             ; Clear interrupts 
    mov ax, 0x7c0
    mov ds, ax                      ; Data segment and Extra Segment cannot be directly populated. They can only be populated via ax
    mov es, ax
    mov ax, 00
    mov ss, ax
    mov sp, 0x7c00                  ; Stack grows downward
    sti                             ; Set (enable) interrupts
    
    ;; See section on Reading from CHS below
    mov ah, 2                       ; Read Sector Command
    mov al, 1                       ; One sector to read
    mov ch, 0                       ; Cylinder lower 8 bits
    mov cl, 2                       ; Read sector 2
    mov dh, 0                       ; Head number and DL is already set (automatically)
    mov bx, buffer                  ; Place to store the data read
    int 0x13                        ; Read disk interrupt
    jc error
    mov si, buffer                  ; Reading the data from the buffer
    call print
    jmp $
    
error:
    mov si, error_message
    call print
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

error_message: db 'Failed to read the sector', 0

times 510-($-$$) db 0
dw 0xAA55

buffer: