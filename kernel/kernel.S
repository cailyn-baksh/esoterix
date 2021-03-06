#include "common.h"
#include "board.h"

.global _start
.global panic

@@@@@   .rodata   @@@@@
.section ".rodata"

CRLF: .byte 0xD,0xA,0x0
kPanicStr: .asciz "Kernel panic. Code %p%s"

@@@@@    .data    @@@@@
.section ".data"

@@@@@    .text    @@@@@
.section ".text.boot"

.org 0x8000
_start:
	@ disable all cores except core 0
	mrc p15,0,r5,c0,c0,5
	ands r5,r5,#3
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

	@ Enter kernel
	ldr r4,=kernel_main
	blx r4

halt:
	wfe
	b halt


.section ".text"

@ Prints error information to uart1 and halts kernel
@ Takes an error code in r0
@ When panic is called r10 will contain the error code,
@ even if panic fails later.
panic:
	mov r10,r0  @ Move r0 into r10 in case printing fails

	ldr r0,=kPanicStr
	ldr r1,=board
	ldr r2,=CRLF
	bl uart1_printf

	b halt

