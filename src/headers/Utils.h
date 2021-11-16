#include<stddef.h>
#include<terminal_functions.h>

size_t strlen(char* name) {
	int length = 0;
	while(name[length++]);
	return length;
}

void print(char* str) {
	terminal_initalize();
	size_t length = strlen(str);
	for(size_t i = 0; i < length; i++) {
		terminal_write(str[i], 0x0F);
	}
}