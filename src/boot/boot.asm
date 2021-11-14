ORG 0x7c00                          ; ORG 0x7C00  -> if DS:SI has 0x7c0 and 0x7c00 then the address will become 0x7c0*16 + 0x7c00 != `message`. But now, we must consider GDT
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:                             ; For the first BIOS parameter block (https://wiki.osdev.org/FAT)
    jmp short start
    nop

times 33 db 0                       ; For rest of the BIOS parameter blocks i.e. all the remaining set to 0

start:
    jmp 0:step                      ; Makes our code segment 0x7c0
                                    ; For more information on interrupts/exceptions, see https://wiki.osdev.org/Exceptions

step:
    cli                             ; Clear interrupts 
    mov ax, 0
    mov ds, ax                      ; Data segment and Extra Segment cannot be directly populated. They can only be populated via ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00                  ; Stack grows downward
    sti                             ; Set (enable) interrupts
    
.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:load32


; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; OFFSET 0x08
gdt_code:                           ; CS must point to this; CS = code segment
    dw 0xffff                       ; Segment limit first 0-15 bits (see diagram in notes)
    dw 0                            ; Base 0-15 bits
    db 0                            ; Base 16-23 bits
    db 0x9a                         ; Access byte
    db 11001111b                    ; High 4-bits and low 4-bits of flags
    db 0                            ; Base 34-31 bits
    
; OFFSET 0x10
gdt_data:                           ; DS, ES, FS, GS, SS must point to this; DS = data segment, ES = extra segment
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 11001111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; Size of GDT
    dd gdt_start

[BITS 32]
load32:                             ; Enters into the 32-bit protected mode. This means that BIOS can no longer be access from here. Also, we cannot read from the disk too. So, we have to write our own disk driver. 
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
    jmp $                           ; Also, since this can only handle 512 bytes, there will be problems if this gets bigger than 512 bytes.

times 510-($-$$) db 0
dw 0xAA55

buffer: