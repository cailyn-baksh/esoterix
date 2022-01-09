#ifndef _UART_H_
#define _UART_H_

#define AUX_ENABLE_OFFSET			0x00215004
#define AUX_MU_IO_OFFSET			0x00215040
#define AUX_MU_IIR_OFFSET			0x00215044
#define AUX_MU_IER_OFFSET			0x00215048
#define AUX_MU_LCR_OFFSET			0x0021504C
#define AUX_MU_MCR_OFFSET			0x00215050
#define AUX_MU_LSR_OFFSET			0x00215054
#define AUX_MU_MSR_OFFSET			0x00215058

#define AUX_MU_SCRATCH_OFFSET		0x0021505C
#define AUX_MU_CNTL_OFFSET			0x00215060
#define AUX_MU_STAT_OFFSET			0x00215064
#define AUX_MU_BAUD_OFFSET			0x00215068

#ifdef __ASSEMBLER__
/* ASM */

#else
/* C */

#include <stdint.h>

void init_uart1(void);
void uart1_putc(char);
void uart1_puts(char *);
void uart1_printhex(uint32_t val);

#endif  // __ASSEMBLER__

#endif  // _UART_H_

