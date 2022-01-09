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

uart1_printf:
	push {r1-r3}  @ Push extra arguments onto stack
	mov r2,sp  @ r2 = start of varargs
	mov r1,r0  @ r1 = format string
	@ Save frame
	push {r4-r8, lr}

1:
	ldrb r0,[r1]
	add r1,r1,#1

	cmp r0,#0
	beq 0f  @ null terminator
	cmp r0,#'%'
	beq 2f  @ Format

	@ print the char normally
	bl uart1_putc
	b 1b

@ Format
2:
	@ r3 is a scratch register
	mov r4,#0  @ flags
	mov r5,#0  @ width
	mov r6,#0  @ precision
	mov r7,#0  @ length

3:  @ Flags field
	@ load next char
	ldrb r0,[r1]
	add r1,r1,#1

	cmp r0,#0  @ Null terminator
	beq 0f

	cmp r0,#'-'  @ left align flag
	orreq r4,r4,#PRINTF_FLAG_LALIGN
	beq 3b  @ check for another flag

	cmp r0,#'+'  @ Sign flag
	orreq r4,r4,#PRINTF_FLAG_SIGN
	beq 3b  @ check for another flag

	cmp r0,#' '  @ Alternate sign flag
	orreq r4,r4,#PRINTF_FLAG_SIGN2
	beq 3b  @ check for another flag

	cmp r0,#'0'  @ Zero flag
	orreq r4,r4,#PRINTF_FLAG_ZERO
	beq 3b  @ check for another flag

	cmp r0,#'#'  @ Alt flag
	orreq r4,r4,#PRINTF_FLAG_ALT_FORM
	beq 3b  @ check for another flag

4:  @ Width Field

	@ if r0 == '*' && r5 == 0
	cmp r0,#'*'  @ Dynamic value
	bne 5f  @ test numbers
	cmp r5,#0
	bne 1b  @ * is not valid here, stop interpreting format string

	mov r5,#PRINTF_DYNAMIC

	@ Read next char and continue to the next field
	ldrb r0,[r1]
	add r1,r1,#1

	cmp r0,#0  @ return on null terminator
	beq 0f

	b 6f

5:	@ else if r0 >= '0' && r0 <= '9'

	cmp r0,#'0'
	blt 6f
	cmp r0,#'9'
	bgt 6f

	mov r3,#10  @ r5 = r5 * 10
	mul r5,r5,r3
	sub r3,r0,#0x30 @ r5 = r5 + int(r0)
	add r5,r5,r3

	@ load next char and check again
	ldrb r0,[r1]
	add r1,r1,#1

	cmp r0,#0  @ null terminator
	beq 0f

	b 4b

6:  @ precision field
	cmp r0,#'.'
	bne 9f  @ no precision field

	@ load next char
	ldrb r0,[r1]
	add r1,r1,#1
	cmp r0,#0  @ return on null terminator
	beq 0f

7:
	@ if r0 == '*' && r6 == 0
	cmp r0,#'*'  @ Dynamic value
	bne 8f  @ test for numbers
	cmp r6,#0
	bne 1b  @ * is not valid here, stop interpreting format string

	@ Dynamic value
	mov r5,#PRINTF_DYNAMIC

	@ Load next char and move to next field
	ldrb r0,[r1]
	add r1,r1,#1

	cmp r0,#0  @ Return on null terminator
	beq 0f

	b 9f

8:  @ else if r0 >= '0' && r0 <= '9'
	cmp r0,#'0'
	blt 9f
	cmp r0,#'9'
	bgt 9f

	mov r3,#10  @ r6 = r6 * 10
	mul r6,r6,r3
	sub r3,r0,#0x30  @ r6 = r6 + int(r0)
	add r6,r6,r3

	@ load next char and check again
	ldrb r0,[r1]
	add r1,r1,#1

	cmp r0,#0  @ return on null terminator
	beq 0f

	b 7b

