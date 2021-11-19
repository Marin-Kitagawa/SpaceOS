#ifndef IDT_H
#define IDT_H

#include<stdint.h>
struct idt_desc {
	uint16_t offset_1;			// Offset bits 0-15
	uint16_t selector;			// Code segment selector i.e. GDT or LDT selector
	uint8_t zero;				// Unused; always 0
	uint8_t type_attr;			// Type and attributes
	uint16_t offset_2;			// Offset bits 16-31
}__attribute__((packed));


struct idtr_desc {
	uint16_t limit;				// Size of IDT - 1
	uint32_t base;				// Base Address of the start of IDT
}__attribute__((packed));

void idt_init();

#endif