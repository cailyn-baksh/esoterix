.include "board.inc"
.include "utils.inc"

.global init_uart1
.global uart1_putc
.global uart1_puts

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
	gethwdata r4,"mmio_base"

	@ AUX_ENABLE register |= 1
	ldoffset r5,r4,#AUX_ENABLE_OFFSET
	ldr r6,[r5]
	orr r6,#1
	str r6,[r5]

	@ AUX_MU_CNTL register = 0
	ldoffset r5,r4,#AUX_MU_CNTL_OFFSET
	mov r6,#0
	str r6,[r5] 

	@ AUX_MU_LCR register = 3
	ldoffset r5,r4,#AUX_MU_LCR_OFFSET
	mov r6,#3
	str r6,[r5]

	@ AUX_MU_MCR register = 0
	ldoffset r5,r4,#AUX_MU_MCR_OFFSET
	mov r6,#0
	str r6,[r5]

	@ AUX_MU_IER reg = 0
	ldoffset r5,r4,#AUX_MU_IER_OFFSET
	mov r6,#0
	str r6,[r5]

	@ AUX1_MU_IIR reg = 0xc6
	ldoffset r5,r4,#AUX_MU_IIR_OFFSET
	mov r6,#0xc6
	str r6,[r5]

	@ set baud
	ldoffset r5,r4,#AUX_MU_BAUD_OFFSET
	mov r6,#270
	str r6,[r5]

	@ map to gpio pins 14 and 15
	ldoffset r5,r4,#GPFSEL1_OFFSET
	ldr r6,[r5]
	bic r6,r6,#0x3F000  @ clear bits 12 to 17
	orr r6,r6,#(2 << 12) | (2 << 15)
	str r6,[r5]

	ldoffset r5,r4,#GPPUD_OFFSET
	mov r6,#0
	str r6,[r5]

	push {r0, lr}
	mov r0,#150
	bl noploop
	pop {r0, lr}

	ldoffset r5,r4,#GPPUDCLK0_OFFSET
	mov r6,#(1 << 14) | (1 << 15)
	str r6,[r5]

	push {r0, lr}
	mov r0,#150
	bl noploop
	pop {r0, lr}

	mov r6,#0
	str r6,[r5]

	@ enable Tx, Rx
	ldoffset r5,r4,#AUX_MU_CNTL_OFFSET
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
	gethwdata r6,"mmio_base"

	ldoffset r4,r6,#AUX_MU_LSR_OFFSET

1:	nop
	ldr r5,[r4]
	tst r5,#0x20
	beq 1b  @ do while !(AUX_MU_LSR & 0x20)

	@ Write char
	ldoffset r4,r6,#AUX_MU_IO_OFFSET
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
	@ CRLF
	mov r0,#0x0D
	bl uart1_putc
	mov r0,#0x0A
	bl uart1_putc

	pop {r4}
	RESTOREFRAME
	bx lr

