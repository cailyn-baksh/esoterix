#include <stdint.h>

#include "common.h"
#include "board.h"
#include "uart.h"

uint32_t kernel_main(uint32_t r0, uint32_t r1, uint32_t atags, uint32_t r3) {
	switch ((r3 >> 4) & 0xFFF) {
		case 0xB76:
			board = &boards[0];
			break;
		case 0xC07:
			board = &boards[1];
			break;
		case 0xD03:
			board = &boards[2];
			break;
		case 0xD08:
			board = &boards[3];
			break;
	}

	init_uart1();

	uart1_puts("Booting " OSNAME " v" OSVER "\r\n");

	return 0;
}