9:  @ length field
	@ if r0 == 'h'
	@   if r7 != PRINTF_LEN_INT_SHORT
	@     r7 = PRINTF_LEN_INT_SHORT
	@     read next char
	@     b 9b
	@   elif r7 == PRINTF_LEN_INT_SHORT
	@     r7 = PRINTF_LEN_INT_CHAR
	@     read next char
	@     b 10f
	@ if r0 == 'l'
	@   if r7 != PRINTF_LEN_INT_LONG
	@     r7 = PRINTF_LEN_INT_LONG
	@     read next char
	@     b 9b
	@   elif r7 != 0
	@     r7 = PRINTF_LEN_INT_LONG_LONG
	@     read next char
	@     b 10f
	@ if r7 != 0
	@   invalid
	@
	@ if r0 == 'z'
	@   r7 = PRINTF_LEN_INT_SIZE
	@ if r0 == 'j'
	@   r7 = PRINTF_LEN_INT_MAX
	@ if r0 == 't'
	@   r7 = PRINTF_LEN_INT_PTRDIFF
	@ if r0 == 'L'
	@   r7 = PRINTF_LEN_FLOAT_LONG
	@
	@ read next char

	cmp r0,#0  @ return on null terminator
	beq 0f

	@ if r0 == 'h'
	cmp r0,#'h'
	bne 10f  @ go to next if
	@ if r7 != PRINTF_LEN_INT_SHORT
	cmp r7,#PRINTF_LEN_INT_SHORT
	movne r7,#PRINTF_LEN_INT_SHORT
	ldrbne r0,[r1]  @ Read next character
	addne r1,r1,#1
	bne 9b
	@ elif r7 == PRINTF_LEN_INT_SHORT
	moveq r7,#PRINTF_LEN_INT_CHAR
	ldrbeq r0,[r1]  @ Read next character
	addeq r1,r1,#1
	beq 12f

10:	@ elif r0 == 'l'
	cmp r0,#'l'
	bne 11f  @ go to next if
	@ if r7 != PRINTF_LEN_INT_LONG
	cmp r7,#PRINTF_LEN_INT_LONG
	movne r7,#PRINTF_LEN_INT_LONG
	ldrbne r0,[r1]  @ Read next character
	addne r1,r1,#1
	bne 9b
	@ elif r7 == PRINTF_LEN_INT_LONG
	moveq r7,#PRINTF_LEN_INT_LONG_LONG
	ldrbeq r0,[r1]  @ Read next character
	addeq r1,r1,#1
	beq 12f
	
11:
	cmp r7,#0
	bne 1b  @ Invalid format

	cmp r0,#'z'
	moveq r7,#PRINTF_LEN_INT_SIZE
	cmp r0,#'j'
	moveq r7,#PRINTF_LEN_INT_MAX
	cmp r0,#'t'
	moveq r7,#PRINTF_LEN_INT_PTRDIFF
	cmp r0,#'L'
	moveq r7,#PRINTF_LEN_FLOAT_LONG

	ldrb r0,[r1]
	add r1,r1,#1

12:  @ Type field
	cmp r0,#0
	beq 0f  @ Return on null terminator

	cmp r0,#'%'
	@ Literal %
	cmp r0,#'d'
	cmpne r0,#'i'
	@ signed integer
	cmp r0,#'u'
	@ unsigned integer
	cmp r0,#'f'
	@ double in fixed-point notation (lowercase)
	cmp r0,#'F'
	@ double in fixed point notation (uppercase)
	cmp r0,#'e'
	@ double in standard form (lowercase)
	cmp r0,#'E'
	@ double in standard form (uppercase)
	cmp r0,#'g'
	@ double (infer notation) (lowercase)
	cmp r0,#'G'
	@ double (infer notation) (uppercase)
	cmp r0,#'x'
	@ hex unsigned int (lowercase)
	cmp r0,#'X'
	@ hex unsigned int (uppercase)
	cmp r0,#'o'
	@ octal unsigned int
	cmp r0,#'s'
	@ string
	cmp r0,#'c'
	@ char
	cmp r0,#'p'
	@ void *
	cmp r0,#'a'
	@ hexfloat (lowercase)
	cmp r0,#'A'
	@ hexfloat (uppercase)
	cmp r0,#'n'
	@ write # of character printed to int ptr

	@ Print formatted output
	b 1b

0:
	pop {r4-r8, lr}
	pop {r1-r3}
	bx lr

