#include<memory/memory.h>

void* memset(void* ptr, int c, size_t size) {
	char* p = (char*)ptr;
	for(size_t i = 0; i < size; i++) {
		p[i] = (char) c;
	}
	return ptr;
}