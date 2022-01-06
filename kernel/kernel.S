#include "common.h"
#include "board.h"

.global _start

.extern read_atags
.extern init_uart1
.extern uart1_putc
.extern uart1_puts
.extern mbox_call

@@@@@   .rodata   @@@@@
.section ".rodata"

bootMsgStr: .asciz "Starting Esoterix v0.0.1"
failMsgStr: .asciz "mbox failed"
succMsgStr: .asciz "mbox success"

@@@@@    .data    @@@@@
.section ".data"

@@@@@    .text    @@@@@
.section ".text"

.org 0x8000
_start:
	@ disable all cores except core 0
	mrc p15,0,r5,c0,c0,5
	and r5,r5,#3
	cmp r5,#0
	bne halt  @ halt if corenum & 3 != 0

	@ init stack
	ldr r5,=_start
	mov sp,r5

	@ Clear bss
	ldr r4,=__bss_start
	ldr r9,=__bss_end
	mov r5,#0
	mov r6,#0
	mov r7,#0
	mov r8,#0
	b 2f

1:
	@ write r5-r8 starting at [r4]
	stmia r4!,{r5-r8}
2:
	@ loop if below __bss_end
	cmp r4,r9
	blo 1b
	
	@ check board version
	mrc p15,0,r5,c0,c0,0

	@ Rpi 1
	ldr r4,=0xB76
	cmp r5,r4
	beq 1f

	@ Rpi 2
	ldr r4,=0xC07
	cmp r5,r4
	beq 2f

	@ Rpi 3
	ldr r4,=0xD03
	cmp r5,r4	
	beq 3f

	@ Rpi 4
	ldr r4,=0xD08
	cmp r5,r4
	beq 4f

	@ Unknown board
	b 2f
	b halt

1:
@	ldr r3,=rpi1_data
@	b 5f
2:
@	ldr r3,=rpi2_data
@	b 5f
3:
@	ldr r3,=rpi3_data
@	b 5f
4:
@	ldr r3,=rpi4_data
5:
@	ldr r4,=boardDataStructPtr
@	str r3,[r4]

	@ handle ATAGs
	@bl read_atags

	@ Set up UART1
	bl init_uart1

	ldr r0,=bootMsgStr
	bl uart1_puts

	ldr r4,=kernel_main
	blx r3
	
halt:
	wfe
	b halt

