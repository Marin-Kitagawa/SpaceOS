section .asm

global insb
global outb
global insw
global outw

insb:
	push ebp
	mov ebp, esp
	xor eax, eax
	mov edx, [ebp+8]
	in al, dx				; Intel IN instruction for a byte
	pop ebp
	ret

insw:
	push ebp
	mov ebp, esp
	xor eax, eax
	mov edx, [ebp+8]
	in ax, dx				; Intel IN instruction for a WORD
	pop ebp
	ret

outb:
	push ebp
	mov ebp, esp
	mov edx, [ebp+8]
	mov eax, [ebp+12]
	out dx, al				; Intel OUT instruction for a byte
	pop ebp
	ret

outw:
	push ebp
	mov ebp, esp
	mov edx, [ebp+8]
	mov eax, [ebp+12]
	out dx, ax				; Intel OUT instruction for a WORD
	pop ebp
	ret