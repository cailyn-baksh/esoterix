.include "board.inc"
.include "utils.inc"

.global init_uart1
.global uart1_putc

@ nops r0 times
noploop:
	bne _noploop_end
	subs r0,r0,#1
	nop
	b noploop

_noploop_end:
	bx lr

@ Initialize UART1. Takes MMIO base address in r0
init_uart1:
	stmia sp!, {r5, r6, sl, fp}

	@ AUX_ENABLE register |= 1
	ldoffset r5,r0,#AUX_ENABLE_OFFSET
	ldr r6,[r5]
	orr r6,#1
	str r6,[r5]

	@ AUX_MU_CNTL register = 0
	ldoffset r5,r0,#AUX_MU_CNTL_OFFSET
	mov r6,#0
	str r6,[r5] 

	@ AUX_MU_LCR register = 3
	ldoffset r5,r0,#AUX_MU_LCR_OFFSET
	mov r6,#3
	str r6,[r5]

	@ AUX_MU_MCR register = 0
	ldoffset r5,r0,#AUX_MU_MCR_OFFSET
	mov r6,#0
	str r6,[r5]

	@ AUX_MU_IER reg = 0
	ldoffset r5,r0,#AUX_MU_IER_OFFSET
	mov r6,#0
	str r6,[r5]

	@ AUX1_MU_IIR reg = 0xc6
	ldoffset r5,r0,#AUX_MU_IIR_OFFSET
	mov r6,#0xc6
	str r6,[r5]

	@ set baud
	ldoffset r5,r0,#AUX_MU_BAUD_OFFSET
	mov r6,#270
	str r6,[r5]

	@ map to gpio pins 14 and 15
	ldoffset r5,r0,#GPFSEL1_OFFSET
	ldr r6,[r5]
	bic r6,r6,#0x3F000  @ clear bits 12 to 17
	orr r6,r6,#(2 << 12) | (2 << 15)
	str r6,[r5]

	ldoffset r5,r0,#GPPUD_OFFSET
	mov r6,#0
	str r6,[r5]

	push {r0, lr}
	mov r0,#150
	bl noploop
	pop {r0, lr}

	ldoffset r5,r0,#GPPUDCLK0_OFFSET
	mov r6,#(1 << 14) | (1 << 15)
	str r6,[r5]

	push {r0, lr}
	mov r0,#150
	bl noploop
	pop {r0, lr}

	mov r6,#0
	str r6,[r5]

	@ enable Tx, Rx
	ldoffset r5,r0,#AUX_MU_CNTL_OFFSET
	mov r6,#3
	str r6,[r5]

0:	ldmia sp!, {r5, r6, sl, fp}
	bx lr


@ writes a character to uart1
@ takes the MMIO base addr in r0, the character in r1
uart1_putc:
	stmia sp!, {r4, r5, sl, fp}

	ldoffset r4,r0,#AUX_MU_LSR_OFFSET

1:	nop
	ldr r5,[r4]
	tst r5,#0x20
	beq 1b  @ do while !(AUX_MU_LSR & 0x20)

	@ Write char
	ldoffset r4,r0,#AUX_MU_IO_OFFSET
	str r1,[r4]

0:	ldmia sp!, {r4, r5, sl, fp}
	bx lr


