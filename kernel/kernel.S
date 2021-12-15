.include "board.inc"

.global _start
.global mmio_base
.global board_type

.extern read_atags

@@@@@   .rodata   @@@@@
.section ".rodata"

@ Hardware data structures.
@ These structures define hardware-specific constants for every
@ supported board
@
@ byte ID
@   Board identifier
@ dword MMIO_BASE
@   MMIO base address
@ str BOARD_NAME
@   null terminated string with board name. Since this is the last
@   element its size is irrelevant


@ Raspberry Pi 1
rpi1_data:
.byte BOARD_RPI1
.4byte 0x20000000
.asciz "Raspi1"

@ Raspberry Pi 2
rpi2_data:
.byte BOARD_RPI2
.4byte 0x3F000000
.asciz "Raspi2"

@ Raspberry Pi 3
rpi3_data:
.byte BOARD_RPI3
.4byte 0x3F000000
.asciz "Raspi3"

@ Raspberry Pi 4
rpi4_data:
.byte BOARD_RPI4
.4byte 0xFE000000
.asciz "Raspi4"

@@@@@    .data    @@@@@
.section ".data"

@ Address of hardware data struct
boardDataStructPtr: .4byte 0

@@@@@   Macros    @@@@@
@ Reads property from selected HWDATA struct into reg
.macro gethwdata reg:req property:req
	ldr \reg,=boardDataStructPtr
	.ifeqs "\property", "id"
		ldr \reg,[\reg]
	.else
	.ifeqs "\property", "mmio_base"
		ldr \reg,[\reg, #1]
	.else
	.ifeqs "\property", "board_name"
		ldr \reg,[\reg, #5]
	.endif  @ cant get .elseif to work with strings
	.endif
	.endif
.endm

@@@@@    .text    @@@@@
.section ".text"

_start:
	@ disable all cores except core 0
	mrc p15,0,r5,c0,c0,5
	ands r5,r5,#3
	bne halt  @ halt if corenum & 3 != 0

	@ init stack
	mov sp,#0x8000
	
	@ check board version
	mrc p15,0,r5,c0,c0,0

	@ Rpi 1
	mov r4,#0xB76
	cmp r5,r4
	beq 1f

	@ Rpi 2
	mov r4,#0xC07
	cmp r5,r4
	beq 2f

	@ Rpi 3
	mov r4,#0xD03
	cmp r5,r4	
	beq 3f

	@ Rpi 4
	mov r4,#0xD08
	cmp r5,r4
	beq 4f

	@ Unknown board
	b halt

1:
	ldr r3,=rpi1_data
	b 5f
2:
	ldr r3,=rpi2_data
	b 5f
3:
	ldr r3,=rpi3_data
	b 5f
4:
	ldr r3,=rpi4_data
5:
	ldr r4,=boardDataStructPtr
	str r3,[r4]

	@ handle ATAGs
	bl read_atags

	@ Set up UART1
	gethwdata r0,"mmio_base"

	b kernel_main

kernel_main:
	

halt:
	wfe
	b _start

