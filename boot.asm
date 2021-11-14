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

times 510-($-$$) db 0
dw 0xAA55

; This bootloader will somtimes tamper with the data because of the BIOS Parameter Block. Some BIOS will expect this to be present
; So we create a BIOS Parameter block for jmp short 3C nop. This is required to jump over the disk format information. This is required even in Non-bootable volumes (required as JMP in both Windows and OSX).
; Without the above jump, BIOS will attempt to load the data that isn't a code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reading from CHS (Cylindrical Head Sector)                                                ;;
;; AH = 02h                                                                                  ;;
;; AL = number of sectors to read                                                            ;;
;; CH = low eight bits of cylinder number                                                    ;;
;; CL = sector number 1-63 (bits 0-5) high two bits of cylinder (bits 6-7, hard disk only)   ;;
;; DH = head number                                                                          ;;
;; DL = drive number (bit 7 set for hard disk) drive number choosen automatically.           ;;
;; ES:BX -> data buffer                                                                      ;;
;; Returns:                                                                                  ;;
;; CF (carry flag) set if there is an error or cleared on success                            ;;
;; If AH = 11h (corrected ECC error) AL = burst length                                       ;;
;; AH = status and AL = number of sectors transferred                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;