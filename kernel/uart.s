.include "board.inc"
.include "utils.inc"

.global init_uart1

@ Initialize UART1. Takes MMIO base address in r0
init_uart1:
	stmia sp!, {r5, r6, sl, fp}

	@ UART1_ENABLE register |= 1
	ldoffset r5,r0,#UART1_ENABLE_OFFSET
	ldr r6,[r5]
	orr r6,#1
	str r6,[r5]

	@ UART1_MU_CTRL register = 0
	ldoffset r5,r0,#UART1_MU_CTRL_OFFSET
	mov r6,#0
	str r6,[r5] 

	@ UART1_MU_LCR register = 3
	ldoffset r5,r0,#UART1_MU_LCR_OFFSET
	mov r6,#3
	str r6,[r5]

	@ UART1_MU_MCR register = 0
	ldoffset r5,r0,#UART1_MU_MCR_OFFSET
	mov r6,#0
	str r6,[r5]

	@ UART1_MU_IER reg = 0
	ldoffset r5,r0,#UART1_MU_IER_OFFSET
	mov r6,#0
	str r6,[r5]

	@ UART1_MU_IIR reg = 0xc6
	ldoffset r5,r0,#UART1_MU_IIR_OFFSET
	mov r6,#0xc6
	str r6,[r5]

	@ set baud
	ldoffset r5,r0,#UART1_MU_BAUD_OFFSET
	mov r6,#270
	str r6,[r5]

0:	ldmia sp!, {r5, r6, sl, fp}
	bx lr
