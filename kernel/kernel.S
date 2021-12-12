.include "board.inc"

.global _start
.global mmio_base
.global board_type

.org 0x8000

.section ".data"

mmio_base: .byte 0,0,0,0
board_type: .byte 0

.section ".text.boot"

_start:
	// disable all cores except core 0
	mrc p15,0,r5,c0,c0,5
	and r5,r5,#3
	cmp r5,#0
	bne halt

	// init stack
	mov sp,#0x8000
	
	// check board version
	mrc p15,0,r5,c0,c0,0

	// Rpi 1
	mov r4,#0xB76
	cmp r5,r4
	beq 1f

	// Rpi 2
	mov r4,#0xC07
	cmp r5,r4
	beq 2f

	// Rpi 3
	mov r4,#0xD03
	cmp r5,r4
	beq 3f

	// Rpi 4
	mov r4,#0xD08
	cmp r5,r4
	beq 3f

	// Unknown board
	mov r4,#0
	mov r3,#BOARD_UNK
	b 5f

1:
	mov r4,#0x20000000
	mov r3,#BOARD_RPI1
	b 5f
2:
	mov r4,#0x3F000000
	mov r3,#BOARD_RPI2
	b 5f
3:
	mov r4,#0x3F000000
	mov r3,#BOARD_RPI3
	b 5f
4:
	mov r4,#0xFE000000
	mov r3,#BOARD_RPI4
5:
	ldr r2,=mmio_base
	str r4,[r2]
	ldr r2,=board_type
	str r4,[r2]

	b kernel_entry

.section ".text"

kernel_entry:

halt:
	wfe
	b _start
