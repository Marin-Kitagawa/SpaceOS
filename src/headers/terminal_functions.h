#include<stdint.h>

uint16_t terminal_make_char(char c, int color) {
	return (color << 8) | c;
}

void terminal_putchar(int x, int y, char ch, int c) {
	video_memory[ y * VGA_WIDTH + x] = terminal_make_char(ch, c);
}

void terminal_initalize() {
	// Clear the screen
	video_memory = (uint16_t*) 0xB8000;
	for(int y = 0; y < VGA_HEIGHT; y++) {
		for(int x = 0; x < VGA_WIDTH; x++) {
			video_memory[y * VGA_WIDTH + x] = terminal_make_char(' ', 0);
		}
	}
}

void terminal_write(char c, int color) {
	if(c == '\n') {
		terminal_row += 1;
		terminal_col = 0;
	} else {
		terminal_putchar(terminal_col, terminal_row, c, color);
		terminal_col += 1;
		if(terminal_col >= VGA_WIDTH) {
			terminal_col = 0;
			terminal_row += 1;
		}
	}
}