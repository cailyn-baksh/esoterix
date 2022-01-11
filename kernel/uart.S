#include "common.h"
#include "board.h"
#include "uart.h"

.global init_uart1
.global uart1_putc
.global uart1_puts
.global uart1_printhex
.global uart1_printf

.section ".text"

@ nops r0 times
noploop:
	bne _noploop_end
	subs r0,r0,#1
	nop
	b noploop

_noploop_end:
	bx lr

@ Initializes UART1
init_uart1:
	SAVEFRAME
	push {r4, r5, r6}

	@ Get MMIO base address
	ldr r4,=board  @ r4 = ptr to ptr to HWData struct
	ldr r4,[r4]  @ r4 = ptr to HWData struct
	ldr r4,[r4, #HWData_mmio_base_offset]	

	@ AUX_ENABLE register |= 1
	ldr r5,=AUX_ENABLE_OFFSET
	add r5,r4,r5
	
	ldr r6,[r5]
	orr r6,#1
	str r6,[r5]

	@ AUX_MU_CNTL register = 0
	ldr r5,=AUX_MU_CNTL_OFFSET
	add r5,r4,r5

	mov r6,#0
	str r6,[r5] 

	@ AUX_MU_LCR register = 3
	ldr r5,=AUX_MU_LCR_OFFSET
	add r5,r4,r5

	mov r6,#3
	str r6,[r5]

	@ AUX_MU_MCR register = 0
	ldr r5,=AUX_MU_MCR_OFFSET
	add r5,r4,r5

	mov r6,#0
	str r6,[r5]

	@ AUX_MU_IER reg = 0
	ldr r5,=AUX_MU_IER_OFFSET
	add r5,r4,r5

	mov r6,#0
	str r6,[r5]

	@ AUX1_MU_IIR reg = 0xc6
	ldr r5,=AUX_MU_IIR_OFFSET
	add r5,r4,r5

	mov r6,#0xc6
	str r6,[r5]

	@ set baud
	ldr r5,=AUX_MU_BAUD_OFFSET
	add r5,r4,r5

	ldr r6,=270
	str r6,[r5]

	@ map to gpio pins 14 and 15
	ldr r5,=GPFSEL1_OFFSET
	add r5,r4,r5

	ldr r6,[r5]
	bic r6,r6,#0x3F000  @ clear bits 12 to 17
	orr r6,r6,#(2 << 12) | (2 << 15)
	str r6,[r5]

	ldr r5,=GPPUD_OFFSET
	add r5,r4,r5

	mov r6,#0
	str r6,[r5]

	push {r0, lr}
	mov r0,#150
	bl noploop
	pop {r0, lr}

	ldr r5,=GPPUDCLK0_OFFSET
	add r5,r4,r5
	mov r6,#(1 << 14) | (1 << 15)
	str r6,[r5]

	push {r0, lr}
	mov r0,#150
	bl noploop
	pop {r0, lr}

	mov r6,#0
	str r6,[r5]

	@ enable Tx, Rx
	ldr r5,=AUX_MU_CNTL_OFFSET
	add r5,r4,r5
	mov r6,#3
	str r6,[r5]

0:
	pop {r4, r5, r6}
	RESTOREFRAME
	bx lr


@ writes a character to uart1
@ takes the character in r0
uart1_putc:
	SAVEFRAME
	push {r4, r5, r6}

	@ get MMIO base address
	ldr r6,=board  @ r6 = ptr to ptr to HWData struct
	ldr r6,[r6]  @ r6 = ptr to HWData struct
	ldr r6,[r6, #HWData_mmio_base_offset]

	ldr r4,=AUX_MU_LSR_OFFSET
	add r4,r6,r4

1:	nop
	ldr r5,[r4]
	tst r5,#0x20
	beq 1b  @ do while !(AUX_MU_LSR & 0x20)

	@ Write char
	ldr r4,=AUX_MU_IO_OFFSET
	add r4,r6,r4
	strb r0,[r4]

0:
	pop {r4, r5, r6}
	RESTOREFRAME
	bx lr

@ Writes a null-terminated string to uart1
@ Takes the address of the string in r0
uart1_puts:
	SAVEFRAME
	push {r4}
	mov r4,r0  @ put string addr in r4, so we dont have to push and mov each loop

1:
	ldrb r0,[r4]
	cmp r0,#0
	beq 0f  @ return at null terminator

	bl uart1_putc

	add r4,#1
	b 1b

0:
	pop {r4}
	RESTOREFRAME
	bx lr

@ Prints unsigned hex representation of r0 to uart1
uart1_printhex:
	SAVEFRAME
	mov r1,r0   @ r1 = word to print
	mov r2,#28  @ r2 = shift amount

1:
	mov r3,r1
	lsr r3,r3,r2  @ r3 >>= r2
	and r3,r3,#0xF  @ Clear high bits

	ldr r0,=hexchars  @ uart1_putc(*(&hexchars+r3))
	add r0,r0,r3
	ldrb r0,[r0]
	bl uart1_putc

	subs r2,r2,#4  @ Decrease shift amount (and update flags)
	bpl 1b  @ loop if r2 > 0

0:
	RESTOREFRAME
	bx lr
hexchars: .ascii "0123456789abcdef"

#define PRINTF_FLAG_LALIGN			0x01  // left align instead of right align
#define PRINTF_FLAG_SIGN			0x02  // Prepend + for positive numbers and - for negative numbers
#define PRINTF_FLAG_SIGN2			0x04  // Prepend ' ' for positive and - for negative. Overruled by PRINTF_FLAG_SIGN
#define PRINTF_FLAG_ZERO			0x08  // Prepend 0 for numeric types with width specified
#define PRINTF_FLAG_ALT_FORM		0x10  // Alternate form, determined by type field

#define PRINTF_DYNAMIC				0xFFFFFFFF

#define PRINTF_LEN_INT_CHAR			0x01  // For int types, int-sized arg promoted from char
#define PRINTF_LEN_INT_SHORT		0x02  // For int types, int-sized arg promoted from short
#define PRINTF_LEN_INT_LONG			0x03  // For int types, long-sized arg. Ignored by float types
#define PRINTF_LEN_INT_LONG_LONG	0x04  // For int types, long long-sized arg
#define PRINTF_LEN_INT_SIZE			0x05  // For int types, size_t-sized arg
#define PRINTF_LEN_INT_MAX			0x06  // For int types, intmax_t-sized arg
#define PRINTF_LEN_INT_PTRDIFF		0x07  // For int types, ptrdiff_t-sized arg
#define PRINTF_LEN_FLOAT_LONG		0x08  // For float types, long double-sized arg

@ void uart1_printf(const char *format, ...);
uart1_printf:
	push {r1-r3}  @ Push extra arguments onto stack
	mov r2,sp  @ remember where varargs begin
	push {r4-r8, lr}  @ Save registers

	mov r4,r0  @ r4 = pointer to format string
	mov r5,r2  @ r5 = pointer to next arg
	mov r6,#0  @ r6 = number of chars printed

1:
	ldrb r0,[r4],#1  @ read byte and increment ptr

	cmp r0,#0  @ Return on null terminator
	beq 0f
	cmp r0,#'%'  @ Format specifier
	beq 2f

	@ Print the char normally
	bl _uart1_printf_putc
	b 1b

2:
	ldrb r0,[r4],#1  @ read next char

	cmp r0,#0  @ Return on null terminator
	beq 0f
	cmp r0,#'d'  @ Signed integer
	cmpne r0,#'i'	
	cmp r0,#'u'  @ Unsigned integer
	cmp r0,#'x'  @ Hex uint (lower)
	cmp r0,#'X'  @ Hex uint (upper)
	cmp r0,#'o'  @ Octal uint
	cmp r0,#'s'  @ String
	beq _uart1_printf_fmtstr

	cmp r0,#'c'  @ Character
	cmp r0,#'p'  @ Pointer
	cmp r0,#'n'  @ Store number of chars printed

	b 1b
0:
	pop {r4-r8, lr}
	pop {r1-r3}
	bx lr

@ %s
_uart1_printf_fmtstr:
	ldr r1,[r5],#4  @ Load address of string and increment ptr to next arg

50:
	ldrb r0,[r1],#1  @ Load character

	cmp r0,#0
	beq 1b  @ Stop at null terminator
	
	bl _uart1_printf_putc  @ print char then loop
	b 50b

@ Prints individual character for uart1_printf
_uart1_printf_putc:
	push {lr}
	bl uart1_putc  @ print character
	add r6,r6,#1  @ increment chars printed counter
	pop {lr}
	bx lr

