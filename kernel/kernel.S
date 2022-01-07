#include "common.h"
#include "board.h"

.global _start

.extern read_atags
.extern init_uart1
.extern uart1_putc
.extern uart1_puts
.extern uart1_printhex
.extern mbox_call

@@@@@   .rodata   @@@@@
.section ".rodata"

CRLF: .byte 0xD,0xA,0x0
kExitMsgStr: .asciz "Kernel exited with code "
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
	
	@ store board version in r3
	mrc p15,0,r3,c0,c0,0

	ldr r4,=kernel_main
	blx r4

	@ handle ATAGs
	@bl read_atags

	@ Notify kernel exit
	push {r0}
	ldr r0,=kExitMsgStr
	bl uart1_puts
	pop {r0}
	bl uart1_printhex
	ldr r0,=CRLF
	bl uart1_puts

halt:
	wfe
	b halt

