#ifndef IO_H
#define IO_H
unsigned char insb(unsigned short port);		// Read byte from port
unsigned short insw(unsigned short port);		// Read word from port
void outb(unsigned short port, unsigned char data);	// Write byte to port
void outw(unsigned short port, unsigned short data);	// Write word to port
#endif