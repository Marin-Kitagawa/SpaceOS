# BIOS Parameter Block
This `bootloader` will somtimes tamper with the data because of the BIOS Parameter Block. Some BIOS will expect this to be present
So we create a `BIOS` Parameter block for `jmp short 3C nop`. This is required to jump over the disk format information. This is required even in Non$-$bootable volumes (required as JMP in both Windows and OSX).
Without the above jump, BIOS will attempt to load the data that isn't a code

# Reading from CHS (Cylindrical Head Sector)
1. `AH` = $02\text{H}$
2. `AL = number of sectors to read
3. `CH` = low eight bits of cylinder number
4. `CL` = sector number $1-63$ (bits $0-5$) high two bits of cylinder (bits $6-7$, hard disk only)
5. `DH` = head number
6. `DL` = drive number (bit $7$ set for hard disk) drive number choosen automatically.
7. `ES:BX` -> data buffer
8. Returns:
9. `CF` (carry flag) set if there is an error or cleared on success
10. If `AH` = $11\text{H}$ (corrected `ECC` error) `AL` = burst length
11. `AH` = status and AL = number of sectors transferred

# Global Descriptor Table
1. It must be loaded to enter the Protective Mode
2. More information can be seen in [OSDEV - Global Descriptor Table](https://wiki.osdev.org/Global_Descriptor_Table)


# Debugging using the GNU Debugger (`gdb`)
```bash
gdb 
target remote | qemu-system-x86_64 -hda boot.bin -S -gdb stdio
c
layout asm
info registers
```