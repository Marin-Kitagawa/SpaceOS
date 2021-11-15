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

# A20 Line
The A20 line is a special line that is used to enable the memory above 1MB. That is, the 21st bit of memory accesses.
From the newer computers starting from IBM PS/2, the A20 line can be enabled via `Fast A20 Gate` i.e. it doesn't require any delay loops or polling.
It has just 3 instructions. Of these, `in` and `out` instructions -> reads from and writes to processor bus respectively

# Setting up a Cross Compiler
1. We cannot use `gcc` because it is for Linux. 
2. Since we are creating our own OS, we need to create a cross-compiler.
3. The cross-compiled `gcc` will not have standard libraries. This is expected because we are creating our own OS and hence kernel doesn't need support for the standard libraries.

# Loading the 32-bit Kernel into the Memory
## Writing the `linkerscript`
1. The kernel is basic at the start. So, we output the file in `binary` format.
2. Due to this, we need not load headers
3. The kernel cannot read files at this point.

## Writing a disk driver to load the kernel
1. For this we want to write a driver for the kernel to be loaded into memory.
2. For more info, see [OSDEV - ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode) and [OSDEV - ATA Read/Write Sectors](https://wiki.osdev.org/ATA_read/write_sectors)

## Verifying if the `os.bin` is loaded perfectly
```bash
gdb
add-symbol-file ./build/kernelfull.o 0x100000 # Address to load from
break _start
target remote | qemu-system-x86_64 -hda o s.bin -S -gdb stdio
# You will hit the breakpoint `_start` which you declared globally inside `kernel.asm` 
layout asm
# info registers
stepi  # Step into the `_start` function and execute the code (asm) one by one
```