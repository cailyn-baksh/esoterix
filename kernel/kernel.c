#include <stdint.h>
#include <limits.h>

#include "common.h"
#include "board.h"
#include "kparams.h"
#include "uart.h"

#define NOEXTERN
#include "errno.h"
#undef NOEXTERN

uint32_t errno = ENONE;

uint32_t kernel_main(uint32_t r0, uint32_t r1, uint32_t r2, uint32_t r3) {
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

	handle_kernel_params(r2);

	const char *name = "cailyn";
	unsigned int nChars = 0;

	uart1_printf("Hello %s%c\r\n", name, '!');
	uart1_printf("%x %X%n\r\n", 0xbaddeed, 0xDEADACE, &nChars);
	uart1_printf("The last line was 0x%X chars long\r\n", nChars);
	uart1_printf("nChars is at address %p\r\n", &nChars);
	uart1_printf("8 in octal is %o, and 1 638 221 485 is %o (should be 14151243255)\r\n", 8, 1638221485);

	uart1_printf("%u\r\n", UINT_MAX);

	return 0;
}
