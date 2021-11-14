ORG 0                               ; ORG 0x7C00  -> if DS:SI has 0x7c0 and 0x7c00 then the address will become 0x7c0*16 + 0x7c00 != `message
BITS 16
_start:                             ; For the first BIOS parameter block (https://wiki.osdev.org/FAT)
    jmp short start
    nop

times 33 db 0                       ; For rest of the BIOS parameter blocks i.e. all the remaining set to 0

start:
    jmp 0x7c0:step                  ; Makes our code segment 0x7c0
                                    ; For more information on interrupts/exceptions, see https://wiki.osdev.org/Exceptions
handle_zero:                        ; For handling interrupt 0x00 (official name)
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret
    
handle_one:
    mov ah, 0eh
    mov al, 'V'
    mov bx, 0x00
    int 0x10
    iret

step:
    cli                             ; Clear interrupts 
    mov ax, 0x7c0
    mov ds, ax                      ; Data segment and Extra Segment cannot be directly populated. They can only be populated via ax
    mov es, ax
    mov ax, 00
    mov ss, ax
    mov sp, 0x7c00                  ; Stack grows downward
    sti                             ; Set (enable) interrupts
   
    mov word[ss:0x00], handle_zero  ; If ss is not specified, then it will take the data segment by default. But the interrupt 0x00 starts at 0x00 while ds points to 0x7c -> leads to a problem
    mov word[ss:0x02], 0x7c0
    
    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

    ; int 0                           ; For example, division by zero is an interrupt zero
    ; mov ax, 0x00
    ; div ax                          ; This divides ax by ax -> interrupt zero
    int 1

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

; This bootloader will somtimes tamper with the data because of the BIOS Parameter Block. Some BIOS will expect this to be present
; So we create a BIOS Parameter block for jmp short 3C nop. This is required to jump over the disk format information. This is required even in Non-bootable volumes (required as JMP in both Windows and OSX).
; Without the above jump, BIOS will attempt to load the data that isn't a code