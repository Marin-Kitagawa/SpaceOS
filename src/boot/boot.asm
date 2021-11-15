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
    jmp $


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
load32:                             ; Loading the Kernel into memory
    mov eax, 1                      ; The starting sector to load. It starts from 1 and not 0 because 0 is the boot sector
    mov ecx, 100                    ; Number of sectors to load
    mov edi, 0x0100000              ; 1iMB offset. This is the address where the kernel will be loaded
    call ata_lba_read               ; Load the kernel into memory. LBA = Logical Block Address.
    jmp CODE_SEG:0x0100000

ata_lba_read:                     ; LBA -> 32-bits
    mov ebx, eax                  ; Backup the LBA
    shr eax, 24                   ; Send the highest 8 bits of the LBA to the hard disk controller. i.e. Shifting to the right by 24 bits = having the highest 8 bits of the LBA
    or eax, 0xe0                  ; Select the master drive
    mov dx, 0x1f6                 ; Port for ATA controller
    out dx, al                    ; Sending complete; `out` -> processor bus
    
    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1f2
    out dx, al
    ; Finished sending the total sectors to read
    
    ; Send more bits of the LBA
    mov eax, ebx                   ; Restore the backed-up LBA
    mov dx, 0x1f3
    out dx, al
    ; Finished sneding more bits of the LBA
    
    ; Send more bits of the LBA
    mov dx, 0x1f4                  ; Send the command to the controller
    mov eax, ebx                   ; Restore the backed-up LBA. (Not necessary but in case of any edits above that might corrupt the backup LBA)
    shr eax, 8
    out dx, al
    ; Finished sending more bits of the LBA
    
    ; Send upper 16 bits of the LBA
    mov dx, 0x1f5
    mov eax, ebx
    shr eax, 16
    out dx, al
    ; Finished sending upper 16 bits of the LBA
    
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al
    
    ; Read all sectors into memory
.next_sector:
    push ecx
    
    ; Check if the drive is ready
.retry:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .retry
    
    ; Read 256 words at a time
    mov ecx, 0x100                  ; Number of words to read (256 words = 512 bytes = 1 sector)
    mov dx, 0x1f0
    rep insw                        ; Read input word from the IO port specified by the `dx` and store it in the address mentioned by ES:(E)DI register
    pop ecx                         ; We pushed `ecx` which is the number of sectors to read. And here, we restore it
    loop .next_sector               ; Loop back to the start of the loop. It autodecrements the value of `ecx` and if it is 0, it will exit the loop.
    ; End of reading sectors into memory
    ret

times 510-($-$$) db 0
dw 0xAA55