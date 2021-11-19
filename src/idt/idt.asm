section .asm

global idt_load

idt_load:
	push ebp
	mov ebp, esp
	mov ebx, [ebp + 8]				; If it is set to `ebp`, it will point to the base. If +4, then it will point to the return address and only on +8, it will point correctly
	lidt [ebx]
	pop ebp
	ret
	