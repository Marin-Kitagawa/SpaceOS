#include<idt/idt.h>
#include<config.h>
#include<memory/memory.h>
#include<kernel.h>

struct idt_desc idt_descriptors[SPACEOS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;
extern void idt_load(struct idtr_desc* ptr);
void idt_zero() {
	print("Divide by zero error\n");
}

void idt_set(int interrupt_number, void* address) {
	struct idt_desc* desc = &idt_descriptors[interrupt_number];
	desc -> offset_1 = (uint32_t) address & 0xFFFF;
	desc -> selector = KERNEL_CODE_SEGMENT_OFFSET;
	desc -> zero = 0;
	desc -> type_attr = 0xEE;
	desc -> offset_2 = (uint32_t) address >> 16;
}

void idt_init() {
	memset(idt_descriptors, 0, sizeof(idt_descriptors));
	idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
	idtr_descriptor.base = (uint32_t) idt_descriptors;

	// Load the IDT
	idt_load(&idtr_descriptor);
}