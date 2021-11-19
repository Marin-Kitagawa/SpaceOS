#include<kernel.h>
#include<stdint.h>
#include<stddef.h>
#include<idt/idt.h>


uint16_t* video_memory = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;


uint16_t terminal_make_char(char c, int color) {
	return (color << 8) | c;
}

void terminal_putchar(int x, int y, char ch, int c) {
	video_memory[ y * VGA_WIDTH + x] = terminal_make_char(ch, c);
}

void terminal_initalize() {
	video_memory = (uint16_t*) 0xB8000;
	for(int y = 0; y < VGA_HEIGHT; y++) {
		for(int x = 0; x < VGA_WIDTH; x++) {
			terminal_putchar(x, y, ' ', 0);
		}
	}
}

void terminal_write(char c, int color) {
	if(c == '\n') {
		terminal_row += 1;
		terminal_col = 0;
		return;
	} 
	terminal_putchar(terminal_col, terminal_row, c, color);
	terminal_col += 1;
	if(terminal_col >= VGA_WIDTH) {
		terminal_col = 0;
		terminal_row += 1;
	}
}

size_t strlen(char* name) {
	int length = 0;
	while(name[length++]);
	return length;
}

void print(char* str) {
	size_t length = strlen(str);
	for(int i = 0; i < length; i++) {
		terminal_write(str[i], 0x0F);
	}
}

void kernel_main() {
	terminal_initalize();
	print("MEGHA AKASH");

	// Initialize the IDT
	idt_init();

}